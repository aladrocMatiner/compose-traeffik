## ADDED Requirements

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
