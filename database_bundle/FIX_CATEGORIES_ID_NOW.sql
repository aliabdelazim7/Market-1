-- إصلاح مباشر لمشكلة categories.id
-- شغّل هذا الملف وحده أولًا. لا يحذف أي بيانات.
create extension if not exists pgcrypto;

do $$
declare
  id_type text;
  id_default text;
begin
  select c.data_type, c.column_default
    into id_type, id_default
  from information_schema.columns c
  where c.table_schema = 'public'
    and c.table_name = 'categories'
    and c.column_name = 'id';

  if id_type is null then
    raise exception 'جدول public.categories غير موجود';
  end if;

  if id_type = 'uuid' then
    execute 'alter table public.categories alter column id set default gen_random_uuid()';
  else
    execute 'alter table public.categories alter column id set default gen_random_uuid()::text';
  end if;
end $$;

-- تحقق نهائي: هذا الاستعلام يجب أن يعرض Default غير NULL.
select table_schema, table_name, column_name, data_type, column_default
from information_schema.columns
where table_schema = 'public'
  and table_name = 'categories'
  and column_name = 'id';
