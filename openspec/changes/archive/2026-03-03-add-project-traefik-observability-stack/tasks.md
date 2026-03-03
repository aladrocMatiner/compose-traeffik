## 1. OpenSpec Contract

- [x] 1.1 Confirmar `traefik-observability` como proyecto soportado en el catálogo.
- [x] 1.2 Confirmar dependencias del proyecto: `traefik-stepca` y `traefik-keycloak`.
- [x] 1.3 Confirmar política TLS: default StepCA ACME con override explícito soportado.
- [x] 1.4 Validar artefactos del cambio con `openspec validate add-project-traefik-observability-stack --strict`.

## 2. Project Definition

- [x] 2.1 Crear estructura `deployment/projects/traefik-observability/`.
- [x] 2.2 Definir manifiesto (`id`, `description`, `repo_url`, `repo_ref`, `compose_profile`, `services`, `required_env`, `depends_on_projects`, `tls_mode`, `public_host` opcional).
- [x] 2.3 Registrar `traefik-observability` en el catálogo para `deployment-project-list`.

## 3. Deployment Behavior

- [x] 3.1 Implementar tasks Ansible para sync de `compose-traeffik` en la VM.
- [x] 3.2 Ejecutar compose para servicios del proyecto de observabilidad (según manifiesto).
- [x] 3.3 Aplicar `tls_mode=stepca-acme` por defecto.
- [x] 3.4 Permitir override explícito de `tls_mode` con validación de valores soportados.
- [x] 3.5 Integrar configuración de autenticación vía Keycloak según contrato de proyecto.
- [x] 3.6 Garantizar idempotencia razonable del flujo de proyecto.
- [x] 3.7 Asegurar que los endpoints web del stack se publican detrás de Traefik y que la terminación TLS la gestiona Traefik según `tls_mode`.

## 4. Guardrails, Documentation and Testing

- [x] 4.1 Validar variables requeridas del proyecto antes de `docker compose up -d`.
- [x] 4.2 Añadir guardrails para dependencias faltantes (`traefik-stepca`, `traefik-keycloak`).
- [x] 4.3 Documentar ejecución de `project=traefik-observability` y override de TLS.
- [x] 4.4 Añadir tests de wiring del catálogo y contrato TLS/auth/dependencias.
- [x] 4.5 Evitar overrides ad-hoc de servicios fuera del manifiesto del proyecto.

## 5. Validation and Handoff

- [x] 5.1 Re-ejecutar `openspec validate add-project-traefik-observability-stack --strict`.
- [x] 5.2 Revisar coherencia final entre proposal, tasks y spec delta.
