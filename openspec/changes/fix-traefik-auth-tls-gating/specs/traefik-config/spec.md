## ADDED Requirements
### Requirement: Auth usersFile mounted for protected UIs
The system SHALL mount a Traefik auth directory and use usersFile-based BasicAuth for the DNS UI and dashboard.

#### Scenario: Fresh run uses usersFile
- **WHEN** Traefik starts with the default auth directory mounted
- **THEN** DNS UI and dashboard routes return 401 (not 404) due to valid auth middleware

### Requirement: Dashboard remains HTTPS-only and auth-protected by default
The system SHALL not expose the Traefik dashboard via a host HTTP port and SHALL route it only through the HTTPS router with auth.

#### Scenario: Dashboard default security
- **WHEN** the stack starts with default settings
- **THEN** no host port 8080 is published and dashboard access requires HTTPS + auth

### Requirement: Certbot TLS config is gated by Mode B
The system SHALL only load certbot TLS entries when Mode B is enabled.

#### Scenario: Mode B disabled
- **WHEN** Mode B is disabled
- **THEN** Traefik does not attempt to load certbot cert files and logs no missing-cert parse errors

#### Scenario: Mode B enabled
- **WHEN** Mode B is enabled and certbot certs are present
- **THEN** Traefik loads the certbot TLS entries and serves those certificates

### Requirement: Redirect toggle is consistent across routing and tests
The system SHALL use a single redirect toggle variable for routing, healthchecks, and tests (with legacy fallback if needed).

#### Scenario: Redirect enabled
- **WHEN** `HTTP_TO_HTTPS_MIDDLEWARE=redirect-to-https@file` is set
- **THEN** healthchecks and tests expect HTTP to redirect to HTTPS

#### Scenario: Redirect disabled
- **WHEN** `HTTP_TO_HTTPS_MIDDLEWARE=noop@file` is set
- **THEN** healthchecks and tests expect HTTP to remain on HTTP

