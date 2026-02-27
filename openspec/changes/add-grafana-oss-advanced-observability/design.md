## Context
The repository already ships an optional observability module (`Grafana + Prometheus + Loki + Alloy`) with Traefik telemetry as the baseline. That baseline is valuable but incomplete for incident triage where request latency spikes, application hotspots, or intermittent errors require traces and profiles in addition to logs/metrics.

The change must remain compatible with local self-hosted workflows:
- Docker Compose based
- profile-gated optional modules
- internal-only backends by default
- no-sudo smoke tests

## Goals / Non-Goals
- Goals:
  - Add distributed tracing with Tempo OSS.
  - Add continuous profiling with Pyroscope OSS.
  - Keep logs/metrics behavior stable.
  - Add a repeatable synthetic check path using k6 OSS.
  - Preserve secure defaults (internal-only for observability backends except Grafana).
- Non-Goals:
  - Multi-node/high-availability observability.
  - Mimir deployment in this phase.
  - Mandatory app instrumentation in every service on day one.

## Decisions
- Decision: Keep the `observability` profile as the single module entry point.
  - Rationale: preserves current operator workflow and avoids profile fragmentation.
- Decision: Tempo and Pyroscope will be internal-only by default (no host ports, no Traefik routers).
  - Rationale: matches existing Prometheus/Loki security posture.
- Decision: Alloy remains the central collector/forwarder, using OTLP for traces and `pyroscope.receive_http` for profiles.
  - Rationale: one data-plane component for logs/traces/profiles is easier to reason about and test, while staying compatible with current Alloy components.
- Decision: k6 will run on-demand via a Make target and Compose wrapper, not as a long-running service.
  - Rationale: synthetic checks are workload events, not persistent infrastructure.
- Decision: Mimir is explicitly deferred.
  - Rationale: object storage, retention, and tenancy complexity are disproportionate for the current single-node scope.

## Risks / Trade-offs
- Risk: Signal pipeline complexity increases (Alloy config grows significantly).
  - Mitigation: separate core blocks in Alloy config by signal type and add smoke coverage for key endpoints.
- Risk: Traces/profiles may remain empty if apps are not instrumented.
  - Mitigation: document this clearly; add starter synthetic traffic and dashboard guidance.
- Risk: k6 integration path may vary depending on selected output backend.
  - Mitigation: pin one supported output path for phase 1 and test it in smoke/static checks.

## Migration Plan
1. Add Tempo and Pyroscope service definitions and configs.
2. Extend Alloy and Grafana datasources.
3. Add environment variables and guardrails.
4. Add Make targets and tests.
5. Update docs and examples.

Rollback is straightforward: disable/remove new services and keep existing metrics/logs stack unchanged.

## Resolved Choices
- Tempo and Pyroscope retention defaults are aligned with Loki (`168h`) and remain overridable in `.env`.
- k6 output path is Prometheus remote-write receiver (`experimental-prometheus-rw`) to integrate with Grafana/Prometheus workflows.
- Documentation includes explicit ingest endpoints for traces (`alloy:4317/4318`) and profiles (`alloy:9999`).
