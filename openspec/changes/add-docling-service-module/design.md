## Context
The repository uses a consistent service-module model: optional Compose profiles, Traefik-centered ingress, env preflight checks, bootstrap scripts, and smoke-test-driven confidence gates. A Docling module should reuse that model to avoid introducing a parallel operational path.

Docling has explicit runtime controls for UI/API, auth, worker engines (local/RQ), and OTEL/Prometheus. It therefore aligns well with this repo's approach, but requires careful defaults to keep setup lightweight and secure.

## Goals / Non-Goals
- Goals:
  - Add a first-class Docling module behind Traefik.
  - Preserve TLS mode compatibility including optional Step-CA mode.
  - Provide explicit Keycloak integration contract without forcing Keycloak on baseline runs.
  - Provide optional observability wiring via Docling OTEL/metrics toggles.
  - Keep workflows consistent with existing repo commands and tests.
- Non-Goals:
  - Comprehensive production autoscaling strategy for all Docling workloads.
  - Mandatory GPU image selection in default path.
  - Full identity-provider bootstrapping automation.

## Decisions
- Decision: Use profile `docling` with dedicated module lifecycle commands.
  - Rationale: keeps parity with existing modules and supports targeted operations.
- Decision: Expose Docling only via Traefik HTTPS router (`docling.<DEV_DOMAIN>`).
  - Rationale: consistent ingress and TLS hardening controls.
- Decision: Keep TLS behavior tied to shared `TLS_CERT_RESOLVER` contract.
  - Rationale: supports Mode A/B/C without custom Docling TLS logic.
- Decision: Model Keycloak integration as an explicit ingress/auth contract (disabled by default).
  - Rationale: Docling supports API key auth and OAuth-proxy patterns; this avoids hard coupling.
- Decision: Make observability optional using Docling native telemetry toggles.
  - Rationale: additive observability with no runtime dependency when disabled.
- Decision: Start with CPU-oriented default image strategy and optional advanced variants.
  - Rationale: lowest-friction baseline while keeping extension points for GPU deployments.

## Risks / Trade-offs
- Risk: Upstream Docling image tags and variant naming can change.
  - Mitigation: verify and pin selected image strategy before coding.
- Risk: Keycloak integration ambiguity (app-native vs proxy-native) may cause misconfiguration.
  - Mitigation: enforce clear env contract and profile-gated validation for enabled auth mode.
- Risk: RQ/Redis optional topology increases operational complexity.
  - Mitigation: phase-1 default to simple/local engine with optional RQ path documented and tested statically.
- Risk: Observability toggles can expose accidental coupling.
  - Mitigation: keep telemetry hooks optional and internal by default.

## Migration Plan
1. Add change-scoped specs/proposal/tasks (this change).
2. Implement module compose and bootstrap defaults.
3. Add integration contracts (Step-CA compatibility, Keycloak, observability).
4. Add smoke tests and docs updates.
5. Validate via OpenSpec, docs checks, and module smoke suites.

Rollback path: disable `docling` profile and remove module artifacts; existing stack remains unchanged.

## Open Questions
- Should phase 1 include optional Redis/RQ services in-module or defer to external Redis only?
- Should keycloak integration default to API-key + optional Traefik forward-auth, or OAuth-proxy sidecar pattern?
- Which Docling image tag policy is acceptable for this repo (`stable` channel vs explicit dated/version tags)?
