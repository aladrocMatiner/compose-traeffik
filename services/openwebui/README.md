[English](README.md) | [Svenska](README.sv.md) | [Espanol](README.es.md)

# OpenWebUI service

<a id="overview"></a>
## Overview

OpenWebUI is an optional chat/web UI module exposed behind Traefik.

<a id="location"></a>
## Where it lives

- `services/openwebui/compose.yml`

<a id="run"></a>
## How it runs

```bash
make webui-up
make webui-status
```

URL (via Traefik): `https://openwebui.${DEV_DOMAIN}`

<a id="configuration"></a>
## Configuration

Relevant env vars in `.env.example`:
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
## Ports, networks, volumes

- Public ports: none (Traefik handles public exposure)
- Network: `proxy` (`traefik-proxy`)
- Volume: `openwebui-data`

<a id="security"></a>
## Security notes

- Keep `OPENWEBUI_ENABLE_SIGNUP=false` unless open registration is intentional.
- API/UI is exposed through Traefik HTTPS routing only.

<a id="troubleshooting"></a>
## Troubleshooting

- If route is not reachable:
  - `make webui-status`
  - `make webui-logs`
- If backend calls fail, validate OpenAI/Ollama variables.

<a id="related"></a>
## Related pages

- [Root README](../../README.md)
- [Traefik](../traefik/README.md)
