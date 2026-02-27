## Why

Necesitamos un proyecto `traefik-quay` en el catálogo de deployment con el mismo baseline de seguridad que el resto de proyectos: certificados por StepCA y autenticación integrada con Keycloak.

## What Changes

- Añadir proyecto `traefik-quay` en `deployment/projects/traefik-quay/`.
- Exponer Quay detrás de Traefik como reverse proxy del proyecto (UI y endpoints de registry según contrato del manifiesto).
- Definir manifiesto explícito con:
  - `depends_on_projects` incluyendo `traefik-stepca` y `traefik-keycloak`
  - fuente de repo y `repo_ref` pinneada
  - perfil/servicios de compose y variables requeridas
- Definir playbook del proyecto para sync de repo y despliegue `docker compose up -d`.
- Aplicar política TLS por defecto basada en StepCA ACME, con override explícito soportado, siempre con terminación TLS en Traefik según modo TLS OpenSpec.
- Aplicar contrato de autenticación de Quay contra Keycloak (OIDC/SSO) según variables del manifiesto.

## Capabilities

### New Capabilities

- None.

### Modified Capabilities

- `deployment-project-catalog`: añade proyecto concreto `traefik-quay` con dependencias de seguridad declaradas.

## Impact

- Affected code (planned): `deployment/projects/traefik-quay/*`, playbooks/vars de proyecto en `deployment/ansible`, wiring de catálogo, docs/tests.
- Operación: despliegue reproducible de Quay detrás de Traefik con TLS y autenticación integrados por defecto.
- Riesgo: prerequisitos no satisfechos (StepCA/Keycloak); se mitiga con guardrails de dependencias y validación previa de variables.
