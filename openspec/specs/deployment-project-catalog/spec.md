# deployment-project-catalog Specification

## Purpose
TBD - created by archiving change add-project-traefik-keycloak. Update Purpose after archive.
## Requirements
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

### Requirement: Project `traefik-harbor` deploys Harbor behind Traefik
The system SHALL publish Harbor through Traefik reverse proxy in the `traefik-harbor` project workflow.

#### Scenario: Operator selects `project=traefik-harbor`
- **WHEN** an operator runs `make deployment-project project=traefik-harbor`
- **THEN** runtime routing for Harbor is exposed through Traefik-managed routes
- **AND** Harbor is not exposed as a direct bypass of the Traefik edge path

### Requirement: Project `traefik-harbor` declares dependencies on StepCA and Keycloak projects
The system SHALL provide a predefined project `traefik-harbor` whose manifest declares dependencies on `traefik-stepca` and `traefik-keycloak`.

#### Scenario: Harbor project manifest is inspected
- **WHEN** an operator inspects the `traefik-harbor` project definition
- **THEN** `depends_on_projects` includes `traefik-stepca` and `traefik-keycloak`
- **AND** dependency intent is explicit without relying on external documentation

### Requirement: Project `traefik-harbor` defaults to StepCA ACME for certificates through Traefik TLS termination
The system SHALL default `traefik-harbor` project TLS mode to StepCA-backed ACME unless an explicit supported override is provided, and TLS termination SHALL be handled by Traefik according to the selected OpenSpec TLS mode.

#### Scenario: Default TLS mode is applied
- **WHEN** `project=traefik-harbor` is run without TLS override
- **THEN** runtime configuration uses StepCA ACME as certificate source
- **AND** Traefik certificate resolution uses StepCA ACME settings from project/environment contract
- **AND** deployment proceeds only when required StepCA ACME settings are available

#### Scenario: TLS override is provided
- **WHEN** an operator provides an explicit supported `tls_mode` override
- **THEN** the project uses the requested TLS mode instead of StepCA ACME default
- **AND** deployment validates mode-specific required variables before compose apply

### Requirement: Project `traefik-harbor` enforces Keycloak-based authentication contract
The system SHALL configure Harbor authentication integration with Keycloak according to the project manifest contract.

#### Scenario: Auth contract is applied
- **WHEN** `project=traefik-harbor` is deployed with dependencies satisfied
- **THEN** runtime config applies Keycloak-backed authentication for Harbor sign-in
- **AND** deployment fails fast if required Keycloak integration variables are missing

### Requirement: Project `traefik-harbor` defines observability integration contract compatible with `traefik-observability`
The system SHALL define an observability contract for `traefik-harbor` that is compatible with `traefik-observability`, and SHALL keep the base Harbor deployment operable without requiring `traefik-observability` as a hard dependency.

#### Scenario: Base deployment runs without observability dependency
- **WHEN** `project=traefik-harbor` is deployed with default observability settings
- **THEN** deployment is not blocked by absence of `traefik-observability` dependency
- **AND** project configuration preserves Harbor/Traefik telemetry hooks required for later observability integration

#### Scenario: Explicit observability integration is enabled
- **WHEN** operators enable the Harbor observability integration mode
- **THEN** deployment validates required observability variables before compose apply
- **AND** deployment fails fast with clear missing-variable messages when observability prerequisites are incomplete

### Requirement: Project `traefik-harbor` deploys only manifest-declared services
The system SHALL deploy only services declared by the `traefik-harbor` manifest and SHALL reject ad-hoc runtime service overrides.

#### Scenario: Runtime service override conflicts with manifest
- **WHEN** runtime inputs attempt to deploy services outside the manifest service list
- **THEN** deployment fails with a contract-violation message
- **AND** `docker compose up -d` is not executed with conflicting service selection

### Requirement: Project `traefik-n8n` deploys n8n behind Traefik
The system SHALL provide a predefined project `traefik-n8n` that deploys n8n behind Traefik through the project deployment workflow.

