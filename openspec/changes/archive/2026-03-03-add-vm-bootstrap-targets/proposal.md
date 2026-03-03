## Why

Necesitamos una base reproducible para preparar VMs donde luego desplegaremos stacks `docker compose` en distintos entornos. Hoy el repositorio no define un flujo estándar para provisionar hosts Ubuntu con IP fija, acceso SSH y Docker listo, ni un contrato común entre `libvirt` local (QEMU) y `Proxmox` remoto.

## What Changes

- Definir una nueva capacidad `vm-provisioning` para provisionamiento de VMs con `Terraform` y bootstrap inicial con `cloud-init`.
- Definir una nueva capacidad `host-bootstrap` para scripts post-provision que instalan Docker Engine + Compose plugin sobre hosts Ubuntu ya accesibles por SSH.
- Formalizar soporte de dos targets iniciales: `libvirt` local y `proxmox` remoto, con contrato de entradas/salidas común.
- Fijar como alcance actual la preparación del host (red/SSH/Docker), dejando el deployment específico del stack y la capa `Ansible` para un cambio posterior.

## Capabilities

### New Capabilities

- `vm-provisioning`: contrato de provisionamiento multi-target (`libvirt`, `proxmox`) usando Terraform + cloud-init con Ubuntu cloud images e IPs fijas.
- `host-bootstrap`: contrato de scripts para instalación/verificación de Docker en hosts Ubuntu provisionados.

### Modified Capabilities

- None.

## Impact

- Affected code (planned): nueva estructura `infra/terraform/`, plantillas `infra/cloud-init/` y scripts operativos `scripts/infra-*.sh` / `scripts/host-*.sh`.
- Affected secrets handling (planned): variables de entorno y archivos ignorados para credenciales de `Proxmox` y llaves SSH.
- Affected future integration (planned): outputs de Terraform preparados para consumo posterior por `Ansible`.
- Este cambio define contrato y plan de implementación; no aplica aún el deployment del stack `docker compose`.
