## Context
Keycloak is stateful and reverse-proxy-sensitive. The repo pattern is Docker Compose + Traefik + Make wrappers + smoke tests + multilingual docs. The implementation must fit that pattern while avoiding common Keycloak misconfiguration behind proxies (hostname/proxy headers/TLS assumptions).

Observability is optional in this branch. The design should prepare Keycloak metrics/log hooks so a reusable Grafana/Prometheus/Loki/collector stack can scrape/ingest data when that stack exists and is enabled, but Keycloak must run correctly without observability services.

## Goals / Non-Goals
- Goals:
- Provide a repo-native Keycloak module behind Traefik HTTPS with sane defaults for local/lab use.
- Make the module bootstrap-able, testable, and documented like other services.
- Prepare optional observability integration points (metrics/logs) without adding a hard runtime dependency.

- Non-Goals:
- No HA/multi-node Keycloak cluster.
- No production hardening exhaustive guide (mTLS, external cache, external DB HA).
- No realm import/export automation in MVP.
- No full Keycloak backup/restore runbooks in this change (separate day-2 change if needed).

## Architecture Decisions
- Decision: Keycloak runs as an optional compose service plus a local Postgres dependency.
- Rationale: aligns with current repo service module pattern and keeps setup simple for local SSO testing.

- Decision: TLS terminates at Traefik; Keycloak is configured for reverse proxy awareness.
- Rationale: consistent with repo edge model and reduces Keycloak certificate management complexity.

- Decision: Keycloak observability is optional and profile-gated.
- Rationale: base Keycloak deployment should not require Grafana/Prometheus/Loki/collector containers.

## Planned Module Shape
- `services/keycloak/compose.yml`
- `services/keycloak/README.md`, `README.es.md`, `README.sv.md`
- (optional assets) `services/keycloak/observability/` for dashboards/scrape hints/templates, if used
- `scripts/keycloak-bootstrap.sh`
- Make targets (`keycloak-up/down/restart/logs/status`, `keycloak-bootstrap`)
- smoke tests for compose config, make wiring, guardrails, and optional observability wiring

## Key Technical Risks to Handle in Planning
- Upstream Keycloak env var naming changes (bootstrap admin vars, proxy settings, metrics settings) across versions
- Hostname/proxy header misconfiguration causing login/callback issues behind Traefik
- Metrics exposure accidentally public when observability is enabled
- Drift between base Keycloak config and observability-enabled config path
- Management/health/metrics port confusion (main HTTP port vs management interface) causing broken probes or unsafe exposure

## Compatibility / Integration Notes
- Base stack (`make up`) should remain unchanged unless Keycloak profile is enabled.
- Keycloak docs must state endpoint, profile, bootstrap flow, and reverse proxy assumptions.
- Observability readiness must be documented as optional and non-blocking when observability stack is absent.
- Runtime validation should include at least login page reachability plus one admin/token/API sanity check, not only an HTTP 200 on the landing page.
