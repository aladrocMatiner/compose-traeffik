# Change: Add Observability Option Policy for New Services

## Why
Recent service modules need optional observability integration, but the requirement is currently implicit and easy to miss. A cross-cutting spec is needed so every new service module plans and documents observability compatibility with secure defaults.

## What Changes
- Add a cross-cutting specification requiring all new service modules to define an optional observability integration strategy.
- Require secure defaults (telemetry not public by default), documentation, and smoke-test coverage for observability wiring.
- Apply the policy to future service proposals such as GitLab.

## Impact
- Affected specs: `service-observability-option`, `tests-docs`, `tests-suite`, `docs-endpoints-tls`
- Affected code (future implementations): service compose labels/config, guardrails, docs, tests
