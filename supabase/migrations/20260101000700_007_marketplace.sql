create table if not exists public.marketplace_categories (
    id uuid primary key default gen_random_uuid(),
    name text not null,
    slug text not null unique,
    description text,
    icon_url text,
    display_order integer not null default 0,
    is_active boolean not null default true
);

create table if not exists public.products (
    id uuid primary key default gen_random_uuid(),
    seller_id uuid not null references public.users(id) on delete cascade,
    category_id uuid not null references public.marketplace_categories(id) on delete restrict,
    name text not null,
    description text,
    price_idr integer not null default 0,
    stock integer not null default 0,
    unit text,
    wa_number text,
    wa_template text,
    avg_rating numeric(3,2),
    is_active boolean not null default true,
    created_at timestamptz not null default timezone('utc', now()),
    updated_at timestamptz not null default timezone('utc', now())
);

create table if not exists public.product_images (
    id uuid primary key default gen_random_uuid(),
    product_id uuid not null references public.products(id) on delete cascade,
    image_url text not null,
    storage_path text,
    display_order integer not null default 0,
    created_at timestamptz not null default timezone('utc', now())
);

create table if not exists public.product_reviews (
    id uuid primary key default gen_random_uuid(),
    product_id uuid not null references public.products(id) on delete cascade,
    user_id uuid not null references public.users(id) on delete cascade,
    rating integer not null,
    body text,
    created_at timestamptz not null default timezone('utc', now())
);

create table if not exists public.whatsapp_order_logs (
    id uuid primary key default gen_random_uuid(),
    user_id uuid not null references public.users(id) on delete cascade,
    product_id uuid not null references public.products(id) on delete cascade,
    seller_id uuid not null references public.users(id) on delete cascade,
    template_message text,
    clicked_at timestamptz not null default timezone('utc', now())
);

create index if not exists idx_products_seller_id on public.products(seller_id);
create index if not exists idx_products_category_id on public.products(category_id);
create index if not exists idx_product_images_product_id on public.product_images(product_id);
create index if not exists idx_product_reviews_product_id on public.product_reviews(product_id);
create index if not exists idx_product_reviews_user_id on public.product_reviews(user_id);
create index if not exists idx_whatsapp_order_logs_user_id on public.whatsapp_order_logs(user_id);
create index if not exists idx_whatsapp_order_logs_product_id on public.whatsapp_order_logs(product_id);
create index if not exists idx_whatsapp_order_logs_seller_id on public.whatsapp_order_logs(seller_id);

drop trigger if exists trg_products_set_updated_at on public.products;
create trigger trg_products_set_updated_at
before update on public.products
for each row
execute function public.set_updated_at();
