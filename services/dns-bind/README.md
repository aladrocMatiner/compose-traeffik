[English](README.md) | [Svenska](README.sv.md) | [Espanol](README.es.md)

# DNS service (BIND)

<a id="overview"></a>
## Overview

BIND is an optional DNS profile that serves local zones for project domains. A web UI is exposed through Traefik at `https://bind.${BASE_DOMAIN}`.

<a id="location"></a>
## Where it lives

- `services/dns-bind/compose.yml`
- `services/dns-bind/config/`
- `services/dns-bind/zones/`

<a id="run"></a>
## How it runs

Provision the zone file:
```bash
make bind-provision
```

Start the service:
```bash
make bind-up
```

View logs:
```bash
make bind-logs
```

Stop the service:
```bash
make bind-down
```

<a id="configuration"></a>
## Configuration

Relevant env vars in `.env.example`:
- `BASE_DOMAIN`
- `LOOPBACK_X`
- `ENDPOINTS`
- `BIND_BIND_ADDRESS`
- `BIND_UI_HOSTNAME`
- `BIND_UI_BASIC_AUTH_USER`
- `BIND_UI_BASIC_AUTH_PASSWORD`
- `BIND_UI_BASIC_AUTH_HTPASSWD_PATH`

<a id="ports"></a>
## Ports, networks, volumes

- Ports: `53/udp`, `53/tcp` (bound to `BIND_BIND_ADDRESS`)
- Network: `proxy` (`traefik-proxy`)
- Volumes: `services/dns-bind/config` and `services/dns-bind/zones`

<a id="security"></a>
## Security notes

- The UI is exposed only via Traefik and protected by BasicAuth.
- The UI port is not published directly on the host.
- Do not enable both `dns` and `bind` profiles on the same host (port 53 conflict).

<a id="troubleshooting"></a>
## Troubleshooting

- Port 53 already in use: stop the conflicting service or change `BIND_BIND_ADDRESS`.
- UI auth failures: regenerate `bind-ui.htpasswd` via `./scripts/env-generate.sh --mode=full`.
- Missing zone file: run `make bind-provision` before starting the service.

<a id="related"></a>
## Related pages

- [Root README](../../README.md)
- [Traefik](../traefik/README.md)
