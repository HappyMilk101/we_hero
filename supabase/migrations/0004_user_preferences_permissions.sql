-- Replace the broad legacy policy with operation-specific self-access rules.
alter table public.user_preferences enable row level security;

drop policy if exists "own preferences" on public.user_preferences;
drop policy if exists "own preferences select" on public.user_preferences;
drop policy if exists "own preferences insert" on public.user_preferences;
drop policy if exists "own preferences update" on public.user_preferences;

revoke all on table public.user_preferences from anon;
revoke all on table public.user_preferences from authenticated;

grant select, insert, update on table public.user_preferences to authenticated;

create policy "own preferences select"
  on public.user_preferences for select
  using (auth.uid() = user_id);

create policy "own preferences insert"
  on public.user_preferences for insert
  with check (auth.uid() = user_id);

create policy "own preferences update"
  on public.user_preferences for update
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);
