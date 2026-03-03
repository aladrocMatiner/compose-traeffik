# deployment-project-system Specification

## Purpose
TBD - created by archiving change add-keycloak-realm-bootstrap-and-project-clients. Update Purpose after archive.
## Requirements
### Requirement: `traefik-keycloak` bootstrap SHALL ensure shared realm and initial user
The system SHALL ensure a shared Keycloak realm `local.test` and an initial login user during deployment of `project=traefik-keycloak`.

#### Scenario: First deployment bootstraps realm and user
- **WHEN** an operator runs `make deployment-project project=traefik-keycloak`
- **THEN** deployment ensures realm `local.test` exists and is enabled
- **AND** deployment ensures user `jose.romero` exists with an initial password
- **AND** deployment reports success without requiring manual Keycloak console setup

#### Scenario: Re-run is idempotent
- **WHEN** `project=traefik-keycloak` is re-executed
- **THEN** existing realm and user are reused/updated in place
- **AND** no duplicate realm/user entities are created

### Requirement: Project deployments MAY declare OIDC client provisioning contract
The system SHALL support project-level OIDC client provisioning inputs so each deployed project can create or update its own Keycloak client under the shared realm.

#### Scenario: Project declares OIDC contract
- **WHEN** a project deployment includes OIDC client contract values (`realm`, `client_id`, `redirect_uris`, `web_origins`)
- **THEN** deployment treats those values as authoritative for Keycloak client provisioning
- **AND** malformed OIDC contract input is rejected before compose apply

### Requirement: OIDC clients SHALL be created or updated during project deployment
The system SHALL create or update the project-specific OIDC client as part of project deployment execution, rather than relying on pre-created global clients.

#### Scenario: Client does not exist yet
- **WHEN** a project requiring OIDC is deployed and its client is missing in realm `local.test`
- **THEN** deployment creates the client with declared redirect URIs and web origins
- **AND** generated/effective client secret is propagated to the target project runtime configuration

#### Scenario: Client already exists
- **WHEN** a project requiring OIDC is deployed and its client already exists
- **THEN** deployment updates client settings to the declared contract
- **AND** deployment remains idempotent across repeated runs

### Requirement: OIDC project deployments SHALL fail fast when Keycloak dependency is unavailable
The system SHALL fail before compose apply when an OIDC-enabled project cannot reach or authenticate against the Keycloak dependency.

#### Scenario: Keycloak dependency is missing
- **WHEN** an OIDC-enabled project is deployed without a valid Keycloak dependency context
- **THEN** deployment fails with an explicit dependency/authentication error
- **AND** the output includes recovery guidance to deploy/fix `traefik-keycloak` first

### Requirement: OIDC clients SHALL be provisioned on-demand only
The system SHALL provision OIDC clients only for projects that are actually deployed.

#### Scenario: Unsupported or undeployed project
- **WHEN** a project has not been selected for deployment
- **THEN** no Keycloak client is created for that project
- **AND** the realm remains free of unused pre-seeded clients

### Requirement: Project manifest supports inter-project dependencies
The system SHALL support an optional `depends_on_projects` field in project manifests, containing project ids required before deploying the selected project.

#### Scenario: Manifest declares dependencies
- **WHEN** a project manifest includes `depends_on_projects`
- **THEN** each entry is interpreted as a required project dependency
- **AND** non-list or malformed values are rejected as invalid manifest input

### Requirement: Deployment project workflow performs dependency preflight checks
The system SHALL validate declared project dependencies before running bootstrap and project deploy stages.

#### Scenario: Missing dependencies are detected
- **WHEN** `deployment-project` is executed for a project whose declared dependencies are not satisfied
- **THEN** the workflow fails before project deployment
- **AND** the error output lists missing dependency project ids
- **AND** the output includes explicit recovery guidance to deploy dependencies first

#### Scenario: Dependencies are satisfied
- **WHEN** all declared dependencies are satisfied
- **THEN** the workflow continues to baseline bootstrap and project deployment stages
- **AND** no dependency error is emitted

#### Scenario: Security dependencies gate Traefik-published app deployment
- **WHEN** a project published behind Traefik declares security dependencies (for example StepCA and Keycloak)
- **THEN** dependency preflight must pass before app deployment is allowed
- **AND** deployment is blocked if those declared security dependencies are not satisfied

### Requirement: Make target `deployment-project` selects a predefined deployment project
The system SHALL provide a Make target `deployment-project` that requires `project=<id>` and runs a predefined project deployment workflow.

#### Scenario: Operator runs project deployment with defaults
- **WHEN** an operator runs `make deployment-project project=<id>`
- **THEN** the workflow resolves the selected project definition
- **AND** the deployment uses `target=qemu` and `os=ubuntu` by default for `deployment-project` unless explicitly overridden

