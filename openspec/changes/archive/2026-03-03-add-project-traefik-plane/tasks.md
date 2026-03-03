## 1. OpenSpec Contract

- [x] 1.1 Confirmar `traefik-plane` como id válido del catálogo `deployment-project`.
- [x] 1.2 Confirmar dependencia explícita de `traefik-stepca`, `traefik-keycloak` y `traefik-observability`.
- [x] 1.3 Confirmar política TLS: default `stepca-acme` con override explícito soportado.
- [x] 1.4 Confirmar contrato OIDC de Plane con bootstrap/reconciliación idempotente en Keycloak.
- [x] 1.5 Validar artefactos con `openspec validate add-project-traefik-plane --strict`.

## 2. Project Definition and Catalog Wiring

- [x] 2.1 Crear `deployment/projects/traefik-plane/manifest.json`.
- [x] 2.2 Registrar `traefik-plane` en `deployment/projects/catalog.json`.
- [x] 2.3 Añadir `traefik-plane` a `deployment-project-list` y al test de salida esperada.
- [x] 2.4 Definir `compose_profile` y lista cerrada de servicios Plane detrás de Traefik.
- [x] 2.5 Definir `required_env` mínimo y contrato `public_host` para `plane.<BASE_DOMAIN>`.

## 3. Deployment Behavior (Ansible + Scripts)

- [x] 3.1 Añadir preflight que valide presencia de `services/plane/compose.yml` en `repo_ref` fijado.
- [x] 3.2 Añadir sincronización/backport de assets Plane necesarios cuando aplique.
- [x] 3.3 Asegurar bootstrap idempotente de secretos Plane antes de compose apply.
- [x] 3.4 Aplicar defaults runtime Plane necesarios para despliegue no interactivo en VM objetivo.
- [x] 3.5 Ejecutar `compose up -d` limitado a servicios declarados por manifiesto.
- [x] 3.6 Mantener idempotencia del flujo `deployment-project` para re-ejecuciones.

## 4. TLS, Keycloak and Observability Integration

- [x] 4.1 Validar prerequisitos StepCA cuando `tls_mode=stepca-acme`.
- [x] 4.2 Resolver OIDC realm/client de Plane desde manifiesto y defaults de proyecto.
- [x] 4.3 Implementar lookup/create/update de cliente OIDC Plane en Keycloak (idempotente).
- [x] 4.4 Sincronizar secreto OIDC efectivo de Keycloak al `.env` de Plane y recrear servicio si cambia.
- [x] 4.5 Aplicar contrato de observabilidad de Plane (env/labels/hosts) sin bypass de Traefik.
- [x] 4.6 Fallar rápido con mensajes claros si faltan dependencias o variables críticas.

## 5. Tests and Documentation

- [x] 5.1 Extender `deployment/tests/smoke/test_deployment_project_catalog.sh` para `traefik-plane`.
- [x] 5.2 Extender `deployment/tests/smoke/test_deployment_keycloak_oidc_idempotency_contract.sh` para flujo OIDC de Plane.
- [x] 5.3 Añadir/ajustar smoke test de guardrails de preflight para módulo Plane ausente en `repo_ref`.
- [x] 5.4 Actualizar `deployment/README.md` con orden recomendado y notas operativas de `traefik-plane`.
- [x] 5.5 Documentar variables mínimas y fallback de integración (TLS/OIDC/observabilidad).

## 6. Validation and Handoff

- [x] 6.1 Ejecutar `openspec validate add-project-traefik-plane --strict`.
- [x] 6.2 Ejecutar tests smoke afectados del área deployment.
- [x] 6.3 Verificar coherencia final entre `proposal.md`, `design.md`, `tasks.md` y delta spec.
