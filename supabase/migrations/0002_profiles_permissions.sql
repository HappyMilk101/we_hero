-- The profiles table is intentionally available only to authenticated users.
-- Row-level access remains limited to the signed-in user's own profile by the
-- existing "own profile" policy from 0001_we_hero.sql.
revoke all on table public.profiles from anon;
revoke all on table public.profiles from authenticated;

grant select, insert, update on table public.profiles to authenticated;
