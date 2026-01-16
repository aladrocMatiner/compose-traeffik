# Change: Align smoke tests and documentation with routing/tls toggles

## Why
After routing and TLS fixes land, smoke tests and docs must reflect the real behavior of redirect toggles, docker provider routing, and Mode B/C certificate handling. Today the tests assume the Traefik ping endpoint is reachable on port 8080, and docs still describe certbot behavior that does not match actual routing without required mounts/config. This change updates tests and docs to validate the corrected behavior and avoid misleading guidance.

## Discovery Summary
- **Smoke tests**:
  - `test_traefik_ready.sh` calls `http://traefik.${DEV_DOMAIN}:8080/ping`.
  - `test_http_redirect.sh` only validates redirect when enabled, but does not assert behavior when disabled.
  - `test_routing.sh` / `test_tls_handshake.sh` only check whoami; they pass even when docker provider is disabled because file-provider routers exist.
- **Docs**:
  - `README.md` lists the dashboard at `http://traefik.${DEV_DOMAIN}:8080`.
  - TLS guides in `docs/tls-mode-*.md` mention certbot and step-ca behavior that depends on new env-driven config and mounts.
- **Dependencies**:
  - `fix-traefik-provider-dashboard-redirect` will change dashboard exposure and routing behavior.
  - `fix-tls-bc-determinism` will change certbot/step-ca handling and env vars.

## What Changes
- Update smoke tests to validate:
  - docker provider routing is enabled (or profile endpoints are reachable when enabled).
  - redirect toggle affects routing behavior (both enabled and disabled cases).
  - Traefik readiness check matches the new dashboard/ping access path.
- Update `tests/README.md` to describe the updated test behavior and prerequisites.
- Update `README.md` and TLS guides to match the new routing/tls toggles and deterministic Mode B/C behavior.

## Impact
- Affected specs: tests-docs-alignment
- Affected files: `tests/smoke/*.sh`, `tests/README.md`, `README.md`, `docs/tls-mode-a-selfsigned.md`, `docs/tls-mode-b-letsencrypt-certbot.md`, `docs/tls-mode-c-stepca-acme.md`
