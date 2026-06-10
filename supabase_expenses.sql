CREATE TABLE IF NOT EXISTS expenses (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  date date NOT NULL,
  description text,
  category text,
  project_name text,
  amount numeric(12,2),
  currency text DEFAULT 'USD',
  status text DEFAULT 'Pending',
  added_by text,
  notes text,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);
ALTER TABLE expenses ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Allow all on expenses" ON expenses FOR ALL TO anon USING (true) WITH CHECK (true);

CREATE TABLE IF NOT EXISTS expense_budgets (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  project_name text,
  month text,
  year integer,
  budget_amount numeric(12,2),
  currency text DEFAULT 'USD',
  created_at timestamptz DEFAULT now()
);
ALTER TABLE expense_budgets ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Allow all on expense_budgets" ON expense_budgets FOR ALL TO anon USING (true) WITH CHECK (true);
