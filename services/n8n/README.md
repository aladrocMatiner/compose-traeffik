[English](README.md) | [Svenska](README.sv.md) | [Espanol](README.es.md)

# n8n service

<a id="overview"></a>
## Overview

n8n is an optional workflow automation service exposed through Traefik at `https://n8n.${DEV_DOMAIN}`.

<a id="location"></a>
## Where it lives

- `services/n8n/compose.yml`
- `services/n8n/config/n8n.env.example`
- `services/n8n/rendered/` (generated; gitignored)

<a id="run"></a>
## How it runs

```bash
make n8n-bootstrap
make n8n-up
make n8n-status
```

<a id="configuration"></a>
## Configuration

Relevant env vars in `.env.example`:
- `N8N_HOSTNAME` (default `n8n`)
- `N8N_DB_*`, `N8N_ENCRYPTION_KEY`
- `N8N_KEYCLOAK_*` (optional OIDC runbook/guardrails)
- `N8N_OBSERVABILITY_*` (optional health/metrics hooks)
- `N8N_STEPCA_TRUST_*` (optional outbound CA trust)

<a id="ports"></a>
## Ports, networks, volumes

- Ports: container port `5678` (not published to host)
- Networks: `proxy`, `n8n-internal`
- Volumes: `n8n-data`, `n8n-db-data`

<a id="security"></a>
## Security notes

- n8n is exposed only through Traefik.
- PostgreSQL runs on an internal network only.
- OIDC/Keycloak and observability hooks are disabled by default.
- If using a step-ca-signed Keycloak issuer, enable the n8n step-ca trust options and rerun `make n8n-bootstrap`.

<a id="troubleshooting"></a>
## Troubleshooting

- If preflight says rendered config is missing or stale, run `make n8n-bootstrap`.
- Check `make n8n-logs` for both `n8n` and `n8n-db` logs.
- Verify `n8n.${DEV_DOMAIN}` resolves to this host (hosts file or DNS).
- Validate health with `curl -sk https://n8n.${DEV_DOMAIN}/healthz`.

<a id="related"></a>
## Related pages

- [Root README](../../README.md)
- [Traefik](../traefik/README.md)
- [Step-CA](../step-ca/README.md)
