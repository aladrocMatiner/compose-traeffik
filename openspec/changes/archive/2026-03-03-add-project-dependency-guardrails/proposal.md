## Why

Los proyectos del catálogo empiezan a depender entre sí (por ejemplo, certificados vía StepCA y autenticación vía Keycloak). Sin un contrato explícito de dependencias, los despliegues pueden fallar tarde o de forma no determinista.

## What Changes

- Extender el contrato de manifiesto de proyectos para soportar `depends_on_projects`.
- Definir preflight obligatorio de dependencias antes de ejecutar bootstrap/despliegue del proyecto.
- Fallar temprano con mensajes accionables cuando falte una dependencia.
- Añadir checks/documentación de dependencias en el flujo `deployment-project`.
- Asegurar que dependencias de seguridad (por ejemplo `traefik-stepca` para certificados y `traefik-keycloak` para auth) se validan antes del despliegue de aplicaciones detrás de Traefik.

## Capabilities

### New Capabilities

- None.

### Modified Capabilities

- `deployment-project-system`: añade contrato de dependencias entre proyectos y guardrails de preflight.

## Impact

- Affected code (planned): validación de manifiestos en `deployment/projects/*`, wiring de `deployment-project` en scripts/Make, tests y docs.
- Operación: menor riesgo de fallos tardíos al declarar dependencias explícitas.
- Riesgo: complejidad adicional en resolución de dependencias; se mitiga empezando con validación lineal simple (sin DAG complejo) y mensajes claros.
