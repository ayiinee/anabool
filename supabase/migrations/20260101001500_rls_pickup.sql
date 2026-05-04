alter table public.couriers enable row level security;
alter table public.courier_locations enable row level security;
alter table public.pickup_packages enable row level security;
alter table public.pickup_orders enable row level security;
alter table public.pickup_status_logs enable row level security;

drop policy if exists "public read pickup_packages" on public.pickup_packages;
create policy "public read pickup_packages"
on public.pickup_packages
for select
using (is_active = true);
