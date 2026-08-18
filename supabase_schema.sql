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
alter table products add column if not exists alert_threshold numeric default 5;
alter table products add column if not exists is_hidden boolean default false;
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

-- 4. إخلاء المنتجات والتصنيفات القديمة وتأسيس تصنيفات السوبر ماركت
delete from order_items;
delete from products;
delete from categories;

insert into categories (id, name, image_url) values
  ('cat_dairy',    'ألبان ومجمدات',   'https://images.unsplash.com/photo-1628088062854-d1870b4553da?w=500&q=80'),
  ('cat_dry',      'بقالة جافة',     'https://images.unsplash.com/photo-1586201375761-83865001e31c?w=500&q=80'),
  ('cat_beverages','مشروبات وحلويات', 'https://images.unsplash.com/photo-1527960471264-932f39eb5846?w=500&q=80'),
  ('cat_cleaning', 'منظفات ورقيات',  'https://images.unsplash.com/photo-1585421514738-01798e348b17?w=500&q=80'),
  ('cat_produce',  'خضار وفواكه',    'https://images.unsplash.com/photo-1610832958506-aa56368176cf?w=500&q=80'),
  ('cat_meat',     'لحوم وأسماك',    'https://images.unsplash.com/photo-1607623814075-e51df1bdc82f?w=500&q=80')
on conflict (id) do update set name = excluded.name;

-- 5. منتجات الديمو للسوبر ماركت
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
  ('pur_102', 'PINV-502', 'sup_2', 8400,  8400,  8400,  'cash', 'توريد تشكيلة شنط ومحافظ جلد', now())
on conflict (id) do nothing;

insert into purchase_items (id, invoice_id, product_id, quantity, purchase_price, to_display) values
  ('pitem_101', 'pur_101', 'prod_1', 5, 1800, 5),
  ('pitem_102', 'pur_102', 'prod_6', 4, 950, 4)
on conflict (id) do nothing;

-- -----------------------------------------------------------------------------
-- تم إعداد وتعبئة قاعدة البيانات بنجاح بكافة بيانات المبيعات والمصروفات والديمو!
-- -----------------------------------------------------------------------------
