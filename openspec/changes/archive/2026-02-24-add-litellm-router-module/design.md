## Context
This repository is a Traefik-centered Docker Compose stack with optional services managed through profiles, Make targets, `.env` configuration, preflight validation, smoke tests, and multilingual README documentation. The new LLM router module must fit that operating model so it can be enabled and maintained like DNS and step-ca.

The goal is a first LiteLLM integration that is easy to adopt locally and in small self-hosted setups, without immediately introducing database-backed governance features.

## Goals / Non-Goals
- Goals:
  - Add LiteLLM as an optional service module with Traefik HTTPS exposure and no direct host port publish.
  - Keep configuration file-based (`services/litellm/config.yaml`) plus `.env` for secrets/provider keys.
  - Provide an idempotent bootstrap flow for LiteLLM secrets (`make litellm-bootstrap`).
  - Add preflight validation, smoke tests, and multilingual docs matching project conventions.
  - Keep the initial module provider-agnostic and usable without external DB/Redis dependencies.
- Non-Goals:
  - Implement LiteLLM virtual keys, budgets, teams, or admin features that require Postgres in v1.
  - Add Redis-backed routing cooldowns/usage tracking in v1.
  - Add another provider service (for example Ollama) in this change.
  - Build runtime integration tests that call paid/external LLM providers.

## Decisions
- Service naming and profile:
  - Compose service name: `litellm`.
  - Compose profile: `litellm`.
  - Service directory: `services/litellm/` with `compose.yml` and multilingual READMEs.
- Endpoint and routing:
  - Default external hostname prefix: `llm`.
  - Endpoint exposed via Traefik HTTPS at `https://llm.${DEV_DOMAIN}`.
  - No direct host port publish for LiteLLM HTTP API by default.
  - Traefik router middlewares should be configurable via `.env` (for example `LITELLM_MIDDLEWARES`) with a safe default that includes `security-headers@file`.
  - Traefik labels must follow the same TLS resolver pattern used by other services (`TLS_CERT_RESOLVER` compatible across Modes A/B/C).
- Configuration model:
  - LiteLLM proxy configuration is committed as a template/config file (`services/litellm/config.yaml`).
  - Secrets and provider API keys stay in `.env` only and are referenced from config via environment placeholders.
  - The implementation must verify the exact supported syntax for env references in the pinned LiteLLM version before finalizing the config template.
- Authentication and security baseline:
  - LiteLLM API authentication SHALL be enabled by default via a required master key (`LITELLM_MASTER_KEY`).
  - A bootstrap-generated salt/secondary secret (`LITELLM_SALT_KEY`) SHALL also be stored in `.env` to support secure key-related features and avoid weak defaults.
  - Preflight validation SHALL reject empty/placeholder LiteLLM secrets when the `litellm` profile is enabled.
  - The implementation must explicitly verify how the pinned LiteLLM version exposes docs/admin endpoints and document/limit them accordingly (do not assume route behavior).
- Dependency scope (v1):
  - The `litellm` profile must not require Postgres or Redis to start.
  - Advanced governance/routing persistence can be proposed later as separate optional profiles or changes.
- Testing scope:
  - Add no-sudo smoke tests that validate compose wiring, config template presence/structure, guardrails, bootstrap idempotency, and Make/healthcheck integration.
  - No runtime provider call tests in v1.
- Documentation scope:
  - Update root `README.md`, `README.sv.md`, `README.es.md` endpoint/service sections.
  - Add `services/litellm/README*.md` following the manifest anchor structure.
  - Update `docs.manifest.json`, `scripts/README.md`, and `tests/README.md`.

## Security Considerations
- Secrets lifecycle:
  - LiteLLM secrets must be generated into `.env` by `make litellm-bootstrap` and never committed.
  - `.env.example` should contain empty values/placeholders only, with comments pointing to the bootstrap command.
  - Bootstrap must be idempotent by default and require explicit force/rotation behavior to overwrite existing secrets.
- Exposure model:
  - LiteLLM traffic should terminate at Traefik using the existing TLS stack and not be published directly on the host.
  - Docs must clearly state that exposing LiteLLM beyond local/trusted networks requires additional controls (network policy, auth rotation, monitoring).
  - Any upstream docs/admin endpoints exposed by LiteLLM must be explicitly reviewed and either documented with security notes or disabled in the chosen startup/config pattern.
- Provider keys:
  - Provider credentials (OpenAI, Anthropic, OpenRouter, etc.) must remain optional and externalized in `.env`.
  - The config file must not embed real API keys or example secrets that look valid.

## Integration Plan (Implementation Order for Low-Ambiguity Execution)
1. Verify upstream LiteLLM contract from primary docs/image for the chosen pinned version:
   - container image tag
   - container port
   - startup command/entrypoint for proxy mode
   - config file path and syntax
   - env var names for master key/salt/auth
   - health endpoint(s)
2. Scaffold `services/litellm/` files (`compose.yml`, `config.yaml`, README EN/SV/ES placeholders/content) and add `.gitkeep` only if a state/config directory is required.
3. Add `LITELLM_*` variables to `.env.example` (image, hostname, secrets, optional provider keys, config toggles).
4. Wire `services/litellm/compose.yml` into `scripts/compose.sh` and `Makefile` `COMPOSE_FILES` in the same order pattern as existing services.
5. Add Make targets (`litellm-bootstrap`, `litellm-up/down/restart/logs/status`) and ensure `make help` + `.PHONY` are updated.
6. Implement `scripts/litellm-bootstrap.sh` and connect `make litellm-bootstrap`.
7. Extend `scripts/validate-env.sh` with LiteLLM guardrails.
8. Add smoke tests and hook them into `scripts/healthcheck.sh`.
9. Update root/service/script/test docs and `docs.manifest.json`.
10. Run validation (`openspec validate --strict`, docs-check, new smoke tests).

## Risks / Trade-offs
- LiteLLM has fast-moving config/auth options; pinning and verifying the exact version is mandatory to avoid drift between docs and implementation.
- A file-based config is repository-friendly but may expose unsupported examples if not validated against the pinned version.
- Avoiding Postgres/Redis keeps v1 simple but defers some governance features; docs must be explicit about current scope.

## Open Questions (Resolved Defaults for This Proposal)
- Hostname prefix: default to `llm` (documented and overrideable via `.env`).
- Endpoint domain: use `${DEV_DOMAIN}` (same pattern as whoami/step-ca Traefik services).
- Add `llm` to `ENDPOINTS` automatically: no, not in bootstrap; document manual addition for hosts/DNS tooling to avoid surprising `.env` edits.
- Include LiteLLM UI/admin workflows in v1 docs: only if supported and securely documented for the pinned version; otherwise document API-only usage and health checks.
