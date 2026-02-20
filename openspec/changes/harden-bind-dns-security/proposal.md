## Why

La rama `dns-bind` ya es funcional, pero aún no tiene un contrato OpenSpec específico para hardening de seguridad DNS y pruebas de seguridad continuas. Esto deja huecos de riesgo (configuraciones permisivas, exposición innecesaria, regresiones silenciosas) cuando se hagan cambios futuros en BIND, Compose y documentación.

## Security Objectives

- Reducir superficie de ataque de BIND en entorno local/lab.
- Evitar fugas de información y abuso del resolver.
- Mantener operación reproducible con configuración mínima segura por defecto.
- Añadir tests de seguridad no-sudo para detectar regresiones rápidamente.

## What Changes

- Definir baseline de hardening para BIND en esta rama:
- limitar exposición de puertos y listeners al ámbito esperado;
- mantener recursión desactivada para uso autoritativo local;
- restringir transferencias de zona (`AXFR`) por defecto;
- minimizar fingerprinting (`version`/`hostname`/`server-id` en consultas CHAOS);
- documentar política de permisos de ficheros de zona/config.
- Definir guardrails de configuración para `.env` y compose:
- validar que `BIND_BIND_ADDRESS` no abra DNS fuera del scope previsto sin configuración explícita;
- validar que BIND se ejecute con configuración renderizada segura y rutas controladas.
- Añadir smoke/security tests dedicados:
- test de no recursión;
- test de `AXFR` denegado;
- test de ocultación de versión/metadata;
- test de exposición de puertos/listeners esperados;
- test de permisos y ownership de archivos críticos.
- Alinear documentación operativa y troubleshooting de seguridad:
- guía de hardening DNS;
- checklist de verificación post-cambios;
- matriz de señales esperadas (pass/fail) para tests de seguridad.

## Capabilities

### New Capabilities
- None.

### Modified Capabilities
- `dns-bind-service`: endurecer configuración operativa del servicio BIND.
- `dns-bind-provisioning`: reforzar reglas de generación y permisos de zona.
- `guardrails`: añadir validaciones de seguridad DNS en preflight/config.
- `tests-suite`: incorporar pruebas de seguridad DNS específicas.
- `tests-docs`: documentar comportamiento y troubleshooting de pruebas de seguridad.
- `documentation`: reflejar flujo oficial de hardening y validación de seguridad DNS.

## Impact

- Affected code (planned):
- `services/dns-bind/config/named.conf.template`
- `services/dns-bind/compose.yml`
- `scripts/bind-provision.sh`
- `scripts/validate-env.sh` (si aplica)
- `scripts/healthcheck.sh`
- `tests/smoke/*` (nuevos tests de seguridad DNS)
- Affected docs (planned):
- `docs/06-howto/service-dns-bind.md`
- `tests/README.md`
- `scripts/README.md`
- `README*.md` (resumen de seguridad operativo, si aplica)
- Security validation (planned):
- `make test` debe cubrir seguridad DNS base;
- pruebas manuales de referencia con `dig` para recursión/AXFR/CHAOS;
- checklist de hardening documentado para contributors.

## Out of Scope

- No se introducen controles enterprise (DNSSEC signing, TSIG multi-tenant, RPZ compleja) en este cambio.
- No se cambian topologías de red externas al stack local salvo lo necesario para hardening básico.

