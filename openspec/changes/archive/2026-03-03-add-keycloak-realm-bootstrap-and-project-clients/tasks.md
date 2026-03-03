## 1. OpenSpec Contract

- [x] 1.1 Validar contrato de realm compartido `local.test` para proyectos SSO.
- [x] 1.2 Validar contrato de bootstrap de usuario inicial (`jose.romero`).
- [x] 1.3 Validar contrato de clientes OIDC por proyecto (create/update en deploy).
- [x] 1.4 Ejecutar `openspec validate add-keycloak-realm-bootstrap-and-project-clients --strict`.

## 2. Keycloak Bootstrap (traefik-keycloak)

- [x] 2.1 Añadir variables de bootstrap (`KEYCLOAK_BOOTSTRAP_REALM`, `KEYCLOAK_BOOTSTRAP_USERNAME`, `KEYCLOAK_BOOTSTRAP_PASSWORD`) con defaults.
- [x] 2.2 Implementar tareas idempotentes para asegurar realm `local.test`.
- [x] 2.3 Implementar tareas idempotentes para asegurar usuario `jose.romero` y password inicial.
- [x] 2.4 Añadir guardrail para fail-fast cuando no se pueda autenticar con admin de Keycloak.

## 3. OIDC Client Provisioning by Project

- [x] 3.1 Definir contrato de entrada OIDC por proyecto (manifest/vars) para `client_id`, `redirect_uris`, `web_origins`, `realm`.
- [x] 3.2 Implementar create/update idempotente de cliente OIDC durante `project_deploy`.
- [x] 3.3 Inyectar `OIDC_CLIENT_ID/OIDC_CLIENT_SECRET` y endpoints en `.env` del proyecto destino.
- [x] 3.4 Añadir guardrail de dependencia Keycloak para proyectos con OIDC habilitado.
- [x] 3.5 Asegurar que no se crean clientes para proyectos no desplegados.

## 4. First Consumer Migration

- [x] 4.1 Migrar `traefik-observability` al contrato OIDC estándar en realm `local.test`.
- [x] 4.2 Verificar flujo browser: `grafana -> keycloak(local.test) -> grafana`.
- [x] 4.3 Validar que certificados TLS siguen emitidos por StepCA para hosts del proyecto.

## 5. Testing and Documentation

- [x] 5.1 Actualizar smoke tests de contrato de manifiestos/catálogo para nuevos campos/expectativas OIDC.
- [x] 5.2 Añadir tests de idempotencia para create/update de realm/usuario/cliente.
- [x] 5.3 Documentar procedimiento operativo (bootstrap user, override de password, cliente por proyecto).

## 6. Validation and Handoff

- [x] 6.1 Re-ejecutar `openspec validate add-keycloak-realm-bootstrap-and-project-clients --strict`.
- [x] 6.2 Revisar coherencia final entre proposal, design, tasks y delta spec.
