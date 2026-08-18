-- إصلاح آمن لمشكلة NULL في أعمدة id عند إدخال سجلات جديدة
-- لا يحذف أو يعدّل أي بيانات موجودة.
create extension if not exists pgcrypto;

do $$
declare
  tbl text;
  id_type text;
begin
  foreach tbl in array array[
    'categories','products','customers','suppliers','cashiers',
    'orders','expenses','employees','store_settings'
  ] loop
    if exists (
      select 1 from information_schema.columns
      where table_schema = 'public'
        and table_name = tbl
        and column_name = 'id'
    ) then
      select data_type into id_type
      from information_schema.columns
      where table_schema = 'public'
        and table_name = tbl
        and column_name = 'id';

      if id_type = 'uuid' then
        execute format(
          'alter table public.%I alter column id set default gen_random_uuid()',
          tbl
        );
      else
        execute format(
          'alter table public.%I alter column id set default gen_random_uuid()::text',
          tbl
        );
      end if;
    end if;
  end loop;
end $$;
-- CRM-MOB-Market / Market-1 database installation bundle
-- Generated from the repository SQL files.
-- Run in Supabase SQL Editor on a new project.
-- Do not run this bundle against a production database without a backup.
create extension if not exists pgcrypto;
create extension if not exists "uuid-ossp";


-- ==========================================================================
-- SOURCE: db/00_MASTER_SCHEMA_RECONCILIATION.sql
-- ==========================================================================

-- =============================================================================
-- HANCES PRO — MASTER SCHEMA RECONCILIATION SCRIPT (حل جذري شامل)
-- =============================================================================
--  هذا الملف يضمن وجود جميع الجداول والأعمدة الـ 44 الخاصة بالنظام بالكامل.
--  آمن للتشغيل في أي وقت (Idempotent)، ولا يمس البيانات الحالية إطلاقاً.
-- =============================================================================

-- ── حظر التعارضات مع الـ Views القديمة إن وجدت ─────────────────────────────────
drop view if exists v_stock_gap cascade;

-- ── Table: products ─────────────────────────────────────────
create table if not exists products (id text primary key, created_at timestamptz default now());
alter table products add column if not exists name text;
alter table products add column if not exists barcode text;
alter table products add column if not exists image_url text;
alter table products add column if not exists purchase_price numeric default 0;
alter table products add column if not exists average_purchase_price numeric default 0;
alter table products add column if not exists sale_price numeric default 0;
alter table products add column if not exists discount_price numeric default 0;
alter table products add column if not exists wholesale_price numeric default 0;
alter table products add column if not exists half_wholesale_price numeric default 0;
alter table products add column if not exists season text;
alter table products add column if not exists stock_quantity numeric default 0;
alter table products add column if not exists display_quantity numeric default 0;
alter table products add column if not exists factory_quantity numeric default 0;
alter table products add column if not exists category_id text;
alter table products add column if not exists unit text;
alter table products add column if not exists is_hidden boolean default false;
alter table products add column if not exists color text;
alter table products add column if not exists supplier_name text;
alter table products add column if not exists website_ad_cost numeric default 0;
alter table products add column if not exists amazon_price numeric default 0;
alter table products add column if not exists amazon_discount_price numeric default 0;
alter table products add column if not exists amazon_commission numeric default 0;
alter table products add column if not exists amazon_ad_cost numeric default 0;
alter table products add column if not exists amazon_shipping numeric default 0;
alter table products add column if not exists noon_price numeric default 0;
alter table products add column if not exists noon_discount_price numeric default 0;
alter table products add column if not exists noon_commission numeric default 0;
alter table products add column if not exists noon_shipping numeric default 0;
alter table products add column if not exists noon_ad_cost numeric default 0;
alter table products add column if not exists jumia_price numeric default 0;
alter table products add column if not exists jumia_discount_price numeric default 0;
alter table products add column if not exists jumia_commission numeric default 0;
alter table products add column if not exists jumia_shipping numeric default 0;
alter table products add column if not exists jumia_ad_cost numeric default 0;
alter table products add column if not exists custom_stores jsonb;
alter table products enable row level security;
drop policy if exists "allow_all_anon_authenticated" on products;
create policy "allow_all_anon_authenticated" on products for all to anon, authenticated using (true) with check (true);
grant all on products to anon, authenticated;

-- ── Table: materials ─────────────────────────────────────────
create table if not exists materials (id text primary key, created_at timestamptz default now());
alter table materials add column if not exists name text;
alter table materials add column if not exists unit text;
alter table materials add column if not exists cost_per_unit numeric default 0;
alter table materials add column if not exists stock_quantity numeric default 0;
alter table materials add column if not exists supplier_id text;
alter table materials add column if not exists created_at text;
alter table materials enable row level security;
drop policy if exists "allow_all_anon_authenticated" on materials;
create policy "allow_all_anon_authenticated" on materials for all to anon, authenticated using (true) with check (true);
grant all on materials to anon, authenticated;

-- ── Table: production_orders ─────────────────────────────────────────
create table if not exists production_orders (id text primary key, created_at timestamptz default now());
alter table production_orders add column if not exists product_id text;
alter table production_orders add column if not exists product_name text;
alter table production_orders add column if not exists color text;
alter table production_orders add column if not exists code text;
alter table production_orders add column if not exists quantity numeric default 0;
alter table production_orders add column if not exists materials_cost numeric default 0;
alter table production_orders add column if not exists extra_costs numeric default 0;
alter table production_orders add column if not exists total_cost numeric default 0;
alter table production_orders add column if not exists cost_per_piece numeric default 0;
alter table production_orders add column if not exists sale_price numeric default 0;
alter table production_orders add column if not exists notes text;
alter table production_orders add column if not exists created_at text;
alter table production_orders enable row level security;
drop policy if exists "allow_all_anon_authenticated" on production_orders;
create policy "allow_all_anon_authenticated" on production_orders for all to anon, authenticated using (true) with check (true);
grant all on production_orders to anon, authenticated;

-- ── Table: devo_items ─────────────────────────────────────────
create table if not exists devo_items (id text primary key, created_at timestamptz default now());
alter table devo_items add column if not exists product_id text;
alter table devo_items add column if not exists product_name text;
alter table devo_items add column if not exists barcode text;
alter table devo_items add column if not exists quantity numeric default 0;
alter table devo_items add column if not exists unit_cost numeric default 0;
alter table devo_items add column if not exists supplier_id text;
alter table devo_items add column if not exists supplier_name text;
alter table devo_items add column if not exists reason text;
alter table devo_items add column if not exists status text;
alter table devo_items add column if not exists note text;
alter table devo_items add column if not exists created_at text;
alter table devo_items add column if not exists updated_at text;
alter table devo_items enable row level security;
drop policy if exists "allow_all_anon_authenticated" on devo_items;
create policy "allow_all_anon_authenticated" on devo_items for all to anon, authenticated using (true) with check (true);
grant all on devo_items to anon, authenticated;

-- ── Table: write_offs ─────────────────────────────────────────
create table if not exists write_offs (id text primary key, created_at timestamptz default now());
alter table write_offs add column if not exists product_id text;
alter table write_offs add column if not exists product_name text;
alter table write_offs add column if not exists barcode text;
alter table write_offs add column if not exists quantity numeric default 0;
alter table write_offs add column if not exists unit_cost numeric default 0;
alter table write_offs add column if not exists total_cost numeric default 0;
alter table write_offs add column if not exists reason text;
alter table write_offs add column if not exists created_at text;
alter table write_offs enable row level security;
drop policy if exists "allow_all_anon_authenticated" on write_offs;
create policy "allow_all_anon_authenticated" on write_offs for all to anon, authenticated using (true) with check (true);
grant all on write_offs to anon, authenticated;

-- ── Table: categories ─────────────────────────────────────────
create table if not exists categories (id text primary key, created_at timestamptz default now());
alter table categories add column if not exists name text;
alter table categories add column if not exists image_url text;
alter table categories enable row level security;
drop policy if exists "allow_all_anon_authenticated" on categories;
create policy "allow_all_anon_authenticated" on categories for all to anon, authenticated using (true) with check (true);
grant all on categories to anon, authenticated;

-- ── Table: customers ─────────────────────────────────────────
create table if not exists customers (id text primary key, created_at timestamptz default now());
alter table customers add column if not exists name text;
alter table customers add column if not exists phone text;
alter table customers add column if not exists timestamp text;
alter table customers add column if not exists custom_id text;
alter table customers add column if not exists card_number text;
alter table customers enable row level security;
drop policy if exists "allow_all_anon_authenticated" on customers;
create policy "allow_all_anon_authenticated" on customers for all to anon, authenticated using (true) with check (true);
grant all on customers to anon, authenticated;

-- ── Table: suppliers ─────────────────────────────────────────
create table if not exists suppliers (id text primary key, created_at timestamptz default now());
alter table suppliers add column if not exists name text;
alter table suppliers add column if not exists phone text;
alter table suppliers add column if not exists address text;
alter table suppliers add column if not exists balance numeric default 0;
alter table suppliers add column if not exists created_at text;
alter table suppliers enable row level security;
drop policy if exists "allow_all_anon_authenticated" on suppliers;
create policy "allow_all_anon_authenticated" on suppliers for all to anon, authenticated using (true) with check (true);
grant all on suppliers to anon, authenticated;

-- ── Table: cashiers ─────────────────────────────────────────
create table if not exists cashiers (id text primary key, created_at timestamptz default now());
alter table cashiers add column if not exists name text;
alter table cashiers add column if not exists password text;
alter table cashiers add column if not exists pin text;
alter table cashiers add column if not exists phone text;
alter table cashiers add column if not exists photo_url text;
alter table cashiers add column if not exists created_at text;
alter table cashiers add column if not exists email text;
alter table cashiers add column if not exists full_access boolean default false;
alter table cashiers enable row level security;
drop policy if exists "allow_all_anon_authenticated" on cashiers;
create policy "allow_all_anon_authenticated" on cashiers for all to anon, authenticated using (true) with check (true);
grant all on cashiers to anon, authenticated;

-- ── Table: purchase_invoices ─────────────────────────────────────────
create table if not exists purchase_invoices (id text primary key, created_at timestamptz default now());
alter table purchase_invoices add column if not exists invoice_number text;
alter table purchase_invoices add column if not exists supplier_id text;
alter table purchase_invoices add column if not exists total numeric default 0;
alter table purchase_invoices add column if not exists paid_amount numeric default 0;
alter table purchase_invoices add column if not exists paid_cash numeric default 0;
alter table purchase_invoices add column if not exists paid_visa numeric default 0;
alter table purchase_invoices add column if not exists paid_wallet numeric default 0;
alter table purchase_invoices add column if not exists paid_instapay numeric default 0;
alter table purchase_invoices add column if not exists paid_method5 numeric default 0;
alter table purchase_invoices add column if not exists paid_method6 numeric default 0;
alter table purchase_invoices add column if not exists payment_method text;
alter table purchase_invoices add column if not exists created_at text;
alter table purchase_invoices add column if not exists notes text;
alter table purchase_invoices add column if not exists source_invoice_id text;
alter table purchase_invoices add column if not exists items text;
alter table purchase_invoices enable row level security;
drop policy if exists "allow_all_anon_authenticated" on purchase_invoices;
create policy "allow_all_anon_authenticated" on purchase_invoices for all to anon, authenticated using (true) with check (true);
grant all on purchase_invoices to anon, authenticated;

-- ── Table: purchase_items ─────────────────────────────────────────
create table if not exists purchase_items (id text primary key, created_at timestamptz default now());
alter table purchase_items add column if not exists product_id text;
alter table purchase_items add column if not exists quantity numeric default 0;
alter table purchase_items add column if not exists purchase_price numeric default 0;
alter table purchase_items add column if not exists to_display numeric default 0;
alter table purchase_items enable row level security;
drop policy if exists "allow_all_anon_authenticated" on purchase_items;
create policy "allow_all_anon_authenticated" on purchase_items for all to anon, authenticated using (true) with check (true);
grant all on purchase_items to anon, authenticated;

-- ── Table: stock_intakes ─────────────────────────────────────────
create table if not exists stock_intakes (id text primary key, created_at timestamptz default now());
alter table stock_intakes add column if not exists product_id text;
alter table stock_intakes add column if not exists product_name text;
alter table stock_intakes add column if not exists quantity numeric default 0;
alter table stock_intakes add column if not exists unit_cost numeric default 0;
alter table stock_intakes add column if not exists total_value numeric default 0;
alter table stock_intakes add column if not exists source text;
alter table stock_intakes add column if not exists note text;
alter table stock_intakes add column if not exists created_at text;
alter table stock_intakes enable row level security;
drop policy if exists "allow_all_anon_authenticated" on stock_intakes;
create policy "allow_all_anon_authenticated" on stock_intakes for all to anon, authenticated using (true) with check (true);
grant all on stock_intakes to anon, authenticated;

-- ── Table: orders ─────────────────────────────────────────
create table if not exists orders (id text primary key, created_at timestamptz default now());
alter table orders add column if not exists items text;
alter table orders add column if not exists total numeric default 0;
alter table orders add column if not exists paid_amount numeric default 0;
alter table orders add column if not exists paid_cash numeric default 0;
alter table orders add column if not exists paid_visa numeric default 0;
alter table orders add column if not exists paid_wallet numeric default 0;
alter table orders add column if not exists paid_instapay numeric default 0;
alter table orders add column if not exists paid_method5 numeric default 0;
alter table orders add column if not exists paid_method6 numeric default 0;
alter table orders add column if not exists type text;
alter table orders add column if not exists date text;
alter table orders add column if not exists payment_method text;
alter table orders add column if not exists refund_method text;
alter table orders add column if not exists refunded_cash numeric default 0;
alter table orders add column if not exists refunded_visa numeric default 0;
alter table orders add column if not exists refunded_wallet numeric default 0;
alter table orders add column if not exists refunded_instapay numeric default 0;
alter table orders add column if not exists refunded_method5 numeric default 0;
alter table orders add column if not exists refunded_method6 numeric default 0;
alter table orders add column if not exists refunded_at text;
alter table orders add column if not exists customer text;
alter table orders add column if not exists cashier_name text;
alter table orders add column if not exists salesperson_id text;
alter table orders add column if not exists salesperson_name text;
alter table orders add column if not exists sales_channel text;
alter table orders add column if not exists platform_name text;
alter table orders add column if not exists isOffline boolean default false;
alter table orders add column if not exists is_deleted boolean default false;
alter table orders add column if not exists deleted_at text;
alter table orders add column if not exists deletion_reason text;
alter table orders add column if not exists notes text;
alter table orders add column if not exists coupon_code text;
alter table orders add column if not exists discount_amount numeric default 0;
alter table orders add column if not exists car_id text;
alter table orders add column if not exists exchange_data text;
alter table orders enable row level security;
drop policy if exists "allow_all_anon_authenticated" on orders;
create policy "allow_all_anon_authenticated" on orders for all to anon, authenticated using (true) with check (true);
grant all on orders to anon, authenticated;

-- ── Table: held_invoices ─────────────────────────────────────────
create table if not exists held_invoices (id text primary key, created_at timestamptz default now());
alter table held_invoices add column if not exists customer_name text;
alter table held_invoices add column if not exists customer_phone text;
alter table held_invoices add column if not exists customer_custom_id text;
alter table held_invoices add column if not exists items text;
alter table held_invoices add column if not exists total numeric default 0;
alter table held_invoices add column if not exists invoice_type text;
alter table held_invoices add column if not exists salesperson_id text;
alter table held_invoices add column if not exists salesperson_name text;
alter table held_invoices add column if not exists cashier_name text;
alter table held_invoices add column if not exists notes text;
alter table held_invoices add column if not exists deposit numeric default 0;
alter table held_invoices add column if not exists deposit_split numeric default 0;
alter table held_invoices add column if not exists created_at text;
alter table held_invoices add column if not exists expires_at text;
alter table held_invoices add column if not exists customer_address text;
alter table held_invoices add column if not exists shipping_note text;
alter table held_invoices add column if not exists kind text;
alter table held_invoices add column if not exists status text;
alter table held_invoices add column if not exists return_data text;
alter table held_invoices add column if not exists returned_at text;
alter table held_invoices add column if not exists shipping_return_cost numeric default 0;
alter table held_invoices add column if not exists order_id text;
alter table held_invoices add column if not exists status_at text;
alter table held_invoices add column if not exists status_note text;
alter table held_invoices enable row level security;
drop policy if exists "allow_all_anon_authenticated" on held_invoices;
create policy "allow_all_anon_authenticated" on held_invoices for all to anon, authenticated using (true) with check (true);
grant all on held_invoices to anon, authenticated;

-- ── Table: expenses ─────────────────────────────────────────
create table if not exists expenses (id text primary key, created_at timestamptz default now());
alter table expenses add column if not exists category text;
alter table expenses add column if not exists amount numeric default 0;
alter table expenses add column if not exists paid_cash numeric default 0;
alter table expenses add column if not exists paid_visa numeric default 0;
alter table expenses add column if not exists paid_wallet numeric default 0;
alter table expenses add column if not exists paid_instapay numeric default 0;
alter table expenses add column if not exists paid_method5 numeric default 0;
alter table expenses add column if not exists paid_method6 numeric default 0;
alter table expenses add column if not exists note text;
alter table expenses add column if not exists payment_method text;
alter table expenses add column if not exists date text;
alter table expenses add column if not exists car_id text;
alter table expenses add column if not exists employee_transaction_id text;
alter table expenses enable row level security;
drop policy if exists "allow_all_anon_authenticated" on expenses;
create policy "allow_all_anon_authenticated" on expenses for all to anon, authenticated using (true) with check (true);
grant all on expenses to anon, authenticated;

-- ── Table: car_subscriptions ─────────────────────────────────────────
create table if not exists car_subscriptions (id text primary key, created_at timestamptz default now());
alter table car_subscriptions add column if not exists car_number text;
alter table car_subscriptions add column if not exists car_details text;
alter table car_subscriptions add column if not exists customer_name text;
alter table car_subscriptions add column if not exists customer_phone text;
alter table car_subscriptions add column if not exists created_at text;
alter table car_subscriptions add column if not exists status text;
alter table car_subscriptions add column if not exists subscription_duration_months numeric default 0;
alter table car_subscriptions add column if not exists subscription_frequency_days numeric default 0;
alter table car_subscriptions enable row level security;
drop policy if exists "allow_all_anon_authenticated" on car_subscriptions;
create policy "allow_all_anon_authenticated" on car_subscriptions for all to anon, authenticated using (true) with check (true);
grant all on car_subscriptions to anon, authenticated;

-- ── Table: maintenance_appointments ─────────────────────────────────────────
create table if not exists maintenance_appointments (id text primary key, created_at timestamptz default now());
alter table maintenance_appointments add column if not exists subscription_id text;
alter table maintenance_appointments add column if not exists appointment_date text;
alter table maintenance_appointments add column if not exists description text;
alter table maintenance_appointments add column if not exists report text;
alter table maintenance_appointments add column if not exists cost numeric default 0;
alter table maintenance_appointments add column if not exists status text;
alter table maintenance_appointments add column if not exists is_reminded boolean default false;
alter table maintenance_appointments add column if not exists created_at text;
alter table maintenance_appointments enable row level security;
drop policy if exists "allow_all_anon_authenticated" on maintenance_appointments;
create policy "allow_all_anon_authenticated" on maintenance_appointments for all to anon, authenticated using (true) with check (true);
grant all on maintenance_appointments to anon, authenticated;

-- ── Table: financing_accounts ─────────────────────────────────────────
create table if not exists financing_accounts (id text primary key, created_at timestamptz default now());
alter table financing_accounts add column if not exists type text;
alter table financing_accounts add column if not exists lender_name text;
alter table financing_accounts add column if not exists lender_phone text;
alter table financing_accounts add column if not exists lender_details text;
alter table financing_accounts add column if not exists description text;
alter table financing_accounts add column if not exists principal_amount numeric default 0;
alter table financing_accounts add column if not exists collection_amount numeric default 0;
alter table financing_accounts add column if not exists collection_date text;
alter table financing_accounts add column if not exists installment_count numeric default 0;
alter table financing_accounts add column if not exists status text;
alter table financing_accounts add column if not exists created_at text;
alter table financing_accounts enable row level security;
drop policy if exists "allow_all_anon_authenticated" on financing_accounts;
create policy "allow_all_anon_authenticated" on financing_accounts for all to anon, authenticated using (true) with check (true);
grant all on financing_accounts to anon, authenticated;

-- ── Table: financing_payments ─────────────────────────────────────────
create table if not exists financing_payments (id text primary key, created_at timestamptz default now());
alter table financing_payments add column if not exists account_id text;
alter table financing_payments add column if not exists payment_type text;
alter table financing_payments add column if not exists due_date text;
alter table financing_payments add column if not exists amount numeric default 0;
alter table financing_payments add column if not exists paid_amount numeric default 0;
alter table financing_payments add column if not exists remaining_amount numeric default 0;
alter table financing_payments add column if not exists status text;
alter table financing_payments add column if not exists paid_at text;
alter table financing_payments add column if not exists expense_id text;
alter table financing_payments add column if not exists note text;
alter table financing_payments enable row level security;
drop policy if exists "allow_all_anon_authenticated" on financing_payments;
create policy "allow_all_anon_authenticated" on financing_payments for all to anon, authenticated using (true) with check (true);
grant all on financing_payments to anon, authenticated;

-- ── Table: financing_transactions ─────────────────────────────────────────
create table if not exists financing_transactions (id text primary key, created_at timestamptz default now());
alter table financing_transactions add column if not exists account_id text;
alter table financing_transactions add column if not exists payment_id text;
alter table financing_transactions add column if not exists transaction_type text;
alter table financing_transactions add column if not exists amount numeric default 0;
alter table financing_transactions add column if not exists remaining_after numeric default 0;
alter table financing_transactions add column if not exists payment_method text;
alter table financing_transactions add column if not exists expense_id text;
alter table financing_transactions add column if not exists note text;
alter table financing_transactions add column if not exists created_at text;
alter table financing_transactions enable row level security;
drop policy if exists "allow_all_anon_authenticated" on financing_transactions;
create policy "allow_all_anon_authenticated" on financing_transactions for all to anon, authenticated using (true) with check (true);
grant all on financing_transactions to anon, authenticated;

-- ── Table: store_settings ─────────────────────────────────────────
create table if not exists store_settings (id text primary key, created_at timestamptz default now());
alter table store_settings add column if not exists name text;
alter table store_settings add column if not exists currency text;
alter table store_settings add column if not exists logo text;
alter table store_settings add column if not exists taxRate numeric default 0;
alter table store_settings add column if not exists themeColor text;
alter table store_settings add column if not exists address text;
alter table store_settings add column if not exists phone text;
alter table store_settings add column if not exists phone2 text;
alter table store_settings add column if not exists whatsappCountryCode text;
alter table store_settings add column if not exists initial_balance numeric default 0;
alter table store_settings add column if not exists locationUrl text;
alter table store_settings add column if not exists cashierPermissions boolean default false;
alter table store_settings add column if not exists paymentLabels jsonb;
alter table store_settings add column if not exists paymentMethodsEnabled boolean default false;
alter table store_settings add column if not exists paymentOpeningBalances numeric default 0;
alter table store_settings add column if not exists savingsOpeningBalances numeric default 0;
alter table store_settings add column if not exists showInvoiceProfit boolean default false;
alter table store_settings add column if not exists allowCashierEmployeeAdvance boolean default false;
alter table store_settings add column if not exists dayStartHour numeric default 0;
alter table store_settings add column if not exists expenseCategories text;
alter table store_settings add column if not exists incomeCategories text;
alter table store_settings add column if not exists pagesQrUrl text;
alter table store_settings add column if not exists pagesQrLabel text;
alter table store_settings add column if not exists pagesQrImage text;
alter table store_settings enable row level security;
drop policy if exists "allow_all_anon_authenticated" on store_settings;
create policy "allow_all_anon_authenticated" on store_settings for all to anon, authenticated using (true) with check (true);
grant all on store_settings to anon, authenticated;

-- ── Table: employees ─────────────────────────────────────────
create table if not exists employees (id text primary key, created_at timestamptz default now());
alter table employees add column if not exists name text;
alter table employees add column if not exists job_title text;
alter table employees add column if not exists phone text;
alter table employees add column if not exists working_hours text;
alter table employees add column if not exists monthly_salary numeric default 0;
alter table employees add column if not exists annual_leave_balance numeric default 0;
alter table employees add column if not exists monthly_leave_days numeric default 0;
alter table employees add column if not exists shift_start text;
alter table employees add column if not exists shift_end text;
alter table employees add column if not exists late_grace_minutes numeric default 0;
alter table employees add column if not exists friday_shift_start text;
alter table employees add column if not exists friday_shift_end text;
alter table employees add column if not exists friday_is_off boolean default false;
alter table employees add column if not exists hire_date text;
alter table employees add column if not exists is_active boolean default false;
alter table employees add column if not exists created_at text;
alter table employees add column if not exists cashier_id text;
alter table employees add column if not exists commission_rate numeric default 0;
alter table employees add column if not exists attendance_pin text;
alter table employees enable row level security;
drop policy if exists "allow_all_anon_authenticated" on employees;
create policy "allow_all_anon_authenticated" on employees for all to anon, authenticated using (true) with check (true);
grant all on employees to anon, authenticated;

-- ── Table: employee_transactions ─────────────────────────────────────────
create table if not exists employee_transactions (id text primary key, created_at timestamptz default now());
alter table employee_transactions add column if not exists employee_id text;
alter table employee_transactions add column if not exists amount numeric default 0;
alter table employee_transactions add column if not exists type text;
alter table employee_transactions add column if not exists payment_method text;
alter table employee_transactions add column if not exists paid_cash numeric default 0;
alter table employee_transactions add column if not exists paid_visa numeric default 0;
alter table employee_transactions add column if not exists paid_wallet numeric default 0;
alter table employee_transactions add column if not exists paid_instapay numeric default 0;
alter table employee_transactions add column if not exists paid_method5 numeric default 0;
alter table employee_transactions add column if not exists paid_method6 numeric default 0;
alter table employee_transactions add column if not exists month text;
alter table employee_transactions add column if not exists deductions numeric default 0;
alter table employee_transactions add column if not exists note text;
alter table employee_transactions add column if not exists created_at text;
alter table employee_transactions enable row level security;
drop policy if exists "allow_all_anon_authenticated" on employee_transactions;
create policy "allow_all_anon_authenticated" on employee_transactions for all to anon, authenticated using (true) with check (true);
grant all on employee_transactions to anon, authenticated;

-- ── Table: employee_leaves ─────────────────────────────────────────
create table if not exists employee_leaves (id text primary key, created_at timestamptz default now());
alter table employee_leaves add column if not exists employee_id text;
alter table employee_leaves add column if not exists start_date text;
alter table employee_leaves add column if not exists end_date text;
alter table employee_leaves add column if not exists days_count numeric default 0;
alter table employee_leaves add column if not exists leave_type text;
alter table employee_leaves add column if not exists deduction_amount numeric default 0;
alter table employee_leaves add column if not exists month text;
alter table employee_leaves add column if not exists note text;
alter table employee_leaves add column if not exists created_at text;
alter table employee_leaves add column if not exists waived_amount numeric default 0;
alter table employee_leaves add column if not exists waived_at text;
alter table employee_leaves add column if not exists waive_note text;
alter table employee_leaves enable row level security;
drop policy if exists "allow_all_anon_authenticated" on employee_leaves;
create policy "allow_all_anon_authenticated" on employee_leaves for all to anon, authenticated using (true) with check (true);
grant all on employee_leaves to anon, authenticated;

-- ── Table: employee_deductions ─────────────────────────────────────────
create table if not exists employee_deductions (id text primary key, created_at timestamptz default now());
alter table employee_deductions add column if not exists employee_id text;
alter table employee_deductions add column if not exists amount numeric default 0;
alter table employee_deductions add column if not exists days numeric default 0;
alter table employee_deductions add column if not exists reason text;
alter table employee_deductions add column if not exists month text;
alter table employee_deductions add column if not exists date text;
alter table employee_deductions add column if not exists created_at text;
alter table employee_deductions add column if not exists waived_amount numeric default 0;
alter table employee_deductions add column if not exists waived_at text;
alter table employee_deductions add column if not exists waive_note text;
alter table employee_deductions enable row level security;
drop policy if exists "allow_all_anon_authenticated" on employee_deductions;
create policy "allow_all_anon_authenticated" on employee_deductions for all to anon, authenticated using (true) with check (true);
grant all on employee_deductions to anon, authenticated;

-- ── Table: employee_bonuses ─────────────────────────────────────────
create table if not exists employee_bonuses (id text primary key, created_at timestamptz default now());
alter table employee_bonuses add column if not exists employee_id text;
alter table employee_bonuses add column if not exists amount numeric default 0;
alter table employee_bonuses add column if not exists reason text;
alter table employee_bonuses add column if not exists month text;
alter table employee_bonuses add column if not exists date text;
alter table employee_bonuses add column if not exists created_at text;
alter table employee_bonuses enable row level security;
drop policy if exists "allow_all_anon_authenticated" on employee_bonuses;
create policy "allow_all_anon_authenticated" on employee_bonuses for all to anon, authenticated using (true) with check (true);
grant all on employee_bonuses to anon, authenticated;

-- ── Table: employee_attendance ─────────────────────────────────────────
create table if not exists employee_attendance (id text primary key, created_at timestamptz default now());
alter table employee_attendance add column if not exists employee_id text;
alter table employee_attendance add column if not exists date text;
alter table employee_attendance add column if not exists check_in text;
alter table employee_attendance add column if not exists check_out text;
alter table employee_attendance add column if not exists shift_start text;
alter table employee_attendance add column if not exists late_minutes numeric default 0;
alter table employee_attendance add column if not exists deduction_amount numeric default 0;
alter table employee_attendance add column if not exists month text;
alter table employee_attendance add column if not exists note text;
alter table employee_attendance add column if not exists created_at text;
alter table employee_attendance add column if not exists waived_amount numeric default 0;
alter table employee_attendance add column if not exists waived_at text;
alter table employee_attendance add column if not exists waive_note text;
alter table employee_attendance enable row level security;
drop policy if exists "allow_all_anon_authenticated" on employee_attendance;
create policy "allow_all_anon_authenticated" on employee_attendance for all to anon, authenticated using (true) with check (true);
grant all on employee_attendance to anon, authenticated;

-- ── Table: product_suggestions ─────────────────────────────────────────
create table if not exists product_suggestions (id text primary key, created_at timestamptz default now());
alter table product_suggestions add column if not exists name text;
alter table product_suggestions add column if not exists notes text;
alter table product_suggestions add column if not exists is_purchased boolean default false;
alter table product_suggestions add column if not exists created_at text;
alter table product_suggestions enable row level security;
drop policy if exists "allow_all_anon_authenticated" on product_suggestions;
create policy "allow_all_anon_authenticated" on product_suggestions for all to anon, authenticated using (true) with check (true);
grant all on product_suggestions to anon, authenticated;

-- ── Table: coupons ─────────────────────────────────────────
create table if not exists coupons (id text primary key, created_at timestamptz default now());
alter table coupons add column if not exists code text;
alter table coupons add column if not exists discount_type text;
alter table coupons add column if not exists discount_value numeric default 0;
alter table coupons add column if not exists start_date text;
alter table coupons add column if not exists end_date text;
alter table coupons add column if not exists max_uses_per_customer numeric default 0;
alter table coupons add column if not exists max_uses_total numeric default 0;
alter table coupons add column if not exists used_count numeric default 0;
alter table coupons add column if not exists is_active boolean default false;
alter table coupons add column if not exists created_at text;
alter table coupons enable row level security;
drop policy if exists "allow_all_anon_authenticated" on coupons;
create policy "allow_all_anon_authenticated" on coupons for all to anon, authenticated using (true) with check (true);
grant all on coupons to anon, authenticated;

-- ── Table: cashier_notes ─────────────────────────────────────────
create table if not exists cashier_notes (id text primary key, created_at timestamptz default now());
alter table cashier_notes add column if not exists cashier_name text;
alter table cashier_notes add column if not exists note text;
alter table cashier_notes add column if not exists is_read boolean default false;
alter table cashier_notes add column if not exists created_at text;
alter table cashier_notes enable row level security;
drop policy if exists "allow_all_anon_authenticated" on cashier_notes;
create policy "allow_all_anon_authenticated" on cashier_notes for all to anon, authenticated using (true) with check (true);
grant all on cashier_notes to anon, authenticated;

-- ── Table: admin_users ─────────────────────────────────────────
create table if not exists admin_users (id text primary key, created_at timestamptz default now());
alter table admin_users add column if not exists name text;
alter table admin_users add column if not exists password text;
alter table admin_users add column if not exists email text;
alter table admin_users add column if not exists permissions text;
alter table admin_users add column if not exists created_at text;
alter table admin_users enable row level security;
drop policy if exists "allow_all_anon_authenticated" on admin_users;
create policy "allow_all_anon_authenticated" on admin_users for all to anon, authenticated using (true) with check (true);
grant all on admin_users to anon, authenticated;

