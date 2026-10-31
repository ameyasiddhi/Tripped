-- Tripped: database setup for Supabase
-- Paste this whole file into Supabase > SQL Editor > New query, then click Run.
-- Before running, replace YOUR_ADMIN_EMAIL (one place, near the bottom) with the email you'll log in with.

create extension if not exists pgcrypto;

-- ---------- Tables ----------

create table if not exists public.posts (
  id            uuid primary key default gen_random_uuid(),
  created_at    timestamptz not null default now(),
  body          text not null check (char_length(body) between 5 and 280),
  category      text not null check (category in ('spares','om','procurement','manpower','compliance','other')),
  plant_type    text not null check (plant_type in ('thermal','hydro','solar','wind','gas','nuclear','other')),
  country       text not null check (char_length(country) between 2 and 60),
  region        text check (region is null or char_length(region) <= 40),
  lat           double precision not null check (lat between -90 and 90),
  lon           double precision not null check (lon between -180 and 180),
  status        text not null default 'live' check (status in ('live','held','hidden')),
  hold_reason   text,
  is_sample     boolean not null default false,
  is_fixed      boolean not null default false,
  metoo_count   integer not null default 0,
  report_count  integer not null default 0
);

create table if not exists public.metoos (
  id          uuid primary key default gen_random_uuid(),
  created_at  timestamptz not null default now(),
  post_id     uuid not null references public.posts(id) on delete cascade,
  country     text check (country is null or char_length(country) <= 60)
);

-- Optional emails ("tell me if someone fixes this"). Never readable by the public.
create table if not exists public.post_contacts (
  post_id     uuid primary key references public.posts(id) on delete cascade,
  email       text not null check (char_length(email) <= 200),
  created_at  timestamptz not null default now()
);

create index if not exists posts_status_idx on public.posts(status);
create index if not exists metoos_post_idx on public.metoos(post_id);

-- ---------- Table access ----------
-- Supabase no longer exposes new tables to the website automatically (change rolled out 2026),
-- so give each role exactly the table access it needs. Row level security still applies on top.
grant select on public.posts, public.metoos to anon, authenticated;
grant update, delete on public.posts to authenticated;
grant select on public.post_contacts to authenticated;
grant all on public.posts, public.metoos, public.post_contacts to service_role;

-- ---------- Admin check ----------

create or replace function public.is_admin() returns boolean
language sql stable as $$
  select coalesce(auth.jwt() ->> 'email', '') = 'YOUR_ADMIN_EMAIL';
$$;

-- ---------- Row level security ----------

alter table public.posts enable row level security;
alter table public.metoos enable row level security;
alter table public.post_contacts enable row level security;

drop policy if exists "public reads live posts" on public.posts;
create policy "public reads live posts" on public.posts
  for select using (status = 'live' or public.is_admin());

drop policy if exists "admin updates posts" on public.posts;
create policy "admin updates posts" on public.posts
  for update using (public.is_admin()) with check (public.is_admin());

drop policy if exists "admin deletes posts" on public.posts;
create policy "admin deletes posts" on public.posts
  for delete using (public.is_admin());

drop policy if exists "public reads metoos" on public.metoos;
create policy "public reads metoos" on public.metoos for select using (true);

drop policy if exists "admin reads contacts" on public.post_contacts;
create policy "admin reads contacts" on public.post_contacts
  for select using (public.is_admin());

-- No insert policies: the public can only write through the three functions below.

-- ---------- Automatic screening ----------
-- Holds a post for review if it looks like it names a company or person,
-- or contains contact details or links. Everything else goes live at once.

create or replace function public.screen_text(t text) returns text
language plpgsql immutable as $$
declare s text := lower(t);
begin
  if s ~ '[a-z0-9._%+-]+@[a-z0-9.-]+\.[a-z]{2,}' then return 'email address'; end if;
  if s ~ '(https?://|www\.|\.(com|in|org|net|io)\M)' then return 'link'; end if;
  if t ~ '\d[\d\s-]{8,}\d' then return 'phone or long number'; end if;
  if s ~ '\m(pvt|ltd|limited|llp|inc|corp|corporation|gmbh|llc|plc)\M' then return 'company name'; end if;
  if t ~ '\m(Mr|Mrs|Ms|Dr|Shri|Smt|Sir)\.?\s+[A-Z]' then return 'person''s name'; end if;
  if s ~ '\m(fuck|shit|bastard|bitch|chutiya|madarchod|bhenchod|randi)\M' then return 'language'; end if;
  return null;
end $$;

-- ---------- Public functions ----------

