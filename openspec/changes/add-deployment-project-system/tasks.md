## 1. OpenSpec Contract

- [ ] 1.1 Confirmar el contrato del comando `deployment-project` con selector obligatorio `project=<id>`.
- [ ] 1.2 Confirmar defaults del flujo de proyectos para `deployment-project`: `target=qemu` y `os=ubuntu`.
- [ ] 1.3 Validar artefactos del cambio con `openspec validate add-deployment-project-system --strict`.

## 2. CLI and Orchestration Wiring

- [ ] 2.1 Añadir target `deployment-project` en `Makefile`.
- [ ] 2.2 Añadir target `deployment-project-list` para listar ids de proyecto soportados (una línea por id).
- [ ] 2.3 Añadir variable `DEPLOYMENT_PROJECT` y parsing de `project=<id>`.
- [ ] 2.4 Implementar resolución y validación de proyecto soportado.
- [ ] 2.5 Encadenar pipeline base para proyectos: provision -> wait -> `system_bootstrap` -> project deploy.
- [ ] 2.6 Garantizar que los defaults `qemu/ubuntu` no alteran el comportamiento de otros targets `deployment-*`.

## 3. Project System Contract

- [ ] 3.1 Definir estructura de proyecto bajo `deployment/projects/<project-id>/`.
- [ ] 3.2 Definir esquema obligatorio del manifiesto por proyecto (`id`, `description`, `repo_url`, `repo_ref`, `compose_profile`, `services`, `deploy_playbook`, `required_env`, `tls_mode`) y campo opcional `public_host`.
- [ ] 3.3 Definir validación de manifiesto (campos requeridos, tipos básicos, lista no vacía de servicios).
- [ ] 3.4 Definir contrato de ejecución Ansible para proyecto (incluye clone/pull del repo y `docker compose up -d` con selección fija desde manifiesto).
- [ ] 3.5 Añadir fallos claros para proyecto no encontrado o manifiesto inválido.
- [ ] 3.6 Definir política de fallo por defecto (no auto-destroy) y salida con pasos de recuperación.
- [ ] 3.7 Definir semántica de idempotencia para re-ejecución del mismo `project=<id>`.
- [ ] 3.8 Definir y validar contrato de exposición web detrás de Traefik y gestión TLS por Traefik según `tls_mode` del manifiesto.
- [ ] 3.9 Definir resolución de hostname público para proyectos web: default `<project-id>.<BASE_DOMAIN>` con override opcional por `public_host`.

## 4. Documentation and Testing

- [ ] 4.1 Documentar uso de `make deployment-project project=<id>`.
- [ ] 4.2 Documentar `make deployment-project-list` y formato de salida estable.
- [ ] 4.3 Añadir smoke tests de wiring/guardrails para el selector `project`.
- [ ] 4.4 Añadir smoke tests para contrato de orden de etapas (`provision -> wait -> bootstrap -> project deploy`).
- [ ] 4.5 Asegurar que los tests no dependen de credenciales ni estado remoto para validar contrato CLI.
- [ ] 4.6 Documentar contrato de hostname público (`<project-id>.<BASE_DOMAIN>` y override `public_host`).

## 5. Validation and Handoff

- [ ] 5.1 Re-ejecutar `openspec validate add-deployment-project-system --strict`.
- [ ] 5.2 Revisar coherencia final entre proposal, tasks y spec delta.
