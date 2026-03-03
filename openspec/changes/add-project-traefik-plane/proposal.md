## Why

Queremos incorporar `traefik-plane` al flujo `deployment-project` con el mismo contrato operativo que ya usamos en stacks complejos: edge Traefik, TLS por defecto con StepCA ACME, bootstrap OIDC en Keycloak e integración explícita con observabilidad.

Hoy el catálogo no contempla Plane como proyecto desplegable, lo que obliga a despliegues ad-hoc y deja sin contrato formal aspectos críticos (dependencias, TLS mode, variables obligatorias, y reconciliación de cliente OIDC).

## What Changes

- Añadir proyecto `traefik-plane` en `deployment/projects/traefik-plane/` con manifiesto completo (`id`, `repo_url`, `repo_ref`, `compose_profile`, `services`, `required_env`, `tls_mode`, `depends_on_projects`, `oidc`, `public_host`).
- Registrar `traefik-plane` en `deployment/projects/catalog.json` y en la salida de `deployment-project-list`.
- Definir dependencia explícita del proyecto respecto a:
  - `traefik-stepca` (certificados ACME por defecto),
  - `traefik-keycloak` (bootstrap y reconciliación OIDC),
  - `traefik-observability` (stack de telemetría ya operativo y contrato de integración).
- Definir política TLS por defecto `stepca-acme` con override explícito soportado y validación de prerequisitos por modo.
- Extender `deployment/ansible/roles/project_deploy` para:
  - sincronizar/validar la presencia del módulo `services/plane`,
  - aplicar defaults y secretos runtime de Plane de forma idempotente,
  - provisionar/actualizar cliente OIDC de Plane en Keycloak y sincronizar secreto efectivo al `.env`,
  - activar contrato de observabilidad para Plane sin bypass del edge Traefik.
- Añadir cobertura en smoke tests (`deployment/tests/smoke`) y documentación de ejecución/orden recomendado.

## Capabilities

### New Capabilities

- None.

### Modified Capabilities

- `deployment-project-catalog`: añade contrato de proyecto `traefik-plane` con dependencias StepCA/Keycloak/Observability, TLS por defecto y guardrails de OIDC/telemetría.

## Impact

- Affected code (planned):
  - `deployment/projects/catalog.json`
  - `deployment/projects/traefik-plane/manifest.json`
  - `deployment/scripts/deployment-project.sh`
  - `deployment/ansible/roles/project_deploy/defaults/main.yml`
  - `deployment/ansible/roles/project_deploy/tasks/main.yml`
  - `deployment/tests/smoke/test_deployment_project_catalog.sh`
  - `deployment/tests/smoke/test_deployment_keycloak_oidc_idempotency_contract.sh`
  - `deployment/README.md`
- Operación:
  - `make deployment-project project=traefik-plane ...` pasa a ser flujo soportado y repetible.
- Riesgos principales:
  - Divergencia entre rama de control y `repo_ref` de Plane (módulo ausente o incompatible).
  - Configuración incompleta de secretos OIDC/Plane.
  - Integración de telemetría parcial.
- Mitigación:
  - preflight estricto de manifiesto/dependencias/módulo Plane,
  - bootstrap idempotente de secretos,
  - validación temprana de contrato OIDC antes de `docker compose up -d`.
