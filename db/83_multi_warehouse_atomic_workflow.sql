-- Market 1 / Mido Market
-- Atomic workflow for stock issue requests.
-- Run after db/82_multi_warehouse_foundation.sql.

create extension if not exists pgcrypto;

-- The legacy schema did not always define a unique warehouse/product key.
-- Consolidate legacy duplicates before enabling the atomic upsert used below.
with grouped as (
  select warehouse_id, product_id, min(ctid) as keeper, sum(coalesce(stock_quantity, 0)) as total
  from public.warehouse_stock
  where warehouse_id is not null and product_id is not null
  group by warehouse_id, product_id
  having count(*) > 1
)
update public.warehouse_stock ws
set stock_quantity = grouped.total
from grouped
where ws.ctid = grouped.keeper;

delete from public.warehouse_stock ws
using (
  select ctid,
         row_number() over (partition by warehouse_id, product_id order by created_at nulls first, ctid) as rn
  from public.warehouse_stock
  where warehouse_id is not null and product_id is not null
) duplicates
where ws.ctid = duplicates.ctid and duplicates.rn > 1;

create unique index if not exists warehouse_stock_warehouse_product_uidx
  on public.warehouse_stock(warehouse_id, product_id)
  where warehouse_id is not null and product_id is not null;

-- Create a request and its lines in one transaction.
create or replace function public.create_stock_issue_request(
  p_source_warehouse_id text,
  p_target_warehouse_id text,
  p_requested_by text,
  p_items jsonb,
  p_notes text default null
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_request_id text := gen_random_uuid()::text;
  v_request_number text := public.next_stock_issue_request_number();
  v_item jsonb;
  v_qty numeric;
  v_product_id text;
  v_source_exists boolean;
  v_target_exists boolean;
begin
  if p_source_warehouse_id is null or p_target_warehouse_id is null
     or p_source_warehouse_id = p_target_warehouse_id then
    raise exception 'INVALID_WAREHOUSE_ROUTE';
  end if;

  if p_items is null or jsonb_typeof(p_items) <> 'array' or jsonb_array_length(p_items) = 0 then
    raise exception 'EMPTY_REQUEST_ITEMS';
  end if;

  select exists(select 1 from public.warehouses where id = p_source_warehouse_id and coalesce(is_active, true)),
         exists(select 1 from public.warehouses where id = p_target_warehouse_id and coalesce(is_active, true))
    into v_source_exists, v_target_exists;
  if not v_source_exists or not v_target_exists then raise exception 'WAREHOUSE_NOT_FOUND'; end if;

  insert into public.stock_issue_requests
    (id, request_number, source_warehouse_id, target_warehouse_id, requested_by, status, notes)
  values
    (v_request_id, v_request_number, p_source_warehouse_id, p_target_warehouse_id, p_requested_by, 'submitted', p_notes);

  for v_item in select * from jsonb_array_elements(p_items) loop
    v_product_id := nullif(v_item->>'product_id', '');
    v_qty := (v_item->>'quantity')::numeric;
    if v_product_id is null or v_qty is null or v_qty <= 0 then
      raise exception 'INVALID_REQUEST_ITEM';
    end if;
    insert into public.stock_issue_request_items (id, request_id, product_id, requested_quantity)
    values (gen_random_uuid()::text, v_request_id, v_product_id, v_qty);
  end loop;

  return jsonb_build_object('id', v_request_id, 'request_number', v_request_number, 'status', 'submitted');
end;
$$;

-- Approve a submitted request. Approval does not move stock.
create or replace function public.approve_stock_issue_request(
  p_request_id text,
  p_approved_by text,
  p_items jsonb default null
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_request public.stock_issue_requests%rowtype;
  v_item jsonb;
  v_qty numeric;
  v_product_id text;
begin
  select * into v_request from public.stock_issue_requests where id = p_request_id for update;
  if not found then raise exception 'REQUEST_NOT_FOUND'; end if;
  if v_request.status <> 'submitted' then raise exception 'REQUEST_NOT_SUBMITTED'; end if;

  if p_items is null then
    update public.stock_issue_request_items
      set approved_quantity = requested_quantity
      where request_id = p_request_id;
  else
    for v_item in select * from jsonb_array_elements(p_items) loop
      v_product_id := nullif(v_item->>'product_id', '');
      v_qty := (v_item->>'quantity')::numeric;
      if v_product_id is null or v_qty is null or v_qty < 0 then raise exception 'INVALID_APPROVED_ITEM'; end if;
      update public.stock_issue_request_items
        set approved_quantity = v_qty
        where request_id = p_request_id and product_id = v_product_id;
      if not found then raise exception 'APPROVED_ITEM_NOT_IN_REQUEST'; end if;
    end loop;
  end if;

  update public.stock_issue_requests
    set status = 'approved', approved_by = p_approved_by, approved_at = now()
    where id = p_request_id;
  return jsonb_build_object('id', p_request_id, 'status', 'approved');
end;
$$;

-- Dispatch: lock source stock rows, verify every line, decrement source once,
-- and mark the quantities in transit. No partial dispatch is possible.
create or replace function public.dispatch_stock_issue_request(
  p_request_id text,
  p_dispatched_by text
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_request public.stock_issue_requests%rowtype;
  v_item record;
  v_available numeric;
  v_qty numeric;
begin
  select * into v_request from public.stock_issue_requests where id = p_request_id for update;
  if not found then raise exception 'REQUEST_NOT_FOUND'; end if;
  if v_request.status <> 'approved' then raise exception 'REQUEST_NOT_APPROVED'; end if;

  for v_item in
    select i.*, coalesce(i.approved_quantity, i.requested_quantity) as qty
    from public.stock_issue_request_items i
    where i.request_id = p_request_id
    order by i.product_id
  loop
    v_qty := coalesce(v_item.qty, 0);
    if v_qty <= 0 then continue; end if;

    insert into public.warehouse_stock (id, warehouse_id, product_id, stock_quantity, min_stock)
    values (gen_random_uuid()::text, v_request.source_warehouse_id, v_item.product_id, 0, 0)
    on conflict (warehouse_id, product_id) do nothing;

    select stock_quantity into v_available
      from public.warehouse_stock
      where warehouse_id = v_request.source_warehouse_id and product_id = v_item.product_id
      for update;
    if coalesce(v_available, 0) < v_qty then
      raise exception 'INSUFFICIENT_STOCK:%:%', v_item.product_id, v_available;
    end if;

    update public.warehouse_stock
      set stock_quantity = stock_quantity - v_qty
      where warehouse_id = v_request.source_warehouse_id and product_id = v_item.product_id;

    update public.stock_issue_request_items
      set dispatched_quantity = v_qty
      where id = v_item.id;

    insert into public.stock_movement_logs
      (id, product_id, warehouse_id, type, quantity, reference_type, reference_id, notes)
    values
      (gen_random_uuid()::text, v_item.product_id, v_request.source_warehouse_id, 'transfer', -v_qty,
       'stock_issue_request', p_request_id, 'صرف من المخزن المصدر إلى شحنة قيد النقل');
  end loop;

  update public.stock_issue_requests
    set status = 'dispatched', dispatched_by = p_dispatched_by, dispatched_at = now()
    where id = p_request_id;
  return jsonb_build_object('id', p_request_id, 'status', 'dispatched');
end;
$$;

-- Receive: lock the request, add only dispatched quantities to target once,
-- and make the receipt operation idempotent by requiring dispatched status.
create or replace function public.receive_stock_issue_request(
  p_request_id text,
  p_received_by text
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_request public.stock_issue_requests%rowtype;
  v_item record;
  v_qty numeric;
begin
  select * into v_request from public.stock_issue_requests where id = p_request_id for update;
  if not found then raise exception 'REQUEST_NOT_FOUND'; end if;
  if v_request.status <> 'dispatched' then raise exception 'REQUEST_NOT_DISPATCHED'; end if;

  for v_item in
    select i.*, coalesce(i.dispatched_quantity, 0) as qty
    from public.stock_issue_request_items i
    where i.request_id = p_request_id
    order by i.product_id
  loop
    v_qty := coalesce(v_item.qty, 0);
    if v_qty <= 0 then continue; end if;

    insert into public.warehouse_stock (id, warehouse_id, product_id, stock_quantity, min_stock)
    values (gen_random_uuid()::text, v_request.target_warehouse_id, v_item.product_id, v_qty, 0)
    on conflict (warehouse_id, product_id)
    do update set stock_quantity = public.warehouse_stock.stock_quantity + excluded.stock_quantity;

    update public.stock_issue_request_items
      set received_quantity = v_qty
      where id = v_item.id;

    insert into public.stock_movement_logs
      (id, product_id, warehouse_id, type, quantity, reference_type, reference_id, notes)
    values
      (gen_random_uuid()::text, v_item.product_id, v_request.target_warehouse_id, 'transfer', v_qty,
       'stock_issue_request', p_request_id, 'استلام شحنة محولة من المخزن المصدر');
  end loop;

  update public.stock_issue_requests
    set status = 'received', received_by = p_received_by, received_at = now()
    where id = p_request_id;
  return jsonb_build_object('id', p_request_id, 'status', 'received');
end;
$$;

revoke all on function public.create_stock_issue_request(text,text,text,jsonb,text) from public;
revoke all on function public.approve_stock_issue_request(text,text,jsonb) from public;
revoke all on function public.dispatch_stock_issue_request(text,text) from public;
revoke all on function public.receive_stock_issue_request(text,text) from public;
grant execute on function public.create_stock_issue_request(text,text,text,jsonb,text) to authenticated;
grant execute on function public.approve_stock_issue_request(text,text,jsonb) to authenticated;
grant execute on function public.dispatch_stock_issue_request(text,text) to authenticated;
grant execute on function public.receive_stock_issue_request(text,text) to authenticated;

notify pgrst, 'reload schema';

-- End of migration 83.
