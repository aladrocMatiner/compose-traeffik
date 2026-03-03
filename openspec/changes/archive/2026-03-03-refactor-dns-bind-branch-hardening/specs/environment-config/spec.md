## MODIFIED Requirements

### Requirement: Bootstrap enables Traefik dashboard and optional profiles by default
The env generator used by `make bootstrap` SHALL default to turning on the Traefik dashboard and optional profiles (`le`, `stepca`) while keeping BIND DNS opt-in to avoid automatic port 53 conflicts on hosts with local resolvers. The generated `.env` file SHALL set `TRAEFIK_DASHBOARD=true` and `COMPOSE_PROFILES=le,stepca` while keeping other TLS defaults unchanged.

#### Scenario: Bootstrapping a pristine repo
- **WHEN** a developer runs `make bootstrap` in a clean checkout
- **THEN** the resulting `.env` contains `TRAEFIK_DASHBOARD=true` and `COMPOSE_PROFILES=le,stepca`
- **AND** DNS-related defaults are aligned with BIND variables instead of Technitium-specific settings
- **AND** BIND can be enabled explicitly via `COMPOSE_PROFILES=bind` or `make bind-up`

### Requirement: Bootstrap provisions BasicAuth assets for the enabled UIs
`make bootstrap` SHALL ensure concrete htpasswd files exist for the Traefik dashboard before enabling it so preflight validation succeeds without manual intervention.

#### Scenario: Bootstrapping creates auth assets
- **WHEN** `make bootstrap` completes with dashboard enabled
- **THEN** `services/traefik/auth/traefik-dashboard.htpasswd` exists alongside its example counterpart
- **AND** no Technitium-specific DNS UI auth file is required for successful `make up`
