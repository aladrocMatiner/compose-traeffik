[English](README.md) | [Svenska](README.sv.md) | [Espanol](README.es.md)

# Step-CA service

<a id="overview"></a>
## Oversikt

Step-CA tillhandahaller en intern ACME-server (Mode C) for lokal certifikatutgivning.

<a id="location"></a>
## Var den finns

- `services/step-ca/compose.yml`
- `services/step-ca/config/`
- `services/step-ca/secrets/`

<a id="run"></a>
## Hur den kor

```bash
./scripts/compose.sh --profile stepca up -d step-ca
```

Bootstrap CA:
```bash
make stepca-bootstrap
```

<a id="configuration"></a>
## Konfiguration

Relevanta env vars i `.env.example`:
- `DEV_DOMAIN`
- `STEP_CA_NAME`
- `STEP_CA_ADMIN_PROVISIONER_PASSWORD`
- `STEP_CA_PASSWORD`
- `TLS_CERT_RESOLVER`

<a id="ports"></a>
## Portar, natverk, volymer

- Portar: container port `9000` (inte exponerad pa host)
- Natverk: `stepca-internal`, `proxy`
- Volymer:
  - `services/step-ca/config` -> `/home/step/config`
  - `services/step-ca/secrets` -> `/home/step/secrets`
  - `stepca-data` -> `/home/step/data`

<a id="security"></a>
## Sakerhetsnoter

- Bootstrap-losenord anvands endast vid `make stepca-bootstrap`.
- Hemligheter lagras under `services/step-ca/secrets`.

<a id="troubleshooting"></a>
## Felsokning

- Kontrollera att `stepca`-profilen ar aktiv och containern kor.
- Anvand `make logs` for att se `step-ca`-loggar.

<a id="related"></a>
## Relaterade sidor

- [Root README](../../README.sv.md)
- [Traefik](../traefik/README.sv.md)
