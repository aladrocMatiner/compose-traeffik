## Why

This repository is a Traefik-centered edge stack with optional DNS, Certbot, and step-ca, but it still lacks an automation/workflow application module. We need an n8n module to validate reverse proxy behavior for a stateful app with webhooks, a database dependency, and recurring optional integrations (Keycloak, observability, and step-ca TLS compatibility).

## What Changes

- Add an optional `n8n` service module behind Traefik with a bundled database dependency (expected: PostgreSQL) using the repo's profile-based compose layering and a default public hostname of `n8n.<DEV_DOMAIN>`.
- Add n8n bootstrap/render helper scripts and Make targets (`n8n-bootstrap`, `n8n-up/down/restart/logs/status`).
- Add n8n env/bootstrap integration so `.env.example` provides safe defaults while `make bootstrap` randomizes required secrets (`N8N_ENCRYPTION_KEY`, DB password, bootstrap admin password) and provisions local generated artifacts/config for the n8n module.
- Add optional integration hooks (disabled by default) for:
  - Keycloak login / SSO (scope gated by upstream product tier and supported auth path verification; generated runbook by default)
  - observability (implement the full upstream-supported/install-documented path when available, expected metrics/health toggles for n8n)
  - step-ca TLS mode compatibility through Traefik, plus internal CA trust for outbound HTTPS calls (e.g., Keycloak)
- Extend preflight validation (`scripts/validate-env.sh`) with n8n profile guardrails and optional integration input validation.
- Add n8n static smoke tests (wiring/guardrails/rendering) and multilingual docs updates.

## Capabilities

### New Capabilities
- `n8n-service`: n8n service module lifecycle, compose wiring, reverse-proxy integration, webhook URL configuration, and optional integration hooks.

### Modified Capabilities
- `guardrails`: add n8n profile preflight validation for rendered config and optional Keycloak/observability/step-ca trust inputs.
- `bootstrap-secrets`: define bootstrap-generated n8n/database secrets and local generated assets for a ready-to-run default workflow.
- `environment-config`: add n8n defaults that are safe in `.env.example` while allowing bootstrap to randomize/install concrete values.
- `scripts-docs`: document n8n helper scripts and lifecycle workflows.
- `tests-docs`: document the n8n static smoke suite and runtime validation notes.
- `tests-suite`: document service-specific static smoke suites beyond `make test`.
- `docs-endpoints-tls`: include the n8n endpoint (`https://n8n.<DEV_DOMAIN>`) and TLS mode compatibility notes.
- `services-layout`: extend service layout expectations to include the n8n module.
- `docs-multilang`: maintain EN/SV/ES parity for the new service page and root references.

## Impact

- Affected code: `.env.example`, `.gitignore`, `Makefile`, `scripts/compose.sh`, `scripts/validate-env.sh`, `scripts/env-generate.sh`, `scripts/README.md`, `tests/README.md`, `docs.manifest.json`, `README*.md`.
- New code (planned): `services/n8n/**`, `scripts/n8n-*.sh`, `tests/smoke/test_n8n_*.sh`.
- Runtime impact (planned): optional `n8n` profile adds n8n and PostgreSQL containers; default stack remains unchanged unless the profile is enabled.