#### Scenario: Operator selects `project=traefik-n8n`
- **WHEN** an operator runs `make deployment-project project=traefik-n8n`
- **THEN** project deployment syncs the declared repository/ref on the target VM
- **AND** compose apply starts the manifest-declared services for Traefik and n8n
- **AND** runtime routing for n8n is exposed through Traefik-managed routes

### Requirement: Project `traefik-n8n` defaults to StepCA ACME through Traefik TLS termination
The system SHALL default `traefik-n8n` TLS mode to StepCA-backed ACME unless an explicit supported override is provided, and TLS termination SHALL be handled by Traefik according to the selected OpenSpec TLS mode.

#### Scenario: Default TLS mode is applied
- **WHEN** `project=traefik-n8n` is run without TLS override
- **THEN** Traefik certificate handling for n8n routes uses `stepca-acme`
- **AND** deployment proceeds only when required StepCA ACME settings are available

#### Scenario: TLS override is provided
- **WHEN** an operator provides an explicit supported `tls_mode` override
- **THEN** Traefik uses the requested TLS mode for n8n routes
- **AND** deployment validates mode-specific required variables before compose apply

### Requirement: Project `traefik-n8n` supports optional Keycloak OIDC contract
The system SHALL support optional Keycloak OIDC integration for `traefik-n8n` when explicitly enabled by project configuration.

#### Scenario: OIDC mode is enabled
- **WHEN** OIDC integration is enabled for `traefik-n8n`
- **THEN** deployment validates required Keycloak OIDC variables before compose apply
- **AND** deployment fails fast with a clear missing-variable message when prerequisites are incomplete

### Requirement: Project `traefik-n8n` deploys only manifest-declared services
The system SHALL deploy only services declared by the `traefik-n8n` manifest and SHALL reject ad-hoc runtime service overrides.

#### Scenario: Runtime service override conflicts with manifest
- **WHEN** runtime inputs attempt to deploy services outside the manifest service list
- **THEN** deployment fails with a contract-violation message
- **AND** `docker compose up -d` is not executed with conflicting service selection

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

### Requirement: Project `traefik-freeipa` is discoverable in deployment catalog before service implementation
The system SHALL allow `traefik-freeipa` to be represented in the deployment project catalog even when the FreeIPA service stack is not yet implemented.

#### Scenario: Operator lists available projects
- **WHEN** an operator runs a project catalog listing command
- **THEN** `traefik-freeipa` appears as a supported project identifier
- **AND** the project contract is discoverable without requiring service runtime availability

### Requirement: Project `traefik-freeipa` declares StepCA dependency and TLS default contract
The system SHALL define `traefik-stepca` as dependency for `traefik-freeipa` and SHALL default TLS mode to StepCA-backed ACME unless an explicit supported override is provided.

#### Scenario: FreeIPA manifest contract is inspected
- **WHEN** an operator inspects the `traefik-freeipa` project definition
- **THEN** `depends_on_projects` includes `traefik-stepca`
- **AND** default `tls_mode` is `stepca-acme`
- **AND** supported TLS override behavior is explicit in deployment contract

### Requirement: Project `traefik-freeipa` fails fast before compose apply when service is not implemented
The system SHALL stop deployment before compose apply for `traefik-freeipa` when required FreeIPA service/profile implementation is missing.

#### Scenario: Operator deploys `traefik-freeipa` before service implementation
- **WHEN** an operator runs `make deployment-project project=traefik-freeipa`
- **THEN** deployment exits before `docker compose up -d`
- **AND** the error message clearly states that FreeIPA service implementation is pending
- **AND** the message points to deployment-only contract status rather than generic compose failure

### Requirement: Project `traefik-freeipa` enforces manifest service contract once implemented
The system SHALL keep service selection bound to manifest-declared services and SHALL reject ad-hoc runtime service overrides for `traefik-freeipa`.

#### Scenario: Runtime service override conflicts with FreeIPA manifest
- **WHEN** runtime input attempts to deploy services outside the manifest service list
- **THEN** deployment fails with a contract-violation message
- **AND** compose apply is not executed with conflicting service selection

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

