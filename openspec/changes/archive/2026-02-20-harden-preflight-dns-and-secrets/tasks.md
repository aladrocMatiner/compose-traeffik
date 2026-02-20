## 1. Discovery & Scope Confirmation
- [x] 1.1 Confirm dns targets bypass preflight (`Makefile`) and current auth mount points (`services/traefik/compose.yml`).
- [x] 1.2 Confirm current preflight behavior and auth path validation (`scripts/validate-env.sh`).

## 2. Preflight Enforcement
- [x] 2.1 Update `scripts/compose.sh` to run `scripts/validate-env.sh` before any docker compose call.
- [x] 2.2 Update `Makefile` dns targets to use `scripts/compose.sh` (ensures preflight for dns-up/down/logs/status).

## 3. Secret/Auth Guardrails
- [x] 3.1 Tighten `scripts/validate-env.sh` to:
  - reject `COMPOSE_PROFILES` with empty entries (leading/trailing/double commas),
  - require `DNS_ADMIN_PASSWORD` when dns profile is enabled and reject placeholder values,
  - require htpasswd paths under `/etc/traefik/auth/` and fail on example files or missing host files.
- [x] 3.2 Update `.env.example` to remove weak default for `DNS_ADMIN_PASSWORD` and keep htpasswd paths aligned with `/etc/traefik/auth/`.
- [x] 3.3 Update `.gitignore` to ignore all real `services/traefik/auth/*.htpasswd` while keeping `*.htpasswd.example` tracked.

## 4. Documentation Sync
- [x] 4.1 Update `scripts/README.md` to document `scripts/validate-env.sh`, required env vars, and htpasswd creation guidance.

## 5. Validation (manual)
- [x] 5.1 Run `./scripts/validate-env.sh` with `COMPOSE_PROFILES=dns` and placeholder password to confirm fail-closed messaging.
- [x] 5.2 Run `make dns-up` with a valid htpasswd and non-placeholder `DNS_ADMIN_PASSWORD` to confirm preflight passes and compose executes.