-- ── Table: platform_collections ─────────────────────────────────────────
create table if not exists platform_collections (id text primary key, created_at timestamptz default now());
alter table platform_collections add column if not exists entity_type text;
alter table platform_collections add column if not exists entity_name text;
alter table platform_collections add column if not exists month text;
alter table platform_collections add column if not exists expected_amount numeric default 0;
alter table platform_collections add column if not exists collected_amount numeric default 0;
alter table platform_collections add column if not exists status text;
alter table platform_collections add column if not exists notes text;
alter table platform_collections add column if not exists created_at text;
alter table platform_collections enable row level security;
drop policy if exists "allow_all_anon_authenticated" on platform_collections;
create policy "allow_all_anon_authenticated" on platform_collections for all to anon, authenticated using (true) with check (true);
grant all on platform_collections to anon, authenticated;

-- ── Table: shipping_carriers ─────────────────────────────────────────
create table if not exists shipping_carriers (id text primary key, created_at timestamptz default now());
alter table shipping_carriers add column if not exists name text;
alter table shipping_carriers add column if not exists contact_person text;
alter table shipping_carriers add column if not exists phone text;
alter table shipping_carriers add column if not exists email text;
alter table shipping_carriers add column if not exists address text;
alter table shipping_carriers add column if not exists rate_per_kg numeric default 0;
alter table shipping_carriers add column if not exists base_fee numeric default 0;
alter table shipping_carriers add column if not exists tracking_url_template text;
alter table shipping_carriers add column if not exists notes text;
alter table shipping_carriers add column if not exists status text;
alter table shipping_carriers add column if not exists created_at text;
alter table shipping_carriers enable row level security;
drop policy if exists "allow_all_anon_authenticated" on shipping_carriers;
create policy "allow_all_anon_authenticated" on shipping_carriers for all to anon, authenticated using (true) with check (true);
grant all on shipping_carriers to anon, authenticated;

-- ── Table: shipments ─────────────────────────────────────────
create table if not exists shipments (id text primary key, created_at timestamptz default now());
alter table shipments add column if not exists carrier_id text;
alter table shipments add column if not exists invoice_id text;
alter table shipments add column if not exists tracking_number text;
alter table shipments add column if not exists status text;
alter table shipments add column if not exists shipping_cost numeric default 0;
alter table shipments add column if not exists delivery_fee numeric default 0;
alter table shipments add column if not exists recipient_name text;
alter table shipments add column if not exists recipient_phone text;
alter table shipments add column if not exists recipient_address text;
alter table shipments add column if not exists estimated_delivery text;
alter table shipments add column if not exists delivered_at text;
alter table shipments add column if not exists notes text;
alter table shipments add column if not exists created_at text;
alter table shipments enable row level security;
drop policy if exists "allow_all_anon_authenticated" on shipments;
create policy "allow_all_anon_authenticated" on shipments for all to anon, authenticated using (true) with check (true);
grant all on shipments to anon, authenticated;

-- ── Table: warehouses ─────────────────────────────────────────
create table if not exists warehouses (id text primary key, created_at timestamptz default now());
alter table warehouses add column if not exists name text;
alter table warehouses add column if not exists code text;
alter table warehouses add column if not exists location text;
alter table warehouses add column if not exists manager_name text;
alter table warehouses add column if not exists phone text;
alter table warehouses add column if not exists is_default boolean default false;
alter table warehouses add column if not exists created_at text;
alter table warehouses enable row level security;
drop policy if exists "allow_all_anon_authenticated" on warehouses;
create policy "allow_all_anon_authenticated" on warehouses for all to anon, authenticated using (true) with check (true);
grant all on warehouses to anon, authenticated;

-- ── Table: warehouse_stock ─────────────────────────────────────────
create table if not exists warehouse_stock (id text primary key, created_at timestamptz default now());
alter table warehouse_stock add column if not exists warehouse_id text;
alter table warehouse_stock add column if not exists product_id text;
alter table warehouse_stock add column if not exists stock_quantity numeric default 0;
alter table warehouse_stock add column if not exists min_stock numeric default 0;
alter table warehouse_stock enable row level security;
drop policy if exists "allow_all_anon_authenticated" on warehouse_stock;
create policy "allow_all_anon_authenticated" on warehouse_stock for all to anon, authenticated using (true) with check (true);
grant all on warehouse_stock to anon, authenticated;

-- ── Table: stock_transfers ─────────────────────────────────────────
create table if not exists stock_transfers (id text primary key, created_at timestamptz default now());
alter table stock_transfers add column if not exists transfer_number text;
alter table stock_transfers add column if not exists source_warehouse_id text;
alter table stock_transfers add column if not exists target_warehouse_id text;
alter table stock_transfers add column if not exists status text;
alter table stock_transfers add column if not exists notes text;
alter table stock_transfers add column if not exists created_by text;
alter table stock_transfers add column if not exists created_at text;
alter table stock_transfers add column if not exists items text;
alter table stock_transfers enable row level security;
drop policy if exists "allow_all_anon_authenticated" on stock_transfers;
create policy "allow_all_anon_authenticated" on stock_transfers for all to anon, authenticated using (true) with check (true);
grant all on stock_transfers to anon, authenticated;

-- ── Table: stock_transfer_items ─────────────────────────────────────────
create table if not exists stock_transfer_items (id text primary key, created_at timestamptz default now());
alter table stock_transfer_items add column if not exists transfer_id text;
alter table stock_transfer_items add column if not exists product_id text;
alter table stock_transfer_items add column if not exists quantity numeric default 0;
alter table stock_transfer_items add column if not exists notes text;
alter table stock_transfer_items enable row level security;
drop policy if exists "allow_all_anon_authenticated" on stock_transfer_items;
create policy "allow_all_anon_authenticated" on stock_transfer_items for all to anon, authenticated using (true) with check (true);
grant all on stock_transfer_items to anon, authenticated;

-- ── Table: stock_movement_logs ─────────────────────────────────────────
create table if not exists stock_movement_logs (id text primary key, created_at timestamptz default now());
alter table stock_movement_logs add column if not exists product_id text;
alter table stock_movement_logs add column if not exists warehouse_id text;
alter table stock_movement_logs add column if not exists type text;
alter table stock_movement_logs add column if not exists quantity numeric default 0;
alter table stock_movement_logs add column if not exists reference_type text;
alter table stock_movement_logs add column if not exists reference_id text;
alter table stock_movement_logs add column if not exists notes text;
alter table stock_movement_logs add column if not exists created_at text;
alter table stock_movement_logs enable row level security;
drop policy if exists "allow_all_anon_authenticated" on stock_movement_logs;
create policy "allow_all_anon_authenticated" on stock_movement_logs for all to anon, authenticated using (true) with check (true);
grant all on stock_movement_logs to anon, authenticated;

-- ── Table: supplier_ledger_entries ─────────────────────────────────────────
create table if not exists supplier_ledger_entries (id text primary key, created_at timestamptz default now());
alter table supplier_ledger_entries add column if not exists supplier_id text;
alter table supplier_ledger_entries add column if not exists transaction_type text;
alter table supplier_ledger_entries add column if not exists reference_number text;
alter table supplier_ledger_entries add column if not exists debit numeric default 0;
alter table supplier_ledger_entries add column if not exists credit numeric default 0;
alter table supplier_ledger_entries add column if not exists balance numeric default 0;
alter table supplier_ledger_entries add column if not exists payment_account_id text;
alter table supplier_ledger_entries add column if not exists note text;
alter table supplier_ledger_entries add column if not exists created_at text;
alter table supplier_ledger_entries enable row level security;
drop policy if exists "allow_all_anon_authenticated" on supplier_ledger_entries;
create policy "allow_all_anon_authenticated" on supplier_ledger_entries for all to anon, authenticated using (true) with check (true);
grant all on supplier_ledger_entries to anon, authenticated;

-- ── Table: adv_purchase_invoices ─────────────────────────────────────────
create table if not exists adv_purchase_invoices (id text primary key, created_at timestamptz default now());
alter table adv_purchase_invoices add column if not exists invoice_number text;
alter table adv_purchase_invoices add column if not exists supplier_id text;
alter table adv_purchase_invoices add column if not exists warehouse_id text;
alter table adv_purchase_invoices add column if not exists invoice_date text;
alter table adv_purchase_invoices add column if not exists due_date text;
alter table adv_purchase_invoices add column if not exists status text;
alter table adv_purchase_invoices add column if not exists subtotal numeric default 0;
alter table adv_purchase_invoices add column if not exists discount numeric default 0;
alter table adv_purchase_invoices add column if not exists tax_amount numeric default 0;
alter table adv_purchase_invoices add column if not exists freight_cost numeric default 0;
alter table adv_purchase_invoices add column if not exists total_amount numeric default 0;
alter table adv_purchase_invoices add column if not exists paid_amount numeric default 0;
alter table adv_purchase_invoices add column if not exists notes text;
alter table adv_purchase_invoices add column if not exists created_at text;
alter table adv_purchase_invoices add column if not exists items text;
alter table adv_purchase_invoices enable row level security;
drop policy if exists "allow_all_anon_authenticated" on adv_purchase_invoices;
create policy "allow_all_anon_authenticated" on adv_purchase_invoices for all to anon, authenticated using (true) with check (true);
grant all on adv_purchase_invoices to anon, authenticated;

-- ── Table: adv_purchase_invoice_items ─────────────────────────────────────────
create table if not exists adv_purchase_invoice_items (id text primary key, created_at timestamptz default now());
alter table adv_purchase_invoice_items add column if not exists purchase_invoice_id text;
alter table adv_purchase_invoice_items add column if not exists product_id text;
alter table adv_purchase_invoice_items add column if not exists quantity numeric default 0;
alter table adv_purchase_invoice_items add column if not exists unit_cost numeric default 0;
alter table adv_purchase_invoice_items add column if not exists landed_unit_cost numeric default 0;
alter table adv_purchase_invoice_items add column if not exists tax_rate numeric default 0;
alter table adv_purchase_invoice_items add column if not exists total_cost numeric default 0;
alter table adv_purchase_invoice_items enable row level security;
drop policy if exists "allow_all_anon_authenticated" on adv_purchase_invoice_items;
create policy "allow_all_anon_authenticated" on adv_purchase_invoice_items for all to anon, authenticated using (true) with check (true);
grant all on adv_purchase_invoice_items to anon, authenticated;

-- ── Table: supplier_transactions ─────────────────────────────────────────
create table if not exists supplier_transactions (id text primary key, created_at timestamptz default now());
alter table supplier_transactions add column if not exists supplier_id text;
alter table supplier_transactions add column if not exists type text;
alter table supplier_transactions add column if not exists amount numeric default 0;
alter table supplier_transactions add column if not exists balance_after numeric default 0;
alter table supplier_transactions add column if not exists payment_method text;
alter table supplier_transactions add column if not exists reference_no text;
alter table supplier_transactions add column if not exists created_at text;
alter table supplier_transactions enable row level security;
drop policy if exists "allow_all_anon_authenticated" on supplier_transactions;
create policy "allow_all_anon_authenticated" on supplier_transactions for all to anon, authenticated using (true) with check (true);
grant all on supplier_transactions to anon, authenticated;

-- ── Table: logistics_orders ─────────────────────────────────────────
create table if not exists logistics_orders (id text primary key, created_at timestamptz default now());
alter table logistics_orders add column if not exists order_id text;
alter table logistics_orders add column if not exists carrier_id text;
alter table logistics_orders add column if not exists tracking_number text;
alter table logistics_orders add column if not exists shipping_cost numeric default 0;
alter table logistics_orders add column if not exists status text;
alter table logistics_orders add column if not exists estimated_delivery text;
alter table logistics_orders add column if not exists shipped_at text;
alter table logistics_orders add column if not exists created_at text;
alter table logistics_orders enable row level security;
drop policy if exists "allow_all_anon_authenticated" on logistics_orders;
create policy "allow_all_anon_authenticated" on logistics_orders for all to anon, authenticated using (true) with check (true);
grant all on logistics_orders to anon, authenticated;

-- ── تحديث الـ schema cache بتاع PostgREST ───────────────────────────────────
notify pgrst, 'reload schema';



-- ==========================================================================
-- SOURCE: setup_new_database.sql
-- ==========================================================================

-- =============================================================================
-- ADRIA / HANCES PRO ERP - سكريبت إعداد قاعدة البيانات الشامل الموحد + بيانات ديمو كاملة
-- =============================================================================
-- شغّل هذا الملف بالكامل في Supabase SQL Editor:
-- Supabase Dashboard > SQL Editor > New query > Run
-- =============================================================================

-- -----------------------------------------------------------------------------
-- 1) الإضافات الأساسية (Extensions)
-- -----------------------------------------------------------------------------
create extension if not exists pgcrypto;
create extension if not exists "uuid-ossp";

-- -----------------------------------------------------------------------------
-- 2) إنشاء وإنعاش الجداول والأعمدة (Schema Reconciliation)
-- -----------------------------------------------------------------------------

-- 1. إعدادات المتجر (store_settings)
create table if not exists store_settings (
  id text primary key default gen_random_uuid()::text,
  created_at timestamptz default now()
);
alter table store_settings add column if not exists name text default 'متجر ADRIA الفاخر - Enterprise POS';
alter table store_settings add column if not exists currency text default 'ج.م';
alter table store_settings add column if not exists logo text default 'https://cdn-icons-png.flaticon.com/512/3143/3143641.png';
alter table store_settings add column if not exists tax_rate numeric default 0;
alter table store_settings add column if not exists taxrate numeric default 0;
alter table store_settings add column if not exists theme_color text default '#4f46e5';
alter table store_settings add column if not exists themecolor text default '#4f46e5';
alter table store_settings add column if not exists address text default 'القاهرة - مصر';
alter table store_settings add column if not exists phone text default '01000000000';
alter table store_settings add column if not exists phone2 text default '';
alter table store_settings add column if not exists whatsapp_country_code text default '20';
alter table store_settings add column if not exists whatsappcountrycode text default '20';
alter table store_settings add column if not exists initial_balance numeric default 100000;
alter table store_settings add column if not exists location_url text default '';
alter table store_settings add column if not exists locationurl text default '';
alter table store_settings add column if not exists cashierpermissions boolean default false;
alter table store_settings add column if not exists paymentlabels jsonb;
alter table store_settings add column if not exists paymentmethodsenabled boolean default false;
alter table store_settings add column if not exists paymentopeningbalances numeric default 0;
alter table store_settings add column if not exists savingsopeningbalances numeric default 0;
alter table store_settings add column if not exists showinvoiceprofit boolean default true;
alter table store_settings add column if not exists allowcashieremployeeadvance boolean default false;
alter table store_settings add column if not exists daystarthour numeric default 0;
alter table store_settings add column if not exists expensecategories text default 'كهرباء وإيجار,بضائع ومشتريات,رواتب وسلف,صيانة وتشغيل,مصاريف شحن,نثريات';
alter table store_settings add column if not exists incomecategories text default 'مبيعات محل,مبيعات أونلاين,خدمات صيانة,إيرادات أخرى';
alter table store_settings add column if not exists pagesqrurl text default '';
alter table store_settings add column if not exists pagesqrlabel text default '';
alter table store_settings add column if not exists pagesqrimage text default '';
alter table store_settings add column if not exists tax_number text default '';
alter table store_settings add column if not exists commercial_record text default '';
alter table store_settings add column if not exists default_invoice_format text default 'thermal';

-- 2. التصنيفات (categories)
create table if not exists categories (
  id text primary key default gen_random_uuid()::text,
  created_at timestamptz default now()
);
alter table categories add column if not exists name text not null;
alter table categories add column if not exists image_url text;

-- 3. المنتجات (products)
create table if not exists products (
  id text primary key default gen_random_uuid()::text,
  created_at timestamptz default now()
);
alter table products add column if not exists name text not null;
alter table products add column if not exists barcode text unique;
alter table products add column if not exists image_url text;
alter table products add column if not exists purchase_price numeric default 0;
alter table products add column if not exists average_purchase_price numeric default 0;
alter table products add column if not exists sale_price numeric default 0;
alter table products add column if not exists discount_price numeric default 0;
alter table products add column if not exists wholesale_price numeric default 0;
alter table products add column if not exists half_wholesale_price numeric default 0;
alter table products add column if not exists stock_quantity numeric default 0;
alter table products add column if not exists display_quantity numeric default 0;
alter table products add column if not exists factory_quantity numeric default 0;
alter table products add column if not exists category_id text;
alter table products add column if not exists unit text default 'قطعة';
alter table products add column if not exists season text;
alter table products add column if not exists is_hidden boolean default false;
alter table products add column if not exists color text;
alter table products add column if not exists supplier_name text;
alter table products add column if not exists custom_stores jsonb;

-- 4. العملاء (customers)
create table if not exists customers (
  id text primary key default gen_random_uuid()::text,
  created_at timestamptz default now()
);
alter table customers add column if not exists name text not null default 'عميل نقدي';
alter table customers add column if not exists phone text;
alter table customers add column if not exists custom_id text;
alter table customers add column if not exists card_number text;
alter table customers add column if not exists timestamp text;

-- 5. الموردين (suppliers)
create table if not exists suppliers (
  id text primary key default gen_random_uuid()::text,
  created_at timestamptz default now()
);
alter table suppliers add column if not exists name text not null;
alter table suppliers add column if not exists phone text;
alter table suppliers add column if not exists email text;
alter table suppliers add column if not exists address text;
alter table suppliers add column if not exists balance numeric default 0;
alter table suppliers add column if not exists current_balance numeric default 0;
alter table suppliers add column if not exists credit_limit numeric default 0;

-- 6. الكاشيرين (cashiers)
create table if not exists cashiers (
  id text primary key default gen_random_uuid()::text,
  created_at timestamptz default now()
);
alter table cashiers add column if not exists name text not null;
alter table cashiers add column if not exists password text;
alter table cashiers add column if not exists pin text;
alter table cashiers add column if not exists phone text;
alter table cashiers add column if not exists photo_url text;
alter table cashiers add column if not exists email text;
alter table cashiers add column if not exists full_access boolean default false;

-- 7. الموظفين (employees)
create table if not exists employees (
  id text primary key default gen_random_uuid()::text,
  created_at timestamptz default now()
);
alter table employees add column if not exists name text not null;
alter table employees add column if not exists job_title text;
alter table employees add column if not exists phone text;
alter table employees add column if not exists working_hours text;
alter table employees add column if not exists monthly_salary numeric default 0;
alter table employees add column if not exists annual_leave_balance numeric default 0;
alter table employees add column if not exists monthly_leave_days numeric default 0;
alter table employees add column if not exists shift_start text default '09:00';
alter table employees add column if not exists shift_end text default '17:00';
alter table employees add column if not exists late_grace_minutes numeric default 15;
alter table employees add column if not exists friday_shift_start text;
alter table employees add column if not exists friday_shift_end text;
alter table employees add column if not exists friday_is_off boolean default true;
alter table employees add column if not exists hire_date text;
alter table employees add column if not exists is_active boolean default true;
alter table employees add column if not exists cashier_id text;
alter table employees add column if not exists commission_rate numeric default 0;
alter table employees add column if not exists attendance_pin text;

-- 8. معاملات الموظفين (employee_transactions)
create table if not exists employee_transactions (
  id text primary key default gen_random_uuid()::text,
  created_at timestamptz default now()
);
alter table employee_transactions add column if not exists employee_id text;
alter table employee_transactions add column if not exists amount numeric default 0;
alter table employee_transactions add column if not exists type text; -- salary, advance, incentive
alter table employee_transactions add column if not exists payment_method text default 'cash';
alter table employee_transactions add column if not exists paid_cash numeric default 0;
alter table employee_transactions add column if not exists paid_visa numeric default 0;
alter table employee_transactions add column if not exists paid_wallet numeric default 0;
alter table employee_transactions add column if not exists paid_instapay numeric default 0;
alter table employee_transactions add column if not exists deductions numeric default 0;
alter table employee_transactions add column if not exists month text;
alter table employee_transactions add column if not exists note text;

-- 9. إجازات الموظفين (employee_leaves)
create table if not exists employee_leaves (
  id text primary key default gen_random_uuid()::text,
  created_at timestamptz default now()
);
alter table employee_leaves add column if not exists employee_id text;
alter table employee_leaves add column if not exists start_date text;
alter table employee_leaves add column if not exists end_date text;
alter table employee_leaves add column if not exists days_count numeric default 1;
alter table employee_leaves add column if not exists leave_type text default 'paid';
alter table employee_leaves add column if not exists deduction_amount numeric default 0;
alter table employee_leaves add column if not exists month text;
alter table employee_leaves add column if not exists note text;

-- 10. الفواتير والطلبات (orders)
create table if not exists orders (
  id text primary key,
  created_at timestamptz default now()
);
alter table orders add column if not exists idempotency_key text unique;
alter table orders add column if not exists items text;
alter table orders add column if not exists total numeric default 0;
alter table orders add column if not exists paid_amount numeric default 0;
alter table orders add column if not exists paid_cash numeric default 0;
alter table orders add column if not exists paid_visa numeric default 0;
alter table orders add column if not exists paid_wallet numeric default 0;
alter table orders add column if not exists paid_instapay numeric default 0;
alter table orders add column if not exists paid_method5 numeric default 0;
alter table orders add column if not exists paid_method6 numeric default 0;
alter table orders add column if not exists type text default 'sale';
alter table orders add column if not exists date text;
alter table orders add column if not exists payment_method text default 'cash';
alter table orders add column if not exists customer text;
alter table orders add column if not exists customer_id text;
alter table orders add column if not exists cashier_name text;
alter table orders add column if not exists salesperson_id text;
alter table orders add column if not exists salesperson_name text;
alter table orders add column if not exists sales_channel text;
alter table orders add column if not exists platform_name text;
alter table orders add column if not exists isoffline boolean default false;
alter table orders add column if not exists is_deleted boolean default false;
alter table orders add column if not exists deleted_at text;
alter table orders add column if not exists deletion_reason text;
alter table orders add column if not exists notes text;
alter table orders add column if not exists coupon_code text;
alter table orders add column if not exists discount_amount numeric default 0;
alter table orders add column if not exists car_id text;

-- عداد أرقام الفواتير
create table if not exists invoice_counter (
  id int primary key default 1,
  current_value integer default 10,
  check (id = 1)
);
insert into invoice_counter (id, current_value) values (1, 10) on conflict (id) do update set current_value = greatest(invoice_counter.current_value, 10);

-- 11. بنود الفاتورة (order_items)
create table if not exists order_items (
  id text primary key default gen_random_uuid()::text,
  created_at timestamptz default now()
);
alter table order_items add column if not exists order_id text;
alter table order_items add column if not exists product_id text;
alter table order_items add column if not exists product_name text;
alter table order_items add column if not exists barcode text;
alter table order_items add column if not exists quantity numeric default 1;
alter table order_items add column if not exists returned_quantity numeric default 0;
alter table order_items add column if not exists refunded_amount numeric default 0;
alter table order_items add column if not exists sale_price numeric default 0;
alter table order_items add column if not exists purchase_price numeric default 0;

-- 12. المصروفات (expenses)
create table if not exists expenses (
  id text primary key default gen_random_uuid()::text,
  created_at timestamptz default now()
);
alter table expenses add column if not exists category text not null;
alter table expenses add column if not exists amount numeric default 0;
alter table expenses add column if not exists paid_cash numeric default 0;
alter table expenses add column if not exists paid_visa numeric default 0;
alter table expenses add column if not exists paid_wallet numeric default 0;
alter table expenses add column if not exists paid_instapay numeric default 0;
alter table expenses add column if not exists paid_method5 numeric default 0;
alter table expenses add column if not exists paid_method6 numeric default 0;
alter table expenses add column if not exists note text;
alter table expenses add column if not exists payment_method text default 'cash';
alter table expenses add column if not exists date text;
alter table expenses add column if not exists car_id text;
alter table expenses add column if not exists employee_transaction_id text;

-- 13. فواتير المشتريات (purchase_invoices)
create table if not exists purchase_invoices (
  id text primary key default gen_random_uuid()::text,
  created_at timestamptz default now()
);
alter table purchase_invoices add column if not exists invoice_number text;
alter table purchase_invoices add column if not exists supplier_id text;
alter table purchase_invoices add column if not exists total numeric default 0;
alter table purchase_invoices add column if not exists paid_amount numeric default 0;
alter table purchase_invoices add column if not exists paid_cash numeric default 0;
alter table purchase_invoices add column if not exists paid_visa numeric default 0;
alter table purchase_invoices add column if not exists paid_wallet numeric default 0;
alter table purchase_invoices add column if not exists paid_instapay numeric default 0;
alter table purchase_invoices add column if not exists payment_method text default 'cash';
alter table purchase_invoices add column if not exists notes text;
alter table purchase_invoices add column if not exists items text;

-- 14. بنود المشتريات (purchase_items)
create table if not exists purchase_items (
  id text primary key default gen_random_uuid()::text,
  created_at timestamptz default now()
);
alter table purchase_items add column if not exists invoice_id text;
alter table purchase_items add column if not exists product_id text;
alter table purchase_items add column if not exists quantity numeric default 1;
alter table purchase_items add column if not exists purchase_price numeric default 0;
alter table purchase_items add column if not exists to_display numeric default 0;

-- 15. المخازن (warehouses)
create table if not exists warehouses (
  id text primary key default gen_random_uuid()::text,
  created_at timestamptz default now()
);
alter table warehouses add column if not exists name text not null;
alter table warehouses add column if not exists location text;
alter table warehouses add column if not exists manager_id text;
alter table warehouses add column if not exists status text default 'active';

-- 16. شركات الشحن (shipping_carriers)
create table if not exists shipping_carriers (
  id text primary key default gen_random_uuid()::text,
  created_at timestamptz default now()
);
alter table shipping_carriers add column if not exists name text not null;
alter table shipping_carriers add column if not exists phone text;
alter table shipping_carriers add column if not exists email text;
alter table shipping_carriers add column if not exists tracking_url_template text;
alter table shipping_carriers add column if not exists status text default 'active';

-- 17. الكوبونات (coupons)
create table if not exists coupons (
  id text primary key default gen_random_uuid()::text,
  created_at timestamptz default now()
);
alter table coupons add column if not exists code text not null unique;
alter table coupons add column if not exists discount_type text default 'percentage';
alter table coupons add column if not exists discount_value numeric default 0;
alter table coupons add column if not exists used_count integer default 0;
alter table coupons add column if not exists is_active boolean default true;

-- 18. الفواتير المعلقة (held_invoices)
create table if not exists held_invoices (
  id text primary key default gen_random_uuid()::text,
  created_at timestamptz default now()
);
alter table held_invoices add column if not exists customer_name text;
alter table held_invoices add column if not exists customer_phone text;
alter table held_invoices add column if not exists items text;
alter table held_invoices add column if not exists total numeric default 0;
alter table held_invoices add column if not exists invoice_type text;
alter table held_invoices add column if not exists cashier_name text;
alter table held_invoices add column if not exists notes text;
alter table held_invoices add column if not exists deposit numeric default 0;
alter table held_invoices add column if not exists status text default 'pending';

-- -----------------------------------------------------------------------------
-- 3) تفعيل RLS والصلاحيات للجميع (Row Level Security & Permissions)
-- -----------------------------------------------------------------------------
do $$
declare
  t text;
  tables text[] := array[
    'store_settings', 'categories', 'products', 'customers', 'suppliers',
    'cashiers', 'employees', 'employee_transactions', 'employee_leaves',
    'orders', 'order_items', 'expenses', 'purchase_invoices', 'purchase_items',
    'warehouses', 'shipping_carriers', 'coupons', 'held_invoices', 'invoice_counter'
  ];
begin
  foreach t in array tables loop
    execute format('alter table %I enable row level security;', t);
    execute format('drop policy if exists "allow_all_anon_authenticated" on %I;', t);
    execute format('create policy "allow_all_anon_authenticated" on %I for all to anon, authenticated using (true) with check (true);', t);
    execute format('grant all on %I to anon, authenticated;', t);
  end loop;
end $$;

-- -----------------------------------------------------------------------------
-- 4) دالة نقل المخزون بين المعرض والمستودع (RPC Function)
-- -----------------------------------------------------------------------------
create or replace function rpc_transfer_warehouse_stock(
  p_product_id text,
  p_transfer_qty numeric,
  p_direction text
) returns jsonb language plpgsql security definer as $$
declare
  v_prod record;
  v_new_display numeric;
begin
  select * into v_prod from products where id = p_product_id for update;
  if not found then
    return jsonb_build_object('success', false, 'message', 'المنتج غير موجود');
  end if;

  if p_direction = 'to_display' then
    if (v_prod.stock_quantity - coalesce(v_prod.display_quantity, 0)) < p_transfer_qty then
      return jsonb_build_object('success', false, 'message', 'الكمية المتاحة بالمستودع غير كافية');
    end if;
    v_new_display := coalesce(v_prod.display_quantity, 0) + p_transfer_qty;
  elsif p_direction = 'to_warehouse' then
    if coalesce(v_prod.display_quantity, 0) < p_transfer_qty then
      return jsonb_build_object('success', false, 'message', 'الكمية المعروضة بالمحل غير كافية');
    end if;
    v_new_display := coalesce(v_prod.display_quantity, 0) - p_transfer_qty;
  else
    return jsonb_build_object('success', false, 'message', 'اتجاه النقل غير صحيح');
  end if;

  update products set display_quantity = v_new_display where id = p_product_id;
  return jsonb_build_object('success', true, 'new_display_quantity', v_new_display);
end;
$$;

-- -----------------------------------------------------------------------------
-- 5) إضافة بيانات الديمو المتكاملة والشاملة (Comprehensive Demo Data Seeding)
-- -----------------------------------------------------------------------------

-- 1. إعدادات المتجر الافتراضية
insert into store_settings (
  id, name, currency, logo, tax_rate, theme_color, address, phone, phone2,
  whatsapp_country_code, initial_balance, expensecategories, incomecategories
)
values (
  'default_setting',
  'متجر ADRIA الفاخر للأزياء والإكسسوارات',
  'ج.م',
  'https://images.unsplash.com/photo-1441986300917-64674bd600d8?w=200&q=80',
  0,
  '#4f46e5',
  'القاهرة - شارع التحرير - مصر',
  '01012345678',
  '01187654321',
  '20',
  100000,
  'كهرباء وإيجار,بضائع ومشتريات,رواتب وسلف,صيانة وتشغيل,مصاريف شحن,نثريات',
  'مبيعات محل,مبيعات أونلاين,خدمات صيانة,إيرادات أخرى'
)
on conflict (id) do update set
  name = excluded.name,
  currency = excluded.currency,
  logo = excluded.logo,
  initial_balance = excluded.initial_balance,
  address = excluded.address,
  phone = excluded.phone;

-- 2. المخازن
insert into warehouses (id, name, location, status) values
  ('wh_1', 'المخزن الرئيسي (المركز التجاري)', 'القاهرة - المبنى الرئيسي', 'active'),
  ('wh_2', 'مخزن المعرض (فرع المعادي)', 'القاهرة - فرع المعادي', 'active'),
  ('wh_3', 'مخزن التوزيع أونلاين', 'الجيزة - شيراتون', 'active')
on conflict (id) do nothing;

-- 3. شركات الشحن
insert into shipping_carriers (id, name, phone, email, tracking_url_template, status) values
  ('sc_1', 'بوسطة (Bosta)', '19001', 'info@bosta.co', 'https://bosta.co/tracking/{TN}', 'active'),
  ('sc_2', 'أرامكس (Aramex)', '023338877', 'support@aramex.com', 'https://www.aramex.com/track/{TN}', 'active'),
  ('sc_3', 'SMSA Express', '0227998877', 'support@smsaexpress.com', 'https://www.smsaexpress.com/track/{TN}', 'active')
on conflict (id) do nothing;

-- 4. التصنيفات
insert into categories (id, name, image_url) values
  ('cat_watches',     'ساعات رجالية ونسائية', 'https://images.unsplash.com/photo-1524805444758-089113d48a6d?w=500&q=80'),
  ('cat_bags',        'حقائب وشنط فاخرة',    'https://images.unsplash.com/photo-1584917865442-de89df76afd3?w=500&q=80'),
  ('cat_accessories', 'إكسسوارات ومجوهرات',  'https://images.unsplash.com/photo-1599643478518-a784e5dc4c8f?w=500&q=80'),
  ('cat_glasses',     'نظارات شمسية طبية',   'https://images.unsplash.com/photo-1511499767150-a48a237f0083?w=500&q=80'),
  ('cat_wallets',     'محافظ وأحزمة جلدية',   'https://images.unsplash.com/photo-1627123424574-724758594e93?w=500&q=80'),
  ('cat_gifts',       'علاب وهدايا VIP',      'https://images.unsplash.com/photo-1549465220-1a8b9238cd48?w=500&q=80')