### Requirement: Project `traefik-awx` is discoverable in deployment catalog before runtime integration
The system SHALL allow `traefik-awx` to be represented in the deployment project catalog even when AWX hybrid runtime integration is not yet implemented in `deployment-project`.

#### Scenario: Operator lists available projects
- **WHEN** an operator runs a project catalog listing command
- **THEN** `traefik-awx` appears as a supported project identifier
- **AND** the project contract is discoverable without requiring runtime availability

### Requirement: Project `traefik-awx` declares StepCA/Keycloak dependencies and TLS baseline
The system SHALL define `traefik-stepca` and `traefik-keycloak` as dependencies for `traefik-awx` and SHALL default TLS mode to StepCA-backed ACME unless an explicit supported override is provided.

#### Scenario: AWX manifest contract is inspected
- **WHEN** an operator inspects the `traefik-awx` project definition
- **THEN** `depends_on_projects` includes `traefik-stepca` and `traefik-keycloak`
- **AND** default `tls_mode` is `stepca-acme`
- **AND** supported TLS override behavior is explicit in deployment contract

### Requirement: Project `traefik-awx` declares Keycloak OIDC authentication contract
The system SHALL declare AWX Keycloak authentication intent in the project manifest contract.

#### Scenario: OIDC contract is inspected
- **WHEN** an operator inspects the `traefik-awx` project definition
- **THEN** `oidc.enabled` is `true`
- **AND** `oidc.realm` and `oidc.client_id` are explicitly defined

### Requirement: Project `traefik-awx` fails fast before compose apply while runtime integration is pending
The system SHALL stop deployment before compose apply for `traefik-awx` when required AWX hybrid runtime integration is missing from `deployment-project`.

#### Scenario: Operator deploys `traefik-awx` before hybrid integration is implemented
- **WHEN** an operator runs `make deployment-project project=traefik-awx`
- **THEN** deployment exits before `docker compose up -d`
- **AND** the error message clearly states that AWX runtime hybrid integration is pending
- **AND** the message provides an explicit transition path

### Requirement: Project `traefik-awx` enforces manifest service contract
The system SHALL keep service selection bound to manifest-declared services and SHALL reject ad-hoc runtime service overrides for `traefik-awx`.

#### Scenario: Runtime service override conflicts with AWX manifest
- **WHEN** runtime input attempts to deploy services outside the manifest service list
- **THEN** deployment fails with a contract-violation message
- **AND** compose apply is not executed with conflicting service selection

### Requirement: Project `traefik-webui` deploys WebUI behind Traefik
The system SHALL provide a predefined project `traefik-webui` that deploys WebUI behind Traefik through the project deployment workflow.

#### Scenario: Operator selects `project=traefik-webui`
- **WHEN** an operator runs `make deployment-project project=traefik-webui`
- **THEN** project deployment syncs the declared repository/ref on the target VM
- **AND** compose apply starts the manifest-declared services for Traefik and WebUI
- **AND** runtime routing for WebUI is exposed through Traefik-managed routes

### Requirement: Project `traefik-webui` depends on StepCA project for default certificate flow
The system SHALL declare `traefik-stepca` as dependency for `traefik-webui` default TLS flow.

#### Scenario: WebUI manifest is inspected
- **WHEN** an operator inspects the `traefik-webui` project definition
- **THEN** `depends_on_projects` includes `traefik-stepca`
- **AND** dependency intent for default certificate issuance is explicit

### Requirement: Project `traefik-webui` defaults to StepCA ACME through Traefik TLS termination
The system SHALL default `traefik-webui` TLS mode to StepCA-backed ACME unless an explicit supported override is provided, and TLS termination SHALL be handled by Traefik according to the selected OpenSpec TLS mode.

#### Scenario: Default TLS mode is applied
- **WHEN** `project=traefik-webui` is run without TLS override
- **THEN** Traefik certificate handling for WebUI routes uses `stepca-acme`
- **AND** deployment proceeds only when required StepCA ACME settings are available

#### Scenario: TLS override is provided
- **WHEN** an operator provides an explicit supported `tls_mode` override
- **THEN** Traefik uses the requested TLS mode for WebUI routes
- **AND** deployment validates mode-specific required variables before compose apply

