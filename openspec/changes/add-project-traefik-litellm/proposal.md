## Why

Queremos formalizar LiteLLM como proyecto desplegable dentro del catálogo para poder provisionarlo de forma reproducible detrás de Traefik, con política TLS alineada al contrato OpenSpec.

## What Changes

- Añadir proyecto `traefik-litellm` en `deployment/projects/traefik-litellm/`.
- Definir manifiesto explícito del proyecto con `repo_url`, `repo_ref`, `compose_profile`, `services`, `required_env`, `depends_on_projects` y `tls_mode`.
- Declarar dependencia de `traefik-stepca` para el modo TLS por defecto.
- Definir playbook de proyecto para sync de repo y despliegue `docker compose up -d`.
- Exponer LiteLLM detrás de Traefik.
- Aplicar política TLS por defecto `stepca-acme`, con override explícito soportado y terminación TLS gestionada por Traefik según modo TLS OpenSpec.

## Capabilities

### New Capabilities

- None.

### Modified Capabilities

- `deployment-project-catalog`: añade proyecto concreto `traefik-litellm` con contrato de proxy/TLS explícito.

## Impact

- Affected code (planned): `deployment/projects/traefik-litellm/*`, playbooks/vars de proyecto en `deployment/ansible`, wiring de catálogo, docs/tests.
- Operación: despliegue reproducible de LiteLLM detrás de Traefik con certificados OpenSpec por defecto.
- Riesgo: configuración incompleta de variables LLM/API; se mitiga con validación previa de `required_env` y guardrails de manifiesto.
