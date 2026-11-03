-- EAMIN TOP-UP: Supabase database foundation
-- Run this file in Supabase SQL Editor. Never put the service_role key in website code.

create extension if not exists pgcrypto;

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  full_name text,
  phone text,
  role text not null default 'customer' check (role in ('customer','admin')),
  created_at timestamptz not null default now()
);

create table if not exists public.products (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  category text not null default 'Free Fire',
  description text,
  package_label text not null,
  price_bdt numeric(10,2) not null check (price_bdt >= 0),
  active boolean not null default true,
  sort_order integer not null default 0,
  created_at timestamptz not null default now()
);

create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete restrict,
  product_id uuid references public.products(id) on delete set null,
  product_name text not null,
  package_label text not null,
  player_uid text not null,
  player_name text,
  customer_phone text not null,
  amount_bdt numeric(10,2) not null default 0 check (amount_bdt >= 0),
  payment_method text not null check (payment_method in ('bKash','Nagad')),
  transaction_id text not null,
  status text not null default 'pending' check (status in ('pending','processing','completed','rejected')),
  admin_note text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.wallet_requests (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete restrict,
  amount_bdt numeric(10,2) not null check (amount_bdt > 0),
  payment_method text not null check (payment_method in ('bKash','Nagad')),
  transaction_id text not null,
  status text not null default 'pending' check (status in ('pending','approved','rejected')),
  admin_note text,
  created_at timestamptz not null default now()
);

create table if not exists public.wallet_ledger (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete restrict,
  amount_bdt numeric(10,2) not null,
  entry_type text not null check (entry_type in ('credit','debit','refund','adjustment')),
  reference_id uuid,
  note text,
  created_at timestamptz not null default now()
);

create table if not exists public.topup_codes (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete restrict,
  code text not null,
  description text,
  redeemed boolean not null default false,
  created_at timestamptz not null default now()
);

create or replace function public.is_admin()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1 from public.profiles
    where id = auth.uid() and role = 'admin'
  );
$$;

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.profiles (id, full_name, phone)
  values (new.id, coalesce(new.raw_user_meta_data->>'full_name',''), coalesce(new.raw_user_meta_data->>'phone',''))
  on conflict (id) do nothing;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created_eamin on auth.users;
create trigger on_auth_user_created_eamin
after insert on auth.users
for each row execute procedure public.handle_new_user();

alter table public.profiles enable row level security;
alter table public.products enable row level security;
alter table public.orders enable row level security;
alter table public.wallet_requests enable row level security;
alter table public.wallet_ledger enable row level security;
alter table public.topup_codes enable row level security;

drop policy if exists "profile read own or admin" on public.profiles;
create policy "profile read own or admin" on public.profiles for select to authenticated
using (id = auth.uid() or public.is_admin());

drop policy if exists "profile update safe fields" on public.profiles;
revoke update on public.profiles from authenticated;
grant update (full_name, phone) on public.profiles to authenticated;
create policy "profile update safe fields" on public.profiles for update to authenticated
using (id = auth.uid() or public.is_admin())
with check (id = auth.uid() or public.is_admin());

drop policy if exists "products public read active" on public.products;
create policy "products public read active" on public.products for select
using (active = true or public.is_admin());
drop policy if exists "products admin manage" on public.products;
create policy "products admin manage" on public.products for all to authenticated
using (public.is_admin()) with check (public.is_admin());

drop policy if exists "orders own or admin read" on public.orders;
create policy "orders own or admin read" on public.orders for select to authenticated
using (user_id = auth.uid() or public.is_admin());
drop policy if exists "orders customer create" on public.orders;
create policy "orders customer create" on public.orders for insert to authenticated
with check (user_id = auth.uid() and status = 'pending');
drop policy if exists "orders admin update" on public.orders;
create policy "orders admin update" on public.orders for update to authenticated
using (public.is_admin()) with check (public.is_admin());

drop policy if exists "wallet requests own or admin read" on public.wallet_requests;
create policy "wallet requests own or admin read" on public.wallet_requests for select to authenticated
using (user_id = auth.uid() or public.is_admin());
drop policy if exists "wallet requests customer create" on public.wallet_requests;
create policy "wallet requests customer create" on public.wallet_requests for insert to authenticated
with check (user_id = auth.uid() and status = 'pending');
drop policy if exists "wallet requests admin update" on public.wallet_requests;
create policy "wallet requests admin update" on public.wallet_requests for update to authenticated
using (public.is_admin()) with check (public.is_admin());

drop policy if exists "wallet ledger own or admin read" on public.wallet_ledger;
create policy "wallet ledger own or admin read" on public.wallet_ledger for select to authenticated
using (user_id = auth.uid() or public.is_admin());
drop policy if exists "wallet ledger admin manage" on public.wallet_ledger;
create policy "wallet ledger admin manage" on public.wallet_ledger for all to authenticated
using (public.is_admin()) with check (public.is_admin());

drop policy if exists "codes own or admin read" on public.topup_codes;
create policy "codes own or admin read" on public.topup_codes for select to authenticated
using (user_id = auth.uid() or public.is_admin());
drop policy if exists "codes admin manage" on public.topup_codes;
create policy "codes admin manage" on public.topup_codes for all to authenticated
using (public.is_admin()) with check (public.is_admin());

grant usage on schema public to anon, authenticated;
grant select on public.products to anon, authenticated;
grant select, insert on public.orders to authenticated;
grant update (status, admin_note, updated_at) on public.orders to authenticated;
grant select, insert on public.wallet_requests to authenticated;
grant update (status, admin_note) on public.wallet_requests to authenticated;
grant select on public.wallet_ledger, public.topup_codes to authenticated;
grant insert, update, delete on public.products, public.wallet_ledger, public.topup_codes to authenticated;
grant select, update (full_name, phone) on public.profiles to authenticated;

-- After creating your own account, promote ONLY that account to admin:
-- update public.profiles set role = 'admin' where id = 'YOUR_AUTH_USER_UUID';
