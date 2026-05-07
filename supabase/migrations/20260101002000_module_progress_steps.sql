alter table public.user_module_progress
add column if not exists step_id uuid references public.module_steps(id) on delete cascade;

alter table public.user_module_progress
drop constraint if exists user_module_progress_user_id_module_id_key;

create unique index if not exists idx_user_module_progress_user_module_step
on public.user_module_progress(user_id, module_id, step_id)
where step_id is not null;

create index if not exists idx_user_module_progress_step_id
on public.user_module_progress(step_id);
