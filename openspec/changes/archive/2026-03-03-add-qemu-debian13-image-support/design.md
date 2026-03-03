# Design: Debian 13 Image Profile on QEMU/Libvirt (Phased Qualification)

## Context

El repositorio ya tiene un flujo funcional para `qemu/libvirt` con Ubuntu y trabajo experimental con Gentoo. `Debian 13` es un candidato de baja complejidad relativa, pero aun asi requiere una incorporacion disciplinada para mantener reproducibilidad, compatibilidad con `cloud-init`, y una interfaz uniforme (`make deployment os=...`) sin degradar el flujo existente.

El objetivo de este diseno es separar claramente:

- calificacion de imagen cloud (`Debian 13`)
- validacion del contrato de provisionamiento (`hostname`, IP fija, SSH)
- integracion posterior en wrappers/scripts
- futuro follow-up de Docker bootstrap/paridad `deployment-ready`

## Goals / Non-Goals

### Goals

- Definir un perfil `debian13` para `target=qemu` (`libvirt`) bajo el contrato de `vm-provisioning`.
- Fijar una estrategia de pinning/checksum para la cloud image de Debian 13.
- Validar compatibilidad `cloud-init` con NoCloud (`libvirt_cloudinit_disk`) para hostname, SSH e IP fija.
- Definir una matriz de validacion minima y evidencia para declarar el perfil `qemu-provisionable`.
- Preparar la integracion en el flujo principal con cambios minimos y mensajes de error claros.

### Non-Goals

- No implementar soporte `proxmox` para Debian 13 en este cambio.
- No garantizar `deployment-bootstrap` / Docker parity en Debian 13 en esta proposal.
- No redisenar el modulo Terraform `libvirt`; solo extenderlo con metadatos/perfil si hace falta.
- No cambiar el contrato de otros perfiles (`ubuntu`, `gentoo`) mas alla de compartir utilidades si es necesario.

## Assumptions and Constraints

- `qemu` target sigue usando `libvirt` y el root Terraform actual.
- La imagen Debian 13 seleccionada debe ser oficial o documentadamente confiable.
- `cloud-init` es requisito de entrada para integracion en el flujo principal.
- La red de validacion primaria sera `libvirt default` (NAT), con IP fija dentro de su subred.
- `wait_for_lease` no se usara como mecanismo de readiness (se mantiene el enfoque de IP fija + SSH checks).

## Maturity Gates (for this OS profile)

### Gate 0: `image-selected`

Objective:
- Seleccionar una cloud image Debian 13 con metadata verificable.

Entry criteria:
- Existe una o mas fuentes candidatas de imagen Debian 13.

Exit criteria:
- Se selecciona una fuente oficial (o se documenta por que no) con URL pinneada.
- Se define checksum strategy (SHA256 oficial o checksum versionado en manifest).
- Se registra formato, arquitectura y notas de compatibilidad esperadas.

Evidence:
- metadata de imagen (URL/version/fecha/checksum)
- notas de seleccion y fallback candidate

### Gate 1: `cloud-init-compatible`

Objective:
- Confirmar que la imagen aplica `user-data` NoCloud para hostname y SSH key injection.

Entry criteria:
- Gate 0 completado.

Exit criteria:
- VM arranca en `qemu/libvirt`.
- `cloud-init` ejecuta sin fallos criticos.
- Hostname esperado aplicado.
- Clave SSH del operador inyectada y login por SSH posible (aunque aun no se valide IP fija).

Evidence:
- `cloud-init status --wait`
- `hostname`
- prueba SSH con la key actual

### Gate 2: `qemu-provisionable`

Objective:
- Validar el contrato base de `vm-provisioning` para `Debian 13` en `libvirt`.

Entry criteria:
- Gate 1 completado.
- Parametros de red fija definidos para la red de prueba.

Exit criteria:
- IP fija funcional via `cloud-init`.
- Gateway y DNS operativos.
- SSH accesible por la IP fija.
- Persistencia tras reboot (red + SSH + hostname).

Evidence:
- `ip -4 addr`, `ip route`, resolucion DNS
- prueba SSH a IP fija
- reboot + reconexion

### Gate 3: `integration-ready` (for vm-provisioning only)

Objective:
- Tener definida la integracion al flujo principal sin ambiguedad.

Entry criteria:
- Gate 2 completado.

Exit criteria:
- Interfaz `os=debian13` definida y validaciones de errores especificadas.
- Cambios requeridos en wrapper/Makefile/templates acotados y documentados.
- Follow-up de Docker bootstrap delimitado explicitamente.

Evidence:
- decision notes
- checklist de implementacion aprobable

## Technical Workstreams

## Workstream A: Image Source, Pinning, and Provenance

### Objectives

- Seleccionar una cloud image Debian 13 reproducible y estable para `qemu/libvirt`.

### Decisions to capture

