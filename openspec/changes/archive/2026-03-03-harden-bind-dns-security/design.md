## Context

El stack DNS en `dns-bind` ya funciona, pero sin un baseline formal de hardening es fácil introducir regresiones de seguridad: exposición accidental de listeners, respuestas recursivas no deseadas, transferencias de zona abiertas o filtración de metadata.

## Goals / Non-Goals

- Goals:
- Establecer defaults seguros para BIND en entorno local/lab.
- Añadir validaciones preventivas (guardrails) antes de ejecutar compose.
- Añadir smoke tests de seguridad DNS ejecutables en CI/local.
- Documentar verificación y rollback para operación segura.
- Non-Goals:
- No introducir DNSSEC autoritativo completo ni TSIG avanzado.
- No rediseñar topología de red global del proyecto.

## Decisions

- Decision: Mantener BIND en modo autoritativo local con `recursion no` y `allow-transfer { none; }`.
- Rationale: reduce abuso como resolver abierto y fuga por AXFR.

- Decision: Exigir loopback por defecto en `BIND_BIND_ADDRESS`, con override explícito `BIND_ALLOW_NONLOCAL_BIND=true`.
- Rationale: evita exposición involuntaria de DNS al exterior.

- Decision: Validar configuración/zonas antes del arranque (`named-checkconf`, `named-checkzone`).
- Rationale: falla temprano ante errores de configuración y evita estado parcialmente inseguro.

- Decision: Añadir pruebas de seguridad DNS dedicadas a runtime y validación de inputs.
- Rationale: detectar regresiones rápidamente con señales pass/fail claras.

## Risks / Trade-offs

- Riesgo: hardening puede romper setups que dependían de comportamientos permisivos.
- Mitigación: flag de override explícito y runbook de rollback.

- Riesgo: pruebas runtime de seguridad añaden tiempo al `make test`.
- Mitigación: se ejecutan con binding loopback dedicado y cleanup automático.

## Migration Plan

1. Aplicar hardening en `named.conf.template`, compose y guardrails.
2. Añadir smoke tests de seguridad DNS e integrarlos en `scripts/healthcheck.sh`.
3. Actualizar documentación operativa y troubleshooting.
4. Validar con `make test`, `make docs-check` y `openspec validate --strict`.

