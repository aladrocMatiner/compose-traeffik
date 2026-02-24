[English](README.md) | [Svenska](README.sv.md) | [Espanol](README.es.md)

# Servicio LiteLLM

<a id="overview"></a>
## Overview

LiteLLM es un perfil opcional que ofrece un proxy/router LLM compatible con OpenAI detras de Traefik.

<a id="location"></a>
## Where it lives

- `services/litellm/compose.yml`
- `services/litellm/config.yaml`

<a id="run"></a>
## How it runs

Genera secretos LiteLLM en `.env`:
```bash
make litellm-bootstrap
```

Inicia el servicio:
```bash
make litellm-up
```

Modo standalone (solo Traefik + LiteLLM):
```bash
make litellm-standalone-up
```

Verifica health (endpoint LiteLLM v1.81.x):
```bash
curl -sk "https://${LITELLM_HOSTNAME:-llm}.${DEV_DOMAIN}/health/liveliness" \
  -H "Authorization: Bearer ${LITELLM_MASTER_KEY}"
```

Verifica la UI/docs/admin en hostname dedicado (se espera prompt BasicAuth de Traefik):
```bash
curl -skI "https://${LITELLM_UI_HOSTNAME:-llm-admin}.${DEV_DOMAIN}/ui"
```

Ejemplo de request (funciona con la ruta local por defecto si el backend Ollama-compatible esta disponible):
```bash
curl -sk "https://${LITELLM_HOSTNAME:-llm}.${DEV_DOMAIN}/chat/completions" \
  -H "Authorization: Bearer ${LITELLM_MASTER_KEY}" \
  -H 'Content-Type: application/json' \
  -d "{\"model\":\"${LITELLM_LOCAL_MODEL_ALIAS:-local-ollama}\",\"messages\":[{\"role\":\"user\",\"content\":\"ping\"}]}"
```

<a id="configuration"></a>
## Configuration

Variables relevantes en `.env.example`:
- `LITELLM_IMAGE`
- `LITELLM_HOSTNAME`
- `LITELLM_UI_HOSTNAME`
- `LITELLM_PORT`
- `LITELLM_MIDDLEWARES`
- `LITELLM_UI_MIDDLEWARES`
- `LITELLM_MASTER_KEY` (generada por `make litellm-bootstrap`)
- `LITELLM_SALT_KEY` (generada por `make litellm-bootstrap`)
- `LITELLM_UI_BASIC_AUTH_USER` / `LITELLM_UI_BASIC_AUTH_PASSWORD` (generadas por `make litellm-bootstrap`)
- `LITELLM_UI_BASIC_AUTH_HTPASSWD_PATH`
- `LITELLM_LOCAL_API_BASE`
- `LITELLM_LOCAL_MODEL_ALIAS` / `LITELLM_LOCAL_MODEL_REF`
- `OPENAI_API_KEY` (opcional)
- `ANTHROPIC_API_KEY` (opcional)
- `OPENROUTER_API_KEY` (opcional)
- `DEV_DOMAIN`
- `TLS_CERT_RESOLVER`

La configuracion de rutas/modelos vive en `services/litellm/config.yaml` y debe referenciar secretos con `os.environ/<VAR>`.
La plantilla incluye una ruta local por defecto para que puedas apuntar a otro host en la LAN cambiando solo `.env`.

<a id="ports"></a>
## Ports, networks, volumes

- Puerto: `4000` en el contenedor (no publicado en host)
- Red: `proxy` (`traefik-proxy`)
- Volumen: `services/litellm/config.yaml` -> `/app/config.yaml` (solo lectura)

<a id="security"></a>
## Security notes

- El servicio se expone solo via Traefik en `https://${LITELLM_HOSTNAME:-llm}.${DEV_DOMAIN}`.
- La UI/docs/admin se expone en `https://${LITELLM_UI_HOSTNAME:-llm-admin}.${DEV_DOMAIN}` con BasicAuth de Traefik.
- La autenticacion de LiteLLM API esta habilitada por defecto con `LITELLM_MASTER_KEY`.
- Las credenciales BasicAuth de la UI son distintas de la master key de la API.
- Rota secretos con `LITELLM_BOOTSTRAP_ARGS=--force make litellm-bootstrap` y actualiza clientes.
- El backend local por defecto (`LITELLM_LOCAL_API_BASE`) esta pensado para red local/LAN de confianza; securizalo aparte si esta en otra maquina.
- Las claves de proveedores son opcionales en `.env`; las requests fallaran hasta que un proveedor o backend local este configurado/activo.

<a id="troubleshooting"></a>
## Troubleshooting

- Ejecuta `make litellm-status` y `make litellm-logs`.
- Si falla preflight, ejecuta `make litellm-bootstrap` y verifica credenciales API/UI y el htpasswd de LiteLLM.
- Si falla la resolucion del hostname, agrega `llm` y/o `llm-admin` (o tus overrides) a `ENDPOINTS` y vuelve a ejecutar hosts/DNS.
- En modo standalone con `step-ca` remoto, configura `STEP_CA_CA_SERVER` y confia la CA en los clientes.

<a id="related"></a>
## Related pages

- [README raiz](../../README.es.md)
- [Traefik](../traefik/README.es.md)
