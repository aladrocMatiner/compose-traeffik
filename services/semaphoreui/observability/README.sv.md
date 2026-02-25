[English](README.md) | [Svenska](README.sv.md) | [Espanol](README.es.md)

# Semaphore UI observability

Observability-stod for Semaphore UI i denna modul ar valfritt och sakert som standard.

## Vad som stods

- Loggar: stods via containerloggar (`docker logs semaphoreui`) och discovery-labels for collectors.
- Metrik: exponeras inte av denna modul som standard (Semaphore har ingen inbyggd Prometheus-endpoint i det verifierade upstream-kontraktet for denna implementation).

## Aktivera optionen

Satt i `.env`:

```bash
SEMAPHOREUI_OBSERVABILITY_ENABLED=true
SEMAPHOREUI_OBSERVABILITY_DISCOVERY=labels
```

Detta lagger till stabila labels for collectors/dashboards. Det deployar inte Grafana/Prometheus/Loki.

## Viktiga punkter

- Ingen publik telemetri-router skapas i Traefik.
- Tjansten ska fungera normalt nar observability ar avstangt.
- Om en observability-stack finns i annan branch/miljo, anvand service-labels for discovery.

## Framtida app-pack-layout (reserverad)

Om dashboards/queries laggs till senare, placera dem under:
- `services/semaphoreui/observability/dashboards/`
- `services/semaphoreui/observability/queries/`
