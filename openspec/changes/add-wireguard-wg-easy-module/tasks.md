## 0. Approval Gate

- [ ] 0.1 Obtener aprobación de esta propuesta OpenSpec antes de implementar cambios de código.
- [ ] 0.2 Leer `proposal.md` y `design.md` completos antes de tocar `compose`, `Makefile`, scripts o docs.

## 1. Upstream Contract Snapshot (Required before coding)

- [ ] 1.1 Revisar la documentación oficial de `wg-easy` para la versión a usar y elegir un tag pinneado estable (no `latest`).
- [ ] 1.2 Confirmar variables de entorno soportadas por esa versión (especialmente autenticación/admin inicial, endpoint/host y puerto UDP).
- [ ] 1.2.1 Confirmar el mapeo exacto de variables de auth/admin para la versión pinneada y fijar las entradas `WG_*` que vivirán en `.env.example`.
- [ ] 1.3 Documentar (en comentarios del compose o en el README del servicio) cualquier prerrequisito host obligatorio (`/dev/net/tun`, sysctls, capacidades).
- [ ] 1.4 Ajustar el diseño de mapeo de variables del proyecto si el upstream cambió nombres o semántica.

## 2. Service Scaffold and Compose Layering

- [ ] 2.1 Crear `services/wg-easy/compose.yml` con servicio `wg-easy` y perfil `wg`.
- [ ] 2.2 Añadir labels de Traefik para la UI HTTPS con hostname configurable por `.env`.
- [ ] 2.2.1 Usar `TLS_CERT_RESOLVER` en el router `wg-easy` con el mismo patrón de los servicios actuales para compatibilidad Mode A/B/C.
- [ ] 2.3 Configurar exposición del puerto UDP WireGuard mediante variable `WG_SERVER_PORT` (host) y puerto de contenedor correspondiente.
- [ ] 2.3.1 Configurar bind address del puerto UDP con variable dedicada (por ejemplo `WG_BIND_ADDRESS`) y política de exposición explícita.
- [ ] 2.4 Verificar que no se publica ningún puerto TCP de UI al host.
- [ ] 2.5 Adjuntar el servicio a la red `proxy` para routing de Traefik.
- [ ] 2.6 Configurar mounts y capacidades mínimas necesarias para WireGuard (sin `privileged: true` por defecto).
- [ ] 2.7 Definir persistencia local en `services/wg-easy/` y rutas consistentes con la imagen elegida.
- [ ] 2.8 Añadir `services/wg-easy/compose.yml` a la lista de compose fragments en `scripts/compose.sh`.
- [ ] 2.9 Añadir `services/wg-easy/compose.yml` a `COMPOSE_FILES` en `Makefile`.
- [ ] 2.10 Verificar explícitamente en el compose del servicio que la UI web no queda expuesta por TCP host y que solo el puerto UDP WireGuard se publica.

## 3. Make Lifecycle and Bootstrap Interface

- [ ] 3.1 Añadir targets `wg-up`, `wg-down`, `wg-restart`, `wg-logs`, `wg-status` y `wg-bootstrap` a `Makefile`.
- [ ] 3.2 Asegurar que los targets usan `scripts/compose.sh` y perfil `wg` (patrón equivalente a `bind-*`).
- [ ] 3.3 Añadir entradas de ayuda en `make help` para los nuevos targets.
- [ ] 3.4 Verificar que los targets quedan acotados al servicio `wg-easy` (sin afectar otros servicios).
- [ ] 3.5 Implementar `scripts/wg-bootstrap.sh` (o equivalente documentado) para rellenar variables `WG_*` en `.env`.
- [ ] 3.6 Hacer `make wg-bootstrap` idempotente por defecto: rellenar vacíos y no sobrescribir credenciales existentes sin flag explícito de rotación/force.
- [ ] 3.7 Definir comportamiento cuando falta `.env` (fallar con mensaje que indique `make bootstrap` o crear `.env` de forma controlada) y documentarlo.

## 4. Env Contract and Guardrails

