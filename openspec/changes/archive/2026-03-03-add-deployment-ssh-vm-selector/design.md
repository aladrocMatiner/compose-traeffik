## Context

Ya existe un flujo `deployment-ssh` para conectarse a una VM provisionada, pero hoy usa únicamente los outputs Terraform del root `infra/terraform/targets/libvirt`. Eso es suficiente para un estado single-host, pero no para operar un host concreto cuando hay varias VMs o cuando el estado Terraform no corresponde al host de interés.

El usuario pide una UX como `make deployment-ssh target=<qemu|proxmox> name=<name>` y también `make deployment-list target=<qemu|proxmox>` para listar los deployments/VMs creados por backend. También pide un fallback de acceso por credenciales (`root` / `abc123`) cuando SSH normal no funcione. Dado que esa credencial es insegura y fácil de filtrar/abusar, conviene diseñarla como una opción de depuración local explícita (si se acepta) y no como comportamiento por defecto.

## Goals / Non-Goals

- Goals:
- Permitir seleccionar un host por backend (`qemu` o `proxmox`) y nombre en `make deployment-ssh`.
- Permitir listar deployments/VMs gestionados por backend mediante `make deployment-list target=<qemu|proxmox>`.
- Mantener el modo actual basado en `terraform output` cuando no se pasa selector.
- Definir resolución de IP para `libvirt` por nombre de VM usando `virsh` y fuentes locales (agent/ARP/DHCP).
- Definir una estrategia determinista para identificar "recursos creados por este tooling" en listados de backend.
- Definir fallback de recuperación cuando SSH no está disponible.
- Dejar documentada una postura clara de seguridad sobre credenciales inseguras.
- Non-Goals:
- No implementar todavía multi-state Terraform por proyecto (eso merece un cambio separado).
- No implementar todavía el resolver completo de Proxmox si el backend no está listo (pero sí fijar la interfaz `target=proxmox name=<name>`).
- No habilitar credenciales inseguras por defecto.

## Decisions

- Decision: `deployment-ssh` aceptará un selector explícito con sintaxis `make deployment-ssh target=<qemu|proxmox> name=<name>`.
- Rationale: Separa backend (`target`) y nombre (`name`), evita ambigüedad y mantiene una interfaz uniforme entre backends.

- Decision: Se mantendrá el modo actual basado en outputs Terraform cuando no se pase selector explícito.
- Rationale: Preserva compatibilidad con el flujo actual (`deployment`, `deployment-ready`, etc.).

- Decision: Se añadirá `deployment-list target=<qemu|proxmox>` como interfaz de inventario por backend, separada de `deployment-ssh`.
- Rationale: Reduce fricción operativa y evita depender del state Terraform para descubrir hosts disponibles.

- Decision: Para `target=qemu`, la resolución de acceso seguirá una estrategia por capas (agent/ARP/DHCP) y reportará claramente qué fuente se usó; `target=proxmox` tendrá un resolver específico con la misma interfaz cuando esté disponible.
- Rationale: `qemu-guest-agent` puede no estar listo o no responder; necesitamos tolerancia y diagnósticos útiles.

- Decision: `deployment-list` usará un criterio determinista para "recursos gestionados" (por ejemplo, prefijo de nombre configurable) y deberá mostrar ese criterio en docs o salida.
- Rationale: Sin filtro, el listado puede mezclar VMs ajenas al proyecto en el mismo hypervisor.

- Decision: Si SSH no está disponible para un host seleccionado, el sistema mostrará un fallback de recuperación apropiado al backend (por ejemplo `virsh console <vm>` para `qemu`) y no asumirá credenciales por defecto.
- Rationale: `virsh console` es un canal local de recuperación más seguro que una contraseña estática hardcodeada.

- Decision: Las credenciales de fallback tipo `root/abc123` NO se habilitarán por defecto. Si se soporta un modo de depuración local, deberá ser opt-in explícito y con advertencias visibles.
- Rationale: Evita introducir una puerta trasera predecible en imágenes/hosts de lab, incluso en entornos locales.

## Access Resolution Strategy (proposed)

Para `make deployment-ssh target=qemu name=<name>` (backend local `libvirt`):

