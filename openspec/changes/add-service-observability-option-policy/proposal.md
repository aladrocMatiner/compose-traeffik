# Change: Require an Optional Observability Integration Contract for New Services

## Why
Recent service additions (e.g. Keycloak in another branch) benefit from a consistent pattern for optional observability integration, but the current `master` branch does not define this as a cross-cutting OpenSpec requirement.

Without a shared policy, each new service may handle telemetry exposure, docs, and smoke-test coverage differently, causing security drift and inconsistent integration with the reusable Grafana/Prometheus/Loki/collector stack pattern.

## What Changes
- Add a new cross-cutting capability spec `service-observability-option` that defines expectations for optional observability integration in new services.
- Require safe defaults (service must work without observability; no public telemetry exposure by default).
- Require documentation and smoke-test coverage for observability wiring when a service introduces observability toggles/hooks.
- Align existing cross-cutting specs (`services-layout`, `scripts-docs`, `tests-docs`, `tests-suite`) with this requirement.

## Impact
- Affected specs:
  - `service-observability-option` (new)
  - `services-layout`
  - `scripts-docs`
  - `tests-docs`
  - `tests-suite`
- Affected code: none (spec-only policy change)

## Note
If the same policy is merged to `master` from another branch first, this change should be dropped or rebased to avoid duplicate spec deltas.
