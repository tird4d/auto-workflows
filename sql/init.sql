CREATE TABLE IF NOT EXISTS tickets (
  id SERIAL PRIMARY KEY,
  customer_id TEXT,
  category TEXT NOT NULL,
  priority TEXT NOT NULL,
  summary TEXT,
  confidence NUMERIC(3,2),
  raw_message TEXT,
  status TEXT NOT NULL DEFAULT 'classified',
  cost_source TEXT,
  estimated_tokens INTEGER,
  estimated_cost_usd NUMERIC(10,6),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Safe to re-run against an already-existing table (e.g. this demo's Postgres).
ALTER TABLE tickets ADD COLUMN IF NOT EXISTS cost_source TEXT;
ALTER TABLE tickets ADD COLUMN IF NOT EXISTS estimated_tokens INTEGER;
ALTER TABLE tickets ADD COLUMN IF NOT EXISTS estimated_cost_usd NUMERIC(10,6);

