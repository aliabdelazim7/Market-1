-- Market 1 / Mido Market
-- Multi-warehouse foundation: main warehouses, sub-warehouses, scoped access,
-- and stock issue requests. All IDs are text-compatible with the existing schema.

create extension if not exists pgcrypto;

-- 1) Warehouse hierarchy
alter table if exists public.warehouses
  add column if not exists parent_warehouse_id text,
  add column if not exists warehouse_type text default 'sub',
  add column if not exists governorate text,
  add column if not exists is_active boolean default true;

update public.warehouses
set warehouse_type = case when coalesce(is_default, false) then 'main' else coalesce(warehouse_type, 'sub') end
where warehouse_type is null or warehouse_type not in ('main', 'sub');

alter table if exists public.warehouses
  drop constraint if exists warehouses_warehouse_type_check;
alter table if exists public.warehouses
  add constraint warehouses_warehouse_type_check
  check (warehouse_type in ('main', 'sub'));

alter table if exists public.warehouses
  drop constraint if exists warehouses_parent_not_self;
alter table if exists public.warehouses
  add constraint warehouses_parent_not_self
  check (parent_warehouse_id is null or parent_warehouse_id <> id);

create index if not exists warehouses_parent_idx on public.warehouses(parent_warehouse_id);
create index if not exists warehouses_type_idx on public.warehouses(warehouse_type);

-- Seed the two agreed main warehouses only when they do not already exist.
insert into public.warehouses (id, name, code, governorate, warehouse_type, is_active, is_default)
select gen_random_uuid()::text, 'مخزن طنطا', 'TANTA-MAIN', 'الغربية', 'main', true, false
where not exists (select 1 from public.warehouses where code = 'TANTA-MAIN');

insert into public.warehouses (id, name, code, governorate, warehouse_type, is_active, is_default)
select gen_random_uuid()::text, 'مخزن إسكندرية', 'ALEX-MAIN', 'الإسكندرية', 'main', true, false
where not exists (select 1 from public.warehouses where code = 'ALEX-MAIN');

-- 2) User-to-warehouse access. A user may be assigned to multiple branches.
create table if not exists public.admin_warehouse_access (
  id text primary key default gen_random_uuid()::text,
  admin_user_id text not null,
  warehouse_id text not null,
  access_role text not null default 'operator',
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  unique (admin_user_id, warehouse_id),
  check (access_role in ('viewer', 'operator', 'warehouse_manager', 'director'))
);

create index if not exists admin_warehouse_access_user_idx
  on public.admin_warehouse_access(admin_user_id);
create index if not exists admin_warehouse_access_warehouse_idx
  on public.admin_warehouse_access(warehouse_id);

-- 3) Stock issue requests: request first, inventory movement later.
create table if not exists public.stock_issue_requests (
  id text primary key default gen_random_uuid()::text,
  request_number text not null unique,
  source_warehouse_id text not null,
  target_warehouse_id text not null,
  requested_by text,
  approved_by text,
  dispatched_by text,
  received_by text,
  status text not null default 'draft',
  notes text,
  rejection_reason text,
  requested_at timestamptz not null default now(),
  approved_at timestamptz,
  dispatched_at timestamptz,
  received_at timestamptz,
  cancelled_at timestamptz,
  created_at timestamptz not null default now(),
  check (source_warehouse_id <> target_warehouse_id),
  check (status in ('draft', 'submitted', 'approved', 'dispatched', 'received', 'rejected', 'cancelled'))
);

create table if not exists public.stock_issue_request_items (
  id text primary key default gen_random_uuid()::text,
  request_id text not null,
  product_id text not null,
  requested_quantity numeric not null,
  approved_quantity numeric,
  dispatched_quantity numeric,
  received_quantity numeric,
  notes text,
  created_at timestamptz not null default now(),
  check (requested_quantity > 0),
  check (approved_quantity is null or approved_quantity >= 0),
  check (dispatched_quantity is null or dispatched_quantity >= 0),
  check (received_quantity is null or received_quantity >= 0)
);