on conflict (id) do nothing;

-- 5. منتجات الديمو (20+ منتج مع أسعار وصور وتفاصيل متكاملة)
insert into products (
  id, name, barcode, purchase_price, average_purchase_price, sale_price, half_wholesale_price, wholesale_price, discount_price, stock_quantity, display_quantity, category_id, unit, supplier_name, image_url
) values
  -- تصنيف: ساعات
  ('prod_1',  'ساعة رولكس دايتونا استيل سبورت', '1001', 1800, 1800, 3200, 2900, 2700, 3000, 25, 10, 'cat_watches', 'قطعة', 'شركة الساعات السويسرية', 'https://images.unsplash.com/photo-1522335789203-aabd1fc54bc9?w=500&q=80'),
  ('prod_2',  'ساعة كاسيو إيديفيس رجالي أسود',  '1002', 700,  700,  1350, 1200, 1100, 1250, 40, 15, 'cat_watches', 'قطعة', 'شركة اليابان للواردات', 'https://images.unsplash.com/photo-1539185441755-769473a23570?w=500&q=80'),
  ('prod_3',  'ساعة كارتييه سانتوس جلد بني',   '1003', 2100, 2100, 3800, 3400, 3200, 3600, 15, 5,  'cat_watches', 'قطعة', 'مؤسسة الأناقة الخليجية', 'https://images.unsplash.com/photo-1524805444758-089113d48a6d?w=500&q=80'),
  ('prod_4',  'ساعة أوميغا سيمستر استيل فضي', '1004', 2400, 2400, 4200, 3800, 3500, 3900, 12, 4,  'cat_watches', 'قطعة', 'شركة الساعات السويسرية', 'https://images.unsplash.com/photo-1547996160-81dfa63595aa?w=500&q=80'),
  ('prod_5',  'ساعة نسائية روزجولد كريستال',  '1005', 450,  450,  950,  850,  800,  890,  30, 12, 'cat_watches', 'قطعة', 'مؤسسة الأناقة الخليجية', 'https://images.unsplash.com/photo-1508685096489-7aacd43bd3b1?w=500&q=80'),

  -- تصنيف: حقائب وشنط
  ('prod_6',  'حقيبة يد كوتش جلد طبيعي بيج',   '2001', 950,  950,  1750, 1550, 1450, 1650, 20, 8,  'cat_bags', 'قطعة', 'مصنع الجلود الفاخرة', 'https://images.unsplash.com/photo-1584917865442-de89df76afd3?w=500&q=80'),
  ('prod_7',  'حقيبة شانيل كروس أسود كلاسيك', '2002', 1200, 1200, 2200, 1950, 1800, 2000, 18, 6,  'cat_bags', 'قطعة', 'مؤسسة الأناقة الخليجية', 'https://images.unsplash.com/photo-1548036328-c9fa89d128fa?w=500&q=80'),
  ('prod_8',  'شنطة ظهر لويس فيتون مونوغرام',  '2003', 1350, 1350, 2400, 2150, 2000, 2250, 15, 5,  'cat_bags', 'قطعة', 'مؤسسة الأناقة الخليجية', 'https://images.unsplash.com/photo-1553062407-98eeb64c6a62?w=500&q=80'),
  ('prod_9',  'حقيبة يد وسط مايكل كورس جولد',  '2004', 850,  850,  1600, 1400, 1300, 1500, 22, 10, 'cat_bags', 'قطعة', 'مصنع الجلود الفاخرة', 'https://images.unsplash.com/photo-1590874103328-eac38a683ce7?w=500&q=80'),

  -- تصنيف: إكسسوارات ومجوهرات
  ('prod_10', 'إسوارة كارتييه لوف ستيل ذهبي',   '3001', 350,  350,  680,  600,  550,  630,  50, 20, 'cat_accessories', 'قطعة', 'مؤسسة الإكسسوارات الذهبية', 'https://images.unsplash.com/photo-1611591475155-426c116c6736?w=500&q=80'),
  ('prod_11', 'إسوارة فان كليف 5 وردات أسود', '3002', 320,  320,  620,  550,  500,  580,  45, 18, 'cat_accessories', 'قطعة', 'مؤسسة الإكسسوارات الذهبية', 'https://images.unsplash.com/photo-1599643478518-a784e5dc4c8f?w=500&q=80'),
  ('prod_12', 'عقد لؤلؤ طبيعي كلاسيك أنيق',  '3003', 500,  500,  980,  880,  820,  900,  25, 10, 'cat_accessories', 'قطعة', 'مؤسسة الإكسسوارات الذهبية', 'https://images.unsplash.com/photo-1535632066927-ab7c9ab60908?w=500&q=80'),
  ('prod_13', 'سلسلة فضة عيار 925 دلاية قلب', '3004', 280,  280,  540,  480,  450,  490,  35, 15, 'cat_accessories', 'قطعة', 'مؤسسة الإكسسوارات الذهبية', 'https://images.unsplash.com/photo-1515562141207-7a88fb7ce338?w=500&q=80'),

  -- تصنيف: نظارات شمسية
  ('prod_14', 'نظارة راي بان أفياتور كلاسيك', '4001', 450,  450,  890,  790,  720,  820,  30, 12, 'cat_glasses', 'قطعة', 'شركة النظارات العالمية', 'https://images.unsplash.com/photo-1511499767150-a48a237f0083?w=500&q=80'),
  ('prod_15', 'نظارة شمسية كارتييه فريم جولد',  '4002', 650,  650,  1250, 1100, 1000, 1150, 20, 8,  'cat_glasses', 'قطعة', 'شركة النظارات العالمية', 'https://images.unsplash.com/photo-1572635196237-14b3f281503f?w=500&q=80'),

  -- تصنيف: محافظ وأحزمة
  ('prod_16', 'محفظة رجالي جلد طبيعي تومي',    '5001', 200,  200,  390,  350,  320,  360,  50, 25, 'cat_wallets', 'قطعة', 'مصنع الجلود الفاخرة', 'https://images.unsplash.com/photo-1627123424574-724758594e93?w=500&q=80'),
  ('prod_17', 'حزام رجالي جلد طبيعي اتوماتيك',  '5002', 180,  180,  350,  310,  290,  320,  40, 20, 'cat_wallets', 'قطعة', 'مصنع الجلود الفاخرة', 'https://images.unsplash.com/photo-1553062407-98eeb64c6a62?w=500&q=80'),

  -- تصنيف: هدايا VIP
  ('prod_18', 'علبة هدايا قطيفة فاخرة للساعة', '6001', 50,   50,   120,  100,  90,   110,  100, 40, 'cat_gifts', 'قطعة', 'مؤسسة التغليف والأظرف', 'https://images.unsplash.com/photo-1549465220-1a8b9238cd48?w=500&q=80'),
  ('prod_19', 'بوكس VIP مجمع (ساعة+سلسلة+محفظة)', '6002', 850,  850,  1590, 1400, 1300, 1490, 25, 10, 'cat_gifts', 'طقم', 'مؤسسة التغليف والأظرف', 'https://images.unsplash.com/photo-1513885535751-8b9238bd345a?w=500&q=80')
on conflict (id) do update set
  name = excluded.name,
  sale_price = excluded.sale_price,
  purchase_price = excluded.purchase_price,
  stock_quantity = excluded.stock_quantity,
  display_quantity = excluded.display_quantity,
  image_url = excluded.image_url;

-- 6. العملاء
insert into customers (id, name, phone, custom_id, card_number) values
  ('cust_1', 'أحمد محمود العبد', '01011112222', 'CUST-101', 'CRD-9001'),
  ('cust_2', 'سارة محمد الشريف',  '01133334444', 'CUST-102', 'CRD-9002'),
  ('cust_3', 'محمود إبراهيم علي', '01255556666', 'CUST-103', 'CRD-9003'),
  ('cust_4', 'منى عبد العزيز',   '01077778888', 'CUST-104', 'CRD-9004')
on conflict (id) do nothing;

-- 7. الموردين
insert into suppliers (id, name, phone, email, address, balance, current_balance) values
  ('sup_1', 'شركة الساعات السويسرية',    '0223456789', 'swiss@watches.com', 'القاهرة - وسط البلد', 0, 0),
  ('sup_2', 'مصنع الجلود الفاخرة',       '0229876543', 'leather@factory.com', 'الجيزة - المنطقة الصناعية', 0, 0),
  ('sup_3', 'مؤسسة الإكسسوارات الذهبية', '01099887766', 'accessories@gold.com', 'الإسكندرية - المنشية', 0, 0)
on conflict (id) do nothing;

-- 8. الكاشيرين
insert into cashiers (id, name, password, pin, phone, full_access) values
  ('cashier_admin', 'المدير العام (Admin)', '123456', '1234', '01000000001', true),
  ('cashier_main',  'كاشير الفرع الرئيسي',  '123456', '5555', '01000000002', false)
on conflict (id) do nothing;

-- 9. الموظفين
insert into employees (id, name, job_title, phone, monthly_salary, is_active, shift_start, shift_end) values
  ('emp_1', 'محمد عبد الرحمن', 'مدير المبيعات',  '01012340001', 8500, true, '09:00', '17:00'),
  ('emp_2', 'نورهان مصطفى',   'أخصائية كاشير',   '01012340002', 5500, true, '09:00', '17:00'),
  ('emp_3', 'علي حسام الدين',  'مسؤول المخزن',    '01012340003', 6000, true, '09:00', '17:00')
on conflict (id) do nothing;

-- 10. الكوبونات
insert into coupons (id, code, discount_type, discount_value, is_active) values
  ('cp_1', 'WELCOME10', 'percentage', 10, true),
  ('cp_2', 'VIP50',      'fixed',      50, true)
on conflict (id) do nothing;

-- 11. فواتير مبيعات ديمو لتغذية الإحصائيات (Orders & Order Items)
insert into orders (
  id, total, paid_amount, paid_cash, paid_visa, payment_method, type, customer, customer_id, cashier_name, notes, date, created_at
) values
  ('INV-1001', 3200, 3200, 3200, 0, 'cash', 'sale', 'أحمد محمود العبد', 'cust_1', 'المدير العام (Admin)', 'فاتورة ديمو مبيعات اليوم', to_char(now(), 'YYYY-MM-DD"T"HH24:MI:SS.MS"Z"'), now()),
  ('INV-1002', 1750, 1750, 1750, 0, 'cash', 'sale', 'سارة محمد الشريف',  'cust_2', 'المدير العام (Admin)', 'فاتورة ديمو حقيبة كوتش', to_char(now(), 'YYYY-MM-DD"T"HH24:MI:SS.MS"Z"'), now()),
  ('INV-1003', 1350, 1350, 0, 1350, 'visa', 'sale', 'محمود إبراهيم علي', 'cust_3', 'كاشير الفرع الرئيسي', 'فاتورة فيزا كاسيو إيديفيس', to_char(now(), 'YYYY-MM-DD"T"HH24:MI:SS.MS"Z"'), now()),
  ('INV-1004', 680,  680,  680,  0, 'cash', 'sale', 'منى عبد العزيز',   'cust_4', 'المدير العام (Admin)', 'فاتورة إسوارة كارتييه', to_char(now(), 'YYYY-MM-DD"T"HH24:MI:SS.MS"Z"'), now()),
  ('INV-1005', 2400, 2400, 2400, 0, 'cash', 'sale', 'أحمد محمود العبد', 'cust_1', 'المدير العام (Admin)', 'مبيعات هذا الأسبوع', to_char(now() - interval '2 days', 'YYYY-MM-DD"T"HH24:MI:SS.MS"Z"'), now() - interval '2 days'),
  ('INV-1006', 4200, 4200, 4200, 0, 'cash', 'sale', 'سارة محمد الشريف',  'cust_2', 'المدير العام (Admin)', 'مبيعات هذا الأسبوع', to_char(now() - interval '3 days', 'YYYY-MM-DD"T"HH24:MI:SS.MS"Z"'), now() - interval '3 days'),
  ('INV-1007', 3800, 3800, 3800, 0, 'cash', 'sale', 'محمود إبراهيم علي', 'cust_3', 'المدير العام (Admin)', 'مبيعات هذا الشهر', to_char(now() - interval '10 days', 'YYYY-MM-DD"T"HH24:MI:SS.MS"Z"'), now() - interval '10 days')
on conflict (id) do update set
  total = excluded.total,
  paid_amount = excluded.paid_amount,
  date = excluded.date;

-- بنود الفواتير (Order Items)
insert into order_items (id, order_id, product_id, product_name, barcode, quantity, sale_price, purchase_price) values
  ('item_101', 'INV-1001', 'prod_1', 'ساعة رولكس دايتونا استيل سبورت', '1001', 1, 3200, 1800),
  ('item_102', 'INV-1002', 'prod_6', 'حقيبة يد كوتش جلد طبيعي بيج',   '2001', 1, 1750, 950),
  ('item_103', 'INV-1003', 'prod_2', 'ساعة كاسيو إيديفيس رجالي أسود',  '1002', 1, 1350, 700),
  ('item_104', 'INV-1004', 'prod_10','إسوارة كارتييه لوف ستيل ذهبي',   '3001', 1, 680,  350),
  ('item_105', 'INV-1005', 'prod_8', 'شنطة ظهر لويس فيتون مونوغرام',  '2003', 1, 2400, 1350),
  ('item_106', 'INV-1006', 'prod_4', 'ساعة أوميغا سيمستر استيل فضي', '1004', 1, 4200, 2400),
  ('item_107', 'INV-1007', 'prod_3', 'ساعة كارتييه سانتوس جلد بني',   '1003', 1, 3800, 2100)
on conflict (id) do nothing;

-- 12. المصروفات ديمو (Expenses)
insert into expenses (id, category, amount, paid_cash, note, payment_method, date, created_at) values
  ('exp_101', 'كهرباء وإيجار', 1500, 1500, 'فاتورة كهرباء وإيجار الفرع الرئيسي', 'cash', to_char(now(), 'YYYY-MM-DD"T"HH24:MI:SS.MS"Z"'), now()),
  ('exp_102', 'مصاريف شحن',   350,  350,  'مصاريف شحن طرد بوسطة للعميل',        'cash', to_char(now(), 'YYYY-MM-DD"T"HH24:MI:SS.MS"Z"'), now()),
  ('exp_103', 'نثريات',       250,  250,  'نثريات وضيافة العملاء بالمعرض',     'cash', to_char(now() - interval '2 days', 'YYYY-MM-DD"T"HH24:MI:SS.MS"Z"'), now() - interval '2 days'),
  ('exp_104', 'صيانة وتشغيل',  600,  600,  'صيانة طابعة الفواتير والسيستم',      'cash', to_char(now() - interval '5 days', 'YYYY-MM-DD"T"HH24:MI:SS.MS"Z"'), now() - interval '5 days')
on conflict (id) do nothing;

-- 13. فواتير المشتريات ديمو (Purchase Invoices & Items)
insert into purchase_invoices (id, invoice_number, supplier_id, total, paid_amount, paid_cash, payment_method, notes, created_at) values
  ('pur_101', 'PINV-501', 'sup_1', 12500, 12500, 12500, 'cash', 'توريد طقم ساعات رولكس وأوميغا', now()),
  ('pur_102', 'PINV-502', 'sup_2', 8400,  8400,  8400,  'cash', 'توريد تشكيلة شنط ومافظ جلد', now())
on conflict (id) do nothing;

insert into purchase_items (id, invoice_id, product_id, quantity, purchase_price, to_display) values
  ('pitem_101', 'pur_101', 'prod_1', 5, 1800, 5),
  ('pitem_102', 'pur_102', 'prod_6', 4, 950, 4)
on conflict (id) do nothing;

-- -----------------------------------------------------------------------------
-- تم إعداد وتعبئة قاعدة البيانات بنجاح بكافة بيانات المبيعات والمصروفات والديمو!
-- -----------------------------------------------------------------------------



-- ==========================================================================
-- SOURCE: db/00_fresh_setup_extras.sql
-- ==========================================================================

-- =============================================================================
-- ADRIA — schema extras for a FRESH database.
-- Run this AFTER setup_new_database.sql. It adds every column/table the app
-- needs that the base file may be missing. Idempotent — safe to run again.
-- =============================================================================

-- Customers ------------------------------------------------------------------
alter table customers add column if not exists card_number text;

-- Products: units + fractional (weight) quantities -------------------------
alter table products add column if not exists unit text not null default 'قطعة';
alter table products alter column stock_quantity type numeric using stock_quantity::numeric;
alter table purchase_items alter column quantity type numeric using quantity::numeric;
alter table order_items alter column quantity type numeric using quantity::numeric;
alter table order_items alter column returned_quantity type numeric using returned_quantity::numeric;

-- Order items: refunded cash per item --------------------------------------
alter table order_items add column if not exists refunded_amount numeric default 0;
update order_items set refunded_amount = 0 where refunded_amount is null;

-- Orders: payment method, soft-delete, car link, refund method -------------
alter table orders add column if not exists payment_method text default 'cash';
alter table orders add column if not exists refund_method text;
alter table orders add column if not exists car_id uuid references car_subscriptions(id) on delete set null;
alter table orders add column if not exists is_deleted boolean not null default false;
alter table orders add column if not exists deleted_at timestamptz;
alter table orders add column if not exists deletion_reason text;
create index if not exists idx_orders_is_deleted on orders(is_deleted);
create index if not exists idx_orders_deleted_at on orders(deleted_at);

-- Store settings: opening balance ------------------------------------------
alter table store_settings add column if not exists initial_balance numeric default 0;
alter table store_settings add column if not exists allow_cashier_employee_advance boolean default false;

-- Purchase invoices: payment method ----------------------------------------
alter table purchase_invoices add column if not exists payment_method text default 'cash';

-- Expenses: payment split + car link ---------------------------------------
alter table expenses add column if not exists paid_cash      numeric default 0;
alter table expenses add column if not exists paid_visa      numeric default 0;
alter table expenses add column if not exists paid_wallet    numeric default 0;
alter table expenses add column if not exists paid_instapay  numeric default 0;
alter table expenses add column if not exists payment_method text default 'cash';
alter table expenses add column if not exists car_id uuid references car_subscriptions(id) on delete set null;

-- Car subscriptions: status + subscription terms ---------------------------
alter table car_subscriptions add column if not exists status text default 'active';
alter table car_subscriptions add column if not exists subscription_duration_months integer;
alter table car_subscriptions add column if not exists subscription_frequency_days integer;

-- Employees: phone, status, leave balance, hire date -----------------------
alter table employees add column if not exists phone text;
alter table employees add column if not exists is_active boolean not null default true;
alter table employees add column if not exists annual_leave_balance numeric not null default 0;
alter table employees add column if not exists hire_date date default current_date;
create index if not exists idx_employees_is_active on employees(is_active);

-- Employee transactions: deductions + incentive type -----------------------
alter table employee_transactions add column if not exists deductions numeric default 0;
alter table employee_transactions drop constraint if exists employee_transactions_type_check;
alter table employee_transactions
  add constraint employee_transactions_type_check
  check (type in ('salary', 'advance', 'incentive'));

-- Cashiers: login email (for Supabase Auth) --------------------------------
alter table cashiers add column if not exists email text;



-- ==========================================================================
-- SOURCE: db/01_setup_adria.sql
-- ==========================================================================

-- ============================================================
-- ADRIA — متجر ملابس | إعداد قاعدة البيانات من الصفر (نسخة فاضية)
-- ينشئ كل الجداول + تصنيفات ملابس فقط، بدون أي منتجات أو بيانات.
-- شغّله بالكامل مرة واحدة: Supabase > SQL Editor > New query > Run
-- ============================================================

create extension if not exists pgcrypto;
create extension if not exists "uuid-ossp";

-- ============================================================
-- 1) الجداول
-- ============================================================

create table if not exists store_settings (
  id uuid default gen_random_uuid() primary key,
  name text not null default 'ADRIA',
  currency text default 'ج.م',
  logo text default 'https://cdn-icons-png.flaticon.com/512/3531/3531849.png',
  tax_rate numeric default 0,
  theme_color text default '#4f46e5',
  address text default '',
  phone text default '',
  phone2 text default '',
  whatsapp_country_code text default '2',
  initial_balance numeric default 0,
  location_url text default ''
);

create table if not exists categories (
  id uuid default gen_random_uuid() primary key,
  name text not null,
  created_at timestamptz default now()
);

create table if not exists products (
  id uuid default gen_random_uuid() primary key,
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
  category_id uuid references categories(id) on delete set null,
  is_hidden boolean default false,
  created_at timestamptz default now()
);

create table if not exists customers (
  id uuid default gen_random_uuid() primary key,
  custom_id text unique,
  name text not null default 'بدون اسم',
  phone text unique not null,
  card_number text,
  created_at timestamptz default now()
);

create table if not exists suppliers (
  id uuid default gen_random_uuid() primary key,
  name text not null,
  phone text,
  address text,
  created_at timestamptz default now()
);

create table if not exists car_subscriptions (
  id uuid primary key default gen_random_uuid(),
  car_number text not null,
  car_details text,
  customer_name text,
  customer_phone text,
  status text default 'active',
  subscription_duration_months integer,
  subscription_frequency_days integer,
  created_at timestamptz default now()
);

create table if not exists maintenance_appointments (
  id uuid primary key default gen_random_uuid(),
  subscription_id uuid not null references car_subscriptions(id) on delete cascade,
  appointment_date date not null,
  description text,
  report text,
  cost numeric default 0,
  status text default 'pending',
  is_reminded boolean default false,
  created_at timestamptz default now()
);

create table if not exists purchase_invoices (
  id uuid default gen_random_uuid() primary key,
  invoice_number text not null,
  supplier_id uuid references suppliers(id) on delete set null,
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
  id uuid default gen_random_uuid() primary key,
  invoice_id uuid references purchase_invoices(id) on delete cascade,
  product_id uuid references products(id) on delete set null,
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
  customer_id uuid references customers(id) on delete set null,
  cashier_name text,
  car_id uuid references car_subscriptions(id) on delete set null,
  coupon_code text,
  discount_amount numeric default 0,
  is_deleted boolean not null default false,
  deleted_at timestamptz,
  deletion_reason text,
  notes text,
  created_at timestamptz default now()
);
create index if not exists idx_orders_is_deleted on orders(is_deleted);
create index if not exists idx_orders_deleted_at on orders(deleted_at);

create table if not exists invoice_counter (
  id int primary key default 1,
  current_value integer default 1,
  check (id = 1)
);
insert into invoice_counter (id, current_value) values (1, 1)
on conflict (id) do nothing;

create table if not exists order_items (
  id uuid default gen_random_uuid() primary key,
  order_id text references orders(id) on delete cascade,
  product_id uuid references products(id) on delete set null,
  product_name text not null,
  barcode text,
  quantity numeric default 1,
  returned_quantity numeric default 0,
  refunded_amount numeric default 0,
  sale_price numeric default 0,
  purchase_price numeric default 0
);

create table if not exists expenses (
  id uuid default gen_random_uuid() primary key,
  category text not null,
  amount numeric not null default 0,
  note text,
  payment_method text default 'cash',
  paid_cash numeric default 0,
  paid_visa numeric default 0,
  paid_wallet numeric default 0,
  paid_instapay numeric default 0,
  car_id uuid references car_subscriptions(id) on delete set null,
  created_at timestamptz default now()
);

create table if not exists financing_accounts (
  id uuid default gen_random_uuid() primary key,
  type text not null default 'loan',
  lender_name text not null,
  lender_phone text default '',
  lender_details text default '',
  description text default '',
  principal_amount numeric not null default 0,
  collection_amount numeric not null default 0,
  collection_date date not null,
  installment_count integer not null default 1,
  status text not null default 'open',
  created_at timestamptz default now()
);

create table if not exists financing_payments (
  id uuid default gen_random_uuid() primary key,
  account_id uuid references financing_accounts(id) on delete cascade,
  payment_type text not null,
  due_date date not null,
  amount numeric not null default 0,
  paid_amount numeric not null default 0,
  remaining_amount numeric not null default 0,
  status text not null default 'pending',
  paid_at timestamptz,
  expense_id uuid references expenses(id) on delete set null,
  note text,
  created_at timestamptz default now()
);

create table if not exists financing_transactions (
  id uuid default gen_random_uuid() primary key,
  account_id uuid references financing_accounts(id) on delete cascade,
  payment_id uuid references financing_payments(id) on delete cascade,
  transaction_type text not null,
  amount numeric not null default 0,
  remaining_after numeric not null default 0,
  payment_method text not null default 'cash',
  expense_id uuid references expenses(id) on delete set null,
  note text,
  created_at timestamptz default now()
);

create table if not exists cashiers (
  id uuid default gen_random_uuid() primary key,
  name text not null,
  password text,
  phone text,
  photo_url text,
  email text,
  created_at timestamptz default now()
);

create table if not exists employees (
  id uuid default gen_random_uuid() primary key,
  name text not null,
  job_title text,
  phone text,
  working_hours text,
  monthly_salary numeric default 0,
  annual_leave_balance numeric not null default 0,
  hire_date date default current_date,
  is_active boolean not null default true,
  cashier_id uuid,
  commission_rate numeric default 0,
  created_at timestamptz default now()
);
create index if not exists idx_employees_is_active on employees(is_active);

create table if not exists employee_transactions (
  id uuid default gen_random_uuid() primary key,
  employee_id uuid references employees(id) on delete cascade,
  amount numeric not null,
  type text check (type in ('salary', 'advance', 'incentive')),
  payment_method text default 'cash',
  paid_cash numeric default 0,
  paid_visa numeric default 0,
  paid_wallet numeric default 0,
  paid_instapay numeric default 0,
  deductions numeric default 0,
  month text,
  note text,
  created_at timestamptz default now()
);

create table if not exists employee_leaves (
  id uuid default gen_random_uuid() primary key,
  employee_id uuid references employees(id) on delete cascade,
  start_date date not null,
  end_date date not null,
  days_count numeric not null default 1,
  leave_type text not null check (leave_type in ('paid', 'unpaid')),
  deduction_amount numeric not null default 0,
  month text,
  note text,
  created_at timestamptz default now()
);
create index if not exists idx_employee_leaves_employee_id on employee_leaves(employee_id);
create index if not exists idx_employee_leaves_month on employee_leaves(month);
create index if not exists idx_employee_leaves_start_date on employee_leaves(start_date);

create table if not exists product_suggestions (
  id uuid default gen_random_uuid() primary key,
  name text not null,
  notes text,
  is_purchased boolean default false,
  created_at timestamptz default now()
);

create table if not exists cashier_notes (
  id uuid default gen_random_uuid() primary key,
  cashier_name text not null,
  note text not null,
  is_read boolean default false,
  created_at timestamptz default now()
);

create table if not exists coupons (
  id uuid default gen_random_uuid() primary key,
  code text not null unique,
  discount_type text not null default 'percentage' check (discount_type in ('percentage','fixed')),
  discount_value numeric not null default 0,
  start_date timestamptz,
  end_date timestamptz,
  max_uses_per_customer integer,
  max_uses_total integer,
  used_count integer not null default 0,
  is_active boolean not null default true,
  created_at timestamptz default now()
);

-- ============================================================
-- 2) تفعيل RLS + سياسات مفتوحة (تُقفل لاحقاً بـ secure_rls_migration.sql)
-- ============================================================
do $$
declare t text;
begin
  foreach t in array array[
    'store_settings','categories','products','customers','suppliers',
    'car_subscriptions','maintenance_appointments','purchase_invoices','purchase_items',
    'orders','invoice_counter','order_items','expenses',
    'financing_accounts','financing_payments','financing_transactions',
    'cashiers','employees','employee_transactions','employee_leaves',
    'product_suggestions','cashier_notes','coupons'
  ]
  loop
    execute format('alter table %I enable row level security;', t);
    if not exists (
      select 1 from pg_policies where schemaname = 'public' and tablename = t and policyname = 'allow all'
    ) then
      execute format('create policy "allow all" on %I for all using (true) with check (true);', t);
    end if;
  end loop;
end $$;

do $$
begin
  begin execute 'alter publication supabase_realtime add table car_subscriptions'; exception when others then null; end;
  begin execute 'alter publication supabase_realtime add table maintenance_appointments'; exception when others then null; end;
end $$;

-- ============================================================
-- 3) بيانات أولية: إعدادات المتجر + تصنيفات ملابس فقط (بدون منتجات)
-- ============================================================

insert into store_settings (name, currency, tax_rate, theme_color, initial_balance)
select 'ADRIA', 'ج.م', 0, '#4f46e5', 0
where not exists (select 1 from store_settings);

insert into categories (id, name) values
  (gen_random_uuid()::text, 'رجالي'),
  (gen_random_uuid()::text, 'حريمي'),
  (gen_random_uuid()::text, 'أطفالي'),
  (gen_random_uuid()::text, 'أحذية'),
  (gen_random_uuid()::text, 'شنط وإكسسوارات'),
  (gen_random_uuid()::text, 'ملابس داخلية'),
  (gen_random_uuid()::text, 'ملابس رياضية'),
  (gen_random_uuid()::text, 'شتوي وجاكيتات')
on conflict do nothing;

-- ============================================================
-- تم. كل الجداول جاهزة + 8 تصنيفات ملابس، بدون أي منتجات.
-- ============================================================



-- ==========================================================================
-- SOURCE: db/02_login_rpc.sql
-- ==========================================================================

-- =============================================================================
-- POS LOGIN DATA RPC  (run AFTER secure_rls_migration.sql)
-- =============================================================================
-- After the RLS lockdown, the cashier login screen can no longer read the
-- `cashiers` table with the anon key — so the "choose your name" dropdown is
-- empty and cashiers cannot log in.
--
-- This SECURITY DEFINER function exposes ONLY what the login screen needs:
--   * basic store branding (name / logo / colour / currency)
--   * each cashier's id, name, and login email  (NO passwords)
-- It is the only cashier data anon can see. Safe to run more than once.
-- =============================================================================

create or replace function public.get_pos_login_data()
returns jsonb
language sql
security definer
set search_path = public
as $$
  select jsonb_build_object(
    'settings', (
      select jsonb_build_object(
        'name', s.name, 'currency', s.currency,
        'logo', s.logo, 'theme_color', s.theme_color
      )
      from store_settings s limit 1
    ),
    'cashiers', (
      select coalesce(
        jsonb_agg(jsonb_build_object('id', c.id, 'name', c.name, 'email', c.email)
                  order by c.created_at desc),
        '[]'::jsonb)
      from cashiers c
    )
  );
$$;

revoke all on function public.get_pos_login_data() from public;
grant execute on function public.get_pos_login_data() to anon, authenticated;



-- ==========================================================================
-- SOURCE: db/03_refund_method.sql
-- ==========================================================================

-- Stores the payment method the cashier used to refund a return
-- (cash / visa / wallet / instapay) so the treasury attributes the cash
-- outflow to the correct method. Safe, nullable, run once on each project.
alter table orders add column if not exists refund_method text;



-- ==========================================================================
-- SOURCE: db/04_manufacturing.sql
-- ==========================================================================

-- ============================================================
-- ADRIA — موديول التصنيع (خامات + أوامر تصنيع)
-- شغّله مرة واحدة على قاعدة البيانات.
-- ============================================================

-- لون المنتج (للملابس)
alter table products add column if not exists color text;

-- الخامات (أقمشة، خيوط، أزرار... إلخ)
create table if not exists materials (
  id uuid default gen_random_uuid() primary key,
  name text not null,
  unit text not null default 'متر',
  cost_per_unit numeric not null default 0,
  stock_quantity numeric not null default 0,
  created_at timestamptz default now()
);

-- أوامر التصنيع (دفعة إنتاج)
create table if not exists production_orders (
  id text default gen_random_uuid()::text primary key,
  product_id text references products(id) on delete set null,
  product_name text not null,
  color text,
  code text,
  quantity numeric not null default 0,
  materials_cost numeric not null default 0,
  extra_costs numeric not null default 0,
  total_cost numeric not null default 0,
  cost_per_piece numeric not null default 0,
  sale_price numeric not null default 0,
  notes text,
  created_at timestamptz default now()
);

-- الخامات المستهلكة في كل أمر تصنيع
create table if not exists production_materials (
  id text default gen_random_uuid()::text primary key,
  production_id text references production_orders(id) on delete cascade,
  material_id text references materials(id) on delete set null,
  material_name text,
  quantity numeric not null default 0,
  cost numeric not null default 0
);

-- RLS مفتوح مؤقتاً (يُقفل بـ secure_rls_migration.sql لاحقاً)
do $$
declare t text;
begin
  foreach t in array array['materials','production_orders','production_materials']
  loop
    execute format('alter table %I enable row level security;', t);
    if not exists (
      select 1 from pg_policies where schemaname = 'public' and tablename = t and policyname = 'allow all'
    ) then
      execute format('create policy "allow all" on %I for all using (true) with check (true);', t);
    end if;
  end loop;
