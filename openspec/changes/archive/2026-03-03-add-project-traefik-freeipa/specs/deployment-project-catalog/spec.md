## ADDED Requirements

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
