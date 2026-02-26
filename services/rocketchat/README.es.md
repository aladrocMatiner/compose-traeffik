[English](README.md) | [Svenska](README.sv.md) | [Espanol](README.es.md)

# Servicio Rocket.Chat

<a id="overview"></a>
## Overview

Rocket.Chat es un modulo opcional de aplicacion real para este stack. Corre detras de Traefik e incluye MongoDB (helper de init del replica set) y NATS en el profile `rocketchat`.

<a id="location"></a>
## Where it lives

- `services/rocketchat/compose.yml`
- `services/rocketchat/config/rocketchat.env.example` (fallback trackeado para parseo de compose)
- `services/rocketchat/rendered/` (generado por `make rocketchat-bootstrap`, ignorado por git)

<a id="run"></a>
## How it runs

Generar artefactos renderizados:
```bash
make rocketchat-bootstrap
```

Iniciar el profile:
```bash
make rocketchat-up
```

Estado:
```bash
make rocketchat-status
```

Logs:
```bash
make rocketchat-logs
```

Parar:
```bash
make rocketchat-down
```

<a id="configuration"></a>
## Configuration

Variables relevantes en `.env.example`:
- `ROCKETCHAT_VERSION`, `ROCKETCHAT_IMAGE`
- `ROCKETCHAT_HOSTNAME`, `ROCKETCHAT_PORT`
- `ROCKETCHAT_MONGODB_*`, `ROCKETCHAT_NATS_VERSION`
- `ROCKETCHAT_RENDERED_ENV_PATH`
- `ROCKETCHAT_OBSERVABILITY_ENABLED`, `ROCKETCHAT_METRICS_PORT`
- `ROCKETCHAT_KEYCLOAK_ENABLED`, `ROCKETCHAT_KEYCLOAK_*`
- `DEV_DOMAIN`, `TLS_CERT_RESOLVER`

Artefactos renderizados (gitignored):
- Env runtime de Rocket.Chat: `services/rocketchat/rendered/rocketchat.env`
- Checklist de Keycloak: `services/rocketchat/rendered/keycloak-custom-oauth.md`

Integracion Keycloak:
- Opcional y desactivada por defecto.
- Este repo renderiza un checklist/runbook (callback URL + endpoints) desde `.env`.
- La creacion del proveedor Custom OAuth en Rocket.Chat sigue siendo una tarea manual en la UI admin.

Hooks de observabilidad:
- Opcionales y desactivados por defecto (`ROCKETCHAT_OBSERVABILITY_ENABLED=false`).
- Si se activan, el render habilita ajustes Prometheus de Rocket.Chat y labels de scrape.
- Las metricas no se exponen publicamente por Traefik por defecto.

<a id="ports"></a>
## Ports, networks, volumes

- Endpoint publico: `https://rocketchat.${DEV_DOMAIN}` via Traefik (sin puerto host directo para la app)
- Puertos internos (solo contenedor): Rocket.Chat `3000`, metricas `9458`, MongoDB `27017`, NATS `4222/8222`
- Redes: `proxy` y privada `rocketchat-internal`
- Volumenes: `rocketchat-uploads`, `rocketchat-mongodb-data`

<a id="security"></a>
## Security notes

- Anade `rocketchat` a `ENDPOINTS` (o DNS/hosts) para resolucion local.
- El preflight falla si falta el env renderizado de Rocket.Chat; ejecuta `make rocketchat-bootstrap` primero.
- Los inputs de Keycloak se validan solo cuando `ROCKETCHAT_KEYCLOAK_ENABLED=true` (issuer HTTPS y credenciales requeridas).
- Rocket.Chat va por Traefik, asi que usa el mismo modo TLS del stack (self-signed, LE o step-ca opcional).

<a id="troubleshooting"></a>
## Troubleshooting

- `make rocketchat-up` falla por config renderizada: ejecuta `make rocketchat-bootstrap` y verifica `services/rocketchat/rendered/rocketchat.env`.
- Rocket.Chat espera dependencias: revisa `make rocketchat-logs` para `rocketchat-mongodb`, `rocketchat-mongodb-init` y `rocketchat-nats`.
- No aparece boton de Keycloak: confirma la configuracion manual Custom OAuth en la UI admin de Rocket.Chat y compara con `services/rocketchat/rendered/keycloak-custom-oauth.md`.
- Problemas de confianza TLS local (step-ca o self-signed): revisa las guias TLS y pasos de trust en la documentacion raiz.

<a id="related"></a>
## Related pages

- [Root README](../../README.es.md)
- [Traefik](../traefik/README.es.md)
- [Step-CA](../step-ca/README.es.md)
