## ADDED Requirements

### Requirement: Project `traefik-stepca` is registered with explicit immutable deployment intent
The system SHALL provide a predefined project `traefik-stepca` with an explicit manifest that declares `repo_url`, pinned `repo_ref`, `compose_profile=stepca`, `services=[traefik, step-ca]`, `tls_mode`, and `required_env`.

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
