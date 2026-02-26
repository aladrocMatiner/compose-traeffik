# Design: Gentoo (Experimental) on QEMU/Libvirt - Phased Qualification and Isolation

## Context

El repositorio ya dispone de un flujo operativo para `qemu/libvirt` con Ubuntu (`Terraform + cloud-init` + scripts de bootstrap). Gentoo no debe entrar como una simple variante de URL de imagen porque introduce incertidumbre en varias capas:

- disponibilidad/estabilidad de imagen cloud con `cloud-init`
- init system (`OpenRC` vs `systemd`) y gestion de servicios
- herramientas de red y nombres de interfaz esperados por `cloud-init`
- disponibilidad de `python3` para Ansible
- viabilidad y costo temporal de bootstrap de Docker (package manager `emerge`, binpkgs, kernel/cgroups)

Por ello, el diseño se centra primero en **calificacion** y **aislamiento**.

## Goals / Non-Goals

### Goals

- Definir una ruta de adopcion segura para `Gentoo (Experimental)` en `target=qemu` (`libvirt`).
- Separar explicitamente la calificacion de imagen/provisionamiento del bootstrap Docker.
- Establecer gates de madurez y evidencia objetiva antes de promover cualquier nivel de soporte.
- Aislar artefactos, scripts y notas de Gentoo en `experiments/gentoo-qemu/` para minimizar acoplamiento con el flujo estable.
- Preparar el trabajo para futura extraccion a repo/submodulo sin rehacer estructura.

### Non-Goals

- No implementar soporte `proxmox` para Gentoo en este cambio.
- No prometer `deployment-ready` con Docker/Compose como resultado directo de esta propuesta.
- No modificar el contrato base de `vm-provisioning` para otros OS estables.
- No introducir una matriz completa de variantes Gentoo desde el inicio (se prioriza una baseline calificada).

## Key Constraints and Assumptions

- `qemu` target usa `libvirt` y debe seguir reutilizando el root Terraform existente para el flujo estable, salvo artefactos de exploracion que queden en `experiments/gentoo-qemu/`.
- La compatibilidad con `cloud-init` es requisito de entrada para integrar Gentoo en el flujo principal.
- El soporte se marca como **Experimental** hasta completar evidencia minima definida en este documento.
- El baseline calificado inicial para `Gentoo (Experimental)` DEBE usar `OpenRC`; variantes `systemd` pueden soportarse como override explicito (`init=systemd`) para provisionamiento experimental si tienen manifest calificado, pero no cambian que el objetivo principal de integracion/promocion sea `OpenRC`.
- El flujo de operador para Gentoo debe permitir seleccionar `init=openrc|systemd`, con `openrc` como valor por defecto cuando `os=gentoo`.

## Isolation Strategy (Future Repo/Submodule Ready)

### Directory Boundary

Se crea `experiments/gentoo-qemu/` como workspace aislado para discovery, manifests, scripts y evidencia. Este directorio se considera una unidad extraible.

Planned layout (initial):

- `experiments/gentoo-qemu/README.md`: alcance, status y roadmap
- `experiments/gentoo-qemu/AGENTS.md`: reglas de trabajo locales y limites con el repo principal
- `experiments/gentoo-qemu/docs/`: decisiones, matriz de compatibilidad y evidencia
- `experiments/gentoo-qemu/manifests/`: metadatos de imagen (URL/checksum/variant/init-system)
- `experiments/gentoo-qemu/cloud-init/`: templates/adaptaciones especificas si hicieran falta
- `experiments/gentoo-qemu/scripts/`: scripts/spikes de calificacion (descarga, inspeccion, smoke tests)
- `experiments/gentoo-qemu/artifacts/`: evidencia de pruebas (logs, outputs, reports)
- `experiments/gentoo-qemu/work/`: area ignorada para imagenes descargadas y pruebas locales

### Boundary Rules

- No mezclar scripts experimentales de Gentoo con `scripts/` del flujo estable hasta que se cumplan los gates de calificacion.
- Toda decision tecnica nueva (imagen, init system, workaround de cloud-init) debe quedar documentada en `experiments/gentoo-qemu/docs/`.
- Los artefactos pesados (qcow2, caches, logs largos) quedan ignorados por `.gitignore` local.
- Las referencias a rutas del repo principal deben limitarse a una capa de adaptacion/documentacion para facilitar futura extraccion.

