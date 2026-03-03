# Change: Add reusable observability stack for Traefik-based deployments (Prometheus + Grafana + Loki)

## Why
The project needs an operator-friendly way to inspect traffic, errors, and platform behavior without leaving the Compose/Traefik workflow. A dedicated observability module should be reusable across multiple application deployments (CTFd now, other services later) while keeping the stack optional and self-hosted.

## Discovery Summary (for implementer)
- Traefik is already the ingress and currently runs without Prometheus metrics or access logs configured.
- The repo favors profile-gated optional modules with `services/<module>/compose.yml`, Makefile wrappers, preflight checks, smoke tests, and multilingual docs.
- CTFd does not provide a built-in Prometheus metrics endpoint in the upstream project; logs are the reliable phase-1 telemetry source for CTFd.
- Traefik supports Prometheus metrics and access logs in static config.
- Grafana Loki requires a collector/agent for container logs; this change plans to use Grafana Alloy (preferred over Promtail due Promtail deprecation/LTS status).
- Traefik is the stable shared layer across deployments, so strong default integration at the Traefik layer gives the best reuse/consistency.

## What Changes
- Add a new optional profile-backed module `services/observability/compose.yml` containing:
  - `prometheus`
  - `grafana`
  - `loki`
  - `alloy` (log collection agent for Traefik and app containers)
- Add observability configuration files under `services/observability/` (Prometheus scrape config, Loki config, Alloy pipeline config, Grafana datasources/dashboards provisioning).
- Expose Grafana via Traefik at `https://grafana.<DEV_DOMAIN>` using HTTPS and repo routing conventions.
- Keep Prometheus and Loki internal-only by default (no host port and no public Traefik routers unless a future change adds explicit opt-in exposure).
- Update Traefik static config to emit Prometheus metrics and structured access logs suitable for scraping/ingestion as a strong default integration (internal-only exposure), with sensitive-header logging minimized by default.
- Structure observability configs so the stack is reusable for future Traefik-routed app modules, with CTFd as the initial app integration pack.
- Add `.env.example`, bootstrap, guardrails, Make targets, smoke tests, and docs for the observability module.

## Telemetry Scope (Phase 1)
- Traefik (baseline for all deployments): Prometheus metrics + access logs (Loki via Alloy)
- CTFd (initial app integration pack): container/application logs (Loki via Alloy)
- Grafana/Prometheus/Loki self-metrics/logs are available for stack troubleshooting
- CTFd application-level Prometheus metrics are out of scope (not natively exposed upstream)

## Non-Goals (Phase 1)
- Alertmanager, alert routing, or notification channels
- cAdvisor / node-exporter / host metrics (can be a follow-up change)
- Public exposure of Prometheus or Loki UIs/APIs
- Long-term retention tuning for production scale

## Security / Operations Notes (Phase 1)
- The observability collector (Alloy) may require read access to Docker logs and Docker metadata, which increases observability-module trust; this MUST be documented and mounts SHOULD be read-only where possible.
- Prometheus and Loki remain internal-only by default.
- Traefik observability is integrated strongly by default, but without creating new public metrics exposure.

## Impact
- Affected specs:
  - `observability-stack` (new)
  - `traefik-observability` (new)
  - `compose-wrapper`
  - `guardrails`
  - `bootstrap-secrets`
  - `docs-endpoints-tls`
- Affected code/docs (planned):
  - `services/observability/compose.yml`
  - `services/observability/{prometheus,loki,alloy,grafana}/...`
  - `services/observability/README*.md`
  - `services/traefik/traefik.yml`
  - `.env.example`
  - `scripts/observability-bootstrap.sh`
  - `scripts/validate-env.sh`
  - `Makefile`, `scripts/compose.sh`, `scripts/healthcheck.sh`, `tests/smoke/*`
  - `README*.md`, `scripts/README.md`, `tests/README.md`, `docs.manifest.json`

## Dependencies / Order
- The observability module SHOULD be implementable and runnable without `ctfd` enabled (Traefik-only observability is the baseline use case).
- The CTFd module change SHOULD land before adding/validating CTFd-specific log queries, panels, or dashboards in this observability module.
