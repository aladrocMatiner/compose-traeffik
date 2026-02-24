## ADDED Requirements
### Requirement: DNS service profile with secure UI
The system SHALL provide a `dns` Compose profile running a DNS service with a web UI exposed only via Traefik HTTPS at `dns.<BASE_DOMAIN>` and protected by auth.

#### Scenario: UI exposure is Traefik-only
- **WHEN** the `dns` profile is enabled
- **THEN** the DNS UI is reachable at `https://dns.<BASE_DOMAIN>` via Traefik `websecure`
- **AND** the DNS UI port is not published directly on the host

#### Scenario: Default auth protection
- **WHEN** the DNS UI router is enabled
- **THEN** a Traefik BasicAuth middleware is applied by default

#### Scenario: Safe-by-default DNS binding
- **WHEN** the DNS service starts with default settings
- **THEN** TCP/UDP port 53 is bound to `127.0.0.1` only

### Requirement: Domain convention defaults
The system SHALL support a project naming convention where `BASE_DOMAIN` defaults to `<PROJECT_NAME>.aladroc.io`.

#### Scenario: Default domain derivation
- **WHEN** `PROJECT_NAME` is set in `.env`
- **THEN** documentation and examples use `BASE_DOMAIN=${PROJECT_NAME}.aladroc.io`
