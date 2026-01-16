## 1. Implementation
- [ ] 1.1 Confirm dashboard exposure strategy (HTTPS-only router vs disabled by toggle) and redirect toggle variable strategy.
- [ ] 1.2 Add docker provider configuration to `services/traefik/traefik.yml` with `exposedByDefault=false` and `network=traefik-proxy`.
- [ ] 1.3 Update `services/traefik/compose.yml` to remove host port 8080 exposure while keeping the docker socket mount.
- [ ] 1.4 Update dashboard router config in `services/traefik/dynamic/dashboard.yml` to use HTTPS entrypoint + TLS + auth (or gate it behind `TRAEFIK_DASHBOARD`).
- [ ] 1.5 Add a `noop` middleware in `services/traefik/dynamic/middlewares.yml` and wire whoami HTTP router to select middleware via env.
- [ ] 1.6 Update `services/whoami/compose.yml` to use the env-driven middleware selector.
- [ ] 1.7 Update `.env.example` with any new selector variables and document their expected values.

## 2. Validation
- [ ] 2.1 Update redirect and dashboard readiness tests if the endpoints change (optional but recommended).
- [ ] 2.2 Verify routing for dns/step-ca endpoints when profiles are enabled.
