# Change: Add Plane service module (Traefik + optional Step-CA, Keycloak, Observability)

## Why
The repository currently includes edge/TLS utilities and optional app modules, but it does not provide a first-class project-management service. Plane is a strong fit for self-hosted planning workflows and should follow the same module patterns already used in the repository: profile-gated activation, Traefik-only ingress, preflight guardrails, bootstrap scripts, smoke tests, and multilingual documentation.

The user also requires the Plane integration to keep `stepca`, `keycloak`, and `observability` optional. This means Plane must run safely without those modules, while still offering clean integration hooks when operators enable them.

## Discovery Summary (for implementer)
- Service modules are organized under `services/<module>/compose.yml` and orchestrated via `scripts/compose.sh` + `Makefile` lifecycle targets.
- Preflight validation is centralized in `scripts/validate-env.sh` and must remain profile-gated.
- Endpoint and TLS behavior are documented in root README files and `docs/` guides.
- Existing modules (`ctfd`, `observability`) establish patterns for secret bootstrap, optional profile activation, and static smoke tests.
- In this branch, Keycloak is not yet part of the active stack; therefore Plane SSO integration must support both a future local `keycloak` module and an external Keycloak endpoint.

## What Changes
- Add a new optional Plane service module under `services/plane/` (profile `plane`) with Traefik HTTPS routing at `https://plane.<DEV_DOMAIN>`.
- Add Plane runtime dependencies (database/cache/object storage as required by the selected upstream Plane topology) on internal networks with persistent volumes.
- Keep Plane exposed through Traefik only (no direct host UI/API port exposure by default).
- Add `.env.example` variables and `make plane-bootstrap` for idempotent secret/bootstrap generation.
- Add `make plane-up/down/restart/logs/status` (and `make test-plane`) using the existing compose wrapper patterns.
- Add profile-gated preflight guardrails for Plane core config, plus optional checks for Keycloak and observability integration toggles.
- Define optional Keycloak OIDC integration contract (disabled by default) for either local module or external IdP.
- Define optional observability integration hooks (labels/log routing/metrics-trace readiness as supported by Plane) without introducing a hard dependency on the `observability` profile.
- Ensure TLS compatibility across existing modes, including Mode C when `stepca` is enabled.

## Non-Goals (Phase 1)
- Production HA topology for Plane.
- Automated backup/restore workflows for Plane stateful data.
- Mandatory Keycloak or observability deployment as a prerequisite.
- Deep realm/client provisioning automation inside Keycloak.

## Impact
- Affected specs:
  - `plane-service` (new)
  - `compose-wrapper`
  - `bootstrap-secrets`
  - `guardrails`
  - `docs-endpoints-tls`
  - `tests-suite`
- Affected code/docs (planned):
  - `services/plane/compose.yml`
  - `services/plane/README*.md`
  - `.env.example`
  - `scripts/plane-bootstrap.sh`
  - `scripts/validate-env.sh`
  - `Makefile`
  - `scripts/healthcheck.sh`
  - `tests/smoke/*plane*`
  - `README*.md`, `scripts/README.md`, `tests/README.md`, `docs.manifest.json`

## Dependencies / Order
- This change SHOULD keep Plane functional when `stepca`, `keycloak`, and `observability` are disabled.
- If a local Keycloak module is not present, Plane OIDC integration SHOULD still support an external Keycloak endpoint.
- Observability integration SHOULD be additive and must not block base Plane startup.
