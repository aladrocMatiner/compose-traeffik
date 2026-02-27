## 1. OpenSpec Contract

- [ ] 1.1 Confirmar `traefik-stepca` como primer proyecto soportado del catálogo.
- [ ] 1.2 Confirmar alcance de despliegue: servicios `traefik` y `step-ca` con perfil `stepca`.
- [ ] 1.3 Validar artefactos del cambio con `openspec validate add-project-traefik-stepca --strict`.

## 2. Project Definition

- [ ] 2.1 Crear estructura `deployment/projects/traefik-stepca/`.
- [ ] 2.2 Definir manifiesto del proyecto (id, descripción, `repo_url`, `repo_ref` pinneada, `compose_profile`, `services`, `tls_mode`, `required_env`, `public_host` opcional).
- [ ] 2.3 Definir playbook/variables del proyecto para clone/sync y despliegue compose.
- [ ] 2.4 Registrar `traefik-stepca` en el catálogo expuesto por `deployment-project-list`.

## 3. Deployment Behavior

- [ ] 3.1 Implementar tasks Ansible para clonar/actualizar `compose-traeffik` en la VM objetivo.
- [ ] 3.2 Ejecutar compose con selección predefinida del proyecto (`profile=stepca`, servicios `traefik` y `step-ca`).
- [ ] 3.3 Validar variables requeridas del proyecto antes del `docker compose up -d`.
- [ ] 3.4 Asegurar que la terminación TLS la gestiona Traefik según `tls_mode` del manifiesto (default esperado: `stepca-acme`).
- [ ] 3.5 Garantizar idempotencia razonable del flujo de proyecto.

## 4. Documentation and Testing

- [ ] 4.1 Documentar cómo ejecutar `project=traefik-stepca`.
- [ ] 4.2 Añadir tests de wiring del catálogo para confirmar que el proyecto existe y referencia el perfil/servicios esperados.
- [ ] 4.3 Añadir tests para validar que el manifiesto declara `repo_ref` pinneada, `tls_mode` y `required_env`.
- [ ] 4.4 Añadir validación de contrato para evitar overrides ad-hoc de servicios fuera del manifiesto del proyecto.

## 5. Validation and Handoff

- [ ] 5.1 Re-ejecutar `openspec validate add-project-traefik-stepca --strict`.
- [ ] 5.2 Revisar coherencia final entre proposal, tasks y spec delta.
