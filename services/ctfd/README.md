[English](README.md) | [Svenska](README.sv.md) | [Espanol](README.es.md)

# CTFd service

<a id="overview"></a>
## Overview

CTFd is an optional CTF platform module exposed behind Traefik. This module runs `ctfd` plus internal MariaDB and Redis dependencies.

<a id="location"></a>
## Where it lives

- `services/ctfd/compose.yml`

<a id="run"></a>
## How it runs

```bash
make ctfd-bootstrap
make ctfd-up
make ctfd-status
```

URL (when routed via Traefik): `https://ctfd.${DEV_DOMAIN}`

<a id="configuration"></a>
## Configuration

Relevant env vars in `.env.example`:
- `CTFD_HOSTNAME`
- `CTFD_IMAGE`
- `CTFD_DB_IMAGE`
- `CTFD_REDIS_IMAGE`
- `CTFD_SECRET_KEY`
- `CTFD_DB_NAME`
- `CTFD_DB_USER`
- `CTFD_DB_PASSWORD`
- `CTFD_DB_ROOT_PASSWORD`
- `CTFD_WORKERS`

Secrets can be generated/persisted with `make ctfd-bootstrap`.

<a id="ports"></a>
## Ports, networks, volumes

- Public ports: none (Traefik handles public exposure)
- Networks:
  - `proxy` (CTFd app only, for Traefik routing)
  - `ctfd-internal` (internal app/db/cache traffic)
- Volumes:
  - `ctfd-db-data`
  - `ctfd-redis-data`
  - `ctfd-uploads`
  - `ctfd-logs`

<a id="security"></a>
## Security notes

- CTFd, MariaDB, and Redis do not publish host ports by default.
- The UI is exposed only through Traefik HTTPS routing.
- Database/cache are isolated on an internal network.
- Preflight checks require CTFd secrets when profile `ctfd` is enabled.

<a id="troubleshooting"></a>
## Troubleshooting

- First run admin setup is done in the CTFd web UI.
- If startup loops, inspect DB/cache readiness:
  - `make ctfd-logs`
- If preflight fails, generate missing secrets:
  - `make ctfd-bootstrap`

<a id="related"></a>
## Related pages

- [Root README](../../README.md)
- [Traefik](../traefik/README.md)
- [Observability](../observability/README.md)
