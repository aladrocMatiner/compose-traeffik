## 1. OpenSpec Contract

- [x] 1.1 Confirmar `traefik-awx` como proyecto soportado en el catálogo.
- [x] 1.2 Confirmar dependencias obligatorias: `traefik-stepca` y `traefik-keycloak`.
- [x] 1.3 Confirmar política TLS: default StepCA ACME con override explícito soportado.
- [x] 1.4 Confirmar contrato OIDC de Keycloak en el manifiesto.
- [x] 1.5 Validar artefactos del cambio con `openspec validate add-project-traefik-awx --strict`.

## 2. Deployment-Side Project Definition

- [x] 2.1 Crear estructura `deployment/projects/traefik-awx/`.
- [x] 2.2 Definir manifiesto (`id`, `description`, `repo_url`, `repo_ref`, `compose_profile`, `services`, `required_env`, `depends_on_projects`, `tls_mode`, `public_host`, `oidc`).
- [x] 2.3 Registrar `traefik-awx` en el catálogo para `deployment-project-list`.

## 3. Guardrails (Hybrid Runtime Pending)

- [x] 3.1 Añadir preflight en `deployment-project` para detectar que el runtime híbrido AWX no está integrado todavía.
- [x] 3.2 Fallar antes de `docker compose up -d` con mensaje explícito de estado "deployment-only".
- [x] 3.3 Incluir transición operativa clara (`k3d + AWX operator` dentro de `deployment-project`).

## 4. Documentation and Testing

- [x] 4.1 Documentar estado del proyecto `traefik-awx` como contrato de deployment disponible con runtime pendiente.
- [x] 4.2 Extender tests de catálogo para incluir `traefik-awx` (wiring + contrato manifest).
- [x] 4.3 Extender tests de workflow para validar fail-fast pre-compose en `traefik-awx`.
- [x] 4.4 Mantener guardrail de "no overrides ad-hoc de servicios" en el contrato manifest.

## 5. Validation and Handoff

- [x] 5.1 Re-ejecutar `openspec validate add-project-traefik-awx --strict`.
- [x] 5.2 Revisar coherencia final entre proposal, tasks y spec delta.
