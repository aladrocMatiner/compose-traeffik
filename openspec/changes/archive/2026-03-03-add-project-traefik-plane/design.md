## Context

El flujo `deployment-project` actual ya resuelve contratos complejos por proyecto (TLS mode, dependencias entre proyectos, OIDC en Keycloak y reconciliación post-compose). Plane introduce una topología más grande (frontend, API, workers y dependencias stateful) y necesita conservar el mismo comportamiento determinista.

Además, en el estado actual del repositorio, el servicio Plane vive en otra línea de evolución (master), por lo que el diseño debe blindar el caso en que el `repo_ref` fijado no contenga `services/plane/compose.yml`.

## Goals / Non-Goals

- Goals:
  - Añadir `traefik-plane` al catálogo de `deployment-project` con contrato explícito y validable.
  - Mantener defaults de TLS alineados al resto (`stepca-acme` + override soportado).
  - Reutilizar patrón idempotente de bootstrap OIDC en Keycloak.
  - Encajar observabilidad como dependencia declarada y contrato operacional, sin exposición directa fuera de Traefik.
  - Fallar rápido con mensajes accionables ante precondiciones no satisfechas.
- Non-Goals:
  - Diseñar HA/escalado horizontal de Plane.
  - Construir backup/restore de datos de Plane en este cambio.
  - Reescribir el rol `project_deploy` para generalización completa de OIDC multi-servicio.

## Decisions

- Decision: modelar `traefik-plane` como proyecto de catálogo (no despliegue manual fuera de manifiesto).
  - Why: mantiene consistencia con guardrails existentes (servicios declarados, dependencias, TLS mode).

- Decision: declarar dependencias explícitas `traefik-stepca`, `traefik-keycloak`, `traefik-observability`.
  - Why: la intención queda machine-readable y el preflight de dependencias evita estados parciales.
  - Tradeoff: aumenta el orden de despliegue requerido, pero evita fallos opacos en runtime.

- Decision: usar `stepca-acme` como `tls_mode` por defecto con override explícito.
  - Why: es el baseline ya adoptado por el catálogo y reduce deriva operacional.

- Decision: añadir guardrail de presencia de `services/plane/compose.yml` en `repo_ref` fijado.
  - Why: evita que un `repo_ref` antiguo rompa tarde durante `compose up`.

- Decision: seguir patrón actual de reconciliación OIDC por proyecto (lookup/create/update client + sync secret efectivo).
  - Why: ya está testado para `wikijs`, `semaphoreui`, `rocketchat`, `gitlab` y `litellm`.

## Risks / Trade-offs

- Riesgo: drift entre composición real de Plane y lista de servicios declarados en manifiesto.
  - Mitigación: validar lista exacta esperada en smoke tests de catálogo.

- Riesgo: secretos de Plane/OIDC vacíos o placeholders en `.env`.
  - Mitigación: bootstrap idempotente + asserts explícitos antes de compose apply.

- Riesgo: dependencia de observabilidad desplegada pero no funcional para señales de Plane.
  - Mitigación: checks mínimos de contrato (hosts/env/labels) y documentación de límites.

## Migration Plan

1. Añadir change OpenSpec y validar.
2. Implementar manifest/catalog wiring de `traefik-plane`.
3. Extender `project_deploy` para preflight Plane + OIDC + observabilidad.
4. Actualizar smoke tests del catálogo y contrato OIDC idempotente.
5. Documentar orden recomendado de despliegue incluyendo `traefik-plane`.

## Open Questions

- El cliente OIDC de Plane debe usar un rol realm dedicado (como `litellm_proxy_admin`) o solo login estándar en esta fase.
- Confirmar si se fuerza dependencia dura con `traefik-observability` o se acepta degradación controlada cuando no esté desplegado.
