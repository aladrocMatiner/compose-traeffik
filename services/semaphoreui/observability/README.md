[English](README.md) | [Svenska](README.sv.md) | [Espanol](README.es.md)

# Semaphore UI observability

Semaphore UI observability support in this module is optional and safe-by-default.

## What is supported

- Logs: supported through container logs (`docker logs semaphoreui`) and collector discovery labels.
- Metrics: not exposed by this module by default (Semaphore does not provide a native Prometheus endpoint in the verified upstream contract for this implementation).

## Enable the option

Set in `.env`:

```bash
SEMAPHOREUI_OBSERVABILITY_ENABLED=true
SEMAPHOREUI_OBSERVABILITY_DISCOVERY=labels
```

This adds stable labels for downstream collectors/dashboards. It does not deploy Grafana/Prometheus/Loki.

## Key points

- No public telemetry router is created in Traefik.
- The service must work normally with observability disabled.
- If an observability stack is enabled in another branch/environment, use service labels to discover the container.

## Future app-pack layout (reserved)

If dashboards/queries are added later, keep them under:
- `services/semaphoreui/observability/dashboards/`
- `services/semaphoreui/observability/queries/`
