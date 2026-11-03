-- EAMIN TOP-UP: safe wallet approval function
create or replace function public.admin_approve_wallet_request(request_id uuid)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  req public.wallet_requests%rowtype;
begin
  if not public.is_admin() then
    raise exception 'admin access required';
  end if;

  select * into req
  from public.wallet_requests
  where id = request_id
  for update;

  if not found then
    raise exception 'wallet request not found';
  end if;
  if req.status <> 'pending' then
    raise exception 'wallet request already processed';
  end if;

  update public.wallet_requests
  set status = 'approved'
  where id = request_id;

  insert into public.wallet_ledger(user_id, amount_bdt, entry_type, reference_id, note)
  values(req.user_id, req.amount_bdt, 'credit', req.id, 'Approved Add Money request');
end;
$$;

revoke all on function public.admin_approve_wallet_request(uuid) from public;
grant execute on function public.admin_approve_wallet_request(uuid) to authenticated;
