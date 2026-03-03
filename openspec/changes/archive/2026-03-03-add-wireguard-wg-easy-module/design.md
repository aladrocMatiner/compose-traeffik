## Context

El stack actual usa una estrategia clara de composición por capas:
- `compose/base.yml` define redes/volúmenes compartidos.
- cada servicio vive en `services/<service>/compose.yml`.
- `Makefile` y `scripts/compose.sh` mantienen una lista explícita de fragments compose.
- Traefik enruta servicios por labels Docker con `exposedByDefault=false`.

La integración de WireGuard debe respetar este patrón para ser transparente al usuario y mantenible para futuras ramas.

## Goals / Non-Goals

### Goals

- Añadir un módulo WireGuard opcional fácil de activar (`profile=wg`) sin romper `make up`.
- Mantener la UI de administración detrás de Traefik (HTTPS) y evitar exposición TCP directa de la UI.
- Publicar solo el puerto UDP del túnel WireGuard con configuración explícita por `.env`.
- Proveer una interfaz operativa consistente con el resto del repo (`Makefile`, docs multilenguaje, smoke tests, guardrails).
- Dejar instrucciones y tareas lo bastante concretas para implementación por otro agente con baja inferencia.

### Non-Goals

- No validar conectividad VPN runtime en smoke tests generales.
- No soportar topologías mesh/multi-site avanzadas (solo servidor WireGuard clásico con UI).
- No rediseñar Traefik ni la estructura de perfiles existente.

## Decisions

### 1. Naming and Layout

- Carpeta de servicio: `services/wg-easy/`
- Compose service name: `wg-easy`
- Profile: `wg`
- Make lifecycle targets: `wg-up`, `wg-down`, `wg-restart`, `wg-logs`, `wg-status`

Rationale:
- El nombre de carpeta refleja el upstream elegido.
- El perfil corto `wg` es fácil de recordar y consistente con perfiles cortos existentes (`le`).
- Los targets dedicados evitan forzar al usuario a recordar `COMPOSE_PROFILES=wg ...`.

### 2. Exposure Model (UI + Tunnel)

- UI de administración:
- Se expone solo por Traefik mediante labels Docker.
- Hostname por defecto: `wg.${DEV_DOMAIN}` (configurable vía `WG_UI_HOSTNAME`).
- No se publica el puerto web de `wg-easy` en el host (`51821/tcp` u otro puerto UI).

- Túnel WireGuard:
- Se publica un único puerto UDP al host (`WG_SERVER_PORT`, default `51820`).
- El bind address de host se hará configurable (`WG_BIND_ADDRESS`) con una política explícita de exposición no-local (guardrail + override).
- El endpoint anunciado a clientes se configura por `.env` (`WG_SERVER_ENDPOINT`, default `wg.${DEV_DOMAIN}`).

Rationale:
- Mantiene un modelo coherente con el resto del stack (UIs detrás de Traefik).
- Reduce superficie de exposición (sin UI TCP directa).
- Permite usar el mismo FQDN para UI y endpoint WireGuard (HTTPS + UDP en puertos distintos).

Decision:
- Mantener una política de exposición explícita del puerto UDP similar al enfoque de BIND:
- `WG_BIND_ADDRESS` configurable;
- guardrail para detectar exposición no-loopback sin confirmación explícita (`WG_ALLOW_NONLOCAL_BIND=true`, nombre final a fijar en implementación).

Rationale:
- Hace visible cuándo el operador está exponiendo realmente un endpoint VPN fuera del host.
- Alinea la postura de seguridad del módulo con las guardrails existentes del proyecto.

### 2b. TLS Mode Compatibility for WireGuard UI

Decision:
- El router HTTPS de `wg-easy` deberá usar la misma convención que los servicios existentes:
- `traefik.http.routers.<name>.tls=true`
- `traefik.http.routers.<name>.tls.certresolver=${TLS_CERT_RESOLVER:-}`

Rationale:
- Mantiene compatibilidad con Mode A (resolver vacío + certs file), Mode B (LE) y Mode C (step-ca) sin lógica especial por servicio.

### 3. Project-Facing Env Contract (proposed)

Variables mínimas (proyecto) para routing/exposición y defaults seguros:
- `WG_EASY_IMAGE` (imagen pinneada; confirmar tag estable en implementación)
- `WG_UI_HOSTNAME` (default `wg`)
- `WG_SERVER_ENDPOINT` (default `wg.${DEV_DOMAIN}`)
- `WG_SERVER_PORT` (default `51820`)
- `WG_BIND_ADDRESS` (default/strategy to be defined in implementation with security guardrail; likely loopback-first or explicit opt-in for non-local bind)
- `WG_ALLOW_NONLOCAL_BIND` (explicit override flag if non-loopback bind is configured)
- `WG_UI_MIDDLEWARES` (default `security-headers@file`)
- `WG_INSECURE` (default `false`; no usar reverse-proxyless)

