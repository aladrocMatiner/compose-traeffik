# Change: Add Keycloak Service Module (Traefik + Optional Observability Hooks)

## Why
The repository currently lacks an identity provider service module. Keycloak is a common requirement for SSO/OIDC testing, but it needs reverse-proxy-aware configuration behind Traefik and a consistent integration pattern with the repo's Make/docs/tests workflows.

The user also wants Keycloak to be ready for optional monitoring using the Grafana Labs observability stack pattern used in another branch/project, without making observability a hard dependency for the base Keycloak deployment.

## What Changes
- Add a new optional `keycloak` service module (`profile: keycloak`) using Keycloak + PostgreSQL behind Traefik HTTPS.
- Add bootstrap flow for Keycloak admin and DB credentials persisted in `.env`.
- Add preflight guardrails for Keycloak hostname/proxy/TLS/reverse-proxy-safe settings and observability toggles.
- Define optional observability integration hooks for Keycloak (metrics/logs readiness) that activate only when an observability option/profile is enabled.
- Add Make targets, smoke tests, and multilingual documentation for the Keycloak module.
- Document scope limitations (no realm import automation / no advanced HA / no full day-2 backup strategy in this change).

## Impact
- Affected specs: `keycloak-service` (new), `bootstrap-secrets`, `compose-wrapper`, `guardrails`, `docs-endpoints-tls`, `docs-multilang`, `scripts-docs`, `tests-docs`, `tests-suite`
- Affected code (planned): `services/keycloak/`, `Makefile`, `scripts/*`, `.env.example`, docs/test runbooks
