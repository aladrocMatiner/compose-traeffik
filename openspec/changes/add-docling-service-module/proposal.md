# Change: Add Docling service module (Traefik + Step-CA, Keycloak, Observability integration contracts)

## Why
The repository currently provides edge/TLS tooling and optional service modules, but it lacks a first-class document-conversion API service. Docling is a strong fit for OCR/parsing workflows and should follow the same module conventions used by the stack: profile-gated activation, Traefik-only ingress, preflight guardrails, bootstrap scripts, smoke tests, and multilingual docs.

The requested rollout must integrate with Step-CA, Keycloak, and observability. Docling should remain usable in baseline mode while exposing explicit contracts for these integrations.

## Discovery Summary (for implementer)
- Docling Serve publishes official container images on `ghcr.io` and `quay.io` with CPU and GPU variants.
- The service exposes API, OpenAPI docs, and optional UI (`DOCLING_SERVE_ENABLE_UI`) on port `5001`.
- Runtime supports API-key auth (`DOCLING_SERVE_API_KEY`) and an OAuth-proxy pattern in deployment examples.
- Reverse-proxy compatibility is configurable via Uvicorn settings (`UVICORN_ROOT_PATH`, `UVICORN_PROXY_HEADERS`).
- Observability hooks are available via built-in OTEL/Prometheus toggles (`DOCLING_SERVE_OTEL_*`, `OTEL_EXPORTER_OTLP_ENDPOINT`).
- Async scaling can use local workers or Redis/RQ (`DOCLING_SERVE_ENG_KIND=rq` + `DOCLING_SERVE_ENG_RQ_REDIS_URL`).

## What Changes
- Add a new optional Docling module under `services/docling/` (profile `docling`) with Traefik HTTPS routing at `https://docling.<DEV_DOMAIN>`.
- Add Docling application service and module-scoped dependencies (as required by selected engine mode), with pinned image strategy.
- Keep public access through Traefik only, with internal-only defaults for stateful dependencies.
- Add `.env.example` variables and `make docling-bootstrap` for idempotent secret/bootstrap generation.
- Add `make docling-up/down/restart/logs/status` and `make test-docling` targets using the shared compose wrapper.
- Add profile-gated preflight guardrails for Docling core config and integration-aware checks for Keycloak/observability.
- Define Step-CA compatibility through existing TLS resolver contract (no Docling-specific TLS branching).
- Define Keycloak integration contract at ingress/auth-proxy layer, supporting local profile or external IdP endpoint.
- Define optional observability hooks for metrics/traces/log discovery without hard dependency on observability profile.

## Non-Goals (Phase 1)
- Full production HA and autoscaling for Docling workers.
- End-to-end Keycloak realm/client provisioning automation.
- Mandatory GPU deployment mode in the default profile.
- Broad multi-tenant policy framework beyond existing stack guardrails.

## Impact
- Affected specs:
  - `docling-service` (new)
  - `compose-wrapper`
  - `bootstrap-secrets`
  - `guardrails`
  - `docs-endpoints-tls`
  - `tests-suite`
- Affected code/docs (planned):
  - `services/docling/compose.yml`
  - `services/docling/README*.md`
  - `.env.example`
  - `scripts/docling-bootstrap.sh`
  - `scripts/validate-env.sh`
  - `Makefile`
  - `scripts/healthcheck.sh`
  - `tests/smoke/*docling*`
  - `README*.md`, `scripts/README.md`, `tests/README.md`, `docs.manifest.json`

## Dependencies / Order
- Docling MUST stay deployable with baseline stack settings (without requiring Keycloak and observability).
- Step-CA integration MUST remain via the existing `TLS_CERT_RESOLVER` contract.
- If local Keycloak services are unavailable, integration MUST still support external Keycloak-compatible auth endpoint/proxy.
- Observability integration MUST be additive and non-blocking when disabled.
