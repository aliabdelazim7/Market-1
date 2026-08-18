from pathlib import Path

src = Path('/home/ubuntu/Market-1/database_bundle/DATABASE_ALL_IN_ONE_DEBUGGED.sql')
dst = Path('/home/ubuntu/Market-1/database_bundle/DATABASE_ALL_IN_ONE_DEBUGGED2.sql')
text = src.read_text(encoding='utf-8')
marker = "-- SOURCE: db/40_attendance_self_service.sql"
if marker not in text:
    raise SystemExit('attendance source marker not found')

migration = r'''
-- ============================================================================
-- EMPLOYEE TYPE RECONCILIATION
-- The master schema stores employee IDs as text. Attendance functions also
-- require date/time columns with their native PostgreSQL types.
-- This migration preserves values and does not delete rows.
-- ============================================================================

do $$
begin
  if exists (select 1 from information_schema.columns where table_schema='public' and table_name='employee_attendance' and column_name='date' and data_type='text') then
    alter table public.employee_attendance alter column date type date using nullif(trim(date), '')::date;
  end if;
  if exists (select 1 from information_schema.columns where table_schema='public' and table_name='employee_attendance' and column_name='check_in' and data_type='text') then
    alter table public.employee_attendance alter column check_in type timestamptz using nullif(trim(check_in), '')::timestamptz;
  end if;
  if exists (select 1 from information_schema.columns where table_schema='public' and table_name='employee_attendance' and column_name='check_out' and data_type='text') then
    alter table public.employee_attendance alter column check_out type timestamptz using nullif(trim(check_out), '')::timestamptz;
  end if;
  if exists (select 1 from information_schema.columns where table_schema='public' and table_name='employee_attendance' and column_name='shift_start' and data_type='text') then
    alter table public.employee_attendance alter column shift_start type time using nullif(trim(shift_start), '')::time;
  end if;
  if exists (select 1 from information_schema.columns where table_schema='public' and table_name='employee_leaves' and column_name='start_date' and data_type='text') then
    alter table public.employee_leaves alter column start_date type date using nullif(trim(start_date), '')::date;
  end if;
  if exists (select 1 from information_schema.columns where table_schema='public' and table_name='employee_leaves' and column_name='end_date' and data_type='text') then
    alter table public.employee_leaves alter column end_date type date using nullif(trim(end_date), '')::date;
  end if;
  if exists (select 1 from information_schema.columns where table_schema='public' and table_name='employees' and column_name='hire_date' and data_type='text') then
    alter table public.employees alter column hire_date type date using nullif(trim(hire_date), '')::date;
  end if;
  foreach -- no-op marker
  in array array[]::text[] loop
  end loop;
end $$;

'''
# Remove the harmless-looking but invalid placeholder loop before writing.
migration = migration.replace("  foreach -- no-op marker\n  in array array[]::text[] loop\n  end loop;\n", "")
text = text.replace(marker, migration + marker, 1)
dst.write_text(text, encoding='utf-8')
print(dst)
print('migration inserted:', text.count('EMPLOYEE TYPE RECONCILIATION'))
print('bytes:', dst.stat().st_size)
