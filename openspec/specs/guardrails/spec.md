# guardrails Specification

## Purpose
TBD - created by archiving change harden-preflight-dns-and-secrets. Update Purpose after archive.
## Requirements
### Requirement: Preflight validation gate
The system SHALL execute preflight validation before any Docker Compose invocation and abort with a non-zero exit status when validation fails. The validation SHALL support profile-gated checks for optional modules such as GitLab.

#### Scenario: DNS target runs preflight
- **WHEN** a user runs `make dns-up`
- **THEN** preflight validation runs before Docker Compose is executed
- **AND** the command exits non-zero if validation fails

#### Scenario: GitLab target runs preflight
- **WHEN** a user runs `make gitlab-up`
- **THEN** preflight validation evaluates GitLab-specific checks only when the `gitlab` profile is enabled
- **AND** the command exits non-zero on invalid required GitLab configuration

### Requirement: Profile parsing sanity
The system SHALL reject malformed `COMPOSE_PROFILES` values that would produce empty or invalid profile flags.

#### Scenario: Empty profile entry
- **WHEN** `COMPOSE_PROFILES` contains a leading, trailing, or double comma
- **THEN** preflight validation fails with a clear message

### Requirement: Admin UI auth safety
The system SHALL require non-example htpasswd files for admin UIs and only accept usersFile paths under `/etc/traefik/auth/`.

#### Scenario: Example htpasswd file provided
- **WHEN** a dashboard or DNS UI is enabled and the configured usersFile path points to an example file
- **THEN** preflight validation fails with a clear message

### Requirement: DNS admin password validation
The system SHALL require a non-placeholder `DNS_ADMIN_PASSWORD` when the dns profile is enabled.

#### Scenario: Placeholder DNS password
- **WHEN** `COMPOSE_PROFILES` includes `dns` and `DNS_ADMIN_PASSWORD` is empty or a known placeholder
- **THEN** preflight validation fails with a clear message

### Requirement: Htpasswd secrets ignored by git
The repository SHALL ignore non-example htpasswd files under `services/traefik/auth/` to prevent accidental commits.

#### Scenario: Real htpasswd file added
- **WHEN** a user creates `services/traefik/auth/*.htpasswd`
- **THEN** the file is ignored by git while `*.htpasswd.example` remains tracked

### Requirement: Preflight documentation
Operational documentation SHALL describe preflight validation and the required environment variables for admin UI authentication. The documentation SHALL also describe service-specific preflight checks added for modules such as GitLab.

#### Scenario: Script documentation
- **WHEN** a user reads `scripts/README.md`
- **THEN** it lists `scripts/validate-env.sh` and the relevant htpasswd environment variables

#### Scenario: GitLab preflight guidance
- **WHEN** a user reads GitLab setup documentation and `scripts/README.md`
- **THEN** they can identify GitLab-specific preflight requirements such as SSH port format and OIDC-required variables when OIDC is enabled

### Requirement: Safe default DNS bind exposure
The system SHALL require loopback-only `BIND_BIND_ADDRESS` by default when `bind` profile is enabled, unless an explicit non-local override is set.

#### Scenario: Non-local address blocked by default
- **WHEN** `COMPOSE_PROFILES` includes `bind`
- **AND** `BIND_BIND_ADDRESS` is non-loopback
- **AND** `BIND_ALLOW_NONLOCAL_BIND` is not `true`
- **THEN** preflight validation fails with a clear message

#### Scenario: Explicit override allows non-local bind
- **WHEN** `COMPOSE_PROFILES` includes `bind`
- **AND** `BIND_BIND_ADDRESS` is non-loopback
- **AND** `BIND_ALLOW_NONLOCAL_BIND=true`
- **THEN** preflight validation allows execution to continue

### Requirement: Rocket.Chat profile preflight validation
The system SHALL validate Rocket.Chat profile inputs and rendered config prerequisites before compose operations when the `rocketchat` profile is used.

