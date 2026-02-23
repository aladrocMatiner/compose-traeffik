[English](README.md) | [Svenska](README.sv.md) | [Espanol](README.es.md)

# wg-easy service (WireGuard)

<a id="overview"></a>
## Overview

`wg-easy` ger en WireGuard-server med webb-UI for att hantera peers och exportera klientkonfigurationer.
I detta projekt exponeras UI:t bakom Traefik over HTTPS, medan WireGuard-tunneln anvander en UDP-port pa hosten.

<a id="location"></a>
## Where it lives

- `services/wg-easy/compose.yml`
- `services/wg-easy/data/` (runtime state; gitignored)
- `scripts/wg-bootstrap.sh` (bootstrap av adminvariabler i `.env`)

<a id="run"></a>
## How it runs

Bootstrap adminvariabler i `.env` forst:
```bash
make wg-bootstrap
```

Starta servicen:
```bash
make wg-up
```

Inspektera status/loggar:
```bash
make wg-status
make wg-logs
```

Stoppa servicen:
```bash
make wg-down
```

<a id="configuration"></a>
## Configuration

Relevanta env-vars i `.env.example`:
- `WG_EASY_IMAGE`
- `WG_UI_HOSTNAME`
- `WG_UI_MIDDLEWARES`
- `WG_INSECURE` (maste vara `false` i denna integration)
- `WG_BIND_ADDRESS`
- `WG_ALLOW_NONLOCAL_BIND`
- `WG_SERVER_PORT`
- `WG_SERVER_ENDPOINT`
- `WG_INIT_ENABLED`
- `WG_INIT_USERNAME`
- `WG_INIT_PASSWORD` (genereras av `make wg-bootstrap`)
- `TLS_CERT_RESOLVER`
- `DEV_DOMAIN`

Bootstrap/rotation:
- `make wg-bootstrap` fyller saknade `WG_INIT_*` i `.env` och skriver inte over befintliga varden som standard.
- For rotation av supportade bootstrapvarden, kor `WG_BOOTSTRAP_ARGS=--force make wg-bootstrap`.

<a id="ports"></a>
## Ports, networks, volumes

- Ports:
  - UDP `WG_BIND_ADDRESS:WG_SERVER_PORT -> 51820/udp` (WireGuard-tunnel)
  - UI TCP-porten publiceras **inte** direkt pa hosten (serveras via Traefik)
- Networks:
  - `proxy`
- Volumes:
  - `services/wg-easy/data` -> `/etc/wireguard`

<a id="security"></a>
## Security notes

- Admin-UI routas via Traefik HTTPS och `WG_INSECURE=true` blockeras av preflight.
- Icke-loopback UDP-exponering kraver explicit bekraftelse: `WG_ALLOW_NONLOCAL_BIND=true`.
- Containern anvander explicita capabilities/devices och inte `privileged: true` som standard.
- Runtime-state under `services/wg-easy/data/` kan innehalla kansligt material och ar gitignored.

Host-prerequisites (vanliga Linux-miljoer):
- `/dev/net/tun` tillganglig
- Docker-engine med stod for kravda capabilities/devices
- Kernelstod for WireGuard / forwarding enligt hostens behov

<a id="troubleshooting"></a>
## Troubleshooting

- **UI kan inte nas pa `https://wg.<DEV_DOMAIN>`**
  - Kontrollera `make wg-status`, `make logs` och Traefik-loggar.
  - Kontrollera att `WG_UI_HOSTNAME` och `DEV_DOMAIN` matchar hosts/DNS.
  - Lagg till `wg` i `ENDPOINTS` och kor `make hosts-apply` igen om du anvander hosts-mappning.

- **Preflight blockerar WireGuard-start**
  - Kontrollera `WG_BIND_ADDRESS`, `WG_ALLOW_NONLOCAL_BIND`, `WG_SERVER_PORT`, `WG_SERVER_ENDPOINT` och `WG_INSECURE` i `.env`.

- **Containern startar inte (TUN/capabilities-fel)**
  - Bekrafta att `/dev/net/tun` finns och kan passeras till Docker.
  - Granska host/kernel-stod och runtime-restriktioner.

<a id="related"></a>
## Related pages

- [Root README](../../README.sv.md)
- [Traefik](../traefik/README.sv.md)
- `tests/README.md`
- `scripts/README.md`
