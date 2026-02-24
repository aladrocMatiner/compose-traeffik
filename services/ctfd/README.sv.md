[English](README.md) | [Svenska](README.sv.md) | [Espanol](README.es.md)

# CTFd service

<a id="overview"></a>
## Oversikt

CTFd ar en valfri CTF-plattformmodul exponerad bakom Traefik. Modulen kor `ctfd` med interna beroenden MariaDB och Redis.

<a id="location"></a>
## Var den finns

- `services/ctfd/compose.yml`

<a id="run"></a>
## Hur den kor

```bash
make ctfd-bootstrap
make ctfd-up
make ctfd-status
```

URL (via Traefik): `https://ctfd.${DEV_DOMAIN}`

<a id="configuration"></a>
## Konfiguration

Relevanta env vars i `.env.example`:
- `CTFD_HOSTNAME`
- `CTFD_IMAGE`
- `CTFD_DB_IMAGE`
- `CTFD_REDIS_IMAGE`
- `CTFD_SECRET_KEY`
- `CTFD_DB_NAME`
- `CTFD_DB_USER`
- `CTFD_DB_PASSWORD`
- `CTFD_DB_ROOT_PASSWORD`
- `CTFD_WORKERS`

Skapa/persista hemligheter med `make ctfd-bootstrap`.

<a id="ports"></a>
## Portar, natverk, volymer

- Publika portar: inga (Traefik exponerar UI)
- Natverk:
  - `proxy` (endast CTFd-app)
  - `ctfd-internal` (app/db/cache-trafik)
- Volymer:
  - `ctfd-db-data`
  - `ctfd-redis-data`
  - `ctfd-uploads`
  - `ctfd-logs`

<a id="security"></a>
## Sakerhetsnoter

- CTFd, MariaDB och Redis publicerar inga host-portar som standard.
- UI exponeras endast via Traefik over HTTPS.
- DB/cache isoleras i internt natverk.
- Preflight kraver CTFd-hemligheter nar profilen `ctfd` ar aktiv.

<a id="troubleshooting"></a>
## Felsokning

- Forsta admin-kontot skapas i CTFd-webbgranssnittet.
- Vid omstarter, kontrollera DB/cache readiness:
  - `make ctfd-logs`
- Om preflight faller, generera hemligheter:
  - `make ctfd-bootstrap`

<a id="related"></a>
## Relaterade sidor

- [Root README](../../README.sv.md)
- [Traefik](../traefik/README.sv.md)
- [Observability](../observability/README.sv.md)
