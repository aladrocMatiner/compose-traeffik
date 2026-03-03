# Change: Add Debian 13 QEMU/Libvirt Image Profile (Deep Plan)

## Why

Queremos ampliar el target local `qemu` (backend `libvirt`) con soporte para `Debian 13` usando el mismo stack base (`Terraform + cloud-init`) y el mismo contrato operativo de provisionamiento. Aunque Debian es mucho mas sencillo que Gentoo, conviene planificar a conciencia esta incorporacion para evitar drift de imagenes cloud, diferencias silenciosas de `cloud-init`/networking y falsas expectativas de paridad inmediata con `deployment-ready` (Docker/Compose).

Ademas, `Debian 13` es un buen candidato para consolidar un patron reutilizable de incorporacion de nuevos OS Debian-like (pinning, checksums, smoke tests, validacion de red fija y evidencia de compatibilidad) que luego se pueda reutilizar para otros perfiles.

## What Changes

- Definir soporte de perfil de imagen `debian13` para `target=qemu` (`libvirt`) dentro del flujo de `vm-provisioning`.
- Definir una planificacion exhaustiva por fases para seleccionar, pinnear y validar una cloud image oficial de Debian 13 con `cloud-init`.
- Formalizar una matriz minima de validacion (`hostname`, IP fija, SSH, reboot persistence) para considerar el perfil `qemu-provisionable`.
- Documentar riesgos y decisiones de compatibilidad (renderer de red, nombre de interfaz, SSH package/service, `cloud-init` behavior).
- Dejar explicito que la paridad de `host-bootstrap` (`deployment-bootstrap`, Docker/Compose plugin) es un follow-up y no parte del alcance de esta propuesta.

## Capabilities

### New Capabilities

- None.

### Modified Capabilities

- `vm-provisioning`: extender el target `qemu`/`libvirt` con un perfil de imagen `debian13` (Debian 13) basado en cloud image oficial y compatible con `cloud-init`.

## Impact

- Affected code (planned): `deployment/scripts/infra-provision.sh`, `infra/terraform/targets/libvirt/`, `infra/cloud-init/` (si se requiere branching minimo), `Makefile`, y documentacion operativa.
- Dependency note: depende del contrato base de `add-vm-bootstrap-targets` y del flujo `qemu/libvirt` ya funcional para Ubuntu/Gentoo.
- Scope note: esta propuesta se centra en provisionamiento y validacion de VM `qemu/libvirt`; Docker/bootstrap/Compose para Debian 13 queda para un follow-up.
- Ops note: se definira pinning de imagen (URL versionada + checksum policy) para reducir cambios no deterministas en laboratorios locales.

## Proposed Delivery Stages (Planning Scope)

1. `Stage A - Image Selection & Provenance`: elegir cloud image oficial Debian 13, checksum y politica de pinning.
2. `Stage B - cloud-init Baseline`: validar hostname + SSH key injection con NoCloud en `libvirt`.
3. `Stage C - Static Networking`: validar IP fija + gateway + DNS + persistencia tras reboot en red `libvirt`.
4. `Stage D - QEMU Profile Integration Prep`: definir cambios minimos en wrapper/Makefile/templates para integrar `debian13`.
5. `Stage E - Docker Bootstrap Follow-up Boundary`: documentar lo necesario para paridad futura sin implementarla aqui.

## Success Criteria for This Proposal (Planning Acceptance)

- Existe un plan por fases con criterios de entrada/salida y evidencia minima por fase.
- La delta spec de `vm-provisioning` deja claro el contrato de `debian13` para `qemu/libvirt`.
- El plan define politica de pinning/checksum y negative tests minimos (metadata invalida / imagen incompatible).
- Queda explicito que `deployment-ready` (Docker) no se considera completado por esta proposal.

## Risks if We Skip This Planning

- Uso de imagen `latest` sin pinning y roturas no reproducibles en labs.
- Provision aparentemente correcto pero con IP fija/SSH no persistentes tras reboot.
- Branching ad-hoc en `cloud-init`/scripts sin evidencia de necesidad real.
- Mezclar soporte de imagen con Docker bootstrap y aumentar retrabajo.
