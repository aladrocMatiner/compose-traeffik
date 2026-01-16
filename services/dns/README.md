[English](README.md) | [Svenska](README.sv.md) | [Espanol](README.es.md)

# DNS service (Technitium)

<a id="overview"></a>
## Overview

Technitium DNS is an optional profile that provides DNS for the project domain and exposes its UI through Traefik.

<a id="location"></a>
## Where it lives

- `services/dns/compose.yml`
- `services/dns/data/`

<a id="run"></a>
## How it runs

```bash
./scripts/compose.sh --profile dns up -d dns
```

Provision records:
```bash
make dns-provision
```

Configure Ubuntu split-DNS:
```bash
sudo make dns-config-apply
```

<a id="configuration"></a>
## Configuration

Relevant env vars in `.env.example`:
- `BASE_DOMAIN`
- `DNS_ADMIN_PASSWORD`
- `DNS_BIND_ADDRESS`
- `DNS_UI_HOSTNAME`
- `DNS_UI_MIDDLEWARES`
- `DNS_UI_ALLOWLIST_SOURCE_RANGES`
- `LOOPBACK_X`
- `ENDPOINTS`

<a id="ports"></a>
## Ports, networks, volumes

- Ports: `53/udp`, `53/tcp` (bound to `DNS_BIND_ADDRESS`)
- Network: `proxy` (`traefik-proxy`)
- Volume: `services/dns/data` -> `/etc/dns`

<a id="security"></a>
## Security notes

- UI is exposed only via Traefik on `https://dns.${BASE_DOMAIN}`.
- Port 53 binds to localhost by default.

<a id="troubleshooting"></a>
## Troubleshooting

- Ensure the `dns` profile is enabled and `DNS_ADMIN_PASSWORD` is set.
- Use `make dns-logs` and `make dns-status`.

<a id="related"></a>
## Related pages

- [Root README](../../README.md)
- [Traefik](../traefik/README.md)