Variables opcionales (passthrough a `wg-easy`, sujetas a verificación con docs upstream en implementación):
- DNS por defecto para clientes
- rangos / allowed IPs
- parámetros de MTU / keepalive
- variables de autenticación/admin inicial (nombres exactos a confirmar según versión pinneada), representadas como entradas `WG_*` en `.env.example` y rellenadas por `make wg-bootstrap`

Rationale:
- Separa contrato del proyecto (estable, legible) del contrato interno de la imagen upstream (más cambiante).
- Reduce acoplamiento a cambios de `wg-easy`.

Implementation note for future agent:
- Antes de tocar `services/wg-easy/compose.yml`, revisar el ejemplo upstream de la versión pinneada y fijar el mapeo exacto de variables (especialmente auth).
- Dejar explícito (en compose + docs) cómo se mapea `TLS_CERT_RESOLVER` al router de Traefik para `wg-easy`.

### 3b. Auth Bootstrap / Secret Handling Decision

Decision:
- La credencial inicial de administración de `wg-easy` se gestionará vía `.env` usando variables `WG_*` documentadas (nombres exactos definidos tras validar la versión pinneada).
- Se añadirá un flujo dedicado `make wg-bootstrap` que rellene esas variables en `.env` cuando estén vacías.
- El comportamiento será idempotente por defecto (no sobrescribir valores existentes sin acción explícita de rotación/force).
- La documentación deberá incluir el procedimiento de rotación de credenciales y el impacto en estado persistido si aplica.

Rationale:
- Hace explícito el onboarding de admin sin depender del primer arranque manual de la UI.
- Mantiene consistencia con la política del proyecto de persistir secretos operativos en `.env`.
- Evita cargar `make bootstrap` general con lógica específica de un perfil opcional que puede no usarse.

### 4. Runtime Privileges and Host Prerequisites

El módulo WireGuard requiere privilegios/capacidades del host (según docs upstream y entorno):
- capacidades de red (p. ej. `NET_ADMIN`)
- acceso a TUN (`/dev/net/tun`)
- sysctls para forwarding/marcas si aplica
- en algunos hosts, módulos/kernel adicionales

Decision:
- Mantener privilegios mínimos necesarios (no `privileged: true` por defecto).
- Documentar prerequisitos host en el README del servicio y troubleshooting.
- Mantener el perfil `wg` deshabilitado por defecto para evitar fallos en bootstrap de entornos sin soporte WireGuard.

### 5. Persistence Strategy

- Persistencia local del servicio bajo `services/wg-easy/` (p. ej. `services/wg-easy/data/`).
- Añadir exclusiones en `.gitignore` para estado y secretos generados por `wg-easy`.
- Mantener `README` del servicio con ubicación exacta de datos, puertos y advertencias.

Rationale:
- Consistencia con el patrón del repo (`step-ca`, `traefik`, `dns-bind`).
- Transparencia operativa para backup/inspección local.

### 6. Guardrails (Preflight Validation)

Extender `scripts/validate-env.sh` para cuando `COMPOSE_PROFILES` incluya `wg`:
- validar `WG_SERVER_PORT` como entero (1-65535)
- validar política de exposición de `WG_BIND_ADDRESS` (si no es loopback, exigir override explícito)
- validar `WG_UI_HOSTNAME` como label DNS simple (sin espacios ni caracteres inválidos)
- validar `WG_SERVER_ENDPOINT` no vacío (hostname/IP explícito)
- rechazar `WG_INSECURE=true` (o valor equivalente) por defecto en esta integración

Rationale:
- Evita errores y exposiciones inseguras antes de invocar Docker Compose.
- Mantiene el patrón de guardrails ya usado para dashboard y BIND.

### 7. Test Strategy (Static + Guardrails Only)

Se añaden tests a `make test` que no dependan del runtime WireGuard:
- `test_wg_easy_service_config.sh`
- valida profile `wg`, labels Traefik, exposición UDP, ausencia de puerto UI TCP host, mounts/capacidades esperadas.
- `test_wg_guardrails.sh`
- valida rechazo de configuraciones inválidas/inseguras por `scripts/validate-env.sh`.
- `test_wg_make_targets.sh`
- valida presencia de targets `wg-*` y uso de `scripts/compose.sh --profile wg` con scope del servicio.
- `test_wg_bootstrap_env.sh`
- valida wiring de `make wg-bootstrap` / script asociado para rellenar variables `WG_*` en `.env` de prueba y comportamiento idempotente básico.

No se añade test runtime del túnel:
- demasiado dependiente del host (kernel, TUN, permisos, iptables/nft, rootless vs rootful).

## Security Coverage Checklist (for implementation review)

La implementación deberá cubrir estas perspectivas de seguridad, no solo "funcionar":

