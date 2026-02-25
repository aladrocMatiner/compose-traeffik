[English](README.md) | [Svenska](README.sv.md) | [Espanol](README.es.md)

# Observabilidad de Semaphore UI

La observabilidad de Semaphore UI en este modulo es opcional y segura por defecto.

## Que esta soportado

- Logs: soportado mediante logs del contenedor (`docker logs semaphoreui`) y labels de discovery para collectors.
- Metricas: este modulo no expone metricas por defecto (Semaphore no ofrece endpoint Prometheus nativo en el contrato upstream verificado para esta implementacion).

## Activar la opcion

Configura en `.env`:

```bash
SEMAPHOREUI_OBSERVABILITY_ENABLED=true
SEMAPHOREUI_OBSERVABILITY_DISCOVERY=labels
```

Esto anyade labels estables para collectors/dashboards. No despliega Grafana/Prometheus/Loki.

## Puntos clave

- No se crea un router publico de telemetria en Traefik.
- El servicio debe funcionar normal con observabilidad desactivada.
- Si existe una stack de observabilidad en otra rama/entorno, usa labels del servicio para discovery.

## Layout futuro de app-pack (reservado)

Si se anyaden dashboards/queries mas adelante, mantenlos en:
- `services/semaphoreui/observability/dashboards/`
- `services/semaphoreui/observability/queries/`
