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
