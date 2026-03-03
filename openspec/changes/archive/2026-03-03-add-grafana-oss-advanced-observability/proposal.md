# Change: Expand observability module with Grafana OSS advanced signals

## Why
The current observability module covers metrics and logs (`Prometheus + Loki + Grafana + Alloy`) and is useful for baseline operations. To debug distributed failures faster and reduce blind spots, the stack needs first-class support for traces, continuous profiling, and synthetic checks using additional Grafana OSS tools.

## What Changes
- Add `tempo` (Grafana Tempo OSS) to the observability module as an internal-only backend for distributed tracing.
- Add `pyroscope` (Grafana Pyroscope OSS) as an internal-only backend for continuous profiling.
- Extend Alloy configuration to ingest OTLP traces and forward them to Tempo, plus ingest profiles via `pyroscope.receive_http` and forward them to Pyroscope, while preserving existing log ingestion to Loki.
- Extend Grafana provisioning with Tempo and Pyroscope datasources plus starter dashboards/panels for trace/profile exploration.
- Add an on-demand `k6` execution path for synthetic HTTP checks against Traefik-routed endpoints and expose results in Grafana-compatible metrics flow.
- Add environment variables, Make targets, preflight validations, smoke tests, and docs for the expanded stack.
- Keep Mimir out of scope in this phase to avoid introducing distributed object storage and high-operational-complexity requirements.

## Impact
- Affected specs:
  - `observability-stack`
  - `compose-wrapper`
  - `guardrails`
  - `docs-endpoints-tls`
  - `tests-suite`
- Affected code (planned):
  - `services/observability/compose.yml`
  - `services/observability/alloy/config.alloy`
  - `services/observability/grafana/provisioning/datasources/datasources.yml`
  - `services/observability/grafana/dashboards/`
  - `services/observability/tempo/`
  - `services/observability/pyroscope/`
  - `.env.example`
  - `scripts/validate-env.sh`
  - `Makefile`
  - `tests/smoke/`
  - `services/observability/README*.md`
  - `README*.md`

## Dependencies / Order
- This proposal extends the existing observability module and assumes the current `observability` profile is already available.
- Implementation should land in phases: tracing/profiling plumbing first (Tempo/Pyroscope/Alloy/Grafana), then synthetic checks (`k6`) and extra dashboards/tests/docs.
