## ADDED Requirements

### Requirement: Project `traefik-quay` deploys Quay behind Traefik
The system SHALL publish Quay through Traefik reverse proxy in the `traefik-quay` project workflow.

#### Scenario: Operator selects `project=traefik-quay`
- **WHEN** an operator runs `make deployment-project project=traefik-quay`
- **THEN** runtime routing for Quay is exposed through Traefik-managed routes
- **AND** Quay is not exposed as a direct bypass of the Traefik edge path

### Requirement: Project `traefik-quay` declares dependencies on StepCA and Keycloak projects
The system SHALL provide a predefined project `traefik-quay` whose manifest declares dependencies on `traefik-stepca` and `traefik-keycloak`.

#### Scenario: Quay manifest is inspected
- **WHEN** an operator inspects the `traefik-quay` project definition
- **THEN** `depends_on_projects` includes `traefik-stepca` and `traefik-keycloak`
- **AND** dependency intent is explicit without relying on external documentation

### Requirement: Project `traefik-quay` defaults to StepCA ACME for certificates through Traefik TLS termination
The system SHALL default `traefik-quay` project TLS mode to StepCA-backed ACME unless an explicit supported override is provided, and TLS termination SHALL be handled by Traefik according to the selected OpenSpec TLS mode.

#### Scenario: Default TLS mode is applied
- **WHEN** `project=traefik-quay` is run without TLS override
- **THEN** runtime configuration uses StepCA ACME as certificate source
- **AND** Traefik certificate resolution uses StepCA ACME settings from project/environment contract
- **AND** deployment proceeds only when required StepCA ACME settings are available

#### Scenario: TLS override is provided
- **WHEN** an operator provides an explicit supported `tls_mode` override
- **THEN** the project uses the requested TLS mode instead of StepCA ACME default
- **AND** deployment validates mode-specific required variables before compose apply

### Requirement: Project `traefik-quay` enforces Keycloak-based authentication contract
The system SHALL configure Quay authentication integration with Keycloak according to the project manifest contract.

#### Scenario: Auth contract is applied
- **WHEN** `project=traefik-quay` is deployed with dependencies satisfied
- **THEN** runtime config applies Keycloak-backed authentication for Quay sign-in
- **AND** deployment fails fast if required Keycloak integration variables are missing

### Requirement: Project `traefik-quay` deploys only manifest-declared services
The system SHALL deploy only services declared by the `traefik-quay` manifest and SHALL reject ad-hoc runtime service overrides.

#### Scenario: Runtime service override conflicts with manifest
- **WHEN** runtime inputs attempt to deploy services outside the manifest service list
- **THEN** deployment fails with a contract-violation message
- **AND** `docker compose up -d` is not executed with conflicting service selection
