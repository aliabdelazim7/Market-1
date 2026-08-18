-- RESET_DATABASE_NOW.sql
-- تصفير قاعدة بيانات عميل جديد.
-- يحذف البيانات من كل جداول public الموجودة فعليًا فقط.
-- يحافظ على schema والجداول والـ functions والـ views والـ policies.
-- يعيد sequences إلى البداية ويتعامل مع الـ foreign keys.
-- لا يحتوي على DROP TABLE أو DROP SCHEMA أو مراجع لجداول ثابتة.

begin;

do $$
declare
  r record;
  v_count integer := 0;
begin
  for r in
    select table_schema, table_name
    from information_schema.tables
    where table_schema = 'public'
      and table_type = 'BASE TABLE'
      and table_name <> 'spatial_ref_sys'
    order by table_name
  loop
    execute format(
      'truncate table %I.%I restart identity cascade',
      r.table_schema,
      r.table_name
    );
    v_count := v_count + 1;
  end loop;

  raise notice 'تم تصفير % جدول من جداول public بنجاح.', v_count;
end $$;

commit;

-- تحقق عام لا يعتمد على أسماء جداول معينة.
select
  count(*)::integer as public_tables_count
from information_schema.tables
where table_schema = 'public'
  and table_type = 'BASE TABLE'
  and table_name <> 'spatial_ref_sys';
