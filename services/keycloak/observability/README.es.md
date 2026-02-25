[English](README.md) | [Svenska](README.sv.md) | [Espanol](README.es.md)

# Keycloak Observability Hooks (Opcional)

Este modulo no requiere el stack de observabilidad para funcionar.

Cuando `KEYCLOAK_OBSERVABILITY_ENABLED=true`:
- Keycloak habilita metricas internas en la interfaz de management (`/metrics`, puerto `9000` por defecto)
- El contenedor expone labels de discovery para observabilidad (estrategia por defecto: `labels`)
- No se crea router publico de metricas en Traefik por defecto
