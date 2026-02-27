## Why

Queremos ampliar el soporte del target local `qemu` (backend `libvirt`) para imagenes de Rocky Linux 9 usando el mismo stack base (`Terraform` + `cloud-init`) sin cambiar la arquitectura general. Esto permite probar deployments y bootstrap de hosts sobre una matriz de sistemas operativos mas amplia antes de entrar en soporte especifico de `Ansible` y stacks `docker compose`.

## What Changes

- Definir soporte de perfil de imagen `target=qemu` para `Rocky Linux 9` dentro del flujo de `vm-provisioning`.
- Formalizar la seleccion del OS/perfil de imagen y sus defaults de cloud image (source/pinning/checksum policy) para `Rocky Linux 9`.
- Definir validaciones minimas de compatibilidad con `cloud-init` (hostname, red fija, SSH) sobre `qemu/libvirt`.
- Documentar el alcance de esta propuesta: provisionamiento de imagen/VM para `qemu`, con notas de follow-up para bootstrap Docker si aplica.

## Capabilities

### New Capabilities

- None.

### Modified Capabilities

- `vm-provisioning`: extender el target `qemu`/`libvirt` para soportar un perfil de imagen `rockylinux9` (Rocky Linux 9).

## Impact

- Affected code (planned): `deployment/scripts/infra-provision.sh`, `infra/terraform/targets/libvirt/`, plantillas `infra/cloud-init/` (si se requieren ajustes por distro) y documentacion operativa.
- Dependency note: este cambio depende del contrato base definido en `add-vm-bootstrap-targets`.
- Scope note: esta propuesta se centra en soporte de imagen/provisionamiento `qemu`; la paridad completa de `host-bootstrap` (Docker) puede requerir un follow-up por distro.
