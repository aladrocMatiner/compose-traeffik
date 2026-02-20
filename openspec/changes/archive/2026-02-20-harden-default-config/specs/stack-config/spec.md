## ADDED Requirements
### Requirement: Local-only default domains
The default configuration SHALL use a non-public local-only domain for DEV_DOMAIN and BASE_DOMAIN.

#### Scenario: Developer uses .env.example without edits
- **WHEN** a developer copies .env.example to .env
- **THEN** the default domains resolve to local-only values (e.g., local.test)

### Requirement: Pinned DNS service image
The DNS service image SHALL be pinned to a specific version tag to ensure reproducibility.

#### Scenario: Stack is pulled on two different days
- **WHEN** the DNS service image is pulled from the registry
- **THEN** the same version tag is used and behavior remains consistent

### Requirement: Guardrails for example htpasswd usage
The system SHALL prevent enabling the Traefik dashboard or DNS UI when htpasswd paths point to example files.

#### Scenario: Operator enables the dashboard without updating htpasswd
- **WHEN** the dashboard is enabled and the htpasswd path references an example file
- **THEN** the system surfaces a clear error and refuses to start
