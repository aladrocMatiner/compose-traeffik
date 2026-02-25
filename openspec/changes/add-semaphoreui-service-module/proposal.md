# Change: Add Semaphore UI Service Module with Traefik, Optional Keycloak OIDC, and Observability Hooks

## Why
Semaphore UI is a good fit for this repository's self-hosted automation pattern (Compose + Traefik + Make + docs/tests), but the project currently lacks a service module for it.

The requested deployment also needs two optional integrations from day one:
- Keycloak (OIDC login)
- observability hooks compatible with the Grafana/Prometheus/Loki/collector stack used in another branch

## What Changes
- Add a new `semaphoreui` service module under `services/semaphoreui/` with Traefik HTTPS routing.
- Add an internal PostgreSQL service for Semaphore UI (no host port exposure by default).
- Add `make semaphoreui-bootstrap/up/down/restart/logs/status` targets using the compose wrapper.
- Add profile-gated guardrails and bootstrap secret generation for Semaphore UI.
- Add optional Keycloak OIDC configuration (disabled by default) with repo-level `.env` toggles and documented mapping to Semaphore's `SEMAPHORE_*` settings.
- Add optional observability hooks (safe defaults, no public metrics/management exposure by default) and docs/tests for integration with the reusable observability stack.
- Add service docs (`README*.md`), root docs updates, scripts/tests docs updates, and smoke tests.

## Non-Goals
- Shipping the full Grafana/Prometheus/Loki/collector stack in this change.
- Shipping a Keycloak service module in this branch (Semaphore should support external or future in-repo Keycloak).
- Production hardening beyond the repo's standard local/lab defaults.

## Impact
- Affected specs:
  - `semaphoreui-service` (new)
  - `bootstrap-secrets`
  - `compose-wrapper`
  - `guardrails`
  - `docs-endpoints-tls`
  - `docs-multilang`
  - `scripts-docs`
  - `tests-docs`
  - `tests-suite`
- Affected code (planned):
  - `services/semaphoreui/*`
  - `scripts/semaphoreui-bootstrap.sh`
  - `scripts/validate-env.sh`
  - `scripts/compose.sh`
  - `Makefile`
  - `.env.example`
  - `README*.md`, `scripts/README.md`, `tests/README.md`, `docs.manifest.json`
