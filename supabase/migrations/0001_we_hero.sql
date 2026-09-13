create extension if not exists pgcrypto;

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  nickname text not null check (char_length(nickname) between 1 and 30),
  level integer not null default 1 check (level >= 1),
  hero_xp integer not null default 0 check (hero_xp >= 0),
  coin_balance integer not null default 0 check (coin_balance >= 0),
  created_at timestamptz not null default now(), updated_at timestamptz not null default now()
);
create table if not exists public.user_preferences (
  user_id uuid primary key references public.profiles(id) on delete cascade,
  categories text[] not null default '{}', activity_style text check (activity_style in ('solo','group','both')),
  available_minutes integer check (available_minutes in (10,30,60,180)), environment text check (environment in ('indoor','outdoor','both')),
  created_at timestamptz not null default now()
);
create table if not exists public.missions (
  id uuid primary key default gen_random_uuid(), title text not null, description text not null, category text not null,
  difficulty text not null check (difficulty in ('easy','normal','challenge')), estimated_minutes integer not null check (estimated_minutes > 0),
  base_coin_reward integer not null check (base_coin_reward >= 0), base_xp_reward integer not null check (base_xp_reward >= 0),
  verification_type text not null default 'photo', active boolean not null default true, created_at timestamptz not null default now()
);
create table if not exists public.activities (
  id uuid primary key default gen_random_uuid(), user_id uuid not null references public.profiles(id) on delete cascade,
  mission_id uuid not null references public.missions(id), note text, completed_at timestamptz not null default now(),
  coin_reward integer not null default 0, xp_reward integer not null default 0, unique(user_id, mission_id, completed_at)
);
create table if not exists public.activity_photos (
  id uuid primary key default gen_random_uuid(), activity_id uuid not null references public.activities(id) on delete cascade,
  storage_path text not null, sha256 text not null, created_at timestamptz not null default now()
);
create table if not exists public.avatar_items (
  id uuid primary key default gen_random_uuid(), component_type text not null, name text not null, asset_id text not null unique,
  price integer not null default 0, item_type text not null default 'normal', created_at timestamptz not null default now()
);
create table if not exists public.user_items (user_id uuid references public.profiles(id) on delete cascade, item_id uuid references public.avatar_items(id) on delete cascade, acquired_at timestamptz not null default now(), primary key(user_id,item_id));
create table if not exists public.avatar_loadouts (user_id uuid primary key references public.profiles(id) on delete cascade, components jsonb not null default '{}', updated_at timestamptz not null default now());
create table if not exists public.coin_transactions (id uuid primary key default gen_random_uuid(), user_id uuid references public.profiles(id) on delete cascade, amount integer not null, reason text not null, created_at timestamptz not null default now());
create table if not exists public.xp_transactions (id uuid primary key default gen_random_uuid(), user_id uuid references public.profiles(id) on delete cascade, amount integer not null, reason text not null, created_at timestamptz not null default now());
create table if not exists public.sidekick_recommendations (id uuid primary key default gen_random_uuid(), user_id uuid references public.profiles(id) on delete cascade, mission_ids uuid[] not null, message text not null, created_at timestamptz not null default now());

create index if not exists activities_user_completed_idx on public.activities(user_id, completed_at);
create index if not exists missions_category_active_idx on public.missions(category, active);

alter table public.profiles enable row level security; alter table public.user_preferences enable row level security; alter table public.activities enable row level security; alter table public.activity_photos enable row level security; alter table public.user_items enable row level security; alter table public.avatar_loadouts enable row level security; alter table public.coin_transactions enable row level security; alter table public.xp_transactions enable row level security; alter table public.sidekick_recommendations enable row level security;
create policy "own profile" on public.profiles for all using (auth.uid() = id) with check (auth.uid() = id);
create policy "own preferences" on public.user_preferences for all using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "read active missions" on public.missions for select using (active = true);
create policy "own activities" on public.activities for select using (auth.uid() = user_id);
create policy "own photos" on public.activity_photos for select using (exists (select 1 from public.activities a where a.id = activity_id and a.user_id = auth.uid()));
create policy "own inventory" on public.user_items for select using (auth.uid() = user_id);
create policy "own loadout" on public.avatar_loadouts for all using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "own transactions" on public.coin_transactions for select using (auth.uid() = user_id);
create policy "own xp" on public.xp_transactions for select using (auth.uid() = user_id);
create policy "own recommendations" on public.sidekick_recommendations for select using (auth.uid() = user_id);