#### Scenario: Missing project selector is rejected
- **WHEN** an operator runs `make deployment-project` without `project=<id>`
- **THEN** the command fails with a clear usage error
- **AND** no provisioning or deployment action is started

### Requirement: Make target `deployment-project-list` exposes supported project ids
The system SHALL provide a Make target `deployment-project-list` that prints supported project ids in a stable, script-friendly format.

#### Scenario: Operator lists supported projects
- **WHEN** an operator runs `make deployment-project-list`
- **THEN** the command prints one supported project id per line in stable order
- **AND** the command exits with status `0` without requiring active VM resources

### Requirement: Project workflow enforces ordered baseline and project deployment stages
The system SHALL execute the project workflow in a fixed order: infrastructure provisioning, SSH/cloud-init readiness wait, baseline host bootstrap via `system_bootstrap`, and project-specific deployment.

#### Scenario: Ordered execution path
- **WHEN** a supported project is selected
- **THEN** VM provisioning is executed first
- **AND** readiness checks run before any project deployment tasks
- **AND** baseline bootstrap is executed through `system_bootstrap` before the project playbook executes

### Requirement: Project definitions use a validated manifest schema
The system SHALL require each project definition to provide a manifest with required keys `id`, `description`, `repo_url`, `repo_ref`, `compose_profile`, `services`, `deploy_playbook`, `required_env`, and `tls_mode`, and MAY include optional `public_host`.

#### Scenario: Invalid manifest is rejected
- **WHEN** a project manifest is missing required keys or has invalid field types
- **THEN** the workflow fails fast with a clear manifest-validation error
- **AND** no provisioning or deployment action is started

#### Scenario: Unsupported project id is rejected
- **WHEN** an operator provides an unknown `project=<id>`
- **THEN** the workflow fails fast with a clear unsupported-project message
- **AND** no partial deployment is attempted

### Requirement: Web application projects are exposed through Traefik with OpenSpec TLS mode
The system SHALL expose web application projects behind Traefik reverse proxy and SHALL enforce that TLS termination is handled by Traefik using the manifest-selected OpenSpec TLS mode.

#### Scenario: Project declares web TLS mode
- **WHEN** a web application project manifest is resolved
- **THEN** Traefik is the required edge proxy for project HTTP(S) routes
- **AND** certificate handling follows `tls_mode` from the project manifest

### Requirement: Web application projects resolve a deterministic public hostname
The system SHALL resolve public hostname for web application projects as `<project-id>.<BASE_DOMAIN>` by default and SHALL allow optional override through manifest field `public_host`.

#### Scenario: Default public hostname is used
- **WHEN** a web application project does not define `public_host`
- **THEN** deployment resolves public hostname to `<project-id>.<BASE_DOMAIN>`
- **AND** Traefik route host matching uses that resolved hostname

#### Scenario: Manifest overrides public hostname
- **WHEN** a web application project manifest defines `public_host`
- **THEN** deployment uses `public_host` instead of `<project-id>.<BASE_DOMAIN>`
- **AND** route host resolution remains validated before compose apply

### Requirement: Project workflow defines explicit failure handling policy
The system SHALL keep provisioned infrastructure by default when a failure occurs after provisioning, and SHALL provide explicit recovery guidance.

#### Scenario: Failure occurs after VM provisioning
- **WHEN** `deployment-project` fails during bootstrap or project deploy stages
- **THEN** the workflow reports the failed stage clearly
- **AND** the workflow does not auto-destroy the VM by default
- **AND** the output includes explicit next-step guidance for retry and manual destroy commands

### Requirement: Project workflow is idempotent for repeated runs
The system SHALL support repeated execution of the same `project=<id>` on the same host without destructive reinitialization.

#### Scenario: Operator re-runs an already deployed project
- **WHEN** `deployment-project` is executed again for the same project and target host
- **THEN** repository sync and compose application are applied in-place
- **AND** the workflow converges to the declared manifest state without duplicating project resources

### Requirement: Project workflow resolves deterministic deployment host naming
The system SHALL resolve deployment host naming from the selected project and platform selectors using the pattern `<project-id>-<os>` and SHALL append `-<init>` only when `init` is explicitly provided.

#### Scenario: Host name without init selector
- **WHEN** an operator runs `make deployment-project project=<id> os=<os>` without `init=...`
- **THEN** the resolved deployment host name is `<project-id>-<os>`
- **AND** no trailing init segment is added

#### Scenario: Host name with init selector
- **WHEN** an operator runs `make deployment-project project=<id> os=<os> init=<init>`
- **THEN** the resolved deployment host name is `<project-id>-<os>-<init>`
- **AND** the same resolved name is used consistently across provisioning and deployment stages

