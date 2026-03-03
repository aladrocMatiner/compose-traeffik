## Why

Queremos un modelo SSO consistente para todos los proyectos desplegados detrás de Traefik. Para eso necesitamos:

- Un realm compartido y estable (`local.test`) en Keycloak.
- Un usuario bootstrap inicial para validar el flujo end-to-end desde el primer despliegue.
- Un mecanismo repetible para que cada proyecto tenga su cliente OIDC sin preconfigurar manualmente todos los clientes futuros.

## What Changes

- Definir bootstrap obligatorio del proyecto `traefik-keycloak` para crear/asegurar el realm `local.test`.
- Definir bootstrap inicial de usuario de acceso (default: `jose.romero` / `abcd123`) durante el despliegue de `traefik-keycloak`, con soporte de override por variables.
- Definir contrato para que cada proyecto gestione su propio cliente OIDC en su etapa Ansible de despliegue (create/update idempotente), asumiendo permisos de ejecución en la máquina del proyecto según decisión operativa actual.
- Definir que los clientes OIDC se crean bajo demanda por proyecto (no pre-seeding global de todos los clientes posibles).
- Estandarizar variables de integración OIDC por proyecto para evitar wiring ad-hoc (`realm`, `auth/token/userinfo`, `client_id`, `client_secret`, `redirect_uris`, `web_origins`).
- Añadir guardrails de dependencias: si un proyecto requiere OIDC y no existe dependencia operativa de Keycloak, el despliegue debe fallar temprano con mensaje accionable.

## Capabilities

### New Capabilities

- None.

### Modified Capabilities

- `deployment-project-system`: añade contrato de bootstrap de realm/usuario Keycloak y de provisión de clientes OIDC por proyecto.

## Impact

- Affected code (planned):
  - `deployment/scripts/deployment-project.sh`
  - `deployment/ansible/roles/project_deploy/tasks/main.yml`
  - manifiestos de proyectos que usen OIDC (`deployment/projects/*/manifest.json`)
  - documentación y smoke tests de catálogo/deployment.
- Operación:
  - Menos pasos manuales para habilitar SSO en nuevos proyectos.
  - Un único realm compartido con usuario inicial conocido para validación rápida.
- Riesgo:
  - Gestión de secretos de cliente OIDC; mitigación inicial con variables de deployment y evolución posterior a vault/sops.
