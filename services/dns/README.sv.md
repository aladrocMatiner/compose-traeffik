[English](README.md) | [Svenska](README.sv.md) | [Espanol](README.es.md)

# DNS service (Technitium)

<a id="overview"></a>
## Oversikt

Technitium DNS ar en valfri profil som ger DNS for projektdomannen och exponerar UI via Traefik.

<a id="location"></a>
## Var den finns

- `services/dns/compose.yml`
- `services/dns/data/`

<a id="run"></a>
## Hur den kor

```bash
./scripts/compose.sh --profile dns up -d dns
```

Provisionera records:
```bash
make dns-provision
```

Konfigurera Ubuntu split-DNS:
```bash
sudo make dns-config-apply
```

<a id="configuration"></a>
## Konfiguration

Relevanta env vars i `.env.example`:
- `BASE_DOMAIN`
- `DNS_ADMIN_PASSWORD`
- `DNS_BIND_ADDRESS`
- `DNS_UI_HOSTNAME`
- `DNS_UI_MIDDLEWARES`
- `DNS_UI_ALLOWLIST_SOURCE_RANGES`
- `LOOPBACK_X`
- `ENDPOINTS`

<a id="ports"></a>
## Portar, natverk, volymer

- Portar: `53/udp`, `53/tcp` (bundna till `DNS_BIND_ADDRESS`)
- Natverk: `proxy` (`traefik-proxy`)
- Volym: `services/dns/data` -> `/etc/dns`

<a id="security"></a>
## Sakerhetsnoter

- UI exponeras endast via Traefik pa `https://dns.${BASE_DOMAIN}`.
- Port 53 binder till localhost som standard.

<a id="troubleshooting"></a>
## Felsokning

- Kontrollera att `dns`-profilen ar aktiv och att `DNS_ADMIN_PASSWORD` ar satt.
- Anvand `make dns-logs` och `make dns-status`.

<a id="related"></a>
## Relaterade sidor

- [Root README](../../README.sv.md)
- [Traefik](../traefik/README.sv.md)
