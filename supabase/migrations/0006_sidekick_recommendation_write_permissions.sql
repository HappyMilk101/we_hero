-- Allow authenticated users to read and create only their own recommendations.
alter table public.sidekick_recommendations enable row level security;

revoke all on table public.sidekick_recommendations from anon;
revoke all on table public.sidekick_recommendations from authenticated;
grant select, insert on table public.sidekick_recommendations to authenticated;

drop policy if exists "own recommendations" on public.sidekick_recommendations;
drop policy if exists "own recommendations select" on public.sidekick_recommendations;
drop policy if exists "own recommendations insert" on public.sidekick_recommendations;

create policy "own recommendations select"
  on public.sidekick_recommendations for select
  using (auth.uid() = user_id);

create policy "own recommendations insert"
  on public.sidekick_recommendations for insert
  with check (auth.uid() = user_id);
