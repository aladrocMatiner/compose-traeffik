## 1. Upstream Contract Verification (before coding)
- [x] 1.1 Verify and pin the Plane image/tag strategy and required service topology for the selected Plane release.
- [x] 1.2 Verify Plane environment variables for app secrets, public URLs, database/cache/object storage, and worker/background services.
- [x] 1.3 Verify Plane reverse-proxy guidance for Traefik TLS termination and forwarded headers.
- [x] 1.4 Verify Plane OIDC/SSO settings needed for Keycloak integration and document required env contract.
- [x] 1.5 Verify Plane observability surfaces (logs, metrics, traces if supported) and safe defaults.

## 2. Plane Service Module Layout and Compose Wiring
- [x] 2.1 Create `services/plane/` with `compose.yml` and multilingual README scaffolding.
- [x] 2.2 Add Plane application services and required stateful dependencies with pinned images.
- [x] 2.3 Wire Traefik routers/middlewares for `https://plane.<DEV_DOMAIN>` using repo conventions.
- [x] 2.4 Keep stateful dependencies internal-only by default (no host/public exposure).
- [x] 2.5 Add persistent volumes for Plane application data and dependencies.
- [x] 2.6 Add startup coordination/healthchecks to reduce dependency race conditions.

## 3. Optional Integration Contracts (Step-CA / Keycloak / Observability)
- [x] 3.1 Ensure Plane routers use existing `TLS_CERT_RESOLVER` behavior so Mode A/B/C keeps working without special-case logic.
- [x] 3.2 Add optional Keycloak OIDC configuration flags/env vars (disabled by default).
- [x] 3.3 Support Keycloak integration with either local `keycloak` profile deployment or external Keycloak URL.
- [x] 3.4 Add optional observability discovery/wiring hooks for Plane telemetry without hard dependency on the observability profile.
- [x] 3.5 Ensure Plane works unchanged when all optional integrations are disabled.

## 4. Environment Template and Bootstrap
- [x] 4.1 Add `PLANE_*` (and integration toggle) variables to `.env.example` with safe defaults.
- [x] 4.2 Implement `scripts/plane-bootstrap.sh` to generate/persist required Plane secrets idempotently.
- [x] 4.3 Add explicit secret rotation mode/flag for bootstrap.
- [x] 4.4 Add `make plane-bootstrap` target and help text.

## 5. Guardrails and Validation
- [x] 5.1 Extend `scripts/validate-env.sh` with profile-gated Plane checks (hostname, required secrets, unsafe placeholders).
- [x] 5.2 Add Keycloak-specific validation only when Plane OIDC integration is enabled.
- [x] 5.3 Add observability-related validation that does not block Plane when observability is disabled.
- [x] 5.4 Keep all Plane checks non-blocking when the `plane` profile is not enabled.

## 6. Makefile / Compose Wrapper Integration
- [x] 6.1 Add `plane-up/down/restart/logs/status` targets using `scripts/compose.sh --profile plane`.
- [x] 6.2 Add `test-plane` target for Plane smoke tests.
- [x] 6.3 Ensure `make help` documents Plane lifecycle/bootstrap/test commands.

## 7. Smoke Tests
- [x] 7.1 Add `tests/smoke/test_plane_service_config.sh` for compose wiring, labels, and exposure rules.
- [x] 7.2 Add `tests/smoke/test_plane_guardrails.sh` for profile-gated preflight behavior.
- [x] 7.3 Add `tests/smoke/test_plane_make_targets.sh` for Makefile wiring/help output.
- [x] 7.4 Add `tests/smoke/test_plane_bootstrap_env.sh` for secret generation + idempotency.
- [x] 7.5 Add `tests/smoke/test_plane_optional_integrations.sh` for static Keycloak/observability toggle behavior.
- [x] 7.6 Integrate Plane smoke suite into `scripts/healthcheck.sh` service-aware execution.

## 8. Documentation
- [x] 8.1 Update `README.md` with Plane endpoint/profile and optional integration notes.
- [x] 8.2 Update `README.es.md` with matching Plane content.
- [x] 8.3 Update `README.sv.md` with matching Plane content.
- [x] 8.4 Add `services/plane/README.md` with architecture/bootstrap/lifecycle and troubleshooting.
- [x] 8.5 Add `services/plane/README.es.md` with structural parity.
- [x] 8.6 Add `services/plane/README.sv.md` with structural parity.
- [x] 8.7 Update `scripts/README.md`, `tests/README.md`, and `docs.manifest.json` for Plane assets.
- [x] 8.8 Document hosts/ENDPOINTS updates for `plane` and optional `keycloak` endpoint interactions.

## 9. Validation and Handoff
- [x] 9.1 Run `openspec validate add-plane-service-module --strict`.
- [x] 9.2 Run `make docs-check`.
- [x] 9.3 Run Plane smoke tests individually plus `make test-plane`.
- [x] 9.4 Run `make test` and record unrelated pre-existing failures separately.
