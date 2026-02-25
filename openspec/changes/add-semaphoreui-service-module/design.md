## Context
Semaphore UI (`semaphoreui/semaphore`) is a web UI/API for Ansible/Terraform/OpenTofu workflows. In this repository it should follow the same integration model as other services:
- optional Compose profile
- Traefik-only public access path
- `.env` + bootstrap scripts for secrets and defaults
- preflight guardrails
- service-specific smoke tests and multilingual docs

The requested optional Keycloak integration increases config complexity because Semaphore's OIDC provider configuration is JSON-based. The requested optional observability integration should be compatible with the reusable observability stack pattern (Traefik metrics/logs + Loki/collector + optional service metrics), while keeping Semaphore functional when observability is disabled.

## Goals
- Add a `semaphoreui` service module that works behind Traefik on a subdomain.
- Use a repo-managed PostgreSQL dependency with internal-only networking.
- Provide optional OIDC login with Keycloak using explicit `.env` toggles.
- Provide optional observability hooks that are safe by default and documented.
- Make implementation straightforward for a medium-capability coding agent by reducing ambiguity in config strategy and validation steps.

## Non-Goals
- Build/ship the observability stack itself in this branch.
- Build/ship the Keycloak service module in this branch.
- Implement advanced HA scaling or production clustering for Semaphore.

## Architecture Decisions

### 1) Service layout and profile
- Service directory: `services/semaphoreui/`
- Compose profile: `semaphoreui`
- Main services:
  - `semaphoreui`
  - `semaphoreui-db` (PostgreSQL)

### 2) Public exposure path
- Traefik serves `https://semaphore.<DEV_DOMAIN>` by default (hostname configurable via `.env`).
- Semaphore UI/API MUST not publish host ports directly by default.
- DB MUST remain internal-only (no `ports:` by default).

### 3) Semaphore configuration strategy (implementation target)
To keep the module consistent with repo patterns while supporting OIDC JSON configuration:
- Prefer container env vars for base configuration (`SEMAPHORE_*`, DB, admin bootstrap, web root, etc.).
- Generate the OIDC provider JSON value from repo-level env vars in `scripts/semaphoreui-bootstrap.sh` and persist it in `.env` as a single escaped value (or a documented multiline-safe equivalent) under a repo-level variable (e.g. `SEMAPHOREUI_OIDC_PROVIDERS_JSON`).
- Map that repo-level variable into the container's `SEMAPHORE_OIDC_PROVIDERS` env only when OIDC is enabled.

This avoids introducing a rendered config file unless upstream behavior or escaping proves unreliable.

### 4) Optional Keycloak integration model
- OIDC is disabled by default.
- When enabled, Semaphore config is driven from repo-level variables (`SEMAPHOREUI_OIDC_*`) that describe the Keycloak realm/client and provider metadata URL.
- The module MUST support both:
  - a future in-repo Keycloak module (e.g. `https://keycloak.<DEV_DOMAIN>`)
  - an external Keycloak deployment reachable by URL
- Guardrails MUST only enforce OIDC-specific secrets/URLs when OIDC is enabled.

### 5) Optional observability integration model
Observability is modeled as a service-level option, not a hard dependency.

Baseline behavior:
- Semaphore works with observability disabled.
- No public metrics/management endpoint exposure by default.
- Logs remain available through standard container logs.

When observability option is enabled:
- Service emits/retains stable labels or metadata to support collector discovery.
- Documentation describes expected integration path with the Grafana Labs stack pattern used in another branch.
- If upstream exposes metrics, plan MUST keep the endpoint internal-only and document the scrape path/port.
- If upstream metrics are not available or not practical, docs MUST explicitly state logs-only integration and the gap.

### 6) Runtime validation expectations
Because reverse proxy + OIDC flows can fail in subtle ways, runtime validation for implementation must include:
- Traefik route (`/`) behind TLS
- login page render
- API sanity (`/api/ping` or version-appropriate endpoint)
- OIDC login redirect URL generation sanity when OIDC is enabled (without requiring full Keycloak login automation in smoke tests)

## Risks and Mitigations
- **OIDC JSON escaping in `.env` is fragile**: mitigate with a bootstrap-generated canonical JSON value + smoke tests + docs.
- **Semaphore reverse proxy behavior may require specific web-root/proxy settings**: add mandatory upstream verification task before coding.
- **Observability expectations may exceed upstream capabilities (metrics)**: define logs-only fallback explicitly and verify upstream before implementation.