create index if not exists stock_issue_requests_source_idx
  on public.stock_issue_requests(source_warehouse_id, status, created_at desc);
create index if not exists stock_issue_requests_target_idx
  on public.stock_issue_requests(target_warehouse_id, status, created_at desc);
create index if not exists stock_issue_request_items_request_idx
  on public.stock_issue_request_items(request_id);

-- 4) Read-only helper for branch users: own stock plus the parent main warehouse stock.
create or replace function public.get_warehouse_scope(p_warehouse_id text)
returns table (
  warehouse_id text,
  warehouse_name text,
  warehouse_type text,
  parent_warehouse_id text,
  stock_visible boolean
)
language sql
security definer
set search_path = public
as $$
  select w.id, w.name, w.warehouse_type, w.parent_warehouse_id, true
  from public.warehouses w
  where w.id = p_warehouse_id
     or w.id = (select parent_warehouse_id from public.warehouses where id = p_warehouse_id)
  order by case when w.id = p_warehouse_id then 0 else 1 end, w.name;
$$;

revoke all on function public.get_warehouse_scope(text) from public;
grant execute on function public.get_warehouse_scope(text) to authenticated;

-- 5) Request number generator, safe under concurrent users.
create or replace function public.next_stock_issue_request_number()
returns text
language plpgsql
security definer
set search_path = public
as $$
declare
  n bigint;
begin
  perform pg_advisory_xact_lock(hashtext('market1-stock-issue-request-number'));
  select coalesce(max(nullif(regexp_replace(request_number, '\D', '', 'g'), '')::bigint), 0) + 1
    into n
  from public.stock_issue_requests;
  return 'REQ-' || lpad(n::text, 6, '0');
end;
$$;

revoke all on function public.next_stock_issue_request_number() from public;
grant execute on function public.next_stock_issue_request_number() to authenticated;

-- RLS is enabled, but policies remain deliberately minimal here because the app
-- currently uses authenticated Supabase access. Scope enforcement is added in the
-- transactional RPC migration after the existing auth/session shape is confirmed.
alter table public.admin_warehouse_access enable row level security;
alter table public.stock_issue_requests enable row level security;
alter table public.stock_issue_request_items enable row level security;

drop policy if exists "authenticated warehouse access" on public.admin_warehouse_access;
create policy "authenticated warehouse access" on public.admin_warehouse_access
  for all to authenticated using (true) with check (true);

drop policy if exists "authenticated stock issue requests" on public.stock_issue_requests;
create policy "authenticated stock issue requests" on public.stock_issue_requests
  for all to authenticated using (true) with check (true);

drop policy if exists "authenticated stock issue request items" on public.stock_issue_request_items;
create policy "authenticated stock issue request items" on public.stock_issue_request_items
  for all to authenticated using (true) with check (true);

notify pgrst, 'reload schema';

-- Expected first-run result: two main warehouses exist, and the three new tables
-- are available. Do not delete existing warehouse or stock rows.
select
  (select count(*) from public.warehouses where warehouse_type = 'main') as main_warehouses,
  (select count(*) from public.admin_warehouse_access) as warehouse_access_rows,
  (select count(*) from public.stock_issue_requests) as stock_issue_requests;

comment on table public.stock_issue_requests is 'طلبات صرف مخزون من مخزن مصدر إلى مخزن مستهدف؛ لا حركة مخزون قبل الصرف والاستلام.';
comment on column public.warehouses.parent_warehouse_id is 'المخزن الرئيسي الأب للمخزن الفرعي.';
comment on column public.warehouses.warehouse_type is 'main للمخزن الرئيسي، sub للمخزن الفرعي.';
comment on column public.admin_warehouse_access.access_role is 'صلاحية المستخدم داخل مخزن محدد.';

notify pgrst, 'reload schema';

-- End of migration 82.
-- Use db/83_multi_warehouse_atomic_workflow.sql for the movement RPCs after this foundation is applied.
