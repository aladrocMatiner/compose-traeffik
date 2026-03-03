[English](README.md) | [Svenska](README.sv.md) | [Espanol](README.es.md)

# OpenWebUI service

<a id="overview"></a>
## Oversikt

OpenWebUI ar en valfri webb/chat-modul exponerad bakom Traefik.

<a id="location"></a>
## Var den finns

- `services/openwebui/compose.yml`

<a id="run"></a>
## Hur den kor

```bash
make webui-up
make webui-status
```

URL (via Traefik): `https://openwebui.${DEV_DOMAIN}`

<a id="configuration"></a>
## Konfiguration

Relevanta env vars i `.env.example`:
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
## Portar, natverk, volymer

- Publika portar: inga (Traefik hanterar publik exponering)
- Natverk: `proxy` (`traefik-proxy`)
- Volym: `openwebui-data`

<a id="security"></a>
## Sakerhetsnoter

- Hall `OPENWEBUI_ENABLE_SIGNUP=false` om oppen registrering inte ar avsiktlig.
- UI/API exponeras endast via Traefik HTTPS-routing.

<a id="troubleshooting"></a>
## Felsokning

- Om routen inte svarar:
  - `make webui-status`
  - `make webui-logs`
- Om backend-anrop misslyckas, verifiera OpenAI/Ollama-variabler.

<a id="related"></a>
## Relaterade sidor

- [Root README](../../README.sv.md)
- [Traefik](../traefik/README.sv.md)
