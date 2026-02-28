# SemaphoreUI Implementation Problems

## Scope
This document records issues found while implementing and validating `traefik-semaphoreui` in QEMU/libvirt with Traefik + StepCA + Keycloak.

## 1) Invalid container tag
- Symptom: deployment failed during `docker compose up -d` with `manifest unknown` for `semaphoreui/semaphore:v2.13.18`.
- Root cause: selected image tag did not exist in Docker registry.
- Fix applied: switched default image to `semaphoreui/semaphore:latest`.
- Files:
  - `services/semaphoreui/compose.yml`
  - `.env.example`

## 2) Semaphore container crash due to malformed OIDC JSON
- Symptom: `semaphoreui` container restarted continuously with panic:
  - `invalid character 'n'...`
  - later `invalid character 'k'...`
- Root cause:
  - `SEMAPHORE_OIDC_PROVIDERS` value written with invalid JSON shape at first.
  - then JSON string was not preserved correctly through `.env` parsing / compose interpolation.
- Fix applied:
  - changed value to object map format expected by Semaphore (`{"keycloak": {...}}`), not array.
  - wrapped env in single quotes in `.env` generation.
  - wrapped compose env assignment as string: `SEMAPHORE_OIDC_PROVIDERS: "${SEMAPHORE_OIDC_PROVIDERS}"`.
- Files:
  - `deployment/ansible/roles/project_deploy/tasks/main.yml`
  - `services/semaphoreui/compose.yml`

## 3) 401 / permissions errors for project creation and user admin operations
- Symptom:
  - 401 when creating project as Keycloak user.
  - UI action to grant admin produced HTTP 500 from frontend.
  - backend logs: `jose.romero is not permitted to edit users`.
- Root cause:
  - Keycloak user was provisioned as external non-admin (`external=true`, `admin=false`).
  - `SEMAPHORE_NON_ADMIN_CAN_CREATE_PROJECT=false` blocked non-admin project creation.
- Operational fix applied in VM:
  - promoted user in DB:
    - `update "user" set admin=true where username='jose.romero';`
- Follow-up recommendation:
  - automate role assignment in Ansible for designated bootstrap user(s), or keep local `admin` as control-plane account for user/role management.

## 4) HTTP 404 on `semaphoreui.local.test` while TLS cert was valid
- Symptom: valid StepCA cert but `HTTPS 404` from Traefik for Semaphore route.
- Root cause: backend app was crash-looping; router existed but service had no healthy target.
- Fix applied: resolved OIDC env encoding issues (items #2), then recreated service.

## 5) Noisy unrelated env warnings from optional services
- Symptom: compose warning lines for `WIKIJS_*` variables during Semaphore deploy.
- Root cause: shared compose layering includes additional service files; non-selected services still parse env placeholders.
- Current impact: warning only (non-blocking).
- Recommendation: reduce warning noise by adding safe defaults or isolating compose includes per project profile more strictly.

## Validation performed after fixes
- Containers healthy:
  - `traefik`, `whoami`, `semaphoreui-db`, `semaphoreui`
- Endpoints:
  - `https://whoami-semaphoreui.local.test` -> 200
  - `https://traefik-semaphoreui.local.test` -> 401 (expected dashboard auth)
  - `https://semaphoreui.local.test` -> 200
- Certificates:
  - Issuer from StepCA intermediate (`aladroc.io Intermediate CA`) for all exposed hosts.
