CREATE TABLE IF NOT EXISTS activity_log (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  user_full_name text,
  action text,
  project_name text,
  section_name text,
  details text,
  created_at timestamptz DEFAULT now()
);

-- Add custom_columns tracking to sections table
ALTER TABLE sections
  ADD COLUMN IF NOT EXISTS custom_columns jsonb DEFAULT '[]'::jsonb;
