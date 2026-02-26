[English](README.md) | [Svenska](README.sv.md) | [Espanol](README.es.md)

# Wiki.js service

<a id="overview"></a>
## Overview

Wiki.js is an optional documentation/wiki application module exposed through Traefik at `https://wiki.${DEV_DOMAIN}`.

<a id="location"></a>
## Where it lives

- `services/wikijs/compose.yml`
- `services/wikijs/config/wikijs.env.example`
- `services/wikijs/rendered/` (generated; gitignored)

<a id="run"></a>
## How it runs

```bash
make wikijs-bootstrap
make wikijs-up
make wikijs-status
```

<a id="configuration"></a>
## Configuration

Relevant env vars in `.env.example`:
- `WIKIJS_HOSTNAME` (default `wiki`)
- `WIKIJS_IMAGE`
- `WIKIJS_DB_*`
- `WIKIJS_KEYCLOAK_*` (optional)
- `WIKIJS_OBSERVABILITY_*` (optional)
- `WIKIJS_STEPCA_TRUST_*` (optional)

<a id="ports"></a>
## Ports, networks, volumes

- Ports: container port `3000` (not published to host)
- Networks: `proxy`, `wikijs-internal`
- Volumes: `wikijs-data`, `wikijs-db-data`

<a id="security"></a>
## Security notes

- Wiki.js is only exposed through Traefik routers.
- The database is on an internal network only.
- Keycloak and observability integrations are disabled by default.
- If using a step-ca-signed Keycloak issuer, enable the Wiki.js step-ca trust options and rerun `make wikijs-bootstrap`.

<a id="troubleshooting"></a>
## Troubleshooting

- If preflight says rendered config is missing or stale, run `make wikijs-bootstrap`.
- Check `make wikijs-logs` for both `wikijs` and `wikijs-db` logs.
- Verify `wiki.${DEV_DOMAIN}` resolves to this host (hosts file or DNS).

<a id="related"></a>
## Related pages

- [Root README](../../README.md)
- [Traefik](../traefik/README.md)
- [Step-CA](../step-ca/README.md)
