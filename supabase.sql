-- Exécutez ce script dans Supabase SQL Editor pour configurer le projet.
create table if not exists public.notes (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  content text not null check (char_length(btrim(content)) between 1 and 500),
  created_at timestamptz not null default now()
);

create index if not exists notes_user_created_at_idx on public.notes (user_id, created_at desc);
alter table public.notes enable row level security;
grant select, insert on public.notes to authenticated;

drop policy if exists "Users read own notes" on public.notes;
drop policy if exists "Users create own notes" on public.notes;
create policy "Users read own notes" on public.notes
  for select to authenticated
  using (auth.uid() = user_id);
create policy "Users create own notes" on public.notes
  for insert to authenticated
  with check (auth.uid() = user_id);

create table if not exists public.invoices (
  id text primary key,
  client_email text,
  invoice jsonb not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists invoices_client_email_idx on public.invoices (lower(client_email));
alter table public.invoices enable row level security;
grant select, insert, update, delete on public.invoices to authenticated;

drop policy if exists "Admins manage invoices" on public.invoices;
drop policy if exists "Clients read their invoices" on public.invoices;
create policy "Admins manage invoices" on public.invoices
  for all to authenticated
  using (lower(auth.jwt()->>'email') = 'thosane90@gmail.com')
  with check (lower(auth.jwt()->>'email') = 'thosane90@gmail.com');
create policy "Clients read their invoices" on public.invoices
  for select to authenticated
  using (lower(client_email) = lower(auth.jwt()->>'email'));

do $$
begin
  alter publication supabase_realtime add table public.invoices;
exception when duplicate_object then null;
end $$;

insert into storage.buckets (id, name, public, file_size_limit)
values ('invoice-files', 'invoice-files', false, 52428800)
on conflict (id) do update set public = false, file_size_limit = 52428800;

drop policy if exists "Admins upload invoice files" on storage.objects;
drop policy if exists "Admins update invoice files" on storage.objects;
drop policy if exists "Admins delete invoice files" on storage.objects;
drop policy if exists "Invoice owners read invoice files" on storage.objects;
create policy "Admins upload invoice files" on storage.objects
  for insert to authenticated
  with check (bucket_id = 'invoice-files' and lower(auth.jwt()->>'email') = 'thosane90@gmail.com');
create policy "Admins update invoice files" on storage.objects
  for update to authenticated
  using (bucket_id = 'invoice-files' and lower(auth.jwt()->>'email') = 'thosane90@gmail.com')
  with check (bucket_id = 'invoice-files' and lower(auth.jwt()->>'email') = 'thosane90@gmail.com');
create policy "Admins delete invoice files" on storage.objects
  for delete to authenticated
  using (bucket_id = 'invoice-files' and lower(auth.jwt()->>'email') = 'thosane90@gmail.com');
create policy "Invoice owners read invoice files" on storage.objects
  for select to authenticated
  using (
    bucket_id = 'invoice-files'
    and (
      lower(auth.jwt()->>'email') = 'thosane90@gmail.com'
      or exists (
        select 1 from public.invoices i
        where i.id = split_part(name, '/', 1)
          and lower(i.client_email) = lower(auth.jwt()->>'email')
      )
    )
  );