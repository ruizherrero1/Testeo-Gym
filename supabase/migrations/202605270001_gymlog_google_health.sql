create table if not exists public.gymlog_google_connections (
  user_id uuid primary key references auth.users(id) on delete cascade,
  google_refresh_token text not null,
  google_health_refresh_token text,
  google_scopes text,
  backup_file_id text,
  backup_file_url text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.gymlog_oauth_states (
  state text primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  return_to text not null,
  expires_at timestamptz not null,
  created_at timestamptz not null default now()
);

create table if not exists public.gymlog_synced_sessions (
  user_id uuid not null references auth.users(id) on delete cascade,
  local_id text not null,
  google_data_point_name text not null,
  synced_at timestamptz not null default now(),
  primary key (user_id, local_id)
);

alter table public.gymlog_google_connections enable row level security;
alter table public.gymlog_oauth_states enable row level security;
alter table public.gymlog_synced_sessions enable row level security;

revoke all on public.gymlog_google_connections from anon, authenticated;
revoke all on public.gymlog_oauth_states from anon, authenticated;
revoke all on public.gymlog_synced_sessions from anon, authenticated;

grant all on public.gymlog_google_connections to service_role;
grant all on public.gymlog_oauth_states to service_role;
grant all on public.gymlog_synced_sessions to service_role;
