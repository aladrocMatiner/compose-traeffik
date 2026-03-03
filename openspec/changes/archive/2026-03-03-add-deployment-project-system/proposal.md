## Why

El flujo actual de `make deployment-*` provisiona y prepara la VM, pero no define una capa estandar para desplegar "proyectos" reutilizables sobre esa base. Queremos un contrato unico donde `project=<id>` seleccione un despliegue predefinido y reproducible sin pasos manuales.

## What Changes

- Añadir un entrypoint de alto nivel `make deployment-project project=<id> [target=<...>] [os=<...>]`.
- Añadir `make deployment-project-list` para descubrir proyectos soportados sin inspeccionar internals.
- Definir defaults del flujo de proyectos **solo para `deployment-project`**: `target=qemu` y `os=ubuntu` (salvo override explicito).
- Definir un sistema de proyectos en `deployment/projects/<project-id>/` con manifiesto validable y playbook de despliegue.
- Establecer como contrato de proyecto de aplicaciones web que el tráfico HTTP(S) se publica detrás de Traefik y que la terminación TLS la gestiona Traefik usando el modo TLS declarado en OpenSpec.
- Definir resolución determinista de hostname público para proyectos web: por defecto `<project-id>.<BASE_DOMAIN>` con posibilidad de override explícito en manifiesto.
- Estandarizar el pipeline de ejecucion por proyecto:
  1) provision VM  
  2) wait SSH/cloud-init  
  3) bootstrap base (`system_bootstrap`)  
  4) despliegue del proyecto (incluyendo clone de `compose-traeffik` y `docker compose` de servicios predefinidos)
- Añadir validaciones para `project` ausente/no soportado y documentación/tests de wiring.
- Definir politica de fallo: por defecto no destruir automaticamente la VM cuando falla una etapa posterior al provisionamiento; mostrar pasos de recuperación explícitos.
- Definir contrato de idempotencia para re-ejecuciones del mismo proyecto.

## Capabilities

### New Capabilities

- `deployment-project-system`: contrato de seleccion y ejecucion de proyectos sobre el flujo de deployment.

### Modified Capabilities

- None.

## Impact

- Affected code (planned): `Makefile`, `deployment/scripts/*`, `deployment/projects/*`, `deployment/ansible/playbooks/*`, documentación y smoke tests.
- Operación: un único comando orientado a intención (`project=<id>`) para provisionar y desplegar stack.
- Riesgo: acoplar demasiado la lógica por proyecto en Make; se mitiga con contrato de manifiesto/playbook por proyecto y validaciones de entrada.
