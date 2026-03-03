## 1. OpenSpec Contract

- [x] 1.1 Confirmar `traefik-harbor` como proyecto soportado en el catálogo.
- [x] 1.2 Confirmar dependencias obligatorias: `traefik-stepca` y `traefik-keycloak`.
- [x] 1.3 Confirmar política TLS: default `stepca-acme` con override explícito soportado.
- [x] 1.4 Confirmar contrato de observabilidad compatible con `traefik-observability` sin dependencia obligatoria por defecto.
- [x] 1.5 Validar artefactos del cambio con `openspec validate add-project-traefik-harbor --strict`.

## 2. Project Definition

- [x] 2.1 Crear estructura `deployment/projects/traefik-harbor/`.
- [x] 2.2 Definir manifiesto (`id`, `description`, `repo_url`, `repo_ref`, `compose_profile`, `services`, `required_env`, `depends_on_projects`, `tls_mode`, `public_host` opcional).
- [x] 2.3 Incluir variables requeridas para contrato de auth (Keycloak) y observabilidad (cuando esté habilitada).
- [x] 2.4 Registrar `traefik-harbor` en el catálogo para `deployment-project-list`.

## 3. Deployment Behavior

- [x] 3.1 Implementar tasks Ansible para sync de `compose-traeffik` en la VM.
- [x] 3.2 Ejecutar compose para servicios del proyecto Harbor (según manifiesto).
- [x] 3.3 Aplicar `tls_mode=stepca-acme` por defecto.
- [x] 3.4 Permitir override explícito de `tls_mode` con validación de valores soportados.
- [x] 3.5 Integrar configuración de autenticación Harbor-Keycloak según contrato de proyecto.
- [x] 3.6 Integrar wiring de observabilidad de Harbor/Traefik según contrato del manifiesto.
- [x] 3.7 Garantizar idempotencia razonable del flujo de proyecto.
- [x] 3.8 Asegurar que Harbor se publica detrás de Traefik y que la terminación TLS la gestiona Traefik según `tls_mode`.

## 4. Guardrails, Documentation and Testing

- [x] 4.1 Validar variables requeridas del proyecto antes de `docker compose up -d`.
- [x] 4.2 Añadir guardrails para dependencias faltantes (`traefik-stepca`, `traefik-keycloak`).
- [x] 4.3 Añadir guardrail para fallar con mensaje claro si se habilita integración de observabilidad y faltan variables requeridas.
- [x] 4.4 Documentar ejecución de `project=traefik-harbor` y overrides de TLS/auth/observabilidad.
- [x] 4.5 Añadir tests de wiring del catálogo y contrato TLS/auth/observabilidad/dependencias.
- [x] 4.6 Evitar overrides ad-hoc de servicios fuera del manifiesto del proyecto.

## 5. Validation and Handoff

- [x] 5.1 Re-ejecutar `openspec validate add-project-traefik-harbor --strict`.
- [x] 5.2 Revisar coherencia final entre proposal, tasks y spec delta.