- Exposición:
- UI por Traefik/HTTPS y sin puerto TCP de UI publicado al host.
- Puerto UDP WireGuard explícito y configurable.

- Contenedor:
- capacidades mínimas necesarias;
- evitar `privileged: true` salvo justificación fuerte;
- mounts limitados a TUN/config/estado requeridos.

- Configuración:
- guardrails de preflight para puerto, hostname, endpoint y modo inseguro;
- mensajes de error accionables.

- Secretos/estado:
- bootstrap de admin vía `.env` con flujo dedicado `make wg-bootstrap`;
- no sobrescribir credenciales existentes por defecto (idempotencia);
- persistencia documentada;
- rutas ignoradas por git;
- no introducir secretos hardcodeados en compose/docs.

- Operación:
- prerequisitos host documentados (TUN, sysctls, kernel/modulos);
- troubleshooting de fallos de arranque por capabilities/TUN.

### 8. Documentation Integration

Cambios documentales planeados:
- `README*.md`: endpoint WireGuard UI + nota del endpoint UDP; sección servicios; operaciones (`wg-*` targets); troubleshooting básico.
- `README*.md`: endpoint WireGuard UI + nota del endpoint UDP; sección servicios; operaciones (`wg-*` + `wg-bootstrap`); troubleshooting básico.
- `services/wg-easy/README*.md`: run/config/ports/security/troubleshooting/related (mismo esquema de anchors).
- `docs.manifest.json`: registrar nuevo servicio `wg-easy`.
- `tests/README.md`: inventario y troubleshooting de tests WireGuard.
- `scripts/README.md`: inventario/workflows con `wg-*` y preflight/guardrails de variables `WG_*`.

Decision:
- Incluir deltas OpenSpec explícitas también para documentación del proyecto (no solo endpoints/tests).

Rationale:
- Hace visible en revisión que la implementación debe actualizar la documentación raíz, multilenguaje y runbooks operativos, en lugar de dejarlo implícito en tareas.

## Risks / Trade-offs

- Riesgo: `wg-easy` cambia variables o comportamiento entre releases.
- Mitigación: pin de imagen + verificación de contrato upstream antes de implementar.

- Riesgo: usuarios asumen que `make up` inicia VPN.
- Mitigación: perfil `wg` explícito y documentación clara (`COMPOSE_PROFILES=wg` o `make wg-up`).

- Riesgo: hosts sin soporte WireGuard/TUN fallan al arrancar el perfil.
- Mitigación: prerequisitos documentados y no habilitar por defecto.

- Riesgo: doble capa de seguridad confusa (Traefik + auth propia de `wg-easy`).
- Mitigación: documentar que la UI queda protegida por TLS/Traefik y usar auth nativa de `wg-easy` según versión; evitar `INSECURE`.

## Suggested File Touch Order (for implementation agent)

1. Verificar docs upstream y fijar tag/variables `wg-easy`.
2. Crear `services/wg-easy/compose.yml`.
3. Añadir el compose fragment en `scripts/compose.sh` y `Makefile`.
4. Añadir targets `wg-*` en `Makefile`.
5. Añadir flujo `wg-bootstrap` (script + Make target) y fijar el mapeo exacto de variables `WG_*` de auth según upstream pinneado.
6. Extender `.env.example` y `scripts/validate-env.sh` (incluyendo guardrail de bind address + compatibilidad TLS resolver).
7. Añadir `.gitignore` para datos/secrets de `wg-easy`.
8. Crear `services/wg-easy/README*.md` y registrar en `docs.manifest.json`.
9. Actualizar `README*.md` y `scripts/README.md` (endpoints/servicios/operaciones/troubleshooting/preflight/wg-bootstrap).
10. Añadir smoke tests + integrar en `scripts/healthcheck.sh` + inventario en `tests/README.md` (incluyendo wiring `Makefile` y `wg-bootstrap`).
11. Ejecutar validaciones (`make docs-check`, smoke tests relevantes, `openspec validate ... --strict`).

## Validation Plan (post-implementation)

- `openspec validate add-wireguard-wg-easy-module --strict`
- `make docs-check`
- `tests/smoke/test_wg_easy_service_config.sh`
- `tests/smoke/test_wg_guardrails.sh`
- `tests/smoke/test_wg_make_targets.sh`
- `tests/smoke/test_wg_bootstrap_env.sh`
- `make test` (confirmar integración del inventario y orden de ejecución)
- validación manual del router `wg-easy` en Mode A y al menos un modo ACME (B o C) para confirmar wiring de `TLS_CERT_RESOLVER`
- validación manual de `make wg-bootstrap` (rellena `.env` sin sobrescribir por defecto; rotación explícita si se implementa)
- Validación manual opcional:
- `make wg-up`
- `curl -vk https://wg.${DEV_DOMAIN}` (o hostname configurado)
- verificación de `docker compose ps` y de publicación UDP del puerto WireGuard
