-- ============================================================
-- FOOTHILL FEED · DAILY HQ · SUPABASE TABLES
-- Paste this entire block into: Supabase → SQL Editor → Run
-- ============================================================

-- ── 1. hq_state ─────────────────────────────────────────────
-- Stores daily/weekly/monthly task state, focus, skips, notes
-- Keyed by owner + scope_key (e.g. "daily:2026-05-13")
CREATE TABLE IF NOT EXISTS hq_state (
  id          BIGSERIAL PRIMARY KEY,
  owner       TEXT NOT NULL DEFAULT 'jeff',
  scope_key   TEXT NOT NULL,          -- e.g. "daily:2026-05-13" | "weekly:2026-05-11" | "monthly:2026-05"
  data        JSONB NOT NULL DEFAULT '{}',
  updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (owner, scope_key)
);

-- ── 2. hq_notes ─────────────────────────────────────────────
-- Quick capture / brain dump notes (append-only log)
CREATE TABLE IF NOT EXISTS hq_notes (
  id          BIGSERIAL PRIMARY KEY,
  owner       TEXT NOT NULL DEFAULT 'jeff',
  note_text   TEXT NOT NULL,
  captured_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ── 3. hq_ai_cache ──────────────────────────────────────────
-- Caches AI-generated content (motivation, staff message) by date
-- so we don't re-call the API every page load
CREATE TABLE IF NOT EXISTS hq_ai_cache (
  id          BIGSERIAL PRIMARY KEY,
  cache_key   TEXT NOT NULL UNIQUE,   -- e.g. "jeff_mot:2026-05-13"
  content     JSONB NOT NULL,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  expires_at  TIMESTAMPTZ NOT NULL DEFAULT (NOW() + INTERVAL '24 hours')
);

-- ── 4. hq_vendor_skips ──────────────────────────────────────
-- Tracks biweekly vendor skip toggles by week
CREATE TABLE IF NOT EXISTS hq_vendor_skips (
  id          BIGSERIAL PRIMARY KEY,
  owner       TEXT NOT NULL DEFAULT 'jeff',
  week_key    TEXT NOT NULL,           -- ISO week start date "2026-05-11"
  vendor_name TEXT NOT NULL,
  skipped     BOOLEAN NOT NULL DEFAULT TRUE,
  UNIQUE (owner, week_key, vendor_name)
);

-- ── Enable Row Level Security (RLS) ─────────────────────────
-- Since this is Jeff-only and uses the anon key from the browser,
-- we use a simple secret-header check pattern.
-- For now: disable RLS so the anon key can read/write freely.
-- (Your Supabase project is already used this way for Staff Hub.)
ALTER TABLE hq_state        DISABLE ROW LEVEL SECURITY;
ALTER TABLE hq_notes        DISABLE ROW LEVEL SECURITY;
ALTER TABLE hq_ai_cache     DISABLE ROW LEVEL SECURITY;
ALTER TABLE hq_vendor_skips DISABLE ROW LEVEL SECURITY;

-- ── Indexes for fast lookups ─────────────────────────────────
CREATE INDEX IF NOT EXISTS idx_hq_state_owner_scope ON hq_state (owner, scope_key);
CREATE INDEX IF NOT EXISTS idx_hq_notes_owner ON hq_notes (owner, captured_at DESC);
CREATE INDEX IF NOT EXISTS idx_hq_ai_cache_key ON hq_ai_cache (cache_key);
CREATE INDEX IF NOT EXISTS idx_hq_vendor_skips ON hq_vendor_skips (owner, week_key);

-- ── Done ─────────────────────────────────────────────────────
SELECT 'Daily HQ tables created successfully ✓' AS status;
