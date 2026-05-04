create table if not exists public.cats (
    id uuid primary key default gen_random_uuid(),
    owner_id uuid not null references public.users(id) on delete cascade,
    name text not null,
    breed text,
    gender text,
    date_of_birth date,
    avatar_url text,
    is_vaccinated boolean not null default false,
    health_notes text,
    created_at timestamptz not null default timezone('utc', now()),
    updated_at timestamptz not null default timezone('utc', now())
);

create table if not exists public.litter_boxes (
    id uuid primary key default gen_random_uuid(),
    user_id uuid not null references public.users(id) on delete cascade,
    cat_id uuid references public.cats(id) on delete set null,
    location_label text,
    litter_type text,
    last_cleaned_at timestamptz,
    status text not null default 'normal',
    created_at timestamptz not null default timezone('utc', now()),
    updated_at timestamptz not null default timezone('utc', now())
);

create table if not exists public.litter_box_daily_status (
    id uuid primary key default gen_random_uuid(),
    litter_box_id uuid not null references public.litter_boxes(id) on delete cascade,
    status_date date not null,
    cleanliness_status text not null,
    pee_count integer not null default 0,
    poop_count integer not null default 0,
    last_cleaned_at timestamptz,
    abnormal_pattern_detected boolean not null default false,
    alert_message text,
    created_at timestamptz not null default timezone('utc', now()),
    updated_at timestamptz not null default timezone('utc', now())
);

create table if not exists public.cat_activities (
    id uuid primary key default gen_random_uuid(),
    cat_id uuid not null references public.cats(id) on delete cascade,
    litter_box_id uuid references public.litter_boxes(id) on delete set null,
    scan_session_id uuid,
    type text not null,
    notes text,
    recorded_at timestamptz not null default timezone('utc', now()),
    created_at timestamptz not null default timezone('utc', now())
);

create index if not exists idx_cats_owner_id on public.cats(owner_id);
create index if not exists idx_litter_boxes_user_id on public.litter_boxes(user_id);
create index if not exists idx_litter_boxes_cat_id on public.litter_boxes(cat_id);
create unique index if not exists uq_litter_box_daily_status_box_date
on public.litter_box_daily_status(litter_box_id, status_date);
create index if not exists idx_cat_activities_cat_id on public.cat_activities(cat_id);
create index if not exists idx_cat_activities_litter_box_id on public.cat_activities(litter_box_id);
create index if not exists idx_cat_activities_scan_session_id on public.cat_activities(scan_session_id);

drop trigger if exists trg_cats_set_updated_at on public.cats;
create trigger trg_cats_set_updated_at
before update on public.cats
for each row
execute function public.set_updated_at();

drop trigger if exists trg_litter_boxes_set_updated_at on public.litter_boxes;
create trigger trg_litter_boxes_set_updated_at
before update on public.litter_boxes
for each row
execute function public.set_updated_at();

drop trigger if exists trg_litter_box_daily_status_set_updated_at on public.litter_box_daily_status;
create trigger trg_litter_box_daily_status_set_updated_at
before update on public.litter_box_daily_status
for each row
execute function public.set_updated_at();
