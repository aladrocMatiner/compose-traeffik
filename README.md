[English](README.md) | [Svenska](README.sv.md) | [Espanol](README.es.md)

# Traefik Docker Compose Edge Stack

<a id="overview"></a>
## Overview

This repository provides a Docker Compose edge stack centered on Traefik. It is designed for local development, with optional profiles for BIND (DNS), Let's Encrypt (Certbot), and step-ca. The documentation system is README-based and available in English, Swedish, and Spanish.

<a id="quickstart"></a>
## Quickstart (Mode A: Local Self-Signed TLS)

1. **Clone the repository**
   ```bash
   git clone https://github.com/aladrocMatiner/compose-traeffik.git
   cd compose-traeffik
   ```

2. **Bootstrap your env and secrets (production-minimal by default)**
   ```bash
   make bootstrap
   # Production-minimal defaults (optional profiles disabled).
   # Update DEV_DOMAIN, BASE_DOMAIN, LOOPBACK_X, ENDPOINTS as needed.
   # Defaults use the local-only domain local.test.
   ```
   Full defaults (optional profiles enabled):
   ```bash
   make bootstrap-full
   # This mirrors the full .env template defaults.
   # BasicAuth htpasswd files are generated from .env credentials.
   ```
   Alternative: generate `.env` directly from the template:
   ```bash
   ./scripts/env-generate.sh --mode=prod
   # Use --mode=full for full defaults or --force to regenerate.
   # ./scripts/env-generate.sh --mode=full --force
   ```

3. **Generate local certificates**
   ```bash
   make certs-local
   ```

4. **Map local subdomains to loopback (recommended)**
   ```bash
   make hosts-generate
   sudo make hosts-apply
   make hosts-status
   ```

5. **Start the stack**
   ```bash
   make up
   ```

6. **Run smoke tests**
   ```bash
   make test
   ```

7. **Verify the demo service**
   ```bash
   curl -vk "https://whoami.${DEV_DOMAIN}"
   ```

For detailed TLS workflows, see:
- [Mode A: Self-signed](docs/tls-mode-a-selfsigned.md)
- [Mode B: Let's Encrypt + Certbot](docs/tls-mode-b-letsencrypt-certbot.md)
- [Mode C: Step-CA ACME](docs/tls-mode-c-stepca-acme.md)

<a id="endpoints"></a>
## Endpoints

- **Whoami**: `https://whoami.${DEV_DOMAIN}` (default stack; uses Traefik HTTPS)
- **Traefik dashboard**: `https://traefik.${DEV_DOMAIN}` (BasicAuth; enabled by default)
- **Step-CA UI**: `https://step-ca.${DEV_DOMAIN}` (profile `stepca`; enabled by default)
- **OpenWebUI**: `https://openwebui.${DEV_DOMAIN}` (profile `webui`)

<a id="services"></a>
## Services

- [Traefik](services/traefik/README.md) - reverse proxy and routing core.
- [Whoami](services/whoami/README.md) - demo service used for routing tests.
- [DNS (BIND)](services/dns-bind/README.md) - optional profile `bind`.
- [OpenWebUI](services/openwebui/README.md) - optional profile `webui`.
- [Certbot](services/certbot/README.md) - optional profile `le`.
- [Step-CA](services/step-ca/README.md) - optional profile `stepca`.

<a id="docs-map"></a>
## Docs map

- Overview, Quickstart, Endpoints, Operations, Testing, Troubleshooting (this page)
- TLS setup guides (in `docs/`):
  - [Mode A: Self-signed](docs/tls-mode-a-selfsigned.md)
  - [Mode B: Let's Encrypt + Certbot](docs/tls-mode-b-letsencrypt-certbot.md)
  - [Mode C: Step-CA ACME](docs/tls-mode-c-stepca-acme.md)
- Service pages (links above)
- Migration notes and how to add a new service doc (this page)

<a id="operations"></a>
## Operations

Common commands:
- `make up`, `make down`, `make logs`, `make ps`
- `make certs-local`
- `make certs-le-issue`, `make certs-le-renew` (profile `le`)
- `make stepca-up`, `make stepca-bootstrap`, `make stepca-trust-install`
- `make bind-up`, `make bind-status`, `make bind-restart`, `make bind-provision`
- `make hosts-generate`, `make hosts-apply`, `make hosts-status`

Auth files:
- `services/traefik/auth/traefik-dashboard.htpasswd.example` (Traefik dashboard BasicAuth)
- `make bootstrap-full` generates `services/traefik/auth/*.htpasswd` from `.env` values:
  - `TRAEFIK_DASHBOARD_BASIC_AUTH_USER` / `TRAEFIK_DASHBOARD_BASIC_AUTH_PASSWORD`
- To rotate credentials, update the `.env` values and re-run `./scripts/env-generate.sh --mode=full`.
- Preflight checks reject `.example` paths when enabling the Traefik dashboard.

Compose project pinning:
- The compose wrapper pins `--project-directory` and `--project-name` to avoid cross‑CWD conflicts. Override with `COMPOSE_PROJECT_NAME` in `.env` if needed.

DNS security defaults:
- BIND runs as authoritative local DNS with recursion disabled and AXFR blocked.
- `BIND_BIND_ADDRESS` controls the bind interface.
- Non-loopback exposure requires `BIND_ALLOW_NONLOCAL_BIND=true`.

<a id="testing"></a>
## Testing

Run the smoke tests with:
```bash
make test
```
See `tests/README.md` for details.
Operational scripts: see `scripts/README.md`.

<a id="troubleshooting"></a>
## Troubleshooting

- Check that `DEV_DOMAIN` and `BASE_DOMAIN` match your hosts/DNS setup.
- If ports 80/443 are in use, stop conflicting services and retry `make up`.
- Use `make logs` to inspect Traefik and service logs.

<a id="add-service-doc"></a>
## Add a service doc

1. Create `services/<service>/README.md`, `README.sv.md`, and `README.es.md`.
2. Add the language selector line at the top of each file.
3. Use the same anchors and section order as other service READMEs.
4. Add the service to `docs.manifest.json`.
5. Run `make docs-check`.

<a id="migration"></a>
## Migration note

- Root documentation now lives in `README.md`, `README.sv.md`, and `README.es.md`.
- Service documentation now lives under `services/<service>/README*.md`.
- Legacy `docs/` content remains for reference but is no longer the primary entry point.
- If you had custom links to old `docs/` pages, update them to the new README locations.
