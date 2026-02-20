## Context
Traefik dynamic config currently includes BasicAuth inline for the dashboard and references a DNS UI usersFile path that is not mounted, causing 404s on fresh runs. Certbot TLS entries are always loaded, producing noisy errors when the certs are absent. The redirect toggle used by routing is different from the one healthcheck/tests expect.

## Goals / Non-Goals
- Goals:
  - Use usersFile-based BasicAuth for dashboard and DNS UI, with a mounted auth directory.
  - Keep dashboard HTTPS-only and auth-protected by default.
  - Load certbot TLS entries only when Mode B is enabled.
  - Unify redirect toggle usage across routing and tests.
- Non-Goals:
  - Rework Traefik router rules or TLS resolver selection beyond gating certbot file loading.
  - Introduce new secret management tooling.

## Decisions
- Decision: Use a single users file mounted at `/etc/traefik/auth/` for both dashboard and DNS UI.
  - Rationale: Simplifies rotation and avoids embedded hashes in repo.
- Decision: Gate certbot TLS entries by conditional rendering of a Mode B-only dynamic file (or alternate load mechanism) tied to existing env/profile state.
  - Rationale: Avoids file-provider parse errors when Mode B is disabled.
- Decision: Standardize on `HTTP_TO_HTTPS_MIDDLEWARE` as the canonical toggle, with `HTTP_TO_HTTPS_REDIRECT` as backward-compatible fallback.
  - Rationale: Router labels already use the middleware selector.

## Risks / Trade-offs
- Conditional rendering may require updating the dynamic render script; scope may need to be extended to include it.
- Introducing a shared users file requires clear documentation to avoid accidental reuse of example credentials.

## Migration Plan
1) Add auth directory + example file, mount into Traefik, switch middlewares to usersFile.
2) Gate certbot TLS entry with Mode B only (conditional render or separate file load).
3) Update healthcheck/tests to use the canonical redirect toggle.
4) Add README notes on generating users file and dashboard enablement.

## Open Questions
- Are we allowed to update `scripts/traefik-render-dynamic.sh` (not currently in scope) to conditionally render Mode B TLS files?
- Should dashboard routing be fully gated by `TRAEFIK_DASHBOARD=false` (requires conditional render), or kept always-on but auth-protected?

