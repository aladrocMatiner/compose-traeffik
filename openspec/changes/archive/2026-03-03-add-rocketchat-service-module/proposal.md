## Why

This repository already provides a Traefik-centered edge stack with optional DNS, Certbot, and step-ca profiles, but it lacks a real application module beyond the `whoami` demo service. We need a reusable Rocket.Chat module to validate the stack against a stateful web application with WebSocket traffic, internal dependencies, and optional integration hooks (Keycloak and observability).

## What Changes

- Add a new optional `rocketchat` service module (Rocket.Chat + MongoDB replica set bootstrap + NATS) behind Traefik.
- Add Rocket.Chat bootstrap/render scripts and Make targets (`rocketchat-bootstrap`, `rocketchat-up/down/restart/logs/status`).
- Add optional configuration hooks for:
  - Keycloak custom OAuth setup guidance (rendered runbook/checklist from `.env` values)
  - Rocket.Chat Prometheus metrics settings and scrape labels (disabled by default)
- Extend preflight validation (`scripts/validate-env.sh`) with Rocket.Chat profile guardrails and Keycloak/observability input checks.
- Add Rocket.Chat static smoke tests (wiring/guardrails/rendering) and document them.
- Update root/service docs and docs manifest in EN/SV/ES.

## Capabilities

### New Capabilities
- `rocketchat-service`: Rocket.Chat service module lifecycle, compose wiring, and optional integration hooks.

### Modified Capabilities
- `guardrails`: add Rocket.Chat profile preflight checks for rendered config and optional Keycloak/observability values.
- `scripts-docs`: document Rocket.Chat helper scripts and lifecycle workflows.
- `tests-docs`: document Rocket.Chat smoke suite usage and troubleshooting.
- `tests-suite`: document service-specific static smoke suites beyond `make test`.
- `docs-endpoints-tls`: include Rocket.Chat endpoint and TLS mode compatibility notes.
- `services-layout`: extend service layout expectations to include the new Rocket.Chat module.
- `docs-multilang`: maintain EN/SV/ES parity for the new service page and root references.

## Impact

- Affected code: `.env.example`, `.gitignore`, `Makefile`, `scripts/compose.sh`, `scripts/validate-env.sh`, `scripts/README.md`, `tests/README.md`, `docs.manifest.json`, `README*.md`.
- New code: `services/rocketchat/**`, `scripts/rocketchat-*.sh`, `tests/smoke/test_rocketchat_*.sh`.
- Runtime impact: optional `rocketchat` profile adds Rocket.Chat, MongoDB, MongoDB replica set init helper, and NATS services.
