[English](README.md) | [Svenska](README.sv.md) | [Espanol](README.es.md)

# OpenWebUI-tjanst

<a id="overview"></a>
## Oversikt

OpenWebUI ger ett webbgranssnitt for lokala LLM-backends och OpenAI-kompatibla API:er, publicerat bakom Traefik.

<a id="location"></a>
## Var den finns

- `services/openwebui/compose.yml`

<a id="run"></a>
## Hur den kors

Starta:
```bash
make webui-up
```

Status:
```bash
make webui-status
```

Loggar:
```bash
make webui-logs
```

Stoppa:
```bash
make webui-down
```

<a id="configuration"></a>
## Konfiguration

Relevanta variabler i `.env.example`:
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
## Portar, natverk, volymer

- Intern port: `8080`
- Publik route: `https://openwebui.${DEV_DOMAIN}`
- Natverk: `proxy` (`traefik-proxy`)
- Volym: `openwebui-data`

<a id="security"></a>
## Sakerhetsnoter

- Hall `OPENWEBUI_ENABLE_SIGNUP=false` for kontrollerad access.
- Satt `OPENWEBUI_SECRET_KEY` i icke-efemara miljoer.

<a id="troubleshooting"></a>
## Felsokning

- Route ej tillganglig: kontrollera `make ps` och Traefik-loggar.
- Backend-anrop misslyckas: kontrollera `OPENWEBUI_OLLAMA_BASE_URL` / `OPENWEBUI_OPENAI_API_BASE_URLS`.

<a id="related"></a>
## Relaterade sidor

- [Root README](../../README.sv.md)
- [Traefik](../traefik/README.sv.md)
