[English](README.md) | [Svenska](README.sv.md) | [Espanol](README.es.md)

# Observability service

<a id="overview"></a>
## Oversikt

Valfri observability-modul som kan ateranvandas for deployment bakom Traefik:
- Prometheus (metrics)
- Grafana (UI)
- Loki (loggar)
- Alloy (logginsamling)

Baslinjen ar Traefik-telemetri (Prometheus-metrics + JSON access logs). CTFd-loggar ar inkluderade som forsta app-pack.

<a id="location"></a>
## Var den finns

- `services/observability/compose.yml`
- `services/observability/prometheus/`
- `services/observability/loki/`
- `services/observability/alloy/`
- `services/observability/grafana/`

<a id="run"></a>
## Hur den kor

```bash
make observability-bootstrap
make observability-up
make observability-status
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
- `GRAFANA_ADMIN_USER`
- `GRAFANA_ADMIN_PASSWORD`
- `GRAFANA_SECRET_KEY`
- `PROMETHEUS_RETENTION_TIME`
- `LOKI_RETENTION_PERIOD`

Generera/persistera Grafana-hemligheter med `make observability-bootstrap`.

<a id="ports"></a>
## Portar, natverk, volymer

- Publik endpoint:
  - endast Grafana (via Traefik)
- Interna som standard:
  - Prometheus
  - Loki
- Natverk:
  - `proxy` (Grafana och Prometheus for intern scraping av Traefik)
  - `observability-internal`
- Volymer:
  - `grafana-data`
  - `prometheus-data`
  - `loki-data`
  - `alloy-data`

<a id="security"></a>
## Sakerhetsnoter

- Prometheus och Loki exponeras inte publikt som standard.
- Traefik-metrics scrapas internt (Prometheus i `proxy` endast for intern reachability).
- Traefik access logs ar JSON och droppar kansliga headers som standard.
- Alloy behover lasratt till Docker metadata/loggar; mounts ska vara read-only dar det ar mojligt.

<a id="troubleshooting"></a>
## Felsokning

- Om Grafana inte startar, generera hemligheter:
  - `make observability-bootstrap`
- Om Traefik-metrics saknas, verifiera:
  - `services/traefik/traefik.yml` har `metrics.prometheus`
  - `prometheus` ar ansluten till `proxy`
- Tomma CTFd-paneler ar normalt om `ctfd` inte kor; Traefik-only mode ar stott.

Hosts-not:
- Om du hanterar `ENDPOINTS` manuellt, lagg till `grafana` innan `make hosts-apply`.
- Eller lamna `ENDPOINTS` tomt for auto-discovery via `Host()`-regler.

<a id="related"></a>
## Relaterade sidor

- [Root README](../../README.sv.md)
- [Traefik](../traefik/README.sv.md)
- [CTFd](../ctfd/README.sv.md)
