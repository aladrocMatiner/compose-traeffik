[English](README.md) | [Svenska](README.sv.md) | [Espanol](README.es.md)

# Observability service

<a id="overview"></a>
## Resumen

Modulo opcional de observabilidad reusable para despliegues detras de Traefik:
- Prometheus (metricas)
- Grafana (UI)
- Loki (logs)
- Tempo (trazas)
- Pyroscope (profiles)
- Alloy (coleccion/forwarding)
- k6 (synthetic checks on-demand)

La base reusable es la telemetria de Traefik (metricas + access logs JSON). Se incluye un pack inicial para logs de CTFd.

<a id="location"></a>
## Donde vive

- `services/observability/compose.yml`
- `services/observability/prometheus/`
- `services/observability/loki/`
- `services/observability/tempo/`
- `services/observability/alloy/`
- `services/observability/k6/`
- `services/observability/grafana/`

<a id="run"></a>
## Como corre

```bash
make observability-bootstrap
make observability-up
make observability-status
make observability-k6
```

URL de Grafana (via Traefik): `https://grafana.${DEV_DOMAIN}`

<a id="configuration"></a>
## Configuracion

Variables relevantes en `.env.example`:
- `GRAFANA_HOSTNAME`
- `GRAFANA_IMAGE`
- `PROMETHEUS_IMAGE`
- `LOKI_IMAGE`
- `ALLOY_IMAGE`
- `TEMPO_IMAGE`
- `PYROSCOPE_IMAGE`
- `K6_IMAGE`
- `GRAFANA_ADMIN_USER`
- `GRAFANA_ADMIN_PASSWORD`
- `GRAFANA_SECRET_KEY`
- `PROMETHEUS_RETENTION_TIME`
- `LOKI_RETENTION_PERIOD`
- `TEMPO_RETENTION_PERIOD`
- `PYROSCOPE_RETENTION_PERIOD`
- `K6_TARGET_URL`

Genera/persiste secretos de Grafana con `make observability-bootstrap`.

<a id="ports"></a>
## Puertos, redes, volumenes

- Endpoint publico:
  - solo Grafana (via Traefik)
- Internos por defecto:
  - Prometheus
  - Loki
  - Tempo
  - Pyroscope
- Redes:
  - `proxy` (Grafana y Prometheus para scraping interno de Traefik)
  - `observability-internal`
- Volumenes:
  - `grafana-data`
  - `prometheus-data`
  - `loki-data`
  - `tempo-data`
  - `pyroscope-data`
  - `alloy-data`

<a id="security"></a>
## Notas de seguridad

- Prometheus, Loki, Tempo y Pyroscope no se exponen publicamente por defecto.
- Las metricas de Traefik se scrapean internamente (Prometheus en `proxy` solo para reachability interna).
- Los access logs de Traefik van en JSON con headers sensibles descartados por defecto.
- Alloy envia trazas OTLP a Tempo y mantiene la coleccion de logs Docker hacia Loki.
- Alloy recibe perfiles por `pyroscope.receive_http` en el puerto `9999` y los envia a Pyroscope.
- Alloy necesita lectura de metadata/logs Docker; mounts en read-only cuando es posible.

<a id="troubleshooting"></a>
## Troubleshooting

- Si Grafana no arranca, genera secretos:
  - `make observability-bootstrap`
- Si faltan metricas de Traefik, verifica:
  - `services/traefik/traefik.yml` con `metrics.prometheus`
  - `prometheus` unido a `proxy`
- Si paneles CTFd salen vacios, es normal si `ctfd` no esta corriendo; Traefik-only mode esta soportado.
- Si trazas salen vacias, verifica que clientes envian OTLP a `alloy:4317` (gRPC) o `alloy:4318` (HTTP).
- Si perfiles salen vacios, verifica que clientes envian perfiles a `alloy:9999` (Pyroscope HTTP ingest).

Nota hosts:
- Si gestionas `ENDPOINTS` manualmente, anyade `grafana` antes de `make hosts-apply`.
- O deja `ENDPOINTS` vacio para auto-discovery por reglas `Host()`.

<a id="related"></a>
## Paginas relacionadas

- [Root README](../../README.es.md)
- [Traefik](../traefik/README.es.md)
- [CTFd](../ctfd/README.es.md)
