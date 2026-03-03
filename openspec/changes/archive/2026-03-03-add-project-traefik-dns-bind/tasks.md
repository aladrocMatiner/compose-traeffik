## 1. OpenSpec Contract

- [x] 1.1 Confirmar `traefik-dns-bind` como proyecto soportado en el catálogo.
- [x] 1.2 Confirmar contrato de red: DNS directo por BIND en puerto 53; Traefik para rutas HTTP(S) cuando apliquen.
- [x] 1.3 Confirmar política TLS: default `stepca-acme` para rutas HTTPS de Traefik con override explícito soportado.
- [x] 1.4 Validar artefactos del cambio con `openspec validate add-project-traefik-dns-bind --strict`.

## 2. Project Definition

- [x] 2.1 Crear estructura `deployment/projects/traefik-dns-bind/`.
- [x] 2.2 Definir manifiesto (`id`, `description`, `repo_url`, `repo_ref`, `compose_profile`, `services`, `required_env`, `tls_mode`, `public_host` opcional).
- [x] 2.3 Registrar `traefik-dns-bind` en el catálogo para `deployment-project-list`.

## 3. Deployment Behavior

- [x] 3.1 Implementar tasks Ansible para sync de `compose-traeffik` en la VM objetivo.
- [x] 3.2 Ejecutar compose para servicios predefinidos del proyecto (`traefik` + `bind`).
- [x] 3.3 Validar que la configuración de BIND publica DNS en UDP/TCP 53 según manifiesto/entorno.
- [x] 3.4 Aplicar `tls_mode=stepca-acme` por defecto para rutas HTTPS de Traefik del proyecto.
- [x] 3.5 Permitir override explícito de `tls_mode` con validación de valores soportados.
- [x] 3.6 Garantizar idempotencia razonable del flujo.

## 4. Guardrails, Documentation and Testing

- [x] 4.1 Validar variables requeridas antes de `docker compose up -d`.
- [x] 4.2 Documentar ejecución de `project=traefik-dns-bind` y contrato de red DNS vs HTTP(S).
- [x] 4.3 Añadir tests de wiring del catálogo y contrato TLS/puertos del proyecto.
- [x] 4.4 Evitar overrides ad-hoc de servicios fuera del manifiesto.

## 5. Validation and Handoff

- [x] 5.1 Re-ejecutar `openspec validate add-project-traefik-dns-bind --strict`.
- [x] 5.2 Revisar coherencia final entre proposal, tasks y spec delta.
