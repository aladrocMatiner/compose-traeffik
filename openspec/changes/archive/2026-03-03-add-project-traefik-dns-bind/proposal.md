## Why

Necesitamos un proyecto de catálogo para desplegar DNS autoritativo/local con BIND junto al edge de Traefik en la misma VM de deployment. Esto permite estandarizar un perfil de infraestructura DNS reutilizable dentro del sistema de proyectos.

## What Changes

- Añadir proyecto `traefik-dns-bind` en `deployment/projects/traefik-dns-bind/`.
- Definir manifiesto explícito del proyecto con `repo_url`, `repo_ref`, `compose_profile`, `services`, `required_env` y `tls_mode`.
- Definir playbook de proyecto para sync de repo y ejecución `docker compose up -d` con servicios predefinidos (`traefik` + `bind`).
- Mantener contrato de red:
  - DNS (UDP/TCP 53) servido por BIND directamente en su puerto.
  - Traefik como proxy edge para rutas HTTP(S) del proyecto cuando existan.
- Definir política TLS OpenSpec para rutas HTTPS gestionadas por Traefik (default `stepca-acme`, override explícito soportado).

## Capabilities

### New Capabilities

- None.

### Modified Capabilities

- `deployment-project-catalog`: añade proyecto concreto `traefik-dns-bind` con contrato de red/TLS explícito.

## Impact

- Affected code (planned): `deployment/projects/traefik-dns-bind/*`, playbooks/vars de proyecto en `deployment/ansible`, wiring de catálogo, docs/tests.
- Operación: despliegue reproducible del stack DNS (BIND) con edge Traefik en el mismo workflow de proyectos.
- Riesgo: confusión de plano de tráfico DNS vs HTTP(S); se mitiga con contrato explícito de red en manifiesto y tests de wiring.
