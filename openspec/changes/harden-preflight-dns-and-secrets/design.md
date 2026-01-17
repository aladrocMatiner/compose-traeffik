## Context
Preflight validation exists but is not consistently invoked, and auth file paths can point to locations not mounted into the Traefik container. DNS admin credentials can remain weak defaults without blocking.

## Goals / Non-Goals
- Goals:
  - Enforce preflight checks on all compose entrypoints.
  - Fail closed for admin UI auth if example htpasswd files are used.
  - Require non-placeholder DNS admin password when DNS profile is enabled.
  - Prevent accidental commits of real htpasswd files.
- Non-Goals:
  - Refactoring compose structure or Traefik routing.
  - Adding new services or profiles.

## Decisions
- Add preflight invocation to `scripts/compose.sh` so any compose command runs validation.
- Keep `scripts/up.sh` validation (already present) to fail before rendering configs.
- Restrict htpasswd env vars to `/etc/traefik/auth/<file>` and resolve to `services/traefik/auth/<file>` on host.
- Treat `DNS_ADMIN_PASSWORD=change-me` as invalid and require explicit user-provided value.

## Risks / Trade-offs
- Stricter preflight may block workflows that previously relied on `.env.example` defaults; mitigated by clear error messages.
- Double validation (in `up.sh` and `compose.sh`) could add minor overhead but keeps early failure before rendering.

## Migration Plan
- Users must set `DNS_ADMIN_PASSWORD` to a non-placeholder value and generate real htpasswd files before enabling DNS or dashboard routes.
