# Change: Add GitLab Service Module

## Why
The project needs a self-hosted GitLab deployment that fits the existing `docker compose + Traefik + Makefile + smoke tests + multilingual docs` workflow. The module also needs optional Keycloak SSO and optional observability wiring so it can coexist with other service modules without forcing extra dependencies.

## What Changes
- Add a new optional `gitlab` service module based on GitLab Omnibus Docker behind Traefik TLS.
- Add `make gitlab-*` lifecycle and bootstrap targets with `.env`-driven configuration.
- Add optional Keycloak OIDC configuration rendered into GitLab Omnibus config.
- Add optional observability hooks (logs/health/labels, safe defaults) compatible with the Grafana/Prometheus/Loki collector stack if enabled elsewhere.
- Add guardrails, smoke tests, and multilingual documentation for the module.
- Add service-specific smoke test target `make test-gitlab` and integrate with the shared smoke runner.

## Impact
- Affected specs: `gitlab-service`, `compose-wrapper`, `bootstrap-secrets`, `guardrails`, `docs-endpoints-tls`, `tests-suite`, `tests-docs`, `scripts-docs`
- Affected code: `services/gitlab/`, `Makefile`, `scripts/compose.sh`, `scripts/validate-env.sh`, `scripts/healthcheck.sh`, `tests/smoke/`, root/service READMEs, `.env.example`, `docs.manifest.json`

## Out of Scope (This Change)
- GitLab Runner deployment (separate service/module)
- GitLab Pages, Container Registry, object storage, SMTP relay
- Full backup/restore/upgrade automation (planned separately in `add-gitlab-day2-nfs-backup-operations`)
- Shipping the observability stack itself (only compatibility hooks here)
