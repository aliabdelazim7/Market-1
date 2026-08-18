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
