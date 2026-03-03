## MODIFIED Requirements

### Requirement: Preflight validation gate
The system SHALL execute preflight validation before any Docker Compose invocation and abort with a non-zero exit status when validation fails.

#### Scenario: BIND target runs preflight
- **WHEN** a user runs `make bind-up`
- **THEN** preflight validation runs before Docker Compose is executed
- **AND** the command exits non-zero if validation fails

### Requirement: Admin UI auth safety
The system SHALL require non-example htpasswd files for enabled admin UIs and only accept usersFile paths under `/etc/traefik/auth/`.

#### Scenario: Example htpasswd file provided
- **WHEN** the Traefik dashboard is enabled and the configured usersFile path points to an example file
- **THEN** preflight validation fails with a clear message

## REMOVED Requirements

### Requirement: DNS admin password validation
**Reason**: Technitium (`dns` profile) is removed from `dns-bind`; BIND flow does not use `DNS_ADMIN_PASSWORD`.
**Migration**: Use `bind` profile commands and `BIND_BIND_ADDRESS`; remove legacy `DNS_ADMIN_PASSWORD` usage from local env files.
