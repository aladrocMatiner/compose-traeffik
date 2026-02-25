## MODIFIED Requirements
### Requirement: Preflight validation gate
The system SHALL execute preflight validation before any Docker Compose invocation and abort with a non-zero exit status when validation fails. The repository MAY define additional module-specific preflight checks for non-Compose workflows (for example AWX/k3d scripts) and those checks SHALL also fail fast with clear messages.

#### Scenario: DNS target runs preflight
- **WHEN** a user runs `make dns-up`
- **THEN** preflight validation runs before Docker Compose is executed
- **AND** the command exits non-zero if validation fails

#### Scenario: AWX target runs module preflight
- **WHEN** a user runs an AWX/k3d lifecycle target (`make awx-*`)
- **THEN** the command validates required tools and AWX/K3d environment values before mutating local cluster state
- **AND** exits non-zero with a clear message if prerequisites are missing

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
Operational documentation SHALL describe preflight validation and the required environment variables for admin UI authentication.

#### Scenario: Script documentation
- **WHEN** a user reads `scripts/README.md`
- **THEN** it lists `scripts/validate-env.sh` and the relevant htpasswd environment variables

### Requirement: AWX/k3d environment safety validation
The system SHALL validate AWX/k3d environment inputs that affect security or local networking (for example hostname labels, NodePort range, and secret placeholders) before AWX lifecycle operations proceed.

#### Scenario: Invalid AWX NodePort or placeholder secret
- **WHEN** an AWX lifecycle command is run with an invalid `AWX_NODEPORT_HTTP` or placeholder AWX secret values
- **THEN** the command fails before creating/updating the cluster or AWX resources
- **AND** the error identifies the invalid variable and expected format

#### Scenario: Unsafe kubeconfig path for local AWX module
- **WHEN** an AWX lifecycle command is configured to write `KUBECONFIG` into a non-gitignored or disallowed path in the repository
- **THEN** the command fails (or requires an explicit override as documented)
- **AND** the error explains the recommended gitignored path pattern
