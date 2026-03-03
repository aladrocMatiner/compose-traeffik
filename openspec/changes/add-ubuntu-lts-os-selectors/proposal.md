## Why

Hoy el flujo de provision expone un unico selector `ubuntu` (actualmente alineado a 24.04/Noble) y no permite elegir de forma explicita entre LTS anteriores. Esto limita pruebas de compatibilidad y migracion para hosts que todavia necesitan 20.04 o 22.04.

Necesitamos ampliar el contrato de seleccion de OS para incluir `ubuntu20.04`, `ubuntu22.04` y `ubuntu24.04`, manteniendo compatibilidad con el selector historico `ubuntu`.

## What Changes

- Extender el contrato de seleccion de OS en provisioning para aceptar:
  - `ubuntu20.04`
  - `ubuntu22.04`
  - `ubuntu24.04`
- Mantener `ubuntu` como alias retrocompatible (resuelto de forma determinista a `ubuntu24.04`).
- Definir metadatos de imagen cloud pinneados por version (URL/path/checksum policy) para cada perfil Ubuntu LTS.
- Alinear validaciones y ayuda de CLI/Make (`infra-provision`, `host-wait-ssh`, `host-bootstrap`, `host-bootstrap-check`, `deployment-list-os`) con los nuevos selectores.
- Mantener fail-fast claro cuando se use un selector no soportado para el target o fase actual.

## Capabilities

### New Capabilities

- None.

### Modified Capabilities

- `vm-provisioning`: soportar perfiles Ubuntu LTS versionados para `qemu/libvirt` con pinning explicito.
- `deployment-cli`: exponer selectores Ubuntu versionados en discovery (`deployment-list-os`) con salida estable.

## Impact

- Affected code (planned):
  - `deployment/scripts/infra-provision.sh`
  - `deployment/scripts/host-wait-ssh.sh`
  - `deployment/scripts/host-bootstrap.sh`
  - `deployment/scripts/host-bootstrap-check.sh`
  - `Makefile`
  - docs + smoke tests de deployment list/selector contract
- Operacion:
  - el operador podra elegir explicitamente Ubuntu 20.04/22.04/24.04 en `make deployment ... os=<selector>`.
- Compatibilidad:
  - `os=ubuntu` seguira funcionando (alias a `ubuntu24.04`) para no romper automatizaciones existentes.
- Scope note:
  - en esta propuesta el foco es `qemu/libvirt`; cualquier ampliacion especifica de `proxmox` por version de plantilla queda como follow-up si requiere contrato adicional.
