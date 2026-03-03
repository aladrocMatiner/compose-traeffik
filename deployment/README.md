# Deployment

## Deploy En QEMU

Prerequisitos:

- `terraform`
- `ansible-playbook`
- conectividad libvirt local (`qemu:///system`)

Selectores Ubuntu LTS soportados en provisioning:

- `ubuntu20.04`
- `ubuntu22.04`
- `ubuntu24.04`
- `ubuntu` (alias retrocompatible de `ubuntu24.04`)

Listado de proyectos disponibles:

```bash
make deployment-project-list
```

Orden recomendado de despliegue en QEMU:

```bash
make deployment-project project=traefik-stepca target=qemu os=ubuntu
make deployment-project project=traefik-dns-bind target=qemu os=ubuntu
make deployment-project project=traefik-keycloak target=qemu os=ubuntu
make deployment-project project=traefik-observability target=qemu os=ubuntu
make deployment-project project=traefik-wikijs target=qemu os=ubuntu
make deployment-project project=traefik-semaphoreui target=qemu os=ubuntu
make deployment-project project=traefik-rocketchat target=qemu os=ubuntu
make deployment-project project=traefik-gitlab target=qemu os=ubuntu
make deployment-project project=traefik-litellm target=qemu os=ubuntu
make deployment-project project=traefik-webui target=qemu os=ubuntu
make deployment-project project=traefik-docling target=qemu os=ubuntu
make deployment-project project=traefik-awx target=qemu os=ubuntu
make deployment-project project=traefik-plane target=qemu os=ubuntu
make deployment-project project=traefik-quay target=qemu os=ubuntu
make deployment-project project=traefik-n8n target=qemu os=ubuntu
make deployment-project project=traefik-harbor target=qemu os=ubuntu
make deployment-project project=traefik-freeipa target=qemu os=ubuntu
```

Notas para `traefik-dns-bind`:

- BIND expone DNS directamente por `53/udp` y `53/tcp` (no pasa por Traefik).
- Traefik solo se usa para endpoints HTTP(S) del proyecto (por ejemplo, dashboard).

Notas para `traefik-litellm`:

- Despliega stack full: `litellm` + `litellm-db` (PostgreSQL persistente) detrás de Traefik.
- Requiere `traefik-keycloak` desplegado para SSO OIDC automático.
- Por defecto apunta a inferencia OpenAI-compatible en `http://10.64.70.81:11434/v1` con modelo `openai/gpt-oss:20b`.
- Puedes sobreescribir backend/modelo con `OPENAI_API_BASE` y `LITELLM_MODEL` en `.env`.
- El rol admin en LiteLLM se resuelve desde Keycloak: se crea `litellm_proxy_admin` y se asigna al usuario bootstrap (`KEYCLOAK_BOOTSTRAP_USERNAME`, por defecto `jose.romero`).
- La UI/admin de LiteLLM queda accesible en `https://litellm.local.test/ui`.

Notas para `traefik-docling`:

- Estado actual: contrato de despliegue disponible en catálogo, pero runtime de servicio Docling no implementado.
- `make deployment-project project=traefik-docling ...` falla de forma intencional antes de `docker compose up -d`.
- Camino de transición esperado: implementar `services/docling/compose.yml` y soporte del profile `docling`; después retirar el guardrail de "deployment-only".

Notas para `traefik-webui`:

- Despliega `openwebui` detras de Traefik (`https://openwebui.local.test` por defecto).
- Depende de `traefik-stepca` para TLS por defecto (`tls_mode=stepca-acme`), con override soportado via `tls_mode=letsencrypt-acme`.
- Usa contrato de manifiesto cerrado: solo despliega `traefik` + `openwebui` (sin overrides ad-hoc de servicios).

Notas para `traefik-awx`:

- Estado actual: contrato de despliegue disponible en catálogo, pero runtime híbrido AWX (`k3d` + operator) aún no integrado en `deployment-project`.
- `make deployment-project project=traefik-awx ...` falla de forma intencional antes de `docker compose up -d`.
- Camino de transición esperado: integrar en `deployment-project` el flujo AWX basado en `scripts/awx-k3d-up.sh` + `scripts/awx-up.sh` y su contrato OIDC/TLS.

Notas para `traefik-plane`:

- Depende explícitamente de `traefik-stepca`, `traefik-keycloak` y `traefik-observability`.
- TLS por defecto: `tls_mode=stepca-acme` (admite override soportado).
- Incluye reconciliación OIDC idempotente en Keycloak y sincroniza `PLANE_OIDC_CLIENT_SECRET` al `.env` efectivo.
- Si el `repo_ref` pinneado no contiene `services/plane/compose.yml`, el runner falla en preflight antes de provision/compose.

Notas para `traefik-quay`:

- Contrato de proyecto registrado con dependencias `traefik-stepca` y `traefik-keycloak`.
- TLS por defecto `stepca-acme`, expuesto detrás de Traefik, con defaults de integración OIDC en `.env`.

Notas para `traefik-n8n`:

- Contrato de proyecto registrado con dependencia base `traefik-stepca`.
- OIDC de Keycloak es opcional (`oidc.enabled=true`): cuando se habilita, se validan prerequisitos antes de compose.

Notas para `traefik-harbor`:

- Contrato de proyecto registrado con dependencias `traefik-stepca` y `traefik-keycloak`.
- Incluye contrato de observabilidad opcional (`observability.enabled=true`) con validación de variables requeridas.

Notas para `traefik-freeipa`:

- Estado actual: contrato de despliegue disponible en catálogo, runtime FreeIPA pendiente.
- `make deployment-project project=traefik-freeipa ...` falla de forma intencional antes de `docker compose up -d`.
- Camino de transición esperado: implementar `services/freeipa/compose.yml` y profile `freeipa`, actualizar `repo_ref` del manifiesto y reintentar.
