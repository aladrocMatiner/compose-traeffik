[English](README.md) | [Svenska](README.sv.md) | [Espanol](README.es.md)

# Traefik service

<a id="overview"></a>
## Oversikt

Traefik ar reverse proxy och routing-karnan for denna stack. Den hanterar HTTP/HTTPS och laddar dynamisk konfiguration fran `services/traefik/dynamic-rendered`.

<a id="location"></a>
## Var den finns

- `services/traefik/compose.yml`
- `services/traefik/traefik.yml`
- `services/traefik/dynamic/`
- `services/traefik/dynamic-rendered/`
- `services/traefik/auth/`

<a id="run"></a>
## Hur den kor

```bash
./scripts/compose.sh up -d traefik
```

Den dynamiska konfigurationen renderas av `scripts/traefik-render-dynamic.sh`, som koras av `scripts/up.sh`.

<a id="configuration"></a>
## Konfiguration

Relevanta env vars i `.env.example`:
- `DEV_DOMAIN`
- `TRAEFIK_IMAGE`
- `TLS_CERT_RESOLVER`

<a id="ports"></a>
## Portar, natverk, volymer

- Portar: `80`, `443`, `8080`
- Natverk: `proxy` (`traefik-proxy`)
- Volymer:
  - `/var/run/docker.sock` (read-only)
  - `services/traefik/traefik.yml`
  - `services/traefik/dynamic-rendered`
  - `certs-data` volume
  - `shared/certs/local`

<a id="security"></a>
## Sakerhetsnoter

- Dashboard ar inte oinloggad (`api.insecure=false`).
- Exponering kraver explicit routing och middleware.

<a id="troubleshooting"></a>
## Felsokning

- Kor `make logs` och inspektera `traefik`-loggarna.
- Om routing fallerar, kor `make up` igen for att rendera om dynamisk config.

<a id="related"></a>
## Relaterade sidor

- [Root README](../../README.sv.md)
- [Whoami](../whoami/README.sv.md)
