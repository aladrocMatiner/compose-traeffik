## ADDED Requirements

### Requirement: Project `traefik-plane` deploys Plane stack behind Traefik
The system SHALL provide a predefined project `traefik-plane` that deploys the Plane application stack behind Traefik through the deployment project workflow.

#### Scenario: Operator selects `project=traefik-plane`
- **WHEN** an operator runs `make deployment-project project=traefik-plane`
- **THEN** project deployment syncs the declared repository/ref on the target VM
- **AND** compose apply starts the manifest-declared Plane services behind Traefik routes
- **AND** Plane web access is exposed via the project host contract on HTTPS

### Requirement: Project `traefik-plane` declares StepCA, Keycloak, and Observability dependencies
The system SHALL declare `traefik-stepca`, `traefik-keycloak`, and `traefik-observability` as dependencies for `traefik-plane`.

#### Scenario: Plane manifest is inspected
- **WHEN** an operator inspects the `traefik-plane` project definition
- **THEN** `depends_on_projects` includes `traefik-stepca`, `traefik-keycloak`, and `traefik-observability`
- **AND** dependency intent is explicit in manifest data

### Requirement: Project `traefik-plane` defaults to StepCA ACME and supports explicit TLS override
The system SHALL default `traefik-plane` TLS mode to StepCA-backed ACME unless an explicit supported override is provided, and deployment SHALL validate mode-specific prerequisites before compose apply.

#### Scenario: Default TLS mode is applied
- **WHEN** `project=traefik-plane` is run without explicit TLS override
- **THEN** Traefik certificate handling for Plane routes uses StepCA ACME settings
- **AND** deployment proceeds only when required StepCA ACME settings are available

#### Scenario: Unsupported TLS mode is requested
- **WHEN** an operator provides an unsupported `tls_mode` override
- **THEN** deployment fails fast with an unsupported-TLS-mode error
- **AND** `docker compose up -d` is not executed

### Requirement: Project `traefik-plane` provisions and reconciles Keycloak OIDC client idempotently
The system SHALL provision or reconcile a Plane OIDC client in Keycloak for `traefik-plane` and SHALL persist the effective client secret into project runtime configuration idempotently.

#### Scenario: OIDC client is missing on first deployment
- **WHEN** `traefik-plane` is deployed and the configured OIDC client does not exist in Keycloak
- **THEN** deployment creates the client, refreshes lookup, and updates the OIDC contract
- **AND** the effective client secret is synced to project `.env`

#### Scenario: OIDC client already exists
- **WHEN** `traefik-plane` is redeployed and the OIDC client already exists
- **THEN** deployment updates/reconciles the client contract without duplicate creation
- **AND** deployment remains idempotent across reruns

### Requirement: Project `traefik-plane` enforces observability integration contract
The system SHALL apply Plane observability integration settings according to project contract and SHALL keep Plane traffic exposed through Traefik rather than direct public service exposure.

#### Scenario: Observability contract is applied
- **WHEN** `traefik-plane` is deployed with dependencies satisfied
- **THEN** deployment applies documented Plane observability environment/label contract
- **AND** no direct host port exposure bypassing Traefik is introduced by deployment automation

### Requirement: Project `traefik-plane` fails fast when pinned repository lacks Plane module
The system SHALL stop deployment before compose apply when the pinned project `repo_ref` does not contain required Plane service assets.

#### Scenario: Plane compose module is missing in pinned repo
- **WHEN** `services/plane/compose.yml` is not present in the pinned `repo_ref`
- **THEN** deployment fails with a clear actionable error about missing Plane module assets
- **AND** `docker compose up -d` is not executed

### Requirement: Project `traefik-plane` deploys only manifest-declared services
The system SHALL deploy only services declared by the `traefik-plane` manifest and SHALL reject ad-hoc runtime service overrides.

#### Scenario: Runtime service override conflicts with Plane manifest
- **WHEN** runtime input attempts to deploy services outside the `traefik-plane` manifest service list
- **THEN** deployment fails with a contract-violation message
- **AND** compose apply is not executed with conflicting service selection
