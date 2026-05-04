create table if not exists public.education_categories (
    id uuid primary key default gen_random_uuid(),
    name text not null,
    slug text not null unique,
    description text,
    icon_url text,
    display_order integer not null default 0,
    created_at timestamptz not null default timezone('utc', now())
);

create table if not exists public.education_content (
    id uuid primary key default gen_random_uuid(),
    category_id uuid not null references public.education_categories(id) on delete restrict,
    type text not null,
    title text not null,
    slug text not null unique,
    body text not null,
    summary text not null,
    thumbnail_url text,
    video_url text,
    meowpoints_reward integer not null default 0,
    is_featured boolean not null default false,
    is_published boolean not null default false,
    created_at timestamptz not null default timezone('utc', now()),
    updated_at timestamptz not null default timezone('utc', now())
);

create table if not exists public.user_edu_progress (
    user_id uuid not null references public.users(id) on delete cascade,
    content_id uuid not null references public.education_content(id) on delete cascade,
    progress_pct numeric(5,2) not null default 0,
    is_completed boolean not null default false,
    points_claimed boolean not null default false,
    completed_at timestamptz,
    primary key (user_id, content_id)
);

create table if not exists public.modules (
    id uuid primary key default gen_random_uuid(),
    waste_class_id uuid not null references public.waste_classes(id) on delete restrict,
    category text not null,
    poop_type text,
    title text not null,
    summary text not null,
    content_json jsonb not null default '{}'::jsonb,
    slug text not null unique,
    meowpoints_reward integer not null default 0,
    estimated_duration_minutes integer not null default 0,
    updated_at timestamptz not null default timezone('utc', now())
);

create table if not exists public.module_steps (
    id uuid primary key default gen_random_uuid(),
    module_id uuid not null references public.modules(id) on delete cascade,
    step_order integer not null,
    step_key text not null,
    title text not null,
    instruction text not null,
    image_url text,
    video_url text,
    safety_note text,
    meowpoints_granted integer not null default 0,
    created_at timestamptz not null default timezone('utc', now()),
    unique (module_id, step_order)
);

create table if not exists public.user_module_progress (
    id uuid primary key default gen_random_uuid(),
    user_id uuid not null references public.users(id) on delete cascade,
    module_id uuid not null references public.modules(id) on delete cascade,
    current_step_order integer not null default 0,
    progress_pct numeric(5,2) not null default 0,
    is_completed boolean not null default false,
    points_claimed boolean not null default false,
    completed_at timestamptz,
    created_at timestamptz not null default timezone('utc', now()),
    updated_at timestamptz not null default timezone('utc', now()),
    unique (user_id, module_id)
);

create index if not exists idx_education_content_category_id on public.education_content(category_id);
create index if not exists idx_user_edu_progress_content_id on public.user_edu_progress(content_id);
create index if not exists idx_modules_waste_class_id on public.modules(waste_class_id);
create index if not exists idx_module_steps_module_id on public.module_steps(module_id, step_order);
create index if not exists idx_user_module_progress_user_id on public.user_module_progress(user_id);

drop trigger if exists trg_modules_set_updated_at on public.modules;
create trigger trg_modules_set_updated_at
before update on public.modules
for each row
execute function public.set_updated_at();

drop trigger if exists trg_user_module_progress_set_updated_at on public.user_module_progress;
create trigger trg_user_module_progress_set_updated_at
before update on public.user_module_progress
for each row
execute function public.set_updated_at();

drop trigger if exists trg_education_content_set_updated_at on public.education_content;
create trigger trg_education_content_set_updated_at
before update on public.education_content
for each row
execute function public.set_updated_at();
