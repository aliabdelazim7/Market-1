-- Run this only if the previous bundle stopped at car_subscriptions.
create table if not exists public.car_subscriptions (
  id text primary key,
  created_at timestamptz default now(),
  car_number text,
  car_details text,
  customer_name text,
  customer_phone text,
  status text default 'active',
  subscription_duration_months numeric default 0,
  subscription_frequency_days numeric default 0
);
