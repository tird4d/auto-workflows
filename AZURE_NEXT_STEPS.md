# Azure Integration — Next Session Tasks

_Created: 2026-08-14_

## Current Status ✅
- Azure CLI installed + logged in (subscription "Azure subscription 1", tenant `Amaj`).
- Azure OpenAI resource created: `aoai-ticket-classifier` (resource group `rg-ticket-classifier`, region `westeurope`), Foundry-style resource on the `.services.ai.azure.com` domain.
- Two model deployments live: `gpt-5.4-mini` (chat) and `text-embedding-3-small` (embeddings, **not currently used** — embeddings still on plain OpenAI by choice).
- `workflows/ticket-classifier.json` updated: `OpenAI Chat Model` node replaced with `Azure OpenAI Chat Model` (`lmChatAzureOpenAi`), wired into `AI Agent - Classify & Extract`.
- n8n credential fixed and confirmed working: Endpoint = `https://abbasitirdad-1508-resource.services.ai.azure.com`, API Version = `2024-10-21` (the n8n-default `2025-03-01-preview` failed with "API version not supported" — root cause never fully isolated, but `2024-10-21` is proven working via curl + in n8n).
- `.env` updated with `AZURE_OPENAI_API_KEY`, `AZURE_OPENAI_ENDPOINT`, `AZURE_OPENAI_CHAT_DEPLOYMENT_NAME`, `AZURE_OPENAI_EMBEDDING_DEPLOYMENT_NAME` — confirmed gitignored, not committed.

## Immediate Follow-ups (Phase 1 cleanup)
1. **Retest the full pipeline end-to-end** with the Azure-backed Chat Model — cold cache miss, cache hit, low-confidence escalation branch — not just the single node test done so far.
2. **Cost-tracking numbers are now stale** — `Compute Classification Cost` node's pricing constants ($0.15/$0.60 per 1M tokens) were based on `gpt-4o-mini`. Either update to real `gpt-5.4-mini` pricing (check Azure pricing page) or verbally caveat in the interview that the dollar figures are illustrative/heuristic, not exact for the current model.
3. **Update `temp/01 - Support Ticket Classifier (1).json`** (the other canonical live-export copy) to match the same Azure swap made in `workflows/ticket-classifier.json` — currently only one of the two files has this change.
4. **Update `SESSION_HANDOFF.md`** with the Azure credential setup steps so a fresh machine/session can reproduce it (mirrors the existing OpenAI credential documentation style already in that file).
5. Confirm the live n8n workflow (not just the JSON file) has actually been saved/activated with this node swap — re-verify after a container restart that credentials persist.

## Phase 2 — Second Azure-native Artifact (scope small, per prior discussion)
6. **Port the classification agent into a Microsoft Foundry Prompt Agent** (ai.azure.com): reuse the exact system prompt + JSON output schema from `AI Agent - Classify & Extract` — no new design work, just re-entering it in the Foundry portal. Test with 3-5 of the same sample tickets used in n8n to confirm matching output.
7. Optionally screenshot/record both running side-by-side (n8n pipeline vs. Foundry Prompt Agent) as a backup artifact in case live demo access is flaky during the interview.

## Interview Narrative Prep (no build needed, just talking points)
8. Prepare the mapping explanation: n8n workflow ≈ Logic Apps workflow; n8n AI Agent node ≈ Foundry Prompt Agent; Redis Vector Store cache ≈ Azure AI Search; LangChain (underlying n8n) ≈ Microsoft Agent Framework (Semantic Kernel + AutoGen successor).
9. Prepare an honest answer for "why is embeddings still on OpenAI, not Azure" — reasonable answer: cache/vector correctness doesn't depend on provider, swapped the highest-signal piece (the reasoning model) first under time constraints.
10. Rehearse explaining the `2025-03-01-preview` → `2024-10-21` API version debugging story — it's a good "real engineering troubleshooting" anecdote (methodical curl-based isolation instead of guessing).

## Housekeeping / Cost Hygiene
11. **No idle cost confirmed** — deployments are `Standard`/`S0` (pay-per-token), not Provisioned/PTU, so sitting unused between now and the interview costs $0. Only actual request tokens are billed. No need to tear down `rg-ticket-classifier` before the interview.
12. Double check no Azure keys ever get pasted into a shared file, ticket, or committed — `.env` confirmed gitignored, but re-verify before any `git push`.
13. Clean up the superseded `temp/01 - Support Ticket Classifier.json` (older export, already superseded) if it's just adding confusion — or clearly mark it as archived.
