## Why

El despliegue AWX sobre `k3d` cubre la puesta en marcha, pero AWX es un servicio con estado y operación continua. Para evitar que el módulo quede "solo arranca" sin guías de mantenimiento seguras, necesitamos un cambio separado de day-2 operations (backup/restore/upgrade/debug) con runbooks y comandos reproducibles.

## What Changes

- Definir runbooks y scripts/targets para operaciones day-2 de AWX en entorno local/lab (`backup`, `restore`, `upgrade`, `debug`).
- Extender/documentar recuperación segura de credenciales/admin (partiendo del comando base definido en el módulo AWX) y export de información de soporte.
- Documentar estrategia de compatibilidad de versiones (operator/AWX/k3d/K3s) y orden de upgrades.
- Definir validaciones/documentación de pruebas de restauración mínimas.

## Capabilities

### New Capabilities
- `awx-day2-operations`: runbooks y operaciones de mantenimiento para el módulo AWX.

### Modified Capabilities
- `documentation`: añadir runbooks operativos para AWX.
- `scripts-docs`: documentar scripts/targets de day-2 operations.
- `tests-docs`: documentar validaciones manuales de backup/restore/upgrade.

## Impact

- Affected code (planned): `Makefile`, `scripts/awx-*`, `services/awx/README*.md`, `docs/*`, `tests/README.md`.
- No implementación en este cambio; define alcance y contrato para el trabajo de day-2 posterior al MVP.
