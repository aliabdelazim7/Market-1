-- RESET_DATABASE_FOR_NEW_CLIENT.sql
-- هذا الملف يحذف كل البيانات من جداول public فقط.
-- يحافظ على الجداول والـ schema والـ functions والـ views والـ policies.
-- RESTART IDENTITY يعيد العدادات إلى البداية.
-- CASCADE يتعامل مع العلاقات بين الجداول.
-- لا تشغّله على قاعدة تحتوي على بيانات مهمة.

begin;

do $$
declare
  r record;
begin
  for r in
    select table_schema, table_name
    from information_schema.tables
    where table_schema = 'public'
      and table_type = 'BASE TABLE'
      and table_name not in ('spatial_ref_sys')
  loop
    execute format(
      'truncate table %I.%I restart identity cascade',
      r.table_schema,
      r.table_name
    );
  end loop;
end $$;

commit;

-- تحقق: يجب أن يعرض هذا الاستعلام عدد الصفوف الحالية في الجداول الرئيسية.
select
  'categories' as table_name, count(*) as rows_count from public.categories
union all
select 'products', count(*) from public.products
union all
select 'customers', count(*) from public.customers
union all
select 'employees', count(*) from public.employees
union all
select 'orders', count(*) from public.orders;
