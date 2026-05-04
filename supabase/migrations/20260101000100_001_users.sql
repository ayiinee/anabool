create extension if not exists pgcrypto;

create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
    new.updated_at = timezone('utc', now());
    return new;
end;
$$;

create table if not exists public.users (
    id uuid primary key default gen_random_uuid(),
    firebase_uid text not null unique,
    email text unique,
    display_name text,
    avatar_url text,
    phone_number text,
    role text not null default 'user',
    is_pregnant boolean not null default false,
    meowpoints_balance integer not null default 0,
    created_at timestamptz not null default timezone('utc', now()),
    updated_at timestamptz not null default timezone('utc', now())
);

create table if not exists public.user_profiles (
    user_id uuid primary key references public.users(id) on delete cascade,
    safety_mode boolean not null default false,
    risk_group text not null default 'general',
    reminder_interval_hours integer not null default 24,
    preferred_pickup_type text,
    preferred_language text not null default 'id',
    created_at timestamptz not null default timezone('utc', now()),
    updated_at timestamptz not null default timezone('utc', now())
);

create table if not exists public.user_addresses (
    id uuid primary key default gen_random_uuid(),
    user_id uuid not null references public.users(id) on delete cascade,
    label text not null,
    address text not null,
    city text not null,
    province text not null,
    postal_code text,
    lat numeric(10,6),
    lng numeric(10,6),
    is_default boolean not null default false,
    created_at timestamptz not null default timezone('utc', now())
);

create table if not exists public.fcm_tokens (
    id uuid primary key default gen_random_uuid(),
    user_id uuid not null references public.users(id) on delete cascade,
    device_token text not null unique,
    device_type text not null,
    is_active boolean not null default true,
    created_at timestamptz not null default timezone('utc', now()),
    updated_at timestamptz not null default timezone('utc', now())
);

create index if not exists idx_user_addresses_user_id on public.user_addresses(user_id);
create index if not exists idx_fcm_tokens_user_id on public.fcm_tokens(user_id);

drop trigger if exists trg_users_set_updated_at on public.users;
create trigger trg_users_set_updated_at
before update on public.users
for each row
execute function public.set_updated_at();

drop trigger if exists trg_user_profiles_set_updated_at on public.user_profiles;
create trigger trg_user_profiles_set_updated_at
before update on public.user_profiles
for each row
execute function public.set_updated_at();

drop trigger if exists trg_fcm_tokens_set_updated_at on public.fcm_tokens;
create trigger trg_fcm_tokens_set_updated_at
before update on public.fcm_tokens
for each row
execute function public.set_updated_at();
