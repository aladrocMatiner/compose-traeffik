## 1. Upstream Contract Verification (Required before coding)

- [x] 1.1 Pin and verify a stable `semaphoreui/semaphore` image tag and document the exact version target.
- [x] 1.2 Verify current Semaphore Docker env contract for DB config, admin bootstrap, and required crypto/session secrets.
- [x] 1.3 Verify reverse-proxy behavior/settings required for Traefik TLS termination (hostname/web root/proxy headers/websocket paths).
- [x] 1.4 Verify OIDC provider configuration contract (JSON env var name/format, redirect URL pattern, optional password-login disable flags).
- [x] 1.5 Verify healthcheck/API endpoint(s) suitable for compose health checks and runtime validation.
- [x] 1.6 Verify observability capabilities (metrics endpoint if any, log behavior, auth requirements) and document the supported observability mode for this module.

## 2. Service Module Layout and Compose Design

- [x] 2.1 Create `services/semaphoreui/` with `compose.yml` and multilingual `README*.md` scaffolding.
- [x] 2.2 Add `semaphoreui` + `semaphoreui-db` services with persistent volumes and internal network wiring.
- [x] 2.3 Keep PostgreSQL internal-only by default (no host port exposure).
- [x] 2.4 Add Traefik HTTPS router labels for `https://semaphore.<DEV_DOMAIN>` using repo security middleware defaults.
- [x] 2.5 Ensure no direct host port exposure for Semaphore UI/API by default (Traefik-only access path).
- [x] 2.6 Add optional observability hooks (env/labels) that are inert/safe when observability is disabled.
- [x] 2.7 Define and document the collector/scrape discovery strategy used for Semaphore telemetry (labels preferred unless upstream constraints force naming).

## 3. Environment Variables and Bootstrap

- [x] 3.1 Add `SEMAPHOREUI_*` repo-level variables to `.env.example` (hostname, DB, admin, crypto, OIDC toggles, observability toggles).
- [x] 3.2 Implement `scripts/semaphoreui-bootstrap.sh` to generate/persist required secrets idempotently (`--force` rotation).
- [x] 3.3 Generate and persist OIDC provider JSON from repo-level Keycloak/OIDC variables when OIDC is enabled (or keep placeholder/disabled defaults when not enabled).
- [x] 3.4 Add `make semaphoreui-bootstrap` and document secret rotation semantics.
- [x] 3.5 Document safe defaults for local/lab deployment (subdomain Traefik path, internal DB, local admin, OIDC disabled, observability disabled).

## 4. Guardrails and Preflight Validation

- [x] 4.1 Extend `scripts/validate-env.sh` with `semaphoreui` profile-gated checks (hostname, required secrets, non-placeholder values).
- [x] 4.2 Validate OIDC-related settings only when OIDC is enabled (issuer/metadata URL, client ID/secret, redirect path assumptions where applicable).
- [x] 4.3 Validate observability settings remain safe by default (no public metrics exposure toggle enabled by default; supported modes only).
- [x] 4.4 Keep validation non-blocking when the `semaphoreui` profile is not enabled.

## 5. Makefile and Compose Wrapper Integration

- [x] 5.1 Add `semaphoreui-up/down/restart/logs/status` Make targets using `scripts/compose.sh --profile semaphoreui`.
- [x] 5.2 Add `make test-semaphoreui` for service-specific static smoke tests.
- [x] 5.3 Ensure `make help` documents Semaphore UI lifecycle, bootstrap, and `test-semaphoreui` commands.
- [x] 5.4 Keep compatibility with existing `ENV_FILE`, `COMPOSE_PROFILES`, and compose wrapper patterns.
- [x] 5.5 Register Semaphore UI smoke tests in the repo test runner path (`scripts/healthcheck.sh` and docs inventory) so `make test` coverage remains consistent with branch conventions.

## 6. Optional Keycloak (OIDC) Integration

