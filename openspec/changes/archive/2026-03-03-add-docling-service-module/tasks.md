## 1. Upstream Contract Verification (before coding)
- [x] 1.1 Verify and pin Docling image/tag strategy (CPU default, optional GPU variants) for selected release/channel.
- [x] 1.2 Verify Docling environment contract for API/UI, root-path/proxy headers, model cache/artifacts, and engine mode.
- [x] 1.3 Verify Docling reverse-proxy guidance behind Traefik TLS termination and forwarded headers.
- [x] 1.4 Verify Keycloak-compatible auth pattern (API key and/or oauth-proxy/forward-auth contract) and required env settings.
- [x] 1.5 Verify Docling observability surfaces (metrics/traces/logs) and safe defaults.

## 2. Docling Service Module Layout and Compose Wiring
- [x] 2.1 Create `services/docling/` with `compose.yml` and multilingual README scaffolding.
- [x] 2.2 Add Docling app service and required dependencies with pinned image strategy.
- [x] 2.3 Wire Traefik routers/middlewares for `https://docling.<DEV_DOMAIN>` using repo conventions.
- [x] 2.4 Keep module dependencies internal-only by default (no host/public exposure).
- [x] 2.5 Add persistent volumes for model/artifact/cache data where applicable.
- [x] 2.6 Add startup coordination/healthchecks to reduce dependency race conditions.

## 3. Optional Integration Contracts (Step-CA / Keycloak / Observability)
- [x] 3.1 Ensure Docling routers use existing `TLS_CERT_RESOLVER` behavior (Mode A/B/C compatible).
- [x] 3.2 Add optional Keycloak integration toggles/env vars (disabled by default).
- [x] 3.3 Support Keycloak integration with either local `keycloak` profile deployment or external Keycloak endpoint.
- [x] 3.4 Add optional observability discovery/wiring hooks for Docling telemetry without hard dependency on `observability` profile.
- [x] 3.5 Ensure Docling works unchanged when all optional integrations are disabled.

## 4. Environment Template and Bootstrap
- [x] 4.1 Add `DOCLING_*` (and integration toggle) variables to `.env.example` with safe defaults.
- [x] 4.2 Implement `scripts/docling-bootstrap.sh` to generate/persist required Docling secrets idempotently.
- [x] 4.3 Add explicit secret rotation mode/flag for bootstrap.
- [x] 4.4 Add `make docling-bootstrap` target and help text.

## 5. Guardrails and Validation
- [x] 5.1 Extend `scripts/validate-env.sh` with profile-gated Docling checks (hostname, auth/secret contract, unsafe placeholders).
- [x] 5.2 Add Keycloak-specific validation only when Docling auth integration is enabled.
- [x] 5.3 Add observability-related validation that does not block Docling when observability is disabled.
- [x] 5.4 Keep all Docling checks non-blocking when the `docling` profile is not enabled.

## 6. Makefile / Compose Wrapper Integration
- [x] 6.1 Add `docling-up/down/restart/logs/status` targets using `scripts/compose.sh --profile docling`.
- [x] 6.2 Add `test-docling` target for Docling smoke tests.
- [x] 6.3 Ensure `make help` documents Docling lifecycle/bootstrap/test commands.

## 7. Smoke Tests
- [x] 7.1 Add `tests/smoke/test_docling_service_config.sh` for compose wiring, labels, and exposure rules.
- [x] 7.2 Add `tests/smoke/test_docling_guardrails.sh` for profile-gated preflight behavior.
- [x] 7.3 Add `tests/smoke/test_docling_make_targets.sh` for Makefile wiring/help output.
- [x] 7.4 Add `tests/smoke/test_docling_bootstrap_env.sh` for secret generation + idempotency.
- [x] 7.5 Add `tests/smoke/test_docling_optional_integrations.sh` for static Step-CA/Keycloak/observability toggle behavior.
- [x] 7.6 Integrate Docling smoke suite into `scripts/healthcheck.sh` service-aware execution.

## 8. Documentation
- [x] 8.1 Update `README.md` with Docling endpoint/profile and integration notes.
- [x] 8.2 Update `README.es.md` with matching Docling content.
- [x] 8.3 Update `README.sv.md` with matching Docling content.
- [x] 8.4 Add `services/docling/README.md` with architecture/bootstrap/lifecycle and troubleshooting.
- [x] 8.5 Add `services/docling/README.es.md` with structural parity.
- [x] 8.6 Add `services/docling/README.sv.md` with structural parity.
- [x] 8.7 Update `scripts/README.md`, `tests/README.md`, and `docs.manifest.json` for Docling assets.
- [x] 8.8 Document hosts/ENDPOINTS updates for `docling` and optional `keycloak` endpoint interactions.

## 9. Validation and Handoff
- [x] 9.1 Run `openspec validate add-docling-service-module --strict`.
- [x] 9.2 Run `make docs-check`.
- [x] 9.3 Run Docling smoke tests individually plus `make test-docling`.
- [x] 9.4 Run `make test` and record unrelated pre-existing failures separately.
