## Why

Necesitamos incorporar `traefik-freeipa` al flujo `deployment-project` con el baseline operativo que estamos usando en proyectos complejos: TLS por defecto con StepCA ACME, contrato de autenticación con Keycloak y dependencia de observabilidad para telemetría/operación.

Esto evita que FreeIPA se integre de forma ad-hoc y fija desde el principio el contrato de dependencias, TLS y despliegue reproducible.

## What Changes

- Añadir proyecto `traefik-freeipa` en `deployment/projects/traefik-freeipa/`.
- Definir manifiesto explícito del proyecto con:
  - `depends_on_projects`: `traefik-stepca`, `traefik-keycloak`, `traefik-observability`
  - `tls_mode` por defecto `stepca-acme` con override explícito soportado
  - contrato OIDC/Keycloak en bloque `oidc`
  - `repo_url`, `repo_ref`, `compose_profile`, `services`, `required_env`, `public_host`
- Registrar `traefik-freeipa` en `deployment/projects/catalog.json` y en `deployment-project-list`.
- Extender el flujo de deployment para aplicar el contrato de FreeIPA detrás de Traefik con terminación TLS en Traefik según `tls_mode`.
- Añadir guardrails y tests para dependencias, TLS, contrato auth/OIDC y selección cerrada de servicios del manifiesto.

## Capabilities

### New Capabilities

- None.

### Modified Capabilities

- `deployment-project-catalog`: añade proyecto `traefik-freeipa` con dependencias StepCA/Keycloak/Observability y contrato TLS/auth explícito.

## Impact

- Affected code (planned):
  - `deployment/projects/traefik-freeipa/*`
  - `deployment/projects/catalog.json`
  - `deployment/scripts/deployment-project.sh`
  - `deployment/ansible/roles/project_deploy/*`
  - `deployment/tests/smoke/*`
  - documentación de deployment
- Operación: despliegue reproducible de FreeIPA detrás de Traefik con contratos explícitos de seguridad y observabilidad.
- Riesgo: prerequisitos no satisfechos (`traefik-stepca`, `traefik-keycloak`, `traefik-observability`); mitigado con preflight de dependencias y fail-fast antes de compose apply.
