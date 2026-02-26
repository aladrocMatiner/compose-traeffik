## Context

n8n is a stateful Node.js automation platform commonly deployed behind a reverse proxy, with webhook endpoints and persistent credentials that should be backed by a database and an encryption key. In this repo, service modules are profile-gated, fronted by Traefik, documented in EN/SV/ES, and validated with preflight guardrails and static smoke tests before runtime testing.

The user requested the same optional integration pattern used for recent service modules: Keycloak, observability, and step-ca compatibility.

## Goals / Non-Goals

- Goals:
  - Add a reproducible n8n service module behind Traefik using the repo's compose layering pattern.
  - Standardize the public route as `https://n8n.<DEV_DOMAIN>` (profile slug remains `n8n`).
  - Plan optional Keycloak integration hooks, observability hooks, and step-ca compatibility without enabling them by default.
  - Define a bootstrap/render workflow so n8n runtime configuration and integration runbooks are deterministic and testable.
  - Ensure `make bootstrap` can randomize required n8n/database secrets and provision local generated assets so defaults are ready to use.
  - Define static smoke tests and multilingual documentation before/with implementation.
- Non-Goals:
  - Add n8n queue mode, Redis, or worker scaling in the initial module change.
  - Automate enterprise-only SSO provisioning unless upstream docs confirm a stable config path usable in this repo.
  - Add n8n day-2 backup/restore/upgrade workflows in the initial module change.
  - Add a full monitoring stack (Prometheus/Grafana) in this change.

## Upstream Assumptions To Verify Before Coding

1. Official n8n Docker deployment guidance and recommended persistent settings (database, encryption key, webhook/base URLs).
2. Reverse proxy requirements for n8n behind Traefik (forwarded headers, webhook/public URL settings, websocket or SSE/editor connectivity if applicable).
3. Keycloak integration path supported by the target n8n edition/version (enterprise SSO/OIDC or alternative) and callback URL requirements.
4. Observability capabilities supported by n8n today:
   - health endpoint(s)
   - metrics endpoint(s) and activation flags
   - telemetry/diagnostics controls if relevant
5. Whether a Node.js `NODE_EXTRA_CA_CERTS`-style approach is required/recommended when n8n must trust an internal Keycloak issuer signed by step-ca.

## Decisions (Planned)

- Decision: Use a dedicated `n8n` profile with `n8n` and a bundled PostgreSQL service.
  - Why: Keeps the default stack lightweight while providing an end-to-end automation app module with persistence.

- Decision: Use `n8n` as the default public hostname label (for `https://n8n.<DEV_DOMAIN>`).
  - Why: Matches common naming and keeps endpoint naming explicit.

- Decision: Add a `n8n-bootstrap` render step before `n8n-up` that writes generated artifacts under `services/n8n/rendered/`.
  - Why: Matches repo patterns for deterministic config generation and enables static smoke tests for rendering.

- Decision: Extend `make bootstrap` / `scripts/env-generate.sh` to randomize required n8n and database secrets and provision generated local artifacts needed by n8n defaults.
  - Why: The user wants safe defaults in `.env.example` but a ready-to-run bootstrap that installs concrete randomized values automatically.

- Decision: Treat Keycloak integration as an optional hook with generated runbook/checklist by default, because n8n SSO support may depend on edition/licensing.
  - Why: Avoids overpromising unsupported or enterprise-only automation while still planning the integration path.

- Decision: Treat observability as optional hooks with safe defaults, and implement the full upstream-supported/install-documented path when verification confirms it.
  - Why: n8n is known to expose metrics/health via feature flags in many versions, but exact env vars and endpoints should be verified.

- Decision: Treat step-ca as a compatibility mode through Traefik TLS plus optional internal CA trust injection for outbound HTTPS (e.g., Keycloak).
  - Why: The app may need to trust an internal issuer even when inbound TLS is terminated by Traefik.

## Risks / Trade-offs

- Risk: n8n Keycloak/SSO integration may be enterprise-only.
  - Mitigation: Implement disabled-by-default hooks + runbook/guardrails, and mark runtime SSO validation conditional.

- Risk: n8n observability flags may change across versions.
  - Mitigation: Verify against official docs for the pinned image and keep guardrails mode-based.

- Risk: Webhook/public URL settings may be misconfigured behind Traefik, causing workflow callback failures.
  - Mitigation: Render explicit `N8N_HOST` / `N8N_PROTOCOL` / `WEBHOOK_URL` and include runtime validation notes.

- Risk: Bootstrap secret generation may drift from existing repo conventions and break `make bootstrap`.
  - Mitigation: Explicitly include `scripts/env-generate.sh` and `bootstrap-secrets` / `environment-config` spec updates in the implementation tasks.

## Migration / Rollout Plan (For Future Implementation)

1. Upstream verification gate (docs + supported config paths).
2. Compose module + bootstrap/render scripts.
3. Makefile / compose wrapper / preflight integration.
4. Static smoke tests and multilingual docs.
5. Runtime validation (only after proposal approval and implementation).

## Open Questions

- Exact n8n Keycloak/SSO availability and configuration surface for the target image tag (community vs enterprise).
- Whether n8n requires any explicit websocket proxy config beyond standard Traefik forwarding for the editor/runtime UX in the target version.
- Which observability endpoint(s) should be considered the default optional mode in this repo (`metrics`, `healthz`, both).
