## 1. OpenSpec Contract

- [ ] 1.1 Confirmar `traefik-webui` como proyecto soportado en el catálogo.
- [ ] 1.2 Confirmar dependencia de certificados por defecto: `traefik-stepca`.
- [ ] 1.3 Confirmar política TLS: default `stepca-acme` con override explícito soportado.
- [ ] 1.4 Validar artefactos del cambio con `openspec validate add-project-traefik-webui --strict`.

## 2. Project Definition

- [ ] 2.1 Crear estructura `deployment/projects/traefik-webui/`.
- [ ] 2.2 Definir manifiesto (`id`, `description`, `repo_url`, `repo_ref`, `compose_profile`, `services`, `required_env`, `depends_on_projects`, `tls_mode`, `public_host` opcional).
- [ ] 2.3 Registrar `traefik-webui` en el catálogo para `deployment-project-list`.

## 3. Deployment Behavior

- [ ] 3.1 Implementar tasks Ansible para sync de `compose-traeffik` en la VM objetivo.
- [ ] 3.2 Ejecutar compose para servicios de WebUI definidos en manifiesto.
- [ ] 3.3 Asegurar que WebUI se publica detrás de Traefik y que la terminación TLS la gestiona Traefik según `tls_mode`.
- [ ] 3.4 Aplicar `tls_mode=stepca-acme` por defecto.
- [ ] 3.5 Permitir override explícito de `tls_mode` con validación de valores soportados.
- [ ] 3.6 Garantizar idempotencia razonable del flujo.

## 4. Guardrails, Documentation and Testing

- [ ] 4.1 Validar variables requeridas antes de `docker compose up -d`.
- [ ] 4.2 Añadir guardrails para prerequisitos TLS (StepCA ACME) y variables del runtime WebUI.
- [ ] 4.3 Documentar ejecución de `project=traefik-webui` y override TLS.
- [ ] 4.4 Añadir tests de wiring del catálogo y contrato proxy/TLS.
- [ ] 4.5 Evitar overrides ad-hoc de servicios fuera del manifiesto.

## 5. Validation and Handoff

- [ ] 5.1 Re-ejecutar `openspec validate add-project-traefik-webui --strict`.
- [ ] 5.2 Revisar coherencia final entre proposal, tasks y spec delta.
