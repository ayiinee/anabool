alter table public.meowpoints_ledger enable row level security;
alter table public.vouchers enable row level security;
alter table public.user_vouchers enable row level security;
alter table public.impact_events enable row level security;
alter table public.impact_summaries enable row level security;

drop policy if exists "public read vouchers" on public.vouchers;
create policy "public read vouchers"
on public.vouchers
for select
using (is_active = true);
