## Why

Necesitamos un proyecto `traefik-quay` en el catálogo de deployment para desplegar Quay detrás de Traefik con un contrato reusable. A diferencia de otros proyectos con baseline de seguridad obligatorio, en este caso queremos que StepCA, Keycloak y Observabilidad sean integraciones opcionales activables por configuración.

## What Changes

- Añadir proyecto `traefik-quay` en `deployment/projects/traefik-quay/`.
- Exponer Quay detrás de Traefik como reverse proxy del proyecto (UI y rutas del registry según contrato del manifiesto).
- Definir manifiesto explícito con:
  - fuente de repo y `repo_ref` pinneada
  - perfil/servicios de compose y variables requeridas base
  - flags/contrato para integraciones opcionales de `stepca`, `keycloak` y `observability`
- Definir playbook del proyecto para sync de repo y despliegue `docker compose up -d`.
- Definir política TLS del proyecto:
  - base: modo TLS configurable por manifiesto
  - integración opcional: `stepca-acme` cuando se habilite StepCA
  - terminación TLS siempre gestionada por Traefik según modo TLS OpenSpec seleccionado
- Definir contrato de autenticación opcional de Quay con Keycloak (OIDC/SSO) cuando se habilite.
- Definir contrato de observabilidad opcional para métricas/logs/labels de Quay y Traefik cuando se habilite.

## Capabilities

### New Capabilities

- `deployment-project-catalog`: catálogo de proyectos concretos desplegables sobre el sistema de proyectos.

### Modified Capabilities

- None.

## Impact

- Affected code (planned): `deployment/projects/traefik-quay/*`, playbooks/vars de proyecto en `deployment/ansible`, wiring de catálogo, docs/tests.
- Operación: despliegue reproducible de Quay detrás de Traefik con contrato base estable y extensiones opcionales de seguridad/observabilidad.
- Riesgo: combinaciones de configuración opcional incompletas; se mitiga con validación previa por modo y guardrails con mensajes accionables.