### Requirement: Project `traefik-webui` deploys only manifest-declared services
The system SHALL deploy only services declared by the `traefik-webui` manifest and SHALL reject ad-hoc runtime service overrides.

#### Scenario: Runtime service override conflicts with manifest
- **WHEN** runtime inputs attempt to deploy services outside the manifest service list
- **THEN** deployment fails with a contract-violation message
- **AND** `docker compose up -d` is not executed with conflicting service selection

### Requirement: Project `traefik-docling` is discoverable in deployment catalog before service implementation
The system SHALL allow `traefik-docling` to be represented in the deployment project catalog even when the Docling service stack is not yet implemented.

#### Scenario: Operator lists available projects
- **WHEN** an operator runs a project catalog listing command
- **THEN** `traefik-docling` appears as a supported project identifier
- **AND** the project contract is discoverable without requiring service runtime availability

### Requirement: Project `traefik-docling` declares StepCA dependency and TLS default contract
The system SHALL define `traefik-stepca` as dependency for `traefik-docling` and SHALL default TLS mode to StepCA-backed ACME unless an explicit supported override is provided.

#### Scenario: Docling manifest contract is inspected
- **WHEN** an operator inspects the `traefik-docling` project definition
- **THEN** `depends_on_projects` includes `traefik-stepca`
- **AND** default `tls_mode` is `stepca-acme`
- **AND** supported TLS override behavior is explicit in deployment contract

### Requirement: Project `traefik-docling` fails fast before compose apply when service is not implemented
The system SHALL stop deployment before compose apply for `traefik-docling` when required Docling service/profile implementation is missing.

#### Scenario: Operator deploys `traefik-docling` before service implementation
- **WHEN** an operator runs `make deployment-project project=traefik-docling`
- **THEN** deployment exits before `docker compose up -d`
- **AND** the error message clearly states that Docling service implementation is pending
- **AND** the message points to deployment-only contract status rather than generic compose failure

### Requirement: Project `traefik-docling` enforces manifest service contract once implemented
The system SHALL keep service selection bound to manifest-declared services and SHALL reject ad-hoc runtime service overrides for `traefik-docling`.

#### Scenario: Runtime service override conflicts with Docling manifest
- **WHEN** runtime input attempts to deploy services outside the manifest service list
- **THEN** deployment fails with a contract-violation message
- **AND** compose apply is not executed with conflicting service selection

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

### Requirement: Project `traefik-dns-bind` deploys BIND with Traefik edge services
The system SHALL provide a predefined project `traefik-dns-bind` that deploys the BIND DNS service together with Traefik edge services via the project workflow.

#### Scenario: Operator selects `project=traefik-dns-bind`
- **WHEN** an operator runs `make deployment-project project=traefik-dns-bind`
- **THEN** project deployment syncs the declared repository/ref on the target VM
- **AND** compose apply starts the manifest-declared services for Traefik and BIND

### Requirement: Project `traefik-dns-bind` enforces DNS and HTTP(S) traffic boundary
The system SHALL keep DNS traffic served by BIND on UDP/TCP 53 and SHALL use Traefik only for HTTP(S) project routes when present.

#### Scenario: DNS traffic path is evaluated
- **WHEN** the `traefik-dns-bind` project is deployed
- **THEN** DNS service exposure remains bound to BIND DNS ports
- **AND** Traefik is not used as a DNS protocol proxy path

### Requirement: Project `traefik-dns-bind` uses OpenSpec TLS mode for Traefik HTTPS routes
The system SHALL apply OpenSpec TLS mode through Traefik for HTTPS routes in `traefik-dns-bind`, defaulting to `stepca-acme` unless explicitly overridden with a supported mode.

#### Scenario: Default TLS mode is applied
- **WHEN** `project=traefik-dns-bind` is run without TLS override
- **THEN** Traefik certificate handling for project HTTPS routes uses `stepca-acme`
- **AND** deployment proceeds only when required StepCA ACME settings are available

