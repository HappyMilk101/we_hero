-- Audit permissions used by the authenticated Sidekick data path.
-- Existing policies in 0001 restrict both tables to the current user's rows.
alter table public.activities enable row level security;
alter table public.sidekick_recommendations enable row level security;

revoke all on table public.activities from anon;
revoke all on table public.sidekick_recommendations from anon;
revoke all on table public.activities from authenticated;
revoke all on table public.sidekick_recommendations from authenticated;

grant select on table public.activities to authenticated;
grant select on table public.sidekick_recommendations to authenticated;
