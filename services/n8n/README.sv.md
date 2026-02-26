[English](README.md) | [Svenska](README.sv.md) | [Espanol](README.es.md)

# n8n-tjanst

<a id="overview"></a>
## Oversikt

n8n ar en valfri workflow-automationsservice som exponeras via Traefik pa `https://n8n.${DEV_DOMAIN}`.

<a id="location"></a>
## Placering

- `services/n8n/compose.yml`
- `services/n8n/config/n8n.env.example`
- `services/n8n/rendered/` (genererad; gitignorerad)

<a id="run"></a>
## Korning

```bash
make n8n-bootstrap
make n8n-up
make n8n-status
```

<a id="configuration"></a>
## Konfiguration

Relevanta variabler i `.env.example`:
- `N8N_HOSTNAME` (standard `n8n`)
- `N8N_DB_*`, `N8N_ENCRYPTION_KEY`
- `N8N_KEYCLOAK_*` (valfritt OIDC-runbook/guardrails)
- `N8N_OBSERVABILITY_*` (valfritt health/metrics)
- `N8N_STEPCA_TRUST_*` (valfritt)

<a id="ports"></a>
## Portar, natverk, volymer

- Portar: containerport `5678` (inte publicerad pa vardmaskinen)
- Natverk: `proxy`, `n8n-internal`
- Volymer: `n8n-data`, `n8n-db-data`

<a id="security"></a>
## Sakerhet

- n8n exponeras endast via Traefik.
- PostgreSQL kor pa ett internt natverk.
- Keycloak/OIDC och observability ar avstangda som standard.
- Vid step-ca-signerat Keycloak-certifikat, aktivera `N8N_STEPCA_TRUST_*` och kor `make n8n-bootstrap` igen.

<a id="troubleshooting"></a>
## Felsokning

- Om preflight sager att renderad konfiguration saknas eller ar gammal, kor `make n8n-bootstrap`.
- Kontrollera `make n8n-logs` for loggar fran `n8n` och `n8n-db`.
- Bekrafta att `n8n.${DEV_DOMAIN}` pekar mot denna vard (hosts eller DNS).
- Validera health med `curl -sk https://n8n.${DEV_DOMAIN}/healthz`.

<a id="related"></a>
## Relaterade sidor

- [Rot-README](../../README.sv.md)
- [Traefik](../traefik/README.sv.md)
- [Step-CA](../step-ca/README.sv.md)
