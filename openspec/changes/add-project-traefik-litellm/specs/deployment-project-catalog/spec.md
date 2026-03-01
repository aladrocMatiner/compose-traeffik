## ADDED Requirements

### Requirement: Project `traefik-litellm` deploys LiteLLM full stack behind Traefik
The system SHALL provide a predefined project `traefik-litellm` that deploys LiteLLM full stack (proxy + admin UI + persistent PostgreSQL backend) behind Traefik through the project deployment workflow.

#### Scenario: Operator selects `project=traefik-litellm`
- **WHEN** an operator runs `make deployment-project project=traefik-litellm`
- **THEN** project deployment syncs the declared repository/ref on the target VM
- **AND** compose apply starts the manifest-declared services for Traefik, LiteLLM, and LiteLLM PostgreSQL
- **AND** runtime routing for LiteLLM/UI is exposed through Traefik-managed routes

### Requirement: Project `traefik-litellm` depends on StepCA project for default certificate flow
The system SHALL declare `traefik-stepca` as dependency for `traefik-litellm` default TLS flow.

#### Scenario: LiteLLM manifest is inspected
- **WHEN** an operator inspects the `traefik-litellm` project definition
- **THEN** `depends_on_projects` includes `traefik-stepca`
- **AND** dependency intent for default certificate issuance is explicit

### Requirement: Project `traefik-litellm` defaults to StepCA ACME through Traefik TLS termination
The system SHALL default `traefik-litellm` TLS mode to StepCA-backed ACME unless an explicit supported override is provided, and TLS termination SHALL be handled by Traefik according to the selected OpenSpec TLS mode.

#### Scenario: Default TLS mode is applied
- **WHEN** `project=traefik-litellm` is run without TLS override
- **THEN** Traefik certificate handling for LiteLLM routes uses `stepca-acme`
- **AND** deployment proceeds only when required StepCA ACME settings are available

#### Scenario: TLS override is provided
- **WHEN** an operator provides an explicit supported `tls_mode` override
- **THEN** Traefik uses the requested TLS mode for LiteLLM routes
- **AND** deployment validates mode-specific required variables before compose apply

### Requirement: Project `traefik-litellm` provides persistent runtime state for full UI/admin features
The system SHALL persist LiteLLM runtime data in PostgreSQL and SHALL configure LiteLLM to store model/runtime state in DB so admin UI features remain available across restarts.

#### Scenario: LiteLLM full stack restarts
- **WHEN** the `traefik-litellm` stack is restarted
- **THEN** LiteLLM reconnects to the configured PostgreSQL service
- **AND** previously stored runtime state remains available through the LiteLLM UI/admin workflows

### Requirement: Project `traefik-litellm` deploys only manifest-declared services
The system SHALL deploy only services declared by the `traefik-litellm` manifest and SHALL reject ad-hoc runtime service overrides.

#### Scenario: Runtime service override conflicts with manifest
- **WHEN** runtime inputs attempt to deploy services outside the manifest service list
- **THEN** deployment fails with a contract-violation message
- **AND** `docker compose up -d` is not executed with conflicting service selection
