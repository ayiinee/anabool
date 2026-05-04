create table if not exists public.couriers (
    id uuid primary key default gen_random_uuid(),
    user_id uuid not null references public.users(id) on delete cascade,
    vehicle_type text not null,
    plate_number text,
    is_available boolean not null default false,
    rating numeric(3,2),
    created_at timestamptz not null default timezone('utc', now()),
    updated_at timestamptz not null default timezone('utc', now())
);

create table if not exists public.courier_locations (
    id uuid primary key default gen_random_uuid(),
    courier_id uuid not null references public.couriers(id) on delete cascade,
    current_lat numeric(10,6) not null,
    current_lng numeric(10,6) not null,
    heading numeric(6,2),
    speed numeric(8,2),
    updated_at timestamptz not null default timezone('utc', now())
);

create table if not exists public.pickup_packages (
    id uuid primary key default gen_random_uuid(),
    name text not null,
    description text not null,
    pickup_type text not null,
    price_idr integer not null default 0,
    weight_limit_g integer,
    meowpoints_bonus integer not null default 0,
    is_active boolean not null default true,
    created_at timestamptz not null default timezone('utc', now()),
    unique (name, pickup_type)
);

create table if not exists public.pickup_orders (
    id uuid primary key default gen_random_uuid(),
    user_id uuid not null references public.users(id) on delete cascade,
    courier_id uuid references public.couriers(id) on delete set null,
    package_id uuid not null references public.pickup_packages(id) on delete restrict,
    address_id uuid not null references public.user_addresses(id) on delete restrict,
    scan_session_id uuid references public.scan_sessions(id) on delete set null,
    pickup_type text not null,
    status text not null,
    scheduled_at timestamptz,
    pickup_lat numeric(10,6),
    pickup_lng numeric(10,6),
    estimated_weight_g integer,
    actual_weight_g integer,
    notes text,
    meowpoints_earned integer not null default 0,
    created_at timestamptz not null default timezone('utc', now()),
    updated_at timestamptz not null default timezone('utc', now())
);

create table if not exists public.pickup_status_logs (
    id uuid primary key default gen_random_uuid(),
    pickup_order_id uuid not null references public.pickup_orders(id) on delete cascade,
    status text not null,
    note text,
    created_at timestamptz not null default timezone('utc', now())
);

create index if not exists idx_couriers_user_id on public.couriers(user_id);
create index if not exists idx_courier_locations_courier_id on public.courier_locations(courier_id);
create index if not exists idx_pickup_orders_user_id on public.pickup_orders(user_id);
create index if not exists idx_pickup_orders_courier_id on public.pickup_orders(courier_id);
create index if not exists idx_pickup_orders_package_id on public.pickup_orders(package_id);
create index if not exists idx_pickup_orders_address_id on public.pickup_orders(address_id);
create index if not exists idx_pickup_orders_scan_session_id on public.pickup_orders(scan_session_id);
create index if not exists idx_pickup_orders_status on public.pickup_orders(status);
create index if not exists idx_pickup_status_logs_pickup_order_id on public.pickup_status_logs(pickup_order_id);

drop trigger if exists trg_couriers_set_updated_at on public.couriers;
create trigger trg_couriers_set_updated_at
before update on public.couriers
for each row
execute function public.set_updated_at();

drop trigger if exists trg_courier_locations_set_updated_at on public.courier_locations;
create trigger trg_courier_locations_set_updated_at
before update on public.courier_locations
for each row
execute function public.set_updated_at();

drop trigger if exists trg_pickup_orders_set_updated_at on public.pickup_orders;
create trigger trg_pickup_orders_set_updated_at
before update on public.pickup_orders
for each row
execute function public.set_updated_at();
