-- Active missions are readable by signed-in users through the existing
-- "read active missions" RLS policy from 0001_we_hero.sql.
revoke all on table public.missions from anon;
revoke all on table public.missions from authenticated;

grant select on table public.missions to authenticated;
