## Context

El flujo actual ya despliega Keycloak y proyectos dependientes, pero la integración OIDC no está estandarizada para escalar a múltiples proyectos. Se requiere una arquitectura simple para entorno de laboratorio que minimice trabajo manual y mantenga comportamiento idempotente.

## Goals / Non-Goals

- Goals:
  - Unificar autenticación en un realm compartido `local.test`.
  - Garantizar usuario inicial disponible tras desplegar `traefik-keycloak`.
  - Permitir que cada proyecto configure su cliente OIDC de forma reproducible durante su deploy.
  - Evitar preconfigurar todos los clientes futuros.
- Non-Goals:
  - Hardening de credenciales enterprise-grade en esta iteración.
  - Multi-realm por tenant/entorno.
  - Gestión avanzada de políticas/roles por aplicación.

## Decisions

- Decision: Usar realm único `local.test` para SSO transversal.
  - Rationale: mismo usuario/sesión en todos los sistemas con menor complejidad operativa.

- Decision: Bootstrap de usuario inicial en `traefik-keycloak` (`jose.romero` / `abcd123` por default, override permitido).
  - Rationale: validación inmediata del flujo sin pasos manuales.

- Decision: Cada proyecto crea/actualiza su cliente OIDC durante su ansible de despliegue.
  - Rationale: acopla el cliente al ciclo de vida real del proyecto y evita mantener un inventario global de clientes no usados.

- Decision: No precrear clientes de proyectos no desplegados.
  - Rationale: reduce drift, reduce superficie operativa, y evita configuración muerta.

- Decision: Integraciones web deben priorizar OIDC nativo de la aplicación cuando exista soporte.
  - Rationale: evita patrones frágiles de forwardAuth genérico contra endpoints no diseñados para ello.

## Data/Contract Sketch

- Keycloak bootstrap vars (proyecto `traefik-keycloak`):
  - `KEYCLOAK_BOOTSTRAP_REALM` (default `local.test`)
  - `KEYCLOAK_BOOTSTRAP_USERNAME` (default `jose.romero`)
  - `KEYCLOAK_BOOTSTRAP_PASSWORD` (default `abcd123`)

- OIDC project contract (manifest or project vars derivadas):
  - `keycloak_realm`
  - `oidc_client_id`
  - `oidc_redirect_uris[]`
  - `oidc_web_origins[]`
  - `oidc_scopes`

## Workflow

1. Deploy `traefik-keycloak`:
   - asegurar realm `local.test`
   - asegurar usuario bootstrap
2. Deploy project with OIDC:
   - validar dependencia Keycloak
   - create/update cliente OIDC en Keycloak
   - inyectar `client_id/client_secret/endpoints` en `.env` del proyecto
   - aplicar compose y validar login path

## Risks / Trade-offs

- Riesgo: credenciales bootstrap estáticas por defecto.
  - Mitigación: permitir override por variables y recomendar rotación post-bootstrap.
- Riesgo: permisos amplios para gestión de clientes durante despliegue.
  - Mitigación: acotar comandos al realm objetivo y evolucionar a service account mínimo en iteración posterior.
- Riesgo: inconsistencias entre proyectos si no usan contrato OIDC común.
  - Mitigación: contrato explícito en OpenSpec y checks en manifiestos/tests.

## Migration Plan

- Introducir bootstrap de realm/usuario en `traefik-keycloak` sin romper despliegues existentes.
- Migrar proyecto por proyecto al contrato OIDC común (empezando por `traefik-observability`).
- Mantener compatibilidad temporal con configuración previa hasta completar migración.

## Open Questions

- ¿Forzar `UPDATE_PASSWORD` al primer login del usuario bootstrap por defecto?
- ¿Definir naming convention estricta para `client_id` (ej. igual al `project-id`)?
- ¿Cuándo mover secretos a `ansible-vault` como baseline obligatorio?
