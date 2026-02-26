## Context

El repositorio ya tiene un flujo funcional de provisionamiento local `qemu` (backend `libvirt`) para Ubuntu con `Terraform` + `cloud-init`. Queremos extender ese flujo para `openSUSE Leap` manteniendo la misma interfaz general del target `qemu`, con foco inicial en imagen cloud + arranque + red/SSH listos para configuracion posterior.

## Goals / Non-Goals

- Goals:
- Definir un perfil de imagen `opensuse-leap` para `target=qemu`.
- Confirmar compatibilidad de la imagen de `openSUSE Leap` con `cloud-init` para hostname, red fija y SSH.
- Definir politica de pinning/versionado de imagen para reproducibilidad local.
- Documentar restricciones y diferencias conocidas para la distro.
- Non-Goals:
- No introducir soporte `proxmox` en este cambio.
- No garantizar paridad completa de bootstrap Docker/Compose en esta propuesta (puede requerir cambio complementario).
- No cambiar el contrato base de `vm-provisioning`; se amplia con un nuevo perfil de OS.

## Decisions

- Decision: El soporte para `openSUSE Leap` se implementara como un perfil de imagen de `target=qemu` (`libvirt`) reutilizando la misma estructura de Terraform y `cloud-init`.
- Rationale: Minimiza duplicacion y mantiene una interfaz uniforme para futuros OS profiles.

- Decision: El cambio debe fijar una estrategia de pinning de imagen (version o URL estable + checksum policy) para `openSUSE Leap`.
- Rationale: Reduce drift y facilita reproducibilidad de pruebas locales.

- Decision: La validacion minima de exito sera `cloud-init` aplicado + hostname esperado + IP fija + SSH accesible.
- Rationale: Ese es el contrato minimo necesario para handoff a `host-bootstrap`/Ansible.

## Distro-specific Notes

- Fit assessment: cloud images and cloud-init are available, but distro defaults differ more from Ubuntu/Debian.
- Expected image source: openSUSE Leap cloud image.
- Bootstrap parity note: El soporte de `host-bootstrap` para `openSUSE Leap` se tratara como follow-up si requiere cambios por package manager/servicios.

## Risks / Trade-offs

- Riesgo: SSH/cloud-init defaults and package management differ (zypper), so qemu image support should be validated independently from Docker bootstrap parity.
- Mitigacion: separar "soporte de imagen qemu" de "bootstrap Docker" y validar primero el contrato base (cloud-init + SSH + red).

- Riesgo: La imagen elegida no incluya `cloud-init` o no respete la configuracion de red esperada.
- Mitigacion: exigir smoke validation temprana (hostname/IP/SSH) y documentar imagen exacta usada.

## Migration Plan

1. Añadir deltas OpenSpec para `vm-provisioning` con el perfil `opensuse-leap` en `target=qemu`.
2. Implementar metadata/configuracion de imagen para `openSUSE Leap` en el wrapper/target `libvirt`.
3. Validar provisionamiento y acceso SSH con red fija en qemu/libvirt.
4. Documentar prerequisitos, limitaciones y pasos de prueba.
5. Evaluar (en follow-up) paridad de `deployment-ready` para la distro.

## Open Questions

- Cual sera la fuente/pinning exacto de la imagen de `openSUSE Leap` (URL versionada y checksum) en la implementacion.
- Si `openSUSE Leap` requerira variaciones de `cloud-init` (nombre de interfaz, paquete SSH, netplan/networkd, etc.) respecto al template base.
