## 1. Upstream Contract Verification (Required before coding)

- [ ] 1.1 Pin and verify a stable Keycloak image tag and document the exact version target.
- [ ] 1.2 Verify current Keycloak container bootstrap admin env vars (legacy vs new naming) and DB env var contract.
- [ ] 1.3 Verify reverse-proxy settings required for Traefik TLS termination (hostname, proxy headers, HTTP/HTTPS behavior).
- [ ] 1.4 Verify health and metrics enablement env vars/endpoints/ports for the chosen Keycloak version.
- [ ] 1.5 Verify whether metrics endpoint auth/management port behavior requires special compose networking notes for observability.

## 2. Service Module Layout and Compose Design

- [ ] 2.1 Create `services/keycloak/` with compose fragment and multilingual README scaffolding.
- [ ] 2.2 Add `keycloak` and `keycloak-db` services with persistent volumes and internal network wiring.
- [ ] 2.2 Add `keycloak` and `keycloak-db` services with persistent volumes and internal network wiring (DB internal-only; no host port exposure by default).
- [ ] 2.3 Add Traefik HTTPS router labels for `https://keycloak.<DEV_DOMAIN>` with repo security middleware defaults.
- [ ] 2.4 Ensure no direct host port exposure for Keycloak UI/API by default (Traefik-only access path).
- [ ] 2.5 Define optional observability hooks in compose (metrics/log config/env) that remain safe when observability is disabled.
- [ ] 2.6 Define collector/scrape discovery strategy for Keycloak telemetry (container naming vs labels) and document the chosen pattern for future service parity.

## 3. Environment Variables and Bootstrap

- [ ] 3.1 Add `KEYCLOAK_*` / `KC_*` (version-confirmed names), DB, hostname, and observability toggle vars to `.env.example`.
- [ ] 3.2 Implement `scripts/keycloak-bootstrap.sh` to generate/persist admin and DB secrets idempotently (`--force` for rotation).
- [ ] 3.3 Add `make keycloak-bootstrap` and document secret rotation semantics.
- [ ] 3.4 Document safe defaults for local/lab deployment (reverse proxy, hostname, DB credentials generation, observability disabled by default).

## 4. Guardrails and Preflight Validation

- [ ] 4.1 Extend `scripts/validate-env.sh` with Keycloak profile-gated checks (hostname label, required secrets, non-placeholder values).
- [ ] 4.2 Validate reverse-proxy/TLS-related Keycloak settings combinations that could break Traefik exposure.
- [ ] 4.3 Validate observability-related Keycloak settings are safe by default (no public metrics router/port exposure unless explicitly documented).
- [ ] 4.4 Keep validation non-blocking when Keycloak profile is not enabled.

## 5. Makefile and Compose Wrapper Integration

- [ ] 5.1 Add `keycloak-up/down/restart/logs/status` Make targets using `scripts/compose.sh --profile keycloak`.
- [ ] 5.2 Add `make test-keycloak` for service-specific static smoke tests (and integrate with any existing per-service test pattern if present on the branch).
- [ ] 5.3 Ensure `make help` documents Keycloak lifecycle, bootstrap, and `test-keycloak` commands.
- [ ] 5.4 Keep compatibility with existing `ENV_FILE`, `COMPOSE_PROFILES`, and compose wrapper patterns.

## 6. Optional Observability Integration Preparation (Keycloak-specific)

- [ ] 6.1 Define and implement a service-level observability contract (metrics/log readiness) compatible with the Grafana/Prometheus/Loki/collector stack pattern used in the other project branch.
- [ ] 6.2 Add service-specific observability documentation section describing what is emitted/exposed and how it is consumed when observability is enabled.
- [ ] 6.3 Add smoke test coverage for observability wiring/toggles (static config tests only; no dependency on observability runtime stack).
- [ ] 6.4 Ensure Keycloak starts and works normally when observability is disabled.
- [ ] 6.5 (If applicable) Define Keycloak observability \"app pack\" assets (dashboards/queries/labels) layout so it can plug into the reusable observability stack without redesign.

## 7. Tests (Smoke + Runtime Checklist)

- [ ] 7.1 Add smoke test for Keycloak Make target wiring (including `test-keycloak`).
- [ ] 7.2 Add smoke test for Keycloak compose fragment (profile, labels, volumes, DB wiring).
- [ ] 7.3 Add smoke test for Keycloak guardrails.
- [ ] 7.4 Add smoke test for Keycloak observability wiring/toggle behavior (static assertions).
- [ ] 7.5 Document runtime manual validation checklist (bootstrap, up, login page via Traefik, admin/token/API sanity check, health checks, optional metrics reachability when enabled).
- [ ] 7.6 Document/validate that metrics or management endpoints are not publicly exposed by default through Traefik when observability is enabled.

## 8. Documentation (Root, Service, Scripts, Tests)

- [ ] 8.1 Update `README.md`, `README.es.md`, `README.sv.md` with Keycloak endpoint, profile, prerequisites, and commands.
- [ ] 8.2 Add `services/keycloak/README*.md` with architecture, bootstrap, lifecycle, security notes, observability option, and troubleshooting.
- [ ] 8.3 Update `scripts/README.md` with Keycloak scripts.
- [ ] 8.4 Update `tests/README.md` with Keycloak smoke tests and manual runtime validation notes.
- [ ] 8.5 Update `docs.manifest.json` to include Keycloak docs.
- [ ] 8.6 Document `ENDPOINTS`/hosts mapping and TLS mode A/B/C relevance for `keycloak` hostname.

## 9. Validation and Handoff

- [ ] 9.1 Run `openspec validate add-keycloak-service-module --strict`.
- [ ] 9.2 Run `bash -n` for new scripts/tests.
- [ ] 9.3 Run Keycloak smoke tests (`make test-keycloak`) and `make docs-check`.
- [ ] 9.4 Perform runtime validation (`keycloak-bootstrap`, `keycloak-up`, Traefik login page + admin/token/API sanity, health checks) and document results/gaps.
- [ ] 9.5 Validate observability default safety in runtime/config (no public metrics exposure by default; optional telemetry path behavior documented).
- [ ] 9.6 Update this `tasks.md` to reflect only actually completed work.
