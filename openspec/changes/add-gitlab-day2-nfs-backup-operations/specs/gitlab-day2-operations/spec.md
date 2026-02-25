## ADDED Requirements

### Requirement: GitLab day-2 operation commands are provided
The system SHALL provide documented commands and scripts for GitLab backup, restore, upgrade assistance, and debug collection.

#### Scenario: Day-2 commands are discoverable
- **WHEN** a user runs `make help` or reads the GitLab service documentation
- **THEN** they can find `gitlab-backup`, `gitlab-restore`, `gitlab-upgrade`, and `gitlab-debug`
- **AND** each command's purpose and prerequisites are documented

### Requirement: Optional NFS/NAS backup destination is supported as a host-mounted target
The system SHALL support an optional NFS/NAS backup destination for GitLab backups using a host-mounted share, while keeping GitLab repository primary storage on supported local storage.

#### Scenario: NFS backup disabled
- **WHEN** `GITLAB_BACKUP_NFS_ENABLED` is false or unset
- **THEN** GitLab backup commands operate using local backup paths only
- **AND** no NFS-specific validation is required

#### Scenario: NFS backup enabled
- **WHEN** `GITLAB_BACKUP_NFS_ENABLED=true` and the host-mounted NFS path is configured
- **THEN** the GitLab backup workflow copies/uploads backups to the configured NFS destination path
- **AND** the workflow validates that the configured NFS destination path is a mounted host path before use
- **AND** documentation states that the NFS share is a backup target, not live Git repository storage

### Requirement: Restore and upgrade operations require explicit confirmation
The system SHALL require explicit confirmation for destructive or potentially disruptive GitLab day-2 operations such as restore and upgrade helpers.

#### Scenario: Restore without confirmation
- **WHEN** a user runs `make gitlab-restore` without the documented confirmation flag
- **THEN** the command aborts with a clear error explaining how to proceed safely

#### Scenario: Upgrade without confirmation
- **WHEN** a user runs `make gitlab-upgrade` without the documented confirmation flag
- **THEN** the command aborts with a clear error explaining how to proceed safely

### Requirement: Backup documentation covers config/secrets and restore compatibility
The system SHALL document that GitLab application backups are not sufficient by themselves and SHALL include configuration/secrets backup guidance and restore compatibility constraints.

#### Scenario: Operator reads backup runbook
- **WHEN** a user follows the GitLab backup documentation
- **THEN** the runbook explains which GitLab data is covered by the application backup and which config/secrets paths require separate backup
- **AND** the workflow documents or provides a separate config/secrets backup artifact path distinct from the app backup tar
- **AND** it states the version/edition compatibility expectations for restore
