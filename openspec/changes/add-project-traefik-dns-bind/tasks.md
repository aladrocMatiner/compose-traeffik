## 1. OpenSpec Contract

- [ ] 1.1 Confirmar `traefik-dns-bind` como proyecto soportado en el catálogo.
- [ ] 1.2 Confirmar contrato de red: DNS directo por BIND en puerto 53; Traefik para rutas HTTP(S) cuando apliquen.
- [ ] 1.3 Confirmar política TLS: default `stepca-acme` para rutas HTTPS de Traefik con override explícito soportado.
- [ ] 1.4 Validar artefactos del cambio con `openspec validate add-project-traefik-dns-bind --strict`.

## 2. Project Definition

- [ ] 2.1 Crear estructura `deployment/projects/traefik-dns-bind/`.
- [ ] 2.2 Definir manifiesto (`id`, `description`, `repo_url`, `repo_ref`, `compose_profile`, `services`, `required_env`, `tls_mode`, `public_host` opcional).
- [ ] 2.3 Registrar `traefik-dns-bind` en el catálogo para `deployment-project-list`.

## 3. Deployment Behavior

- [ ] 3.1 Implementar tasks Ansible para sync de `compose-traeffik` en la VM objetivo.
- [ ] 3.2 Ejecutar compose para servicios predefinidos del proyecto (`traefik` + `bind`).
- [ ] 3.3 Validar que la configuración de BIND publica DNS en UDP/TCP 53 según manifiesto/entorno.
- [ ] 3.4 Aplicar `tls_mode=stepca-acme` por defecto para rutas HTTPS de Traefik del proyecto.
- [ ] 3.5 Permitir override explícito de `tls_mode` con validación de valores soportados.
- [ ] 3.6 Garantizar idempotencia razonable del flujo.

## 4. Guardrails, Documentation and Testing

- [ ] 4.1 Validar variables requeridas antes de `docker compose up -d`.
- [ ] 4.2 Documentar ejecución de `project=traefik-dns-bind` y contrato de red DNS vs HTTP(S).
- [ ] 4.3 Añadir tests de wiring del catálogo y contrato TLS/puertos del proyecto.
- [ ] 4.4 Evitar overrides ad-hoc de servicios fuera del manifiesto.

## 5. Validation and Handoff

- [ ] 5.1 Re-ejecutar `openspec validate add-project-traefik-dns-bind --strict`.
- [ ] 5.2 Revisar coherencia final entre proposal, tasks y spec delta.
