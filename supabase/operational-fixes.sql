-- EAMIN TOP-UP operational fixes: guest order tracking + duplicate TrxID protection.
-- Run once in Supabase Dashboard > SQL Editor.

create unique index if not exists orders_payment_trx_unique
on public.orders(payment_method, transaction_id);

create unique index if not exists wallet_requests_payment_trx_unique
on public.wallet_requests(payment_method, transaction_id);

create or replace function public.lookup_guest_order(
  p_order_code text,
  p_customer_phone text
)
returns table (
  order_code text,
  product_name text,
  package_label text,
  amount_bdt numeric,
  status text,
  created_at timestamptz
)
language sql
stable
security definer
set search_path = public
as $$
  select g.order_code, g.product_name, g.package_label, g.amount_bdt, g.status, g.created_at
  from public.guest_orders g
  where g.order_code = p_order_code
    and g.customer_phone = p_customer_phone
  limit 1;
$$;

revoke all on function public.lookup_guest_order(text, text) from public;
grant execute on function public.lookup_guest_order(text, text) to anon, authenticated;
