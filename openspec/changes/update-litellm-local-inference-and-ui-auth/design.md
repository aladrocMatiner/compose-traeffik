## Context
The LiteLLM module has been integrated as an optional Traefik-backed service with file-based config, bootstrap-generated API secrets, guardrails, smoke tests, and multilingual docs. Two practical gaps remain:

1. A default local inference backend is not preconfigured, so users must manually edit `services/litellm/config.yaml` before the proxy is useful without cloud providers.
2. The browser-facing LiteLLM management surface (docs/admin UI, depending on upstream behavior and feature availability) is not yet modeled with a dedicated hostname and project-standard credentials bootstrap.

This change is a follow-up planning change to add those behaviors cleanly.

## Goals / Non-Goals
- Goals:
  - Add `.env` parameters for a default local inference endpoint and model/provider settings.
  - Auto-wire LiteLLM config to expose a local inference route by default (no manual YAML edits required).
  - Add explicit LiteLLM management UI credentials to `.env` and generate them via `make litellm-bootstrap`.
  - Protect the management UI with a dedicated Traefik router/hostname and BasicAuth-style credentials (project-consistent), without breaking API clients on the main LiteLLM API hostname.
  - Add a standalone run mode for `Traefik + LiteLLM` only (no whoami/dns/step-ca local containers) for LAN deployments.
  - Document how standalone mode uses Traefik TLS with an external/remote `step-ca` ACME endpoint on the network.
  - Document behavior and add tests/guardrails for the new settings.
- Non-Goals:
  - Automatically install or run the local inference engine itself (for example Ollama) as part of this change.
  - Add a new local inference service container/profile (that can be a separate change if desired).
  - Add database-backed LiteLLM governance features.
  - Auto-discover or manage the remote `step-ca` server lifecycle (it is out-of-scope and external).

## Assumptions
- "Configure automatically" is interpreted as: the LiteLLM module ships with a preconfigured local inference route driven by `.env` defaults and compose wiring. It does not mean auto-installing the inference runtime on the host.
- The default local backend provider target will be an Ollama-compatible HTTP endpoint unless the user overrides the env vars.

## Decisions
- Local inference defaults:
  - Introduce `.env` parameters for a default local inference target, with a provider-agnostic shape and an Ollama default (for example: enable flag, provider, base URL, default model alias/model string).
  - Default endpoint should point to the host machine using a container-reachable host alias (e.g. `http://host.docker.internal:11434`) and the compose service should provide Linux-compatible `host-gateway` mapping if needed.
  - LiteLLM config template should include a local route using these env vars so it is active by default without cloud keys.
- Management UI exposure and credentials:
  - Keep the API endpoint on `https://llm.${DEV_DOMAIN}` (or existing override) for programmatic clients.
  - Add a dedicated management hostname (e.g. `https://llm-admin.${DEV_DOMAIN}` via `LITELLM_UI_HOSTNAME`) routed to the same LiteLLM service.
  - Apply Traefik BasicAuth to the management hostname only, using project-standard htpasswd file generation and path conventions under `/etc/traefik/auth/`.
  - Continue requiring LiteLLM bearer/master key auth for API routes; do not force Traefik BasicAuth on the API hostname.
- Standalone Traefik + LiteLLM mode:
  - Add dedicated Make targets for a standalone LiteLLM edge mode that starts only `traefik` and `litellm` via the compose wrapper (with `COMPOSE_PROFILES=litellm`).
  - The standalone mode should not start `whoami` and should not require local `dns` or `stepca` profiles.
  - Traefik dynamic config rendering must still run for standalone mode before startup.
  - TLS guidance for standalone mode should explicitly cover pointing `STEP_CA_CA_SERVER` to a remote `step-ca` endpoint and trusting that CA on client machines.
- Bootstrap and secrets:
  - Extend `scripts/litellm-bootstrap.sh` to generate UI BasicAuth password (and htpasswd file) in addition to `LITELLM_MASTER_KEY` and `LITELLM_SALT_KEY`.
  - Preserve idempotent behavior by default; support explicit rotation via `--force`.
- Guardrails:
  - Validate LiteLLM UI BasicAuth htpasswd path and file existence when the management router is enabled.
  - Validate local inference URL/hostname parameters format without requiring the local inference service to be reachable at preflight time.
- Upstream verification requirement:
  - Before implementation, verify the pinned LiteLLM version's browser management/docs/admin endpoints and auth behavior. The UI routing/auth plan must match the actual upstream path behavior.

## Security Considerations
- Split exposure model:
  - Separating API and admin hostnames avoids breaking API clients while still adding an access-control layer for browser management surfaces.
- Credential handling:
  - UI credentials should be generated into `.env`/htpasswd and ignored by git like other admin credentials in the repo.
  - Docs must explain that rotating UI credentials invalidates active browser sessions and may require client updates if API route auth strategy changes later.
- Local inference backend:
  - The default local endpoint is intended for trusted local/private environments. Documentation must warn against exposing an unauthenticated local inference backend on public interfaces.
 - Standalone mode:
  - Standalone mode improves deployment minimalism but increases reliance on external DNS/CA/inference services; docs must state these dependencies explicitly.

## Risks / Trade-offs
- LiteLLM UI/admin availability may differ depending on configuration (e.g. DB-backed features). The implementation must avoid hardcoding assumptions and should document fallback behavior (e.g. docs/swagger only vs full admin UI).
- `host.docker.internal` behavior on Linux depends on Docker support and `host-gateway` mapping. Docs and tests must validate config presence, not runtime reachability.
- Adding a second hostname increases documentation and hosts/DNS guidance complexity (`ENDPOINTS` may need `llm-admin` if automated local resolution is desired).
- A new standalone Make workflow can drift from `make up/down/logs` behavior unless tests verify service selection and help text.

## Open Questions (to resolve during implementation verification)
- Exact env var naming for local inference defaults (generic `LITELLM_LOCAL_*` vs provider-specific `OLLAMA_*` aliases).
- Whether the management router should expose all LiteLLM HTTP endpoints on `llm-admin` or only a narrower path set if upstream paths are predictable in the pinned version.
- Whether UI BasicAuth credentials should be separate from any future API client credentials (recommended: yes).
- Final naming for standalone mode targets (`litellm-standalone-*` vs `litellm-edge-*`) while preserving consistency with existing Make target patterns.
