[English](README.md) | [Svenska](README.sv.md) | [Espanol](README.es.md)

# Whoami service

<a id="overview"></a>
## Overview

Whoami is a demo service used for routing and TLS smoke tests.

<a id="location"></a>
## Where it lives

- `services/whoami/compose.yml`

<a id="run"></a>
## How it runs

```bash
./scripts/compose.sh up -d whoami
```

<a id="configuration"></a>
## Configuration

Relevant env vars in `.env.example`:
- `DEV_DOMAIN`
- `TLS_CERT_RESOLVER`

<a id="ports"></a>
## Ports, networks, volumes

- Ports: container port `80` (not published to host)
- Network: `proxy` (`traefik-proxy`)
- Volumes: none

<a id="security"></a>
## Security notes

- The service is only exposed via Traefik routing rules.

<a id="troubleshooting"></a>
## Troubleshooting

- Verify Traefik is running: `make ps` and `make logs`.
- Confirm the `DEV_DOMAIN` host exists in your hosts/DNS setup.

<a id="related"></a>
## Related pages

- [Root README](../../README.md)
- [Traefik](../traefik/README.md)
