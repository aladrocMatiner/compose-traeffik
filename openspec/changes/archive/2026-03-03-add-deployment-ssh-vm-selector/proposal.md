## Why

El flujo actual de `make deployment-ssh` depende del estado Terraform activo (single-host) y no permite seleccionar de forma directa un host concreto usando una UX uniforme de backend + nombre (por ejemplo `target=qemu name=<name>` o `target=proxmox name=<name>`). Tampoco existe un comando para listar los deployments/VMs (y artefactos asociados) creados por backend. Esto complica operar varios hosts/labs cuando existe más de una VM o cuando el estado Terraform no coincide con la máquina que se quiere inspeccionar.

Además, necesitamos definir un comportamiento de recuperación cuando SSH no está disponible. El usuario propone un fallback por credenciales (`root` / `abc123`), pero eso introduce un riesgo de seguridad que conviene formalizar como modo de depuración explícito y no como default.

## What Changes

- Definir una capacidad de acceso a hosts (`host-access`) para seleccionar hosts por backend + nombre desde `make deployment-ssh`.
- Formalizar soporte para sintaxis tipo `make deployment-ssh target=<qemu|proxmox> name=<host-name>` sin romper el modo actual basado en `terraform output`.
- Formalizar soporte para sintaxis `make deployment-list target=<qemu|proxmox>` para listar deployments/VMs creados por backend.
- Definir la estrategia de resolución de acceso (IP/user) para hosts seleccionados por `target` + `name` (empezando por `qemu`/`libvirt`).
- Definir una estrategia de inventario/listado de recursos gestionados (por ejemplo, filtro por prefijo de nombre) para distinguir "lo creado por este tooling" de otras VMs del hypervisor.
- Definir comportamiento de fallback cuando SSH falla (por ejemplo, sugerir `virsh console`).
- Definir una política para credenciales de fallback inseguras: no habilitarlas por defecto; si se soportan, que sean opt-in explícito y local-only.

## Capabilities

### New Capabilities

- `host-access`: acceso operativo a hosts provisionados, incluyendo listado por backend, selección por `target` + `name`, resolución de IP/usuario y fallback de recuperación.

### Modified Capabilities

- None (este cambio se apoya en `add-vm-bootstrap-targets`, pero define un capability adicional de acceso/operación).

## Impact

- Affected code (planned): `Makefile`, scripts de acceso SSH/wait/check/list (`scripts/host-*.sh`) y resolvers de backend (`libvirt`, luego `proxmox`).
- Affected security behavior (planned): manejo de fallback por consola/credenciales para entornos locales.
- Affected docs (planned): `make help`, `scripts/README.md`.
- Dependency note: este cambio depende funcionalmente del flujo base de `add-vm-bootstrap-targets` (provisionamiento + outputs).
