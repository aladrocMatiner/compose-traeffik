## Why

Necesitamos un nuevo proyecto del catálogo para desplegar Keycloak detrás de Traefik con TLS automatizado. La expectativa operativa es usar por defecto certificados obtenidos por ACME contra StepCA en red, manteniendo opción de override cuando se requiera otro emisor o modo TLS.

## What Changes

- Añadir el proyecto `traefik-keycloak` en `deployment/projects/traefik-keycloak/`.
- Definir manifiesto del proyecto con contrato explícito: `repo_url`, `repo_ref` pinneada, perfil/servicios de compose, variables requeridas y `depends_on_projects` con `traefik-stepca` para el modo TLS por defecto.
- Definir política TLS del proyecto:
  - default: resolver ACME de StepCA en red
  - override explícito: otro resolver/modo TLS definido por input de proyecto
- Mantener terminación TLS en Traefik según el modo TLS OpenSpec seleccionado.
- Añadir playbook de proyecto para sync del repo y `docker compose up -d` de los servicios declarados.
- Integrar el proyecto en el catálogo soportado por `deployment-project-list`.

## Capabilities

### New Capabilities

- None.

### Modified Capabilities

- `deployment-project-catalog`: añade proyecto concreto `traefik-keycloak` y su contrato TLS por defecto.

## Impact

- Affected code (planned): `deployment/projects/traefik-keycloak/*`, playbooks/variables de proyecto en `deployment/ansible`, wiring de catálogo y documentación.
- Operación: despliegue reproducible de Keycloak + Traefik con ACME interno por defecto.
- Riesgo: fallo de emisión TLS si StepCA no es accesible; se mitiga con validación previa de endpoint ACME y soporte de override explícito.
