[English](README.md) | [Svenska](README.sv.md) | [Espanol](README.es.md)

# Traefik Docker Compose Edge Stack

<a id="overview"></a>
## Overview

This repository provides a Docker Compose edge stack centered on Traefik. It is designed for local development, with optional profiles for DNS, Let's Encrypt (Certbot), and step-ca. The documentation system is README-based and available in English, Swedish, and Spanish.

<a id="quickstart"></a>
## Quickstart (Mode A: Local Self-Signed TLS)

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd <repository-name>
   ```

2. **Create your env file**
   ```bash
   cp .env.example .env
   # Update DEV_DOMAIN, BASE_DOMAIN, LOOPBACK_X, ENDPOINTS as needed.
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
   Open `https://whoami.${DEV_DOMAIN}` in a browser.

<a id="services"></a>
## Services

- [Traefik](services/traefik/README.md) - reverse proxy and routing core.
- [Whoami](services/whoami/README.md) - demo service used for routing tests.
- [DNS (Technitium)](services/dns/README.md) - optional profile `dns`.
- [Certbot](services/certbot/README.md) - optional profile `le`.
- [Step-CA](services/step-ca/README.md) - optional profile `stepca`.

<a id="docs-map"></a>
## Docs map

- Overview, Quickstart, Operations, Testing, Troubleshooting (this page)
- Service pages (links above)
- Migration notes and how to add a new service doc (this page)

<a id="operations"></a>
## Operations

Common commands:
- `make up`, `make down`, `make logs`, `make ps`
- `make certs-local`
- `make certbot-issue`, `make certbot-renew` (profile `le`)
- `make stepca-up`, `make stepca-bootstrap`, `make stepca-trust-install`
- `make dns-up`, `make dns-provision`, `make dns-config-apply`
- `make hosts-generate`, `make hosts-apply`, `make hosts-status`

<a id="testing"></a>
## Testing

Run the smoke tests with:
```bash
make test
```

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
