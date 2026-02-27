## Why

Actualmente no existe un contrato definido en OpenSpec para roles base de Ansible en `deployment/ansible` que cubran operación multi-OS. Esto deja sin estándar común dos necesidades básicas de bootstrap: actualizar el sistema e instalar herramientas base (`docker` y `git`) en los OS soportados.

## What Changes

- Definir una nueva capacidad `deployment-ansible` para roles operativos base en `deployment/ansible`.
- Añadir un rol simple de actualización de sistema para los selectores OS soportados actualmente: `ubuntu`, `debian12`, `debian13`, `debian`, `gentoo`, `opensuse-leap`, `almalinux9`, `rockylinux9`, `fedora-cloud`.
- Añadir un segundo rol simple para instalar `docker` y `git` en los mismos OS soportados.
- Estandarizar comportamiento esperado de idempotencia, selección de gestor de paquetes por familia y errores claros en plataformas no soportadas.

## Capabilities

### New Capabilities

- `deployment-ansible`: roles base multi-OS para actualización de sistema e instalación de herramientas operativas.

### Modified Capabilities

- None.

## Impact

- Affected code (planned): `deployment/ansible/roles/*`, playbooks de bootstrap/deployment que consuman estos roles, y documentación operativa relacionada.
- Operación: menos drift entre sistemas al disponer de roles comunes y repetibles para mantenimiento base.
- Riesgo: diferencias entre gestores de paquetes y nombres de paquetes por distribución; se mitiga con mapeo explícito por familia OS y validación temprana.
