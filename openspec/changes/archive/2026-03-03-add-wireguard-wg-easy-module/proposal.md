## Why

El proyecto ya tiene una base sólida para edge/local dev (`Traefik + TLS + perfiles opcionales`), pero no dispone de un módulo VPN administrable para acceso remoto o laboratorio. Añadir un servidor WireGuard con UI simplifica operación y pruebas sin romper el flujo actual de Docker Compose.

`wg-easy` encaja con el stack actual porque:
- funciona bien en Docker Compose;
- expone una UI web administrable detrás de reverse proxy;
- permite alta de clientes y exportación de configs/QR sin scripts extra;
- se integra de forma natural con Traefik y el patrón de servicios `services/<service>/compose.yml`.

## What Changes

- Añadir un módulo opcional WireGuard basado en `wg-easy` con perfil `wg`.
- Exponer la UI de administración vía Traefik (HTTPS) usando hostname dedicado (`wg.<DEV_DOMAIN>` por defecto).
- Exponer el puerto UDP de WireGuard de forma configurable (`WG_SERVER_PORT`, default `51820`) sin publicar el puerto TCP de la UI al host.
- Definir una política explícita de exposición del puerto UDP (bind address configurable y guardrail para exposición no-local intencional) alineada con el enfoque de hardening del proyecto.
- Incorporar persistencia del estado del servidor en `services/wg-easy/` y reglas de `.gitignore` para evitar commits accidentales de secretos/configs.
- Añadir variables de entorno y documentación operativa para activar el perfil, mapear hosts locales y usar el módulo de forma segura.
- Definir variables de bootstrap de autenticación/admin de WireGuard en `.env` y un target `make wg-bootstrap` que rellene esas variables de forma idempotente por defecto.
- Integrar la UI WireGuard con el patrón TLS existente del proyecto (Mode A/B/C) usando la misma lógica de `TLS_CERT_RESOLVER`.
- Añadir guardrails de preflight para detectar configuraciones inseguras o inválidas del perfil `wg`.
- Añadir smoke tests estáticos/guardrails y un test de wiring de `Makefile` (sin prueba runtime del túnel) e inventario en `tests/README.md`.
- Añadir targets Make para ciclo de vida del módulo (`wg-up`, `wg-down`, `wg-restart`, `wg-logs`, `wg-status`) reutilizando el compose wrapper existente.
- Añadir target `make wg-bootstrap` para bootstrap/rotación controlada de variables `WG_*` en `.env` (según contrato upstream pinneado).
- Formalizar baseline de seguridad del servicio (UI detrás de Traefik/TLS, sin `privileged: true` por defecto, capacidades mínimas y documentación de prerequisitos host).

## Capabilities

### New Capabilities

- `wireguard-wg-easy-service`: módulo WireGuard opcional con UI HTTPS detrás de Traefik, puerto UDP configurable y persistencia local.

### Modified Capabilities

- `compose-wrapper`: formalizar que targets `wg-*` usan el compose wrapper determinístico con profile/scope explícitos.
- `bootstrap-secrets`: persistencia e idempotencia de credenciales de bootstrap WireGuard en `.env` mediante `make wg-bootstrap`.
- `guardrails`: validaciones de preflight para configuración del perfil `wg`.
- `docs-endpoints-tls`: documentación de endpoints para incluir UI WireGuard (HTTPS) y endpoint WireGuard (UDP) con notas de perfil/seguridad.
- `docs-multilang`: paridad estructural EN/SV/ES y registro del nuevo servicio en el manifiesto de documentación.
- `scripts-docs`: actualizar inventario de scripts/workflows y preflight docs con el módulo WireGuard.
- `tests-docs`: actualizar runbook de `tests/README.md` con pruebas WireGuard y troubleshooting asociado.
- `tests-suite`: inventario de smoke tests actualizado con checks de WireGuard (config/guardrails).

## Impact

- Affected code (planned):
- `services/wg-easy/compose.yml` (nuevo)
- `services/wg-easy/README.md` (nuevo)
- `services/wg-easy/README.sv.md` (nuevo)
- `services/wg-easy/README.es.md` (nuevo)
- `Makefile`
- `scripts/compose.sh`
- `scripts/validate-env.sh`
- `scripts/wg-bootstrap.sh` (nuevo)
- `.env.example`
- `.gitignore`
- `scripts/healthcheck.sh`
- `tests/smoke/test_wg_easy_service_config.sh` (nuevo)
- `tests/smoke/test_wg_guardrails.sh` (nuevo)
- `tests/smoke/test_wg_make_targets.sh` (nuevo)
- `tests/smoke/test_wg_bootstrap_env.sh` (nuevo)
- `tests/README.md`
- `scripts/README.md`
- `README.md`
- `README.sv.md`
- `README.es.md`
- `docs.manifest.json`

- Affected infrastructure behavior (planned):
- nuevo perfil opcional `wg` (no habilitado por defecto en `make bootstrap`);
- nuevo endpoint de UI `https://wg.<DEV_DOMAIN>` (o hostname configurable);
- nuevo puerto UDP WireGuard configurable en host.
- nuevo flujo `make wg-bootstrap` para rellenar variables de bootstrap/admin `WG_*` en `.env` (idempotente por defecto).
- integración TLS del router `wg-easy` con la variable compartida `TLS_CERT_RESOLVER` para mantener compatibilidad con Modes A/B/C.
- onboarding/auth inicial definido como env-managed (`WG_*` en `.env`) con procedimiento documentado y rotación explícita.

## Out of Scope

- No se implementa SSO/OIDC, RBAC ni gestión enterprise multiusuario.
- No se añaden pruebas runtime del túnel WireGuard dentro de `make test` (dependen de kernel/capacidades del host y aumentan fragilidad).
- No se automatiza todavía el aprovisionamiento masivo de clientes fuera de la UI de `wg-easy`.
- No se cambia la política actual de perfiles por defecto de `make bootstrap` salvo que se documente explícitamente tras validación técnica.
- No se integra la generación de credenciales WireGuard en `make bootstrap` general en esta change; se usará `make wg-bootstrap` como flujo dedicado para evitar activar lógica específica de WireGuard en setups sin ese módulo.
