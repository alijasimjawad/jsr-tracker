-- ═══════════════════════════════════════════════════
--  JSR – Network Management  |  Supabase Setup SQL
--  Run this in: Supabase Dashboard → SQL Editor
-- ═══════════════════════════════════════════════════

-- Enable UUID extension (usually already enabled)
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ─────────────────────────────────────────────────
--  1. USERS  (authentication)
-- ─────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS users (
    id         uuid        DEFAULT uuid_generate_v4() PRIMARY KEY,
    username   text        UNIQUE NOT NULL,
    password   text        NOT NULL,
    role       text        NOT NULL DEFAULT 'user',
    created_at timestamptz DEFAULT NOW()
);

-- Add full_name column (idempotent)
ALTER TABLE users ADD COLUMN IF NOT EXISTS full_name TEXT;

-- Add permissions column (idempotent)
ALTER TABLE users ADD COLUMN IF NOT EXISTS permissions jsonb DEFAULT '{}'::jsonb;

-- Default admin account
INSERT INTO users (username, password, role, full_name)
VALUES ('admin', '1234', 'admin', 'Admin')
ON CONFLICT (username) DO NOTHING;

-- Team users
INSERT INTO users (username, password, role, full_name) VALUES
    ('ali.abdulabbas', '1234', 'user', 'Ali Abdulabbas'),
    ('ahmed.hadi',     '1234', 'user', 'Ahmed Hadi'),
    ('ali.shaalan',    '1234', 'user', 'Ali Shaalan'),
    ('wessam.basil',   '1234', 'user', 'Wessam Basil')
ON CONFLICT (username) DO NOTHING;

-- ─────────────────────────────────────────────────
--  2. SECTIONS  (project × section metadata)
-- ─────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS sections (
    id             uuid        DEFAULT uuid_generate_v4() PRIMARY KEY,
    project_name   text        NOT NULL,
    section_name   text        NOT NULL,
    section_label  text        NOT NULL,
    columns        jsonb       NOT NULL DEFAULT '[]',
    custom_columns jsonb                DEFAULT '[]',
    is_custom      boolean     NOT NULL DEFAULT false,
    is_deleted     boolean     NOT NULL DEFAULT false,
    created_at     timestamptz DEFAULT NOW(),
    UNIQUE (project_name, section_name)
);

-- Add custom_columns to existing tables (idempotent)
ALTER TABLE sections ADD COLUMN IF NOT EXISTS custom_columns jsonb DEFAULT '[]'::jsonb;

CREATE INDEX IF NOT EXISTS sections_project_idx ON sections(project_name);

-- ─────────────────────────────────────────────────
--  3. ROWS  (data rows per section)
-- ─────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS rows (
    id         uuid        DEFAULT uuid_generate_v4() PRIMARY KEY,
    section_id uuid        REFERENCES sections(id) ON DELETE CASCADE,
    data       jsonb       NOT NULL DEFAULT '{}',
    row_order  integer     NOT NULL DEFAULT 0,
    created_at timestamptz DEFAULT NOW(),
    updated_at timestamptz DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS rows_section_id_idx    ON rows(section_id);
CREATE INDEX IF NOT EXISTS rows_section_order_idx ON rows(section_id, row_order);

-- Auto-update updated_at on row change
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN NEW.updated_at = NOW(); RETURN NEW; END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS rows_updated_at ON rows;
CREATE TRIGGER rows_updated_at
    BEFORE UPDATE ON rows
    FOR EACH ROW EXECUTE PROCEDURE update_updated_at();

-- ─────────────────────────────────────────────────
--  4. ROW LEVEL SECURITY
--     The app uses the anon key, so we allow full
--     access for all authenticated + anon clients.
-- ─────────────────────────────────────────────────
ALTER TABLE users    ENABLE ROW LEVEL SECURITY;
ALTER TABLE sections ENABLE ROW LEVEL SECURITY;
ALTER TABLE rows     ENABLE ROW LEVEL SECURITY;

-- Drop policies if they already exist (idempotent)
DROP POLICY IF EXISTS "anon_all" ON users;
DROP POLICY IF EXISTS "anon_all" ON sections;
DROP POLICY IF EXISTS "anon_all" ON rows;

CREATE POLICY "anon_all" ON users    FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "anon_all" ON sections FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "anon_all" ON rows     FOR ALL USING (true) WITH CHECK (true);

-- ─────────────────────────────────────────────────
--  Done. The app seeds all project/section data
--  automatically on first load.
-- ─────────────────────────────────────────────────
