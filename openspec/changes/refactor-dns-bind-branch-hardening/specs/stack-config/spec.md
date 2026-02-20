## MODIFIED Requirements

### Requirement: Pinned DNS service image
The DNS service image SHALL be pinned to a specific BIND version tag to ensure reproducibility.

#### Scenario: Stack is pulled on two different days
- **WHEN** the BIND DNS service image is pulled from the registry
- **THEN** the same explicit version tag is used and behavior remains consistent

### Requirement: Guardrails for example htpasswd usage
The system SHALL prevent enabling the Traefik dashboard when its htpasswd path points to example files.

#### Scenario: Operator enables the dashboard without updating htpasswd
- **WHEN** the dashboard is enabled and the htpasswd path references an example file
- **THEN** the system surfaces a clear error and refuses to start