#### Scenario: TLS override is provided
- **WHEN** an operator provides a supported `tls_mode` override
- **THEN** Traefik uses the requested TLS mode for project HTTPS routes
- **AND** deployment validates mode-specific required variables before compose apply

### Requirement: Project `traefik-dns-bind` deploys only manifest-declared services
The system SHALL deploy only services declared by the `traefik-dns-bind` manifest and SHALL reject ad-hoc runtime service overrides.

#### Scenario: Runtime service override conflicts with manifest
- **WHEN** runtime inputs attempt to deploy services outside the manifest service list
- **THEN** deployment fails with a contract-violation message
- **AND** `docker compose up -d` is not executed with conflicting service selection

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

### Requirement: Project `traefik-rocketchat` deploys Rocket.Chat behind Traefik
The system SHALL publish Rocket.Chat through Traefik reverse proxy in the `traefik-rocketchat` project workflow.

#### Scenario: Operator selects `project=traefik-rocketchat`
- **WHEN** an operator runs `make deployment-project project=traefik-rocketchat`
- **THEN** runtime routing for Rocket.Chat is exposed through Traefik-managed routes
- **AND** Rocket.Chat is not exposed as a direct bypass of the Traefik edge path

### Requirement: Project `traefik-rocketchat` declares dependencies on StepCA and Keycloak projects
The system SHALL provide a predefined project `traefik-rocketchat` whose manifest declares dependencies on `traefik-stepca` and `traefik-keycloak`.

#### Scenario: Rocket.Chat manifest is inspected
- **WHEN** an operator inspects the `traefik-rocketchat` project definition
- **THEN** `depends_on_projects` includes `traefik-stepca` and `traefik-keycloak`
- **AND** dependency intent is explicit without relying on external documentation

### Requirement: Project `traefik-rocketchat` defaults to StepCA ACME for certificates through Traefik TLS termination
The system SHALL default `traefik-rocketchat` project TLS mode to StepCA-backed ACME unless an explicit supported override is provided, and TLS termination SHALL be handled by Traefik according to the selected OpenSpec TLS mode.

#### Scenario: Default TLS mode is applied
- **WHEN** `project=traefik-rocketchat` is run without TLS override
- **THEN** runtime configuration uses StepCA ACME as certificate source
- **AND** Traefik certificate resolution uses StepCA ACME settings from project/environment contract
- **AND** deployment proceeds only when required StepCA ACME settings are available

#### Scenario: TLS override is provided
- **WHEN** an operator provides an explicit supported `tls_mode` override
- **THEN** the project uses the requested TLS mode instead of StepCA ACME default
- **AND** deployment validates mode-specific required variables before compose apply

### Requirement: Project `traefik-rocketchat` enforces Keycloak-based authentication contract
The system SHALL configure Rocket.Chat authentication integration with Keycloak according to the project manifest contract.

#### Scenario: Auth contract is applied
- **WHEN** `project=traefik-rocketchat` is deployed with dependencies satisfied
- **THEN** runtime config applies Keycloak-backed authentication for Rocket.Chat sign-in
- **AND** deployment fails fast if required Keycloak integration variables are missing

### Requirement: Project `traefik-rocketchat` deploys only manifest-declared services
The system SHALL deploy only services declared by the `traefik-rocketchat` manifest and SHALL reject ad-hoc runtime service overrides.

#### Scenario: Runtime service override conflicts with manifest
- **WHEN** runtime inputs attempt to deploy services outside the manifest service list
- **THEN** deployment fails with a contract-violation message
- **AND** `docker compose up -d` is not executed with conflicting service selection

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

### Requirement: Project `traefik-wikijs` deploys Wiki.js behind Traefik
The system SHALL publish Wiki.js through Traefik reverse proxy in the `traefik-wikijs` project workflow.

#### Scenario: Operator selects `project=traefik-wikijs`
- **WHEN** an operator runs `make deployment-project project=traefik-wikijs`
- **THEN** runtime routing for Wiki.js is exposed through Traefik-managed routes
- **AND** Wiki.js is not exposed as a direct bypass of the Traefik edge path

