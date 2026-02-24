[English](README.md) | [Svenska](README.sv.md) | [Espanol](README.es.md)

# Observability service

<a id="overview"></a>
## Overview

This optional module provides a reusable observability stack for Traefik-routed deployments:
- Prometheus (metrics)
- Grafana (UI)
- Loki (logs)
- Alloy (log collection)

Traefik telemetry (Prometheus metrics + JSON access logs) is the baseline. CTFd log dashboards/queries are included as the initial app-specific pack.

<a id="location"></a>
## Where it lives

- `services/observability/compose.yml`
- `services/observability/prometheus/`
- `services/observability/loki/`
- `services/observability/alloy/`
- `services/observability/grafana/`

<a id="run"></a>
## How it runs

```bash
make observability-bootstrap
make observability-up
make observability-status
```

Grafana URL (via Traefik): `https://grafana.${DEV_DOMAIN}`

<a id="configuration"></a>
## Configuration

Relevant env vars in `.env.example`:
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

Generate/persist Grafana secrets with `make observability-bootstrap`.

<a id="ports"></a>
## Ports, networks, volumes

- Public endpoints:
  - Grafana only (via Traefik)
- Internal-only by default:
  - Prometheus
  - Loki
- Networks:
  - `proxy` (Grafana and Prometheus for internal scraping of Traefik)
  - `observability-internal`
- Volumes:
  - `grafana-data`
  - `prometheus-data`
  - `loki-data`
  - `alloy-data`

<a id="security"></a>
## Security notes

- Prometheus and Loki are not exposed publicly by default.
- Traefik metrics are scraped internally (Prometheus joins `proxy` for internal reachability only).
- Traefik access logs are JSON-formatted and configured to drop sensitive headers by default.
- Alloy requires read access to Docker metadata/logs; mounts are read-only where possible.

<a id="troubleshooting"></a>
## Troubleshooting

- If Grafana does not start, generate secrets:
  - `make observability-bootstrap`
- If Traefik metrics are empty, verify:
  - `services/traefik/traefik.yml` has `metrics.prometheus`
  - `prometheus` is attached to `proxy`
- If CTFd panels are empty, this is expected when `ctfd` is not running; Traefik-only mode is supported.

Hosts mapping note:
- If you manage `ENDPOINTS` manually, add `grafana` before running `make hosts-apply`.
- Or clear `ENDPOINTS` and rely on host auto-discovery from `Host()` rules.

<a id="related"></a>
## Related pages

- [Root README](../../README.md)
- [Traefik](../traefik/README.md)
- [CTFd](../ctfd/README.md)
