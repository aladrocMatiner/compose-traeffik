[English](README.md) | [Svenska](README.sv.md) | [Espanol](README.es.md)

# Servicio OpenWebUI

<a id="overview"></a>
## Resumen

OpenWebUI ofrece una interfaz web para backends LLM locales y APIs compatibles con OpenAI, publicada detras de Traefik.

<a id="location"></a>
## Donde vive

- `services/openwebui/compose.yml`

<a id="run"></a>
## Como se ejecuta

Iniciar:
```bash
make webui-up
```

Estado:
```bash
make webui-status
```

Logs:
```bash
make webui-logs
```

Parar:
```bash
make webui-down
```

<a id="configuration"></a>
## Configuracion

Variables relevantes en `.env.example`:
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
## Puertos, redes, volumenes

- Puerto interno: `8080`
- Ruta publica: `https://openwebui.${DEV_DOMAIN}`
- Red: `proxy` (`traefik-proxy`)
- Volumen: `openwebui-data`

<a id="security"></a>
## Notas de seguridad

- Mantener `OPENWEBUI_ENABLE_SIGNUP=false` para acceso controlado.
- Definir `OPENWEBUI_SECRET_KEY` en entornos no efimeros.

<a id="troubleshooting"></a>
## Troubleshooting

- Ruta no accesible: revisar `make ps` y logs de Traefik.
- Fallos con backends: validar `OPENWEBUI_OLLAMA_BASE_URL` / `OPENWEBUI_OPENAI_API_BASE_URLS`.

<a id="related"></a>
## Paginas relacionadas

- [Root README](../../README.es.md)
- [Traefik](../traefik/README.es.md)
