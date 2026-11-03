-- Database online di Radar Nicchie (Supabase, piano gratuito).
-- Copia tutto questo testo in Supabase > SQL Editor > New query, poi premi "Run".
-- Crea la tabella delle ricerche: ogni persona vede, salva e cancella solo le proprie.

create table if not exists public.ricerche (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid() references auth.users on delete cascade,
  creato timestamptz not null default now(),
  ricerca text not null,
  impostazioni jsonb,
  riassunto jsonb,
  video jsonb not null
);

alter table public.ricerche enable row level security;

drop policy if exists "vedo le mie ricerche" on public.ricerche;
drop policy if exists "salvo le mie ricerche" on public.ricerche;
drop policy if exists "cancello le mie ricerche" on public.ricerche;

create policy "vedo le mie ricerche" on public.ricerche
  for select using (auth.uid() = user_id);
create policy "salvo le mie ricerche" on public.ricerche
  for insert with check (auth.uid() = user_id);
create policy "cancello le mie ricerche" on public.ricerche
  for delete using (auth.uid() = user_id);

create index if not exists ricerche_utente_data on public.ricerche (user_id, creato desc);

-- Crediti YouTube usati fuori dal browser (per esempio le ricerche fatte da Claude con il motore "cerca-nicchia").
-- Il sito li legge e li aggiunge al contatore "Crediti di oggi". Solo lettura per chi è connesso.
create table if not exists public.crediti_youtube (
  user_id uuid not null references auth.users on delete cascade,
  giorno text not null,
  usati integer not null default 0,
  aggiornato timestamptz not null default now(),
  primary key (user_id, giorno)
);
alter table public.crediti_youtube enable row level security;
drop policy if exists "vedo i miei crediti" on public.crediti_youtube;
create policy "vedo i miei crediti" on public.crediti_youtube for select using (auth.uid() = user_id);
