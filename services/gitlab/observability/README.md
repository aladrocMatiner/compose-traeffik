[English](README.md) | [Svenska](README.sv.md) | [Espanol](README.es.md)

# GitLab observability (optional)

This directory documents optional observability hooks for the GitLab module.

## Included in the GitLab module

- Compose labels for log/health discovery (`com.compose-traeffik.observability.*`)
- Health endpoint reference (`/-/health`, `/-/readiness`, `/-/liveness`)
- Omnibus config toggle that disables bundled Prometheus/exporters by default when `GITLAB_OBSERVABILITY_ENABLED=false`

## Security defaults

- No telemetry/exporter ports are published to the host by default.
- No Traefik routers are created for telemetry endpoints by default.
- If you later integrate a Prometheus/Grafana/Loki stack, keep GitLab telemetry internal-only unless you explicitly document and protect public exposure.

## Suggested future integration

- Logs: collector tails Docker logs for `gitlab`
- Metrics: internal-only GitLab exporters / bundled Prometheus (explicit opt-in)
- Dashboards: add a GitLab app-pack after the observability stack exists
