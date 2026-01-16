[English](README.md) | [Svenska](README.sv.md) | [Espanol](README.es.md)

# Step-CA service

<a id="overview"></a>
## Resumen

Step-CA proporciona un servidor ACME interno (Mode C) para emision local de certificados.

<a id="location"></a>
## Donde vive

- `services/step-ca/compose.yml`
- `services/step-ca/config/`
- `services/step-ca/secrets/`

<a id="run"></a>
## Como corre

```bash
./scripts/compose.sh --profile stepca up -d step-ca
```

Bootstrap CA:
```bash
make stepca-bootstrap
```

<a id="configuration"></a>
## Configuracion

Variables relevantes en `.env.example`:
- `DEV_DOMAIN`
- `STEP_CA_NAME`
- `STEP_CA_ADMIN_PROVISIONER_PASSWORD`
- `STEP_CA_PASSWORD`
- `TLS_CERT_RESOLVER`

<a id="ports"></a>
## Puertos, redes, volumenes

- Puertos: puerto de contenedor `9000` (no publicado en host)
- Redes: `stepca-internal`, `proxy`
- Volumenes:
  - `services/step-ca/config` -> `/home/step/config`
  - `services/step-ca/secrets` -> `/home/step/secrets`
  - `stepca-data` -> `/home/step/data`

<a id="security"></a>
## Notas de seguridad

- Las contrasenas de bootstrap se usan solo durante `make stepca-bootstrap`.
- Los secretos se guardan en `services/step-ca/secrets`.

<a id="troubleshooting"></a>
## Troubleshooting

- Confirma que el perfil `stepca` este activo y el contenedor corriendo.
- Usa `make logs` para ver logs de `step-ca`.

<a id="related"></a>
## Paginas relacionadas

- [Root README](../../README.es.md)
- [Traefik](../traefik/README.es.md)
