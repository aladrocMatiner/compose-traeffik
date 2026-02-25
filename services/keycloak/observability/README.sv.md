[English](README.md) | [Svenska](README.sv.md) | [Espanol](README.es.md)

# Keycloak Observability Hooks (Valfritt)

Denna modul kravs inte for att Keycloak ska fungera.

Nar `KEYCLOAK_OBSERVABILITY_ENABLED=true`:
- Keycloak aktiverar intern metrik pa management-granssnittet (`/metrics`, standardport `9000`)
- Containern exponerar labels for observability discovery (standardstrategi: `labels`)
- Ingen publik metrics-router i Traefik skapas som standard
