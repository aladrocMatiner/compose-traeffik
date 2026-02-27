## 1. OpenSpec Contract

- [ ] 1.1 Confirmar `traefik-semaphoreui` como proyecto soportado en el catálogo.
- [ ] 1.2 Confirmar dependencias obligatorias: `traefik-stepca` y `traefik-keycloak`.
- [ ] 1.3 Confirmar política TLS: default StepCA ACME con override explícito soportado.
- [ ] 1.4 Validar artefactos del cambio con `openspec validate add-project-traefik-semaphoreui --strict`.

## 2. Project Definition

- [ ] 2.1 Crear estructura `deployment/projects/traefik-semaphoreui/`.
- [ ] 2.2 Definir manifiesto (`id`, `description`, `repo_url`, `repo_ref`, `compose_profile`, `services`, `required_env`, `depends_on_projects`, `tls_mode`, `public_host` opcional).
- [ ] 2.3 Registrar `traefik-semaphoreui` en el catálogo para `deployment-project-list`.

## 3. Deployment Behavior

- [ ] 3.1 Implementar tasks Ansible para sync de `compose-traeffik` en la VM objetivo.
- [ ] 3.2 Ejecutar compose para los servicios del proyecto Semaphore UI definidos en manifiesto.
- [ ] 3.3 Aplicar `tls_mode=stepca-acme` por defecto.
- [ ] 3.4 Permitir override explícito de `tls_mode` con validación de valores soportados.
- [ ] 3.5 Integrar autenticación de Semaphore UI con Keycloak según contrato del proyecto.
- [ ] 3.6 Garantizar idempotencia razonable del flujo.
- [ ] 3.7 Asegurar que Semaphore UI se publica detrás de Traefik y que la terminación TLS la gestiona Traefik según `tls_mode`.

## 4. Guardrails, Documentation and Testing

- [ ] 4.1 Validar variables requeridas antes de `docker compose up -d`.
- [ ] 4.2 Añadir guardrails para dependencias faltantes (`traefik-stepca`, `traefik-keycloak`).
- [ ] 4.3 Documentar ejecución de `project=traefik-semaphoreui` y override TLS.
- [ ] 4.4 Añadir tests de wiring del catálogo y contrato TLS/auth/dependencias.
- [ ] 4.5 Evitar overrides ad-hoc de servicios fuera del manifiesto.

## 5. Validation and Handoff

- [ ] 5.1 Re-ejecutar `openspec validate add-project-traefik-semaphoreui --strict`.
- [ ] 5.2 Revisar coherencia final entre proposal, tasks y spec delta.
