#!/usr/bin/env node
// JSR Database Backup Script
// Run with: node backup.js
// Requires: npm install @supabase/supabase-js

const SUPABASE_URL = 'https://tltbkjvrhqsxdspdfeqk.supabase.co';
const SUPABASE_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRsdGJranZyaHFzeGRzcGRmZXFrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODEwMTQ2NzIsImV4cCI6MjA5NjU5MDY3Mn0.jEw34TKJNZ8Ezr3LujjsgWrSc045OFqWlZaoDuas9GQ';

const TABLES = [
    'users',
    'sections',
    'rows',
    'activity_log',
    'general_expenses',
    'team_members',
    'revenue',
    'project_expenses',
    'expense_claims',
    'employee_documents',
];

const BACKUP_DIR = `${require('os').homedir()}/Downloads/JSR_Backups`;
const MAX_FILES  = 48;

const { createClient } = require('@supabase/supabase-js');
const fs   = require('fs');
const path = require('path');

const sb = createClient(SUPABASE_URL, SUPABASE_KEY);

function pad(n) { return String(n).padStart(2, '0'); }

function timestamp() {
    const d = new Date();
    return `${d.getFullYear()}-${pad(d.getMonth()+1)}-${pad(d.getDate())}_${pad(d.getHours())}-${pad(d.getMinutes())}`;
}

async function fetchTable(table) {
    let all = [], from = 0, pageSize = 1000;
    while (true) {
        const { data, error } = await sb.from(table).select('*').range(from, from + pageSize - 1);
        if (error) { console.error(`  ✗ Error fetching ${table}:`, error.message); return []; }
        all = all.concat(data || []);
        if (!data || data.length < pageSize) break;
        from += pageSize;
    }
    return all;
}

async function run() {
    if (!fs.existsSync(BACKUP_DIR)) {
        fs.mkdirSync(BACKUP_DIR, { recursive: true });
        console.log(`Created backup directory: ${BACKUP_DIR}`);
    }

    const backup = { exported_at: new Date().toISOString(), tables: {} };
    let total = 0;

    for (const table of TABLES) {
        process.stdout.write(`  Fetching ${table}… `);
        const rows = await fetchTable(table);
        backup.tables[table] = rows;
        total += rows.length;
        console.log(`${rows.length} rows`);
    }

    const fname = `jsr_backup_${timestamp()}.json`;
    const fpath = path.join(BACKUP_DIR, fname);
    fs.writeFileSync(fpath, JSON.stringify(backup, null, 2), 'utf8');
    console.log(`\n✅ Backup saved: ${fname} — ${total.toLocaleString()} total records`);

    // Keep only the last MAX_FILES backups
    const files = fs.readdirSync(BACKUP_DIR)
        .filter(f => f.startsWith('jsr_backup_') && f.endsWith('.json'))
        .map(f => ({ name: f, time: fs.statSync(path.join(BACKUP_DIR, f)).mtimeMs }))
        .sort((a, b) => b.time - a.time);

    const toDelete = files.slice(MAX_FILES);
    if (toDelete.length > 0) {
        toDelete.forEach(f => {
            fs.unlinkSync(path.join(BACKUP_DIR, f.name));
            console.log(`  🗑  Deleted old backup: ${f.name}`);
        });
    }
}

run().catch(err => { console.error('Backup failed:', err); process.exit(1); });
