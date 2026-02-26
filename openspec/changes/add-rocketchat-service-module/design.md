## Context

Rocket.Chat requires stateful dependencies (MongoDB replica set and NATS in current upstream compose examples) and has app-level settings that are commonly configured from the UI (for example, custom OAuth/Keycloak). This repo prefers reproducible, profile-driven compose modules with preflight guardrails, documented Make targets, and multilingual docs.

## Goals / Non-Goals

- Goals:
  - Add a reproducible Rocket.Chat module behind Traefik using the repo's compose layering strategy.
  - Keep Keycloak and observability optional with explicit defaults and guardrails.
  - Provide bootstrap rendering so runtime env/config files are deterministic and testable.
  - Add static smoke tests that validate wiring without requiring a full Rocket.Chat runtime startup.
- Non-Goals:
  - Fully automate Keycloak provider creation inside Rocket.Chat via API/admin credentials.
  - Ship a Prometheus/Grafana stack in this change.
  - Add backup/restore/upgrade day-2 workflows for Rocket.Chat in this change.

## Decisions

- Decision: Use a dedicated `rocketchat` profile with `rocketchat`, `rocketchat-mongodb`, `rocketchat-mongodb-init`, and `rocketchat-nats` services.
  - Why: Keeps the default stack lightweight while supporting current Rocket.Chat dependency expectations.

- Decision: Render a Rocket.Chat env file and a Keycloak setup checklist into `services/rocketchat/rendered/` via `rocketchat-bootstrap`.
  - Why: Rocket.Chat consumes env vars for runtime settings, and Keycloak custom OAuth still needs manual UI setup in many environments. Rendering a checklist from `.env` provides reproducible inputs without pretending to fully automate UI state.

- Decision: Treat observability as optional hooks (`ROCKETCHAT_OBSERVABILITY_ENABLED`) using Rocket.Chat Prometheus settings and internal scrape labels, disabled by default.
  - Why: Matches the repo's pattern of safe-by-default optional integrations and avoids public telemetry exposure.

- Decision: Add preflight guardrails for Rocket.Chat only when the `rocketchat` profile or Rocket.Chat optional toggles are used.
  - Why: Preserve existing workflows and avoid burdening unrelated stack usage.

## Risks / Trade-offs

- Risk: Rocket.Chat upstream deployment guidance evolves (image tags, dependency expectations).
  - Mitigation: Pin versions in `.env.example`, reference upstream compose/docs in the proposal docs, and keep service wiring modular.

- Risk: Keycloak configuration is partially manual in Rocket.Chat UI.
  - Mitigation: Render exact callback URL and endpoint paths from `.env` into a runbook file and document the limitations clearly.

- Risk: The Rocket.Chat profile adds several containers and can be resource-heavy on dev machines.
  - Mitigation: Keep it profile-gated and provide dedicated lifecycle targets.

## Migration Plan

1. Add Rocket.Chat compose file and scripts.
2. Wire compose wrapper and Make targets.
3. Add env vars and preflight validation.
4. Add smoke tests and documentation.
5. Validate OpenSpec/docs/tests.

## Open Questions

- None for this implementation scope (manual Keycloak UI setup is explicitly documented as a non-goal for automation).