- Fuente exacta (cloud image oficial Debian 13).
- URL pinneada (version/date-specific) vs alias estable y como se resuelve en el script.
- Checksum source y metodo de verificacion.
- Politica de refresh (manual upgrade proposal vs actualizacion automatica).
- Fallback candidate si la imagen principal cambia formato/comportamiento.

### Failure modes

- Imagen no incluye `cloud-init` o lo tiene deshabilitado.
- Imagen cambia de URL/estructura y rompe downloads.
- Falta checksum confiable y se introduce riesgo de drift.

### Mitigations

- Manifest de perfil con URL + checksum + fecha/version.
- Error claro cuando checksum/metadata falta o no coincide.
- Documentar imagen fallback y criterio de sustitucion.

## Workstream B: cloud-init User Data Compatibility

### Objectives

- Confirmar que las plantillas actuales de `user-data` son reutilizables para Debian 13 con cambios minimos o nulos.

### Areas to verify

- `users` + `ssh_authorized_keys`
- `hostname` / `fqdn` / `manage_etc_hosts`
- servicio SSH (`ssh` vs `sshd` enable/start)
- paquetes minimos (`python3`, `qemu-guest-agent`, etc.) si se incluyen en `cloud-init`
- tiempos de `cloud-init` y readiness para `deployment-wait`

### Decision checkpoint

- Si Debian 13 funciona con el template Ubuntu-like actual, evitar branching innecesario.
- Si requiere diferencias (paquete/servicio), encapsularlas por `os_family` con cambios minimos y documentados.

## Workstream C: Static Networking via cloud-init on Libvirt

### Objectives

- Validar `network-config` v2 de `cloud-init` con red fija en `libvirt` sin depender del guest-agent.

### Areas to verify

- nombre de interfaz (`ens3` esperado, pero confirmar)
- aplicacion de `match: macaddress` + `set-name`
- IP fija, gateway y DNS
- comportamiento en primer boot y tras reboot
- coexistencia (o no) con DHCP residual

### Negative tests

- IP fuera de subred/gateway invalido (el workflow debe fallar claramente o quedar diagnosticable)
- metadata de red incompleta (missing gateway/DNS/cidr)
- mismatch de MAC/interface name

## Workstream D: Integration Contract for Main QEMU Flow

### Objectives

- Preparar la incorporacion de `debian13` en el flujo principal con UX consistente y errores claros.

### Planned interface behavior

- `make deployment os=debian13`
- `make deployment-plan os=debian13`
- `make deployment-wait os=debian13`
- `make deployment-ssh os=debian13`
- `make deployment-destroy os=debian13`

### Validation and errors

- Error si `os=debian13` y no existe metadata de imagen pinneada.
- Error si checksum no coincide o no se puede verificar segun policy.
- Error si se usa un parametro no aplicable a Debian (ej. `init=` pensado para Gentoo) con mensaje explicito.

### Change boundaries

- No mezclar aqui la logica de `deployment-bootstrap` (Docker).
- Mantener `host-bootstrap.sh` para Debian 13 como follow-up o trabajo separado.

## Workstream E: Docker Bootstrap Follow-up Boundary (Not in Scope)

### Why define it now

Aunque Debian 13 es apt-friendly y se espera cercano a Ubuntu/Debian 12, mezclar soporte de imagen con bootstrap Docker en el mismo cambio complica la validacion y el rollback.

### Deliverable for this proposal

- Lista clara de preguntas/follow-up para Docker parity:
  - repo Docker oficial para Debian 13 (codename / signed-by)
  - package names exactos
  - validacion `docker compose version`
  - compatibilidad con checks actuales

## Validation and Evidence Plan

## Required evidence for profile qualification

Para dar por bueno el perfil `debian13` (a nivel de provisionamiento qemu) debe registrarse evidencia de:

- metadata de imagen seleccionada (URL/version/checksum)
- `terraform plan` / `apply` del target `libvirt`
- `cloud-init status --wait`
- `hostname`
- `ip -4 addr` / `ip route`
- prueba SSH a la IP fija
- reboot y reconexion exitosa
- al menos un negative test (metadata invalida o checksum mismatch)

## Test Matrix (minimum)

- `libvirt default` network (NAT) con IP fija configurada.
- Reboot persistence test.
- `deployment-ssh` con key actual del operador.
- Error-path test: metadata/checksum invalido.

Optional (if host supports it):
- red `libvirt` custom/bridge para detectar diferencias de naming o routing.

## Security Considerations

- SSH por clave como default; no password fallback por defecto.
- Verificacion de checksum obligatoria para perfiles promocionados.
- No introducir secretos en metadata de imagen ni tfvars versionados.

## Open Questions (to resolve during Stage A/B)

- URL pinneada exacta de Debian 13 y formato final de checksum metadata.
- Si el template `user-data` actual necesita cambios minimos por servicio SSH/paquetes.
- Si `qemu-guest-agent` se instala en `cloud-init` o se deja fuera del gate de provisionamiento.
- Si `debian13` puede compartir por completo el path `debian` futuro o se mantiene perfil versionado explicito.
