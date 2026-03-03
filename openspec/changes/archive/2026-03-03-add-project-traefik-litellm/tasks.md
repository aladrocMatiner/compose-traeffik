## 1. OpenSpec Contract

- [x] 1.1 Confirmar `traefik-litellm` como proyecto soportado en el catálogo.
- [x] 1.2 Confirmar dependencia de certificados por defecto: `traefik-stepca`.
- [x] 1.3 Confirmar política TLS: default `stepca-acme` con override explícito soportado.
- [x] 1.4 Confirmar contrato full stack: LiteLLM + PostgreSQL persistente + UI detrás de Traefik.
- [x] 1.5 Validar artefactos del cambio con `openspec validate add-project-traefik-litellm --strict`.

## 2. Project Definition

- [x] 2.1 Crear estructura `deployment/projects/traefik-litellm/`.
- [x] 2.2 Definir manifiesto (`id`, `description`, `repo_url`, `repo_ref`, `compose_profile`, `services`, `required_env`, `depends_on_projects`, `tls_mode`, `public_host` opcional).
- [x] 2.3 Registrar `traefik-litellm` en el catálogo para `deployment-project-list`.

## 3. Deployment Behavior

- [x] 3.1 Implementar tasks Ansible para sync de `compose-traeffik` en la VM objetivo.
- [x] 3.2 Ejecutar compose para servicios full de LiteLLM definidos en manifiesto (`traefik`, `litellm-db`, `litellm`).
- [x] 3.3 Asegurar que LiteLLM/UI se publica detrás de Traefik y que la terminación TLS la gestiona Traefik según `tls_mode`.
- [x] 3.4 Aplicar `tls_mode=stepca-acme` por defecto.
- [x] 3.5 Permitir override explícito de `tls_mode` con validación de valores soportados.
- [x] 3.6 Garantizar idempotencia razonable del flujo.

## 4. Guardrails, Documentation and Testing

- [x] 4.1 Validar variables requeridas antes de `docker compose up -d`.
- [x] 4.2 Añadir guardrails para prerequisitos TLS (StepCA ACME) y variables del runtime LLM.
- [x] 4.3 Asegurar configuración de persistencia (`DATABASE_URL`, `STORE_MODEL_IN_DB`) y secretos runtime.
- [x] 4.4 Documentar ejecución de `project=traefik-litellm`, prerequisitos (`OPENAI_API_KEY`) y override TLS.
- [x] 4.5 Añadir tests de wiring del catálogo y contrato proxy/TLS/full-stack.
- [x] 4.6 Evitar overrides ad-hoc de servicios fuera del manifiesto.

## 5. Validation and Handoff

- [x] 5.1 Re-ejecutar `openspec validate add-project-traefik-litellm --strict`.
- [x] 5.2 Revisar coherencia final entre proposal, tasks y spec delta.
