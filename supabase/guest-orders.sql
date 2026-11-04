-- EAMIN TOP-UP guest checkout tables. Run after supabase/schema.sql.
create table if not exists public.guest_orders (
  id uuid primary key default gen_random_uuid(),
  order_code text not null unique,
  product_name text not null,
  package_label text not null,
  player_uid text not null,
  player_name text,
  customer_phone text not null,
  amount_bdt numeric(10,2) not null check (amount_bdt >= 0),
  payment_method text not null check (payment_method in ('bKash','Nagad')),
  transaction_id text not null,
  status text not null default 'pending' check (status in ('pending','processing','completed','rejected')),
  admin_note text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create unique index if not exists guest_orders_payment_trx_unique
on public.guest_orders(payment_method, transaction_id);

create table if not exists public.guest_wallet_requests (
  id uuid primary key default gen_random_uuid(),
  request_code text not null unique,
  amount_bdt numeric(10,2) not null check (amount_bdt > 0),
  payment_method text not null check (payment_method in ('bKash','Nagad')),
  transaction_id text not null,
  customer_phone text,
  status text not null default 'pending' check (status in ('pending','approved','rejected')),
  admin_note text,
  created_at timestamptz not null default now()
);
create unique index if not exists guest_wallet_payment_trx_unique
on public.guest_wallet_requests(payment_method, transaction_id);

alter table public.guest_orders enable row level security;
alter table public.guest_wallet_requests enable row level security;

drop policy if exists "guest order public submit" on public.guest_orders;
create policy "guest order public submit" on public.guest_orders for insert to anon, authenticated
with check (status = 'pending' and amount_bdt >= 0
  and length(player_uid) between 5 and 15
  and customer_phone ~ '^01[0-9]{9}$'
  and length(transaction_id) between 4 and 100);
drop policy if exists "guest order admin read" on public.guest_orders;
create policy "guest order admin read" on public.guest_orders for select to authenticated
using (public.is_admin());
drop policy if exists "guest order admin update" on public.guest_orders;
create policy "guest order admin update" on public.guest_orders for update to authenticated
using (public.is_admin()) with check (public.is_admin());

drop policy if exists "guest wallet public submit" on public.guest_wallet_requests;
create policy "guest wallet public submit" on public.guest_wallet_requests for insert to anon, authenticated
with check (status = 'pending' and amount_bdt > 0 and length(transaction_id) between 4 and 100);
drop policy if exists "guest wallet admin read" on public.guest_wallet_requests;
create policy "guest wallet admin read" on public.guest_wallet_requests for select to authenticated
using (public.is_admin());
drop policy if exists "guest wallet admin update" on public.guest_wallet_requests;
create policy "guest wallet admin update" on public.guest_wallet_requests for update to authenticated
using (public.is_admin()) with check (public.is_admin());

grant insert on public.guest_orders, public.guest_wallet_requests to anon, authenticated;
grant select, update on public.guest_orders, public.guest_wallet_requests to authenticated;


-- Safe one-time wallet approval for registered customers.
create or replace function public.admin_approve_wallet_request(request_id uuid)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare req public.wallet_requests%rowtype;
begin
  if not public.is_admin() then raise exception 'admin access required'; end if;
  select * into req from public.wallet_requests where id = request_id for update;
  if not found then raise exception 'wallet request not found'; end if;
  if req.status <> 'pending' then raise exception 'wallet request already processed'; end if;
  update public.wallet_requests set status = 'approved' where id = request_id;
  insert into public.wallet_ledger(user_id, amount_bdt, entry_type, reference_id, note)
  values(req.user_id, req.amount_bdt, 'credit', req.id, 'Approved Add Money request');
end;
$$;
revoke all on function public.admin_approve_wallet_request(uuid) from public;
grant execute on function public.admin_approve_wallet_request(uuid) to authenticated;
