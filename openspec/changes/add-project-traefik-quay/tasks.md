## 1. OpenSpec Contract

- [ ] 1.1 Confirmar `traefik-quay` como proyecto soportado en el catálogo.
- [ ] 1.2 Confirmar contrato base de despliegue detrás de Traefik para Quay.
- [ ] 1.3 Confirmar contrato de integraciones opcionales para `stepca`, `keycloak` y `observability`.
- [ ] 1.4 Validar artefactos del cambio con `openspec validate add-project-traefik-quay --strict`.

## 2. Project Definition

- [ ] 2.1 Crear estructura `deployment/projects/traefik-quay/`.
- [ ] 2.2 Definir manifiesto (`id`, `description`, `repo_url`, `repo_ref`, `compose_profile`, `services`, `required_env`, `tls_mode`, `public_host` opcional, `depends_on_projects` opcional).
- [ ] 2.3 Definir variables/flags para habilitar integraciones opcionales de StepCA, Keycloak y Observabilidad.
- [ ] 2.4 Registrar `traefik-quay` en el catálogo para `deployment-project-list`.

## 3. Deployment Behavior

- [ ] 3.1 Implementar tasks Ansible para sync de `compose-traeffik` en la VM objetivo.
- [ ] 3.2 Ejecutar compose para los servicios del proyecto Quay definidos en manifiesto.
- [ ] 3.3 Implementar integración opcional de StepCA para TLS (`stepca-acme`) cuando esté habilitada.
- [ ] 3.4 Implementar integración opcional de autenticación Quay-Keycloak cuando esté habilitada.
- [ ] 3.5 Implementar integración opcional de observabilidad de Quay/Traefik cuando esté habilitada.
- [ ] 3.6 Garantizar idempotencia razonable del flujo para re-ejecuciones con y sin opcionales.
- [ ] 3.7 Asegurar que Quay se publica detrás de Traefik y que la terminación TLS la gestiona Traefik según `tls_mode`.

## 4. Guardrails, Documentation and Testing

- [ ] 4.1 Validar variables requeridas base antes de `docker compose up -d`.
- [ ] 4.2 Validar precondiciones/variables de cada integración opcional solo cuando esté habilitada.
- [ ] 4.3 Fallar con mensaje claro si una integración opcional está habilitada pero incompleta.
- [ ] 4.4 Documentar ejecución de `project=traefik-quay` en modo base y con opcionales (`stepca`, `keycloak`, `observability`).
- [ ] 4.5 Añadir tests de wiring del catálogo y de combinaciones base/opcional.
- [ ] 4.6 Evitar overrides ad-hoc de servicios fuera del manifiesto del proyecto.

## 5. Validation and Handoff

- [ ] 5.1 Re-ejecutar `openspec validate add-project-traefik-quay --strict`.
- [ ] 5.2 Revisar coherencia final entre proposal, tasks y spec delta.