1. Verificar que el dominio existe (`virsh dominfo <name>`).
2. Intentar resolver IP con `virsh domifaddr --source agent`.
3. Si falla, intentar `virsh domifaddr --source arp`.
4. Si falla, consultar leases DHCP de la red libvirt asociada (`virsh net-dhcp-leases <network>`), usando la MAC de `domiflist`.
5. Si no hay IP resoluble, mostrar instrucción de recuperación por consola (`virsh console <name>`) y salir con error claro.

Para `make deployment-ssh target=proxmox name=<name>`:

- Mantener la misma interfaz (`target` + `name`) y delegar a un resolver específico de Proxmox.
- Si el resolver de Proxmox aún no está implementado en esta fase, devolver error explícito de "unsupported target" con mensaje claro.

Usuario SSH:
- Usar `DEPLOYMENT_HOST_USER` / `--user` si se proporciona.
- Si no, usar `terraform output` cuando esté disponible.
- Si no, usar un default explícito del flujo (`ubuntu`) con mensaje de advertencia.

## Deployment Listing Strategy (proposed)

Para `make deployment-list target=qemu`:

1. Enumerar VMs del backend local `libvirt` (`virsh list --all --name`).
2. Aplicar filtro de recursos gestionados por naming (prefijo configurable; por ejemplo `compose-traeffik-`).
3. Obtener estado (`running`, `shut off`, etc.) y, cuando sea razonable, metadatos básicos (IP si resoluble, red/MAC).
4. Mostrar salida legible para operador (tabla) y considerar formato machine-readable en una fase posterior.
5. Si también se listan "images" (artefactos de disco), distinguir claramente VM/domain vs disk image/base image para evitar ambigüedad.

Para `make deployment-list target=proxmox`:

- Reusar la interfaz `target=proxmox`.
- Si el resolver/listado de Proxmox aún no está implementado, devolver error explícito "not yet supported" con mensaje claro.

## Security / Fallback Policy

- Default:
- Acceso por SSH con key o consola `virsh`.
- No se provisionan ni se sugieren credenciales `root/abc123`.

- Optional debug mode (if approved later):
- Modo local-only, con flag explícito (por ejemplo `DEPLOYMENT_INSECURE_DEBUG_LOGIN=true`).
- Password configurable por operador (no hardcodeado en el repo).
- Advertencia visible en stdout y documentación.

## Risks / Trade-offs

- Riesgo: `target` de la UX (`qemu|proxmox`) puede confundirse con `DEPLOYMENT_TARGET` interno o con terminología `libvirt`.
- Mitigación: Normalizar `qemu` como alias UX del backend local `libvirt` y documentar el mapeo.

- Riesgo: Resolver IP por `virsh` puede ser inconsistente si no hay agent ni ARP/lease visible.
- Mitigación: Estrategia multicapa + fallback a `virsh console` + error claro.

- Riesgo: `deployment-list` puede listar recursos no gestionados por este proyecto si el criterio de filtro es ambiguo.
- Mitigación: Definir prefijo/criterio configurable y mostrarlo explícitamente en docs/salida.

- Riesgo: Añadir modo password insecure puede degradar la postura de seguridad del proyecto.
- Mitigación: Opt-in explícito, local-only, sin password por defecto en repo, y potencialmente separado en otro cambio si se considera demasiado riesgoso.

## Migration Plan

1. Añadir spec `host-access` con contrato de selector `target` + `name` y fallback.
2. Implementar parsing/routing de `deployment-ssh` por `target`.
3. Implementar resolver por `virsh` para `target=qemu`.
4. Añadir `deployment-list` con routing por `target` y estrategia de filtro gestionado.
5. Definir comportamiento de `target=proxmox` para esta fase (resolver/listado real o error explícito "not yet supported").
6. Actualizar `Makefile`/help y scripts docs.
7. (Opcional, si se aprueba) añadir modo de depuración por credenciales local-only con gating explícito.
8. Validar con VMs `libvirt` múltiples (state activo + VM fuera de state) y revisar UX del target `proxmox`.

## Open Questions

- ¿Quieres soportar alias de compatibilidad como `backend=` y `vm=` además de `target=` y `name=` o dejamos solo la UX que pediste?
- ¿Qué criterio prefieres para `deployment-list` en `qemu`: prefijo de nombre (recomendado) o listar todo el hypervisor y marcar "managed/unmanaged"?
- Si se permite modo password de depuración, ¿debe ir en este cambio o en uno aparte por seguridad?
