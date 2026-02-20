# Change: Fix Traefik provider routing, dashboard exposure, and redirect toggle

## Why
Docker label routers are not being loaded because Traefik runs only the file provider, the dashboard is exposed on host port 8080 over HTTP, and the HTTP redirect toggle is not wired to routing. These issues block DNS/step-ca routing, weaken dashboard defaults, and make the redirect toggle misleading.

## Discovery Summary
- **Traefik providers**: only file provider enabled in `services/traefik/traefik.yml` (no docker provider).
- **Docker socket**: mounted in `services/traefik/compose.yml`.
- **Dashboard router**: `services/traefik/dynamic/dashboard.yml` uses entrypoint `traefik` (port 8080).
- **Dashboard exposure**: host port `8080` is published in `services/traefik/compose.yml`.
- **Redirect toggle**: `HTTP_TO_HTTPS_REDIRECT` is read only by tests; routing always uses `redirect-to-https@file` in `services/whoami/compose.yml`.
- **Env toggles**: `.env.example` includes `TRAEFIK_DASHBOARD=false` but it is not wired to config.
- **Tests**: `tests/smoke/test_traefik_ready.sh` hits `http://traefik.${DEV_DOMAIN}:8080/ping`.

## What Changes
- Enable Traefik docker provider with `exposedByDefault=false` and `network=traefik-proxy` so label routers (DNS/step-ca) load.
- Remove host exposure of port 8080 and re-route dashboard access through HTTPS with auth (or disable by default based on a toggle).
- Make the HTTP redirect toggle actually drive middleware selection for the HTTP router.
- Align tests with the new dashboard/ping access path if updated.

## Impact
- Affected specs: traefik-routing-security
- Affected files: `services/traefik/traefik.yml`, `services/traefik/compose.yml`, `services/traefik/dynamic/middlewares.yml`, `services/traefik/dynamic/dashboard.yml` (optional), `services/whoami/compose.yml`, `.env.example`, tests (optional)
