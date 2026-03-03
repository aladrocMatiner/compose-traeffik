## ADDED Requirements

### Requirement: Project `traefik-semaphoreui` deploys Semaphore UI behind Traefik
The system SHALL publish Semaphore UI through Traefik reverse proxy in the `traefik-semaphoreui` project workflow.

#### Scenario: Operator selects `project=traefik-semaphoreui`
- **WHEN** an operator runs `make deployment-project project=traefik-semaphoreui`
- **THEN** runtime routing for Semaphore UI is exposed through Traefik-managed routes
- **AND** Semaphore UI is not exposed as a direct bypass of the Traefik edge path

### Requirement: Project `traefik-semaphoreui` declares dependencies on StepCA and Keycloak projects
The system SHALL provide a predefined project `traefik-semaphoreui` whose manifest declares dependencies on `traefik-stepca` and `traefik-keycloak`.

#### Scenario: SemaphoreUI manifest is inspected
- **WHEN** an operator inspects the `traefik-semaphoreui` project definition
- **THEN** `depends_on_projects` includes `traefik-stepca` and `traefik-keycloak`
- **AND** dependency intent is explicit without relying on external documentation

### Requirement: Project `traefik-semaphoreui` defaults to StepCA ACME for certificates through Traefik TLS termination
The system SHALL default `traefik-semaphoreui` project TLS mode to StepCA-backed ACME unless an explicit supported override is provided, and TLS termination SHALL be handled by Traefik according to the selected OpenSpec TLS mode.

#### Scenario: Default TLS mode is applied
- **WHEN** `project=traefik-semaphoreui` is run without TLS override
- **THEN** runtime configuration uses StepCA ACME as certificate source
- **AND** Traefik certificate resolution uses StepCA ACME settings from project/environment contract
- **AND** deployment proceeds only when required StepCA ACME settings are available

#### Scenario: TLS override is provided
- **WHEN** an operator provides an explicit supported `tls_mode` override
- **THEN** the project uses the requested TLS mode instead of StepCA ACME default
- **AND** deployment validates mode-specific required variables before compose apply

### Requirement: Project `traefik-semaphoreui` enforces Keycloak-based authentication contract
The system SHALL configure Semaphore UI authentication integration with Keycloak according to the project manifest contract.

#### Scenario: Auth contract is applied
- **WHEN** `project=traefik-semaphoreui` is deployed with dependencies satisfied
- **THEN** runtime config applies Keycloak-backed authentication for Semaphore UI sign-in
- **AND** deployment fails fast if required Keycloak integration variables are missing

### Requirement: Project `traefik-semaphoreui` deploys only manifest-declared services
The system SHALL deploy only services declared by the `traefik-semaphoreui` manifest and SHALL reject ad-hoc runtime service overrides.

#### Scenario: Runtime service override conflicts with manifest
- **WHEN** runtime inputs attempt to deploy services outside the manifest service list
- **THEN** deployment fails with a contract-violation message
- **AND** `docker compose up -d` is not executed with conflicting service selection