end $$;



-- ==========================================================================
-- SOURCE: db/05_product_discount.sql
-- ==========================================================================

-- ADRIA — سعر البيع بعد الخصم للمنتجات. شغّله مرة واحدة.
alter table products add column if not exists discount_price numeric default 0;



-- ==========================================================================
-- SOURCE: db/06_inventory_locations.sql
-- ==========================================================================

-- ADRIA — تقسيم المخزون: مستودع + معرض.
-- stock_quantity = الإجمالي (زي ما هو). display_quantity = الكمية المعروضة في المحل.
-- المستودع = الإجمالي - المعروض. شغّله مرة واحدة.
alter table products add column if not exists display_quantity numeric default 0;



-- ==========================================================================
-- SOURCE: db/07_seasons_wholesale.sql
-- ==========================================================================

-- ADRIA — تصنيف موسمي + أسعار الجملة. شغّله مرة واحدة.
alter table products add column if not exists season text;                       -- 'summer' / 'winter'
alter table products add column if not exists wholesale_price numeric default 0;      -- سعر الجملة
alter table products add column if not exists half_wholesale_price numeric default 0; -- سعر نص الجملة



-- ==========================================================================
-- SOURCE: db/08_public_invoice_prices.sql
-- ==========================================================================

-- ADRIA — adds product sale_price + discount_price to the public-invoice RPC
-- so the e-invoice can show the price before & after discount. Run once.
create or replace function public.get_public_invoice(p_id text)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_settings jsonb;
  v_order jsonb;
  v_customer_id uuid;
  v_customer_orders jsonb := '[]'::jsonb;
  v_appointment jsonb;
  v_subscription_id uuid;
  v_appointment_orders jsonb := '[]'::jsonb;
  v_purchase jsonb;
begin
  select jsonb_build_object(
           'name', s.name, 'currency', s.currency, 'logo', s.logo,
           'tax_rate', s.tax_rate, 'theme_color', s.theme_color,
           'address', s.address, 'phone', s.phone, 'phone2', s.phone2,
           'whatsapp_country_code', s.whatsapp_country_code,
           'initial_balance', s.initial_balance, 'location_url', s.location_url
         )
    into v_settings
  from store_settings s limit 1;

  select to_jsonb(o) || jsonb_build_object(
           'customers', (select to_jsonb(c) from customers c where c.id = o.customer_id),
           'order_items', (
             select coalesce(jsonb_agg(to_jsonb(oi) || jsonb_build_object(
                      'products', (select jsonb_build_object('name', p.name, 'sale_price', p.sale_price, 'discount_price', p.discount_price) from products p where p.id = oi.product_id)
                    )), '[]'::jsonb)
             from order_items oi where oi.order_id = o.id
           )
         ), o.customer_id
    into v_order, v_customer_id
  from orders o where o.id = p_id;

  if v_order is not null then
    if v_customer_id is not null then
      select coalesce(jsonb_agg(
               to_jsonb(o2) || jsonb_build_object(
                 'order_items', (
                   select coalesce(jsonb_agg(jsonb_build_object(
                            'quantity', oi.quantity, 'sale_price', oi.sale_price,
                            'returned_quantity', oi.returned_quantity, 'refunded_amount', oi.refunded_amount
                          )), '[]'::jsonb)
                   from order_items oi where oi.order_id = o2.id
                 )
               )
             ), '[]'::jsonb)
        into v_customer_orders
      from orders o2
      where o2.customer_id = v_customer_id and o2.is_deleted = false;
    end if;
    return jsonb_build_object('kind', 'order', 'settings', v_settings,
                             'order', v_order, 'customer_orders', v_customer_orders);
  end if;

  if to_regclass('public.maintenance_appointments') is not null then
    select to_jsonb(a) || jsonb_build_object(
             'car_subscriptions', (select to_jsonb(cs) from car_subscriptions cs where cs.id = a.subscription_id)
           ), a.subscription_id
      into v_appointment, v_subscription_id
    from maintenance_appointments a where a.id = p_id;
    if v_appointment is not null then
      select coalesce(jsonb_agg(
               to_jsonb(o) || jsonb_build_object(
                 'order_items', (
                   select coalesce(jsonb_agg(to_jsonb(oi) || jsonb_build_object(
                            'products', (select jsonb_build_object('name', p.name, 'sale_price', p.sale_price, 'discount_price', p.discount_price) from products p where p.id = oi.product_id)
                          )), '[]'::jsonb)
                   from order_items oi where oi.order_id = o.id
                 )
               )
             ), '[]'::jsonb)
        into v_appointment_orders
      from orders o where o.car_id = v_subscription_id and o.is_deleted = false;
      return jsonb_build_object('kind', 'maintenance', 'settings', v_settings,
                               'appointment', v_appointment, 'appointment_orders', v_appointment_orders);
    end if;
  end if;

  select to_jsonb(pi) || jsonb_build_object(
           'suppliers', (select to_jsonb(su) from suppliers su where su.id = pi.supplier_id),
           'purchase_items', (
             select coalesce(jsonb_agg(to_jsonb(it) || jsonb_build_object(
                      'products', (select jsonb_build_object('name', p.name, 'sale_price', p.sale_price, 'discount_price', p.discount_price) from products p where p.id = it.product_id)
                    )), '[]'::jsonb)
             from purchase_items it where it.invoice_id = pi.id
           )
         )
    into v_purchase
  from purchase_invoices pi
  where pi.id::text = p_id or pi.invoice_number::text = p_id limit 1;

  if v_purchase is not null then
    return jsonb_build_object('kind', 'purchase', 'settings', v_settings, 'purchase', v_purchase);
  end if;

  return null;
end;
$$;

revoke all on function public.get_public_invoice(text) from public;
grant execute on function public.get_public_invoice(text) to anon, authenticated;



-- ==========================================================================
-- SOURCE: db/09_cashier_employee_commission.sql
-- ==========================================================================

-- ADRIA — ربط الكاشير بملف موظف + عمولة المبيعات. شغّله مرة واحدة.
alter table employees add column if not exists cashier_id uuid;
alter table employees add column if not exists commission_rate numeric default 0;



-- ==========================================================================
-- SOURCE: db/10_manager_withdrawals.sql
-- ==========================================================================

-- ADRIA — قائمة المدراء (سحوبات المدير تُسجّل كمصروف category='سحب مدير'). شغّله مرة واحدة.
-- (آمن لإعادة التشغيل — يقفل الجدول على المستخدم المسجّل فقط.)
create table if not exists managers (
  id uuid default gen_random_uuid() primary key,
  name text not null,
  created_at timestamptz default now()
);

-- قفل الجدول على المستخدم المسجّل فقط (نفس سياسة باقي الجداول بعد التأمين).
alter table managers enable row level security;
drop policy if exists "allow all" on managers;
drop policy if exists "authenticated full access" on managers;
create policy "authenticated full access" on managers for all to authenticated using (true) with check (true);
revoke all on managers from anon;
grant all on managers to authenticated;



-- ==========================================================================
-- SOURCE: db/11_fix_public_invoice_uuid.sql
-- ==========================================================================

-- ADRIA — إصلاح فتح فاتورة الشراء من لينك التليجرام.
-- المشكلة: get_public_invoice كانت بتقارن maintenance_appointments.id (uuid) = p_id (text)
-- فبترمي خطأ "operator does not exist: uuid = text" مع أي id مش order → اللينك مبيفتحش.
-- الحل: cast كل المقارنات لـ ::text. شغّله مرة واحدة.
create or replace function public.get_public_invoice(p_id text)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_settings jsonb;
  v_order jsonb;
  v_customer_id uuid;
  v_customer_orders jsonb := '[]'::jsonb;
  v_appointment jsonb;
  v_subscription_id uuid;
  v_appointment_orders jsonb := '[]'::jsonb;
  v_purchase jsonb;
begin
  select jsonb_build_object(
           'name', s.name, 'currency', s.currency, 'logo', s.logo,
           'tax_rate', s.tax_rate, 'theme_color', s.theme_color,
           'address', s.address, 'phone', s.phone, 'phone2', s.phone2,
           'whatsapp_country_code', s.whatsapp_country_code,
           'initial_balance', s.initial_balance, 'location_url', s.location_url
         )
    into v_settings
  from store_settings s
  limit 1;

  -- (a) Sale order
  select to_jsonb(o) || jsonb_build_object(
           'customers', (select to_jsonb(c) from customers c where c.id = o.customer_id),
           'order_items', (
             select coalesce(jsonb_agg(to_jsonb(oi) || jsonb_build_object(
                      'products', (select jsonb_build_object('name', p.name, 'sale_price', p.sale_price, 'discount_price', p.discount_price) from products p where p.id = oi.product_id)
                    )), '[]'::jsonb)
             from order_items oi where oi.order_id = o.id
           )
         ), o.customer_id
    into v_order, v_customer_id
  from orders o where o.id::text = p_id;

  if v_order is not null then
    if v_customer_id is not null then
      select coalesce(jsonb_agg(
               to_jsonb(o2) || jsonb_build_object(
                 'order_items', (
                   select coalesce(jsonb_agg(jsonb_build_object(
                            'quantity', oi.quantity, 'sale_price', oi.sale_price,
                            'returned_quantity', oi.returned_quantity, 'refunded_amount', oi.refunded_amount
                          )), '[]'::jsonb)
                   from order_items oi where oi.order_id = o2.id
                 )
               )
             ), '[]'::jsonb)
        into v_customer_orders
      from orders o2
      where o2.customer_id = v_customer_id and o2.is_deleted = false;
    end if;

    return jsonb_build_object('kind', 'order', 'settings', v_settings,
                             'order', v_order, 'customer_orders', v_customer_orders);
  end if;

  -- (b) Maintenance appointment
  if to_regclass('public.maintenance_appointments') is not null then
    select to_jsonb(a) || jsonb_build_object(
             'car_subscriptions', (select to_jsonb(cs) from car_subscriptions cs where cs.id = a.subscription_id)
           ), a.subscription_id
      into v_appointment, v_subscription_id
    from maintenance_appointments a where a.id::text = p_id;

    if v_appointment is not null then
      select coalesce(jsonb_agg(
               to_jsonb(o) || jsonb_build_object(
                 'order_items', (
                   select coalesce(jsonb_agg(to_jsonb(oi) || jsonb_build_object(
                            'products', (select jsonb_build_object('name', p.name, 'sale_price', p.sale_price, 'discount_price', p.discount_price) from products p where p.id = oi.product_id)
                          )), '[]'::jsonb)
                   from order_items oi where oi.order_id = o.id
                 )
               )
             ), '[]'::jsonb)
        into v_appointment_orders
      from orders o
      where o.car_id = v_subscription_id and o.is_deleted = false;

      return jsonb_build_object('kind', 'maintenance', 'settings', v_settings,
                               'appointment', v_appointment, 'appointment_orders', v_appointment_orders);
    end if;
  end if;

  -- (c) Purchase invoice (by id or invoice_number)
  select to_jsonb(pi) || jsonb_build_object(
           'suppliers', (select to_jsonb(su) from suppliers su where su.id = pi.supplier_id),
           'purchase_items', (
             select coalesce(jsonb_agg(to_jsonb(it) || jsonb_build_object(
                      'products', (select jsonb_build_object('name', p.name, 'sale_price', p.sale_price, 'discount_price', p.discount_price) from products p where p.id = it.product_id)
                    )), '[]'::jsonb)
             from purchase_items it where it.invoice_id = pi.id
           )
         )
    into v_purchase
  from purchase_invoices pi
  where pi.id::text = p_id or pi.invoice_number::text = p_id
  limit 1;

  if v_purchase is not null then
    return jsonb_build_object('kind', 'purchase', 'settings', v_settings, 'purchase', v_purchase);
  end if;

  return null;
end;
$$;

revoke all on function public.get_public_invoice(text) from public;
grant execute on function public.get_public_invoice(text) to anon, authenticated;



-- ==========================================================================
-- SOURCE: db/13_manufacturing_supplier_factory.sql
-- ==========================================================================

-- ADRIA — التصنيع: ربط الخامة بمورد + مخزن المصنع للمنتجات. شغّله مرة واحدة.
alter table materials add column if not exists supplier_id uuid;
alter table products add column if not exists factory_quantity numeric default 0;



-- ==========================================================================
-- SOURCE: db/14_otp_and_salesperson.sql
-- ==========================================================================

-- ADRIA — (1) رموز OTP لفواتير الجملة/نص الجملة  (2) الموظف البائع على الفاتورة
-- شغّله مرة واحدة.

-- (1) جدول رموز التحقق — تستخدمه دالة السيرفر فقط (service role). RLS مقفول للباقي.
create table if not exists otp_codes (
  id uuid default gen_random_uuid() primary key,
  code text not null,
  purpose text default 'wholesale',
  expires_at timestamptz not null,
  used boolean default false,
  created_at timestamptz default now()
);
alter table otp_codes enable row level security;
-- لا نضيف أي policy → anon/authenticated ممنوعين تماماً؛ السيرفر بمفتاح الخدمة فقط.

-- (2) الموظف البائع على الفاتورة (لحساب مبيعاته وأرباحه للعمولة)
alter table orders add column if not exists salesperson_id uuid;
alter table orders add column if not exists salesperson_name text;



-- ==========================================================================
-- SOURCE: db/15_partners.sql
-- ==========================================================================

-- ADRIA — موديول الشركاء: نسبة كل شريك + رصيد افتتاحي + إيداع/سحب لكل شريك. شغّله مرة واحدة.

create table if not exists partners (
  id uuid default gen_random_uuid() primary key,
  name text not null,
  share_percent numeric default 0,     -- نسبة الشريك في المؤسسة %
  opening_balance numeric default 0,   -- الرصيد الافتتاحي للشريك
  created_at timestamptz default now()
);

create table if not exists partner_transactions (
  id uuid default gen_random_uuid() primary key,
  partner_id uuid not null,
  partner_name text,
  type text not null,                  -- 'deposit' (إيداع) | 'withdraw' (سحب)
  amount numeric not null,
  treasury text default 'shop',        -- 'shop' (خزنة المحل) | 'main' (الخزنة الأساسية)
  method text default 'cash',          -- cash / visa / wallet / instapay
  note text,
  created_at timestamptz default now()
);

-- قفل الجدولين على المستخدم المسجّل فقط (نفس سياسة باقي الجداول).
do $$
declare t text;
begin
  foreach t in array array['partners','partner_transactions'] loop
    execute format('alter table public.%I enable row level security;', t);
    execute format('drop policy if exists "authenticated full access" on public.%I;', t);
    execute format('create policy "authenticated full access" on public.%I for all to authenticated using (true) with check (true);', t);
    execute format('revoke all on public.%I from anon;', t);
    execute format('grant all on public.%I to authenticated;', t);
  end loop;
end $$;



-- ==========================================================================
-- SOURCE: db/16_savings.sql
-- ==========================================================================

-- ADRIA — خزنة الادخار (منفصلة عن خزنة المحل). شغّله مرة واحدة.
create table if not exists savings_transactions (
  id uuid default gen_random_uuid() primary key,
  direction text not null,   -- 'in' (تحويل من المحل للادخار) | 'out' (تحويل من الادخار للمحل)
  amount numeric not null,
  method text default 'cash',-- cash / visa / wallet / instapay  (كل طريقة تنتقل بطريقتها)
  source text,               -- 'shop_transfer' | 'day_closing' | 'to_shop' | 'manual'
  note text,
  created_at timestamptz default now()
);
alter table savings_transactions enable row level security;
drop policy if exists "authenticated full access" on savings_transactions;
create policy "authenticated full access" on savings_transactions for all to authenticated using (true) with check (true);
revoke all on savings_transactions from anon;
grant all on savings_transactions to authenticated;



-- ==========================================================================
-- SOURCE: db/17_exchange.sql
-- ==========================================================================

-- ADRIA — بيانات الاستبدال على الفاتورة (الأصناف قبل/بعد + الفرق). شغّله مرة واحدة.
alter table orders add column if not exists exchange_data jsonb;



-- ==========================================================================
-- SOURCE: db/18_stock_adjustments.sql
-- ==========================================================================

-- ADRIA — سجل تسويات الجرد. شغّله مرة واحدة.
create table if not exists stock_adjustments (
  id uuid default gen_random_uuid() primary key,
  product_id uuid,
  product_name text,
  system_qty numeric,
  counted_qty numeric,
  diff numeric,            -- counted - system (سالب = عجز، موجب = زيادة)
  cost numeric default 0,  -- تكلفة الوحدة وقت الجرد
  note text,
  created_at timestamptz default now()
);
alter table stock_adjustments enable row level security;
drop policy if exists "authenticated full access" on stock_adjustments;
create policy "authenticated full access" on stock_adjustments for all to authenticated using (true) with check (true);
revoke all on stock_adjustments from anon;
grant all on stock_adjustments to authenticated;



-- ==========================================================================
-- SOURCE: db/19_settings_extras.sql
-- ==========================================================================

-- ADRIA — صلاحيات الكاشير + تسميات وسائل الدفع (المحافظ). شغّله مرة واحدة.
alter table store_settings add column if not exists cashier_permissions jsonb;
alter table store_settings add column if not exists payment_labels jsonb;



-- ==========================================================================
-- SOURCE: db/20_admin_users.sql
-- ==========================================================================

-- ADRIA — مستخدمو لوحة التحكم بصلاحيات. شغّله مرة واحدة.
create table if not exists admin_users (
  id uuid default gen_random_uuid() primary key,
  name text not null,
  password text,
  email text,
  permissions jsonb default '[]'::jsonb,  -- مصفوفة مسارات الصفحات المسموح بها
  created_at timestamptz default now()
);
alter table admin_users enable row level security;
drop policy if exists "authenticated full access" on admin_users;
create policy "authenticated full access" on admin_users for all to authenticated using (true) with check (true);
revoke all on admin_users from anon;
grant all on admin_users to authenticated;

-- قائمة الدخول (بدون كلمة السر) — يستخدمها anon في شاشة الدخول لاختيار المستخدم.
create or replace function public.get_admin_login_data()
returns jsonb language sql security definer set search_path = public as $$
  select coalesce(jsonb_agg(jsonb_build_object('id', id, 'name', name, 'email', email, 'permissions', permissions) order by name), '[]'::jsonb)
  from admin_users;
$$;
revoke all on function public.get_admin_login_data() from public;
grant execute on function public.get_admin_login_data() to anon, authenticated;



-- ==========================================================================
-- SOURCE: db/21_show_profit.sql
-- ==========================================================================

-- ADRIA — إظهار/إخفاء ربح الفاتورة في شاشة الكاشير. شغّله مرة واحدة.
alter table store_settings add column if not exists show_invoice_profit boolean default true;



-- ==========================================================================
-- SOURCE: db/22_cashier_employee_advance.sql
-- ==========================================================================

-- ADRIA — السماح للكاشير بصرف سلف للموظفين (تُخصم من راتب الشهر). شغّله مرة واحدة.
-- الافتراضي مغلق؛ يُفعّل من إعدادات النظام > صلاحيات الكاشير.
alter table store_settings add column if not exists allow_cashier_employee_advance boolean default false;



-- ==========================================================================
-- SOURCE: db/23_qz_direct_printing.sql
-- ==========================================================================

-- ADRIA — الطباعة المباشرة عبر QZ Tray.
-- لا حاجة لقاعدة البيانات: إعداد الطابعات أصبح محلياً على كل جهاز (localStorage)
-- لأن أسماء الطابعات تختلف من جهاز لآخر. هذا الملف مُبقى فارغاً للتوثيق فقط.
-- (لو سبق وأضفت الأعمدة qz_* فهي غير مستخدمة ولا ضرر منها.)



-- ==========================================================================
-- SOURCE: db/24_payment_methods_5_6.sql
-- ==========================================================================

-- ADRIA — طريقتا دفع إضافيتان (5 و6) لكل منهما حسابها الخاص في الخزنة.
-- يضيف عمودي المبلغ المدفوع لكل طريقة على كل الجداول المالية. شغّله مرة واحدة.
-- (الجداول التي تخزّن الطريقة كنص واحد مثل savings_transactions/partner_transactions
--  لا تحتاج أعمدة جديدة — تقبل القيم method5/method6 مباشرةً.)

-- إعدادات: تفعيل طرق الدفع الإضافية (التسميات تُخزّن في payment_labels الموجود مسبقاً)
alter table store_settings          add column if not exists payment_methods_enabled jsonb;

alter table orders                  add column if not exists paid_method5 numeric default 0;
alter table orders                  add column if not exists paid_method6 numeric default 0;

alter table expenses                add column if not exists paid_method5 numeric default 0;
alter table expenses                add column if not exists paid_method6 numeric default 0;

alter table purchase_invoices       add column if not exists paid_method5 numeric default 0;
alter table purchase_invoices       add column if not exists paid_method6 numeric default 0;

alter table employee_transactions   add column if not exists paid_method5 numeric default 0;
alter table employee_transactions   add column if not exists paid_method6 numeric default 0;

alter table financing_payments      add column if not exists paid_method5 numeric default 0;
alter table financing_payments      add column if not exists paid_method6 numeric default 0;

alter table financing_transactions  add column if not exists paid_method5 numeric default 0;
alter table financing_transactions  add column if not exists paid_method6 numeric default 0;



-- ==========================================================================
-- SOURCE: db/25_held_invoices.sql
-- ==========================================================================

-- =============================================================================
-- HELD / RESERVED INVOICES  (فواتير معلقة / محجوزة)
-- =============================================================================
--  A held invoice reserves stock without recording a sale. From the cashier the
--  staff can later either:
--    * تأكيد البيع  → load it back into the cart and complete a normal sale, or
--    * إرجاع للمخزون → cancel it and return the reserved quantities to stock.
--  There is NO automatic expiry: a held invoice stays held indefinitely until a
--  member of staff actions it. (An earlier version returned it to stock after 7
--  days via a client-side sweep + daily cron — both removed. The expires_at
--  column below is kept for backwards compatibility but is no longer read.)
--
--  Stock is deducted from products.stock_quantity at the moment of holding and
--  added back on return/expiry, so the available quantity always reflects the
--  reservation.
--
--  This script is idempotent — safe to run more than once.
-- =============================================================================

create table if not exists public.held_invoices (
  id uuid primary key default gen_random_uuid(),
  customer_name text,
  customer_phone text,
  customer_custom_id text,
  items jsonb not null default '[]'::jsonb,
  total numeric not null default 0,
  invoice_type text not null default 'retail',
  salesperson_id uuid,
  salesperson_name text,
  cashier_name text,
  notes text,
  created_at timestamptz not null default now(),
  expires_at timestamptz not null default (now() + interval '7 days')
);

create index if not exists idx_held_invoices_expires_at on public.held_invoices(expires_at);
create index if not exists idx_held_invoices_created_at on public.held_invoices(created_at);

-- RLS: authenticated staff only (matches secure_rls_migration.sql).
alter table public.held_invoices enable row level security;
drop policy if exists "allow all" on public.held_invoices;
drop policy if exists "authenticated full access" on public.held_invoices;
create policy "authenticated full access" on public.held_invoices
  for all to authenticated using (true) with check (true);
revoke all on public.held_invoices from anon;
grant all on public.held_invoices to authenticated;



-- ==========================================================================
-- SOURCE: db/27_devo_and_writeoff.sql
-- ==========================================================================

-- ADRIA — الديڤو (قطع راجعة للمصنع/المورد) + الإهلاك (التوالف). شغّله مرة واحدة.
--
-- الديڤو: قطعة معيبة تُسجَّل وتُتابَع حالتها حتى لا تسقط:
--   pending    = مسجّلة (خرجت من المحل / متحجوزة كديڤو)
--   at_factory = اتسلمت المصنع
--   returned   = رجعت من المصنع (نفس القطعة سليمة) → ترجع للمخزون
--   replaced   = تم استبدالها ببديل → يرجع للمخزون
--   closed     = رجعت خالص / تسوية نهائية (رصيد أو استرداد) → تظل خارج المخزون
--
-- الإهلاك: قطعة تالفة تُشطب نهائياً وتُخصم من المخزون (خسارة).

create table if not exists devo_items (
  id uuid default gen_random_uuid() primary key,
  product_id    uuid,
  product_name  text not null,
  barcode       text,
  quantity      numeric default 1,
  unit_cost     numeric default 0,
  supplier_id   uuid,
  supplier_name text,
  reason        text,
  status        text default 'pending',   -- pending | at_factory | returned | replaced | closed
  note          text,
  created_at    timestamptz default now(),
  updated_at    timestamptz default now()
);
alter table devo_items enable row level security;
drop policy if exists "authenticated full access" on devo_items;
create policy "authenticated full access" on devo_items for all to authenticated using (true) with check (true);
revoke all on devo_items from anon;
grant all on devo_items to authenticated;

create table if not exists write_offs (
  id uuid default gen_random_uuid() primary key,
  product_id   uuid,
  product_name text not null,
  barcode      text,
  quantity     numeric default 1,
  unit_cost    numeric default 0,
  total_cost   numeric default 0,
  reason       text,
  created_at   timestamptz default now()
);
alter table write_offs enable row level security;
drop policy if exists "authenticated full access" on write_offs;
create policy "authenticated full access" on write_offs for all to authenticated using (true) with check (true);
revoke all on write_offs from anon;
grant all on write_offs to authenticated;



-- ==========================================================================
-- SOURCE: db/28_ensure_settings_columns.sql
-- ==========================================================================

-- ADRIA — يضمن وجود كل أعمدة إعدادات المتجر.
-- آمن للتشغيل أكتر من مرة. شغّله لو الإعدادات (اللوجو، تسميات المحافظ، ...)
-- مش بتتحفظ وبتطلع رسالة "Could not find the '...' column of 'store_settings'".
--
-- السبب: حفظ الإعدادات بيبعت كل الأعمدة في UPDATE واحد، فأي عمود ناقص
-- بيفشّل الحفظ كله — بما فيه رفع اللوجو.
--
-- ⚠️ النسخة القديمة من الملف ده كانت بتغطي ١٣ عمود بس من ٢٤، فاللي بيشغّلها
-- كان بيقع في نفس الخطأ تاني بس على عمود مختلف (payment_opening_balances
-- أو expense_categories أو pages_qr_*). دلوقتي بتغطي **كل** الأعمدة اللي
-- updateSettings بيبعتها في src/store/useStore.ts.
--
-- لو ضفت عمود جديد في updateSettings، ضيفه هنا كمان.

-- ── الأعمدة الأساسية (من 01_setup_adria.sql — موجودة غالباً) ────────────────
alter table store_settings add column if not exists name                  text default 'ADRIA';
alter table store_settings add column if not exists currency              text default 'ج.م';
alter table store_settings add column if not exists logo                  text default '';
alter table store_settings add column if not exists tax_rate              numeric default 0;
alter table store_settings add column if not exists theme_color           text default '#4f46e5';
alter table store_settings add column if not exists address               text default '';
alter table store_settings add column if not exists phone                 text default '';
alter table store_settings add column if not exists phone2                text default '';
alter table store_settings add column if not exists initial_balance       numeric default 0;
alter table store_settings add column if not exists whatsapp_country_code text default '2';
alter table store_settings add column if not exists location_url          text default '';
alter table store_settings add column if not exists tax_number             text default '';
alter table store_settings add column if not exists commercial_record          text default '';
alter table store_settings add column if not exists default_invoice_format     text default 'A4';

-- ── وسائل الدفع والصلاحيات (19، 22، 24) ─────────────────────────────────────
alter table store_settings add column if not exists payment_labels                 jsonb;
alter table store_settings add column if not exists payment_methods_enabled        jsonb;
alter table store_settings add column if not exists cashier_permissions            jsonb;
alter table store_settings add column if not exists show_invoice_profit            boolean default true;
alter table store_settings add column if not exists allow_cashier_employee_advance boolean default false;

-- ── الأرصدة الافتتاحية (29، 32) ─────────────────────────────────────────────
alter table store_settings add column if not exists payment_opening_balances jsonb;
alter table store_settings add column if not exists savings_opening_balances jsonb;

-- ── اليوم المحاسبي (35) ─────────────────────────────────────────────────────
alter table store_settings add column if not exists day_start_hour integer default 3;

-- ── التصنيفات المخصّصة و QR الصفحات (43، 44) ────────────────────────────────
alter table store_settings add column if not exists expense_categories jsonb;
alter table store_settings add column if not exists income_categories  jsonb;
alter table store_settings add column if not exists pages_qr_url       text;
alter table store_settings add column if not exists pages_qr_label     text;
alter table store_settings add column if not exists pages_qr_image     text;

-- ── تحديث الـ schema cache بتاع PostgREST ───────────────────────────────────
-- من غير السطر ده Supabase ممكن يفضل يرجّع نفس الخطأ لدقايق رغم إن العمود
-- اتضاف فعلاً — لأن الكاش لسه مش عارف بيه. (ده بالظبط معنى رسالة
-- "in the schema cache".)
notify pgrst, 'reload schema';

-- ── تأكيد: بيعرض أي عمود لسه ناقص. المفروض النتيجة ترجع فاضية ───────────────
select c.column_name as "عمود لسه ناقص"
from (values
  ('name'),('currency'),('logo'),('tax_rate'),('theme_color'),('address'),
  ('phone'),('phone2'),('whatsapp_country_code'),('initial_balance'),
  ('location_url'),('payment_labels'),('payment_methods_enabled'),
  ('cashier_permissions'),('show_invoice_profit'),
  ('allow_cashier_employee_advance'),('payment_opening_balances'),
  ('savings_opening_balances'),('day_start_hour'),('expense_categories'),
  ('income_categories'),('pages_qr_url'),('pages_qr_label'),('pages_qr_image')
) as c(column_name)
where not exists (
  select 1 from information_schema.columns i
  where i.table_name = 'store_settings' and i.column_name = c.column_name
);



-- ==========================================================================
-- SOURCE: db/29_payment_opening_balances.sql
-- ==========================================================================

-- ADRIA — رصيد افتتاحي مستقل لكل وسيلة دفع (كاش/فيزا/محفظة/انستا/طريقة5/طريقة6).
-- يُستخدم في «كشوف حسابات وسائل الدفع». شغّله مرة واحدة.
-- الشكل: { "cash": 1000, "visa": 0, "wallet": 500, ... }

alter table store_settings add column if not exists payment_opening_balances jsonb;



-- ==========================================================================
-- SOURCE: db/31_product_supplier.sql
-- ==========================================================================

-- ADRIA — ربط المنتج باسم المورد + استيراد المخزون من Excel. شغّله مرة واحدة.
alter table products add column if not exists supplier_name text; -- اسم المورد الذي يُورّد هذا المنتج (نصّي)
create index if not exists idx_products_supplier_name on products (supplier_name);



-- ==========================================================================
-- SOURCE: db/32_savings_opening_balances.sql
-- ==========================================================================

-- ADRIA — رصيد افتتاحي مستقل لكل وسيلة دفع للخزنة الرئيسية (savings).
-- الفلوس اللي كانت موجودة في الخزنة الرئيسية قبل البدء على النظام.
-- مستقل تماماً عن payment_opening_balances (رصيد خزنة المحل).
-- الشكل: { "cash": 5000, "visa": 0, "wallet": 0, ... }. شغّله مرة واحدة.

alter table store_settings add column if not exists savings_opening_balances jsonb;



-- ==========================================================================
-- SOURCE: db/33_monthly_leave_and_attendance.sql
-- ==========================================================================

-- ADRIA — إجازات شهرية + تسجيل حضور/تأخير للموظفين. شغّله مرة واحدة في Supabase.
--
-- (1) الإجازات بقت شهرية بدل سنوية: كل موظف ليه رصيد أيام شهري يتجدد أول كل شهر.
--     اللي يزيد عن الرصيد يتخصم من الراتب حسب سعر اليوم (الراتب ÷ 30).
-- (2) الحضور: نسجّل وقت الحضور، والنظام يحسب دقائق التأخير عن بداية الدوام
--     (مع دقائق سماح) ويخصم من الراتب بالتناسب مع مدة التأخير.

-- أعمدة إضافية على جدول الموظفين.
alter table employees add column if not exists monthly_leave_days numeric not null default 4; -- رصيد الإجازة الشهري (أيام)
alter table employees add column if not exists shift_start time;                              -- بداية الدوام (مثال 10:00)
alter table employees add column if not exists shift_end time;                                -- نهاية الدوام (لحساب طول يوم العمل)
alter table employees add column if not exists late_grace_minutes numeric not null default 0; -- دقائق سماح قبل احتساب التأخير

