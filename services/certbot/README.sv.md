[English](README.md) | [Svenska](README.sv.md) | [Espanol](README.es.md)

# Certbot service

<a id="overview"></a>
## Oversikt

Certbot ar en valfri profil for att utfarda och fornya Let's Encrypt-certifikat.

<a id="location"></a>
## Var den finns

- `services/certbot/compose.yml`
- `services/certbot/conf/`
- `services/certbot/www/`

<a id="run"></a>
## Hur den kor

Starta profilcontainrarna (certbot + certbot-web):
```bash
./scripts/compose.sh --profile le up -d certbot certbot-web
```

Utfarda eller fornya certifikat:
```bash
make certs-le-issue
make certs-le-renew
```

<a id="configuration"></a>
## Konfiguration

Relevanta env vars i `.env.example`:
- `DEV_DOMAIN`
- `ACME_EMAIL`
- `LETSENCRYPT_STAGING`

<a id="ports"></a>
## Portar, natverk, volymer

- Portar: inga direkta bindningar; Traefik routar `/.well-known/acme-challenge/` till `certbot-web` och Certbot anvander `--webroot`
- Natverk: default compose-natverk
- Volymer:
  - `services/certbot/conf` -> `/etc/letsencrypt`
  - `services/certbot/www` -> `/var/www/certbot`

<a id="security"></a>
## Sakerhetsnoter

- Profilen `le` ar valfri och bor endast aktiveras vid behov.

<a id="troubleshooting"></a>
## Felsokning

- Kontrollera att `ACME_EMAIL` ar satt i `.env`.
- Om issuance misslyckas, kontrollera `make logs certbot`.

<a id="related"></a>
## Relaterade sidor

- [Root README](../../README.sv.md)
- [Traefik](../traefik/README.sv.md)