#### Scenario: Rocket.Chat profile enabled without rendered config
- **WHEN** `COMPOSE_PROFILES` includes `rocketchat` and the rendered Rocket.Chat env file is missing
- **THEN** preflight validation fails with a clear message instructing the operator to run the Rocket.Chat bootstrap/render command

#### Scenario: Optional Keycloak integration enabled with invalid inputs
- **WHEN** Rocket.Chat Keycloak integration is enabled and the issuer URL is not HTTPS or required credentials are missing
- **THEN** preflight validation fails with a clear message

#### Scenario: Optional observability settings are invalid
- **WHEN** Rocket.Chat observability is enabled and the configured metrics port is invalid
- **THEN** preflight validation fails with a clear message

### Requirement: Semaphore UI profile-gated preflight validation
The system SHALL validate Semaphore UI configuration in preflight checks only when the `semaphoreui` profile is enabled.

#### Scenario: Semaphore UI profile disabled
- **WHEN** the `semaphoreui` profile is not enabled
- **THEN** missing Semaphore UI variables do not block unrelated compose workflows

#### Scenario: Semaphore UI profile enabled with invalid config
- **WHEN** the `semaphoreui` profile is enabled and required Semaphore UI values are invalid or placeholders
- **THEN** preflight validation fails with a clear error message

### Requirement: OIDC and observability safety checks for Semaphore UI
The system SHALL validate optional OIDC and observability settings for Semaphore UI with safe defaults.

#### Scenario: OIDC disabled
- **WHEN** OIDC is disabled for Semaphore UI
- **THEN** OIDC-specific values are not required by preflight validation

#### Scenario: OIDC enabled with missing client secret
- **WHEN** OIDC is enabled and required provider/client settings are missing or placeholders
- **THEN** preflight validation fails before Compose is executed

#### Scenario: Unsafe observability exposure requested by default config
- **WHEN** Semaphore UI observability settings would expose telemetry publicly under default/safe mode
- **THEN** preflight validation fails unless the configuration explicitly uses a documented override path

### Requirement: Plane profile preflight validation is profile-gated and integration-aware
The system SHALL validate Plane configuration before compose execution when the `plane` profile is enabled, including core secrets/hostname checks and optional integration checks for Keycloak and observability.

#### Scenario: Missing core Plane configuration
- **WHEN** `COMPOSE_PROFILES` includes `plane` and required Plane values are missing or placeholders
- **THEN** preflight validation fails with clear remediation guidance (including bootstrap command hints)

#### Scenario: Keycloak integration enabled with incomplete OIDC configuration
- **WHEN** Plane OIDC integration is enabled and required Keycloak/OIDC values are incomplete
- **THEN** preflight validation fails with a clear message before containers start

#### Scenario: Keycloak integration disabled
- **WHEN** Plane OIDC integration is disabled
- **THEN** Keycloak-specific checks do not block Plane startup

#### Scenario: Observability integration disabled
- **WHEN** Plane observability integration is disabled
- **THEN** observability-specific checks do not block Plane startup

### Requirement: FreeIPA profile enforces preflight contracts
The system SHALL enforce FreeIPA-specific preflight guardrails only when profile `freeipa` is enabled.

#### Scenario: Missing FreeIPA core secrets
- **WHEN** `COMPOSE_PROFILES` includes `freeipa` and required secrets are missing
- **THEN** preflight fails before compose execution with a clear error.

### Requirement: FreeIPA TLS mode contract is validated
The system SHALL validate `FREEIPA_TLS_MODE` against supported values and enforce resolver/profile compatibility.

#### Scenario: Unsupported TLS mode
- **WHEN** `FREEIPA_TLS_MODE` is not one of `local-ca`, `letsencrypt`, or `stepca-acme`
- **THEN** preflight fails with a contract violation message.

#### Scenario: StepCA mode without resolver contract
- **WHEN** `FREEIPA_TLS_MODE=stepca-acme` and neither `stepca` profile nor `TLS_CERT_RESOLVER=stepca-resolver` is active
- **THEN** preflight fails before compose execution.

