-- Market 1 compatible schema
-- Safe: creates missing tables and columns only; does not drop or delete data.

create extension if not exists pgcrypto;

alter table if exists categories add column if not exists name text;

create table if not exists products (
  id text primary key default (gen_random_uuid())::text,
  name text not null,
  barcode text unique,
  image_url text,
  purchase_price numeric default 0,
  average_purchase_price numeric default 0,
  sale_price numeric default 0,
  discount_price numeric default 0,
  wholesale_price numeric default 0,
  half_wholesale_price numeric default 0,
  season text,
  stock_quantity numeric default 0,
  display_quantity numeric default 0,
  unit text not null default 'قطعة',
  category_id text references categories(id) on delete set null,
  is_hidden boolean default false,
  created_at timestamptz default now()
);

create table if not exists customers (
  id text primary key default (gen_random_uuid())::text,
  custom_id text unique,
  name text not null default 'بدون اسم',
  phone text unique,
  card_number text,
  created_at timestamptz default now()
);

create table if not exists suppliers (
  id text primary key default (gen_random_uuid())::text,
  name text not null,
  phone text,
  address text,
  created_at timestamptz default now()
);

create table if not exists purchase_invoices (
  id text primary key default (gen_random_uuid())::text,
  invoice_number text not null,
  supplier_id text references suppliers(id) on delete set null,
  total numeric not null default 0,
  paid_amount numeric default 0,
  paid_cash numeric default 0,
  paid_visa numeric default 0,
  paid_wallet numeric default 0,
  paid_instapay numeric default 0,
  payment_method text default 'cash',
  notes text,
  created_at timestamptz default now()
);

create table if not exists purchase_items (
  id text primary key default (gen_random_uuid())::text,
  invoice_id text references purchase_invoices(id) on delete cascade,
  product_id text references products(id) on delete set null,
  quantity numeric not null default 1,
  purchase_price numeric not null default 0
);

create table if not exists orders (
  id text primary key,
  total numeric not null default 0,
  paid_amount numeric default 0,
  paid_cash numeric default 0,
  paid_visa numeric default 0,
  paid_wallet numeric default 0,
  paid_instapay numeric default 0,
  payment_method text default 'cash',
  refund_method text,
  type text default 'sale',
  customer_id text references customers(id) on delete set null,
  cashier_name text,
  discount_amount numeric default 0,
  is_deleted boolean not null default false,
  deleted_at timestamptz,
  deletion_reason text,
  notes text,
  client_ref text,
  created_at timestamptz default now()
);

create unique index if not exists uq_orders_client_ref on orders(client_ref) where client_ref is not null;

create table if not exists order_items (
  id text primary key default (gen_random_uuid())::text,
  order_id text references orders(id) on delete cascade,
  product_id text references products(id) on delete set null,
  product_name text not null,
  barcode text,
  quantity numeric default 1,
  returned_quantity numeric default 0,
  refunded_amount numeric default 0,
  sale_price numeric default 0,
  purchase_price numeric default 0
);

create table if not exists invoice_counter (
  id int primary key default 1,
  current_value integer default 1,
  check (id = 1)
);
insert into invoice_counter(id,current_value) values (1,1) on conflict (id) do nothing;

create table if not exists expenses (
  id text primary key default (gen_random_uuid())::text,
  category text not null,
  amount numeric not null default 0,
  note text,
  payment_method text default 'cash',
  paid_cash numeric default 0,
  paid_visa numeric default 0,
  paid_wallet numeric default 0,
  paid_instapay numeric default 0,
  created_at timestamptz default now()
);

create table if not exists cashiers (
  id text primary key default (gen_random_uuid())::text,
  name text not null,
  password text,
  pin text,
  phone text,
  photo_url text,
  email text,
  full_access boolean default false,
  created_at timestamptz default now()
);

create index if not exists idx_products_created_at on products(created_at);
create index if not exists idx_orders_created_at on orders(created_at);
create index if not exists idx_order_items_order_id on order_items(order_id);
create index if not exists idx_purchase_items_invoice_id on purchase_items(invoice_id);

-- Enable access for the app. Tighten these policies later when auth roles are finalized.
do $$ declare t text; begin
  foreach t in array array['categories','products','customers','suppliers','purchase_invoices','purchase_items','orders','order_items','invoice_counter','expenses','cashiers'] loop
    execute format('alter table %I enable row level security', t);
    execute format('drop policy if exists app_anon_all on %I', t);
    execute format('create policy app_anon_all on %I for all to anon, authenticated using (true) with check (true)', t);
    execute format('grant all on table %I to anon, authenticated', t);
  end loop;
end $$;

select table_name from information_schema.tables
where table_schema='public'
  and table_name in ('categories','products','customers','suppliers','purchase_invoices','purchase_items','orders','order_items','invoice_counter','expenses','cashiers')
order by table_name;

select table_name, column_name, data_type, udt_name
from information_schema.columns
where table_schema='public'
  and table_name in ('categories','products','orders','order_items')
  and column_name in ('id','category_id','customer_id','order_id','product_id')
order by table_name, column_name;

-- IMPORTANT: create_sale_atomic must be applied only after this schema succeeds.
-- Its product_id/order_id/customer_id types must match these text-based IDs.

-- End of migration.

-- NOTE: The final SELECT statements are read-only verification queries.
