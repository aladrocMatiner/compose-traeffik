## Context
GitLab Omnibus is significantly heavier and more stateful than other services already integrated into the repo. It also embeds multiple internal components (NGINX, PostgreSQL, Redis, Sidekiq, exporters), which changes reverse proxy and observability design choices.

The project standard is `docker compose` modules routed through Traefik with TLS, `.env`-driven config, bootstrap scripts, preflight guardrails, smoke tests, and EN/SV/ES docs.

## Goals
- Provide a reproducible GitLab module that behaves like other repo services from the user perspective (`make <service>-up`, `-down`, `-status`, `-logs`).
- Use Traefik as the public TLS edge for GitLab HTTP(S).
- Support optional Keycloak OIDC without making Keycloak a hard dependency.
- Support optional observability wiring without exposing telemetry publicly by default.
- Keep implementation legible for a medium-capability coding agent.

## Non-Goals
- Tuning GitLab for production scale or HA.
- Implementing a full GitLab backup/restore/upgrade workflow in this change.
- Managing external infra such as NAS/NFS mounts or SMTP servers automatically.

## Architecture Decisions

### 1. GitLab Omnibus + Traefik (TLS termination at Traefik)
Use the official GitLab Omnibus container behind Traefik. TLS terminates at Traefik. Omnibus is configured with `external_url` set to HTTPS and internal NGINX listening on HTTP only.

Why:
- Matches repo Traefik pattern.
- Avoids dual TLS certificate management inside GitLab.
- Keeps implementation simpler than disabling bundled NGINX entirely.

### 2. HTTP and SSH surfaces are handled separately
- HTTP(S) UI/API: routed via Traefik (`gitlab.<DEV_DOMAIN>`)
- Git SSH: host port mapping (default non-conflicting port, e.g. `2424`) and documented clone URL/port behavior

Why:
- Traefik in this repo is focused on HTTP(S) routing.
- SSH through Traefik requires TCP routing complexity and additional certificates/listeners not needed for MVP.

### 3. Rendered Omnibus config fragment instead of giant env string
Do not put the full Ruby OIDC/proxy config into a single `.env` variable. Generate a repo-managed Omnibus config fragment/template from `.env` values during bootstrap/render.

Why:
- Ruby hash syntax in env strings is hard to review and easy to break.
- Templates are testable and better suited for optional blocks (OIDC, observability settings).
- Generated files can be placed in a predictable gitignored path and validated by smoke tests.

### 4. Observability compatibility is opt-in and safe by default
This module will include observability hooks (labels/logging/health checks and documented internal metrics wiring) but will not expose telemetry publicly by default and will not require an observability stack to be present.

Why:
- Preserves security defaults.
- Keeps GitLab module usable standalone.
- Enables future integration with the observability stack from another branch.

## Configuration Strategy
Planned `.env` groups (exact names to be verified with upstream docs before implementation):
- Core: `GITLAB_ENABLED`, `GITLAB_HOSTNAME`, `GITLAB_IMAGE`, `GITLAB_VERSION`, `GITLAB_HTTP_PORT`
- SSH: `GITLAB_SSH_HOST_PORT`
- Admin/bootstrap: `GITLAB_ROOT_PASSWORD`, `GITLAB_ROOT_EMAIL`
- Traefik/TLS: `GITLAB_TRAEFIK_MIDDLEWARES`, `TLS_CERT_RESOLVER`
- OIDC optional: `GITLAB_OIDC_ENABLED`, `GITLAB_OIDC_PROVIDER_NAME`, `GITLAB_OIDC_ISSUER`, `GITLAB_OIDC_CLIENT_ID`, `GITLAB_OIDC_CLIENT_SECRET`, `GITLAB_OIDC_SCOPES`
- Observability optional: `GITLAB_OBSERVABILITY_ENABLED`, optional labels/metrics toggles documented as internal-only

## Runtime Defaults and Host Expectations
- GitLab startup time is significantly longer than smaller services; docs and runtime checks must call this out explicitly.
- Compose defaults should include GitLab Omnibus runtime prerequisites verified upstream (including shared memory sizing such as `shm_size`) rather than relying on undocumented host defaults.
- Generated GitLab config artifacts should live in a gitignored path (for example under `services/gitlab/rendered/` or `.local/`) and be mounted read-only.

## Runtime Validation Strategy
- Static validation first: compose render, guardrails, make target wiring, docs checks, smoke tests.
- Runtime validation checklist (manual) after implementation:
  - `make gitlab-bootstrap`
  - `make gitlab-up`
  - Wait for healthy startup (long startup expected)
  - `https://gitlab.<DEV_DOMAIN>` returns GitLab login page
  - `/-/health` and `/-/readiness` behave as documented
  - SSH clone port is reachable on configured host port
  - OIDC metadata/login button only appears when OIDC enabled
  - No management/exporter ports are exposed publicly by default

## Risks / Mitigations
- **Resource usage**: GitLab is heavy and starts slowly.
  - Mitigation: document host requirements and startup expectations.
- **Reverse proxy misconfiguration**: login/callback/cookies can break behind SSL termination.
  - Mitigation: explicit Omnibus proxy settings and runtime checklist.
- **OIDC config fragility**: Ruby config formatting errors can prevent startup.
  - Mitigation: template rendering + smoke tests for rendered config.
- **Observability overexposure**: exporters can be accidentally public.
  - Mitigation: no public routes/ports for telemetry by default; guardrails + tests.
