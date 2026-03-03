## 1. Baseline Hardening (Pass 1)

- [x] 1.1 Endurecer `named.conf.template` para modo autoritativo local (`recursion no`, `allow-transfer { none; }`, `allow-update { none; }`).
- [x] 1.2 Reducir fingerprinting DNS (`version`, `hostname`, `server-id`) con valores no divulgados.
- [x] 1.3 Verificar listeners mínimos (solo `BIND_BIND_ADDRESS` + puerto 53 TCP/UDP) y mantener bloqueo de IPv6 si no se usa.
- [x] 1.4 Mantener política de permisos segura para zona/config (`scripts/bind-provision.sh` y rutas montadas).

## 2. Runtime and Compose Hardening (Pass 1)

- [x] 2.1 Revisar y aplicar endurecimiento de contenedor BIND (`no-new-privileges`, capacidades mínimas, escritura solo donde sea necesario).
- [x] 2.2 Asegurar que el arranque valida configuración antes de ejecutar `named` (`named-checkconf` y, si aplica, `named-checkzone`).
- [x] 2.3 Revisar segmentación de red del servicio DNS para minimizar exposición lateral entre servicios.

## 3. Guardrails and Input Validation (Pass 1)

- [x] 3.1 Añadir validación en preflight para `BIND_BIND_ADDRESS` inseguro (ej. wildcard/public) salvo override explícito.
- [x] 3.2 Añadir validación de `BASE_DOMAIN` y sanitización de labels en generación de zonas.
- [x] 3.3 Definir y validar un flag explícito para permitir exposición no-local cuando sea intencional.

## 4. Security Smoke Tests (Pass 1)

- [x] 4.1 Crear smoke test de no-recursión (consulta externa debe fallar/refused).
- [x] 4.2 Crear smoke test de AXFR denegado para la zona autoritativa.
- [x] 4.3 Crear smoke test de ocultación de metadata (`version.bind`, `hostname.bind`, `id.server` en clase CHAOS).
- [x] 4.4 Crear smoke test de exposición/listening esperado (sin listeners DNS fuera del scope configurado).
- [x] 4.5 Crear smoke test de permisos de ficheros críticos (zona/config no world-writable).
- [x] 4.6 Integrar los tests en `scripts/healthcheck.sh` y en la tabla de `tests/README.md`.

## 5. Second Review Additions (Pass 2)

- [x] 5.1 Añadir pruebas negativas para configuraciones maliciosas o inválidas (dominio inválido, endpoint inválido, bind address inseguro).
- [x] 5.2 Añadir checklist de rollback seguro ante hardening fallido (restaurar servicio sin abrir exposición).
- [x] 5.3 Verificar que los cambios no rompen flujo actual (`make up`, `make bind-up`, `make test`, `make docs-check`).

## 6. Documentation and Operational Runbook (Pass 2)

- [x] 6.1 Actualizar `docs/06-howto/service-dns-bind.md` con sección de hardening y comandos de verificación.
- [x] 6.2 Actualizar `scripts/README.md` y `tests/README.md` con señales de fallo de seguridad y troubleshooting.
- [x] 6.3 Añadir resumen en README raíz sobre postura de seguridad DNS en esta rama.

## 7. Validation Gate

- [x] 7.1 Validar artefactos OpenSpec: `openspec validate harden-bind-dns-security --strict`.
- [x] 7.2 Ejecutar validación final de cambios: `make test`, `make docs-check`, y comprobaciones manuales `dig` (no-recursión/AXFR/CHAOS).
