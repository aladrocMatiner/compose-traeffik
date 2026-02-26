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

Visa status:
```bash
make bind-status
```

Kor port-preflight:
```bash
make bind-port-check
```

Starta om efter konfigurationsandringar:
```bash
make bind-restart
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

Sokvag for zonfil:
- Genererad fil: `services/dns-bind/zones/db.${BASE_DOMAIN}`
- Exempel: `services/dns-bind/zones/db.aladroc.io`
- Lagg till egna DNS-poster i den filen `db.<domän>`.

<a id="ports"></a>
## Portar, natverk, volymer

- Portar: `53/udp`, `53/tcp` (bundna till `BIND_BIND_ADDRESS`)
- Natverk: `proxy` (`traefik-proxy`)
- Volymer: `services/dns-bind/config` och `services/dns-bind/zones`

<a id="security"></a>
## Sakerhetsnoter

- Kor inte en annan DNS-tjanst pa samma host (port 53-konflikt).

<a id="troubleshooting"></a>
## Felsokning

- Port 53 ar upptagen: stoppa den konflikterande tjansten eller byt `BIND_BIND_ADDRESS`.
- Kor `make bind-port-check` for att lista lokala lyssnare pa port 53 innan start.
- Zone-filen saknas: kor `make bind-provision` innan du startar.

<a id="related"></a>
## Relaterade sidor

- [Root README](../../README.sv.md)
- [Traefik](../traefik/README.sv.md)
