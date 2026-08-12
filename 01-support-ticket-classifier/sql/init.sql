CREATE TABLE IF NOT EXISTS tickets (
  id SERIAL PRIMARY KEY,
  customer_id TEXT,
  category TEXT NOT NULL,
  priority TEXT NOT NULL,
  summary TEXT,
  confidence NUMERIC(3,2),
  raw_message TEXT,
  status TEXT NOT NULL DEFAULT 'classified',
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
