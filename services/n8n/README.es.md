[English](README.md) | [Svenska](README.sv.md) | [Espanol](README.es.md)

# Servicio n8n

<a id="overview"></a>
## Resumen

n8n es un servicio opcional de automatizacion/workflows expuesto por Traefik en `https://n8n.${DEV_DOMAIN}`.

<a id="location"></a>
## Ubicacion

- `services/n8n/compose.yml`
- `services/n8n/config/n8n.env.example`
- `services/n8n/rendered/` (generado; ignorado por git)

<a id="run"></a>
## Ejecucion

```bash
make n8n-bootstrap
make n8n-up
make n8n-status
```

<a id="configuration"></a>
## Configuracion

Variables relevantes en `.env.example`:
- `N8N_HOSTNAME` (por defecto `n8n`)
- `N8N_DB_*`, `N8N_ENCRYPTION_KEY`
- `N8N_KEYCLOAK_*` (opcional; runbook/guardrails OIDC)
- `N8N_OBSERVABILITY_*` (opcional; health/metrics)
- `N8N_STEPCA_TRUST_*` (opcional)

<a id="ports"></a>
## Puertos, redes, volumenes

- Puertos: puerto de contenedor `5678` (sin publicar en host)
- Redes: `proxy`, `n8n-internal`
- Volumenes: `n8n-data`, `n8n-db-data`

<a id="security"></a>
## Seguridad

- n8n solo se expone mediante Traefik.
- PostgreSQL usa red interna.
- Keycloak/OIDC y observabilidad estan desactivados por defecto.
- Si Keycloak usa certificados de step-ca, activa `N8N_STEPCA_TRUST_*` y ejecuta `make n8n-bootstrap`.

<a id="troubleshooting"></a>
## Solucion de problemas

- Si preflight indica que falta config renderizada, ejecuta `make n8n-bootstrap`.
- Revisa `make n8n-logs` para `n8n` y `n8n-db`.
- Verifica que `n8n.${DEV_DOMAIN}` resuelve a esta maquina.
- Valida health con `curl -sk https://n8n.${DEV_DOMAIN}/healthz`.

<a id="related"></a>
## Paginas relacionadas

- [README raiz](../../README.es.md)
- [Traefik](../traefik/README.es.md)
- [Step-CA](../step-ca/README.es.md)
