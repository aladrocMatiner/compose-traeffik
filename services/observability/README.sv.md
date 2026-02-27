[English](README.md) | [Svenska](README.sv.md) | [Espanol](README.es.md)

# Observability service

<a id="overview"></a>
## Oversikt

Valfri observability-modul som kan ateranvandas for deployment bakom Traefik:
- Prometheus (metrics)
- Grafana (UI)
- Loki (loggar)
- Tempo (traces)
- Pyroscope (profiling)
- Alloy (insamling/forwarding)
- k6 (on-demand synthetic checks)

Baslinjen ar Traefik-telemetri (Prometheus-metrics + JSON access logs).

<a id="location"></a>
## Var den finns

- `services/observability/compose.yml`
- `services/observability/prometheus/`
- `services/observability/loki/`
- `services/observability/tempo/`
- `services/observability/alloy/`
- `services/observability/k6/`
- `services/observability/grafana/`

<a id="run"></a>
## Hur den kor

```bash
make observability-bootstrap
make observability-up
make observability-status
make observability-k6
```

Grafana URL (via Traefik): `https://grafana.${DEV_DOMAIN}`

<a id="configuration"></a>
## Konfiguration

Relevanta env vars i `.env.example`:
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

Generera/persistera Grafana-hemligheter med `make observability-bootstrap`.

<a id="ports"></a>
## Portar, natverk, volymer

- Publik endpoint:
  - endast Grafana (via Traefik)
- Interna som standard:
  - Prometheus
  - Loki
  - Tempo
  - Pyroscope
- Natverk:
  - `proxy` (Grafana och Prometheus for intern scraping av Traefik)
  - `observability-internal`
- Volymer:
  - `grafana-data`
  - `prometheus-data`
  - `loki-data`
  - `tempo-data`
  - `pyroscope-data`
  - `alloy-data`

<a id="security"></a>
## Sakerhetsnoter

- Prometheus, Loki, Tempo och Pyroscope exponeras inte publikt som standard.
- Traefik-metrics scrapas internt (Prometheus i `proxy` endast for intern reachability).
- Traefik access logs ar JSON och droppar kansliga headers som standard.
- Alloy skickar OTLP traces till Tempo och behaller Docker-logginsamling till Loki.
- Alloy tar emot profiler via `pyroscope.receive_http` pa port `9999` och skickar vidare till Pyroscope.
- Alloy behover lasratt till Docker metadata/loggar; mounts ska vara read-only dar det ar mojligt.

<a id="troubleshooting"></a>
## Felsokning

- Om Grafana inte startar, generera hemligheter:
  - `make observability-bootstrap`
- Om Traefik-metrics saknas, verifiera:
  - `services/traefik/traefik.yml` har `metrics.prometheus`
  - `prometheus` ar ansluten till `proxy`
- Om traces ar tomma, verifiera att klienter skickar OTLP till `alloy:4317` (gRPC) eller `alloy:4318` (HTTP).
- Om profiler ar tomma, verifiera att klienter skickar profiler till `alloy:9999` (Pyroscope HTTP ingest).

Hosts-not:
- Om du hanterar `ENDPOINTS` manuellt, lagg till `grafana` innan `make hosts-apply`.
- Eller lamna `ENDPOINTS` tomt for auto-discovery via `Host()`-regler.

<a id="related"></a>
## Relaterade sidor

- [Root README](../../README.sv.md)
- [Traefik](../traefik/README.sv.md)
