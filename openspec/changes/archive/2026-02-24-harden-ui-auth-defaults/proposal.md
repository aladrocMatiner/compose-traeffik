# Change: Harden dashboard/DNS UI auth defaults and wire auth path envs

## Why
Current BasicAuth points at .example files with known credentials, and the DNS UI auth path env var is documented but not wired, which makes it easy to expose UIs with default creds. DNS_ADMIN_PASSWORD can also be blank at runtime, weakening the DNS service.

## What Changes
- Enforce a safe-by-default BasicAuth policy (fail closed unless a non-example htpasswd file is provided).
- Wire `DNS_UI_BASIC_AUTH_HTPASSWD_PATH` (and a dashboard equivalent) into Traefik dynamic middleware configuration.
- Require `DNS_ADMIN_PASSWORD` when the DNS service/UI is enabled (fail fast with a clear message).
- Add brief documentation on generating htpasswd files and required env vars.

## Impact
- Affected capability: `ui-auth`
- Affected code:
  - `services/traefik/dynamic/middlewares.yml`
  - `services/traefik/compose.yml`
  - `services/traefik/auth/*`
  - `services/dns/compose.yml`
  - `.env.example`
  - `scripts/*` (preflight validation if added)
  - `README.md`
