## 1. OpenSpec Contract

- [x] 1.1 Confirmar `traefik-keycloak` como proyecto soportado en el catálogo.
- [x] 1.2 Confirmar política TLS: default ACME vía StepCA en red, override explícito permitido.
- [x] 1.3 Confirmar dependencia de proyecto para TLS por defecto: `traefik-stepca`.
- [x] 1.4 Validar artefactos del cambio con `openspec validate add-project-traefik-keycloak --strict`.

## 2. Project Definition

- [x] 2.1 Crear estructura `deployment/projects/traefik-keycloak/`.
- [x] 2.2 Definir manifiesto del proyecto (`id`, `description`, `repo_url`, `repo_ref`, `compose_profile`, `services`, `required_env`, `depends_on_projects`, `tls_mode`, `public_host` opcional).
- [x] 2.3 Registrar `traefik-keycloak` en el catálogo expuesto por `deployment-project-list`.

## 3. Deployment Behavior

- [x] 3.1 Implementar tasks Ansible para clonar/sincronizar `compose-traeffik` en la VM objetivo.
- [x] 3.2 Ejecutar compose para servicios predefinidos del proyecto (`traefik`, `keycloak`, y dependencias declaradas en manifiesto).
- [x] 3.3 Implementar selección TLS:
- [x] 3.4 Default `tls_mode=stepca-acme` (ACME contra endpoint de StepCA en red).
- [x] 3.5 Permitir override explícito de `tls_mode` con validación de valor soportado.
- [x] 3.6 Garantizar idempotencia razonable del flujo de proyecto.
- [x] 3.7 Asegurar que Keycloak se publica detrás de Traefik y que la terminación TLS la gestiona Traefik según `tls_mode`.

## 4. Guardrails, Documentation and Tests

- [x] 4.1 Validar variables requeridas antes de ejecutar `docker compose up -d`.
- [x] 4.2 Añadir guardrail para fallar con mensaje claro si `tls_mode=stepca-acme` y endpoint ACME no es alcanzable/configurable.
- [x] 4.3 Añadir guardrails para dependencia faltante `traefik-stepca` cuando el modo por defecto esté activo.
- [x] 4.4 Documentar ejecución de `project=traefik-keycloak` y opciones de override TLS.
- [x] 4.5 Añadir tests de wiring del catálogo y contrato TLS/dependencias (default + override).
- [x] 4.6 Evitar overrides ad-hoc de servicios fuera del manifiesto del proyecto.

## 5. Validation and Handoff

- [x] 5.1 Re-ejecutar `openspec validate add-project-traefik-keycloak --strict`.
- [x] 5.2 Revisar coherencia final entre proposal, tasks y spec delta.