-- سجل الحضور والتأخير.
create table if not exists employee_attendance (
  id uuid default gen_random_uuid() primary key,
  employee_id uuid references employees(id) on delete cascade,
  date date not null,
  check_in timestamptz not null,        -- وقت الحضور الفعلي
  shift_start time,                     -- بداية الدوام المتوقعة (لقطة وقت التسجيل)
  late_minutes numeric not null default 0,     -- دقائق التأخير (بعد خصم السماح)
  deduction_amount numeric not null default 0, -- خصم التأخير من الراتب
  month text,                           -- YYYY-MM
  note text,
  created_at timestamptz default now()
);

create index if not exists idx_employee_attendance_employee_id on employee_attendance(employee_id);
create index if not exists idx_employee_attendance_month on employee_attendance(month);
create index if not exists idx_employee_attendance_date on employee_attendance(date);
create unique index if not exists uq_employee_attendance_emp_date on employee_attendance(employee_id, date);

alter table employee_attendance enable row level security;
drop policy if exists "allow all" on employee_attendance;
create policy "allow all" on employee_attendance for all using (true) with check (true);



-- ==========================================================================
-- SOURCE: db/34_held_invoice_deposit.sql
-- ==========================================================================

-- ADRIA — عربون/تحصيل للفواتير المعلّقة (حجز تحت الحساب). شغّله مرة واحدة.
--
-- الفاتورة المعلّقة تقدر تحصّل عربون يدخل الخزنة وقت الحجز. لما العميل ييجي
-- بيتم إتمام الفاتورة ويكمّل الباقي أو يتحطّ آجل. لو اتلغى الحجز (يدوي أو بعد
-- أسبوع تلقائي) العربون يترد للعميل (مرتجع من الدرج) والكمية ترجع للمخزون.
--
-- حركة الفلوس بتتسجّل في جدول expenses:
--   category='حجز'        amount<0  → تحصيل عربون (داخل الخزنة)
--   category='حجز'        amount>0  → رد عربون عند الإلغاء/الانتهاء (خارج)
--   category='تحويل حجز'  amount>0  → تحويل العربون لفاتورة عند الإتمام (يمنع الازدواج)

alter table held_invoices add column if not exists deposit numeric not null default 0;
alter table held_invoices add column if not exists deposit_split jsonb;



-- ==========================================================================
-- SOURCE: db/35_day_start_hour.sql
-- ==========================================================================

-- ADRIA — ساعة بداية اليوم لتقفيل اليومية (مثلاً 3 = اليوم يبدأ 3 صباحاً).
-- الفواتير المسجّلة قبل هذه الساعة تُحسب ضمن تقفيل اليوم السابق. شغّله مرة واحدة.
alter table store_settings add column if not exists day_start_hour integer default 3;



-- ==========================================================================
-- SOURCE: db/36_refunded_at.sql
-- ==========================================================================

-- ADRIA — db/36: تاريخ الاسترجاع على الفاتورة (refunded_at)
-- آمن للتشغيل أكثر من مرة.
--
-- السبب: المرتجع كان بيتحسب في تقفيل اليوم على «تاريخ الفاتورة الأصلية» لأن مفيش
-- تاريخ خاص بالاسترجاع. ده كان بيخلّي استرجاع فاتورة قديمة يظهر في تقفيل يومها
-- القديم بدل اليوم اللي اتعمل فيه الاسترجاع فعليًا. العمود ده بيسجّل وقت آخر
-- استرجاع فيُحسب المرتجع على يومه الصحيح.

alter table orders add column if not exists refunded_at timestamptz;



-- ==========================================================================
-- SOURCE: db/37_cashier_full_access.sql
-- ==========================================================================

-- ADRIA — صلاحية كاملة للكاشير: تجاوز الـ OTP في العمليات الحسّاسة
-- (صرف/تحويل من الخزنة الرئيسية، حذف فاتورة، فتح أسعار الجملة).
-- الكاشير اللي عليه full_access = true يقدر ينفّذ العمليات دي مباشرة بدون رمز تأكيد.
-- شغّله مرة واحدة.
alter table cashiers add column if not exists full_access boolean default false;



-- ==========================================================================
-- SOURCE: db/38_purchase_invoices_notes.sql
-- ==========================================================================

-- ADRIA — db/38: عمود notes على فواتير المشتريات (purchase_invoices)
-- آمن للتشغيل أكثر من مرة.
--
-- السبب: حركات «الخزنة الرئيسية» (فاتورة مشتريات/سداد/تحصيل مدفوعة من الخزنة
-- الرئيسية) بتتعلّم بعلامة داخل notes عشان تتستبعد من تقفيل الكاشير (خزنة المحل).
-- العمود ده كان ناقصاً فكان السداد/التحصيل «من الرئيسية» بيفشل حفظه.

alter table purchase_invoices add column if not exists notes text;



-- ==========================================================================
-- SOURCE: db/39_savings_group_id.sql
-- ==========================================================================

-- ADRIA — ربط صفوف معاملة الخزنة الرئيسية الواحدة بمعرّف مجموعة (group_id)
-- عشان الحذف يشيل كل صفوف العملية (لكل طريقة دفع) دفعة واحدة بدقّة،
-- ويلاقي صف المصروف المرتبط بيها. شغّله مرة واحدة في Supabase → SQL Editor.
alter table savings_transactions add column if not exists group_id uuid;
create index if not exists idx_savings_tx_group on savings_transactions(group_id);



-- ==========================================================================
-- SOURCE: db/40_attendance_self_service.sql
-- ==========================================================================

-- =============================================================================
-- ATTENDANCE SELF-SERVICE (تسجيل حضور/انصراف ذاتي للموظفين)  — بعد db/33 + secure_rls_migration
-- =============================================================================
--  يبني فوق جدول employee_attendance الموجود (db/33):
--   * صفحة عامة منفصلة /attendance يستخدمها كل الموظفين بدون دخول للنظام.
--   * كل موظف يختار اسمه + رقمه السري (attendance_pin) ويسجّل حضور/انصراف مع صورة.
--   * الحضور يحسب التأخير والخصم تلقائياً (نفس منطق التسجيل اليدوي في لوحة التحكم).
--   * كل الكتابة عبر دوال SECURITY DEFINER فقط (anon ماينفعش يكتب مباشرة).
--
--  آمن للتشغيل أكثر من مرة (idempotent).
-- =============================================================================

-- 1) رقم سري لكل موظف + عمود الانصراف على سجل الحضور
alter table employees          add column if not exists attendance_pin text;
alter table employee_attendance add column if not exists check_out timestamptz;

-- ---------------------------------------------------------------------------
-- 2) قائمة الموظفين النشطين لصفحة الحضور (بدون كشف الرقم السري)
-- ---------------------------------------------------------------------------
create or replace function public.get_attendance_employees()
returns jsonb
language sql
security definer
set search_path = public
as $$
  select coalesce(
    jsonb_agg(
      jsonb_build_object('id', e.id, 'name', e.name, 'job_title', e.job_title)
      order by e.name
    ),
    '[]'::jsonb)
  from employees e
  where coalesce(e.is_active, true) = true;
$$;

revoke all on function public.get_attendance_employees() from public;
grant execute on function public.get_attendance_employees() to anon, authenticated;

-- ---------------------------------------------------------------------------
-- 3) حالة اليوم لموظف معيّن (لتفعيل/تعطيل زر الانصراف)
-- ---------------------------------------------------------------------------
create or replace function public.get_attendance_status(p_employee_id uuid)
returns jsonb
language sql
security definer
set search_path = public
as $$
  select coalesce(
    (select jsonb_build_object('check_in', a.check_in, 'check_out', a.check_out)
       from employee_attendance a
      where a.employee_id = p_employee_id
        and a.date = (now() at time zone 'Africa/Cairo')::date),
    jsonb_build_object('check_in', null, 'check_out', null)
  );
$$;

revoke all on function public.get_attendance_status(uuid) from public;
grant execute on function public.get_attendance_status(uuid) to anon, authenticated;

-- ---------------------------------------------------------------------------
-- 4) تسجيل حضور/انصراف — يتحقق من الرقم السري ويحسب التأخير ويكتب الصف
--    p_action: 'check_in' | 'check_out'
--    (منطق التأخير مطابق لدالة computeLateness في الواجهة)
-- ---------------------------------------------------------------------------
create or replace function public.record_attendance(
  p_employee_id uuid,
  p_pin text,
  p_action text
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_emp    employees%rowtype;
  v_today  date := (now() at time zone 'Africa/Cairo')::date;
  v_now    timestamptz := now();
  v_local  timestamp := (now() at time zone 'Africa/Cairo'); -- توقيت القاهرة (ساعة الحائط)
  v_row    employee_attendance%rowtype;
  v_expected     timestamp;
  v_raw_late     numeric;
  v_grace        numeric;
  v_late         numeric := 0;
  v_workday      numeric := 480;
  v_daily        numeric;
  v_ded          numeric := 0;
begin
  select * into v_emp from employees where id = p_employee_id;
  if not found then
    return jsonb_build_object('ok', false, 'error', 'not_found');
  end if;
  if coalesce(v_emp.is_active, true) = false then
    return jsonb_build_object('ok', false, 'error', 'inactive');
  end if;
  if coalesce(v_emp.attendance_pin, '') = '' then
    return jsonb_build_object('ok', false, 'error', 'no_pin');
  end if;
  if v_emp.attendance_pin <> p_pin then
    return jsonb_build_object('ok', false, 'error', 'wrong_pin');
  end if;

  select * into v_row from employee_attendance
   where employee_id = p_employee_id and date = v_today;

  if p_action = 'check_in' then
    if found then
      return jsonb_build_object('ok', false, 'error', 'already_checked_in',
        'name', v_emp.name, 'time', v_row.check_in);
    end if;

    -- حساب التأخير والخصم (لو محدد بداية دوام)
    if v_emp.shift_start is not null then
      v_expected := v_today + v_emp.shift_start;
      v_grace    := coalesce(v_emp.late_grace_minutes, 0);
      v_raw_late := round(extract(epoch from (v_local - v_expected)) / 60.0);
      v_late     := greatest(0, v_raw_late - v_grace);
      if v_late > 0 then
        if v_emp.shift_end is not null then
          v_workday := extract(epoch from (v_emp.shift_end - v_emp.shift_start)) / 60.0;
          if v_workday <= 0 then v_workday := v_workday + 1440; end if;
          if v_workday = 0 then v_workday := 480; end if;
        end if;
        v_daily := coalesce(v_emp.monthly_salary, 0) / 30.0;
        v_ded   := round(least(v_daily, (v_late / v_workday) * v_daily)::numeric, 2);
      end if;
    end if;

    insert into employee_attendance
      (employee_id, date, check_in, shift_start, late_minutes, deduction_amount, month, note)
    values
      (p_employee_id, v_today, v_now, v_emp.shift_start, v_late, v_ded,
       to_char(v_today, 'YYYY-MM'), 'تسجيل ذاتي');

    return jsonb_build_object('ok', true, 'action', 'check_in',
      'name', v_emp.name, 'time', v_now, 'late_minutes', v_late, 'deduction', v_ded);

  elsif p_action = 'check_out' then
    if not found then
      return jsonb_build_object('ok', false, 'error', 'not_checked_in', 'name', v_emp.name);
    end if;
    if v_row.check_out is not null then
      return jsonb_build_object('ok', false, 'error', 'already_checked_out',
        'name', v_emp.name, 'time', v_row.check_out);
    end if;
    update employee_attendance set check_out = v_now where id = v_row.id;
    return jsonb_build_object('ok', true, 'action', 'check_out',
      'name', v_emp.name, 'time', v_now);

  else
    return jsonb_build_object('ok', false, 'error', 'bad_action');
  end if;
end;
$$;

revoke all on function public.record_attendance(uuid, text, text) from public;
grant execute on function public.record_attendance(uuid, text, text) to anon, authenticated;



-- ==========================================================================
-- SOURCE: db/41_partner_group_id.sql
-- ==========================================================================

-- ADRIA — ربط معاملة الشريك بصف دفتر الخزنة الرئيسية (group_id) عشان الحذف/التعديل
-- يرجّع الفلوس للخزنة الرئيسية بدقّة. شغّله مرة واحدة في Supabase → SQL Editor.
-- آمن للتشغيل أكثر من مرة.
alter table partner_transactions add column if not exists group_id uuid;
create index if not exists idx_partner_tx_group on partner_transactions(group_id);



-- ==========================================================================
-- SOURCE: db/42_employee_deductions.sql
-- ==========================================================================

-- =============================================================================
-- EMPLOYEE DEDUCTIONS (خصومات يدوية على الموظف تتجمّع لحد صرف الراتب)
-- =============================================================================
--  ليه جدول منفصل ومش نوع جديد في employee_transactions؟
--  كل صف في employee_transactions بيتطرح من خزنة المحل (computeShopAvailable
--  في utils/treasury، وتقفيل اليوم، والتقارير، وحساب الرصيد الافتتاحي) لأنه
--  بيمثّل فلوس خارجة فعلاً. الخصم مش فلوس خارجة من الدرج — ده تقليل للي إحنا
--  مدينينه للموظف. لو اتحط هناك كان هيقلّل رصيد الخزنة غلط في 6 أماكن.
--
--  الجدول ده بيمشي على نفس نمط employee_leaves: خصم مربوط بشهر، بيتجمّع، وبيتخصم
--  من المتبقي وقت صرف الراتب.
--
--  آمن للتشغيل أكثر من مرة (idempotent).
-- =============================================================================

create table if not exists employee_deductions (
  id uuid primary key default gen_random_uuid(),
  employee_id uuid not null references employees(id) on delete cascade,
  -- المبلغ النهائي بالجنيه — لو الخصم اتسجّل بالأيام بيتحسب هنا وقت الحفظ
  -- (أيام × الراتب/30) عشان باقي الحسابات تقرا رقم واحد بس.
  amount numeric not null default 0,
  -- عدد الأيام لو الخصم اتسجّل بالأيام (بيقبل كسور: 0.5 = نص يوم).
  -- بيتخزّن للعرض في السجل بس — القيمة الفعلية دايماً في amount.
  days numeric not null default 0,
  -- سبب الخصم (اختياري) — بيتعرض في سجل حركات الموظف
  reason text,
  -- الشهر اللي الخصم بيتخصم منه: YYYY-MM
  month text not null,
  -- تاريخ الخصم (اليوم اللي حصل فيه)
  date date not null default (now() at time zone 'Africa/Cairo')::date,
  created_at timestamptz default now()
);

-- لو الجدول كان اتعمل قبل ما عمود days يتضاف، create table if not exists فوق
-- بيعدّي من غير ما يضيفه — فبنضيفه هنا صراحةً.
alter table employee_deductions add column if not exists days numeric not null default 0;

-- شاشة الموظف بتجيب خصومات موظف واحد لشهر واحد.
create index if not exists employee_deductions_emp_month_idx
  on employee_deductions (employee_id, month);

-- نفس سياسة باقي جداول الموظفين (secure_rls_migration): المصرّح لهم بس.
alter table employee_deductions enable row level security;
drop policy if exists "allow all" on employee_deductions;
drop policy if exists "authenticated full access" on employee_deductions;
create policy "authenticated full access" on employee_deductions
  for all to authenticated using (true) with check (true);
revoke all on employee_deductions from anon;
grant all on employee_deductions to authenticated;



-- ==========================================================================
-- SOURCE: db/43_custom_categories_and_pages_qr.sql
-- ==========================================================================

-- =============================================================================
-- ADRIA — db/43: فئات مصروف/إيراد مخصّصة + QR ثابت لصفحات المحل على الفواتير
-- =============================================================================
--  1) فئات المصروف والإيراد كانت options ثابتة في الكود (Finance.tsx و POS.tsx)،
--     فأي فئة جديدة كانت محتاجة تعديل كود ونشر. الأعمدة دي بتخزّن الفئات اللي
--     المستخدم بيضيفها بنفسه، والقوائم الثابتة فضلت في الكود كأساس دايماً موجود.
--     مشتركة بين الخزنة الرئيسية وخزنة الكاشير عشان الفئة تتكتب مرة وتظهر في
--     الاتنين.
--
--  2) pages_qr_url: رابط صفحات المحل اللي بيتحوّل QR ثابت على كل فاتورة مطبوعة.
--     ده غير الـQR الموجود أصلاً اللي بيشاور على الفاتورة نفسها (/view-invoice).
--
--  آمن للتشغيل أكثر من مرة (idempotent).
-- =============================================================================

-- مصفوفات نصية: ["صيانة تكييف", "دعاية"] — الترتيب هو ترتيب الإضافة.
alter table store_settings add column if not exists expense_categories jsonb;
alter table store_settings add column if not exists income_categories  jsonb;

-- رابط صفحات المحل (فيسبوك/انستجرام/لينك تري) + العنوان اللي بيظهر تحت الـQR.
alter table store_settings add column if not exists pages_qr_url   text;
alter table store_settings add column if not exists pages_qr_label text;



-- ==========================================================================
-- SOURCE: db/44_pages_qr_image.sql
-- ==========================================================================

-- =============================================================================
-- ADRIA — db/44: صورة QR مخصّصة لصفحات المحل
-- =============================================================================
--  db/43 خزّن رابط الصفحات وبنولّد منه QR وقت الطباعة. ده بيشتغل، لكنه بيطبع
--  كود عادي — والمحل ممكن يكون عامل QR مصمّم (تابلينك/لينك تري) وعايز يطبعه هو
--  بالظبط بشكله وبراندنج.
--
--  العمود ده بيخزّن الصورة نفسها كـ data URL (نفس نمط store_settings.logo).
--  الأولوية وقت الطباعة: الصورة المرفوعة → لو مفيش، QR مولّد من pages_qr_url.
--
--  الصورة بتتصغّر على canvas قبل الحفظ (شوف Settings.tsx) عشان متكبّرش صف
--  الإعدادات اللي بيتحمّل مع كل فتح للتطبيق.
--
--  آمن للتشغيل أكثر من مرة (idempotent).
-- =============================================================================

alter table store_settings add column if not exists pages_qr_image text;



-- ==========================================================================
-- SOURCE: db/45_employee_bonuses.sql
-- ==========================================================================

-- =============================================================================
-- EMPLOYEE BONUSES (مكافآت تتجمّع على الموظف لحد صرف الراتب)
-- =============================================================================
--  ده مرآة employee_deductions (db/42) بالظبط بس بإشارة موجبة: بيتجمّع خلال
--  الشهر وبيتضاف على المتبقي وقت صرف الراتب.
--
--  ليه جدول منفصل ومش نوع 'incentive' في employee_transactions؟
--  «الحافز» الموجود في employee_transactions بيطلّع فلوس من الدرج ساعتها —
--  بيتحسب في تقفيل اليوم والميزانية و recordMainTreasuryOut. المكافأة هنا مش
--  فلوس خارجة وقت تسجيلها؛ دي زيادة في اللي إحنا مدينينه للموظف، والفلوس
--  بتخرج مرة واحدة وقت صرف الراتب. لو اتحطت هناك كانت هتقلّل رصيد الخزنة
--  مرتين: مرة وقت التسجيل ومرة تانية جوه الراتب.
--
--  مفيش عمود days هنا (عكس الخصم) — مكافأة بالأيام مالهاش معنى واضح.
--
--  آمن للتشغيل أكثر من مرة (idempotent).
-- =============================================================================

create table if not exists employee_bonuses (
  id uuid primary key default gen_random_uuid(),
  employee_id uuid not null references employees(id) on delete cascade,
  -- قيمة المكافأة بالجنيه (موجبة دايماً)
  amount numeric not null default 0,
  -- سبب المكافأة (اختياري) — بيتعرض في سجل حركات الموظف
  reason text,
  -- الشهر اللي المكافأة بتتضاف عليه: YYYY-MM
  month text not null,
  -- تاريخ المكافأة (اليوم اللي استحقّت فيه)
  date date not null default (now() at time zone 'Africa/Cairo')::date,
  created_at timestamptz default now()
);

-- شاشة الموظف بتجيب مكافآت موظف واحد لشهر واحد.
create index if not exists employee_bonuses_emp_month_idx
  on employee_bonuses (employee_id, month);

-- نفس سياسة باقي جداول الموظفين (secure_rls_migration): المصرّح لهم بس.
alter table employee_bonuses enable row level security;
drop policy if exists "allow all" on employee_bonuses;
drop policy if exists "authenticated full access" on employee_bonuses;
create policy "authenticated full access" on employee_bonuses
  for all to authenticated using (true) with check (true);
revoke all on employee_bonuses from anon;
grant all on employee_bonuses to authenticated;



-- ==========================================================================
-- SOURCE: db/46_purchase_returns.sql
-- ==========================================================================

-- ADRIA — مرتجع المورد. شغّله مرة واحدة (آمن للتشغيل أكثر من مرة).
--
-- المرتجع بيتسجّل كصف عادي في purchase_invoices بإجمالي سالب وأصناف بكميات سالبة،
-- بدل جدول جديد. السبب: رصيد المورد محسوب في كل الصفحات كـ sum(total - paid_amount)
-- والخزنة بتقرا paid_* بنفس الطريقة — فبالإشارة السالبة الرصيد والخزنة والتقارير
-- (Analytics / Budget / Finance / DeferredAccounts) بتظبط لوحدها من غير أي تعديل.
-- نفس أسلوب collectSupplierCredit الموجود أصلاً.
--
-- العمود ده بيربط المرتجع بفاتورة الشراء الأصلية، عشان:
--   1. نمنع إرجاع كمية أكبر من المشتراة (المتاح = المشترى - المرتجع سابقاً).
--   2. نرجّع بسعر الشراء المسجّل في الفاتورة نفسها، مش بمتوسط التكلفة الحالي
--      (average_purchase_price) — وإلا المخزون بيتقيّم غلط.
alter table purchase_invoices
  add column if not exists source_invoice_id uuid references purchase_invoices(id) on delete set null;

create index if not exists purchase_invoices_source_invoice_id_idx
  on purchase_invoices (source_invoice_id);



-- ==========================================================================
-- SOURCE: db/48_diagnose_shop_drawer.sql
-- ==========================================================================

-- ADRIA — تفكيك رصيد خزنة المحل. **للقراءة فقط، مش بيعدّل أي حاجة.**
--
-- ليه؟ صفحة الخزنة الرئيسية بتعرض «بالمحل: -3280» مثلاً. الرصيد السالب معناه
-- إن النظام شايف إن اتصرف/اتحوّل من الدرج أكتر من اللي دخله. الاستعلام ده
-- بيفكك الرقم لمكوناته عشان نعرف البند اللي بيسحبه تحت الصفر.
--
-- بيطابق دالة computeShopAvailable في src/utils/treasury.ts:
--   + الفواتير (بيع/سداد)      − المرتجعات
--   − المصاريف                  ± التحويلات الداخلية بين الوسائل
--   − المشتريات (+ لو سالبة)    − المرتبات
--   + الرصيد الافتتاحي (من الإعدادات — مش في الاستعلام ده)
-- والمعلّم بـ [MAIN_TREASURY] مستبعد لأنه بيخص الخزنة الرئيسية مش الدرج.
--
-- قاعدة التقسيم: لو أي عمود paid_* مش صفر، بناخد الأعمدة دي. لو كلهم أصفار،
-- بنحمّل المبلغ كله على payment_method.

with
-- (أ) الفواتير: بيع + سداد آجل = داخل للدرج
orders_in as (
  select m.key, sum(m.val) as amount
  from orders o
  cross join lateral (values
    ('cash',     case when (coalesce(o.paid_cash,0)+coalesce(o.paid_visa,0)+coalesce(o.paid_wallet,0)+coalesce(o.paid_instapay,0)+coalesce(o.paid_method5,0)+coalesce(o.paid_method6,0)) <> 0
                      then coalesce(o.paid_cash,0)
                      else case when o.payment_method='cash' then abs(coalesce(o.paid_amount,0)) else 0 end end),
    ('visa',     case when (coalesce(o.paid_cash,0)+coalesce(o.paid_visa,0)+coalesce(o.paid_wallet,0)+coalesce(o.paid_instapay,0)+coalesce(o.paid_method5,0)+coalesce(o.paid_method6,0)) <> 0
                      then coalesce(o.paid_visa,0)
                      else case when o.payment_method='visa' then abs(coalesce(o.paid_amount,0)) else 0 end end),
    ('wallet',   case when (coalesce(o.paid_cash,0)+coalesce(o.paid_visa,0)+coalesce(o.paid_wallet,0)+coalesce(o.paid_instapay,0)+coalesce(o.paid_method5,0)+coalesce(o.paid_method6,0)) <> 0
                      then coalesce(o.paid_wallet,0)
                      else case when o.payment_method='wallet' then abs(coalesce(o.paid_amount,0)) else 0 end end),
    ('instapay', case when (coalesce(o.paid_cash,0)+coalesce(o.paid_visa,0)+coalesce(o.paid_wallet,0)+coalesce(o.paid_instapay,0)+coalesce(o.paid_method5,0)+coalesce(o.paid_method6,0)) <> 0
                      then coalesce(o.paid_instapay,0)
                      else case when o.payment_method='instapay' then abs(coalesce(o.paid_amount,0)) else 0 end end),
    ('method5',  case when (coalesce(o.paid_cash,0)+coalesce(o.paid_visa,0)+coalesce(o.paid_wallet,0)+coalesce(o.paid_instapay,0)+coalesce(o.paid_method5,0)+coalesce(o.paid_method6,0)) <> 0
                      then coalesce(o.paid_method5,0)
                      else case when o.payment_method='method5' then abs(coalesce(o.paid_amount,0)) else 0 end end),
    ('method6',  case when (coalesce(o.paid_cash,0)+coalesce(o.paid_visa,0)+coalesce(o.paid_wallet,0)+coalesce(o.paid_instapay,0)+coalesce(o.paid_method5,0)+coalesce(o.paid_method6,0)) <> 0
                      then coalesce(o.paid_method6,0)
                      else case when o.payment_method='method6' then abs(coalesce(o.paid_amount,0)) else 0 end end)
  ) as m(key, val)
  where coalesce(o.is_deleted,false) = false
    and o.type in ('sale','payment')
  group by m.key
),
-- (ب) المرتجعات: بتخرج من الدرج على وسيلة الاسترداد
refunds_out as (
  select coalesce(o.refund_method, o.payment_method, 'cash') as key,
         sum(coalesce(oi.refunded_amount,0)) as amount
  from orders o
  join order_items oi on oi.order_id = o.id
  where coalesce(o.is_deleted,false) = false
  group by 1
),
-- (ج) المصاريف والتحويلات — المعلّم [MAIN_TREASURY] مستبعد
exp_rows as (
  select e.*,
    (coalesce(e.paid_cash,0)+coalesce(e.paid_visa,0)+coalesce(e.paid_wallet,0)+coalesce(e.paid_instapay,0)+coalesce(e.paid_method5,0)+coalesce(e.paid_method6,0)) as split_sum
  from expenses e
  where coalesce(e.note,'') not like '%[MAIN_TREASURY]%'
),
exp_out as (
  select
    case when r.category = 'تحويل داخلي' then 'internal_transfer'
         when r.category = 'تحويل للخزنة الرئيسية' then 'transfer_to_main'
         when r.category = 'تحويل من الخزنة الرئيسية' then 'transfer_from_main'
         else 'expense' end as component,
    m.key,
    sum(m.val) as amount
  from exp_rows r
  cross join lateral (values
    ('cash',     case when r.split_sum <> 0 then coalesce(r.paid_cash,0)     else case when r.payment_method='cash'     then abs(coalesce(r.amount,0)) else 0 end end),
    ('visa',     case when r.split_sum <> 0 then coalesce(r.paid_visa,0)     else case when r.payment_method='visa'     then abs(coalesce(r.amount,0)) else 0 end end),
    ('wallet',   case when r.split_sum <> 0 then coalesce(r.paid_wallet,0)   else case when r.payment_method='wallet'   then abs(coalesce(r.amount,0)) else 0 end end),
    ('instapay', case when r.split_sum <> 0 then coalesce(r.paid_instapay,0) else case when r.payment_method='instapay' then abs(coalesce(r.amount,0)) else 0 end end),
    ('method5',  case when r.split_sum <> 0 then coalesce(r.paid_method5,0)  else case when r.payment_method='method5'  then abs(coalesce(r.amount,0)) else 0 end end),
    ('method6',  case when r.split_sum <> 0 then coalesce(r.paid_method6,0)  else case when r.payment_method='method6'  then abs(coalesce(r.amount,0)) else 0 end end)
  ) as m(key, val)
  group by 1, 2
),
-- (د) المشتريات — المعلّم [MAIN_TREASURY] مستبعد
pur_rows as (
  select p.*,
    (coalesce(p.paid_cash,0)+coalesce(p.paid_visa,0)+coalesce(p.paid_wallet,0)+coalesce(p.paid_instapay,0)+coalesce(p.paid_method5,0)+coalesce(p.paid_method6,0)) as split_sum
  from purchase_invoices p
  where coalesce(p.notes,'') not like '%[MAIN_TREASURY]%'
),
pur_out as (
  select m.key, sum(m.val) as amount
  from pur_rows r
  cross join lateral (values
    ('cash',     case when r.split_sum <> 0 then coalesce(r.paid_cash,0)     else case when r.payment_method='cash'     then abs(coalesce(r.paid_amount,0)) else 0 end end),
    ('visa',     case when r.split_sum <> 0 then coalesce(r.paid_visa,0)     else case when r.payment_method='visa'     then abs(coalesce(r.paid_amount,0)) else 0 end end),
    ('wallet',   case when r.split_sum <> 0 then coalesce(r.paid_wallet,0)   else case when r.payment_method='wallet'   then abs(coalesce(r.paid_amount,0)) else 0 end end),
    ('instapay', case when r.split_sum <> 0 then coalesce(r.paid_instapay,0) else case when r.payment_method='instapay' then abs(coalesce(r.paid_amount,0)) else 0 end end),
    ('method5',  case when r.split_sum <> 0 then coalesce(r.paid_method5,0)  else case when r.payment_method='method5'  then abs(coalesce(r.paid_amount,0)) else 0 end end),
    ('method6',  case when r.split_sum <> 0 then coalesce(r.paid_method6,0)  else case when r.payment_method='method6'  then abs(coalesce(r.paid_amount,0)) else 0 end end)
  ) as m(key, val)
  group by m.key
)
select component, key, round(sum(amount)::numeric, 2) as amount from (
  select 'IN  فواتير (بيع/سداد)'      as component, key,  amount from orders_in
  union all
  select 'OUT مرتجعات',                     key, -amount from refunds_out
  union all
  select 'OUT مصاريف',                      key, -amount from exp_out where component='expense'
  union all
  select 'OUT تحويل للخزنة الرئيسية',        key, -amount from exp_out where component='transfer_to_main'
  union all
  select 'IN  تحويل من الخزنة الرئيسية',     key, -amount from exp_out where component='transfer_from_main'
  union all
  select '±   تحويل داخلي بين الوسائل',      key,  amount from exp_out where component='internal_transfer'
  union all
  select 'OUT مشتريات',                     key, -amount from pur_out
) x
group by component, key
having round(sum(amount)::numeric, 2) <> 0
order by key, component;

-- ملاحظات على القراءة:
-- • المرتبات (employee_transactions) مش مضمّنة هنا — لو الفرق لسه مش مفسَّر
--   بعد التفكيك ده، فالبند الناقص غالباً منها.
-- • الرصيد الافتتاحي مخزّن في store_settings.payment_opening_balances
--   (مش جدول)، فمش داخل في الجمع ده — راجعه من صفحة كشف وسائل الدفع.
-- • «تحويل للخزنة الرئيسية» المفروض يساوي اللي دخل الرئيسية فعلاً. لو مجموعه
--   أكبر من (الفواتير − المصاريف − المشتريات) فده معناه إن اتحوّل للرئيسية
--   أكتر من اللي كان في الدرج → الرصيد بيطلع سالب.



-- ==========================================================================
-- SOURCE: db/49_expense_employee_link.sql
-- ==========================================================================

-- ADRIA — ربط صف المصروف بمعاملة الموظف. شغّله مرة واحدة (آمن للتشغيل أكثر من مرة).
--
-- الخلفية: كل راتب/سلفة بيتكتب في مكانين — صف في employee_transactions + صف
-- مصروف بفئة «رواتب». الصفين مالهمش أي رابط، فالكود كان بيدوّر على الصف
-- المقابل **بالمطابقة**: نفس التاريخ + نفس المبلغ + نفس تقسيمة الدفع.
--
-- المطابقة دي هشّة: لو اتصرف راتبين لموظفين مختلفين في نفس اليوم بنفس المبلغ
-- ونفس طريقة الدفع (وده وارد جداً)، المطابقة بترجّع الصف الغلط. النتيجة:
--   • تعديل راتب ممكن يعدّل مصروف راتب موظف تاني.
--   • حذف راتب ممكن يمسح مصروف موظف تاني ويسيب مصروف الأصلي معلّق.
--   • تقارير الميزانية بتسقط واحد من الاتنين فيقل إجمالي المصروفات.
--
-- العمود ده بيربطهم صراحةً فتبقى العملية مضمونة.
-- on delete set null: لو اتمسحت معاملة الموظف من القاعدة مباشرةً، صف المصروف
-- يفضل موجود (الفلوس خرجت فعلاً) بس من غير ربط.
alter table expenses
  add column if not exists employee_transaction_id uuid
  references employee_transactions(id) on delete set null;