- [ ] 4.1 Añadir variables `WG_*` en `.env.example` con comentarios claros de uso, defaults y seguridad.
- [ ] 4.2 Mantener `COMPOSE_PROFILES` sin activar `wg` por defecto (salvo decisión explícita revisada y documentada).
- [ ] 4.3 Extender `scripts/validate-env.sh` para detectar si `wg` está presente en `COMPOSE_PROFILES`.
- [ ] 4.4 Validar `WG_SERVER_PORT` (entero en rango 1-65535) cuando el perfil `wg` esté activo.
- [ ] 4.4.1 Validar `WG_BIND_ADDRESS` (IPv4 loopback/non-loopback según política definida) y requerir override explícito para exposición no-local.
- [ ] 4.5 Validar `WG_UI_HOSTNAME` como label DNS válido (sin espacios/uppercase/caracteres no permitidos).
- [ ] 4.6 Validar `WG_SERVER_ENDPOINT` no vacío (hostname/IP explícito).
- [ ] 4.7 Rechazar `WG_INSECURE=true` (o equivalente inseguro) en integración con Traefik.
- [ ] 4.8 Añadir mensajes de error accionables (qué variable corregir y ejemplo).
- [ ] 4.9 Verificar que los guardrails solo se aplican al perfil `wg` y no rompen `make up` sin `wg`.
- [ ] 4.10 Añadir variables de auth/admin `WG_*` a `.env.example` para el flujo `wg-bootstrap` (nombres exactos según versión pinneada).
- [ ] 4.11 Definir y documentar política de secretos para `wg-bootstrap` (generación, idempotencia, rotación explícita, no impresión de secretos en logs innecesarios).

## 5. Repo Hygiene and Persistence Safety

- [ ] 5.1 Añadir reglas a `.gitignore` para datos/secrets generados bajo `services/wg-easy/` (manteniendo posibles fixtures/documentación trackeados).
- [ ] 5.2 Verificar que la política no oculta los README del servicio.
- [ ] 5.3 Documentar ubicación de datos persistentes y advertencias de backup/secret leakage en el README del servicio.

## 6. Documentation (Multilang + Manifest)

- [ ] 6.1 Crear `services/wg-easy/README.md` siguiendo anchors estándar (`overview`, `location`, `run`, `configuration`, `ports`, `security`, `troubleshooting`, `related`).
- [ ] 6.2 Crear `services/wg-easy/README.sv.md` con la misma estructura/anchors.
- [ ] 6.3 Crear `services/wg-easy/README.es.md` con la misma estructura/anchors.
- [ ] 6.4 Registrar `wg-easy` en `docs.manifest.json` con título multilenguaje.

- [ ] 6.5 Actualizar `README.md`:
- añadir WireGuard en `Endpoints` (UI HTTPS + nota de endpoint UDP/perfil),
- añadir WireGuard en `Services`,
- añadir comandos `wg-*` y `wg-bootstrap` en `Operations`,
- añadir troubleshooting básico (perfil/prerrequisitos host/puerto UDP).
- [ ] 6.6 Actualizar `README.sv.md` con el mismo contenido estructural.
- [ ] 6.7 Actualizar `README.es.md` con el mismo contenido estructural.
- [ ] 6.8 Añadir nota sobre `ENDPOINTS`/hosts mapping para incluir `wg` cuando se use `make hosts-*` (si el flujo documentado lo requiere).
- [ ] 6.9 Documentar claramente prerequisitos host de WireGuard (`/dev/net/tun`, capacidades, sysctls) y límites del soporte en entornos rootless/CI.
- [ ] 6.10 Documentar postura de seguridad de la UI (Traefik/TLS, no reverse-proxyless, auth nativa de `wg-easy` según versión pinneada).
- [ ] 6.11 Actualizar `scripts/README.md` (inventario, preflight guardrails y workflows) para reflejar variables `WG_*`, `wg-*` targets y comportamiento de `scripts/validate-env.sh`.
- [ ] 6.11.1 Documentar en `scripts/README.md` el flujo `make wg-bootstrap`, idempotencia por defecto y rotación de credenciales.
- [ ] 6.12 Verificar discoverability desde `README*.md` hacia `tests/README.md` y `scripts/README.md` se mantiene/queda visible tras añadir el módulo WireGuard.
- [ ] 6.13 Documentar la decisión de onboarding/auth inicial (manual o por `.env`) y el procedimiento de rotación de credenciales administrativas.
- [ ] 6.13 Documentar la decisión de onboarding/auth inicial por `.env` y el procedimiento de `make wg-bootstrap` + rotación de credenciales administrativas.
- [ ] 6.14 Documentar la política de bind address UDP (loopback vs exposición no-local intencional) con ejemplos seguros.

