## ADDED Requirements

### Requirement: Bootstrap enables Traefik dashboard and optional profiles by default
The env generator used by `make bootstrap` SHALL default to turning on the Traefik dashboard and the optional profiles (`dns`, `le`, `stepca`) so that a freshly bootstrapped stack immediately exposes those UIs along with the Mode A self-signed workflow. The generated `.env` file SHALL set `TRAEFIK_DASHBOARD=true`, configure `COMPOSE_PROFILES=dns,le,stepca`, and point `TRAEFIK_DASHBOARD_BASIC_AUTH_HTPASSWD_PATH` and `DNS_UI_BASIC_AUTH_HTPASSWD_PATH` at `/etc/traefik/auth/traefik-dashboard.htpasswd` and `/etc/traefik/auth/dns-ui.htpasswd` respectively while keeping other TLS and endpoint defaults unchanged.

#### Scenario: Bootstrapping a pristine repo
- **WHEN** a developer runs `make bootstrap` in a clean checkout
- **THEN** the resulting `.env` contains the dashboard/profile defaults described above
- **AND** the DNS, Certbot, and Step-CA settings still match their documented defaults so the quickstart works without additional edits

### Requirement: Bootstrap provisions BasicAuth assets for the enabled UIs
`make bootstrap` SHALL ensure concrete htpasswd files exist for the Traefik dashboard and DNS UI before enabling them so that the preflight validation succeeds without manual intervention. If the files do not yet exist, the bootstrap process SHALL copy or generate them from the `.example` fixtures and leave the originals untouched for reference.

#### Scenario: Bootstrapping creates auth assets
- **WHEN** `make bootstrap` completes and the default TREAFIK/UI options are enabled
- **THEN** `services/traefik/auth/traefik-dashboard.htpasswd` and `services/traefik/auth/dns-ui.htpasswd` exist alongside their example counterparts
- **AND** `scripts/validate-env.sh` (triggered via `make up`) no longer errors because the configured htpasswd paths point to real files rather than `.example` placeholders
