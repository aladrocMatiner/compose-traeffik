## Why

Actualmente los roles base (`system_update` y `docker_git`) se ejecutan con playbooks separados. Para bootstrap operativo inicial conviene un único playbook de entrada que aplique ambos pasos en el orden correcto y evite ejecuciones parciales.

## What Changes

- Añadir un playbook `deployment/ansible/playbooks/system_bootstrap.yml`.
- El playbook ejecutará primero `system_update` y después `docker_git`.
- Definir explícitamente el orden de ejecución como contrato de bootstrap.
- Actualizar documentación y checks de sintaxis/lint para incluir el nuevo playbook.

## Capabilities

### New Capabilities

- None.

### Modified Capabilities

- `deployment-ansible`: nuevo flujo compuesto de bootstrap usando roles existentes.

## Impact

- Affected code (planned): `deployment/ansible/playbooks/system_bootstrap.yml`, `deployment/ansible/README.md`, Make targets/checks de ansible.
- Operación: un único entrypoint para bootstrap base multi-OS.
- Riesgo: cambios de orden entre roles podrían introducir regressions; se mitiga fijando el orden en spec y tests de sintaxis/lint.

