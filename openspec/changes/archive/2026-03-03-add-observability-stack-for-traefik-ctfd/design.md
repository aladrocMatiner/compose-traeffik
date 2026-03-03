## Context
The repository already centralizes ingress through Traefik, making it the stable shared layer across deployments and the natural point for HTTP metrics and access logging. CTFd is the first planned app consumer, but the observability design should be reusable for future services, optional, secure-by-default, and aligned with existing service-module conventions.

## Goals
- Provide a profile-gated observability stack with Prometheus, Grafana, Loki, and a log collector.
- Provide strong default observability integration at the Traefik layer (metrics + access logs) while keeping exposure internal-only.
- Monitor Traefik requests/behavior and collect CTFd logs as the initial app integration with minimal app changes.
- Keep the module reusable for future Traefik-routed services without redesigning the stack.
- Expose only Grafana publicly through Traefik; keep internal observability backends private by default.
- Keep implementation detailed enough for a medium-capability coding agent.

## Non-Goals
- Production HA observability
- Alerting/notifications
- Host metrics / deep container metrics (phase 2)
- Public Prometheus/Loki endpoints

## Collector Choice: Alloy vs Promtail
This change plans Grafana Alloy as the log collection agent because Promtail is in deprecation/LTS. Alloy is more future-proof for Grafana/Loki ingestion in 2026.

Implementation note for the coding agent:
- Verify the chosen Alloy image tag and config syntax from official docs before coding.
- If Alloy configuration proves too risky for the selected version, a separate follow-up proposal may swap to Promtail, but this change SHOULD NOT silently change the collector without updating the proposal/deltas.

## Proposed Topology
`services/observability/compose.yml` under profile `observability` defines:
- `grafana` (public via Traefik on `proxy` + internal observability network)
- `prometheus` (internal-only on observability network)
- `loki` (internal-only on observability network)
- `alloy` (internal-only, mounts Docker logs/socket for scraping container logs)

Collector trust boundary:
- Alloy will likely require read access to Docker container logs and Docker metadata (commonly `/var/run/docker.sock` and `/var/lib/docker/containers`).
- This expands observability-module privileges and MUST be documented clearly in the module security notes.
- Mounts SHOULD be read-only wherever possible.

Networks:
- `proxy` for Grafana (Traefik routing)
- a new internal observability network (e.g. `observability-internal`) for Prometheus/Loki/Alloy/Grafana communication

Important connectivity note (must be explicit in implementation):
- Prometheus needs network reachability to Traefik's internal metrics endpoint.
- The implementation MUST choose one explicit pattern and document it:
  - attach `prometheus` to `proxy` and scrape `http://traefik:8080/metrics`, or
  - attach `traefik` to the observability network and scrape there.
- The preferred phase-1 path is attaching `prometheus` to `proxy` while keeping Prometheus internal-only (no host port, no public router).
- This MUST be documented explicitly because joining the `proxy` network is for internal scraping only and does not by itself make `prometheus` publicly reachable.

Persistence (phase 1):
- named volume for Grafana data
- named volume for Loki data
- Prometheus data volume optional but recommended (pin in compose)

Retention / disk safety (phase 1):
- The module SHOULD ship bounded local retention defaults for Prometheus and Loki (via config and/or startup flags) to reduce disk-fill risk.
- Defaults can be modest and overridable through `.env` variables.

## Reuse Model (Traefik-first, app-pack extensions)
The observability stack is designed as a shared platform module:
- Core telemetry (Traefik metrics + Traefik logs + Grafana/Prometheus/Loki plumbing) is generic and useful for any deployment behind Traefik.
- App-specific observability content (e.g., CTFd log queries/panels) is treated as an initial integration pack within the same module.
- The file layout SHOULD make it obvious where future service-specific dashboards/queries or Alloy filters can be added without changing the core stack topology.

Implementation guidance for a medium-capability agent:
- Keep core configs and app-specific provisioning separated by file naming or directories (for example, `core-*` vs `ctfd-*`).
- Avoid hard-failing the stack when app-specific containers (like `ctfd`) are absent; app-specific dashboards may simply show no data.

## Traefik Instrumentation Changes (Strong Default Integration)
Traefik static config (`services/traefik/traefik.yml`) will be extended to support observability:
- enable Prometheus metrics with router/service/entrypoint labels
- enable access logs in structured (JSON) format
- do not publish new host ports for metrics
- do not create public Traefik routers for `prometheus@internal` metrics by default

Design choice:
- Traefik observability instrumentation is expected to be enabled by default (not gated by the `observability` profile), because Traefik is always present and the metrics endpoint remains internal-only.
- The observability profile controls the consumers (Prometheus/Grafana/Loki/Alloy), not whether Traefik emits telemetry.
- Access-log configuration SHOULD avoid logging sensitive request headers by default (for example `Authorization`, `Cookie`, and `Set-Cookie`) to reduce credential leakage risk in Loki.