create index if not exists expenses_employee_transaction_id_idx
  on expenses (employee_transaction_id);

-- ملاحظة: الصفوف القديمة هتفضل employee_transaction_id = null، والكود بيقع
-- على المطابقة القديمة معاها للتوافق. الصفوف الجديدة بس هي اللي هتبقى مربوطة.



-- ==========================================================================
-- SOURCE: db/50_reconcile_payment_accounts.sql
-- ==========================================================================

-- ADRIA — مصالحة كشف حسابات وسائل الدفع. **للقراءة فقط.**
-- بيحسب الرصيد الصح لكل وسيلة من الداتا الخام عشان تقارنه باللي ظاهر في الصفحة.
--
-- طريقة الاستخدام: شغّل كل قسم، وقارن العمود `expected_balance` بالرقم المعروض
-- في /admin/payment-accounts للنطاق المقابل. لو اتساوا → الداتا مظبوطة.


-- ═══ (1) خزنة المحل — الرصيد المتوقع لكل وسيلة ═══
-- بيطابق computeShopAvailable بعد إصلاح عدّ الرواتب المزدوج.
-- ملاحظة: الرصيد الافتتاحي مخزّن في store_settings مش في جدول، فمش مضاف هنا.
-- شوف قسم (4) لقيمته وضيفه بنفسك لو مش صفر.
with mk as (
  select * from (values ('cash'),('visa'),('wallet'),('instapay'),('method5'),('method6')) as t(key)
),
-- الفواتير: بيع + سداد آجل
o_in as (
  select m.key, sum(m.val) as v from orders o
  cross join lateral (values
    ('cash',     case when (coalesce(o.paid_cash,0)+coalesce(o.paid_visa,0)+coalesce(o.paid_wallet,0)+coalesce(o.paid_instapay,0)+coalesce(o.paid_method5,0)+coalesce(o.paid_method6,0))<>0 then coalesce(o.paid_cash,0)     else case when o.payment_method='cash'     then abs(coalesce(o.paid_amount,0)) else 0 end end),
    ('visa',     case when (coalesce(o.paid_cash,0)+coalesce(o.paid_visa,0)+coalesce(o.paid_wallet,0)+coalesce(o.paid_instapay,0)+coalesce(o.paid_method5,0)+coalesce(o.paid_method6,0))<>0 then coalesce(o.paid_visa,0)     else case when o.payment_method='visa'     then abs(coalesce(o.paid_amount,0)) else 0 end end),
    ('wallet',   case when (coalesce(o.paid_cash,0)+coalesce(o.paid_visa,0)+coalesce(o.paid_wallet,0)+coalesce(o.paid_instapay,0)+coalesce(o.paid_method5,0)+coalesce(o.paid_method6,0))<>0 then coalesce(o.paid_wallet,0)   else case when o.payment_method='wallet'   then abs(coalesce(o.paid_amount,0)) else 0 end end),
    ('instapay', case when (coalesce(o.paid_cash,0)+coalesce(o.paid_visa,0)+coalesce(o.paid_wallet,0)+coalesce(o.paid_instapay,0)+coalesce(o.paid_method5,0)+coalesce(o.paid_method6,0))<>0 then coalesce(o.paid_instapay,0) else case when o.payment_method='instapay' then abs(coalesce(o.paid_amount,0)) else 0 end end),
    ('method5',  case when (coalesce(o.paid_cash,0)+coalesce(o.paid_visa,0)+coalesce(o.paid_wallet,0)+coalesce(o.paid_instapay,0)+coalesce(o.paid_method5,0)+coalesce(o.paid_method6,0))<>0 then coalesce(o.paid_method5,0)  else case when o.payment_method='method5'  then abs(coalesce(o.paid_amount,0)) else 0 end end),
    ('method6',  case when (coalesce(o.paid_cash,0)+coalesce(o.paid_visa,0)+coalesce(o.paid_wallet,0)+coalesce(o.paid_instapay,0)+coalesce(o.paid_method5,0)+coalesce(o.paid_method6,0))<>0 then coalesce(o.paid_method6,0)  else case when o.payment_method='method6'  then abs(coalesce(o.paid_amount,0)) else 0 end end)
  ) as m(key,val)
  where coalesce(o.is_deleted,false)=false and o.type in ('sale','payment')
  group by m.key
),
o_ref as (
  select coalesce(o.refund_method,o.payment_method,'cash') as key, sum(coalesce(oi.refunded_amount,0)) as v
  from orders o join order_items oi on oi.order_id=o.id
  where coalesce(o.is_deleted,false)=false group by 1
),
-- المصاريف: مستبعد منها المعلّم بالرئيسية وفئة «رواتب» (بتتحسب من جدول الموظفين)
e_rows as (
  select e.*, (coalesce(e.paid_cash,0)+coalesce(e.paid_visa,0)+coalesce(e.paid_wallet,0)+coalesce(e.paid_instapay,0)+coalesce(e.paid_method5,0)+coalesce(e.paid_method6,0)) as ss
  from expenses e
  where coalesce(e.note,'') not like '%[MAIN_TREASURY]%' and e.category <> 'رواتب'
),
e_out as (
  select m.key, sum(case when r.category='تحويل داخلي' then m.val when coalesce(r.amount,0)<0 then abs(m.val) else -m.val end) as v
  from e_rows r
  cross join lateral (values
    ('cash',     case when r.ss<>0 then coalesce(r.paid_cash,0)     else case when r.payment_method='cash'     then abs(coalesce(r.amount,0)) else 0 end end),
    ('visa',     case when r.ss<>0 then coalesce(r.paid_visa,0)     else case when r.payment_method='visa'     then abs(coalesce(r.amount,0)) else 0 end end),
    ('wallet',   case when r.ss<>0 then coalesce(r.paid_wallet,0)   else case when r.payment_method='wallet'   then abs(coalesce(r.amount,0)) else 0 end end),
    ('instapay', case when r.ss<>0 then coalesce(r.paid_instapay,0) else case when r.payment_method='instapay' then abs(coalesce(r.amount,0)) else 0 end end),
    ('method5',  case when r.ss<>0 then coalesce(r.paid_method5,0)  else case when r.payment_method='method5'  then abs(coalesce(r.amount,0)) else 0 end end),
    ('method6',  case when r.ss<>0 then coalesce(r.paid_method6,0)  else case when r.payment_method='method6'  then abs(coalesce(r.amount,0)) else 0 end end)
  ) as m(key,val)
  group by m.key
),
p_rows as (
  select p.*, (coalesce(p.paid_cash,0)+coalesce(p.paid_visa,0)+coalesce(p.paid_wallet,0)+coalesce(p.paid_instapay,0)+coalesce(p.paid_method5,0)+coalesce(p.paid_method6,0)) as ss
  from purchase_invoices p where coalesce(p.notes,'') not like '%[MAIN_TREASURY]%'
),
p_out as (
  select m.key, sum(case when coalesce(r.paid_amount,0)<0 then abs(m.val) else -m.val end) as v
  from p_rows r
  cross join lateral (values
    ('cash',     case when r.ss<>0 then coalesce(r.paid_cash,0)     else case when r.payment_method='cash'     then abs(coalesce(r.paid_amount,0)) else 0 end end),
    ('visa',     case when r.ss<>0 then coalesce(r.paid_visa,0)     else case when r.payment_method='visa'     then abs(coalesce(r.paid_amount,0)) else 0 end end),
    ('wallet',   case when r.ss<>0 then coalesce(r.paid_wallet,0)   else case when r.payment_method='wallet'   then abs(coalesce(r.paid_amount,0)) else 0 end end),
    ('instapay', case when r.ss<>0 then coalesce(r.paid_instapay,0) else case when r.payment_method='instapay' then abs(coalesce(r.paid_amount,0)) else 0 end end),
    ('method5',  case when r.ss<>0 then coalesce(r.paid_method5,0)  else case when r.payment_method='method5'  then abs(coalesce(r.paid_amount,0)) else 0 end end),
    ('method6',  case when r.ss<>0 then coalesce(r.paid_method6,0)  else case when r.payment_method='method6'  then abs(coalesce(r.paid_amount,0)) else 0 end end)
  ) as m(key,val)
  group by m.key
),
-- الرواتب/السلف: المصروف من الرئيسية مستبعد
s_out as (
  select m.key, -sum(m.val) as v from employee_transactions s
  cross join lateral (values
    ('cash',coalesce(s.paid_cash,0)),('visa',coalesce(s.paid_visa,0)),('wallet',coalesce(s.paid_wallet,0)),
    ('instapay',coalesce(s.paid_instapay,0)),('method5',coalesce(s.paid_method5,0)),('method6',coalesce(s.paid_method6,0))
  ) as m(key,val)
  where coalesce(s.note,'') not like '%[MAIN_TREASURY]%'
  group by m.key
)
select
  mk.key                                                as method,
  round(coalesce(o_in.v,0)::numeric,2)                  as invoices_in,
  round(coalesce(o_ref.v,0)::numeric,2)                 as refunds_out,
  round(coalesce(e_out.v,0)::numeric,2)                 as expenses_net,
  round(coalesce(p_out.v,0)::numeric,2)                 as purchases_net,
  round(coalesce(s_out.v,0)::numeric,2)                 as salaries_out,
  round((coalesce(o_in.v,0)-coalesce(o_ref.v,0)+coalesce(e_out.v,0)+coalesce(p_out.v,0)+coalesce(s_out.v,0))::numeric,2) as expected_balance
from mk
left join o_in   on o_in.key   = mk.key
left join o_ref  on o_ref.key  = mk.key
left join e_out  on e_out.key  = mk.key
left join p_out  on p_out.key  = mk.key
left join s_out  on s_out.key  = mk.key
order by mk.key;


-- ═══ (2) الخزنة الرئيسية — الرصيد المتوقع لكل وسيلة ═══
-- قارنه بالنطاق «الخزنة الرئيسية» في نفس الصفحة (بعد إضافة الافتتاحي من قسم 4).
select
  method,
  round(sum(case when direction='in' then amount else -amount end)::numeric,2) as ledger_net
from savings_transactions
group by method
order by method;


-- ═══ (3) فحص سلامة: مصاريف «رواتب» من غير معاملة موظف ═══
-- المفروض تطلع فاضية. أي صف هنا = مصروف راتب مسجّل يدوياً من صفحة المالية،
-- وده بيتحسب في كشف وسائل الدفع لكنه مستبعد من حساب درج المحل → اختلاف
-- بين الصفحتين بمقدار المبلغ.
select e.id, e.created_at, e.amount, e.payment_method, e.note
from expenses e
where e.category = 'رواتب'
  and e.employee_transaction_id is null
  and coalesce(e.note,'') not like '%[MAIN_TREASURY]%'
  and not exists (
    select 1 from employee_transactions t
    where date(t.created_at) = date(e.created_at)
      and abs(t.amount) = abs(e.amount)
  )
order by e.created_at desc;


-- ═══ (4) الأرصدة الافتتاحية (تُضاف على نتائج 1 و 2) ═══
select payment_opening_balances as shop_opening,
       savings_opening_balances as main_opening,
       initial_balance          as legacy_cash_opening
from store_settings;



-- ==========================================================================
-- SOURCE: db/51_attendance_business_day.sql
-- ==========================================================================

-- =============================================================================
-- ADRIA — الحضور والانصراف على «اليوم المحاسبي» بدل منتصف الليل
-- شغّله مرة واحدة (آمن للتشغيل أكثر من مرة). بيحدّث دوال db/40.
-- =============================================================================
-- المشكلة: دوال الحضور كانت بتستخدم (now() at time zone 'Africa/Cairo')::date،
-- يعني اليوم بينط عند ١٢ بالليل بالظبط. الموظف اللي بيمشي ١ ص كان النظام
-- بيدوّر له على صف حضور بتاريخ اليوم الجديد، ومايلاقيش، فزرار الانصراف
-- بيتقفل ويقول «لم تسجّل حضور اليوم بعد» — والوردية بتفضل مفتوحة للأبد.
--
-- الحل: نفس أساس اليوم المحاسبي المستخدم في كل النظام (store_settings.day_start_hour،
-- افتراضي ٣ ص). الحيلة: نطرح ساعات بداية اليوم من التوقيت المحلي قبل ما ناخد
-- التاريخ — فالساعة ١ ص بتبقى ١٠ م من اليوم اللي فات، والساعة ٥ ص بتبقى
-- ٢ ص من نفس اليوم.
--
-- النتيجة: وردية بدأت ١٢ ظهر التلات وخلصت ١ ص الأربع = صف واحد على التلات.
-- وبعد ٣ ص اليوم بيتقفل فعلاً، واللي نسي ينصرف لازم الأدمن يعدّله يدوياً.
-- =============================================================================

-- 1) اليوم المحاسبي الحالي — مصدر واحد تستخدمه كل دوال الحضور.
create or replace function public.attendance_business_date()
returns date
language sql
stable
security definer
set search_path = public
as $$
  select (
    (now() at time zone 'Africa/Cairo')
    - make_interval(hours => coalesce(
        (select s.day_start_hour from store_settings s order by s.id limit 1), 3))
  )::date;
$$;

revoke all on function public.attendance_business_date() from public;
grant execute on function public.attendance_business_date() to anon, authenticated;


-- 2) حالة اليوم لموظف (بتتحكم في تفعيل زر الانصراف)
create or replace function public.get_attendance_status(p_employee_id uuid)
returns jsonb
language sql
security definer
set search_path = public
as $$
  select coalesce(
    (select jsonb_build_object('check_in', a.check_in, 'check_out', a.check_out)
       from employee_attendance a
      where a.employee_id = p_employee_id
        and a.date = public.attendance_business_date()),
    jsonb_build_object('check_in', null, 'check_out', null)
  );
$$;

revoke all on function public.get_attendance_status(uuid) from public;
grant execute on function public.get_attendance_status(uuid) to anon, authenticated;


-- 3) تسجيل حضور/انصراف — نفس منطق db/40 لكن باليوم المحاسبي
create or replace function public.record_attendance(
  p_employee_id uuid,
  p_pin text,
  p_action text
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_emp    employees%rowtype;
  v_today  date := public.attendance_business_date();  -- اليوم المحاسبي مش التقويمي
  v_now    timestamptz := now();
  v_local  timestamp := (now() at time zone 'Africa/Cairo'); -- توقيت القاهرة (ساعة الحائط)
  v_row    employee_attendance%rowtype;
  v_expected     timestamp;
  v_raw_late     numeric;
  v_grace        numeric;
  v_late         numeric := 0;
  v_workday      numeric := 480;
  v_daily        numeric;
  v_ded          numeric := 0;
begin
  select * into v_emp from employees where id = p_employee_id;
  if not found then
    return jsonb_build_object('ok', false, 'error', 'not_found');
  end if;
  if coalesce(v_emp.is_active, true) = false then
    return jsonb_build_object('ok', false, 'error', 'inactive');
  end if;
  if coalesce(v_emp.attendance_pin, '') = '' then
    return jsonb_build_object('ok', false, 'error', 'no_pin');
  end if;
  if v_emp.attendance_pin <> p_pin then
    return jsonb_build_object('ok', false, 'error', 'wrong_pin');
  end if;

  select * into v_row from employee_attendance
   where employee_id = p_employee_id and date = v_today;

  if p_action = 'check_in' then
    if found then
      return jsonb_build_object('ok', false, 'error', 'already_checked_in',
        'name', v_emp.name, 'time', v_row.check_in);
    end if;

    -- حساب التأخير والخصم (لو محدد بداية دوام)
    if v_emp.shift_start is not null then
      v_expected := v_today + v_emp.shift_start;
      v_grace    := coalesce(v_emp.late_grace_minutes, 0);
      v_raw_late := round(extract(epoch from (v_local - v_expected)) / 60.0);
      v_late     := greatest(0, v_raw_late - v_grace);
      if v_late > 0 then
        if v_emp.shift_end is not null then
          v_workday := extract(epoch from (v_emp.shift_end - v_emp.shift_start)) / 60.0;
          if v_workday <= 0 then v_workday := v_workday + 1440; end if;
          if v_workday = 0 then v_workday := 480; end if;
        end if;
        v_daily := coalesce(v_emp.monthly_salary, 0) / 30.0;
        v_ded   := round(least(v_daily, (v_late / v_workday) * v_daily)::numeric, 2);
      end if;
    end if;

    insert into employee_attendance
      (employee_id, date, check_in, shift_start, late_minutes, deduction_amount, month, note)
    values
      (p_employee_id, v_today, v_now, v_emp.shift_start, v_late, v_ded,
       to_char(v_today, 'YYYY-MM'), 'تسجيل ذاتي');

    return jsonb_build_object('ok', true, 'action', 'check_in',
      'name', v_emp.name, 'time', v_now, 'late_minutes', v_late, 'deduction', v_ded);

  elsif p_action = 'check_out' then
    if not found then
      return jsonb_build_object('ok', false, 'error', 'not_checked_in', 'name', v_emp.name);
    end if;
    if v_row.check_out is not null then
      return jsonb_build_object('ok', false, 'error', 'already_checked_out',
        'name', v_emp.name, 'time', v_row.check_out);
    end if;
    update employee_attendance set check_out = v_now where id = v_row.id;
    return jsonb_build_object('ok', true, 'action', 'check_out',
      'name', v_emp.name, 'time', v_now);

  else
    return jsonb_build_object('ok', false, 'error', 'bad_action');
  end if;
end;
$$;

revoke all on function public.record_attendance(uuid, text, text) from public;
grant execute on function public.record_attendance(uuid, text, text) to anon, authenticated;



-- ==========================================================================
-- SOURCE: db/52_held_invoice_kind_status.sql
-- ==========================================================================

-- =============================================================================
-- ADRIA — نوع وحالة الفاتورة المعلقة (حجز محل / أونلاين)
-- شغّله مرة واحدة (آمن للتشغيل أكثر من مرة).
-- =============================================================================
--  kind:
--    'shop'   = حجز محل — العميل هييجي ياخده. مالوش حالات: يتباع أو يترجّع.
--    'online' = طلب أونلاين — بيمرّ بدورة: معلق → تم الشحن → تم التسليم/ملغي.
--
--  status:
--    'held'      = معلق (الافتراضي لكل حجز جديد)
--    'shipped'   = اتشحن (أونلاين بس)
--    'delivered' = اتسلّم واتحصّل → اتحوّل لفاتورة بيع (order_id فيه رقمها)
--    'cancelled' = اتلغى → البضاعة رجعت للمخزون والعربون اترد
--
--  الصفوف المنتهية (delivered/cancelled) **بتفضل موجودة** كسجل تاريخي عشان
--  موديول الداشبورد يعرض الحالات. شاشة الكاشير بتفلتر على (held, shipped) بس،
--  فمش هتشوف المنتهية — ومفيش أثر على المخزون لأن الحركة بتتعمل وقت تغيير
--  الحالة مش وقت العرض.
-- =============================================================================

alter table public.held_invoices
  add column if not exists kind     text not null default 'shop',
  add column if not exists status   text not null default 'held',
  add column if not exists order_id text,
  add column if not exists status_at timestamptz,
  add column if not exists status_note text;

-- قيود القيم (نضيفها بأمان لو مش موجودة)
do $$
begin
  if not exists (select 1 from pg_constraint where conname = 'held_invoices_kind_chk') then
    alter table public.held_invoices
      add constraint held_invoices_kind_chk check (kind in ('shop', 'online'));
  end if;
  if not exists (select 1 from pg_constraint where conname = 'held_invoices_status_chk') then
    alter table public.held_invoices
      add constraint held_invoices_status_chk
      check (status in ('held', 'shipped', 'delivered', 'cancelled'));
  end if;
end $$;

create index if not exists idx_held_invoices_status on public.held_invoices(status);
create index if not exists idx_held_invoices_kind   on public.held_invoices(kind);

-- الصفوف القديمة: كلها حجز محل معلّق (وده الافتراضي أصلاً، السطر للتأكيد).
update public.held_invoices set kind = 'shop'  where kind   is null;
update public.held_invoices set status = 'held' where status is null;



-- ==========================================================================
-- SOURCE: db/53_held_invoice_address.sql
-- ==========================================================================

-- ADRIA — عنوان التوصيل للطلبات الأونلاين. شغّله مرة واحدة (آمن للتكرار).
--
-- الطلب الأونلاين بيتطبع وبيتسلّم لشركة الشحن، فمحتاج عنوان كامل + ملاحظات
-- للمندوب (علامة مميزة، دور، أقرب معلم...). حجز المحل مش محتاجه فبيفضل فاضي.
alter table public.held_invoices
  add column if not exists customer_address text,
  add column if not exists shipping_note    text;



-- ==========================================================================
-- SOURCE: db/54_held_order_lifecycle.sql
-- ==========================================================================

-- =============================================================================
-- ADRIA — دورة حياة الطلب الأونلاين الكاملة + المرتجع. شغّله مرة واحدة (آمن للتكرار).
-- =============================================================================
--  الحالات بعد التعديل:
--    'held'          = تم التجهيز — البضاعة متحجوزة من المخزون
--    'shipped'       = تم الشحن — راح لشركة الشحن
--    'money_pending' = الفلوس في الطريق — العميل استلم ودفع لشركة الشحن،
--                      بس الفلوس لسه ما وصلتش خزنة المحل (شركة الشحن مدينة لينا)
--    'delivered'     = تم التحصيل — الفلوس دخلت الخزنة واتسجّلت فاتورة بيع
--                      (order_id فيه رقمها)
--    'returned'      = مرتجع — العميل ما استلمش، البضاعة رجعت المخزون
--    'cancelled'     = ملغي — اتلغى قبل ما يوصل العميل
--
--  ليه money_pending حالة تتبّع بس ومش بتسجّل فاتورة؟ لأن الفلوس لسه مش في
--  الخزنة. الفاتورة والقيد المالي بيتعملوا وقت «تم التحصيل» بالظبط، فالخزنة
--  بتفضل مطابقة للفلوس الحقيقية. الإحصائيات في الموديول بتقرا من الجدول ده
--  مباشرةً (تقارير، مش قيود محاسبية).
--
--  المرتجع:
--    جزئي  → أصناف بترجع للمخزون والإجمالي بيقلّ، والطلب بيكمّل دورته عادي.
--    كلي   → كل الأصناف بترجع، الحالة 'returned'، والعربون بيترد للعميل.
--  في الحالتين ممكن يتسجّل «مصاريف شحن مرتجع» كمصروف من الخزنة بتاريخ لحظة
--  تسجيل المرتجع (وده بيتخزّن في shipping_return_cost للتقارير).
-- =============================================================================

alter table public.held_invoices
  add column if not exists return_data           jsonb,
  add column if not exists returned_at           timestamptz,
  add column if not exists shipping_return_cost  numeric default 0;

-- توسيع قيد الحالة ليشمل money_pending و returned.
do $$
begin
  if exists (select 1 from pg_constraint where conname = 'held_invoices_status_chk') then
    alter table public.held_invoices drop constraint held_invoices_status_chk;
  end if;
  alter table public.held_invoices
    add constraint held_invoices_status_chk
    check (status in ('held', 'shipped', 'money_pending', 'delivered', 'returned', 'cancelled'));
end $$;



-- ==========================================================================
-- SOURCE: db/55_fix_exchange_paid_amount.sql
-- ==========================================================================

-- =============================================================================
-- ADRIA — إصلاح «المدفوع» للفواتير اللي اتعملها استبدال قبل التصليح.
-- =============================================================================
-- المشكلة:
--   كود الاستبدال القديم كان بيكتب paid_amount = الإجمالي الجديد على طول، بدل
--   (المدفوع قبل الاستبدال + الفرق اللي اتحصّل). النتيجة: أي فاتورة **آجل**
--   اتعملها استبدال كانت بتبان «مسدّدة بالكامل» ومديونية العميل تختفي.
--   (الفواتير المدفوعة بالكامل مش متأثرة — الرقمين بيطلعوا واحد.)
--
--   الخزنة والمخزون **مش متأثرين**: فرق الاستبدال بيتسجّل صف مالي مستقل بتاريخه،
--   والمخزون بيتعدّل وقت الاستبدال (الراجع + والجديد -). المشكلة في عمود
--   paid_amount بس، اللي كل شاشات المديونية بتقرا منه.
--
-- الحساب الصح لكل فاتورة مستبدلة:
--   المدفوع = تقسيمة يوم البيع (paid_cash..paid_method6)
--           + مجموع فروق الاستبدال (موجب = اتحصّل، سالب = اترد)
--           + أي سداد آجل اتسجّل على الفاتورة (فواتير type='payment')
--   ومحصور بين صفر والإجمالي.
-- =============================================================================

-- ── (1) تشخيص: اعرض الفواتير اللي هتتغيّر قبل ما تعدّل حاجة ──────────────────
with x as (
  select
    o.id,
    o.total,
    o.paid_amount as paid_now,
    coalesce(o.paid_cash,0) + coalesce(o.paid_visa,0) + coalesce(o.paid_wallet,0)
      + coalesce(o.paid_instapay,0) + coalesce(o.paid_method5,0) + coalesce(o.paid_method6,0) as split_paid,
    coalesce((o.exchange_data->>'diff')::numeric, 0)
      + coalesce((select sum((h->>'diff')::numeric)
                  from jsonb_array_elements(coalesce(o.exchange_data->'history', '[]'::jsonb)) h), 0) as exchange_diff,
    coalesce((select sum(p.paid_amount) from orders p
              where p.type = 'payment'
                and coalesce(p.is_deleted, false) = false
                and p.notes like 'سداد أجل للفاتورة رقم #' || o.id || ' %'), 0) as debt_paid
  from orders o
  where o.exchange_data is not null
    and coalesce(o.is_deleted, false) = false
)
select
  id, total, paid_now,
  split_paid, exchange_diff, debt_paid,
  least(total, greatest(0, split_paid + exchange_diff + debt_paid)) as paid_fixed,
  least(total, greatest(0, split_paid + exchange_diff + debt_paid)) - paid_now as difference,
  greatest(0, total - least(total, greatest(0, split_paid + exchange_diff + debt_paid))) as debt_after_fix
from x
order by abs(least(total, greatest(0, split_paid + exchange_diff + debt_paid)) - paid_now) desc;

-- ── (2) الإصلاح: شغّله بعد ما تراجعي نتيجة التشخيص فوق ───────────────────────
-- (آمن للتكرار: تشغيله تاني مش هيغيّر حاجة لأن القيم بتبقى مظبوطة خلاص.)
--
-- update orders o
-- set paid_amount = least(o.total, greatest(0,
--       coalesce(o.paid_cash,0) + coalesce(o.paid_visa,0) + coalesce(o.paid_wallet,0)
--         + coalesce(o.paid_instapay,0) + coalesce(o.paid_method5,0) + coalesce(o.paid_method6,0)
--       + coalesce((o.exchange_data->>'diff')::numeric, 0)
--       + coalesce((select sum((h->>'diff')::numeric)
--                   from jsonb_array_elements(coalesce(o.exchange_data->'history','[]'::jsonb)) h), 0)
--       + coalesce((select sum(p.paid_amount) from orders p
--                   where p.type = 'payment'
--                     and coalesce(p.is_deleted, false) = false
--                     and p.notes like 'سداد أجل للفاتورة رقم #' || o.id || ' %'), 0)
--     ))
-- where o.exchange_data is not null
--   and coalesce(o.is_deleted, false) = false;



-- ==========================================================================
-- SOURCE: db/57_personal_savings_vaults.sql
-- ==========================================================================

-- =============================================================================
-- ADRIA — «الادخار الشخصي» للمدير: خزائن ادخار منفصلة تماماً عن حسابات المحل.
-- شغّليه مرة واحدة في Supabase SQL editor.
-- =============================================================================
-- الفكرة:
--   المدير بيعمل خزائن ادخار بأسماء (مثلاً «ادخار البيت»)، وكل خزنة رصيدها لكل
--   وسيلة دفع. الحركات ٤ أنواع (عمود source):
--     from_main    → إيداع في الخزنة جاي من الخزنة الرئيسية (بيقلّل الرئيسية)
--     to_main      → سحب من الخزنة رايح للخزنة الرئيسية   (بيزوّد الرئيسية)
--     personal_in  → إيداع من فلوس المدير الشخصية من بره   (ملوش علاقة بالرئيسية)
--     personal_out → سحب لجيب المدير الشخصي               (ملوش علاقة بالرئيسية)
--   حركات from_main / to_main بتتكتب كمان صف مقابل في savings_transactions
--   (دفتر الخزنة الرئيسية) مربوط بنفس group_id عشان الحذف يعكس الطرفين مع بعض.
-- =============================================================================

create table if not exists savings_vaults (
  id uuid default gen_random_uuid() primary key,
  name text not null,
  is_active boolean default true,
  created_at timestamptz default now()
);

create table if not exists savings_vault_transactions (
  id uuid default gen_random_uuid() primary key,
  vault_id uuid not null references savings_vaults(id) on delete cascade,
  direction text not null,                 -- 'in' | 'out'
  amount numeric not null,
  method text default 'cash',              -- cash / visa / wallet / instapay / method5 / method6
  source text not null,                    -- from_main | to_main | personal_in | personal_out
  note text,
  group_id uuid,                           -- يربط صف الرئيسية المقابل (لـ from_main/to_main)
  created_at timestamptz default now()
);

create index if not exists idx_svt_vault on savings_vault_transactions(vault_id);
create index if not exists idx_svt_group on savings_vault_transactions(group_id);

-- RLS: نفس سياسة باقي الجداول — وصول كامل للمستخدم المسجّل فقط.
alter table savings_vaults enable row level security;
alter table savings_vault_transactions enable row level security;

drop policy if exists "authenticated full access" on savings_vaults;
create policy "authenticated full access" on savings_vaults for all to authenticated using (true) with check (true);
drop policy if exists "authenticated full access" on savings_vault_transactions;
create policy "authenticated full access" on savings_vault_transactions for all to authenticated using (true) with check (true);

revoke all on savings_vaults from anon;
revoke all on savings_vault_transactions from anon;
grant all on savings_vaults to authenticated;
grant all on savings_vault_transactions to authenticated;



-- ==========================================================================
-- SOURCE: db/59_stock_intakes.sql
-- ==========================================================================

-- ADRIA — سجل «مخزون دخل بدون شراء». شغّله مرة واحدة (آمن للتشغيل أكثر من مرة).
--
-- المشكلة: أي كمية بتدخل المخزون من غير فاتورة شراء — إضافة منتج بكمية ابتدائية،
-- تعديل الكمية يدوياً، استيراد Excel، زيادة في الجرد — مالهاش أي أثر مالي في النظام:
-- مفيش فاتورة مورد، ولا مصروف، ولا حركة خزنة. ومع ذلك قيمتها بتظهر في «إجمالي قيمة
-- المخزون» وبتتخصم كتكلفة (COGS) وقت البيع من average_purchase_price — فالربح بيطلع
-- من غير رأس مال مقيّد في مقابله.
--
-- الحل: الجدول ده بيقيّد قيمة البضاعة دي (الكمية × تكلفة الوحدة وقت الدخول) عشان
-- تتحسب كـ«رأس مال بضاعة بادئين بيه». هو سجل رأس مال عيني — مش بيمسّ الخزنة ولا
-- الموردين، بالظبط زي ما «رصيد افتتاحي» للمورد مش بيمسّ الخزنة.
create table if not exists stock_intakes (
  id uuid default gen_random_uuid() primary key,
  product_id uuid,
  product_name text,
  quantity numeric not null default 0,    -- الكمية الداخلة (موجبة دائماً)
  unit_cost numeric not null default 0,   -- تكلفة الوحدة وقت الدخول
  total_value numeric not null default 0, -- quantity × unit_cost
  source text,                            -- product_created | manual_edit | excel_import | stocktake | opening
  note text,
  created_at timestamptz default now()
);

create index if not exists stock_intakes_product_id_idx on stock_intakes (product_id);
create index if not exists stock_intakes_created_at_idx on stock_intakes (created_at);

alter table stock_intakes enable row level security;
drop policy if exists "authenticated full access" on stock_intakes;
create policy "authenticated full access" on stock_intakes for all to authenticated using (true) with check (true);
revoke all on stock_intakes from anon;
grant all on stock_intakes to authenticated;

-- ترحيل الوضع الحالي مرة واحدة فقط (لو الجدول فاضي): لكل منتج، الجزء من المخزون
-- الحالي اللي مجاش من فاتورة شراء = المخزون الحالي − إجمالي الكميات المشتراة.
-- تقدير متحفّظ (لو اتباع جزء من البضاعة الافتتاحية بيطلع أقل من الحقيقي)، وتقدر
-- تعدّله من صفحة المخزون → «مخزون بدون شراء» (حذف قيد / إضافة قيد يدوي).
do $$
begin
  if not exists (select 1 from stock_intakes) then
    insert into stock_intakes (product_id, product_name, quantity, unit_cost, total_value, source, note)
    select
      p.id,
      p.name,
      greatest(coalesce(p.stock_quantity, 0) - coalesce(pi.qty, 0), 0) as qty,
      coalesce(nullif(p.average_purchase_price, 0), p.purchase_price, 0) as unit_cost,
      greatest(coalesce(p.stock_quantity, 0) - coalesce(pi.qty, 0), 0)
        * coalesce(nullif(p.average_purchase_price, 0), p.purchase_price, 0) as total_value,
      'opening',
      'رصيد افتتاحي — ترحيل تلقائي عند تفعيل السجل'
    from products p
    left join (
      select product_id, sum(quantity) as qty from purchase_items group by product_id
    ) pi on pi.product_id = p.id
    where greatest(coalesce(p.stock_quantity, 0) - coalesce(pi.qty, 0), 0) > 0;
  end if;
end $$;



-- ==========================================================================
-- SOURCE: db/60_friday_shift_and_attendance_admin.sql
-- ==========================================================================

-- =============================================================================
-- ADRIA — شفت الجمعة لكل موظف + إجازة إدارية بدون خصم + تعديل الحضور من الأدمن
-- شغّله مرة واحدة (آمن للتشغيل أكثر من مرة). بيبني فوق db/33 + db/40 + db/51.
-- =============================================================================
-- (1) شفت الجمعة: كل موظف ليه بداية/نهاية دوام مستقلة يوم الجمعة، أو الجمعة راحة
--     أصلاً. لو الحقول فاضية بيرجع للشفت العادي — فالموظفين القدام مايتأثروش.
-- (2) إجازة بدون خصم: نوع ثالث في employee_leaves اسمه 'granted' — الأدمن بيدي
--     الموظف يوم إجازة، مش بيتخصم من المرتب ولا بياكل من الرصيد الشهري (بعكس
--     'paid' اللي بياخد من الرصيد و'unpaid' اللي بيتخصم).
-- (3) أي يوم عليه إجازة (بأي نوع) أو يوم راحة أسبوعية = مفيش حساب تأخير، حتى لو
--     الموظف سجّل حضور — عشان مايتخصمش على يوم أصلاً مش مطلوب فيه دوام.
-- =============================================================================

-- 1) أعمدة شفت الجمعة على الموظفين
alter table employees add column if not exists friday_shift_start time;
alter table employees add column if not exists friday_shift_end   time;
alter table employees add column if not exists friday_is_off      boolean not null default false;

