[English](README.md) | [Svenska](README.sv.md) | [Espanol](README.es.md)

# Traefik service

<a id="overview"></a>
## Overview

Traefik is the reverse proxy and routing core for this stack. It handles HTTP/HTTPS entrypoints and loads dynamic configuration from `services/traefik/dynamic-rendered`.

<a id="location"></a>
## Where it lives

- `services/traefik/compose.yml`
- `services/traefik/traefik.yml`
- `services/traefik/dynamic/`
- `services/traefik/dynamic-rendered/`
- `services/traefik/auth/`

<a id="run"></a>
## How it runs

```bash
./scripts/compose.sh up -d traefik
```

The dynamic config is rendered by `scripts/traefik-render-dynamic.sh`, which is invoked by `scripts/up.sh`.

<a id="configuration"></a>
## Configuration

Relevant env vars in `.env.example`:
- `DEV_DOMAIN`
- `TRAEFIK_IMAGE`
- `TLS_CERT_RESOLVER`

<a id="ports"></a>
## Ports, networks, volumes

- Ports: `80`, `443`, `8080`
- Network: `proxy` (`traefik-proxy`)
- Volumes:
  - `/var/run/docker.sock` (read-only)
  - `services/traefik/traefik.yml`
  - `services/traefik/dynamic-rendered`
  - `certs-data` volume
  - `shared/certs/local`

<a id="security"></a>
## Security notes

- Dashboard is disabled for insecure access (`api.insecure=false`).
- Access to the dashboard requires explicit routing and middleware.

<a id="troubleshooting"></a>
## Troubleshooting

- Run `make logs` and inspect the `traefik` service logs.
- If routing fails, re-run `make up` to re-render dynamic config.

<a id="related"></a>
## Related pages

- [Root README](../../README.md)
- [Whoami](../whoami/README.md)
