## Why

Necesitamos un proyecto `traefik-rocketchat` en el catálogo de deployment con el mismo baseline de seguridad que el resto de proyectos: certificados emitidos por StepCA y autenticación federada con Keycloak.

## What Changes

- Añadir proyecto `traefik-rocketchat` en `deployment/projects/traefik-rocketchat/`.
- Exponer Rocket.Chat detrás de Traefik como reverse proxy del proyecto.
- Definir manifiesto explícito del proyecto con:
  - `depends_on_projects` incluyendo `traefik-stepca` y `traefik-keycloak`
  - fuente de repo y `repo_ref` pinneada
  - perfil/servicios de compose y variables requeridas
- Definir playbook de proyecto para sync de repo y despliegue `docker compose up -d`.
- Aplicar política TLS por defecto basada en StepCA ACME, con override explícito soportado, siempre con terminación TLS en Traefik según modo TLS OpenSpec.
- Aplicar contrato de autenticación de Rocket.Chat con Keycloak según variables del manifiesto.

## Capabilities

### New Capabilities

- None.

### Modified Capabilities

- `deployment-project-catalog`: añade proyecto concreto `traefik-rocketchat` con dependencias de seguridad declaradas.

## Impact

- Affected code (planned): `deployment/projects/traefik-rocketchat/*`, playbooks/vars de proyecto en `deployment/ansible`, wiring de catálogo, docs/tests.
- Operación: despliegue reproducible de Rocket.Chat con TLS y autenticación integrados por defecto.
- Riesgo: prerequisitos no satisfechos (StepCA/Keycloak); se mitiga con guardrails de dependencias y validación previa de variables.