### Requirement: Project `traefik-wikijs` declares dependencies on StepCA and Keycloak projects
The system SHALL provide a predefined project `traefik-wikijs` whose manifest declares dependencies on `traefik-stepca` and `traefik-keycloak`.

#### Scenario: Wikijs manifest is inspected
- **WHEN** an operator inspects the `traefik-wikijs` project definition
- **THEN** `depends_on_projects` includes `traefik-stepca` and `traefik-keycloak`
- **AND** dependency intent is explicit without relying on external documentation

### Requirement: Project `traefik-wikijs` defaults to StepCA ACME for certificates through Traefik TLS termination
The system SHALL default `traefik-wikijs` project TLS mode to StepCA-backed ACME unless an explicit supported override is provided, and TLS termination SHALL be handled by Traefik according to the selected OpenSpec TLS mode.

#### Scenario: Default TLS mode is applied
- **WHEN** `project=traefik-wikijs` is run without TLS override
- **THEN** runtime configuration uses StepCA ACME as certificate source
- **AND** Traefik certificate resolution uses StepCA ACME settings from project/environment contract
- **AND** deployment proceeds only when required StepCA ACME settings are available

#### Scenario: TLS override is provided
- **WHEN** an operator provides an explicit supported `tls_mode` override
- **THEN** the project uses the requested TLS mode instead of StepCA ACME default
- **AND** deployment validates mode-specific required variables before compose apply

### Requirement: Project `traefik-wikijs` enforces Keycloak-based authentication contract
The system SHALL configure Wiki.js authentication integration with Keycloak according to the project manifest contract.

#### Scenario: Auth contract is applied
- **WHEN** `project=traefik-wikijs` is deployed with dependencies satisfied
- **THEN** runtime config applies Keycloak-backed authentication for Wiki.js access
- **AND** deployment fails fast if required Keycloak integration variables are missing

### Requirement: Project `traefik-wikijs` deploys only manifest-declared services
The system SHALL deploy only services declared by the `traefik-wikijs` manifest and SHALL reject ad-hoc runtime service overrides.

#### Scenario: Runtime service override conflicts with manifest
- **WHEN** runtime inputs attempt to deploy services outside the manifest service list
- **THEN** deployment fails with a contract-violation message
- **AND** `docker compose up -d` is not executed with conflicting service selection

### Requirement: Project `traefik-observability` publishes web endpoints behind Traefik
The system SHALL publish observability web endpoints through Traefik reverse proxy in the `traefik-observability` project workflow.

#### Scenario: Operator selects `project=traefik-observability`
- **WHEN** an operator runs `make deployment-project project=traefik-observability`
- **THEN** runtime routing for observability web endpoints is exposed through Traefik-managed routes
- **AND** observability web services are not exposed as a direct bypass of the Traefik edge path

### Requirement: Project `traefik-observability` declares StepCA and Keycloak project dependencies
The system SHALL provide a predefined project `traefik-observability` whose manifest declares dependencies on `traefik-stepca` and `traefik-keycloak`.

#### Scenario: Observability project manifest is inspected
- **WHEN** an operator inspects the `traefik-observability` project definition
- **THEN** `depends_on_projects` includes `traefik-stepca` and `traefik-keycloak`
- **AND** dependency intent is explicit without relying on external documentation

### Requirement: Project `traefik-observability` defaults to StepCA ACME for certificates through Traefik TLS termination
The system SHALL default `traefik-observability` project TLS mode to StepCA-backed ACME unless an explicit supported override is provided, and TLS termination SHALL be handled by Traefik according to the selected OpenSpec TLS mode.

#### Scenario: Default TLS mode is applied
- **WHEN** `project=traefik-observability` is run without TLS override
- **THEN** runtime configuration uses StepCA ACME as certificate source
- **AND** Traefik certificate resolution uses StepCA ACME settings from project/environment contract
- **AND** compose deployment proceeds only when required StepCA ACME settings are available

#### Scenario: TLS override is provided
- **WHEN** an operator provides an explicit supported `tls_mode` override
- **THEN** the project uses the requested TLS mode instead of StepCA ACME default
- **AND** deployment validates mode-specific required variables before compose apply

