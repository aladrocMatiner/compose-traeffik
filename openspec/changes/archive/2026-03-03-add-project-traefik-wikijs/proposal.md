## Why

Necesitamos un proyecto `traefik-wikijs` dentro del catálogo de deployment que reutilice capacidades ya definidas para certificados y autenticación. Este proyecto debe depender explícitamente de StepCA (TLS por defecto) y Keycloak (auth) para mantener un contrato operativo claro.

## What Changes

- Añadir proyecto `traefik-wikijs` en `deployment/projects/traefik-wikijs/`.
- Exponer Wiki.js detrás de Traefik como reverse proxy del proyecto.
- Definir manifiesto explícito del proyecto con:
  - `depends_on_projects` incluyendo `traefik-stepca` y `traefik-keycloak`
  - fuente de repo y `repo_ref` pinneada
  - perfil/servicios de compose y variables requeridas
- Definir playbook de despliegue del proyecto para sync de repo y `docker compose up -d`.
- Aplicar política TLS por defecto basada en StepCA ACME, con override explícito permitido, siempre con terminación TLS en Traefik según modo TLS OpenSpec.
- Aplicar contrato de autenticación basado en Keycloak para acceso a Wiki.js.

## Capabilities

### New Capabilities

- None.

### Modified Capabilities

- `deployment-project-catalog`: añade proyecto concreto `traefik-wikijs` con dependencias de seguridad declaradas.

## Impact

- Affected code (planned): `deployment/projects/traefik-wikijs/*`, playbooks/vars de proyecto en `deployment/ansible`, wiring de catálogo, docs/tests.
- Operación: despliegue reproducible de Wiki.js con TLS y auth integrados por defecto.
- Riesgo: prerequisitos no satisfechos (StepCA/Keycloak); se mitiga con guardrails de dependencias y validación previa de variables requeridas.