-- 2) نوع إجازة ثالث: 'granted' (إجازة إدارية بدون خصم وبدون استهلاك الرصيد)
alter table employee_leaves drop constraint if exists employee_leaves_leave_type_check;
alter table employee_leaves add  constraint employee_leaves_leave_type_check
  check (leave_type in ('paid', 'unpaid', 'granted'));

-- 3) تسجيل الحضور الذاتي — بشفت الجمعة وبتجاهل التأخير في أيام الراحة/الإجازة
create or replace function public.record_attendance(
  p_employee_id uuid,
  p_pin text,
  p_action text
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_emp    employees%rowtype;
  v_today  date := public.attendance_business_date();  -- اليوم المحاسبي مش التقويمي
  v_now    timestamptz := now();
  v_local  timestamp := (now() at time zone 'Africa/Cairo'); -- توقيت القاهرة (ساعة الحائط)
  v_row    employee_attendance%rowtype;
  v_dow          int := extract(dow from v_today);  -- 5 = الجمعة
  v_shift_start  time;
  v_shift_end    time;
  v_off          boolean := false;
  v_expected     timestamp;
  v_raw_late     numeric;
  v_grace        numeric;
  v_late         numeric := 0;
  v_workday      numeric := 480;
  v_daily        numeric;
  v_ded          numeric := 0;
begin
  select * into v_emp from employees where id = p_employee_id;
  if not found then
    return jsonb_build_object('ok', false, 'error', 'not_found');
  end if;
  if coalesce(v_emp.is_active, true) = false then
    return jsonb_build_object('ok', false, 'error', 'inactive');
  end if;
  if coalesce(v_emp.attendance_pin, '') = '' then
    return jsonb_build_object('ok', false, 'error', 'no_pin');
  end if;
  if v_emp.attendance_pin <> p_pin then
    return jsonb_build_object('ok', false, 'error', 'wrong_pin');
  end if;

  -- شفت اليوم: الجمعة ليها شفت مستقل لو محدد، وإلا الشفت العادي.
  if v_dow = 5 then
    v_shift_start := coalesce(v_emp.friday_shift_start, v_emp.shift_start);
    v_shift_end   := coalesce(v_emp.friday_shift_end,   v_emp.shift_end);
    v_off         := coalesce(v_emp.friday_is_off, false);
  else
    v_shift_start := v_emp.shift_start;
    v_shift_end   := v_emp.shift_end;
  end if;

  -- يوم عليه إجازة مسجّلة (بأي نوع) = يوم راحة، مفيش تأخير ولا خصم.
  if exists (
    select 1 from employee_leaves l
     where l.employee_id = p_employee_id
       and v_today between l.start_date and l.end_date
  ) then
    v_off := true;
  end if;

  select * into v_row from employee_attendance
   where employee_id = p_employee_id and date = v_today;

  if p_action = 'check_in' then
    if found then
      return jsonb_build_object('ok', false, 'error', 'already_checked_in',
        'name', v_emp.name, 'time', v_row.check_in);
    end if;

    -- حساب التأخير والخصم (لو محدد بداية دوام واليوم مش راحة)
    if v_shift_start is not null and not v_off then
      v_expected := v_today + v_shift_start;
      v_grace    := coalesce(v_emp.late_grace_minutes, 0);
      v_raw_late := round(extract(epoch from (v_local - v_expected)) / 60.0);
      v_late     := greatest(0, v_raw_late - v_grace);
      if v_late > 0 then
        if v_shift_end is not null then
          v_workday := extract(epoch from (v_shift_end - v_shift_start)) / 60.0;
          if v_workday <= 0 then v_workday := v_workday + 1440; end if;
          if v_workday = 0 then v_workday := 480; end if;
        end if;
        v_daily := coalesce(v_emp.monthly_salary, 0) / 30.0;
        v_ded   := round(least(v_daily, (v_late / v_workday) * v_daily)::numeric, 2);
      end if;
    end if;

    insert into employee_attendance
      (employee_id, date, check_in, shift_start, late_minutes, deduction_amount, month, note)
    values
      (p_employee_id, v_today, v_now, v_shift_start, v_late, v_ded,
       to_char(v_today, 'YYYY-MM'),
       case when v_off then 'تسجيل ذاتي — يوم راحة/إجازة' else 'تسجيل ذاتي' end);

    return jsonb_build_object('ok', true, 'action', 'check_in',
      'name', v_emp.name, 'time', v_now, 'late_minutes', v_late, 'deduction', v_ded,
      'day_off', v_off);

  elsif p_action = 'check_out' then
    if not found then
      return jsonb_build_object('ok', false, 'error', 'not_checked_in', 'name', v_emp.name);
    end if;
    if v_row.check_out is not null then
      return jsonb_build_object('ok', false, 'error', 'already_checked_out',
        'name', v_emp.name, 'time', v_row.check_out);
    end if;
    update employee_attendance set check_out = v_now where id = v_row.id;
    return jsonb_build_object('ok', true, 'action', 'check_out',
      'name', v_emp.name, 'time', v_now);

  else
    return jsonb_build_object('ok', false, 'error', 'bad_action');
  end if;
end;
$$;

revoke all on function public.record_attendance(uuid, text, text) from public;
grant execute on function public.record_attendance(uuid, text, text) to anon, authenticated;



-- ==========================================================================
-- SOURCE: db/62_fix_display_over_stock.sql
-- ==========================================================================

-- =============================================================================
-- ADRIA — تصحيح «الكمية المعروضة أكبر من إجمالي المخزون».
-- شغّله مرة واحدة (آمن للتشغيل أكثر من مرة).
-- =============================================================================
-- السبب: البيع كان بينقص stock_quantity بس ومابيلمسش display_quantity، فبعد ما
-- تبيع من اللي معروض في المحل يفضل الرقم المعروض زي ما هو ويبقى أكبر من الإجمالي.
-- الواجهة كانت بتتعامل معاه بـ min(display, stock) فالأرقام الظاهرة كانت سليمة،
-- لكن حساب «المستودع» (الإجمالي − المعروض) كان بيطلع صفر بالغلط.
--
-- الإصلاح في الكود: البيع/الحجز بقى ينزّل المعروض مع الإجمالي (نفس منطق min).
-- والاستعلام ده بيصلّح الصفوف القديمة مرة واحدة.
-- =============================================================================

-- (1) شوف الأول عدد المنتجات المتأثرة (قراءة فقط).
select count(*) as "منتجات معروضها أكبر من مخزونها"
from products
where coalesce(display_quantity, 0) > coalesce(stock_quantity, 0) + 0.0001;

-- (2) التفاصيل قبل التعديل (قراءة فقط).
-- select id, name, barcode, stock_quantity, display_quantity
-- from products
-- where coalesce(display_quantity,0) > coalesce(stock_quantity,0) + 0.0001
-- order by display_quantity - stock_quantity desc;

-- (3) التصحيح: المعروض ما يزيدش عن الإجمالي.
--     المخزون نفسه مابيتغيرش — الرقم الإجمالي هو الصح، والمعروض هو اللي بايت.
update products
set display_quantity = greatest(0, coalesce(stock_quantity, 0))
where coalesce(display_quantity, 0) > coalesce(stock_quantity, 0) + 0.0001;

-- (4) تأكيد: لازم يرجّع صفر.
select count(*) as "متبقي بعد التصحيح"
from products
where coalesce(display_quantity, 0) > coalesce(stock_quantity, 0) + 0.0001;



-- ==========================================================================
-- SOURCE: db/63_orders_client_ref.sql
-- ==========================================================================

-- =============================================================================
-- ADRIA — منع تكرار الفاتورة لما النت يفصل أثناء الحفظ.
-- شغّله مرة واحدة (آمن للتشغيل أكثر من مرة).
-- =============================================================================
-- المشكلة: الكاشير بيأكّد الفاتورة، الطلب بيوصل للسيرفر ويتسجّل فعلاً، وبعدين
-- النت بيفصل قبل ما الرد يرجع للجهاز. الكود بيشوف «خطأ» فبيقع على الوضع الأوفلاين
-- ويحفظ نسخة محلية، وأول ما النت يرجع بيرفعها ⇒ **نفس البيعة برقمين** (٣١٧ و٣١٨).
--
-- ده سلوك كل نظام بيكتب على الشبكة: الطلب بيتنفّذ «مرة على الأقل» مش «مرة بالظبط».
-- الحل المعياري: بصمة فريدة (idempotency key) بيولّدها الجهاز قبل ما يبعت، وبتتكتب
-- مع الفاتورة. لو الفاتورة اتسجّلت خلاص بنفس البصمة، أي محاولة تانية بترجع من غير
-- ما تكتب صف جديد.
--
-- الفهرس الفريد تحت هو الضمان النهائي: حتى لو الكود غلط، قاعدة البيانات نفسها
-- بترفض الصف المكرر.
-- =============================================================================

alter table orders add column if not exists client_ref text;

-- فريد للصفوف اللي ليها بصمة بس — الفواتير القديمة (client_ref = null) مالهاش شرط.
create unique index if not exists orders_client_ref_uniq
  on orders (client_ref)
  where client_ref is not null;

-- للبحث السريع وقت المزامنة.
create index if not exists orders_client_ref_idx on orders (client_ref);

-- كشف أي تكرار قديم (قبل تشغيل الملف) — قراءة فقط.
-- بيدوّر على فواتير بنفس الإجمالي ونفس الكاشير في خلال ٥ دقايق من بعض.
-- راجعها بنفسك: اللي يطلع مكرر فعلاً امسحه من صفحة الفواتير (الحذف بيرجّع المخزون).
-- select a.id as invoice_1, b.id as invoice_2, a.total, a.cashier_name,
--        a.created_at as time_1, b.created_at as time_2,
--        round(extract(epoch from (b.created_at - a.created_at))::numeric) as seconds_apart
-- from orders a join orders b
--   on b.created_at > a.created_at
--   and b.created_at < a.created_at + interval '5 minutes'
--   and abs(coalesce(b.total,0) - coalesce(a.total,0)) < 0.01
--   and coalesce(b.cashier_name,'') = coalesce(a.cashier_name,'')
--   and coalesce(b.type,'') = coalesce(a.type,'')
-- where coalesce(a.is_deleted,false) = false and coalesce(b.is_deleted,false) = false
--   and coalesce(a.total,0) > 0
-- order by a.created_at desc;



-- ==========================================================================
-- SOURCE: db/64_waive_deductions.sql
-- ==========================================================================

-- =============================================================================
-- مسامحة الخصومات (waive) — المدير يعفي الموظف من خصم قبل صرف الراتب
-- شغّله مرة واحدة (آمن للتشغيل أكتر من مرة).
-- =============================================================================
--  الخصم بيتحسب تلقائياً (تأخير) أو بيتسجّل يدوياً (خصم/إجازة بدون أجر)، لكن
--  المدير ساعات بيسامح: الموظف اتأخر لظرف، أو الخصم اتسجّل بالغلط.
--
--  ليه مش بنمسح الصف أو نصفّر المبلغ وخلاص؟
--    لأن الموظف بيسأل «اتخصم مني كام وليه؟» بعد كده. مسح الصف بيضيّع إن التأخير
--    حصل أصلاً، وتصفير المبلغ لوحده بيضيّع إن المدير سامح (مش إن الغرامة كانت صفر).
--
--  الموديل: الحقل الحيّ (deduction_amount / amount) بيتصفّر — وده اللي كل
--  الحسابات بتقراه، فمفيش سطر حساب واحد محتاج يتغيّر — والمبلغ الأصلي بيتنقل
--  لـ waived_amount مع وقت المسامحة وسببها.
--
--  المسامحة الجزئية شغّالة كمان: waived_amount = الجزء المعفى، والباقي بيفضل
--  في الحقل الحيّ.
-- =============================================================================

-- خصم التأخير (الحقل الحيّ: deduction_amount)
alter table public.employee_attendance
  add column if not exists waived_amount numeric not null default 0,
  add column if not exists waived_at     timestamptz,
  add column if not exists waive_note    text;

-- خصم الإجازة بدون أجر (الحقل الحيّ: deduction_amount)
alter table public.employee_leaves
  add column if not exists waived_amount numeric not null default 0,
  add column if not exists waived_at     timestamptz,
  add column if not exists waive_note    text;

-- الخصم اليدوي (الحقل الحيّ: amount)
alter table public.employee_deductions
  add column if not exists waived_amount numeric not null default 0,
  add column if not exists waived_at     timestamptz,
  add column if not exists waive_note    text;

-- تحقّق: كل الأعمدة لازم تطلع في النتيجة (٩ صفوف).
select table_name, column_name
from information_schema.columns
where table_schema = 'public'
  and table_name in ('employee_attendance', 'employee_leaves', 'employee_deductions')
  and column_name in ('waived_amount', 'waived_at', 'waive_note')
order by table_name, column_name;



-- ==========================================================================
-- SOURCE: db/67_refund_split.sql
-- ==========================================================================

-- =============================================================================
-- ADRIA — استرداد المرتجع على أكتر من وسيلة دفع
-- شغّله مرة واحدة (آمن للتشغيل أكتر من مرة).
-- =============================================================================
--  قبل كده: عمود `refund_method` واحد (كاش أو فيزا أو محفظة أو انستا) — يعني
--  المرتجع كله لازم يرجع على وسيلة واحدة. لكن العميل ممكن يكون دفع بأكتر من
--  وسيلة، أو الدرج مافيهوش كاش كفاية فيترد جزء كاش وجزء انستا.
--
--  الأعمدة دي **تراكمية**: الفاتورة ممكن يترجّع منها أكتر من مرة، فكل مرة
--  بتتضاف على اللي قبلها. المجموع لازم يساوي مجموع order_items.refunded_amount.
--
--  التوافق مع القديم: `refund_method` بيفضل موجود ومتسجّل (بالوسيلة الأكبر).
--  الحسابات بتقرا التقسيمة لو فيها أي رقم، وإلا بترجع للعمود القديم — فالفواتير
--  القديمة بتتحسب زي ما هي بالظبط. نفس قاعدة applySplit في باقي النظام.
-- =============================================================================

alter table orders
  add column if not exists refunded_cash     numeric not null default 0,
  add column if not exists refunded_visa     numeric not null default 0,
  add column if not exists refunded_wallet   numeric not null default 0,
  add column if not exists refunded_instapay numeric not null default 0,
  add column if not exists refunded_method5  numeric not null default 0,
  add column if not exists refunded_method6  numeric not null default 0;

-- تحقّق: لازم تطلع ٦ صفوف.
select column_name, data_type
from information_schema.columns
where table_schema = 'public' and table_name = 'orders'
  and column_name in ('refunded_cash', 'refunded_visa', 'refunded_wallet',
                      'refunded_instapay', 'refunded_method5', 'refunded_method6')
order by column_name;



-- ==========================================================================
-- SOURCE: db/71_hances_pro_enterprise_modules.sql
-- ==========================================================================

-- Migration 71: HANCES PRO Enterprise ERP Modules for ADRIA (Refined)
-- Includes: Shipping Carriers (SMSA/FedEx/Aramex/DHL), Logistics Orders, Warehouse Transfers & Movement Logs, Supplier Transactions, Advanced Purchase Invoices (WACC), and Category Analytics

-- 1. Shipping Carriers & Logistics Orders
create table if not exists shipping_carriers (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  phone text,
  email text,
  address text,
  tracking_url_template text,
  status text default 'active', -- active, inactive
  created_at timestamptz default now()
);

-- Pre-populate default carriers if empty
insert into shipping_carriers (name, phone, email, tracking_url_template, status)
select 'SMSA Express', '920009999', 'support@smsaexpress.com', 'https://www.smsaexpress.com/track/{TN}', 'active'
where not exists (select 1 from shipping_carriers where name = 'SMSA Express');

insert into shipping_carriers (name, phone, email, tracking_url_template, status)
select 'FedEx', '18004633339', 'support@fedex.com', 'https://www.fedex.com/fedextrack/?trknbr={TN}', 'active'
where not exists (select 1 from shipping_carriers where name = 'FedEx');

insert into shipping_carriers (name, phone, email, tracking_url_template, status)
select 'Aramex', '920027447', 'support@aramex.com', 'https://www.aramex.com/track/results?mode=0&ShipmentNumber={TN}', 'active'
where not exists (select 1 from shipping_carriers where name = 'Aramex');

insert into shipping_carriers (name, phone, email, tracking_url_template, status)
select 'DHL', '18002255345', 'support@dhl.com', 'https://www.dhl.com/en/express/tracking.html?AWB={TN}', 'active'
where not exists (select 1 from shipping_carriers where name = 'DHL');

create table if not exists logistics_orders (
  id uuid primary key default gen_random_uuid(),
  order_id text,
  carrier_id uuid references shipping_carriers(id) on delete set null,
  tracking_number text,
  shipping_cost numeric default 0,
  status text default 'pending', -- pending, shipped, delivered, returned
  estimated_delivery date,
  shipped_at timestamptz,
  created_at timestamptz default now()
);

-- 2. Warehouses, Warehouse Transfers & Stock Movement Logs
create table if not exists warehouses (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  location text,
  manager_id text,
  status text default 'active',
  created_at timestamptz default now()
);

create table if not exists warehouse_transfers (
  id uuid primary key default gen_random_uuid(),
  reference_no text unique not null,
  source_warehouse_id uuid references warehouses(id) on delete restrict,
  destination_warehouse_id uuid references warehouses(id) on delete restrict,
  item_id uuid references products(id) on delete cascade,
  quantity numeric not null check (quantity > 0),
  status text default 'pending', -- pending, completed, cancelled
  notes text,
  created_by text,
  created_at timestamptz default now()
);

create table if not exists stock_movement_logs (
  id uuid primary key default gen_random_uuid(),
  item_id uuid references products(id) on delete cascade,
  warehouse_id uuid references warehouses(id) on delete set null,
  movement_type text not null, -- IN, OUT, TRANSFER, ADJUSTMENT
  quantity numeric not null,
  reference_doc_id text,
  timestamp timestamptz default now()
);

-- 3. Supplier Transactions & Enhancements
alter table suppliers add column if not exists current_balance numeric default 0;
alter table suppliers add column if not exists credit_limit numeric default 0;
alter table suppliers add column if not exists email text;

create table if not exists supplier_transactions (
  id uuid primary key default gen_random_uuid(),
  supplier_id uuid references suppliers(id) on delete cascade,
  type text not null, -- PURCHASE, PAYMENT, RETURN
  amount numeric not null,
  balance_after numeric not null,
  payment_method text,
  reference_no text,
  created_at timestamptz default now()
);

-- Enable RLS & Allow authenticated access for all tables
alter table shipping_carriers enable row level security;
alter table logistics_orders enable row level security;
alter table warehouses enable row level security;
alter table warehouse_transfers enable row level security;
alter table stock_movement_logs enable row level security;
alter table supplier_transactions enable row level security;

drop policy if exists "Allow all authenticated users on shipping_carriers" on shipping_carriers;
create policy "Allow all authenticated users on shipping_carriers" on shipping_carriers for all using (true);
drop policy if exists "Allow all authenticated users on logistics_orders" on logistics_orders;
create policy "Allow all authenticated users on logistics_orders" on logistics_orders for all using (true);
drop policy if exists "Allow all authenticated users on warehouses" on warehouses;
create policy "Allow all authenticated users on warehouses" on warehouses for all using (true);
drop policy if exists "Allow all authenticated users on warehouse_transfers" on warehouse_transfers;
create policy "Allow all authenticated users on warehouse_transfers" on warehouse_transfers for all using (true);
drop policy if exists "Allow all authenticated users on stock_movement_logs" on stock_movement_logs;
create policy "Allow all authenticated users on stock_movement_logs" on stock_movement_logs for all using (true);
drop policy if exists "Allow all authenticated users on supplier_transactions" on supplier_transactions;
create policy "Allow all authenticated users on supplier_transactions" on supplier_transactions for all using (true);



-- ==========================================================================
-- SOURCE: db/72_atomic_invoice_number.sql
-- ==========================================================================

-- ADRIA — ترقيم الفواتير الذرّي + إصلاح العدّاد المتأخّر.
-- آمن للتشغيل أكتر من مرة.
--
-- المشكلة اللي بيحلّها: «عذراً، رقم الفاتورة مستخدم حالياً (N)».
--
-- الكود كان بياخد الرقم على خطوتين:
--     select current_value from invoice_counter;   -- قراءة
--     update invoice_counter set current_value = current_value + 1;  -- كتابة
-- ده **مش ذرّي** رغم إن التعليق في الكود كان مكتوب فيه "Atomic approach":
--   • كاشيرين بيقروا في نفس اللحظة → الاتنين بياخدوا نفس الرقم.
--   • لو الـUPDATE فشل لأي سبب، العدّاد بيفضل مكانه فكل بيعة بعد كده بتحاول
--     تاخد نفس الرقم المستخدم — والكاشير بيقف تماماً عن البيع.
--   • أي سكربت seed/reset بيرجّع العدّاد لـ 1 والأوردرات لسه موجودة → نفس القفلة.
--
-- الحل: دالة بتزوّد وترجّع في statement واحد. Postgres بياخد قفل على الصف
-- طول الـUPDATE، فمفيش نافذة يقدر عميل تاني يقرا فيها نفس القيمة.

-- ── 1) مزامنة العدّاد مع أكبر رقم فاتورة موجود فعلاً ────────────────────────
-- ده بيصلّح الحالة الحالية: العدّاد بيرجع لـ 1 بعد الـ seed والأوردرات لسه هناك.
-- بنعدّي الصفوف اللي id بتاعها مش رقم (لو فيه بيانات قديمة بصيغة مختلفة).
update invoice_counter
set current_value = greatest(
  coalesce((select max(id::bigint) from orders where id ~ '^[0-9]+$'), 0) + 1,
  current_value
)
where id = 1;

-- ── 2) الدالة الذرّية ───────────────────────────────────────────────────────
create or replace function next_invoice_number()
returns integer
language plpgsql
security definer
set search_path = public
as $$
declare
  v integer;
begin
  -- UPDATE ... RETURNING في statement واحد = ذرّي. الصف مقفول لحد ما ينتهي.
  update invoice_counter
  set current_value = current_value + 1
  where id = 1
  returning current_value - 1 into v;

  if v is null then
    -- الصف مش موجود (قاعدة بيانات ناقصة) — بننشئه من أكبر رقم فاتورة.
    insert into invoice_counter (id, current_value)
    values (1, coalesce((select max(id::bigint) from orders where id ~ '^[0-9]+$'), 0) + 2)
    on conflict (id) do update set current_value = excluded.current_value
    returning current_value - 1 into v;
  end if;

  -- حزام أمان: لو العدّاد لسه متأخّر عن الواقع (seed مثلاً)، بنقفز فوق
  -- المستخدم بدل ما نرجّع رقم هيصطدم.
  while exists (select 1 from orders where id = v::text) loop
    update invoice_counter
    set current_value = current_value + 1
    where id = 1
    returning current_value - 1 into v;
  end loop;

  return v;
end;
$$;

grant execute on function next_invoice_number() to authenticated;

-- ── 3) تحديث schema cache بتاع PostgREST عشان يشوف الدالة ──────────────────
notify pgrst, 'reload schema';

-- ── 4) تأكيد ────────────────────────────────────────────────────────────────
select
  (select current_value from invoice_counter where id = 1) as "العدّاد دلوقتي",
  (select coalesce(max(id::bigint), 0) from orders where id ~ '^[0-9]+$') as "أكبر رقم فاتورة",
  case
    when (select current_value from invoice_counter where id = 1)
       > (select coalesce(max(id::bigint), 0) from orders where id ~ '^[0-9]+$')
    then 'تمام ✅'
    else 'لسه متأخّر ❌'
  end as "الحالة";



-- ==========================================================================
-- SOURCE: db/73_ensure_orders_columns.sql
-- ==========================================================================

-- ADRIA — يضمن وجود كل أعمدة جدول الفواتير.
-- آمن للتشغيل أكتر من مرة.
--
-- المشكلة اللي بيحلّها: «تعذّر حفظ الفاتورة: Could not find the 'client_ref'
-- column of 'orders' in the schema cache».
--
-- زي إعدادات المتجر بالظبط: تسجيل الفاتورة بيبعت كل الأعمدة في INSERT واحد،
-- فأي عمود ناقص كان بيضيّع **البيعة كلها**. والأخطر إن شاشة الكاشير كانت
-- بتكمّل عادي وتطبع إيصال وتقول «تم الدفع بنجاح» — والفاتورة مش موجودة أصلاً.
--
-- الأعمدة دي بتتراكم من هجرات مختلفة (14 للبائع، 24 لطرق الدفع 5/6،
-- 63 لبصمة التكرار...). لو قاعدة بيانات اتعملت من نسخة قديمة أو من سكربت
-- seed، بيبقى فيها نقص. الملف ده بيلحّقهم كلهم مرة واحدة.

-- ── المبالغ وتقسيمة الدفع ───────────────────────────────────────────────────
alter table orders add column if not exists total           numeric default 0;
alter table orders add column if not exists paid_amount     numeric default 0;
alter table orders add column if not exists paid_cash       numeric default 0;
alter table orders add column if not exists paid_visa       numeric default 0;
alter table orders add column if not exists paid_wallet     numeric default 0;
alter table orders add column if not exists paid_instapay   numeric default 0;
alter table orders add column if not exists paid_method5    numeric default 0;  -- db/24
alter table orders add column if not exists paid_method6    numeric default 0;  -- db/24
alter table orders add column if not exists payment_method  text default 'cash';

-- ── العميل والكاشير والبائع ─────────────────────────────────────────────────
alter table orders add column if not exists customer_id      uuid;
alter table orders add column if not exists cashier_name     text;
alter table orders add column if not exists salesperson_id   uuid;  -- db/14
alter table orders add column if not exists salesperson_name text;  -- db/14

-- ── بيانات إضافية ───────────────────────────────────────────────────────────
alter table orders add column if not exists type            text default 'sale';
alter table orders add column if not exists notes           text;
alter table orders add column if not exists coupon_code     text;
alter table orders add column if not exists discount_amount numeric default 0;
alter table orders add column if not exists car_id          uuid;
alter table orders add column if not exists created_at      timestamptz default now();

-- ── بصمة منع التكرار (db/63) ────────────────────────────────────────────────
-- من غيرها لو النت فصل بعد ما الطلب وصل السيرفر، الكاشير بيعيد الحفظ
-- فالفاتورة بتتسجّل مرتين.
alter table orders add column if not exists client_ref text;
create unique index if not exists orders_client_ref_uniq
  on orders (client_ref)
  where client_ref is not null;
create index if not exists orders_client_ref_idx on orders (client_ref);

-- ── تحديث schema cache بتاع PostgREST ───────────────────────────────────────
-- من غير السطر ده Supabase بيفضل يرجّع نفس الخطأ لدقايق رغم إن العمود اتضاف.
notify pgrst, 'reload schema';

-- ── تأكيد: بيعرض أي عمود لسه ناقص. المفروض النتيجة ترجع فاضية ───────────────
select c.column_name as "عمود لسه ناقص"
from (values
  ('id'),('total'),('paid_amount'),('paid_cash'),('paid_visa'),('paid_wallet'),
  ('paid_instapay'),('paid_method5'),('paid_method6'),('payment_method'),
  ('customer_id'),('cashier_name'),('salesperson_id'),('salesperson_name'),
  ('type'),('notes'),('coupon_code'),('discount_amount'),('car_id'),
  ('created_at'),('client_ref')
) as c(column_name)
where not exists (
  select 1 from information_schema.columns i
  where i.table_name = 'orders' and i.column_name = c.column_name
);



-- ==========================================================================
-- SOURCE: db/74_product_image.sql
-- ==========================================================================

