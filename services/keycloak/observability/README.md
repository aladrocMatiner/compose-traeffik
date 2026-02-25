# Keycloak Observability Hooks (Optional)

This module does not require the observability stack at runtime.

When `KEYCLOAK_OBSERVABILITY_ENABLED=true`:
- Keycloak enables internal metrics on the management interface (`/metrics`, default port `9000`)
- The container exposes observability discovery labels (default strategy: `labels`)
- No public Traefik metrics router is created by default

Suggested reusable app-pack pattern for a Grafana/Prometheus/Loki collector stack:
- Prometheus scrape target: `keycloak:9000/metrics` (same Docker network / internal connectivity)
- Logs: collect container logs for `keycloak` with labels
- Dashboards/queries: store service-specific assets under an observability app-pack folder in the observability stack branch/module
