# Change: Improve README onboarding with endpoints and TLS guides

## Why
Onboarding content needs a clear endpoints list and a self-signed quickstart in the root README, plus three complete TLS setup guides under `docs/` with consistent, operational steps.

## Discovery Summary
- **Compose files**: `compose/base.yml` + `services/*/compose.yml` (layered via Makefile).
- **Services**: traefik, whoami, dns, certbot, step-ca.
- **Profiles**: `dns`, `le`, `stepca`.
- **Networks**: `traefik-proxy` (`proxy`), `stepca-internal`.
- **Endpoints from Host() rules**:
  - `whoami.${DEV_DOMAIN}` (whoami routers in `services/whoami/compose.yml`).
  - `dns.${BASE_DOMAIN}` (DNS UI router in `services/dns/compose.yml`, profile `dns`).
  - `step-ca.${DEV_DOMAIN}` (step-ca router in `services/step-ca/compose.yml`, profile `stepca`).
  - `traefik.${DEV_DOMAIN}` (dashboard router in `services/traefik/dynamic/dashboard.yml`; requires auth, dashboard disabled unless enabled by config toggle).
- **Relevant Make targets**: `make up`, `make down`, `make logs`, `make test`, `make certs-local`, `make certs-le-issue`, `make certs-le-renew`, `make stepca-bootstrap`, `make stepca-trust-install`, `make stepca-trust-uninstall`, `make stepca-trust-verify`, `make hosts-*`, `make dns-*`.
- **Env vars referenced in docs**: `DEV_DOMAIN`, `BASE_DOMAIN`, `PROJECT_NAME`, `LOOPBACK_X`, `ENDPOINTS`, `TLS_CERT_RESOLVER`, `COMPOSE_PROFILES`, `ACME_EMAIL`, `LETSENCRYPT_STAGING`, `LETSENCRYPT_CA_SERVER`, `STEP_CA_*`.

## What Changes
- Update `README.md` with an Endpoints section and a Quick start (Self-signed TLS) section using real commands/vars.
- Add three TLS setup guides under `docs/`:
  - `docs/tls-mode-a-selfsigned.md`
  - `docs/tls-mode-b-letsencrypt-certbot.md`
  - `docs/tls-mode-c-stepca-acme.md`
- Link README to the three TLS guides and include reciprocal links in each guide.

## Impact
- Affected specs: docs-endpoints-tls
- Affected code/docs: `README.md`, new `docs/tls-*.md` guides, optional updates to `.env.example` if new vars are referenced.