## Maturity Gates (Required Before Promoting Support)

### Gate 0: `discovery-complete`

**Objective**: Identificar una o mas imagenes candidatas Gentoo utilizables en `qemu/libvirt`.

Entry criteria:
- Existe hipotesis de fuente de imagen (oficial o imagen preparada por el proyecto).

Exit criteria:
- Se documentan al menos una imagen candidata y una alternativa.
- Se registra formato (`qcow2`/`img`), arquitectura, init system, si incluye `cloud-init`, `openssh`, `python3`.
- Se registra politica de pinning (version/fecha) y checksum (o riesgo si no existe checksum oficial).

Evidence:
- `docs/qualification-matrix.md`
- `manifests/*.yaml` o `.json`
- log de descarga/inspeccion basica

### Gate 1: `image-qualified`

**Objective**: Confirmar que la imagen seleccionada se puede arrancar y es compatible con el baseline de `cloud-init` (o documentar adaptacion minima necesaria).

Entry criteria:
- Gate 0 completado.
- Manifest de imagen con URL + checksum + variante.

Exit criteria:
- VM arranca en `qemu/libvirt` con consola/serial accesible.
- `cloud-init` se ejecuta sin fallos criticos para hostname + SSH key injection.
- Se identifica con evidencia el init system real de la imagen y la candidata baseline seleccionada queda verificada como `OpenRC`.

Evidence:
- `cloud-init status`
- logs de `journalctl` o `rc-status`/logs equivalentes
- prueba de hostname y clave SSH inyectada

### Gate 2: `qemu-provisionable`

**Objective**: Validar contrato minimo de `vm-provisioning` compartido (hostname + IP fija + SSH) en `libvirt`.

Entry criteria:
- Gate 1 completado.
- Configuracion de red fija definida (CIDR, gateway, DNS) para red de prueba.

Exit criteria:
- VM aplica IP fija via `cloud-init` (o adaptacion documentada), responde a SSH y mantiene conectividad tras reboot.
- El workflow falla con errores claros cuando faltan metadatos o la variante no es soportada.
- Se documentan diferencias de interfaz/naming de red y workaround minimo.

Evidence:
- salida de `ip a` / `ip route`
- login SSH repetible
- prueba de reinicio y reconexion
- reporte de errores esperados (negative tests)

### Gate 3: `ansible-ready`

**Objective**: Confirmar que el host es apto para handoff a Ansible (aunque no se implemente el playbook en este cambio).

Entry criteria:
- Gate 2 completado.

Exit criteria:
- `python3` disponible (preinstalado o instalable por un paso reproducible y documentado).
- Usuario SSH y permisos definidos para automatizacion.
- Se documenta comando de verificacion equivalente a `deployment-bootstrap-check` (sin Docker).

Evidence:
- `python3 --version`
- `ansible -m ping` (opcional si se ejecuta)
- notas de servicio SSH segun init system

### Gate 4: `docker-feasibility-assessed`

**Objective**: Tomar una decision informada sobre paridad Docker/Compose.

Entry criteria:
- Gate 3 completado.

Exit criteria:
- Documento de viabilidad con una de estas salidas:
  - `feasible-now` (paso de instalacion y servicios definidos)
  - `feasible-with-constraints` (e.g. binpkgs, OpenRC service constraints, kernel flags)
  - `defer` (no compensa para el objetivo actual)
- Si se difiere, existe follow-up change propuesto.

Evidence:
- `docs/docker-feasibility.md`
- matriz de riesgos / tiempo de provisionamiento

## Technical Workstreams (Exhaustive Planning)

## Workstream A: Image Source and Provenance

### Objectives

- Encontrar una imagen Gentoo reproducible para `qemu/libvirt` con `cloud-init` o con un camino de preparacion documentado.

### Tasks and decisions to capture

- Identificar fuentes oficiales/comunitarias confiables.
- Verificar arquitectura (`x86_64`) y formato compatible (`qcow2` preferido).
- Verificar presencia de `cloud-init` y metodo de datasource esperado (`NoCloud` para `libvirt_cloudinit_disk`).
- Validar disponibilidad de checksum/firmas.
- Definir politica de pinning (version exacta vs latest date-stamped) y cadencia de refresh.
- Registrar EOL/rolling-risk (Gentoo es rolling; definir snapshot policy).

