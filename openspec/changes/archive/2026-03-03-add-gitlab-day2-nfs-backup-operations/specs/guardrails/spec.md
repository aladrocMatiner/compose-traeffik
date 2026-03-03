## MODIFIED Requirements

### Requirement: Preflight validation gate
The system SHALL execute preflight validation before any Docker Compose invocation and abort with a non-zero exit status when validation fails. The validation SHALL support profile-gated checks for optional modules and related day-2 operations.

#### Scenario: DNS target runs preflight
- **WHEN** a user runs `make dns-up`
- **THEN** preflight validation runs before Docker Compose is executed
- **AND** the command exits non-zero if validation fails

#### Scenario: GitLab day-2 NFS validation
- **WHEN** a user runs a GitLab backup-related command with `GITLAB_BACKUP_NFS_ENABLED=true`
- **THEN** validation checks the required NFS backup variables and path safety constraints
- **AND** the command exits non-zero with a clear message on invalid configuration
