create table if not exists public.chat_sessions (
    id uuid primary key default gen_random_uuid(),
    user_id uuid not null references public.users(id) on delete cascade,
    scan_session_id uuid references public.scan_sessions(id) on delete set null,
    initial_context jsonb not null default '{}'::jsonb,
    selected_card text,
    started_at timestamptz not null default timezone('utc', now()),
    ended_at timestamptz,
    updated_at timestamptz not null default timezone('utc', now())
);

create table if not exists public.chat_messages (
    id uuid primary key default gen_random_uuid(),
    session_id uuid not null references public.chat_sessions(id) on delete cascade,
    role text not null,
    message_type text not null,
    content text not null,
    image_url text,
    metadata jsonb not null default '{}'::jsonb,
    sent_at timestamptz not null default timezone('utc', now())
);

create table if not exists public.chat_cta_cards (
    id uuid primary key default gen_random_uuid(),
    message_id uuid not null references public.chat_messages(id) on delete cascade,
    card_type text not null,
    title text not null,
    description text,
    cta_label text not null,
    target_route text,
    payload jsonb not null default '{}'::jsonb,
    display_order integer not null default 0
);

create index if not exists idx_chat_sessions_user_id on public.chat_sessions(user_id);
create index if not exists idx_chat_sessions_scan_session_id on public.chat_sessions(scan_session_id);
create index if not exists idx_chat_messages_session_id on public.chat_messages(session_id, sent_at);
create index if not exists idx_chat_cta_cards_message_id on public.chat_cta_cards(message_id, display_order);

drop trigger if exists trg_chat_sessions_set_updated_at on public.chat_sessions;
create trigger trg_chat_sessions_set_updated_at
before update on public.chat_sessions
for each row
execute function public.set_updated_at();