### Failure modes

- Imagen no trae `cloud-init`.
- Imagen trae `cloud-init` pero sin soporte de networking esperado.
- Imagen arranca pero no habilita SSH.
- Imagen rolling cambia comportamiento sin aviso.

### Mitigations

- Soportar `project-prepared qcow2` como fallback documentado.
- Manifests con checksum obligatorio y metadata de fecha.
- Mantener al menos una imagen alternativa qualificada.

## Workstream B: cloud-init Compatibility (Hostname, Users, SSH)

### Objectives

- Confirmar que el template de `user-data` base funciona o identificar delta minimo especifico de Gentoo.

### Areas to verify

- `users`, `ssh_authorized_keys`
- `hostname`, `manage_etc_hosts`
- package installation in cloud-init (si aplica)
- `runcmd` / `bootcmd` semantics and timing
- `ssh_pwauth` and root login policy (debe permanecer seguro por default)

### Notes

- Evitar introducir password por defecto (`root/abc123`) en perfiles normales; si se usa en debugging, debe ser opt-in y documentado como inseguro.
- Confirmar si `openssh-server` y `cloud-init` vienen preinstalados o deben instalarse en una imagen preparada.

## Workstream C: Static Networking on QEMU/Libvirt

### Objectives

- Validar red fija con la red libvirt usada (`default`/bridge custom) sin depender de guest-agent/lease discovery.

### Areas to verify

- Nombre de interfaz (`ens3`, `enp1s0`, etc.)
- Renderizador de red usado por la imagen (networkd, NetworkManager, scripts, netifrc)
- Compatibilidad de `network-config` v2 de cloud-init con la imagen Gentoo
- Persistencia tras reboot
- DNS y gateway funcionales

### Decision checkpoint

Si `network-config` v2 falla de forma estructural, decidir entre:
- adaptar template Gentoo especifico,
- usar otra variante de imagen,
- pausar integracion principal y mantener soporte experimental aislado.

## Workstream D: Init System and Service Management Matrix

### Why this matters

Los scripts existentes asumen `systemctl` (Ubuntu). En Gentoo queremos baseline `OpenRC`, pero el operador podra seleccionar `init=systemd` como override experimental. Esto impacta SSH, guest-agent y potencialmente Docker, y exige separar claramente baseline (`OpenRC`) de variante override (`systemd`).

### Plan

- Registrar init system real en manifest de imagen.
- Exigir `OpenRC` para la candidata baseline que aspire a cumplir Gates 1-3 y ser el default del flujo.
- Permitir imagenes `systemd` como comparativa/fallback de discovery y como variante seleccionable via `init=systemd` cuando exista manifest compatible.
- Postergar la paridad funcional completa (`OpenRC` + `systemd` en todos los pasos, especialmente bootstrap Docker) hasta despues de integrar un baseline `OpenRC` calificado.

### Output

- `docs/init-system-matrix.md` con comandos equivalentes (`systemctl`, `rc-service`, `rc-update`) y diferencias.

## Workstream E: Ansible Readiness Baseline (No Docker Yet)

### Objectives

- Verificar condiciones minimas para entregar el host a Ansible.

### Checks

- `python3` presente
- SSH estable y usuario con key injection
- `sudo` behavior documentado (si aplica)
- `qemu-guest-agent` opcional (no bloquear Gate 2/3)

### Non-goal reminder

- No ejecutar rol Docker definitivo en esta propuesta.

## Workstream F: Docker/Compose Feasibility Study (Follow-up Decision Input)

### Objectives

- Determinar si tiene sentido soportar Docker en Gentoo en este proyecto y bajo que restricciones.

### Questions to answer

- `emerge` con binpkgs esta disponible y es reproducible?
- Tiempo de bootstrap aceptable para CI/local labs?
- Requisitos de kernel/cgroup para Docker en la imagen/base host?
- Que restricciones concretas introduce `OpenRC` para Docker/Compose frente al flujo Ubuntu actual?
- Conviene `podman` como alternativa o romperia el contrato de proyecto?

### Deliverable

- Decision doc con recomendacion (`support-openrc`, `support-openrc-with-constraints`, `defer`).