Prometheus scrape target (phase 1):
- Traefik internal metrics endpoint via Docker network (`traefik` service, internal entrypoint, e.g. `http://traefik:8080/metrics`)
- Prometheus self metrics (optional, useful for troubleshooting)

## CTFd Telemetry Coverage (Initial App Integration Pack)
CTFd telemetry in phase 1 is log-based and SHOULD be treated as the first app-specific integration:
- configure CTFd to emit access/error logs to stdout/stderr (or container-captured logs)
- Alloy collects Docker container logs for `ctfd` and `traefik`
- Loki stores logs
- Grafana ships with pre-provisioned Loki and Prometheus data sources plus starter dashboards/panels or explored queries

Because CTFd lacks a native Prometheus endpoint, application metrics for CTFd are explicitly out of scope in this change.

## Grafana Exposure and Security
- Public endpoint: `https://grafana.${DEV_DOMAIN}` (hostname label configurable via `.env` e.g. `GRAFANA_HOSTNAME=grafana`)
- Grafana routed through Traefik with standard HTTP/HTTPS router pattern and `security-headers@file`
- Grafana native auth remains enabled (no anonymous access)
- Admin password generated and persisted via `make observability-bootstrap`
- Prometheus and Loki remain non-routed/internal-only by default to reduce attack surface

## Environment and Bootstrap
Planned `.env.example` additions (exact names/version compatibility to verify before implementation):
- `GRAFANA_HOSTNAME=grafana`
- `GRAFANA_IMAGE=<pinned-tag>`
- `PROMETHEUS_IMAGE=<pinned-tag>`
- `LOKI_IMAGE=<pinned-tag>`
- `ALLOY_IMAGE=<pinned-tag>`
- `GRAFANA_ADMIN_USER=admin`
- `GRAFANA_ADMIN_PASSWORD=`
- `GRAFANA_SECRET_KEY=` (optional but recommended)
- `PROMETHEUS_RETENTION_TIME=` (optional tuning)
- `LOKI_RETENTION_PERIOD=` (optional tuning / documented if supported in selected config mode)

Bootstrap flow:
- `scripts/observability-bootstrap.sh`
- `make observability-bootstrap`
- generates/persists missing Grafana secrets only; no UI htpasswd files required in phase 1 because only Grafana is exposed and uses native auth

## Guardrails
Profile-gated checks when `observability` is enabled:
- require non-placeholder `GRAFANA_ADMIN_PASSWORD`
- validate `GRAFANA_HOSTNAME` format
- optionally warn (not fail) when no app-specific telemetry targets such as `ctfd` are enabled, and document that app dashboards may be empty while Traefik telemetry still works
- ensure no observability-specific checks block unrelated stacks when profile disabled

## Testing Strategy (Phase 1)
Add no-sudo/static smoke tests for:
- observability compose wiring (services, profiles, networks, no public ports for Prometheus/Loki, Grafana labels)
- Traefik static observability config presence (metrics + accesslog JSON)
- bootstrap idempotency for Grafana secrets
- guardrails profile gating
- Makefile target wiring and help text
- Grafana provisioning files reference Prometheus and Loki datasources
- app-pack tolerance (e.g., CTFd-specific queries/provisioning present but no hard runtime dependency in static tests)

Runtime ingestion validation (logs appearing in Grafana) is out of scope for smoke tests and SHOULD be documented as manual verification steps.

## Documentation Scope
- Root `README*.md`:
  - `observability` profile usage
  - endpoint list entry for Grafana (`https://grafana.<DEV_DOMAIN>`)
  - note that Prometheus/Loki are internal-only by default
- `services/observability/README*.md`:
  - architecture, data flow, and security posture
  - reusable observability model for future Traefik-routed services
  - bootstrap + Make targets
  - dashboards/datasources provisioning
  - manual verification steps for Traefik telemetry and the initial CTFd integration
  - `hosts-*` / `ENDPOINTS` note for adding `grafana` host mapping (or using auto-discovery mode)
- `scripts/README.md`: `observability-bootstrap.sh`
- `tests/README.md`: new smoke tests
- `docs.manifest.json`: add `observability` service docs

## Upstream Verification Checklist (must do first in implementation)
1. Pin image tags for Grafana, Prometheus, Loki, and Alloy.
2. Verify Alloy config syntax and Docker log discovery method for chosen version.
3. Verify Traefik v3 static config syntax for Prometheus metrics and access logs.
4. Verify Grafana env vars (`GF_SECURITY_ADMIN_USER`, `GF_SECURITY_ADMIN_PASSWORD`, `GF_SECURITY_SECRET_KEY`) for chosen image tag.
5. Verify Loki single-binary config schema for chosen version.

## Recommended Implementation Order
1. Add Traefik observability config updates (metrics + access logs)
2. Add `services/observability/compose.yml` and config files
3. Add `.env.example` + `observability-bootstrap` + Make targets
4. Add guardrails
5. Add smoke tests and `scripts/healthcheck.sh` integration
6. Update docs and `docs.manifest.json`
7. Run OpenSpec validation, docs-check, and smoke tests
