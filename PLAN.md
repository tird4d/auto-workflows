# Project 1: Customer Support Ticket Classifier Agent

## Business Case
Automatically triage incoming customer messages (email/webhook), classify the issue type, extract key data, notify the right team, and send a professional auto-response — reducing manual triage time and response latency.

## Goal for Interview Demo
Show a complete, working n8n workflow that goes from raw customer message → AI-powered understanding → structured storage/notification → automated reply, in under 5 minutes of live demo time.

---

## Workflow Steps (n8n Nodes)

1. **Trigger**
   - `Webhook` node (POST /support-ticket) — simplest for live demo (use curl/Postman/HTML form)
   - Alternative: `Email Trigger (IMAP)` node if demoing real inbox ingestion
   - Input payload: `{ customerId, customerEmail, message }`

2. **AI Agent — Classify & Extract**
   - `AI Agent` node (or `OpenAI`/`Azure OpenAI` Chat Model node) with a structured prompt
   - Use **Structured Output Parser** to force JSON:
     ```json
     {
       "category": "network_outage | database_issue | billing_invoice | other",
       "priority": "low | medium | high | critical",
       "customerId": "string",
       "summary": "string",
       "confidence": 0.0
     }
     ```
   - System prompt: define categories, ask for concise summary + priority reasoning

3. **Branching / Routing**
   - `IF` or `Switch` node on `category` / `priority`
   - Low-confidence branch (`confidence < 0.6`) → route to "needs human review" path (extra credit / robustness talking point)

4. **Persistence**
   - `MongoDB` or `Postgres` node — insert ticket record (customerId, category, priority, summary, timestamp, raw message)

5. **Notification**
   - `Slack` or `Microsoft Teams` node — post message to a channel based on category (e.g., #network-alerts, #billing, #db-issues)
   - Include priority as emoji/badge (🔴 critical, 🟡 medium, 🟢 low)

6. **Auto-Response to Customer**
   - `OpenAI`/`AI Agent` node — generate short, professional acknowledgment referencing the detected category and expected next steps
   - `Respond to Webhook` node (or `Send Email` node) to deliver the reply

---

## Data / Credentials Needed
- [ ] Azure OpenAI or OpenAI API key
- [ ] MongoDB or Postgres connection (can run locally via Docker)
- [ ] Slack or Teams webhook/incoming webhook URL (or mock with webhook.site)

## Demo Script (suggested)
1. Send a sample "network outage" message via curl/Postman.
2. Show n8n execution trace: webhook → AI classification JSON → DB insert → Slack notification → auto-reply.
3. Send a second message that's ambiguous/low-confidence → show it routes to human-review branch.
4. Briefly explain business value: faster triage, consistent categorization, less manual work.

## Stretch Goals (if time permits)
- Add retry/error handling node around the AI call
- Add a simple dashboard query (Postgres/Mongo) showing ticket counts by category
- Multi-language input handling (classify regardless of input language)

## Status
- [ ] Docker/n8n environment set up
- [ ] Credentials configured
- [ ] Workflow built
- [ ] Tested end-to-end
- [ ] Demo script rehearsed
