## Context

El repositorio ya tiene un flujo funcional de provisionamiento local `qemu` (backend `libvirt`) para Ubuntu con `Terraform` + `cloud-init`. Queremos extender ese flujo para `Debian 12` manteniendo la misma interfaz general del target `qemu`, con foco inicial en imagen cloud + arranque + red/SSH listos para configuracion posterior.

## Goals / Non-Goals

- Goals:
- Definir un perfil de imagen `debian12` para `target=qemu`.
- Confirmar compatibilidad de la imagen de `Debian 12` con `cloud-init` para hostname, red fija y SSH.
- Definir politica de pinning/versionado de imagen para reproducibilidad local.
- Documentar restricciones y diferencias conocidas para la distro.
- Non-Goals:
- No introducir soporte `proxmox` en este cambio.
- No garantizar paridad completa de bootstrap Docker/Compose en esta propuesta (puede requerir cambio complementario).
- No cambiar el contrato base de `vm-provisioning`; se amplia con un nuevo perfil de OS.

## Decisions

- Decision: El soporte para `Debian 12` se implementara como un perfil de imagen de `target=qemu` (`libvirt`) reutilizando la misma estructura de Terraform y `cloud-init`.
- Rationale: Minimiza duplicacion y mantiene una interfaz uniforme para futuros OS profiles.

- Decision: El cambio debe fijar una estrategia de pinning de imagen (version o URL estable + checksum policy) para `Debian 12`.
- Rationale: Reduce drift y facilita reproducibilidad de pruebas locales.

- Decision: La validacion minima de exito sera `cloud-init` aplicado + hostname esperado + IP fija + SSH accesible.
- Rationale: Ese es el contrato minimo necesario para handoff a `host-bootstrap`/Ansible.

## Distro-specific Notes

- Fit assessment: apt-compatible and cloud-init friendly, making it the easiest non-Ubuntu addition for qemu/libvirt.
- Expected image source: official Debian cloud image.
- Bootstrap parity note: El soporte de `host-bootstrap` para `Debian 12` se tratara como follow-up si requiere cambios por package manager/servicios.

## Risks / Trade-offs

- Riesgo: Docker bootstrap and package names are very close to Ubuntu, but repo URLs/codenames must be mapped correctly in follow-up host-bootstrap changes.
- Mitigacion: separar "soporte de imagen qemu" de "bootstrap Docker" y validar primero el contrato base (cloud-init + SSH + red).

- Riesgo: La imagen elegida no incluya `cloud-init` o no respete la configuracion de red esperada.
- Mitigacion: exigir smoke validation temprana (hostname/IP/SSH) y documentar imagen exacta usada.

## Migration Plan

1. Añadir deltas OpenSpec para `vm-provisioning` con el perfil `debian12` en `target=qemu`.
2. Implementar metadata/configuracion de imagen para `Debian 12` en el wrapper/target `libvirt`.
3. Validar provisionamiento y acceso SSH con red fija en qemu/libvirt.
4. Documentar prerequisitos, limitaciones y pasos de prueba.
5. Evaluar (en follow-up) paridad de `deployment-ready` para la distro.

## Open Questions

- Cual sera la fuente/pinning exacto de la imagen de `Debian 12` (URL versionada y checksum) en la implementacion.
- Si `Debian 12` requerira variaciones de `cloud-init` (nombre de interfaz, paquete SSH, netplan/networkd, etc.) respecto al template base.
