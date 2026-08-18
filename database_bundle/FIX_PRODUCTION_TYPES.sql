-- إصلاح تعارض أنواع production_orders / production_materials
-- production_orders.id و materials.id في هذا المشروع من نوع text.
-- شغّل هذا الملف وحده ثم أعد تشغيل الحزمة المصححة.
-- لا يحذف بيانات.

create table if not exists public.production_orders (
  id text primary key default gen_random_uuid()::text,
  created_at timestamptz default now()
);

create table if not exists public.materials (
  id text primary key default gen_random_uuid()::text,
  created_at timestamptz default now()
);

create table if not exists public.production_materials (
  id text primary key default gen_random_uuid()::text,
  production_id text,
  material_id text,
  material_name text,
  quantity numeric not null default 0,
  cost numeric not null default 0,
  created_at timestamptz default now()
);

-- لو كان الجدول موجودًا من محاولة سابقة بنوع uuid، وحّده إلى text.
do $$
begin
  if exists (
    select 1 from information_schema.columns
    where table_schema = 'public' and table_name = 'production_materials'
      and column_name = 'production_id' and data_type = 'uuid'
  ) then
    alter table public.production_materials
      drop constraint if exists production_materials_production_id_fkey;
    alter table public.production_materials
      alter column production_id type text using production_id::text;
  end if;

  if exists (
    select 1 from information_schema.columns
    where table_schema = 'public' and table_name = 'production_materials'
      and column_name = 'material_id' and data_type = 'uuid'
  ) then
    alter table public.production_materials
      drop constraint if exists production_materials_material_id_fkey;
    alter table public.production_materials
      alter column material_id type text using material_id::text;
  end if;
end $$;

alter table public.production_materials
  drop constraint if exists production_materials_production_id_fkey;
alter table public.production_materials
  add constraint production_materials_production_id_fkey
  foreign key (production_id) references public.production_orders(id) on delete cascade;

alter table public.production_materials
  drop constraint if exists production_materials_material_id_fkey;
alter table public.production_materials
  add constraint production_materials_material_id_fkey
  foreign key (material_id) references public.materials(id) on delete set null;

select
  table_name,
  column_name,
  data_type
from information_schema.columns
where table_schema = 'public'
  and table_name in ('production_orders', 'production_materials', 'materials')
  and column_name in ('id', 'production_id', 'material_id')
order by table_name, column_name;
