## Why

Necesitamos un proyecto `traefik-harbor` en el catálogo de deployment para desplegar Harbor detrás de Traefik con el baseline de seguridad del repositorio: certificados por StepCA y autenticación integrada con Keycloak. Además, queremos definir desde el contrato la integración con observabilidad para que Harbor encaje en el stack operativo sin depender de pasos manuales.

## What Changes

- Añadir proyecto `traefik-harbor` en `deployment/projects/traefik-harbor/`.
- Exponer Harbor detrás de Traefik como reverse proxy del proyecto (`ui`, `api` y rutas de registry según contrato del manifiesto).
- Definir manifiesto explícito con:
  - `depends_on_projects` incluyendo `traefik-stepca` y `traefik-keycloak`
  - fuente de repo y `repo_ref` pinneada
  - perfil/servicios de compose y variables requeridas
- Definir playbook del proyecto para sync de repo y despliegue `docker compose up -d`.
- Aplicar política TLS por defecto basada en StepCA ACME, con override explícito soportado, siempre con terminación TLS en Traefik según modo TLS OpenSpec.
- Aplicar contrato de autenticación de Harbor con Keycloak según variables del manifiesto.
- Definir contrato de observabilidad para Harbor compatible con `traefik-observability` (métricas/logs/labels), sin convertir `traefik-observability` en dependencia obligatoria del despliegue base.

## Capabilities

### New Capabilities

- None.

### Modified Capabilities

- `deployment-project-catalog`: añade proyecto concreto `traefik-harbor` con contrato de proxy/TLS/auth y observabilidad.

## Impact

- Affected code (planned): `deployment/projects/traefik-harbor/*`, playbooks/vars de proyecto en `deployment/ansible`, wiring de catálogo, docs/tests.
- Operación: despliegue reproducible de Harbor detrás de Traefik con TLS y SSO por defecto, y contrato de observabilidad listo para integración.
- Riesgo: prerequisitos no satisfechos (StepCA/Keycloak/observabilidad habilitada); se mitiga con guardrails de dependencias y validación previa de variables.
