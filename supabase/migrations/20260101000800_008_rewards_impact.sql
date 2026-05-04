create table if not exists public.meowpoints_ledger (
    id uuid primary key default gen_random_uuid(),
    user_id uuid not null references public.users(id) on delete cascade,
    delta integer not null,
    reason text not null,
    source_type text not null,
    source_id uuid,
    created_at timestamptz not null default timezone('utc', now())
);

create table if not exists public.vouchers (
    id uuid primary key default gen_random_uuid(),
    partner_name text not null,
    discount_label text not null,
    points_required integer not null default 0,
    stock integer not null default 0,
    expires_at timestamptz,
    is_active boolean not null default true,
    created_at timestamptz not null default timezone('utc', now())
);

create table if not exists public.user_vouchers (
    id uuid primary key default gen_random_uuid(),
    user_id uuid not null references public.users(id) on delete cascade,
    voucher_id uuid not null references public.vouchers(id) on delete cascade,
    code text not null unique,
    redeemed_at timestamptz,
    used_at timestamptz,
    status text not null
);

create table if not exists public.impact_events (
    id uuid primary key default gen_random_uuid(),
    user_id uuid not null references public.users(id) on delete cascade,
    source_type text not null,
    source_id uuid,
    waste_weight_g integer not null default 0,
    processed_compost_g integer not null default 0,
    impact_note text,
    created_at timestamptz not null default timezone('utc', now())
);

create table if not exists public.impact_summaries (
    user_id uuid primary key references public.users(id) on delete cascade,
    total_scans integer not null default 0,
    total_pickups integer not null default 0,
    total_waste_g integer not null default 0,
    total_compost_g integer not null default 0,
    total_modules_completed integer not null default 0,
    total_education_completed integer not null default 0,
    updated_at timestamptz not null default timezone('utc', now())
);

create index if not exists idx_meowpoints_ledger_user_id on public.meowpoints_ledger(user_id, created_at desc);
create index if not exists idx_user_vouchers_user_id on public.user_vouchers(user_id);
create index if not exists idx_user_vouchers_voucher_id on public.user_vouchers(voucher_id);
create index if not exists idx_impact_events_user_id on public.impact_events(user_id);

drop trigger if exists trg_impact_summaries_set_updated_at on public.impact_summaries;
create trigger trg_impact_summaries_set_updated_at
before update on public.impact_summaries
for each row
execute function public.set_updated_at();
