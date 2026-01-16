## Context
Traefik is currently configured with only the file provider, which disables routing via docker labels. The dashboard is exposed over HTTP on port 8080, and the HTTP redirect toggle in `.env.example` is not wired into routing behavior.

## Goals / Non-Goals
- Goals:
  - Enable docker provider routing for label-defined services (dns/step-ca).
  - Remove default host exposure of the dashboard and serve it only via HTTPS + auth (or disable it entirely).
  - Make the HTTP-to-HTTPS redirect toggle actually switch behavior.
- Non-Goals:
  - Rework TLS modes or certificate issuance logic.
  - Introduce new services or change profiles.

## Decisions
- Add `providers.docker` with `exposedByDefault=false` and `network=traefik-proxy` in `services/traefik/traefik.yml` so docker labels are honored and traffic routes on the proxy network.
- Remove the host port mapping for `8080` and move the dashboard router to `websecure` with TLS + auth to keep access private by default.
- Implement redirect toggling via an env-driven middleware selection: define a `noop` middleware and select between `redirect-to-https@file` and `noop@file` in the HTTP router label.

## Alternatives considered
- Keep the dashboard on 8080 but bind to localhost only. Rejected because it still exposes an HTTP surface on the host and does not match the HTTPS-only expectation.
- Use a conditional static config to turn redirection on/off. Rejected because static config has no conditional support without additional templating.

## Risks / Trade-offs
- Changing the dashboard entrypoint or removing port 8080 will require updates to readiness tests and documentation references.
- Using a noop middleware requires accurate selection via env variables to avoid redirecting when disabled.

## Migration Plan
- Update Traefik config and compose port mappings first.
- Adjust dashboard router entrypoint and TLS settings.
- Wire redirect toggle in whoami HTTP router and add `noop` middleware.
- Update `.env.example` to document toggle values.
- Update tests that assume port 8080.

## Open Questions
- Should `TRAEFIK_DASHBOARD` be enforced (router enabled only when true) or is HTTPS+auth sufficient even when the router is always present?
- Should `HTTP_TO_HTTPS_REDIRECT` remain a boolean with a derived middleware var, or be replaced by a middleware selector value?
