alter table public.marketplace_categories enable row level security;
alter table public.products enable row level security;
alter table public.product_images enable row level security;
alter table public.product_reviews enable row level security;
alter table public.whatsapp_order_logs enable row level security;

drop policy if exists "public read marketplace_categories" on public.marketplace_categories;
create policy "public read marketplace_categories"
on public.marketplace_categories
for select
using (is_active = true);

drop policy if exists "public read products" on public.products;
create policy "public read products"
on public.products
for select
using (is_active = true);
