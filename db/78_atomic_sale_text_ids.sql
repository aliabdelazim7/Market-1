-- Market 1 — Atomic Sale RPC for text-based IDs
-- Safe to run after db/02_schema_compatible_text_ids.sql.
-- Does not delete or reset existing data.

create extension if not exists pgcrypto;

-- Ensure the invoice counter exists without resetting its current value.
create table if not exists invoice_counter (
  id int primary key default 1,
  current_value integer not null default 1,
  check (id = 1)
);

insert into invoice_counter (id, current_value)
values (
  1,
  coalesce((select max(id::bigint) + 1 from orders where id ~ '^[0-9]+$'), 1)
)
on conflict (id) do nothing;

-- Keep the counter ahead of existing numeric invoice IDs.
update invoice_counter
set current_value = greatest(
  current_value,
  coalesce((select max(id::bigint) + 1 from orders where id ~ '^[0-9]+$'), 1)
)
where id = 1;

create or replace function next_invoice_number()
returns integer
language plpgsql
security definer
set search_path = public
as $$
declare
  v integer;
begin
  update invoice_counter
  set current_value = current_value + 1
  where id = 1
  returning current_value - 1 into v;

  if v is null then
    insert into invoice_counter (id, current_value)
    values (1, 2)
    on conflict (id) do update
      set current_value = invoice_counter.current_value + 1
    returning current_value - 1 into v;
  end if;

  while exists (select 1 from orders where id = v::text) loop
    update invoice_counter
    set current_value = current_value + 1
    where id = 1
    returning current_value - 1 into v;
  end loop;

  return v;
end;
$$;

grant execute on function next_invoice_number() to anon, authenticated;

create or replace function create_sale_atomic(
  p_order jsonb,
  p_items jsonb
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_client_ref text;
  v_order_id text;
  v_type text;
  v_total numeric;
  v_item record;
  v_product record;
  v_requested numeric;
  v_existing orders%rowtype;
begin
  if coalesce(jsonb_typeof(p_items), 'null') <> 'array'
     or jsonb_array_length(p_items) = 0 then
    raise exception 'EMPTY_SALE_ITEMS' using errcode = '22023';
  end if;

  v_client_ref := nullif(trim(p_order->>'client_ref'), '');
  v_type := coalesce(nullif(p_order->>'type', ''), 'sale');

  if v_type <> 'sale' then
    raise exception 'ATOMIC_SALE_ONLY_SUPPORTS_SALE_TYPE' using errcode = '22023';
  end if;

  -- Idempotency: a retried request returns the original order and never touches stock again.
  if v_client_ref is not null then
    select * into v_existing
    from orders
    where client_ref = v_client_ref
    limit 1;

    if found then
      return jsonb_build_object(
        'duplicate', true,
        'order', to_jsonb(v_existing)
      );
    end if;
  end if;

  -- Validate all quantities before writing anything.
  for v_item in
    select
      nullif(trim(x.product_id), '') as product_id,
      coalesce(x.quantity, 0)::numeric as quantity
    from jsonb_to_recordset(p_items) as x(
      product_id text,
      quantity numeric,
      product_name text,
      barcode text,
      sale_price numeric,
      purchase_price numeric
    )
  loop
    if v_item.product_id is null or v_item.quantity <= 0 then
      raise exception 'INVALID_SALE_ITEM' using errcode = '22023';
    end if;
  end loop;

  -- Lock products in deterministic ID order, aggregate duplicate cart lines,
  -- and reject overselling instead of clamping stock to zero.
  for v_item in
    select x.product_id, sum(x.quantity)::numeric as quantity
    from jsonb_to_recordset(p_items) as x(
      product_id text,
      quantity numeric,
      product_name text,
      barcode text,
      sale_price numeric,
      purchase_price numeric
    )
    group by x.product_id
    order by x.product_id
  loop
    select id, stock_quantity
      into v_product
    from products
    where id = v_item.product_id
    for update;

    if not found then
      raise exception 'PRODUCT_NOT_FOUND:%', v_item.product_id using errcode = '23503';
    end if;

    if coalesce(v_product.stock_quantity, 0) < v_item.quantity then
      raise exception 'INSUFFICIENT_STOCK:%:available=%:requested=%',
        v_item.product_id,
        coalesce(v_product.stock_quantity, 0),
        v_item.quantity
        using errcode = '23514';
    end if;
  end loop;

  v_order_id := next_invoice_number()::text;
  v_total := coalesce((p_order->>'total')::numeric, 0);

  insert into orders (
    id, total, paid_amount, paid_cash, paid_visa, paid_wallet, paid_instapay,
    payment_method, type, customer_id, cashier_name, discount_amount, notes,
    client_ref, created_at
  ) values (
    v_order_id,
    v_total,
    coalesce((p_order->>'paid_amount')::numeric, 0),
    coalesce((p_order->>'paid_cash')::numeric, 0),
    coalesce((p_order->>'paid_visa')::numeric, 0),
    coalesce((p_order->>'paid_wallet')::numeric, 0),
    coalesce((p_order->>'paid_instapay')::numeric, 0),
    coalesce(nullif(p_order->>'payment_method', ''), 'cash'),
    v_type,
    nullif(p_order->>'customer_id', ''),
    nullif(p_order->>'cashier_name', ''),
    coalesce((p_order->>'discount_amount')::numeric, 0),
    p_order->>'notes',
    v_client_ref,
    coalesce((p_order->>'created_at')::timestamptz, now())
  );

  insert into order_items (
    order_id, product_id, product_name, barcode, quantity, sale_price, purchase_price
  )
  select
    v_order_id,
    x.product_id,
    coalesce(x.product_name, p.name),
    x.barcode,
    x.quantity,
    coalesce(x.sale_price, 0),
    coalesce(x.purchase_price, p.average_purchase_price, p.purchase_price, 0)
  from jsonb_to_recordset(p_items) as x(
    product_id text,
    quantity numeric,
    product_name text,
    barcode text,
    sale_price numeric,
    purchase_price numeric
  )
  join products p on p.id = x.product_id;

  -- This update is safe because every product row was locked and validated above.
  for v_item in
    select x.product_id, sum(x.quantity)::numeric as quantity
    from jsonb_to_recordset(p_items) as x(
      product_id text,
      quantity numeric,
      product_name text,
      barcode text,
      sale_price numeric,
      purchase_price numeric
    )
    group by x.product_id
  loop
    update products
    set stock_quantity = stock_quantity - v_item.quantity,
        display_quantity = greatest(0, coalesce(display_quantity, stock_quantity) - v_item.quantity)
    where id = v_item.product_id;
  end loop;

  select * into v_existing from orders where id = v_order_id;

  return jsonb_build_object(
    'duplicate', false,
    'order', to_jsonb(v_existing)
  );
end;
$$;

grant execute on function create_sale_atomic(jsonb, jsonb) to anon, authenticated;
notify pgrst, 'reload schema';

-- Read-only verification.
select proname, pg_get_function_identity_arguments(oid) as arguments
from pg_proc
where proname in ('next_invoice_number', 'create_sale_atomic')
order by proname;
