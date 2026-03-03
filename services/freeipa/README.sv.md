[English](README.md) | [Svenska](README.sv.md) | [Espanol](README.es.md)

# FreeIPA service

<a id="overview"></a>
## Oversikt

FreeIPA ar en valfri identitetsmodul bakom Traefik. Modulen exponerar FreeIPA-webbentrypoint med persistent lagring och profile-gated kontrakt for TLS mode, Keycloak och observability.

<a id="location"></a>
## Var den finns

- `services/freeipa/compose.yml`

<a id="run"></a>
## Hur den kors

```bash
make freeipa-bootstrap
make freeipa-up
make freeipa-status
```

URL (via Traefik): `https://freeipa.${DEV_DOMAIN}`

<a id="configuration"></a>
## Konfiguration

Relevanta env-vars i `.env.example`:
- `FREEIPA_HOSTNAME`
- `FREEIPA_IMAGE`
- `FREEIPA_SERVER_HOSTNAME`
- `FREEIPA_REALM`, `FREEIPA_DOMAIN`
- `FREEIPA_ADMIN_PASSWORD`, `FREEIPA_DM_PASSWORD`
- `FREEIPA_INSTALL_OPTS`
- `FREEIPA_TLS_MODE`

Valfria integrationer:
- Keycloak-kontrakt: `FREEIPA_KEYCLOAK_*`, `FREEIPA_TRAEFIK_MIDDLEWARES`
- Observability hooks: `FREEIPA_OBSERVABILITY_*`, `FREEIPA_OTEL_*`

Generera hemligheter med `make freeipa-bootstrap`.

<a id="ports"></a>
## Portar, natverk, volymer

- Publika portar: inga (Traefik hanterar publik exponering)
- Natverk:
  - `proxy` (Traefik-routing)
  - `freeipa-internal` (intern modultrafik)
- Volymer:
  - `freeipa-data`

<a id="security"></a>
## Sakerhetsnoteringar

- FreeIPA publicerar inga host-portar som standard.
- UI exponeras endast via Traefik HTTPS-routing.
- Modulen lagrar data pa en dedikerad volym.
- TLS-kompatibilitet styrs av `FREEIPA_TLS_MODE` och `TLS_CERT_RESOLVER` (local CA, LE och Step-CA).
- Preflight ar profile-gated och tillampar bara FreeIPA-kontroller nar `freeipa` profilen ar aktiv.

<a id="troubleshooting"></a>
## Felsokning

- Om preflight faller pa hemligheter, kor:
  - `make freeipa-bootstrap`
- Om TLS-kontraktet faller i Step-CA-lage, satt:
  - `TLS_CERT_RESOLVER=stepca-resolver` eller aktivera `stepca`-profilen
- Om Keycloak ar aktiverat, satt alla `FREEIPA_KEYCLOAK_*` och inkludera `keycloak-forward-auth@file` i middlewares.

<a id="related"></a>
## Relaterade sidor

- [Root README](../../README.sv.md)
- [Traefik](../traefik/README.sv.md)
- [Step-CA](../step-ca/README.sv.md)
- [Observability](../observability/README.sv.md)
