-- Market 1: customers, drivers, GPS visits and delivery statuses
-- Idempotent migration; text IDs are used throughout.

alter table public.customers add column if not exists address text;
alter table public.customers add column if not exists governorate text;
alter table public.customers add column if not exists location_url text;
alter table public.customers add column if not exists latitude numeric;
alter table public.customers add column if not exists longitude numeric;
alter table public.customers add column if not exists institution_type text;
alter table public.customers add column if not exists assigned_driver_id text;
alter table public.customers add column if not exists notes text;

create table if not exists public.drivers (
  id text primary key default gen_random_uuid()::text,
  name text not null,
  phone text,
  national_id text,
  active boolean not null default true,
  default_warehouse_id text,
  created_at timestamptz not null default now()
);

create table if not exists public.customer_visits (
  id text primary key default gen_random_uuid()::text,
  customer_id text not null,
  driver_id text,
  visit_type text not null default 'delivery',
  status text not null default 'assigned',
  notes text,
  assigned_at timestamptz not null default now(),
  on_the_way_at timestamptz,
  arrived_at timestamptz,
  completed_at timestamptz,
  cancelled_at timestamptz,
  assigned_latitude numeric,
  assigned_longitude numeric,
  current_latitude numeric,
  current_longitude numeric,
  created_at timestamptz not null default now(),
  check (visit_type in ('delivery','sales_visit','collection','other')),
  check (status in ('assigned','on_the_way','arrived','completed','cancelled','failed','rescheduled'))
);

create index if not exists customers_phone_idx on public.customers(phone);
create index if not exists customers_governorate_idx on public.customers(governorate);
create index if not exists customers_driver_idx on public.customers(assigned_driver_id);
create index if not exists drivers_active_idx on public.drivers(active);
create index if not exists customer_visits_driver_status_idx on public.customer_visits(driver_id,status,created_at desc);
create index if not exists customer_visits_customer_idx on public.customer_visits(customer_id,created_at desc);

create or replace function public.update_customer_visit_status(
  p_visit_id text,
  p_status text,
  p_latitude numeric default null,
  p_longitude numeric default null,
  p_notes text default null
)
returns public.customer_visits
language plpgsql
security definer
set search_path = public
as $$
declare v public.customer_visits;
begin
  if p_status not in ('assigned','on_the_way','arrived','completed','cancelled','failed','rescheduled') then
    raise exception 'invalid visit status';
  end if;
  update public.customer_visits
  set status = p_status,
      current_latitude = coalesce(p_latitude,current_latitude),
      current_longitude = coalesce(p_longitude,current_longitude),
      notes = coalesce(p_notes,notes),
      on_the_way_at = case when p_status='on_the_way' and on_the_way_at is null then now() else on_the_way_at end,
      arrived_at = case when p_status='arrived' and arrived_at is null then now() else arrived_at end,
      completed_at = case when p_status='completed' and completed_at is null then now() else completed_at end,
      cancelled_at = case when p_status='cancelled' and cancelled_at is null then now() else cancelled_at end
  where id = p_visit_id
  returning * into v;
  if not found then raise exception 'visit not found'; end if;
  return v;
end;
$$;

grant execute on function public.update_customer_visit_status(text,text,numeric,numeric,text) to authenticated;
notify pgrst, 'reload schema';
-- End migration 84.
