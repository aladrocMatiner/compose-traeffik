# Change: Fix Traefik auth mounting, secure dashboard defaults, align redirect toggle, and gate certbot TLS

## Why
Traefik currently references auth files that are not mounted, uses an inline BasicAuth hash for the dashboard, and always loads certbot TLS entries, which produces errors when Mode B is off. Healthchecks still read a legacy redirect toggle, which can drift from actual routing behavior.

## What Changes
- Add a mounted auth directory and usersFile-based BasicAuth for DNS UI and dashboard; provide a non-secret example users file and instructions.
- Ensure dashboard remains HTTPS-only (no host HTTP port exposure) and is protected by auth by default (optionally gated by `TRAEFIK_DASHBOARD`).
- Gate certbot TLS config so Traefik only loads certbot files when Mode B is enabled.
- Align redirect toggle usage across healthcheck/tests with the router’s real middleware selector.

## Impact
- Affected capability: `traefik-config`
- Affected code:
  - `services/traefik/compose.yml`
  - `services/traefik/dynamic/middlewares.yml`
  - `services/traefik/dynamic/dashboard.yml`
  - `services/traefik/dynamic/tls*.yml`
  - `services/traefik/auth/*` (new)
  - `.env.example`
  - `scripts/healthcheck.sh`
  - `tests/*` (if needed)
  - `README.md`

