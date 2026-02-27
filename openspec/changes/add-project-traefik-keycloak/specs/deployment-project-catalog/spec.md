## ADDED Requirements

### Requirement: Project `traefik-keycloak` deploys Keycloak behind Traefik
The system SHALL provide a predefined project `traefik-keycloak` that deploys Keycloak behind Traefik through the project deployment workflow.

#### Scenario: Operator selects `traefik-keycloak`
- **WHEN** an operator runs `make deployment-project project=traefik-keycloak`
- **THEN** the project deployment syncs the declared repository and reference on the target VM
- **AND** compose apply starts the project-declared services for Traefik and Keycloak

### Requirement: Project `traefik-keycloak` depends on StepCA project for default certificate flow
The system SHALL declare `traefik-stepca` as dependency for `traefik-keycloak` default TLS behavior.

#### Scenario: Keycloak project manifest is inspected
- **WHEN** an operator inspects the `traefik-keycloak` project definition
- **THEN** `depends_on_projects` includes `traefik-stepca`
- **AND** dependency intent for default certificate issuance is explicit

### Requirement: Project `traefik-keycloak` defaults to ACME certificate issuance through StepCA
The system SHALL use network ACME against StepCA as the default TLS mode for `traefik-keycloak` unless explicitly overridden.

#### Scenario: Default TLS mode is used
- **WHEN** `project=traefik-keycloak` is executed without explicit TLS override
- **THEN** runtime configuration sets TLS mode to StepCA-backed ACME
- **AND** Traefik certificate resolution uses the StepCA ACME endpoint defined by the project/environment contract

### Requirement: Project `traefik-keycloak` allows explicit TLS mode override
The system SHALL allow an explicit TLS mode override for `traefik-keycloak` and SHALL validate supported values before deployment.

#### Scenario: Operator requests a supported TLS override
- **WHEN** an operator provides an explicit supported `tls_mode`
- **THEN** the project uses the requested TLS mode instead of StepCA ACME default
- **AND** deployment proceeds only if required variables for the selected mode are present

#### Scenario: Operator requests an unsupported TLS mode
- **WHEN** an operator provides an unknown `tls_mode`
- **THEN** the workflow fails fast with a clear unsupported-TLS-mode message
- **AND** compose apply is not executed

### Requirement: Project `traefik-keycloak` validates StepCA ACME prerequisites before compose apply
The system SHALL validate StepCA ACME endpoint configuration before compose apply when `tls_mode=stepca-acme`.

#### Scenario: StepCA ACME endpoint is missing or not configured
- **WHEN** `tls_mode=stepca-acme` is selected and required StepCA ACME settings are missing
- **THEN** the project workflow fails before `docker compose up -d`
- **AND** the error message indicates which prerequisite is missing
