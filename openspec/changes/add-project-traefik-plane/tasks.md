## 1. OpenSpec Contract

- [ ] 1.1 Confirmar `traefik-plane` como id válido del catálogo `deployment-project`.
- [ ] 1.2 Confirmar dependencia explícita de `traefik-stepca`, `traefik-keycloak` y `traefik-observability`.
- [ ] 1.3 Confirmar política TLS: default `stepca-acme` con override explícito soportado.
- [ ] 1.4 Confirmar contrato OIDC de Plane con bootstrap/reconciliación idempotente en Keycloak.
- [ ] 1.5 Validar artefactos con `openspec validate add-project-traefik-plane --strict`.

## 2. Project Definition and Catalog Wiring

- [ ] 2.1 Crear `deployment/projects/traefik-plane/manifest.json`.
- [ ] 2.2 Registrar `traefik-plane` en `deployment/projects/catalog.json`.
- [ ] 2.3 Añadir `traefik-plane` a `deployment-project-list` y al test de salida esperada.
- [ ] 2.4 Definir `compose_profile` y lista cerrada de servicios Plane detrás de Traefik.
- [ ] 2.5 Definir `required_env` mínimo y contrato `public_host` para `plane.<BASE_DOMAIN>`.

## 3. Deployment Behavior (Ansible + Scripts)

- [ ] 3.1 Añadir preflight que valide presencia de `services/plane/compose.yml` en `repo_ref` fijado.
- [ ] 3.2 Añadir sincronización/backport de assets Plane necesarios cuando aplique.
- [ ] 3.3 Asegurar bootstrap idempotente de secretos Plane antes de compose apply.
- [ ] 3.4 Aplicar defaults runtime Plane necesarios para despliegue no interactivo en VM objetivo.
- [ ] 3.5 Ejecutar `compose up -d` limitado a servicios declarados por manifiesto.
- [ ] 3.6 Mantener idempotencia del flujo `deployment-project` para re-ejecuciones.

## 4. TLS, Keycloak and Observability Integration

- [ ] 4.1 Validar prerequisitos StepCA cuando `tls_mode=stepca-acme`.
- [ ] 4.2 Resolver OIDC realm/client de Plane desde manifiesto y defaults de proyecto.
- [ ] 4.3 Implementar lookup/create/update de cliente OIDC Plane en Keycloak (idempotente).
- [ ] 4.4 Sincronizar secreto OIDC efectivo de Keycloak al `.env` de Plane y recrear servicio si cambia.
- [ ] 4.5 Aplicar contrato de observabilidad de Plane (env/labels/hosts) sin bypass de Traefik.
- [ ] 4.6 Fallar rápido con mensajes claros si faltan dependencias o variables críticas.

## 5. Tests and Documentation

- [ ] 5.1 Extender `deployment/tests/smoke/test_deployment_project_catalog.sh` para `traefik-plane`.
- [ ] 5.2 Extender `deployment/tests/smoke/test_deployment_keycloak_oidc_idempotency_contract.sh` para flujo OIDC de Plane.
- [ ] 5.3 Añadir/ajustar smoke test de guardrails de preflight para módulo Plane ausente en `repo_ref`.
- [ ] 5.4 Actualizar `deployment/README.md` con orden recomendado y notas operativas de `traefik-plane`.
- [ ] 5.5 Documentar variables mínimas y fallback de integración (TLS/OIDC/observabilidad).

## 6. Validation and Handoff

- [ ] 6.1 Ejecutar `openspec validate add-project-traefik-plane --strict`.
- [ ] 6.2 Ejecutar tests smoke afectados del área deployment.
- [ ] 6.3 Verificar coherencia final entre `proposal.md`, `design.md`, `tasks.md` y delta spec.
