## ADDED Requirements
### Requirement: Provider-aware smoke tests
The system SHALL include smoke tests that fail when docker provider routing is disabled or when profile endpoints are not routed as expected.

#### Scenario: Docker provider disabled
- **WHEN** the docker provider is disabled in Traefik config
- **THEN** the smoke tests fail and report the missing routing capability

### Requirement: Redirect toggle validation
The system SHALL test both enabled and disabled redirect behavior based on `HTTP_TO_HTTPS_REDIRECT`.

#### Scenario: Redirect enabled
- **WHEN** `HTTP_TO_HTTPS_REDIRECT=true`
- **THEN** HTTP requests redirect to HTTPS

#### Scenario: Redirect disabled
- **WHEN** `HTTP_TO_HTTPS_REDIRECT=false`
- **THEN** HTTP requests do not redirect to HTTPS

### Requirement: Docs aligned with TLS modes
The system SHALL ensure README and TLS guides describe Mode B/C behavior consistent with mounted certbot outputs and env-driven ACME settings.

#### Scenario: Certbot guidance
- **WHEN** a user follows Mode B documentation
- **THEN** the steps describe how Traefik serves certbot-issued certs via the configured mounts