### Requirement: FreeIPA optional integration contracts are validated
The system SHALL validate Keycloak and observability contracts when their toggles are enabled.

#### Scenario: Keycloak enabled with incomplete contract
- **WHEN** `FREEIPA_KEYCLOAK_ENABLED=true` and required Keycloak values are missing
- **THEN** preflight fails with a clear contract message.

#### Scenario: Observability enabled with incomplete contract
- **WHEN** `FREEIPA_OBSERVABILITY_ENABLED=true` and required observability values are missing
- **THEN** preflight fails with a clear contract message.

### Requirement: Advanced observability preflight validation
The system SHALL validate advanced observability configuration variables when the `observability` profile is enabled, including variables needed for Tempo, Pyroscope, and k6 execution settings.

#### Scenario: Invalid advanced observability variable
- **WHEN** `COMPOSE_PROFILES` includes `observability` and an advanced observability variable has an invalid format/value
- **THEN** preflight validation fails with a clear corrective message

#### Scenario: Safe defaults keep backward compatibility
- **WHEN** existing observability users upgrade without setting new advanced variables
- **THEN** preflight validation accepts the configuration if defaults are safe
- **AND** metrics/logs baseline behavior remains available

#### Scenario: k6 execution without required target config
- **WHEN** a user invokes the k6 synthetic check target and required target URL settings are missing
- **THEN** validation fails early with explicit instructions for required variables

### Requirement: Observability profile preflight validation
The system SHALL validate observability-required environment variables before compose runs when the `observability` profile is enabled.

#### Scenario: Missing Grafana admin password
- **WHEN** `COMPOSE_PROFILES` includes `observability` and `GRAFANA_ADMIN_PASSWORD` is missing or a placeholder
- **THEN** preflight validation fails with a clear message that points to `make observability-bootstrap`

#### Scenario: Observability profile disabled
- **WHEN** the `observability` profile is not enabled
- **THEN** observability-specific validation checks do not block unrelated stack workflows

#### Scenario: Observability enabled without app telemetry targets
- **WHEN** `COMPOSE_PROFILES` includes `observability` but app modules such as `ctfd` are not enabled
- **THEN** preflight validation MAY emit a guidance warning about partial dashboards
- **AND** it MUST NOT fail because Traefik-only observability is a supported mode

#### Scenario: Missing retention variables uses safe defaults
- **WHEN** the `observability` profile is enabled and optional retention variables are unset
- **THEN** preflight validation does not fail
- **AND** documentation and module defaults still provide bounded retention behavior

### Requirement: Docling profile preflight validation is profile-gated and integration-aware
The system SHALL validate Docling configuration before compose execution when the `docling` profile is enabled, including core hostname/auth checks and optional integration checks for Keycloak and observability.

#### Scenario: Missing core Docling configuration
- **WHEN** `COMPOSE_PROFILES` includes `docling` and required Docling values are missing or placeholders
- **THEN** preflight validation fails with clear remediation guidance (including bootstrap command hints)

#### Scenario: Keycloak integration enabled with incomplete auth configuration
- **WHEN** Docling Keycloak integration is enabled and required auth values are incomplete
- **THEN** preflight validation fails with a clear message before containers start

#### Scenario: Keycloak integration disabled
- **WHEN** Docling Keycloak integration is disabled
- **THEN** Keycloak-specific checks do not block Docling startup

#### Scenario: Observability integration disabled
- **WHEN** Docling observability integration is disabled
- **THEN** observability-specific checks do not block Docling startup

### Requirement: CTFd profile preflight validation
The system SHALL validate CTFd-required environment variables and hostname format before compose runs when the `ctfd` profile is enabled.

#### Scenario: Missing CTFd secrets
- **WHEN** `COMPOSE_PROFILES` includes `ctfd` and required CTFd secrets are missing or placeholder values
- **THEN** preflight validation fails with a clear message that points to `make ctfd-bootstrap`

#### Scenario: CTFd profile disabled
- **WHEN** the `ctfd` profile is not enabled
- **THEN** CTFd-specific validation checks do not block unrelated stack workflows

