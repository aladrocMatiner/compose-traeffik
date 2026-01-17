## ADDED Requirements
### Requirement: UI auth fail-closed defaults
Dashboard and DNS UI routes SHALL be disabled unless a non-example htpasswd file path is configured.

#### Scenario: Example files present
- **WHEN** only `.example` htpasswd files exist
- **THEN** the dashboard and DNS UI routes are not exposed

#### Scenario: Real htpasswd path configured
- **WHEN** a non-example htpasswd file path is configured
- **THEN** the dashboard and DNS UI routes are exposed behind BasicAuth

## MODIFIED Requirements
### Requirement: DNS UI auth file wiring
The DNS UI BasicAuth middleware SHALL use the path provided in `DNS_UI_BASIC_AUTH_HTPASSWD_PATH`.

#### Scenario: Override path
- **WHEN** `DNS_UI_BASIC_AUTH_HTPASSWD_PATH` is set
- **THEN** Traefik loads the usersFile from that path

## ADDED Requirements
### Requirement: DNS admin password required
The DNS service SHALL refuse to start when the DNS profile is enabled and `DNS_ADMIN_PASSWORD` is empty.

#### Scenario: Missing password with DNS profile
- **WHEN** the DNS profile is enabled and `DNS_ADMIN_PASSWORD` is empty
- **THEN** startup fails early with a clear message
