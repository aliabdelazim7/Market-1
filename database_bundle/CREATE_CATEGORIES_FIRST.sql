-- إصلاح البداية: إنشاء جدول categories إذا لم يكن موجودًا
-- شغّل هذا الملف وحده أولًا في Supabase SQL Editor.
-- لا يحذف أو يفرغ أي بيانات.

create extension if not exists pgcrypto;

create table if not exists public.categories (
  id text primary key default gen_random_uuid()::text,
  created_at timestamptz default now(),
  name text not null,
  image_url text
);

alter table public.categories
  alter column id set default gen_random_uuid()::text;

alter table public.categories enable row level security;

drop policy if exists "allow_all_anon_authenticated" on public.categories;
create policy "allow_all_anon_authenticated"
on public.categories
for all
to anon, authenticated
using (true)
with check (true);

grant all on table public.categories to anon, authenticated;

insert into public.categories (id, name)
select gen_random_uuid()::text, v.name
from (values
  ('رجالي'),
  ('حريمي'),
  ('أطفالي'),
  ('أحذية'),
  ('شنط وإكسسوارات'),
  ('ملابس داخلية'),
  ('ملابس رياضية'),
  ('شتوي وجاكيتات')
) as v(name)
where not exists (
  select 1 from public.categories c where c.name = v.name
);

select id, created_at, name, image_url
from public.categories
order by created_at;
