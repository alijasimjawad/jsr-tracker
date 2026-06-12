-- Team members table
CREATE TABLE IF NOT EXISTS team_members (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  full_name text NOT NULL,
  monthly_salary numeric(15,0) NOT NULL,
  role text,
  is_active boolean DEFAULT true,
  created_at timestamptz DEFAULT now()
);
ALTER TABLE team_members ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Allow all on team_members" ON team_members FOR ALL TO anon USING (true) WITH CHECK (true);

-- Work log: tracks days each member worked on each project per month
CREATE TABLE IF NOT EXISTS work_log (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  member_id uuid REFERENCES team_members(id),
  member_name text,
  project_name text,
  month integer,
  year integer,
  days_worked numeric(4,1),
  working_days_in_month integer,
  daily_rate numeric(15,0),
  total_cost numeric(15,0),
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);
ALTER TABLE work_log ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Allow all on work_log" ON work_log FOR ALL TO anon USING (true) WITH CHECK (true);

-- Revenue per site
CREATE TABLE IF NOT EXISTS revenue (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  project_name text NOT NULL,
  site_id text,
  amount numeric(15,0) NOT NULL DEFAULT 0,
  invoice_date date,
  month integer,
  year integer,
  status text DEFAULT 'Implemented - Pending ATP',
  notes text,
  added_by text,
  created_at timestamptz DEFAULT now()
);
-- Add status column to existing table (idempotent)
ALTER TABLE revenue ADD COLUMN IF NOT EXISTS status text DEFAULT 'Implemented - Pending ATP';
ALTER TABLE revenue ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Allow all on revenue" ON revenue FOR ALL TO anon USING (true) WITH CHECK (true);

-- General expenses (rent, office, etc.)
CREATE TABLE IF NOT EXISTS general_expenses (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  description text NOT NULL,
  category text,
  amount numeric(15,0) NOT NULL,
  expense_date date,
  month integer,
  year integer,
  notes text,
  added_by text,
  created_at timestamptz DEFAULT now()
);
ALTER TABLE general_expenses ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Allow all on general_expenses" ON general_expenses FOR ALL TO anon USING (true) WITH CHECK (true);

-- Project expenses (materials, transport, etc.)
CREATE TABLE IF NOT EXISTS project_expenses (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  project_name text NOT NULL,
  description text NOT NULL,
  category text,
  amount numeric(15,0) NOT NULL,
  expense_date date,
  month integer,
  year integer,
  notes text,
  added_by text,
  created_at timestamptz DEFAULT now()
);
ALTER TABLE project_expenses ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Allow all on project_expenses" ON project_expenses FOR ALL TO anon USING (true) WITH CHECK (true);
