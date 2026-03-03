## Why

Queremos formalizar un proyecto `traefik-webui` para desplegar la interfaz web (WebUI) detrás de Traefik dentro del flujo de deployment por proyectos, con política TLS alineada al contrato OpenSpec.

## What Changes

- Añadir proyecto `traefik-webui` en `deployment/projects/traefik-webui/`.
- Definir manifiesto explícito del proyecto con `repo_url`, `repo_ref`, `compose_profile`, `services`, `required_env`, `depends_on_projects` y `tls_mode`.
- Declarar dependencia de `traefik-stepca` para el modo TLS por defecto.
- Definir playbook de proyecto para sync de repo y despliegue `docker compose up -d`.
- Exponer WebUI detrás de Traefik.
- Aplicar política TLS por defecto `stepca-acme`, con override explícito soportado y terminación TLS gestionada por Traefik según modo TLS OpenSpec.

## Capabilities

### New Capabilities

- None.

### Modified Capabilities

- `deployment-project-catalog`: añade proyecto concreto `traefik-webui` con contrato de proxy/TLS explícito.

## Impact

- Affected code (planned): `deployment/projects/traefik-webui/*`, playbooks/vars de proyecto en `deployment/ansible`, wiring de catálogo, docs/tests.
- Operación: despliegue reproducible de WebUI detrás de Traefik con certificados OpenSpec por defecto.
- Riesgo: variables de bootstrap web/OIDC incompletas; se mitiga con validación previa de `required_env` y guardrails de manifiesto.
