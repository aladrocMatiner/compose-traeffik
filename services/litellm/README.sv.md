[English](README.md) | [Svenska](README.sv.md) | [Espanol](README.es.md)

# LiteLLM-tjanst

<a id="overview"></a>
## Overview

LiteLLM ar en valfri profil som ger en OpenAI-kompatibel LLM-proxy/router bakom Traefik.

<a id="location"></a>
## Where it lives

- `services/litellm/compose.yml`
- `services/litellm/config.yaml`

<a id="run"></a>
## How it runs

Generera LiteLLM-hemligheter i `.env`:
```bash
make litellm-bootstrap
```

Starta tjansten:
```bash
make litellm-up
```

Standalone-lage (bara Traefik + LiteLLM):
```bash
make litellm-standalone-up
```

Verifiera health (LiteLLM v1.81.x endpoint):
```bash
curl -sk "https://${LITELLM_HOSTNAME:-llm}.${DEV_DOMAIN}/health/liveliness" \
  -H "Authorization: Bearer ${LITELLM_MASTER_KEY}"
```

Verifiera UI/docs/admin pa separat hostname (Traefik BasicAuth-prompt forvantas):
```bash
curl -skI "https://${LITELLM_UI_HOSTNAME:-llm-admin}.${DEV_DOMAIN}/ui"
```

Exempelrequest (fungerar med standard lokal route om lokal/LAN Ollama-kompatibel backend ar tillganglig):
```bash
curl -sk "https://${LITELLM_HOSTNAME:-llm}.${DEV_DOMAIN}/chat/completions" \
  -H "Authorization: Bearer ${LITELLM_MASTER_KEY}" \
  -H 'Content-Type: application/json' \
  -d "{\"model\":\"${LITELLM_LOCAL_MODEL_ALIAS:-local-ollama}\",\"messages\":[{\"role\":\"user\",\"content\":\"ping\"}]}"
```

<a id="configuration"></a>
## Configuration

Relevanta env-vars i `.env.example`:
- `LITELLM_IMAGE`
- `LITELLM_HOSTNAME`
- `LITELLM_UI_HOSTNAME`
- `LITELLM_PORT`
- `LITELLM_MIDDLEWARES`
- `LITELLM_UI_MIDDLEWARES`
- `LITELLM_MASTER_KEY` (genereras av `make litellm-bootstrap`)
- `LITELLM_SALT_KEY` (genereras av `make litellm-bootstrap`)
- `LITELLM_UI_BASIC_AUTH_USER` / `LITELLM_UI_BASIC_AUTH_PASSWORD` (genereras av `make litellm-bootstrap`)
- `LITELLM_UI_BASIC_AUTH_HTPASSWD_PATH`
- `LITELLM_LOCAL_API_BASE`
- `LITELLM_LOCAL_MODEL_ALIAS` / `LITELLM_LOCAL_MODEL_REF`
- `OPENAI_API_KEY` (valfri)
- `ANTHROPIC_API_KEY` (valfri)
- `OPENROUTER_API_KEY` (valfri)
- `DEV_DOMAIN`
- `TLS_CERT_RESOLVER`

Routing/modellkonfiguration finns i `services/litellm/config.yaml` och ska referera hemligheter via `os.environ/<VAR>`.
Mallen innehaller en lokal standardroute sa att du kan peka pa en annan maskin i LAN genom att bara andra `.env`.

<a id="ports"></a>
## Ports, networks, volumes

- Port: containerport `4000` (publiceras inte till host)
- Natverk: `proxy` (`traefik-proxy`)
- Volym: `services/litellm/config.yaml` -> `/app/config.yaml` (read-only)

<a id="security"></a>
## Security notes

- Tjansten exponeras bara via Traefik pa `https://${LITELLM_HOSTNAME:-llm}.${DEV_DOMAIN}`.
- UI/docs/admin exponeras pa `https://${LITELLM_UI_HOSTNAME:-llm-admin}.${DEV_DOMAIN}` med Traefik BasicAuth.
- LiteLLM API-auth ar aktiverad som standard via `LITELLM_MASTER_KEY`.
- UI BasicAuth-uppgifter ar separata fran LiteLLM API master key.
- Rotera hemligheter med `LITELLM_BOOTSTRAP_ARGS=--force make litellm-bootstrap` och uppdatera klienter.
- Lokal standard-backend (`LITELLM_LOCAL_API_BASE`) ar avsedd for betrodd lokal/LAN-miljo; sakra den separat om den ar fjarr.
- Provider-API-nycklar ar valfria i `.env`; requests misslyckas tills provider eller lokal backend ar konfigurerad/igang.

<a id="troubleshooting"></a>
## Troubleshooting

- Kor `make litellm-status` och `make litellm-logs`.
- Om preflight faller, kor `make litellm-bootstrap` och kontrollera LiteLLM API/UI-uppgifter samt htpasswd-filen.
- Om hostname-upplosning fallerar, lagg till `llm` och/eller `llm-admin` (eller overrides) i `ENDPOINTS` och kor hosts/DNS-verktygen igen.
- I standalone-lage med fjarr-`step-ca`, satt `STEP_CA_CA_SERVER` och lita pa CA:n i klienterna.

<a id="related"></a>
## Related pages

- [Root README](../../README.sv.md)
- [Traefik](../traefik/README.sv.md)
