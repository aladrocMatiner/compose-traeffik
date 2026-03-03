[English](README.md) | [Svenska](README.sv.md) | [Espanol](README.es.md)

# FreeIPA service

<a id="overview"></a>
## Resumen

FreeIPA es un modulo opcional de gestion de identidad expuesto detras de Traefik. Este modulo publica el entrypoint web de FreeIPA con persistencia y contratos profile-gated para TLS mode, Keycloak y observabilidad.

<a id="location"></a>
## Donde vive

- `services/freeipa/compose.yml`

<a id="run"></a>
## Como corre

```bash
make freeipa-bootstrap
make freeipa-up
make freeipa-status
```

URL (via Traefik): `https://freeipa.${DEV_DOMAIN}`

<a id="configuration"></a>
## Configuracion

Variables relevantes en `.env.example`:
- `FREEIPA_HOSTNAME`
- `FREEIPA_IMAGE`
- `FREEIPA_SERVER_HOSTNAME`
- `FREEIPA_REALM`, `FREEIPA_DOMAIN`
- `FREEIPA_ADMIN_PASSWORD`, `FREEIPA_DM_PASSWORD`
- `FREEIPA_INSTALL_OPTS`
- `FREEIPA_TLS_MODE`

Integraciones opcionales:
- Contrato Keycloak: `FREEIPA_KEYCLOAK_*`, `FREEIPA_TRAEFIK_MIDDLEWARES`
- Hooks observabilidad: `FREEIPA_OBSERVABILITY_*`, `FREEIPA_OTEL_*`

Genera secretos con `make freeipa-bootstrap`.

<a id="ports"></a>
## Puertos, redes, volumenes

- Puertos publicos: ninguno (Traefik expone el servicio)
- Redes:
  - `proxy` (routing Traefik)
  - `freeipa-internal` (trafico interno del modulo)
- Volumenes:
  - `freeipa-data`

<a id="security"></a>
## Notas de seguridad

- FreeIPA no publica puertos al host por defecto.
- La UI se expone solo por Traefik con HTTPS.
- El modulo conserva datos en un volumen dedicado.
- La compatibilidad TLS la gobiernan `FREEIPA_TLS_MODE` y `TLS_CERT_RESOLVER` (local CA, LE y Step-CA).
- El preflight es profile-gated y solo aplica checks de FreeIPA cuando `freeipa` esta activo.

<a id="troubleshooting"></a>
## Troubleshooting

- Si falla preflight por secretos, ejecuta:
  - `make freeipa-bootstrap`
- Si falla el contrato TLS en modo Step-CA, define:
  - `TLS_CERT_RESOLVER=stepca-resolver` o activa perfil `stepca`
- Si habilitas Keycloak, completa `FREEIPA_KEYCLOAK_*` e incluye `keycloak-forward-auth@file` en middlewares.

<a id="related"></a>
## Paginas relacionadas

- [Root README](../../README.es.md)
- [Traefik](../traefik/README.es.md)
- [Step-CA](../step-ca/README.es.md)
- [Observability](../observability/README.es.md)