- [x] 6.1 Define a repo-level OIDC option contract for Semaphore UI that maps cleanly to Keycloak (realm/client/provider URL) without requiring the Keycloak module.
- [x] 6.2 Add docs for using an external Keycloak and (if later merged) an in-repo Keycloak hostname.
- [x] 6.3 Add smoke tests for OIDC config wiring (static assertions only; no full Keycloak runtime dependency).
- [x] 6.4 Document reverse-proxy/OIDC pitfalls (issuer mismatch, redirect URI mismatch, HTTPS hostname, proxy headers).

## 7. Optional Observability Integration Preparation (Semaphore-specific)

- [x] 7.1 Define and implement a Semaphore observability contract compatible with the reusable Grafana/Prometheus/Loki/collector stack pattern.
- [x] 7.2 Add service-specific observability docs describing what is emitted/exposed (logs and metrics if available), auth requirements, and how to integrate when observability is enabled.
- [x] 7.3 Add smoke test coverage for observability wiring/toggles (static config tests only; no observability stack runtime dependency).
- [x] 7.4 Ensure Semaphore works normally when observability is disabled.
- [x] 7.5 Define a future-proof layout for Semaphore observability app-pack assets (dashboards/queries/labels) if metrics/log dashboards are included later.

## 8. Tests (Smoke + Runtime Checklist)

- [x] 8.1 Add smoke test for Semaphore UI Make target wiring (including `test-semaphoreui`).
- [x] 8.2 Add smoke test for Semaphore UI compose fragment (profile, labels, volumes, DB wiring, no host ports).
- [x] 8.3 Add smoke test for Semaphore UI guardrails.
- [x] 8.4 Add smoke test for OIDC wiring (static assertions).
- [x] 8.5 Add smoke test for observability wiring/toggle behavior (static assertions).
- [x] 8.6 Document runtime manual validation checklist (bootstrap, up, Traefik UI, admin login, API ping, optional OIDC redirect sanity, optional telemetry checks).
- [x] 8.7 Document/validate that metrics or management endpoints are not publicly exposed by default through Traefik.
- [x] 8.8 Add/verify smoke test coverage for test-runner wiring (e.g. `make test` / `scripts/healthcheck.sh`) if branch patterns require explicit registration checks.

## 9. Documentation (Root, Service, Scripts, Tests)

- [x] 9.1 Update `README.md`, `README.es.md`, `README.sv.md` with Semaphore UI endpoint, profile, prerequisites, and commands.
- [x] 9.2 Add `services/semaphoreui/README*.md` with architecture, bootstrap, lifecycle, security notes, OIDC option, observability option, and troubleshooting.
- [x] 9.3 Add `services/semaphoreui/observability/README*.md` (or equivalent section/docs) describing observability integration contract.
- [x] 9.4 Update `scripts/README.md` with Semaphore UI scripts.
- [x] 9.5 Update `tests/README.md` with Semaphore UI smoke tests and runtime validation notes.
- [x] 9.6 Update `docs.manifest.json` to include Semaphore UI docs.
- [x] 9.7 Document `ENDPOINTS`/hosts mapping and TLS mode A/B/C relevance for the `semaphore` hostname.

## 10. Validation and Handoff

- [x] 10.1 Run `openspec validate add-semaphoreui-service-module --strict`.
- [x] 10.2 Run `bash -n` for new scripts/tests.
- [x] 10.3 Run Semaphore UI smoke tests (`make test-semaphoreui`) and `make docs-check`.
- [x] 10.4 Perform runtime validation (`semaphoreui-bootstrap`, `semaphoreui-up`, Traefik UI/API sanity, health checks) and document results/gaps.
- [x] 10.5 Validate OIDC/observability default safety in runtime/config (OIDC disabled by default; no public telemetry exposure by default).
- [x] 10.6 Update this `tasks.md` to reflect only actually completed work.