## Workstream G: Integration Back to Main Pipeline

### Objectives

- Integrar solo lo que este calificado sin contaminar el flujo estable.

### Strategy

- Introducir selector `os=gentoo` (o equivalente interno `DEPLOYMENT_OS=gentoo`) con `init=openrc|systemd` solo para Gentoo y default `openrc`.
- Resolver la variante Gentoo mediante manifest metadata por init system (`openrc`/`systemd`) y validar compatibilidad antes de provisionar.
- Mantener `OpenRC` como baseline promocionable aunque exista soporte de override `systemd`.
- Reutilizar `infra/terraform/targets/libvirt` y cloud-init base solo cuando el delta sea minimo y probado.
- Mantener scripts de experimentacion en `experiments/gentoo-qemu/` incluso despues de integrar el path principal.
- No activar `deployment-ready` para Gentoo hasta tener decision explicita de Docker parity.

### Suggested incremental integration milestones

1. `deployment-plan` soporta `gentoo` con metadata validada.
2. `deployment` soporta `gentoo` con `init=openrc` por defecto y alcanza Gate 2 en baseline OpenRC.
3. `deployment` opcionalmente acepta `init=systemd` si hay manifest calificado para esa variante (experimental/override).
4. `deployment-wait` soporta `gentoo` y confirma Gate 3 en baseline OpenRC.
5. `deployment-bootstrap` sigue deshabilitado o experimental hasta follow-up.

## Validation and Evidence Plan

## Required Evidence per run

Cada ejecucion de calificacion debe generar (o copiar) evidencia en `experiments/gentoo-qemu/artifacts/runs/<timestamp>/`:

- manifest de entrada (imagen, checksum, vars de red)
- `terraform plan`/`apply` logs (o equivalente spike)
- `cloud-init status` y logs relevantes
- output de `hostnamectl` o `hostname`
- `ip a`, `ip route`, resolv config
- prueba SSH (`whoami`, `uname -a`, `python3 --version` si aplica)
- init system detectado y comando usado para consultar estado SSH
- resultado del test (pass/fail) con causa si falla

## Test Matrix (minimum)

- Red libvirt `default` (NAT) con IP fija dentro de subred esperada.
- Red libvirt custom (si existe en host de pruebas) para detectar problemas de interfaz/MTU/bridge.
- Reboot validation (persistencia de red y SSH).
- Negative tests:
  - checksum mismatch
  - manifest incompleto
  - imagen sin `cloud-init` (si se prueba una candidata fallida)

## Logging and Traceability

- Cada decision o workaround (e.g. template de `cloud-init` especifico para Gentoo) debe enlazarse a evidencia en `docs/decision-log.md`.
- Evitar knowledge only-in-chat: toda conclusion relevante se registra en archivos del directorio aislado.

## Security Considerations

- SSH por clave como default; no password defaults inseguros.
- Si se habilita password temporal para debugging, debe ser opt-in, con flag explicito y documentado como inseguro.
- Checksums/firmas de imagen son obligatorios para cualquier perfil promocionado fuera de `discovery`.
- La seleccion `init=systemd` debe requerir intencion explicita del operador; el default permanece `openrc`.

## Extraction Readiness Criteria (Future Repo/Submodule)

El directorio `experiments/gentoo-qemu/` se considerara listo para extraerse cuando:

- tenga README con alcance, prerequisitos y flujo reproducible
- scripts internos funcionen sin depender de rutas implicitas del repo principal
- manifests y docs de evidencia esten versionados
- exista una capa adaptadora minima para integrar con el repo principal (en vez de referencias cruzadas extensas)
- el historial de decisiones documente por que sigue experimental o por que se promociona

## Open Questions (To Resolve During Stage A/B)

- Fuente exacta de imagen Gentoo (oficial vs imagen preparada por el proyecto) y su politica de snapshots.
- Si la variante `systemd` quedara limitada a provisioning basico (`deployment`/`deployment-wait`) o tambien se calificara para `ansible-ready`/otros pasos.
- Nivel minimo de soporte deseado para `python3` (preinstalado vs instalacion documentada post-boot).
- Si se acepta que `qemu-guest-agent` sea opcional/ausente en Gentoo experimental.
- Si Docker parity merece cambio separado incluso tras Gate 3.
