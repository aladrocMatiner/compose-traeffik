[English](README.md) | [Svenska](README.sv.md) | [Espanol](README.es.md)

# Servicio OpenWebUI

<a id="overview"></a>
## Resumen

OpenWebUI es un modulo opcional de interfaz web/chat expuesto detras de Traefik.

<a id="location"></a>
## Donde vive

- `services/openwebui/compose.yml`

<a id="run"></a>
## Como corre

```bash
make webui-up
make webui-status
```

URL (via Traefik): `https://openwebui.${DEV_DOMAIN}`

<a id="configuration"></a>
## Configuracion

Variables relevantes en `.env.example`:
- `OPENWEBUI_HOSTNAME`
- `OPENWEBUI_IMAGE`
- `OPENWEBUI_ENABLE_SIGNUP`
- `OPENWEBUI_ENABLE_PERSISTENT_CONFIG`
- `OPENWEBUI_SECRET_KEY`
- `OPENWEBUI_ADMIN_EMAIL`
- `OPENWEBUI_ADMIN_PASSWORD`
- `OPENWEBUI_OLLAMA_BASE_URL`
- `OPENWEBUI_OPENAI_API_BASE_URLS`
- `OPENWEBUI_OPENAI_API_KEYS`

<a id="ports"></a>
## Puertos, redes, volumenes

- Puertos publicos: ninguno (Traefik expone la UI/API)
- Red: `proxy` (`traefik-proxy`)
- Volumen: `openwebui-data`

<a id="security"></a>
## Notas de seguridad

- Mantener `OPENWEBUI_ENABLE_SIGNUP=false` salvo registro abierto intencional.
- La UI/API se expone solo via Traefik con HTTPS.

<a id="troubleshooting"></a>
## Troubleshooting

- Si la ruta no responde:
  - `make webui-status`
  - `make webui-logs`
- Si fallan llamadas a backend, validar variables de OpenAI/Ollama.

<a id="related"></a>
## Paginas relacionadas

- [Root README](../../README.es.md)
- [Traefik](../traefik/README.es.md)
