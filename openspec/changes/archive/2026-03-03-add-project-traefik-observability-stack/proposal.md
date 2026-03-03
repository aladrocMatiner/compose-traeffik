## Why

Queremos un proyecto de observabilidad reutilizable dentro del catálogo de deployment. Este proyecto debe usar certificados por defecto vía StepCA (ACME) y autenticación basada en Keycloak para el acceso a sus endpoints.

## What Changes

- Añadir proyecto `traefik-observability` en `deployment/projects/traefik-observability/`.
- Exponer los endpoints web de observabilidad detrás de Traefik como reverse proxy del proyecto.
- Declarar dependencias de proyecto: `traefik-stepca` (TLS default) y `traefik-keycloak` (auth).
- Definir manifiesto explícito con `repo_url`, `repo_ref` pinneada, perfil/servicios y variables requeridas.
- Definir playbook de proyecto para sync de repo y `docker compose up -d` de stack observabilidad.
- Definir política TLS del proyecto:
  - default: `stepca-acme`
  - override explícito permitido para usar otro modo TLS soportado
  - terminación TLS siempre gestionada por Traefik según el modo TLS OpenSpec seleccionado.

## Capabilities

### New Capabilities

- None.

### Modified Capabilities

- `deployment-project-catalog`: añade proyecto `traefik-observability` y su contrato de dependencias/TLS/auth.

## Impact

- Affected code (planned): `deployment/projects/traefik-observability/*`, playbooks/vars de proyecto en `deployment/ansible`, wiring de catálogo, docs/tests.
- Operación: despliegue reproducible de stack observabilidad con seguridad integrada por defecto.
- Riesgo: más prerequisitos (StepCA + Keycloak); se mitiga con guardrails de dependencias y validación previa de variables.