## 7. Smoke Tests and Test Inventory

- [ ] 7.1 Crear `tests/smoke/test_wg_easy_service_config.sh` para validar configuración estática del compose del servicio.
- [ ] 7.2 Validar en ese test: perfil `wg`, labels Traefik, puerto UDP publicado, ausencia de puerto UI TCP host, red `proxy`, mounts/capacidades esperadas.
- [ ] 7.2.1 Validar en ese test el wiring de TLS del router (`tls=true` y `tls.certresolver=${TLS_CERT_RESOLVER:-}` o patrón equivalente del proyecto).
- [ ] 7.3 Crear `tests/smoke/test_wg_guardrails.sh` para validar rechazos de preflight (`WG_SERVER_PORT`, `WG_BIND_ADDRESS`/override, `WG_UI_HOSTNAME`, `WG_SERVER_ENDPOINT`, `WG_INSECURE`).
- [ ] 7.4 Crear `tests/smoke/test_wg_make_targets.sh` para validar wiring de targets `wg-*` en `Makefile`, `PHONY`, ayuda en `make help`, y uso de `scripts/compose.sh --profile wg`.
- [ ] 7.4.1 Crear `tests/smoke/test_wg_bootstrap_env.sh` para validar `wg-bootstrap` sobre `.env` temporal (rellena variables `WG_*`, no sobrescribe por defecto, falla/guía si falta `.env` según diseño).
- [ ] 7.5 Integrar los tests de WireGuard en `scripts/healthcheck.sh` con mensajes de propósito y manejo de exit status.
- [ ] 7.6 Actualizar `tests/README.md` (tabla inventario, configuración, troubleshooting) con los nuevos tests WireGuard, incluyendo `wg-bootstrap`.
- [ ] 7.7 Mantener la suite libre de dependencias runtime WireGuard (sin requerir levantar el túnel).

## 8. Validation and Handoff

- [ ] 8.1 Validar OpenSpec: `openspec validate add-wireguard-wg-easy-module --strict`.
- [ ] 8.2 Validar docs: `make docs-check` (incluyendo nuevo servicio `wg-easy` en `docs.manifest.json` y paridad EN/SV/ES).
- [ ] 8.3 Ejecutar smoke tests nuevos en local y luego `make test`.
- [ ] 8.4 Verificar manualmente `make wg-up` / `make wg-status` / `make wg-down` en un host con soporte WireGuard (si disponible).
- [ ] 8.4.1 Verificar `make wg-bootstrap` sobre `.env` real o copia temporal: rellena variables `WG_*`, es idempotente y la rotación solo ocurre con acción explícita.
- [ ] 8.5 Confirmar que `make up`, `make down`, `make logs`, `make ps` sin perfil `wg` mantienen comportamiento previo (sin levantar `wg-easy`).
- [ ] 8.6 Confirmar que `make help` describe correctamente los targets `wg-*`.
- [ ] 8.6.1 Confirmar que `make help` describe `wg-bootstrap` y su propósito (rellenar/rotar variables `WG_*` en `.env`).
- [ ] 8.7 Verificar manualmente la UI `wg-easy` bajo Mode A y al menos un modo ACME (B o C) para confirmar compatibilidad de `TLS_CERT_RESOLVER` (si el host soporta el perfil `wg`).
- [ ] 8.8 Dejar todas las tareas reales completadas en este archivo (`- [x]`) al terminar implementación.
