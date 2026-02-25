## Context
The repository is growing via optional service modules. Some services can expose useful telemetry (metrics/logs) or need collector discovery labels, but the observability stack itself may be optional or live on another branch.

A cross-cutting policy is needed so new services consistently:
- remain functional without observability enabled
- avoid public telemetry exposure by default
- document integration paths and smoke-test the wiring

## Goals
- Define a reusable observability-option contract for future services.
- Keep the policy implementation-agnostic (works whether the stack is present or only planned).
- Reinforce security defaults in docs/tests.

## Non-Goals
- Mandate that every service ship Prometheus metrics.
- Mandate that the observability stack exists in every branch.
- Implement collector discovery conventions beyond requiring them to be documented and tested when introduced.
