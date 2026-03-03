## Why

Necesitamos que `traefik-awx` exista en el catálogo de deployment ahora para fijar contrato (dependencias, TLS y OIDC) aunque el runtime híbrido AWX (`k3d` + AWX Operator) todavía no esté integrado dentro del flujo `deployment-project`.

## What Changes

- Añadir proyecto `traefik-awx` en `deployment/projects/traefik-awx/`.
- Definir manifiesto explícito del proyecto con:
  - `depends_on_projects` incluyendo `traefik-stepca` y `traefik-keycloak`
  - fuente de repo y `repo_ref` pinneada
  - perfil/servicios y variables requeridas
  - contrato `oidc` para Keycloak
- Registrar `traefik-awx` en el catálogo para `deployment-project-list`.
- Aplicar política TLS por defecto basada en StepCA ACME, con override explícito soportado, siempre con terminación TLS en Traefik según modo TLS OpenSpec.
- Añadir guardrail de fail-fast antes de compose apply para declarar estado "deployment-only" mientras no exista integración runtime AWX en `deployment-project`.

## Capabilities

### New Capabilities

- None.

### Modified Capabilities

- `deployment-project-catalog`: añade proyecto concreto `traefik-awx` con dependencias de seguridad declaradas.

## Impact

- Affected code: `deployment/projects/traefik-awx/*`, `deployment/projects/catalog.json`, `deployment/scripts/deployment-project.sh`, docs/tests de deployment.
- Operación actual: contrato AWX disponible y validable en catálogo, con dependencias y baseline TLS/OIDC declarados.
- Riesgo: interpretación de disponibilidad runtime; se mitiga con guardrail explícito de "deployment-only" y transición documentada.
