create table if not exists public.waste_classes (
    id uuid primary key default gen_random_uuid(),
    code text not null unique,
    name text not null,
    description text not null,
    risk_level text not null,
    default_action text not null,
    created_at timestamptz not null default timezone('utc', now()),
    updated_at timestamptz not null default timezone('utc', now())
);

create table if not exists public.scan_sessions (
    id uuid primary key default gen_random_uuid(),
    user_id uuid not null references public.users(id) on delete cascade,
    cat_id uuid references public.cats(id) on delete set null,
    litter_box_id uuid references public.litter_boxes(id) on delete set null,
    image_url text,
    image_storage_path text,
    detected_class_id uuid references public.waste_classes(id) on delete set null,
    detected_class text,
    confidence_score numeric(5,4) check (confidence_score between 0 and 1),
    risk_level text,
    scan_status text not null default 'pending',
    ai_feedback text,
    scanned_at timestamptz not null default timezone('utc', now())
);

create table if not exists public.scan_detections (
    id uuid primary key default gen_random_uuid(),
    scan_session_id uuid not null references public.scan_sessions(id) on delete cascade,
    waste_class_id uuid not null references public.waste_classes(id) on delete restrict,
    confidence_score numeric(5,4) check (confidence_score between 0 and 1),
    bounding_box jsonb not null default '{}'::jsonb,
    created_at timestamptz not null default timezone('utc', now())
);

create index if not exists idx_scan_sessions_user_id on public.scan_sessions(user_id);
create index if not exists idx_scan_sessions_cat_id on public.scan_sessions(cat_id);
create index if not exists idx_scan_sessions_litter_box_id on public.scan_sessions(litter_box_id);
create index if not exists idx_scan_sessions_detected_class_id on public.scan_sessions(detected_class_id);
create index if not exists idx_scan_sessions_scanned_at on public.scan_sessions(scanned_at);
create index if not exists idx_scan_detections_scan_session_id on public.scan_detections(scan_session_id);
create index if not exists idx_scan_detections_waste_class_id on public.scan_detections(waste_class_id);

alter table public.cat_activities
drop constraint if exists cat_activities_scan_session_id_fkey;

alter table public.cat_activities
add constraint cat_activities_scan_session_id_fkey
foreign key (scan_session_id)
references public.scan_sessions(id)
on delete set null;

drop trigger if exists trg_waste_classes_set_updated_at on public.waste_classes;
create trigger trg_waste_classes_set_updated_at
before update on public.waste_classes
for each row
execute function public.set_updated_at();
