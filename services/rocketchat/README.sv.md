[English](README.md) | [Svenska](README.sv.md) | [Espanol](README.es.md)

# Rocket.Chat-tjanst

<a id="overview"></a>
## Overview

Rocket.Chat ar en valfri riktig applikationsmodul for denna stack. Den kor bakom Traefik och inkluderar MongoDB (replica set init-helper) och NATS i profilen `rocketchat`.

<a id="location"></a>
## Where it lives

- `services/rocketchat/compose.yml`
- `services/rocketchat/config/rocketchat.env.example` (trackad fallback for compose-parsning)
- `services/rocketchat/rendered/` (genereras av `make rocketchat-bootstrap`, gitignored)

<a id="run"></a>
## How it runs

Rendera konfigurationsartefakter:
```bash
make rocketchat-bootstrap
```

Starta profilen:
```bash
make rocketchat-up
```

Status:
```bash
make rocketchat-status
```

Loggar:
```bash
make rocketchat-logs
```

Stoppa:
```bash
make rocketchat-down
```

<a id="configuration"></a>
## Configuration

Relevanta env-vars i `.env.example`:
- `ROCKETCHAT_VERSION`, `ROCKETCHAT_IMAGE`
- `ROCKETCHAT_HOSTNAME`, `ROCKETCHAT_PORT`
- `ROCKETCHAT_MONGODB_*`, `ROCKETCHAT_NATS_VERSION`
- `ROCKETCHAT_RENDERED_ENV_PATH`
- `ROCKETCHAT_OBSERVABILITY_ENABLED`, `ROCKETCHAT_METRICS_PORT`
- `ROCKETCHAT_KEYCLOAK_ENABLED`, `ROCKETCHAT_KEYCLOAK_*`
- `DEV_DOMAIN`, `TLS_CERT_RESOLVER`

Renderade artefakter (gitignored):
- Rocket.Chat runtime-env: `services/rocketchat/rendered/rocketchat.env`
- Keycloak-checklista: `services/rocketchat/rendered/keycloak-custom-oauth.md`

Keycloak-integration:
- Valfri och avstangd som standard.
- Detta repo renderar en checklista/runbook (callback-URL + endpoint-vagar) fran `.env`.
- Skapande av Custom OAuth-provider i Rocket.Chat ar fortfarande ett manuellt admin-UI-steg.

Observability-hooks:
- Valfria och avstangda som standard (`ROCKETCHAT_OBSERVABILITY_ENABLED=false`).
- Nar aktiverat slar renderingen pa Rocket.Chat Prometheus-installningar och scrape-labels.
- Metrics exponeras inte publikt via Traefik som standard.

<a id="ports"></a>
## Ports, networks, volumes

- Publik endpoint: `https://rocketchat.${DEV_DOMAIN}` via Traefik (ingen direkt host-port for appen)
- Interna portar (endast container): Rocket.Chat `3000`, metrics `9458`, MongoDB `27017`, NATS `4222/8222`
- Natverk: `proxy` och privat `rocketchat-internal`
- Volymer: `rocketchat-uploads`, `rocketchat-mongodb-data`

<a id="security"></a>
## Security notes

- Lagg till `rocketchat` i `ENDPOINTS` (eller DNS/hosts) for lokal namnupplosning.
- Preflight validering misslyckas om renderad Rocket.Chat env-fil saknas; kor `make rocketchat-bootstrap` forst.
- Keycloak-inputs valideras bara nar `ROCKETCHAT_KEYCLOAK_ENABLED=true` (HTTPS issuer och kravda credentials).
- Rocket.Chat routas via Traefik och anvander samma TLS-lage som stacken (self-signed, LE eller valfri step-ca).

<a id="troubleshooting"></a>
## Troubleshooting

- `make rocketchat-up` misslyckas med renderad config: kor `make rocketchat-bootstrap` och kontrollera `services/rocketchat/rendered/rocketchat.env`.
- Rocket.Chat vantar pa beroenden: kontrollera `make rocketchat-logs` for `rocketchat-mongodb`, `rocketchat-mongodb-init` och `rocketchat-nats`.
- Keycloak-knapp visas inte: bekrafta manuell Custom OAuth-konfiguration i Rocket.Chat admin-UI och jamfor med `services/rocketchat/rendered/keycloak-custom-oauth.md`.
- Lokala TLS trust-problem (step-ca eller self-signed): se TLS-guiderna och trust-steg i root-dokumentationen.

<a id="related"></a>
## Related pages

- [Root README](../../README.sv.md)
- [Traefik](../traefik/README.sv.md)
- [Step-CA](../step-ca/README.sv.md)
