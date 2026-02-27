## Why

Necesitamos un proyecto `traefik-gitlab` en el catálogo de deployment con el mismo baseline de seguridad que el resto de proyectos: certificados por StepCA y autenticación integrada con Keycloak.

## What Changes

- Añadir proyecto `traefik-gitlab` en `deployment/projects/traefik-gitlab/`.
- Exponer GitLab detrás de Traefik como reverse proxy del proyecto.
- Definir manifiesto explícito con:
  - `depends_on_projects` incluyendo `traefik-stepca` y `traefik-keycloak`
  - fuente de repo y `repo_ref` pinneada
  - perfil/servicios de compose y variables requeridas
- Definir playbook del proyecto para sync de repo y despliegue `docker compose up -d`.
- Aplicar política TLS por defecto basada en StepCA ACME, con override explícito soportado, siempre con terminación TLS en Traefik según modo TLS OpenSpec.
- Aplicar contrato de autenticación de GitLab contra Keycloak (OIDC/SSO) según variables del manifiesto.

## Capabilities

### New Capabilities

- None.

### Modified Capabilities

- `deployment-project-catalog`: añade proyecto concreto `traefik-gitlab` con dependencias de seguridad declaradas.

## Impact

- Affected code (planned): `deployment/projects/traefik-gitlab/*`, playbooks/vars de proyecto en `deployment/ansible`, wiring de catálogo, docs/tests.
- Operación: despliegue reproducible de GitLab con TLS y autenticación integrados por defecto.
- Riesgo: prerequisitos no satisfechos (StepCA/Keycloak); se mitiga con guardrails de dependencias y validación previa de variables.
