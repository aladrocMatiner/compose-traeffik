[English](README.md) | [Svenska](README.sv.md) | [Espanol](README.es.md)

# OpenWebUI service

<a id="overview"></a>
## Overview

OpenWebUI provides a browser UI for local LLM backends and OpenAI-compatible APIs, published behind Traefik.

<a id="location"></a>
## Where it lives

- `services/openwebui/compose.yml`

<a id="run"></a>
## How it runs

Start:
```bash
make webui-up
```

Status:
```bash
make webui-status
```

Logs:
```bash
make webui-logs
```

Stop:
```bash
make webui-down
```

<a id="configuration"></a>
## Configuration

Relevant env vars in `.env.example`:
- `OPENWEBUI_HOSTNAME`
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

- Internal port: `8080`
- Public route: `https://openwebui.${DEV_DOMAIN}`
- Network: `proxy` (`traefik-proxy`)
- Volume: `openwebui-data`

<a id="security"></a>
## Security notes

- Keep `OPENWEBUI_ENABLE_SIGNUP=false` for controlled access.
- Set `OPENWEBUI_SECRET_KEY` in non-ephemeral environments.

<a id="troubleshooting"></a>
## Troubleshooting

- Route not reachable: verify `make ps` and Traefik logs.
- Backend calls fail: check `OPENWEBUI_OLLAMA_BASE_URL` / `OPENWEBUI_OPENAI_API_BASE_URLS`.

<a id="related"></a>
## Related pages

- [Root README](../../README.md)
- [Traefik](../traefik/README.md)
