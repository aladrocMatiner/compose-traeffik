[English](README.md) | [Svenska](README.sv.md) | [Espanol](README.es.md)

# FreeIPA service

<a id="overview"></a>
## Overview

FreeIPA is an optional identity-management module exposed behind Traefik. This module provides the FreeIPA web entrypoint with persistent data storage and profile-gated integration contracts for TLS mode, Keycloak, and observability.

<a id="location"></a>
## Where it lives

- `services/freeipa/compose.yml`

<a id="run"></a>
## How it runs

```bash
make freeipa-bootstrap
make freeipa-up
make freeipa-status
```

URL (when routed via Traefik): `https://freeipa.${DEV_DOMAIN}`

<a id="configuration"></a>
## Configuration

Relevant env vars in `.env.example`:
- `FREEIPA_HOSTNAME`
- `FREEIPA_IMAGE`
- `FREEIPA_SERVER_HOSTNAME`
- `FREEIPA_REALM`, `FREEIPA_DOMAIN`
- `FREEIPA_ADMIN_PASSWORD`, `FREEIPA_DM_PASSWORD`
- `FREEIPA_INSTALL_OPTS`
- `FREEIPA_TLS_MODE`

Optional integrations:
- Keycloak contract: `FREEIPA_KEYCLOAK_*`, `FREEIPA_TRAEFIK_MIDDLEWARES`
- Observability hooks: `FREEIPA_OBSERVABILITY_*`, `FREEIPA_OTEL_*`

Bootstrap secrets with `make freeipa-bootstrap`.

<a id="ports"></a>
## Ports, networks, volumes

- Public ports: none (Traefik handles public exposure)
- Networks:
  - `proxy` (Traefik routing)
  - `freeipa-internal` (internal module traffic)
- Volumes:
  - `freeipa-data`

<a id="security"></a>
## Security notes

- FreeIPA does not publish host ports by default.
- UI exposure is through Traefik HTTPS routing only.
- The module keeps data on a dedicated volume.
- TLS mode compatibility is governed by `FREEIPA_TLS_MODE` and `TLS_CERT_RESOLVER` (supports local CA, LE, and Step-CA mode contracts).
- Preflight checks are profile-gated and only enforce FreeIPA checks when `freeipa` profile is enabled.

<a id="troubleshooting"></a>
## Troubleshooting

- If preflight fails due to missing secrets, run:
  - `make freeipa-bootstrap`
- If TLS contract fails in Step-CA mode, set:
  - `TLS_CERT_RESOLVER=stepca-resolver` or enable `stepca` profile
- If Keycloak integration is enabled, ensure all `FREEIPA_KEYCLOAK_*` values are set and middleware includes `keycloak-forward-auth@file`.

<a id="related"></a>
## Related pages

- [Root README](../../README.md)
- [Traefik](../traefik/README.md)
- [Step-CA](../step-ca/README.md)
- [Observability](../observability/README.md)
