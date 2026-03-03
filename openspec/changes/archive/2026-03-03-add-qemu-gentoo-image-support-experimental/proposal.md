# Change: Deep Planning for QEMU Gentoo (Experimental) Image Support

## Why

Gentoo es viable con el stack `Terraform + cloud-init + Ansible`, pero su soporte en `qemu/libvirt` es significativamente mas complejo que Ubuntu/Debian por la variabilidad de imagenes cloud, init system (`OpenRC` vs `systemd`), disponibilidad real de `cloud-init`, tiempos de bootstrap y diferencias de servicios/paquetes. Ademas, para este proyecto queremos asegurar un baseline con `OpenRC`, lo que obliga a calificar explicitamente esa variante y no aceptar atajos con imagenes `systemd` como sustituto del default. A la vez, queremos dejar planificada la segunda configuracion posible (`init=systemd`) bajo el mismo contrato de provisionamiento. Si se implementa sin un plan por fases, es muy probable introducir deuda tecnica y falsas expectativas de paridad con `deployment-ready`.

Ademas, el trabajo de Gentoo tiene suficiente complejidad y riesgo como para merecer aislamiento operativo desde el inicio, con vistas a extraerlo a un repositorio aparte o submodulo si crece.

## What Changes

- Reescribir esta propuesta como un plan exhaustivo por fases para el perfil `gentoo` en `target=qemu` (`libvirt`), incluyendo discovery, calificacion de imagen, compatibilidad de `cloud-init`, red fija, SSH y criterios de evidencia.
- Fijar `OpenRC` como init system requerido para el baseline `Gentoo (Experimental)` que se considere calificable para integracion en el flujo principal de `qemu`.
- Definir interfaz de operador para Gentoo con selector de init explícito (`init=<openrc|systemd>`) y valor por defecto `openrc` cuando `os=gentoo`.
- Definir una pista de calificacion explicita para la variante `systemd` (segunda configuracion posible) con manifests y evidencia por variante, sin cambiar que `OpenRC` sea el default.
- Definir gates explicitos de madurez (`image-qualified`, `qemu-provisionable`, `ansible-ready`) para evitar declarar soporte completo antes de validar el contrato base.
- Formalizar que el soporte `Gentoo` entra como **Experimental** y que la paridad de bootstrap Docker/Compose queda en follow-up (salvo estudio de factibilidad en este cambio).
- Crear y documentar un directorio aislado `experiments/gentoo-qemu/` para concentrar scripts, manifests, evidencia y notas de compatibilidad, preparado para futura extraccion a repo/submodulo.
- Ampliar el delta spec de `vm-provisioning` con requisitos de perfil experimental, metadatos de calificacion y fallos claros cuando no se cumplen prerequisitos.

## Capabilities

### New Capabilities

- None.

### Modified Capabilities

- `vm-provisioning`: extender el target `qemu`/`libvirt` con un perfil `gentoo` **experimental** sujeto a calificacion de imagen y compatibilidad de `cloud-init`.

## Impact

- Affected code (planned): `deployment/scripts/infra-provision.sh`, `infra/terraform/targets/libvirt/`, `infra/cloud-init/` (si se requieren plantillas/branching por distro), `Makefile`, y documentacion de uso.
- New isolated workspace: `experiments/gentoo-qemu/` (docs, manifests, scripts y evidencia) para reducir acoplamiento con el flujo estable.
- Dependency note: este trabajo depende del contrato base definido en `add-vm-bootstrap-targets` para `qemu/libvirt`.
- Delivery note: el resultado de esta propuesta **no implica automaticamente** `deployment-ready` con Docker en Gentoo; eso queda gated por evidencia de compatibilidad y follow-up especifico.
- UX note (planned): `make deployment os=gentoo` implicara `init=openrc` por defecto; `make deployment os=gentoo init=systemd` sera la segunda configuracion posible via override explicito (sujeto a manifest calificado y soporte declarado por variante).

## Proposed Delivery Stages (Planning Scope)

1. `Stage A - Discovery & Qualification`: confirmar imagen Gentoo utilizable (cloud image o qcow2 preparado) con metadatos pinneados y checksum.
2. `Stage B - QEMU Provisioning Baseline`: probar hostname + IP fija + SSH con `cloud-init` en `qemu/libvirt` para baseline `OpenRC` y definir evidencia equivalente para la variante `systemd`.
3. `Stage C - Ansible-Ready Baseline`: confirmar `python3` y acceso SSH estable; documentar diferencias de servicio entre `OpenRC` y `systemd` y soporte por variante.
4. `Stage D - Docker Feasibility Assessment`: documentar viabilidad de Docker/Compose (no necesariamente implementarlo) y definir follow-up.
5. `Stage E - Integration/Extraction Decision`: decidir si el trabajo entra en el flujo principal o se mantiene aislado / extrae a submodulo.

## Success Criteria for This Proposal (Planning Acceptance)

- Existe un plan detallado por fases con riesgos, dependencias, criterios de entrada/salida y evidencia requerida.
- La spec delta refleja claramente el caracter experimental y los prerequisitos de calificacion.
- El repositorio contiene un directorio aislado `experiments/gentoo-qemu/` con estructura y reglas para futura extraccion.
- Queda definido `OpenRC` como baseline y valor por defecto para Gentoo, con `systemd` como variante explicita seleccionable via `init=systemd`; se documenta una ruta de calificacion por variante y el tratamiento de la paridad Docker.

## Risks if We Skip This Planning

- Implementacion parcial que parece soportar Gentoo pero falla en red fija/SSH o `cloud-init` de forma no determinista.
- Scripts de bootstrap contaminados con branching prematuro para una distro no calificada.
- Dificultad para extraer el trabajo a repo/submodulo por mezcla con el flujo principal.
- Tiempo perdido persiguiendo Docker/Compose antes de validar el contrato minimo de provisionamiento.
