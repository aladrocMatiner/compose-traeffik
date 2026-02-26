## Why

This repository is a Traefik-centered edge stack with optional DNS, Certbot, and step-ca, but it still lacks a production-like documentation application module. We need a Wiki.js module to validate reverse proxy behavior (including WebSockets), a stateful app dependency (database), and the recurring optional integrations we use in this repo (Keycloak, observability, and step-ca TLS mode compatibility).

## What Changes

- Add an optional `wikijs` service module behind Traefik with a bundled database dependency (expected: PostgreSQL) using the repo's profile-based compose layering and a default public hostname of `wiki.<DEV_DOMAIN>`.
- Add Wiki.js bootstrap/render helper scripts and Make targets (`wikijs-bootstrap`, `wikijs-up/down/restart/logs/status`).
- Add Wiki.js env/bootstrap integration so `.env.example` provides safe defaults while `make bootstrap` randomizes required secrets and installs/provisions any generated local assets/config needed by the Wiki.js module.
- Add optional integration hooks (disabled by default) for:
  - Keycloak login (via the supported Wiki.js auth provider flow, expected OIDC-based but gated by upstream verification)
  - observability (implement the full upstream-supported/install-documented observability path when available; otherwise explicitly scope to the supported subset such as telemetry/health/logging)
  - step-ca TLS mode compatibility through Traefik, plus a plan for internal CA trust when Wiki.js calls a Keycloak issuer signed by step-ca
- Extend preflight validation (`scripts/validate-env.sh`) with Wiki.js profile guardrails and optional integration input validation.
- Add Wiki.js static smoke tests (wiring/guardrails/rendering) and multilingual docs updates.

## Capabilities

### New Capabilities
- `wikijs-service`: Wiki.js service module lifecycle, compose wiring, reverse-proxy integration, and optional integration hooks.

### Modified Capabilities
- `guardrails`: add Wiki.js profile preflight validation for rendered config and optional Keycloak/observability/step-ca trust inputs.
- `bootstrap-secrets`: define bootstrap-generated Wiki.js/database secrets and local generated assets for a ready-to-run default workflow.
- `environment-config`: add Wiki.js defaults that are safe in `.env.example` while allowing bootstrap to randomize/install concrete values.
- `scripts-docs`: document Wiki.js helper scripts and lifecycle workflows.
- `tests-docs`: document the Wiki.js static smoke suite and runtime validation notes.
- `tests-suite`: document service-specific static smoke suites beyond `make test`.
- `docs-endpoints-tls`: include the Wiki.js endpoint (`https://wiki.<DEV_DOMAIN>`) and TLS mode compatibility notes.
- `services-layout`: extend service layout expectations to include the Wiki.js module.
- `docs-multilang`: maintain EN/SV/ES parity for the new service page and root references.

## Impact

- Affected code: `.env.example`, `.gitignore`, `Makefile`, `scripts/compose.sh`, `scripts/validate-env.sh`, `scripts/README.md`, `tests/README.md`, `docs.manifest.json`, `README*.md`.
- New code (planned): `services/wikijs/**`, `scripts/wikijs-*.sh`, `tests/smoke/test_wikijs_*.sh`.
- Runtime impact (planned): optional `wikijs` profile adds Wiki.js and database dependency containers; default stack remains unchanged unless the profile is enabled.
