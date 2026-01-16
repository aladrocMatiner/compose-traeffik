## ADDED Requirements
### Requirement: Env-driven ACME resolver settings
The system SHALL use environment variables for ACME resolver email and CA server values for both Mode B and Mode C.

#### Scenario: ACME settings from env
- **WHEN** Traefik starts
- **THEN** it reads ACME email and CA server values from `.env` instead of hard-coded defaults

### Requirement: Certbot certs consumed by Traefik
The system SHALL mount Certbot outputs into the Traefik container and configure file-provider TLS certificates to serve them.

#### Scenario: Mode B issuance is served
- **WHEN** Certbot issues certificates under the configured path
- **THEN** Traefik serves those certificates for HTTPS requests

### Requirement: Step-CA DNS list validation
The system SHALL validate `STEP_CA_DNS` during bootstrap and SHALL not initialize step-ca with an empty DNS list.

#### Scenario: Missing STEP_CA_DNS
- **WHEN** `STEP_CA_DNS` is missing
- **THEN** the bootstrap script fails fast or applies a documented safe default
