alter table public.education_categories enable row level security;
alter table public.education_content enable row level security;
alter table public.user_edu_progress enable row level security;
alter table public.modules enable row level security;
alter table public.module_steps enable row level security;
alter table public.user_module_progress enable row level security;

drop policy if exists "public read education_categories" on public.education_categories;
create policy "public read education_categories"
on public.education_categories
for select
using (true);

drop policy if exists "public read modules" on public.modules;
create policy "public read modules"
on public.modules
for select
using (true);

drop policy if exists "public read module_steps" on public.module_steps;
create policy "public read module_steps"
on public.module_steps
for select
using (
    exists (
        select 1
        from public.modules
        where modules.id = module_steps.module_id
    )
);

drop policy if exists "public read education_content" on public.education_content;
create policy "public read education_content"
on public.education_content
for select
using (is_published = true);
