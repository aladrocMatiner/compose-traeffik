[English](README.md) | [Svenska](README.sv.md) | [Espanol](README.es.md)

# DNS service (BIND)

<a id="overview"></a>
## Oversikt

BIND ar en valfri DNS-profil som serverar lokala zoner for projektets domaner.

<a id="location"></a>
## Var finns det

- `services/dns-bind/compose.yml`
- `services/dns-bind/config/`
- `services/dns-bind/zones/`

<a id="run"></a>
## Hur den kor

Provisionera zone-filen:
```bash
make bind-provision
```

Starta tjansten:
```bash
make bind-up
```

Visa loggar:
```bash
make bind-logs
```

Stoppa tjansten:
```bash
make bind-down
```

<a id="configuration"></a>
## Konfiguration

Relevanta env vars i `.env.example`:
- `BASE_DOMAIN`
- `LOOPBACK_X`
- `ENDPOINTS`
- `BIND_BIND_ADDRESS`

<a id="ports"></a>
## Portar, natverk, volymer

- Portar: `53/udp`, `53/tcp` (bundna till `BIND_BIND_ADDRESS`)
- Natverk: `proxy` (`traefik-proxy`)
- Volymer: `services/dns-bind/config` och `services/dns-bind/zones`

<a id="security"></a>
## Sakerhetsnoter

- Aktivera inte `dns` och `bind` samtidigt (port 53-konflikt).

<a id="troubleshooting"></a>
## Felsokning

- Port 53 ar upptagen: stoppa den konflikterande tjansten eller byt `BIND_BIND_ADDRESS`.
- Zone-filen saknas: kor `make bind-provision` innan du startar.

<a id="related"></a>
## Relaterade sidor

- [Root README](../../README.sv.md)
- [Traefik](../traefik/README.sv.md)