create or replace function public.create_post(
  p_body text, p_category text, p_plant_type text, p_country text,
  p_region text, p_lat double precision, p_lon double precision, p_email text default null
) returns table(id uuid, status text)
language plpgsql security definer set search_path = public as $$
declare reason text; new_id uuid; st text;
begin
  p_body := btrim(p_body);
  reason := public.screen_text(p_body || ' ' || coalesce(p_region, ''));
  st := case when reason is null then 'live' else 'held' end;
  insert into public.posts(body, category, plant_type, country, region, lat, lon, status, hold_reason)
  values (p_body, p_category, p_plant_type, p_country, nullif(btrim(p_region), ''), p_lat, p_lon, st, reason)
  returning posts.id into new_id;
  if p_email is not null and p_email ~ '^[^@\s]+@[^@\s]+\.[^@\s]+$' then
    insert into public.post_contacts(post_id, email) values (new_id, lower(btrim(p_email)));
  end if;
  return query select new_id, st;
end $$;

drop function if exists public.add_metoo(uuid, text);
create or replace function public.add_metoo(p_post uuid, p_country text default null)
returns table(metoo_id uuid, total integer)
language plpgsql security definer set search_path = public as $$
declare c integer; mid uuid;
begin
  update public.posts set metoo_count = metoo_count + 1
   where id = p_post and status = 'live'
   returning metoo_count into c;
  if c is null then return; end if;
  insert into public.metoos(post_id, country) values (p_post, nullif(btrim(p_country), ''))
  returning metoos.id into mid;
  return query select mid, c;
end $$;

-- Three reports take a post off the globe until you review it.
create or replace function public.report_post(p_post uuid)
returns void
language plpgsql security definer set search_path = public as $$
begin
  update public.posts
     set report_count = report_count + 1,
         status = case when report_count + 1 >= 3 then 'held' else status end,
         hold_reason = case when report_count + 1 >= 3 then 'reported by users' else hold_reason end
   where id = p_post and status = 'live';
end $$;

-- Lets a viewer add their country to the "me too" they just made.
drop function if exists public.set_metoo_country(uuid, text);
create or replace function public.set_metoo_country(p_metoo uuid, p_country text)
returns void
language plpgsql security definer set search_path = public as $$
begin
  update public.metoos set country = nullif(btrim(p_country), '')
   where id = p_metoo and country is null and created_at > now() - interval '1 hour';
end $$;

revoke all on function public.create_post, public.add_metoo, public.report_post, public.set_metoo_country from public;
grant execute on function public.create_post, public.add_metoo, public.report_post, public.set_metoo_country to anon, authenticated;

-- ---------- Sample posts (shown with a "Sample" tag; delete them once real posts arrive) ----------

insert into public.posts(body, category, plant_type, country, region, lat, lon, is_sample, metoo_count, created_at) values
('Spare pump seal took 9 weeks to arrive. Unit ran derated the whole time.', 'spares', 'thermal', 'India', 'Maharashtra', 19.6, 75.4, true, 23, now() - interval '3 days'),
('Three vendor quotes for the same valve, three different specs. Comparing them takes a full day.', 'procurement', 'thermal', 'India', 'Chhattisgarh', 21.4, 82.0, true, 17, now() - interval '5 days'),
('Shift handover is a paper register. Half the open issues get lost by the night shift.', 'om', 'thermal', 'India', 'Jharkhand', 23.6, 85.3, true, 14, now() - interval '2 days'),
('Experienced boiler operators retiring and nobody is trained to replace them.', 'manpower', 'thermal', 'India', 'Uttar Pradesh', 26.9, 80.9, true, 11, now() - interval '8 days'),
('Emission compliance reports are rebuilt by hand from five spreadsheets every month.', 'compliance', 'thermal', 'India', 'Tamil Nadu', 11.1, 78.6, true, 9, now() - interval '6 days'),
('Inverter spares sit in a warehouse 800 km away. Every failure means 4 days of downtime.', 'spares', 'solar', 'India', 'Rajasthan', 26.6, 73.8, true, 8, now() - interval '20 hours'),
('Gearbox oil analysis results come back after the gearbox has already failed.', 'om', 'wind', 'Germany', null, 52.3, 9.9, true, 6, now() - interval '4 days'),
('Purchase approvals need 7 signatures. Urgent orders still wait 3 weeks.', 'procurement', 'gas', 'Indonesia', null, -6.4, 107.2, true, 12, now() - interval '9 hours'),
('Turbine OEM parts cost 4x local equivalents but warranty forces us to buy them.', 'spares', 'gas', 'United States', 'Texas', 31.5, -98.4, true, 7, now() - interval '7 days'),
('Coal quality varies every rake. Nobody shares the test data with operations in time.', 'om', 'thermal', 'South Africa', null, -26.0, 28.6, true, 10, now() - interval '3 days');

insert into public.metoos(post_id, country)
select id, c from public.posts, unnest(array['India','India','Indonesia','South Africa']) c
where is_sample and body like 'Spare pump seal%';
