# Implementation Problems and Fixes

Fecha de actualización: 2026-02-28  
Rama: `deployments`  
Ámbito: implementación del proyecto `traefik-wikijs` con integración `Keycloak + StepCA + Traefik` en target `qemu/libvirt`.

## 1. `terraform` no disponible en `PATH`

- Síntoma: comandos como `make deployment-ssh ...` fallaban con `Missing required command: terraform`.
- Causa raíz: `terraform` no estaba instalado globalmente en el host local.
- Solución aplicada: uso de fallback al binario local `./.tools/bin/terraform` en los scripts de despliegue.
- Resultado: lectura de outputs/state y workflows de deployment funcionales sin instalación global.

## 2. Ruta de proyecto remota incorrecta

- Síntoma: `cd /opt/compose-traeffik` fallaba en VM.
- Causa raíz: el proyecto real se estaba desplegando en `/opt/deployment-projects/<project-id>`.
- Solución aplicada: diagnóstico y ejecución de comandos en ruta correcta del proyecto desplegado.
- Resultado: inspección de compose/logs/DB funcional en VM.

## 3. Error de permisos al renderizar Traefik

- Síntoma: `Permission denied` sobre `services/traefik/traefik-rendered.yml`.
- Causa raíz: archivo con ownership `root:root` y ejecución sin privilegios.
- Solución aplicada: operación con privilegios en host remoto para diagnóstico y ejecución consistente del stack.
- Resultado: compose/logs volvieron a ser utilizables para depuración.

## 4. Colisión entre dos estrategias de autenticación en Wiki.js

- Síntoma: login inestable, errores de callback y comportamiento inconsistente de sesión/logout.
- Causa raíz: coexistencia de flujo nativo de Wiki.js con `wikijs-oauth2-proxy` legado.
- Solución aplicada:
  - `services/wikijs/compose.yml`: mover `wikijs-oauth2-proxy` a perfil separado (`wikijs-oauth2-proxy`) y fuera del flujo normal.
  - `deployment/projects/traefik-wikijs/manifest.json`: remover `wikijs-oauth2-proxy` de servicios del proyecto.
  - Ansible: tareas para parar y eliminar contenedor legacy `wikijs-oauth2-proxy`.
- Resultado: flujo OIDC único y estable (sin doble callback/competencia de sesiones).

## 5. Fallo TLS desde Wiki.js hacia Keycloak

- Síntoma: dentro del contenedor Wiki.js: `unable to get local issuer certificate`.
- Causa raíz: Wiki.js no confiaba en la CA de StepCA para validar `keycloak.local.test`.
- Solución aplicada en `services/wikijs/compose.yml`:
  - montaje de `./services/step-ca/certs/root_ca.crt` en `/etc/ssl/certs/stepca-root-ca.crt`;
  - `NODE_EXTRA_CA_CERTS=/etc/ssl/certs/stepca-root-ca.crt`.
- Resultado: Wiki.js puede consultar endpoints OIDC de Keycloak con TLS válido.

## 6. Parseo frágil de salida de `kcadm` en bootstrap de Keycloak

- Síntoma: fallo en Ansible con `jq: parse error: Invalid numeric literal`.
- Causa raíz: `kcadm.sh` puede emitir líneas extra antes del JSON.
- Solución aplicada en `deployment/ansible/roles/project_deploy/tasks/main.yml`:
  - sanitizar con `sed -n '/^\[/,$p'` antes de `jq`.
- Resultado: bootstrap de usuario/realm en Keycloak idempotente y estable.

## 7. Usuario bootstrap de Keycloak incompleto

- Síntoma: errores de login/estado de usuario en pruebas previas.
- Causa raíz: no se forzaban de forma consistente campos críticos del usuario (email/emailVerified/requiredActions).
- Solución aplicada:
  - bootstrap ahora fija `email`, `enabled=true`, `emailVerified=true`, `requiredActions=[]`.
- Resultado: usuario `jose.romero` consistente para OIDC.

## 8. Login local de Wiki.js fallando pese a mostrar provider `local`