### Requirement: Project `traefik-observability` enforces Keycloak-based authentication contract
The system SHALL configure observability endpoints to use Keycloak-based authentication as defined by the project manifest contract.

#### Scenario: Auth contract is applied
- **WHEN** `project=traefik-observability` is deployed with dependencies satisfied
- **THEN** runtime config applies Keycloak-backed authentication integration for observability access paths
- **AND** deployment fails fast if required Keycloak integration variables are missing

### Requirement: Project `traefik-observability` deploys only manifest-declared services
The system SHALL deploy only services declared by the `traefik-observability` project manifest and SHALL reject ad-hoc runtime service overrides.

#### Scenario: Runtime service override conflicts with project manifest
- **WHEN** runtime inputs attempt to deploy services outside the manifest service list
- **THEN** deployment fails with a contract-violation message
- **AND** `docker compose up -d` is not executed with conflicting service selection

### Requirement: Project `traefik-stepca` is registered with explicit immutable deployment intent
The system SHALL provide a predefined project `traefik-stepca` with an explicit manifest that declares `repo_url`, pinned `repo_ref`, `compose_profile=stepca`, `services=[traefik, step-ca, whoami]`, `tls_mode`, and `required_env`.

#### Scenario: Project manifest is inspected
- **WHEN** an operator or automation inspects the `traefik-stepca` manifest
- **THEN** the exact repository source and pinned reference are visible
- **AND** the exact compose profile and services are visible
- **AND** the selected TLS mode for Traefik certificate handling is visible
- **AND** required environment variables are visible without inferring from external docs

### Requirement: Project `traefik-stepca` deploys Traefik and Smallstep through the project workflow
The system SHALL deploy `traefik` and `step-ca` for `project=traefik-stepca` using the project deployment workflow on the provisioned VM.

#### Scenario: Operator selects `traefik-stepca`
- **WHEN** an operator runs `make deployment-project project=traefik-stepca`
- **THEN** the project deployment playbook syncs `compose-traeffik` from the manifest source and pinned ref on the VM
- **AND** the deployment starts only the predefined services `traefik` and `step-ca`
- **AND** compose execution uses profile `stepca`
- **AND** TLS termination for exposed routes is handled by Traefik using the project-selected OpenSpec TLS mode

### Requirement: Project `traefik-stepca` validates required environment before compose apply
The system SHALL validate required project environment variables before running compose apply for `traefik-stepca`.

#### Scenario: Required project environment is missing
- **WHEN** any variable declared in `required_env` is missing at runtime
- **THEN** project deployment fails before `docker compose up -d`
- **AND** the output reports which variable is missing

### Requirement: Project `traefik-stepca` prevents ad-hoc runtime service override
The system SHALL enforce service/profile selection from the `traefik-stepca` manifest and SHALL reject runtime overrides that conflict with that contract.

#### Scenario: Operator attempts to override project services
- **WHEN** runtime inputs attempt to deploy services outside the manifest-declared list
- **THEN** the workflow fails with a contract-violation message
- **AND** compose apply is not executed with the override

### Requirement: Project `traefik-stepca` supports idempotent re-runs
The system SHALL allow repeated execution of `project=traefik-stepca` on the same host and converge to the same declared state.

#### Scenario: Operator re-runs `traefik-stepca`
- **WHEN** project deployment is executed again for the same host
- **THEN** repository sync and compose apply run in-place
- **AND** the host remains aligned with the manifest-declared profile/services without creating duplicate stack intent

### Requirement: Project `traefik-stepca` enables Traefik dashboard by default
The system SHALL enable the Traefik dashboard by default for `traefik-stepca` and SHALL configure a valid dashboard auth users file path for this project.

#### Scenario: Project defaults are applied
- **WHEN** `project=traefik-stepca` is deployed
- **THEN** `TRAEFIK_DASHBOARD=true` is set in project environment
- **AND** `TRAEFIK_DASHBOARD_BASIC_AUTH_HTPASSWD_PATH` points to a non-example path under `/etc/traefik/auth/`
- **AND** dynamic Traefik config is rendered so the dashboard route is active

