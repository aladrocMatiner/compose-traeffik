## Why

Tras definir el sistema general de proyectos, necesitamos un primer proyecto real para validar el flujo end-to-end. El caso inicial será desplegar Traefik junto con Smallstep (`step-ca`) en la VM provisionada por deployment.

## What Changes

- Añadir el proyecto `traefik-stepca` en `deployment/projects/traefik-stepca/`.
- Definir manifiesto del proyecto con contrato explícito: id, descripción, repositorio, ref pinneada, perfil de compose, servicios, modo TLS OpenSpec y variables requeridas.
- Añadir playbook de proyecto que:
  1) clona el repositorio `compose-traeffik` en la VM  
  2) prepara el entorno requerido para ejecución de compose  
  3) levanta el stack del proyecto (`traefik` + `step-ca`) con el perfil `stepca`
- Asegurar que la terminación TLS para rutas expuestas se gestiona en Traefik según el modo TLS OpenSpec del proyecto (default `stepca-acme`).
- Integrar el proyecto en el catálogo soportado por `deployment-project`.
- Añadir guardrails para validar variables requeridas del proyecto antes de ejecutar `docker compose`.

## Capabilities

### New Capabilities

- `deployment-project-catalog`: catálogo de proyectos concretos desplegables sobre el sistema de proyectos.

### Modified Capabilities

- `deployment-project-system`: registra un proyecto concreto dentro del catálogo definido por el sistema.

## Impact

- Affected code (planned): `deployment/projects/traefik-stepca/*`, playbooks de proyecto en `deployment/ansible`, wiring de catálogo y documentación.
- Operación: primer blueprint reutilizable para exponer Traefik y ACME interno de Smallstep en hosts de pruebas.
- Riesgo: drift de servicios/profiles o ref de repositorio; se mitiga fijando en manifiesto `services=[traefik, step-ca]`, `profile=stepca` y `repo_ref` pinneada.
