## ADDED Requirements

### Requirement: Project `traefik-gitlab` deploys GitLab behind Traefik
The system SHALL publish GitLab through Traefik reverse proxy in the `traefik-gitlab` project workflow.

#### Scenario: Operator selects `project=traefik-gitlab`
- **WHEN** an operator runs `make deployment-project project=traefik-gitlab`
- **THEN** runtime routing for GitLab is exposed through Traefik-managed routes
- **AND** GitLab is not exposed as a direct bypass of the Traefik edge path

### Requirement: Project `traefik-gitlab` declares dependencies on StepCA and Keycloak projects
The system SHALL provide a predefined project `traefik-gitlab` whose manifest declares dependencies on `traefik-stepca` and `traefik-keycloak`.

#### Scenario: GitLab manifest is inspected
- **WHEN** an operator inspects the `traefik-gitlab` project definition
- **THEN** `depends_on_projects` includes `traefik-stepca` and `traefik-keycloak`
- **AND** dependency intent is explicit without relying on external documentation

### Requirement: Project `traefik-gitlab` defaults to StepCA ACME for certificates through Traefik TLS termination
The system SHALL default `traefik-gitlab` project TLS mode to StepCA-backed ACME unless an explicit supported override is provided, and TLS termination SHALL be handled by Traefik according to the selected OpenSpec TLS mode.

#### Scenario: Default TLS mode is applied
- **WHEN** `project=traefik-gitlab` is run without TLS override
- **THEN** runtime configuration uses StepCA ACME as certificate source
- **AND** Traefik certificate resolution uses StepCA ACME settings from project/environment contract
- **AND** deployment proceeds only when required StepCA ACME settings are available

#### Scenario: TLS override is provided
- **WHEN** an operator provides an explicit supported `tls_mode` override
- **THEN** the project uses the requested TLS mode instead of StepCA ACME default
- **AND** deployment validates mode-specific required variables before compose apply

### Requirement: Project `traefik-gitlab` enforces Keycloak-based authentication contract
The system SHALL configure GitLab authentication integration with Keycloak according to the project manifest contract.

#### Scenario: Auth contract is applied
- **WHEN** `project=traefik-gitlab` is deployed with dependencies satisfied
- **THEN** runtime config applies Keycloak-backed authentication for GitLab sign-in
- **AND** deployment fails fast if required Keycloak integration variables are missing

### Requirement: Project `traefik-gitlab` deploys only manifest-declared services
The system SHALL deploy only services declared by the `traefik-gitlab` manifest and SHALL reject ad-hoc runtime service overrides.

#### Scenario: Runtime service override conflicts with manifest
- **WHEN** runtime inputs attempt to deploy services outside the manifest service list
- **THEN** deployment fails with a contract-violation message
- **AND** `docker compose up -d` is not executed with conflicting service selection
