# Change: Add LiteLLM router module as an optional service

## Why
The project already standardizes optional services behind Traefik with Compose profiles, Make targets, preflight validation, smoke tests, and multilingual documentation. Adding a self-hosted LLM router should follow the same pattern so teams can enable it without introducing ad-hoc scripts or undocumented secrets handling.

## What Changes
- Add an optional `litellm` Compose profile with a LiteLLM proxy service under `services/litellm/`.
- Expose the LiteLLM endpoint through Traefik HTTPS only (no direct host TCP publish for the proxy UI/API) using the shared TLS resolver pattern.
- Add `LITELLM_*` environment configuration to `.env.example`, including bootstrap-managed secrets and endpoint hostname settings.
- Add `make litellm-bootstrap`, `litellm-up`, `litellm-down`, `litellm-restart`, `litellm-logs`, and `litellm-status` targets wired through `scripts/compose.sh`.
- Add a `scripts/litellm-bootstrap.sh` helper to generate and populate required LiteLLM secrets in `.env` idempotently.
- Extend `scripts/validate-env.sh` with LiteLLM guardrails (secrets, hostname, and profile-specific safety checks).
- Add no-sudo smoke tests for LiteLLM config, guardrails, bootstrap behavior, and Make/healthcheck wiring.
- Update root/service multilingual docs, `scripts/README.md`, `tests/README.md`, and `docs.manifest.json`.
- Require an upstream contract verification step (image tag, config syntax, CLI/env vars, auth behavior) before implementation is finalized.

## Impact
- Affected specs: litellm-router-service, bootstrap-secrets, compose-wrapper, guardrails, docs-endpoints-tls, docs-multilang, scripts-docs, tests-docs, tests-suite
- Affected code/docs: `services/litellm/compose.yml`, `services/litellm/config.yaml`, `services/litellm/README*.md`, `.env.example`, `Makefile`, `scripts/compose.sh`, `scripts/validate-env.sh`, `scripts/litellm-bootstrap.sh`, `scripts/healthcheck.sh`, `tests/smoke/test_litellm_*.sh`, `README*.md`, `docs.manifest.json`, `scripts/README.md`, `tests/README.md`
