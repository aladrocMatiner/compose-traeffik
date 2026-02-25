[English](README.md) | [Svenska](README.sv.md) | [Espanol](README.es.md)

# GitLab service

<a id="overview"></a>
## Overview

GitLab Omnibus runs as an optional compose profile behind Traefik TLS. The web UI/API is exposed through Traefik and Git SSH is published on a configurable host port.

<a id="location"></a>
## Where it lives

- `services/gitlab/compose.yml`
- `services/gitlab/config/gitlab.rb.tmpl`
- `services/gitlab/rendered/` (generated, gitignored)
- `services/gitlab/observability/`

<a id="run"></a>
## How it runs

Bootstrap secrets and render config:
```bash
make gitlab-bootstrap
```

Start the service:
```bash
make gitlab-up
```

Status:
```bash
make gitlab-status
```

Logs:
```bash
make gitlab-logs
```

Stop:
```bash
make gitlab-down
```

<a id="configuration"></a>
## Configuration

Relevant env vars in `.env.example`:
- `GITLAB_HOSTNAME`
- `GITLAB_IMAGE`, `GITLAB_VERSION`
- `GITLAB_SHM_SIZE`
- `GITLAB_SSH_BIND_ADDRESS`, `GITLAB_SSH_HOST_PORT`
- `GITLAB_ROOT_PASSWORD`, `GITLAB_ROOT_EMAIL`
- `GITLAB_OIDC_*` (optional Keycloak OIDC)
- `GITLAB_OBSERVABILITY_ENABLED` (optional observability hooks)

Generated Omnibus config:
- Template: `services/gitlab/config/gitlab.rb.tmpl`
- Rendered file: `services/gitlab/rendered/gitlab.rb`

<a id="ports"></a>
## Ports, networks, volumes

- HTTPS UI/API: `https://gitlab.${DEV_DOMAIN}` via Traefik (no direct host `80/443` publish)
- Git SSH: `${GITLAB_SSH_HOST_PORT}` on the host to container `22` (default `2424`)
- Network: `proxy` (`traefik-proxy`)
- Volumes:
  - `services/gitlab/rendered` -> `/etc/gitlab`
  - `gitlab-logs` -> `/var/log/gitlab`
  - `gitlab-data` -> `/var/opt/gitlab`

<a id="security"></a>
## Security notes

- TLS terminates at Traefik; GitLab Omnibus listens on HTTP internally.
- OIDC/Keycloak support is optional and disabled by default.
- Observability hooks are optional and telemetry is not publicly exposed by default.
- Add `gitlab` to `ENDPOINTS` (or your DNS/hosts mapping) so `gitlab.${DEV_DOMAIN}` resolves locally.

<a id="troubleshooting"></a>
## Troubleshooting

- Slow first startup is normal for GitLab Omnibus; wait several minutes.
- If preflight fails, run `make gitlab-bootstrap` and re-check `.env`.
- SSH clone problems: verify `GITLAB_SSH_HOST_PORT` is free and reachable.
- OIDC issues: verify `GITLAB_OIDC_ISSUER` is HTTPS and matches your Keycloak realm.

Manual runtime validation checklist (after implementation/runtime testing):
- `make gitlab-up`
- Open `https://gitlab.${DEV_DOMAIN}` and confirm the login page loads through Traefik
- Confirm SSH port reachability on `${GITLAB_SSH_HOST_PORT}` (`ssh -T -p ... git@<host>`)
- Validate `/-/health` / `/-/readiness` from inside the container (localhost checks)
- If OIDC is enabled, verify the OIDC button appears and callback URL matches the configured Keycloak client

<a id="related"></a>
## Related pages

- [Root README](../../README.sv.md)
- [Traefik](../traefik/README.sv.md)
- [GitLab observability notes](observability/README.sv.md)