-- =============================================================================
-- HANCES — db/74: صورة المنتج + ضمان باقي أعمدة جدول products
-- =============================================================================
--  المشكلة: الواجهة بتبعت image_url مع حفظ المنتج، لكن العمود مش موجود في جدول
--  products. و addProduct/updateProduct في src/store/useStore.ts بيتخطّوا أي
--  عمود ناقص ويكمّلوا حفظ الباقي — فالصورة كانت بتبان في الشاشة بعد الحفظ
--  (تحديث محلّي) وتختفي بعد أول تحديث للصفحة، من غير أي رسالة خطأ.
--
--  العمود بيخزّن يا رابط صورة عادي (https://...) يا data URL للصورة المرفوعة
--  من الجهاز بعد تصغيرها على canvas (نفس نمط store_settings.logo).
--
--  الملف كمان بيضمن باقي الأعمدة اللي الواجهة بتبعتها (أسعار المنصّات وخلافه)
--  عشان نفس الباج مايتكررش على حقل تاني. آمن للتشغيل أكتر من مرة (idempotent).
--
--  ⚠️ لو ضفت حقل جديد للمنتج في الواجهة، ضيف عموده هنا كمان.
-- =============================================================================

-- ── صورة المنتج (المطلوبة في جدول المنتجات وفي الكاشير/POS) ─────────────────
alter table products add column if not exists image_url text;

-- ── أعمدة موجودة في ميجريشنز سابقة — بنأكّدها لو القاعدة مااتحدّثتش ──────────
alter table products add column if not exists discount_price       numeric default 0; -- db/05
alter table products add column if not exists display_quantity     numeric default 0; -- db/06
alter table products add column if not exists season               text;              -- db/07
alter table products add column if not exists wholesale_price      numeric default 0; -- db/07
alter table products add column if not exists half_wholesale_price numeric default 0; -- db/07
alter table products add column if not exists color                text;              -- db/04
alter table products add column if not exists factory_quantity     numeric default 0; -- db/13
alter table products add column if not exists supplier_name        text;              -- db/31

-- ── أسعار ومصاريف المنصّات (الواجهة بتبعتها من مودال المنتج) ────────────────
alter table products add column if not exists website_ad_cost        numeric default 0;
alter table products add column if not exists amazon_price           numeric default 0;
alter table products add column if not exists amazon_discount_price  numeric default 0;
alter table products add column if not exists amazon_commission      numeric default 0;
alter table products add column if not exists amazon_shipping        numeric default 0;
alter table products add column if not exists amazon_ad_cost         numeric default 0;
alter table products add column if not exists noon_price             numeric default 0;
alter table products add column if not exists noon_discount_price    numeric default 0;
alter table products add column if not exists noon_commission        numeric default 0;
alter table products add column if not exists noon_shipping          numeric default 0;
alter table products add column if not exists noon_ad_cost           numeric default 0;
alter table products add column if not exists jumia_price            numeric default 0;
alter table products add column if not exists jumia_discount_price   numeric default 0;
alter table products add column if not exists jumia_commission       numeric default 0;
alter table products add column if not exists jumia_shipping         numeric default 0;
alter table products add column if not exists jumia_ad_cost          numeric default 0;
alter table products add column if not exists custom_stores          jsonb;
alter table products add column if not exists colors                 jsonb;
alter table products add column if not exists alert_limit            numeric default 5;
alter table products add column if not exists unit                   text not null default 'قطعة';

-- ── السماح الكامل للـ anon و authenticated بالحفظ والتعديل ─────────
grant all on products to anon, authenticated;
drop policy if exists "allow_all_anon_authenticated" on products;
create policy "allow_all_anon_authenticated" on products for all to anon, authenticated using (true) with check (true);

-- ── تحديث الـ schema cache بتاع PostgREST ───────────────────────────────────
-- من غير السطر ده Supabase ممكن يفضل يرجّع "Could not find the 'image_url'
-- column ... in the schema cache" لدقايق رغم إن العمود اتضاف فعلاً.
notify pgrst, 'reload schema';

-- ── تأكيد: بيعرض أي عمود لسه ناقص. المفروض النتيجة ترجع فاضية ───────────────
select c.column_name as "عمود لسه ناقص"
from (values
  ('image_url'),('discount_price'),('display_quantity'),('season'),
  ('wholesale_price'),('half_wholesale_price'),('color'),('factory_quantity'),
  ('supplier_name'),('website_ad_cost'),('amazon_price'),('amazon_discount_price'),
  ('amazon_commission'),('amazon_shipping'),('amazon_ad_cost'),('noon_price'),('noon_discount_price'),
  ('noon_commission'),('noon_shipping'),('noon_ad_cost'),('jumia_price'),
  ('jumia_discount_price'),('jumia_commission'),('jumia_shipping'),
  ('jumia_ad_cost'),('custom_stores'),('colors'),('alert_limit'),('unit')
) as c(column_name)
where not exists (
  select 1 from information_schema.columns i
  where i.table_name = 'products' and i.column_name = c.column_name
);



-- ==========================================================================
-- SOURCE: db/75_platform_collections.sql
-- ==========================================================================

-- إنشاء جدول تحصيلات المنصات وشركات الشحن
CREATE TABLE IF NOT EXISTS platform_collections (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    entity_type TEXT NOT NULL CHECK (entity_type IN ('platform', 'carrier')),
    entity_name TEXT NOT NULL,
    month TEXT NOT NULL, -- e.g., '2023-10'
    expected_amount NUMERIC DEFAULT 0,
    collected_amount NUMERIC DEFAULT 0,
    status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'collected')),
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- سياسات الأمان RLS
ALTER TABLE platform_collections ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Allow authenticated full access to platform_collections" ON platform_collections;
CREATE POLICY "Allow authenticated full access to platform_collections"
    ON platform_collections
    FOR ALL
    TO authenticated
    USING (true)
    WITH CHECK (true);



-- ==========================================================================
-- SOURCE: db/76_FIX_PRODUCT_SAVE_AND_PERMISSIONS.sql
-- ==========================================================================

-- =============================================================================
-- HANCES PRO — ملف إصلاح الحفظ وصلاحيات جدول المنتجات (ملف منفصل وآمن 100%)
-- =============================================================================
-- هذا الملف يقوم بالآتي:
-- 1. إضافة جميع الأعمدة الناقصة لجدول المنتجات (unit, amazon_shipping, is_hidden, إلخ)
-- 2. إزالة أي View قديم متعارض (مثل v_stock_gap)
-- 3. منح الصلاحيات الكاملة (SELECT, INSERT, UPDATE, DELETE) للـ anon و authenticated
-- 4. إعداد سياسة الأمان RLS المفتوحة لضمان عدم رفض Supabase لأي عملية حفظ
-- =============================================================================

-- ── 1. إزالة أي Views متعارضة ────────────────────────────────────────────────
drop view if exists v_stock_gap cascade;

-- ── 2. ضمان وجود جدول المنتجات وباقي الأعمدة بالكامل ──────────────────────────
create table if not exists products (
  id text primary key,
  created_at timestamptz default now()
);

alter table products add column if not exists name                   text;
alter table products add column if not exists barcode                text;
alter table products add column if not exists image_url              text;
alter table products add column if not exists purchase_price         numeric default 0;
alter table products add column if not exists average_purchase_price numeric default 0;
alter table products add column if not exists sale_price             numeric default 0;
alter table products add column if not exists discount_price         numeric default 0;
alter table products add column if not exists wholesale_price        numeric default 0;
alter table products add column if not exists half_wholesale_price   numeric default 0;
alter table products add column if not exists season                 text;
alter table products add column if not exists stock_quantity         numeric default 0;
alter table products add column if not exists display_quantity       numeric default 0;
alter table products add column if not exists factory_quantity       numeric default 0;
alter table products add column if not exists category_id            text;
alter table products add column if not exists unit                   text default 'قطعة';
alter table products add column if not exists is_hidden              boolean default false;
alter table products add column if not exists color                  text;
alter table products add column if not exists supplier_name          text;

-- أسعار ومصاريف المنصات والمتاجر
alter table products add column if not exists website_ad_cost        numeric default 0;
alter table products add column if not exists amazon_price           numeric default 0;
alter table products add column if not exists amazon_discount_price  numeric default 0;
alter table products add column if not exists amazon_commission      numeric default 0;
alter table products add column if not exists amazon_shipping        numeric default 0;
alter table products add column if not exists amazon_ad_cost         numeric default 0;
alter table products add column if not exists noon_price             numeric default 0;
alter table products add column if not exists noon_discount_price    numeric default 0;
alter table products add column if not exists noon_commission        numeric default 0;
alter table products add column if not exists noon_shipping          numeric default 0;
alter table products add column if not exists noon_ad_cost           numeric default 0;
alter table products add column if not exists jumia_price            numeric default 0;
alter table products add column if not exists jumia_discount_price   numeric default 0;
alter table products add column if not exists jumia_commission       numeric default 0;
alter table products add column if not exists jumia_shipping         numeric default 0;
alter table products add column if not exists jumia_ad_cost          numeric default 0;
alter table products add column if not exists custom_stores          jsonb;
alter table products add column if not exists colors                 jsonb;
alter table products add column if not exists alert_limit            numeric default 5;

-- ── 3. تفعيل RLS وإعطاء الصلاحيات الكاملة للـ anon و authenticated ────────────
alter table products enable row level security;

drop policy if exists "allow_all_products_access" on products;
drop policy if exists "allow_all_anon_authenticated" on products;
drop policy if exists "allow all" on products;

create policy "allow_all_products_access"
  on products
  for all
  to anon, authenticated
  using (true)
  with check (true);

grant all on products to anon, authenticated;

-- ── 4. تحديث الـ Schema Cache الخاص بـ PostgREST ─────────────────────────────
notify pgrst, 'reload schema';



-- ==========================================================================
-- SOURCE: add_card_number_to_customers.sql
-- ==========================================================================

-- ============================================================
-- إضافة حقل رقم الكارت للعملاء
-- شغّل هذا السكريبت في محرر Supabase SQL
-- ============================================================

-- إضافة عمود رقم الكارت إذا لم يكن موجوداً
alter table if exists customers add column if not exists card_number text;

-- إذا كان العمود موجوداً بالفعل، فهذا سيعطي رسالة، لكن هذا طبيعي



-- ==========================================================================
-- SOURCE: add_product_units_schema.sql
-- ==========================================================================

-- ─────────────────────────────────────────────────────────────
-- نظام السوبر ماركت والمواد الغذائية: المنتجات والوحدات والكسور
-- وتطهير قاعدة البيانات من خصائص ومنتجات الملابس السابقة
-- شغّل هذا الملف في Supabase SQL Editor
-- ─────────────────────────────────────────────────────────────

-- 1) إزالة أعمدة الملابس السابقة إن وجدت
alter table products drop column if exists season;
alter table products drop column if exists color;

-- 2) عمود الوحدة على المنتجات (الافتراضي: قطعة)
alter table products
  add column if not exists unit text not null default 'قطعة';

-- 3) السماح بكميات كسرية (وزن/حجم) في المخزون والفواتير
--    تحويل أعمدة الكمية من integer إلى numeric
alter table products
  alter column stock_quantity type numeric using stock_quantity::numeric;

alter table purchase_items
  alter column quantity type numeric using quantity::numeric;

alter table order_items
  alter column quantity type numeric using quantity::numeric,
  alter column returned_quantity type numeric using returned_quantity::numeric;

-- 4) إدراج تصنيفات السوبر ماركت الرئيسية
insert into categories (id, name, image_url) values
  ('cat_dairy',    'ألبان ومجمدات',   'https://images.unsplash.com/photo-1628088062854-d1870b4553da?w=500&q=80'),
  ('cat_dry',      'بقالة جافة',     'https://images.unsplash.com/photo-1586201375761-83865001e31c?w=500&q=80'),
  ('cat_beverages','مشروبات وحلويات', 'https://images.unsplash.com/photo-1527960471264-932f39eb5846?w=500&q=80'),
  ('cat_cleaning', 'منظفات ورقيات',  'https://images.unsplash.com/photo-1585421514738-01798e348b17?w=500&q=80'),
  ('cat_produce',  'خضار وفواكه',    'https://images.unsplash.com/photo-1610832958506-aa56368176cf?w=500&q=80'),
  ('cat_meat',     'لحوم وأسماك',    'https://images.unsplash.com/photo-1607623814075-e51df1bdc82f?w=500&q=80')
on conflict (id) do update set name = excluded.name;

-- 5) إدراج منتجات سوبر ماركت ومواد غذائية شاملة
insert into products (
  id, name, barcode, purchase_price, average_purchase_price, sale_price, half_wholesale_price, wholesale_price, discount_price, stock_quantity, display_quantity, category_id, unit, supplier_name, image_url
) values
  -- ألبان ومجمدات
  ('prod_sm_1',  'جبنة بيضاء فلاحي طازجة',        '6221001', 95,  95,  130, 120, 115, 125, 50,  20, 'cat_dairy',     'كيلو', 'مصنع ألبان الهناء',   'https://images.unsplash.com/photo-1486297678162-eb2a19b0a32d?w=500&q=80'),
  ('prod_sm_2',  'حليب جهينة كامل الدسم 1 لتر',   '6221002', 34,  34,  42,  39,  38,  40,  100, 40, 'cat_dairy',     'لتر',  'شركة جهينة للأغذية', 'https://images.unsplash.com/photo-1563636619-e9143da7973b?w=500&q=80'),
  ('prod_sm_3',  'زبادي جهينة طبيعي 105 جرام',    '6221003', 6.5, 6.5, 8.5, 7.8, 7.5, 8,   200, 80, 'cat_dairy',     'علبة', 'شركة جهينة للأغذية', 'https://images.unsplash.com/photo-1571212515416-fef01fc43637?w=500&q=80'),
  ('prod_sm_4',  'جبنة رومي قديم مبشور',          '6221004', 190, 190, 250, 235, 225, 240, 30,  15, 'cat_dairy',     'كيلو', 'شركة الإخلاص للأجبان','https://images.unsplash.com/photo-1452195100486-9cc805987862?w=500&q=80'),

  -- بقالة جافة
  ('prod_sm_5',  'أرز المطبخ ممتاز 1 كجم',        '6222001', 27,  27,  35,  32,  31,  33,  150, 60, 'cat_dry',       'كيلو', 'مضرب المطبخ للأرز',  'https://images.unsplash.com/photo-1586201375761-83865001e31c?w=500&q=80'),
  ('prod_sm_6',  'زيت عباد الشمس كريستال 800 مل', '6222002', 52,  52,  65,  60,  58,  62,  80,  30, 'cat_dry',       'علبة', 'شركة آرما للزيوت',   'https://images.unsplash.com/photo-1474979266404-7eaacbcd87c5?w=500&q=80'),
  ('prod_sm_7',  'مكرونة حواء قلم 400 جرام',       '6222003', 10.5,10.5,14,  12.5,12,  13.5,200, 90, 'cat_dry',       'باكو', 'شركة المطاحن الحديثة','https://images.unsplash.com/photo-1621996346565-e3def6164286?w=500&q=80'),
  ('prod_sm_8',  'شاي العروسة ناعم 250 جرام',     '6222004', 44,  44,  55,  50,  48,  52,  120, 50, 'cat_dry',       'باكو', 'شركة الفتح للشاي',   'https://images.unsplash.com/photo-1576092768241-dec231879fc3?w=500&q=80'),
  ('prod_sm_9',  'سكر كريستال فاخر 1 كجم',        '6222005', 27,  27,  35,  32,  30,  33,  300, 120,'cat_dry',       'كيلو', 'شركة الدلتا للسكر',  'https://images.unsplash.com/photo-1581009146145-b5ef050c2e1e?w=500&q=80'),

  -- مشروبات وحلويات
  ('prod_sm_10', 'عصير جهينة مانجو 1 لتر',        '6223001', 21,  21,  28,  25,  24,  26,  90,  35, 'cat_beverages', 'لتر',  'شركة جهينة للأغذية', 'https://images.unsplash.com/photo-1600271886742-f049cd451bba?w=500&q=80'),
  ('prod_sm_11', 'بسكويت أوريو الأصلي 6 قطع',     '6223002', 7.5, 7.5, 10,  9,   8.5, 9.5, 250, 100,'cat_beverages', 'باكو', 'شركة مونديليز العالمية','https://images.unsplash.com/photo-1563729784474-d77dbb933a9e?w=500&q=80'),
  ('prod_sm_12', 'مياه معدنية داساني 1.5 لتر',    '6223003', 6.5, 6.5, 9,   7.8, 7.5, 8.5, 180, 70, 'cat_beverages', 'علبة', 'شركة كوكاكولا مصر',  'https://images.unsplash.com/photo-1559839734-2b71ea197ec2?w=500&q=80'),

  -- منظفات ورقيات
  ('prod_sm_13', 'مسحوق أريال أوتوماتيك 2.5 كجم',   '6224001', 155, 155, 195, 180, 172, 185, 40,  15, 'cat_cleaning',  'علبة', 'شركة بروكتر آند جامبل','https://images.unsplash.com/photo-1585421514738-01798e348b17?w=500&q=80'),
  ('prod_sm_14', 'صابون ديتول الأصلي 125 جرام',    '6224002', 16,  16,  22,  19.5,18.5,20.5,150, 60, 'cat_cleaning',  'قطعة', 'شركة ريكيت بينكيزر', 'https://images.unsplash.com/photo-1600857544200-b2f666a9a2ec?w=500&q=80'),
  ('prod_sm_15', 'مناديل فاين كلاسيك 500 منديل',   '6224003', 24,  24,  32,  29,  28,  30,  110, 45, 'cat_cleaning',  'علبة', 'مجموعة فاين الصحية', 'https://images.unsplash.com/photo-1584556812952-905ffd0c611a?w=500&q=80'),

  -- خضار وفواكه
  ('prod_sm_16', 'طماطم بلدي طازجة',             '6225001', 10,  10,  15,  13,  12,  14,  80,  30, 'cat_produce',   'كيلو', 'مزارع الصالحية',     'https://images.unsplash.com/photo-1592924357228-91a4daadcfea?w=500&q=80'),
  ('prod_sm_17', 'بطاطس تحمير فاخرة',             '6225002', 14,  14,  20,  17.5,16.5,18.5,120, 50, 'cat_produce',   'كيلو', 'مزارع البحيرة',      'https://images.unsplash.com/photo-1518977676601-b53f82aba655?w=500&q=80'),
  ('prod_sm_18', 'تفاح أحمر سكري أمريكي',         '6225003', 48,  48,  65,  58,  55,  60,  60,  25, 'cat_produce',   'كيلو', 'شركة الاستيراد الزراعي','https://images.unsplash.com/photo-1560806887-1e4cd0b6cbd6?w=500&q=80'),

  -- لحوم وأسماك
  ('prod_sm_19', 'لحم بلدي كابوريا/كندوز',        '6226001', 310, 310, 380, 355, 345, 365, 40,  20, 'cat_meat',      'كيلو', 'جزارة البركة العصرية','https://images.unsplash.com/photo-1607623814075-e51df1bdc82f?w=500&q=80'),
  ('prod_sm_20', 'دجاج كوكي مجمد 1.1 كجم',       '6226002', 115, 115, 145, 134, 128, 138, 50,  20, 'cat_meat',      'قطعة', 'شركة أطياب للأغذية', 'https://images.unsplash.com/photo-1587593810167-a84920ea0781?w=500&q=80')
on conflict (id) do update set
  name = excluded.name,
  sale_price = excluded.sale_price,
  purchase_price = excluded.purchase_price,
  stock_quantity = excluded.stock_quantity,
  display_quantity = excluded.display_quantity,
  category_id = excluded.category_id,
  unit = excluded.unit,
  image_url = excluded.image_url;

-- تم. المنتجات والتصنيفات الخاصة بالسوبر ماركت أصبحت جاهزة ومحينة بالكامل.



-- ==========================================================================
-- SOURCE: apply_council_fixes.sql
-- ==========================================================================

-- ============================================================
-- سكريبت إصلاحات أمان ونزاهة البيانات (LLM Council Fixes)
-- HANCES PRO ERP / POS System
-- ============================================================

-- 1. إضافة مفتاح منع تكرار الفواتير الأوفلاين (Idempotency Key)
alter table orders add column if not exists idempotency_key text unique;

-- 2. قيود حماية الأسعار والمخزون من الإدخالات السالبة
alter table products add constraint check_sale_price_positive check (sale_price >= 0);
alter table products add constraint check_purchase_price_positive check (purchase_price >= 0);

-- 3. دالة نقل مخزون ذرية بين المستودع والمعرض (Atomic Stock Transfer)
create or replace function rpc_transfer_warehouse_stock(
  p_product_id uuid,
  p_transfer_qty numeric,
  p_direction text -- 'to_display' (من المستودع للمحل) أو 'to_warehouse' (من المحل للمستودع)
) returns jsonb language plpgsql security definer as $$
declare
  v_prod record;
  v_new_display numeric;
begin
  select * into v_prod from products where id = p_product_id for update;
  if not found then
    return jsonb_build_object('success', false, 'message', 'المنتج غير موجود');
  end if;

  if p_direction = 'to_display' then
    -- التأكد من وجود كمية كافية في المستودع
    if (v_prod.stock_quantity - coalesce(v_prod.display_quantity, 0)) < p_transfer_qty then
      return jsonb_build_object('success', false, 'message', 'الكمية المتاحة بالمستودع غير كافية');
    end if;
    v_new_display := coalesce(v_prod.display_quantity, 0) + p_transfer_qty;
  elsif p_direction = 'to_warehouse' then
    if coalesce(v_prod.display_quantity, 0) < p_transfer_qty then
      return jsonb_build_object('success', false, 'message', 'الكمية المعروضة بالمحل غير كافية');
    end if;
    v_new_display := coalesce(v_prod.display_quantity, 0) - p_transfer_qty;
  else
    return jsonb_build_object('success', false, 'message', 'اتجاه النقل غير صحيح');
  end if;

  update products set display_quantity = v_new_display where id = p_product_id;

  return jsonb_build_object('success', true, 'new_display_quantity', v_new_display);
end;
$$;



-- ==========================================================================
-- SOURCE: create_car_maintenance_schema.sql
-- ==========================================================================

-- إنشاء جدول السيارات / الاشتراكات
CREATE TABLE IF NOT EXISTS public.car_subscriptions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    car_number TEXT NOT NULL,
    car_details TEXT,
    customer_name TEXT,
    customer_phone TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- إنشاء جدول مواعيد الصيانة
CREATE TABLE IF NOT EXISTS public.maintenance_appointments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    subscription_id UUID NOT NULL REFERENCES public.car_subscriptions(id) ON DELETE CASCADE,
    appointment_date DATE NOT NULL,
    description TEXT,
    report TEXT,
    cost NUMERIC DEFAULT 0,
    status TEXT DEFAULT 'pending', -- 'pending' أو 'completed'
    is_reminded BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- تفعيل Realtime للجداول
ALTER PUBLICATION supabase_realtime ADD TABLE car_subscriptions;
ALTER PUBLICATION supabase_realtime ADD TABLE maintenance_appointments;

-- السماح بالصلاحيات (Policies) في حال كان Row Level Security مفعل
ALTER TABLE public.car_subscriptions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.maintenance_appointments ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow all actions for authenticated users on car_subscriptions"
    ON public.car_subscriptions
    FOR ALL
    TO authenticated
    USING (true)
    WITH CHECK (true);

CREATE POLICY "Allow all actions for anon on car_subscriptions"
    ON public.car_subscriptions
    FOR ALL
    TO anon
    USING (true)
    WITH CHECK (true);

CREATE POLICY "Allow all actions for authenticated users on maintenance_appointments"
    ON public.maintenance_appointments
    FOR ALL
    TO authenticated
    USING (true)
    WITH CHECK (true);

CREATE POLICY "Allow all actions for anon on maintenance_appointments"
    ON public.maintenance_appointments
    FOR ALL
    TO anon
    USING (true)
    WITH CHECK (true);



-- ==========================================================================
-- SOURCE: create_cashiers_table.sql
-- ==========================================================================

-- ============================================================
-- Cashier Management Table & Schema Updates
-- Run this in your Supabase SQL Editor
-- ============================================================

-- 1. Create the cashiers table
CREATE TABLE IF NOT EXISTS cashiers (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name TEXT NOT NULL,
  password TEXT,
  phone TEXT,
  photo_url TEXT, -- This will store the base64 image or a URL
  created_at TIMESTAMPTZ DEFAULT now()
);

-- 2. Add cashier_name to orders table to track who made the sale
ALTER TABLE orders ADD COLUMN IF NOT EXISTS cashier_name TEXT;

-- 3. Enable RLS (Row Level Security)
ALTER TABLE cashiers ENABLE ROW LEVEL SECURITY;

-- 4. Create "allow all" policy for cashiers (matching existing patterns)
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies 
        WHERE tablename = 'cashiers' AND policyname = 'allow all'
    ) THEN
        CREATE POLICY "allow all" ON cashiers FOR ALL USING (true) WITH CHECK (true);
    END IF;
END
$$;



-- ==========================================================================
-- SOURCE: create_employees_schema.sql
-- ==========================================================================

-- ============================================================
-- مديول الموظفين - الرواتب والسلف
-- ============================================================

-- جدول الموظفين
create table if not exists employees (
  id uuid default gen_random_uuid() primary key,
  name text not null,
  job_title text,
  working_hours text,
  monthly_salary numeric default 0,
  annual_leave_balance numeric not null default 0,
  hire_date date default current_date,
  is_active boolean not null default true,
  created_at timestamptz default now()
);

-- جدول معاملات الموظفين (رواتب وسلف)
create table if not exists employee_transactions (
  id uuid default gen_random_uuid() primary key,
  employee_id uuid references employees(id) on delete cascade,
  amount numeric not null,
  type text check (type in ('salary', 'advance', 'incentive')),
  payment_method text default 'cash',
  paid_cash numeric default 0,
  paid_visa numeric default 0,
  paid_wallet numeric default 0,
  paid_instapay numeric default 0,
  month text, -- تنسيق YYYY-MM
  note text,
  created_at timestamptz default now()
);

create table if not exists employee_leaves (
  id uuid default gen_random_uuid() primary key,
  employee_id uuid references employees(id) on delete cascade,
  start_date date not null,
  end_date date not null,
  days_count numeric not null default 1,
  leave_type text not null check (leave_type in ('paid', 'unpaid')),
  deduction_amount numeric not null default 0,
  month text,
  note text,
  created_at timestamptz default now()
);

-- تفعيل RLS
alter table employees enable row level security;
alter table employee_transactions enable row level security;
alter table employee_leaves enable row level security;

-- سياسات الوصول (مفتوحة حالياً)
create policy "allow all" on employees for all using (true) with check (true);
create policy "allow all" on employee_transactions for all using (true) with check (true);
create policy "allow all" on employee_leaves for all using (true) with check (true);



-- ==========================================================================
-- SOURCE: fix_expenses_schema.sql
-- ==========================================================================

-- إصلاح جدول المصروفات/الإيرادات (expenses)
-- المشكلة: الكود في useStore.ts (addExpense/updateExpense) بيحاول يحفظ أعمدة
-- غير موجودة في الجدول، فالـ insert بيفشل ولا تُحفظ المعاملة.
-- شغّل هذا السكربت في Supabase SQL Editor.

alter table expenses add column if not exists paid_cash      numeric default 0;
alter table expenses add column if not exists paid_visa      numeric default 0;
alter table expenses add column if not exists paid_wallet    numeric default 0;
alter table expenses add column if not exists paid_instapay  numeric default 0;
alter table expenses add column if not exists payment_method text;
alter table expenses add column if not exists car_id         uuid;

-- التأكد أن RLS تسمح بالإدخال (موجودة في السكيمة الأصلية، لكن للأمان):
alter table expenses enable row level security;
do $$
begin
  if not exists (
    select 1 from pg_policies
    where tablename = 'expenses' and policyname = 'allow all'
  ) then
    create policy "allow all" on expenses for all using (true) with check (true);
  end if;
end $$;



-- ==========================================================================
-- SOURCE: update_car_finance_schema.sql
-- ==========================================================================

-- ربط الإيرادات (المبيعات) بالسيارة
ALTER TABLE public.orders ADD COLUMN IF NOT EXISTS car_id UUID REFERENCES public.car_subscriptions(id) ON DELETE SET NULL;

-- ربط المصروفات بالسيارة
ALTER TABLE public.expenses ADD COLUMN IF NOT EXISTS car_id UUID REFERENCES public.car_subscriptions(id) ON DELETE SET NULL;



-- ==========================================================================
-- SOURCE: update_car_status_schema.sql
-- ==========================================================================

ALTER TABLE public.car_subscriptions ADD COLUMN IF NOT EXISTS status TEXT DEFAULT 'active';



-- ==========================================================================
-- SOURCE: update_car_subscriptions_schema_v2.sql
-- ==========================================================================

ALTER TABLE public.car_subscriptions ADD COLUMN IF NOT EXISTS subscription_duration_months INTEGER;
ALTER TABLE public.car_subscriptions ADD COLUMN IF NOT EXISTS subscription_frequency_days INTEGER;



-- ==========================================================================
-- SOURCE: update_deleted_invoices_schema.sql
-- ==========================================================================

-- Add soft-delete fields for sales invoices.
-- Run this once in Supabase SQL Editor before deleting invoices from the app.

alter table orders add column if not exists is_deleted boolean not null default false;
alter table orders add column if not exists deleted_at timestamptz;
alter table orders add column if not exists deletion_reason text;

create index if not exists idx_orders_is_deleted on orders(is_deleted);
create index if not exists idx_orders_deleted_at on orders(deleted_at);



-- ==========================================================================
-- SOURCE: update_employee_leaves_schema.sql
-- ==========================================================================

-- Add employee leave balances, leave log, and incentives.
-- Run this once in Supabase SQL Editor before using employee vacations.

alter table employees add column if not exists annual_leave_balance numeric not null default 0;
alter table employees add column if not exists hire_date date default current_date;

alter table employee_transactions drop constraint if exists employee_transactions_type_check;
alter table employee_transactions
  add constraint employee_transactions_type_check
  check (type in ('salary', 'advance', 'incentive'));

create table if not exists employee_leaves (
  id uuid default gen_random_uuid() primary key,
  employee_id uuid references employees(id) on delete cascade,
  start_date date not null,
  end_date date not null,
  days_count numeric not null default 1,
  leave_type text not null check (leave_type in ('paid', 'unpaid')),
  deduction_amount numeric not null default 0,
  month text,
  note text,
  created_at timestamptz default now()
);

create index if not exists idx_employee_leaves_employee_id on employee_leaves(employee_id);
create index if not exists idx_employee_leaves_month on employee_leaves(month);
create index if not exists idx_employee_leaves_start_date on employee_leaves(start_date);

alter table employee_leaves enable row level security;

drop policy if exists "allow all" on employee_leaves;
create policy "allow all" on employee_leaves for all using (true) with check (true);



-- ==========================================================================
-- SOURCE: update_employee_status_schema.sql
-- ==========================================================================

-- Add active/inactive status for employees.
-- Run this once in Supabase SQL Editor before using employee status filters.

alter table employees add column if not exists is_active boolean not null default true;

create index if not exists idx_employees_is_active on employees(is_active);



-- ==========================================================================
-- SOURCE: update_employees_deductions.sql
-- ==========================================================================

-- إضافة حقل الخصومات لجدول معاملات الموظفين
alter table employee_transactions add column if not exists deductions numeric default 0;



-- ==========================================================================
-- SOURCE: update_employees_phone.sql
-- ==========================================================================

-- إضافة رقم الهاتف لجدول الموظفين
alter table employees add column if not exists phone text;



-- ==========================================================================
-- SOURCE: update_finance_schema.sql
-- ==========================================================================

-- ============================================================
-- تحديث نظام الخزينة والميزانية اليومية
-- ============================================================

-- 1. إضافة طريقة الدفع للجداول الأساسية
alter table orders add column if not exists payment_method text default 'cash';
alter table expenses add column if not exists payment_method text default 'cash';
alter table purchase_invoices add column if not exists payment_method text default 'cash';

-- 2. إضافة رصيد البداية للنظام في الإعدادات
alter table store_settings add column if not exists initial_balance numeric default 0;



-- ==========================================================================
-- SOURCE: update_financing_schema.sql
-- ==========================================================================

-- ============================================================
-- Financing module: loans and associations
-- Run once in Supabase SQL Editor.
-- ============================================================

create table if not exists financing_accounts (
  id uuid default gen_random_uuid() primary key,
  type text not null default 'loan',
  lender_name text not null,
  lender_phone text default '',
  lender_details text default '',
  description text default '',
  principal_amount numeric not null default 0,
  collection_amount numeric not null default 0,
  collection_date date not null,
  installment_count integer not null default 1,
  status text not null default 'open',
  created_at timestamptz default now()
);

create table if not exists financing_payments (
  id uuid default gen_random_uuid() primary key,
  account_id uuid references financing_accounts(id) on delete cascade,
  payment_type text not null,
  due_date date not null,
  amount numeric not null default 0,
  paid_amount numeric not null default 0,
  remaining_amount numeric not null default 0,
  status text not null default 'pending',
  paid_at timestamptz,
  expense_id uuid references expenses(id) on delete set null,
  note text,
  created_at timestamptz default now()
);

create table if not exists financing_transactions (
  id uuid default gen_random_uuid() primary key,
  account_id uuid references financing_accounts(id) on delete cascade,
  payment_id uuid references financing_payments(id) on delete cascade,
  transaction_type text not null,
  amount numeric not null default 0,
  remaining_after numeric not null default 0,
  payment_method text not null default 'cash',
  expense_id uuid references expenses(id) on delete set null,
  note text,
  created_at timestamptz default now()
);

alter table financing_payments add column if not exists paid_amount numeric not null default 0;
alter table financing_payments add column if not exists remaining_amount numeric not null default 0;

update financing_payments
set remaining_amount = greatest(0, amount - coalesce(paid_amount, 0))
where remaining_amount = 0 and status <> 'paid';

alter table financing_accounts enable row level security;
alter table financing_payments enable row level security;
alter table financing_transactions enable row level security;

do $$
begin
  if not exists (
    select 1 from pg_policies
    where schemaname = 'public'
      and tablename = 'financing_accounts'
      and policyname = 'allow all'
  ) then
    create policy "allow all" on financing_accounts for all using (true) with check (true);
  end if;

  if not exists (
    select 1 from pg_policies
    where schemaname = 'public'
      and tablename = 'financing_payments'
      and policyname = 'allow all'
  ) then
    create policy "allow all" on financing_payments for all using (true) with check (true);
  end if;

  if not exists (
    select 1 from pg_policies
    where schemaname = 'public'
      and tablename = 'financing_transactions'
      and policyname = 'allow all'
  ) then
    create policy "allow all" on financing_transactions for all using (true) with check (true);
  end if;
end $$;



-- ==========================================================================
-- SOURCE: update_refunded_amount_schema.sql
-- ==========================================================================

-- Add the actual refunded cash amount per returned invoice item.
-- Run this once in Supabase SQL Editor if older databases only have returned_quantity.

alter table order_items
add column if not exists refunded_amount numeric default 0;

update order_items
set refunded_amount = 0
where refunded_amount is null;

