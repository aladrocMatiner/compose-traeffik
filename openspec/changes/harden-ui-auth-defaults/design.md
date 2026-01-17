## Context
Traefik dynamic middlewares reference `.example` htpasswd files with known credentials and ignore `DNS_UI_BASIC_AUTH_HTPASSWD_PATH`. The DNS service accepts a blank admin password if unset. We need a consistent, safe-by-default policy for UI access and clear env wiring.

## Goals / Non-Goals
- Goals:
  - Fail closed for dashboard/DNS UI unless a real htpasswd file is provided.
  - Wire auth file path env vars into the rendered Traefik dynamic config.
  - Require `DNS_ADMIN_PASSWORD` when the DNS profile is enabled.
- Non-Goals:
  - No routing/TLS refactors.
  - No changes to Traefik providers or service topology.

## Decisions
- Decision: Enforce “fail closed” by requiring non-example htpasswd paths and refusing to enable routes when they are not set.
  - Rationale: Prevent accidental exposure with default credentials.
- Decision: Add explicit env vars for dashboard and DNS UI htpasswd paths (if not already present) and render them into the middleware config.
  - Rationale: Ensure `.env` settings are actually used by Traefik.
- Decision: Add a preflight validation hook (script or Makefile) that fails early when DNS is enabled without `DNS_ADMIN_PASSWORD`.
  - Rationale: Avoid running DNS with empty admin credentials.

## Risks / Trade-offs
- Fail-closed behavior may surprise users who expect the default `.example` credentials to work.
- Additional preflight validation adds a small amount of up-front friction.

## Migration Plan
1) Wire htpasswd path env vars into middleware templates and rendering.
2) Add preflight validation for `DNS_ADMIN_PASSWORD` when DNS profile is enabled.
3) Update documentation to explain required env vars and how to generate htpasswd files.

## Open Questions
- Should dashboard auth use the same env var as DNS UI or a dedicated `TRAEFIK_DASHBOARD_BASIC_AUTH_HTPASSWD_PATH`?
- Should the fail-closed behavior disable the routers entirely or keep them with a missing usersFile (resulting in 404/401)?
