-- Create the exams table
create table exams (
  id uuid default gen_random_uuid() primary key,
  created_at timestamptz default now(),
  title text not null,
  date text,
  time text,
  location text,
  is_urgent boolean default false
);

-- Enable Row Level Security (RLS)
alter table exams enable row level security;

-- Create a policy to allow anyone to read/write for now (testing phase)
-- WARNING: In production, you should restrict this to authenticated users.
create policy "Allow all access" on exams
  for all
  using (true)
  with check (true);
