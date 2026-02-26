## Context

Wiki.js is a stateful Node.js web application commonly deployed behind a reverse proxy and backed by a database (typically PostgreSQL). In this repo, service modules are profile-gated, fronted by Traefik, documented in EN/SV/ES, and validated with preflight guardrails and static smoke tests before runtime testing.

The user requested the same optional integration pattern used for recent service modules: Keycloak, observability, and step-ca compatibility.

## Goals / Non-Goals

- Goals:
  - Add a reproducible Wiki.js service module behind Traefik using the repo's compose layering pattern.
  - Standardize the public Wiki.js route as `https://wiki.<DEV_DOMAIN>` (profile slug remains `wikijs`).
  - Plan optional Keycloak integration hooks, observability hooks, and step-ca compatibility without enabling them by default.
  - Define a bootstrap/render workflow so Wiki.js runtime configuration and integration runbooks are deterministic and testable.
  - Ensure `make bootstrap` can randomize required Wiki.js/database secrets and provision local generated assets so defaults are ready to use.
  - Define static smoke tests and multilingual documentation before implementation.
- Non-Goals:
  - Implement the Wiki.js module in this planning change.
  - Fully automate Wiki.js auth provider creation via DB/API unless upstream docs clearly support a stable config-as-code path.
  - Add Wiki.js day-2 backup/restore/upgrade workflows in the initial module change.
  - Add a full monitoring stack (Prometheus/Grafana) in this change.

## Upstream Assumptions To Verify Before Coding

1. Wiki.js Docker deployment requirements and recommended database backend/version.
2. Reverse proxy requirements for WebSocket support and forwarded headers (and any proxy/body-size headers if relevant).
3. Keycloak integration path supported by Wiki.js (OIDC / OpenID Connect vs generic OAuth/SAML) and required callback URL shape.
4. Observability capabilities supported by Wiki.js today:
   - telemetry controls (documented)
   - health endpoint(s) if available
   - metrics endpoint(s) and recommended integration path if available (or explicit absence thereof)
5. Whether a Node.js `NODE_EXTRA_CA_CERTS`-style approach is required/recommended when Wiki.js must trust an internal Keycloak issuer signed by step-ca.

## Decisions (Planned)

- Decision: Use a dedicated `wikijs` profile with `wikijs` and a bundled database service (expected PostgreSQL, final details gated by upstream verification).
  - Why: Keeps the default stack lightweight while providing an end-to-end application module with state.

- Decision: Use `wiki` as the default public hostname label (for `https://wiki.<DEV_DOMAIN>`) while keeping `wikijs` as the internal module/profile slug.
  - Why: Matches the user's desired endpoint naming while preserving a clear service/module identifier in the repo.

- Decision: Add a `wikijs-bootstrap` render step before `wikijs-up` that writes generated artifacts under `services/wikijs/rendered/`.
  - Why: Matches repo patterns for deterministic config generation and enables static smoke tests for rendering.

- Decision: Extend `make bootstrap` / `scripts/env-generate.sh` to randomize required Wiki.js and database secrets and provision any generated local assets needed by the Wiki.js defaults.
  - Why: The user wants defaults in `.env.example` but a ready-to-run bootstrap that installs concrete randomized values automatically.

- Decision: Treat Keycloak integration as an optional hook with generated runbook/checklist artifacts by default (manual UI/admin configuration likely required unless stable automation is confirmed).
  - Why: Avoids overpromising automation before upstream-supported flows are verified.

- Decision: Treat observability as optional hooks with safe defaults, and implement the full upstream-supported/install-documented path when verification confirms it.
  - Why: Wiki.js telemetry is documented as optional, and the user prefers a full observability integration if upstream supports and documents one.

- Decision: Treat step-ca as a compatibility mode through Traefik TLS plus optional internal CA trust injection for outbound HTTPS to Keycloak (if needed).
  - Why: The app may need to trust an internal issuer even when inbound TLS is terminated by Traefik.

## Risks / Trade-offs

- Risk: Wiki.js auth provider configuration may be UI-only or DB-stored, limiting full automation.
  - Mitigation: Plan for rendered operator runbooks first; automate only what is stable and testable.

- Risk: Wiki.js observability support may not include Prometheus metrics.
  - Mitigation: Define observability as a verification-gated scope; if upstream lacks a full documented path, document and implement the supported subset explicitly (telemetry/health/logging and/or metrics if available).

- Risk: step-ca + Keycloak integration can fail due to container trust chain issues.
  - Mitigation: Add a specific verification task and preflight checks for CA mount/path toggles if implemented.

- Risk: Bootstrap secret generation may drift from existing repo conventions and break `make bootstrap`.
  - Mitigation: Explicitly include `scripts/env-generate.sh` and `bootstrap-secrets` / `environment-config` spec updates in the implementation tasks.

## Migration / Rollout Plan (For Future Implementation)

1. Upstream verification gate (docs + supported config paths).
2. Compose module + bootstrap/render scripts.
3. Makefile / compose wrapper / preflight integration.
4. Static smoke tests and multilingual docs.
5. Runtime validation (only after proposal approval and implementation).

## Open Questions

- Exact Wiki.js auth provider integration surface for Keycloak in the target Wiki.js version (OIDC/OAuth/SAML configuration details).
- Whether Wiki.js exposes a stable metrics endpoint suitable for optional scrape labels and a static testable wiring contract.
- Whether Wiki.js requires any additional reverse-proxy header/body-size configuration beyond standard Traefik defaults for uploads/realtime flows in the target version.
