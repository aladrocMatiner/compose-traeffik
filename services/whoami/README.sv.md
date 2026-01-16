[English](README.md) | [Svenska](README.sv.md) | [Espanol](README.es.md)

# Whoami service

<a id="overview"></a>
## Oversikt

Whoami ar en demo-service som anvands for routing- och TLS-smoke tests.

<a id="location"></a>
## Var den finns

- `services/whoami/compose.yml`

<a id="run"></a>
## Hur den kor

```bash
./scripts/compose.sh up -d whoami
```

<a id="configuration"></a>
## Konfiguration

Relevanta env vars i `.env.example`:
- `DEV_DOMAIN`
- `TLS_CERT_RESOLVER`

<a id="ports"></a>
## Portar, natverk, volymer

- Portar: container port `80` (inte exponerad pa host)
- Natverk: `proxy` (`traefik-proxy`)
- Volymer: inga

<a id="security"></a>
## Sakerhetsnoter

- Servicen exponeras endast via Traefik routing-regler.

<a id="troubleshooting"></a>
## Felsokning

- Kontrollera att Traefik kor: `make ps` och `make logs`.
- Verifiera att `DEV_DOMAIN` finns i hosts/DNS.

<a id="related"></a>
## Relaterade sidor

- [Root README](../../README.sv.md)
- [Traefik](../traefik/README.sv.md)
