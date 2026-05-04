alter table public.waste_classes enable row level security;
alter table public.scan_sessions enable row level security;
alter table public.scan_detections enable row level security;

drop policy if exists "public read waste_classes" on public.waste_classes;
create policy "public read waste_classes"
on public.waste_classes
for select
using (true);