- Síntoma: provider `local` visible, pero login no funcional con credenciales esperadas.
- Causa raíz: discrepancia entre usuario admin esperado y datos reales en DB (email/credenciales).
- Solución aplicada:
  - tarea de sincronización determinista del admin local de Wiki.js:
    - hash bcrypt de `WIKIJS_BOOTSTRAP_ADMIN_PASSWORD`;
    - actualización del usuario local `id=1`;
    - garantía de pertenencia a grupo admin (`userGroups`).
  - ejecución via `docker exec` directo para evitar comportamiento no determinista observado con `compose exec` en este bloque.
- Resultado: login local funcional con el admin bootstrap.

## 9. Error `You are not authorized to login.` con Keycloak

- Síntoma: callback OIDC terminaba en error de autorización (HTTP 500 en callback de Wiki.js).
- Causa raíz: provider `keycloak` de Wiki.js configurado con `selfRegistration=false`, bloqueando auto-provisión de usuario federado.
- Solución aplicada en SQL de provisión (`project_deploy`):
  - `selfRegistration=true` para `authentication.key='keycloak'`;
  - `autoEnrollGroups={"v":[1]}` mantenido para alta con permisos administrativos.
- Resultado: login OIDC completo y creación/actualización correcta del usuario federado.

## 10. Logout OIDC no cerraba sesión SSO en Keycloak

- Síntoma: logout local funcionaba, pero sesión de Keycloak permanecía activa.
- Causa raíz: el cliente `wikijs` no tenía `post.logout.redirect.uris`, provocando `HTTP 400` en endpoint de logout de Keycloak.
- Solución aplicada en contrato OIDC de Ansible:
  - en creación/actualización del cliente `wikijs` se define:
    - `attributes.post.logout.redirect.uris=https://wikijs.<base_domain>`.
- Resultado:
  - logout URL de Keycloak responde `302` (no `400`);
  - sesión SSO se invalida y el siguiente login vuelve a pedir credenciales.

## 11. Contrato OIDC de Wiki.js incompleto para producción del flujo

- Síntoma: inconsistencias en callback/logout entre iteraciones.
- Causa raíz: contrato incompleto para el uso real de Wiki.js nativo.
- Solución aplicada:
  - redirect URI única nativa: `/login/keycloak/callback`;
  - secret de cliente gestionado por Ansible;
  - sincronización del cliente en Keycloak por API admin en cada deployment.
- Resultado: flujo de login/logout reproducible e idempotente.

## 12. Limpieza de servicios legacy para evitar regresiones

- Síntoma: riesgo de reintroducción de rutas/componentes no usados.
- Causa raíz: restos de servicios anteriores en manifest/containers.
- Solución aplicada:
  - limpieza explícita de `wikijs-oauth2-proxy` cuando no está en manifest;
  - manifest final de `traefik-wikijs` limitado a servicios necesarios.
- Resultado: superficie de fallo reducida y despliegue más predecible.

## Validaciones realizadas

- `make deployment-ansible-syntax` sin errores tras cada ajuste relevante.
- `make deployment-project project=traefik-keycloak target=qemu os=ubuntu` exitoso.
- `make deployment-project project=traefik-wikijs target=qemu os=ubuntu` exitoso.
- Pruebas de flujo OIDC por `curl`:
  - login Keycloak -> callback Wiki.js `302` a `/`;
  - logout Wiki.js -> redirect a Keycloak logout;
  - logout Keycloak -> `302` de retorno válido;
  - sesión SSO invalidada (en nuevo login vuelve formulario de credenciales).

## Archivos principales tocados para resolver incidencias

- `deployment/ansible/roles/project_deploy/tasks/main.yml`
- `deployment/ansible/roles/project_deploy/defaults/main.yml`
- `services/wikijs/compose.yml`
- `deployment/projects/traefik-wikijs/manifest.json`
- `deployment/projects/catalog.json`
- `deployment/scripts/deployment-project.sh`
- `deployment/scripts/README.md`
- `deployment/tests/smoke/test_deployment_project_catalog.sh`
- `scripts/compose.sh`
- `openspec/changes/add-project-traefik-wikijs/tasks.md`

