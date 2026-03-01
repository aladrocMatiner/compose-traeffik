# Deployment

## Deploy En QEMU

Prerequisitos:

- `terraform`
- `ansible-playbook`
- conectividad libvirt local (`qemu:///system`)

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
