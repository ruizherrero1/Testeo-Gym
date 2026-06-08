alter table public.gymlog_google_connections
  add column if not exists google_health_refresh_token text;
