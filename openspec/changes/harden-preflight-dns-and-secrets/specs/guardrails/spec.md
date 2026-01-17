## ADDED Requirements

### Requirement: Preflight validation gate
The system SHALL execute preflight validation before any Docker Compose invocation and abort with a non-zero exit status when validation fails.

#### Scenario: DNS target runs preflight
- **WHEN** a user runs `make dns-up`
- **THEN** preflight validation runs before Docker Compose is executed
- **AND** the command exits non-zero if validation fails

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
