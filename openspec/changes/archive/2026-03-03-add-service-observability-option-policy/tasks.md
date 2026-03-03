## 1. Specification and Policy Definition
- [x] 1.1 Add a new cross-cutting spec `service-observability-option`.
- [x] 1.2 Define secure-default requirements (no public telemetry endpoints by default).
- [x] 1.3 Define minimum planning/documentation requirements for logs/health/metrics integration points.
- [x] 1.4 Define minimum smoke-test expectations for observability wiring.

## 2. Cross-Spec Alignment
- [x] 2.1 Update `docs-endpoints-tls` to require documentation of telemetry exposure posture for new services where relevant.
- [x] 2.2 Update `tests-docs` and/or `tests-suite` to require observability wiring tests to be documented for new services.
- [x] 2.3 Ensure wording supports services that only provide logs/health and no native metrics.

## 3. Validation and Handoff
- [x] 3.1 Run `openspec validate add-service-observability-option-policy --strict`.
- [x] 3.2 Confirm the GitLab proposal references and follows this policy.
