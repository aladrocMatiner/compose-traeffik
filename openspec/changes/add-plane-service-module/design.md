## Context
The repository already follows a strong module pattern: optional Compose profiles, Traefik-centric routing, preflight checks, bootstrap scripts, and smoke-test-driven quality gates. A Plane module should reuse that pattern instead of introducing a separate orchestration model.

The requested integration must keep Step-CA, Keycloak, and observability optional:
- Step-CA should remain one TLS mode option, not a Plane requirement.
- Keycloak SSO should be opt-in and should not block local/basic Plane usage.
- Observability should be additive and should not force operators to deploy Grafana tooling to run Plane.

## Goals / Non-Goals
- Goals:
  - Add a first-class Plane module behind Traefik.
  - Preserve existing TLS mode behavior, including optional Step-CA.
  - Provide optional Keycloak OIDC integration contract with safe defaults.
  - Provide optional observability hooks compatible with existing stack patterns.
  - Keep workflows repo-native (Make/bootstrap/guardrails/tests/docs).
- Non-Goals:
  - Full production-grade HA/disaster recovery for Plane.
  - Mandatory identity-provider setup.
  - Mandatory observability stack setup.

## Decisions
- Decision: Use `profile: plane` with lifecycle targets mirroring other modules.
  - Rationale: minimizes operator surprise and keeps workflow uniform.
- Decision: Route Plane only through Traefik HTTPS with existing middleware/TLS resolver wiring.
  - Rationale: consistent ingress hardening and TLS mode reuse.
- Decision: Keep Step-CA integration indirect via existing `TLS_CERT_RESOLVER` contract.
  - Rationale: avoids coupling Plane to CA internals while preserving Mode C support.
- Decision: Make Keycloak integration explicit and opt-in via Plane OIDC env toggles.
  - Rationale: supports SSO where needed without breaking default local usage.
- Decision: Add observability hooks as optional metadata/config, not as runtime requirement.
  - Rationale: keeps base Plane deployment lightweight and compatible with current optional observability model.

## Risks / Trade-offs
- Risk: Plane upstream topology/env contract may evolve across releases.
  - Mitigation: explicit upstream verification tasks and image/version pinning before coding.
- Risk: Keycloak integration can fail silently if OIDC values are partial.
  - Mitigation: profile-gated validation that enforces complete OIDC config only when opt-in is enabled.
- Risk: Observability hooks might create accidental coupling to stack internals.
  - Mitigation: static, optional contracts with no hard dependency and clear docs.

## Migration Plan
1. Add proposal-scoped specs/tasks first (this change).
2. Implement Plane module compose and bootstrap in small increments.
3. Add optional integration toggles (Step-CA compatibility, Keycloak OIDC, observability hooks).
4. Add smoke tests and docs.
5. Validate via `openspec validate`, `make docs-check`, and service-specific tests.

Rollback path: disable `plane` profile and remove module artifacts without changing core Traefik/TLS workflows.

## Open Questions
- Which Plane deployment topology (single image vs split services) is best aligned with this repository's complexity threshold?
- Should Plane's optional Keycloak integration target only Keycloak, or a generic OIDC contract with Keycloak examples?
- Which observability signals are realistic for phase 1 (logs-only vs logs+metrics/traces)?
