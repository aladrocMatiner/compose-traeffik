## Why

Necesitamos un proyecto `traefik-n8n` en el catálogo para desplegar n8n detrás de Traefik con una política TLS consistente con OpenSpec y una base clara para integración de autenticación.

## What Changes

- Añadir proyecto `traefik-n8n` en `deployment/projects/traefik-n8n/`.
- Definir manifiesto explícito del proyecto con:
  - `depends_on_projects` incluyendo `traefik-stepca` para certificados por defecto
  - fuente de repo y `repo_ref` pinneada
  - perfil/servicios de compose y variables requeridas
- Definir playbook de proyecto para sync de repo y despliegue `docker compose up -d`.
- Exponer n8n detrás de Traefik como reverse proxy del proyecto.
- Aplicar política TLS por defecto basada en StepCA ACME, con override explícito soportado y terminación TLS gestionada por Traefik según modo TLS OpenSpec.
- Mantener integración de Keycloak como contrato opcional del proyecto cuando se habilite OIDC.

## Capabilities

### New Capabilities

- None.

### Modified Capabilities

- `deployment-project-catalog`: añade proyecto concreto `traefik-n8n` con contrato de proxy/TLS y opción de auth federada.

## Impact

- Affected code (planned): `deployment/projects/traefik-n8n/*`, playbooks/vars de proyecto en `deployment/ansible`, wiring de catálogo, docs/tests.
- Operación: despliegue reproducible de n8n detrás de Traefik con certificados OpenSpec por defecto.
- Riesgo: variables de integración incompletas (TLS/OIDC); se mitiga con validación previa de `required_env` y guardrails por modo.
