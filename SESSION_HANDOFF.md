# Session Handoff — Project 1: Support Ticket Classifier

_Last updated: 2026-08-13_

## Current Status: Core pipeline working end-to-end ✅

### What's done
- Docker Desktop (Windows, WSL2 integration) upgraded to 4.86.0 — fixed an "invalid tar header" image pull bug caused by an old Docker version.
- `docker-compose.yml` + `.env` set up in this folder — runs **n8n** (port 5678) + **Postgres** (port 5432).
- `.env` has all real values filled in (bringing the same `.env` file to the new PC covers this — do not duplicate secrets here):
  - n8n basic auth user/password
  - Postgres db name/user/password
  - `OPENAI_API_KEY` filled in and **has billing credits added**
  - `SLACK_WEBHOOK_URL` still empty (not set up yet)
- n8n Community Edition license key activated (Settings → Usage and plan).
- `sql/init.sql` was run manually against the `support_tickets` database to create the `tickets` table (has `id SERIAL PRIMARY KEY, customer_id, category, priority, summary, confidence, raw_message, status, created_at`).
- Workflow imported into n8n from `workflows/ticket-classifier.json`:
  **Webhook → AI Agent (classify + extract, structured JSON output) → Postgres insert → IF (confidence >= 0.6) → Slack notify (HTTP Request) → OpenAI auto-reply draft → Respond to Webhook** (with a "needs review" branch for low confidence).
- Credentials configured **directly in n8n UI** (not from `.env` — n8n stores credentials in its own encrypted DB):
  - OpenAI API credential — used by "OpenAI Chat Model" and "OpenAI - Draft Auto Reply" nodes.
  - Postgres credential — Host `postgres` (docker network hostname, NOT `localhost`), Database matching `POSTGRES_DB` in `.env`, user/password matching `.env`.
- Fixed 2 bugs found during testing:
  1. `customer_id` was storing the literal unresolved text `{{ $json.body.customerId }}` because the AI echoed back an unevaluated expression. **Fix applied**: Postgres node's `customer_id` column now reads `={{ $('Webhook - New Ticket').item.json.body.customerId || $json.output.customerId }}` — pulls straight from the trusted webhook payload, not the AI's echo. (Already fixed in `workflows/ticket-classifier.json` AND manually in the live n8n workflow.)
  2. The Postgres node's column mapping accidentally started including an `id` column (defaulting to `0`, breaking auto-increment). **Fix**: removed `id` (and `created_at`) from the mapped columns in the "Postgres - Insert Ticket" node — let Postgres auto-generate both via the sequence/default.
- Verified working test:
  ```bash
  curl -X POST http://localhost:5678/webhook/support-ticket \
    -H 'Content-Type: application/json' \
    -d '{"customerId":"CUST-1001","message":"Our main office has had zero internet connectivity since 9am, this is urgent."}'
  ```
  Correctly classified as `network_outage` / `critical` / confidence `0.95`, and correctly inserted into Postgres with proper auto-incrementing `id` and correct `customer_id`.

### Not done yet — pick up here tomorrow
1. **Slack notification** — `SLACK_WEBHOOK_URL` is empty. Decide: real Slack Incoming Webhook, or mock with a `webhook.site` URL for the demo. Then set it in `.env` and `docker compose restart n8n`.
2. **Verify the auto-reply step** — "OpenAI - Draft Auto Reply" node hasn't been explicitly confirmed to output good text yet (check via `docker compose logs n8n` or the n8n execution view after a successful run).
3. **Test the low-confidence branch** — send an ambiguous/ vague message and confirm it routes to "Notify Slack - Escalation" → "Respond - Needs Review" instead of the main success path.
4. **Rehearse the demo script** from `PLAN.md`.
5. **Project 2 (Document/Contract Analyzer)** — not started yet at all. Its plan is in the sibling folder `02-document-contract-analyzer/PLAN.md` (note: user said they moved this folder "for better control" — confirm its current location on the new PC).

### Key facts / gotchas for the new PC
- This setup requires **Docker Desktop with WSL2 integration** on Windows — check `docker --version` is reasonably current (v24+) before starting; old versions fail to pull images with "invalid tar header".
- Must `cd` into `01-support-ticket-classifier/` before running any `docker compose` command — it only looks for `docker-compose.yml` in the current directory.
- n8n credentials (OpenAI, Postgres) are stored inside n8n's own database (the `n8n_data` Docker volume) — they will NOT exist on a fresh setup on the new PC. If starting fresh containers there, you'll need to recreate both credentials and re-run `sql/init.sql`.
- `.env` contains a real OpenAI API key — keep it out of git (already covered by root `.gitignore`).
- To bring the exact same data/state to the new PC, you'd need to copy the Docker volumes too (`01-support-ticket-classifier_n8n_data`, `01-support-ticket-classifier_postgres_data`), not just the project files. If that's not feasible, plan to redo credential setup + re-import the workflow JSON on the new machine.
