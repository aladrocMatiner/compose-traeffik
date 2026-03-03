## Context

El repositorio contiene el stack `docker compose` y utilidades operativas, pero no una capa de infraestructura para crear y preparar las VMs de destino. El objetivo inmediato es habilitar hosts Ubuntu reproducibles en dos entornos (`libvirt` local y `Proxmox` remoto) con red estática, SSH funcional y Docker instalado, sin introducir todavía la automatización de configuración/deployment con Ansible.

## Goals / Non-Goals

- Goals:
- Definir un contrato común de provisionamiento multi-target con `Terraform`.
- Usar `cloud-init` para bootstrap mínimo de Ubuntu (hostname, red, SSH, paquetes base).
- Definir scripts de bootstrap post-provision para instalar Docker Engine y Compose plugin.
- Asegurar salidas machine-readable (`terraform output -json`) para facilitar la futura integración con Ansible.
- Non-Goals:
- No desplegar aún stacks de `docker compose` en los hosts provisionados.
- No introducir playbooks/roles de Ansible en esta fase.
- No cubrir más targets que `libvirt` y `proxmox` en este cambio.

## Decisions

- Decision: Separar la responsabilidad en dos capas operativas: `Terraform + cloud-init` para crear/preparar la VM, y scripts shell para bootstrap de Docker sobre SSH.
- Rationale: Mantiene `cloud-init` pequeño y facilita iterar la instalación de Docker sin reprovisionar toda la VM.

- Decision: Diseñar un contrato común de variables para ambos targets (identidad, red, acceso, imagen) y aislar variables específicas del provider.
- Rationale: Reduce divergencia entre `libvirt` y `proxmox` y prepara una interfaz estable para automatización posterior.

- Decision: Exigir IP fija y configuración de red aplicada vía `cloud-init` como parte del contrato de provisionamiento.
- Rationale: Simplifica acceso SSH reproducible y evita depender de discovery DHCP para operaciones posteriores.

- Decision: Usar Ubuntu cloud images (baseline esperado: Ubuntu 24.04 LTS) como base de los dos targets.
- Rationale: Alinea tooling de `cloud-init`, minimiza diferencias operativas y reduce el trabajo de bootstrap inicial.

- Decision: Entregar metadata de hosts provisionados mediante outputs de Terraform aptos para consumo por scripts y futura integración con Ansible.
- Rationale: Permite encadenar fases sin acoplar Terraform con `remote-exec` ni introducir Ansible antes de tiempo.

## Target Architecture (proposed)

- `libvirt` local:
- Terraform provider de `libvirt` para crear volumen/VM y adjuntar datos de `cloud-init`.
- Red local (NAT o bridge) gestionada por libvirt con direccionamiento estático dentro de la subred elegida.

- `proxmox` remoto:
- Terraform provider de Proxmox para clonar/crear VM con cloud-init habilitado.
- Credenciales y endpoint inyectados por variables de entorno o archivos ignorados.

- Shared pieces:
- Plantillas `cloud-init` comunes (user-data y, si conviene, network-config).
- Contrato de outputs homogéneo para hostname/IP/SSH user/target.

## Risks / Trade-offs

- Riesgo: Configuración de IP fija puede variar entre entornos (`libvirt` NAT/bridge vs bridge/VLAN en Proxmox).
- Mitigación: Definir un contrato común mínimo y permitir campos target-specific sin romper el modelo base.

- Riesgo: Meter demasiada lógica en `cloud-init` complica depuración y futura migración a Ansible.
- Mitigación: Limitar `cloud-init` a red, SSH y paquetes mínimos; mover Docker a scripts.

- Riesgo: Diferencias entre providers de Proxmox (features/semántica) retrasen implementación.
- Mitigación: Mantener la spec a nivel de contrato y fijar provider exacto/pinning en la fase de implementación.

- Riesgo: Scripts de bootstrap no idempotentes generen estado inconsistente.
- Mitigación: Exigir checks explícitos y comportamiento seguro al re-ejecutar cuando sea posible.

## Migration Plan

1. Crear deltas OpenSpec para `vm-provisioning` y `host-bootstrap`.
2. Implementar estructura base `infra/terraform` y plantillas `cloud-init` comunes.
3. Implementar target `libvirt` y validar provisioning + SSH.
4. Implementar target `proxmox` con el mismo contrato de inputs/outputs.
5. Implementar scripts de bootstrap Docker y checks de readiness.
6. Validar salidas para handoff futuro a Ansible.

## Open Questions

- Qué provider de Proxmox se fijará en implementación (`Telmate/proxmox`, `bpg/proxmox`, u otro) según compatibilidad con la versión de Proxmox disponible.
- Si el script de bootstrap debe aceptar hosts manualmente (`--host`, `--user`) además de consumir `terraform output`.
