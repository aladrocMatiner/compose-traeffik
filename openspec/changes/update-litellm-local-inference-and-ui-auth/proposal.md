# Change: Add default local inference endpoint config and LiteLLM admin UI credentials bootstrap

## Why
The LiteLLM module currently requires manual provider configuration before it is useful, and the browser-based management surface is not yet modeled with project-standard credentials/bootstrap patterns. Adding a default local inference endpoint configuration and explicit admin UI credential handling will improve out-of-the-box usability while keeping security and documentation aligned with the rest of the stack.

## What Changes
- Add `.env` defaults for a local inference backend endpoint (default local provider target) used automatically by the LiteLLM config template.
- Extend LiteLLM config/compose wiring so the local inference backend is preconfigured in the LiteLLM proxy without manual YAML edits.
- Add explicit LiteLLM management UI/web access credentials in `.env` and bootstrap them via `make litellm-bootstrap` (project-standard generated secrets + htpasswd flow if Traefik BasicAuth is used).
- Add a dedicated, documented management UI hostname/router for LiteLLM (separate from API hostname) so UI protection does not break API clients.
- Add a documented "standalone Traefik + LiteLLM" run mode (without whoami/dns/step-ca local containers) with dedicated Make targets/wiring.
- Document how the standalone mode can use Traefik TLS with a remote `step-ca` ACME endpoint on the network.
- Extend preflight guardrails, smoke tests, and multilingual docs for the new local inference and UI auth settings.

## Impact
- Affected specs: litellm-router-service, bootstrap-secrets, compose-wrapper, guardrails, docs-endpoints-tls, docs-multilang, scripts-docs, tests-docs, tests-suite
- Affected code/docs: `services/litellm/compose.yml`, `services/litellm/config.yaml`, `services/litellm/README*.md`, `.env.example`, `scripts/litellm-bootstrap.sh`, `scripts/validate-env.sh`, `services/traefik/dynamic/middlewares.yml` and/or render path, `Makefile` (standalone targets/help), `scripts/up.sh`/`scripts/compose.sh` (if needed), `README*.md`, `scripts/README.md`, `tests/README.md`, `tests/smoke/test_litellm_*.sh`
