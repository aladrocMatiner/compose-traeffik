## ADDED Requirements

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
