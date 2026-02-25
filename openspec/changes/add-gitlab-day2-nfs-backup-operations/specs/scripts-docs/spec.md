## MODIFIED Requirements

### Requirement: Scripts documentation
The system SHALL document all operational scripts in `scripts/README.md`, including purpose, usage, required env vars, and side effects. GitLab day-2 scripts and optional NFS backup behavior SHALL be documented when added.

#### Scenario: Script inventory
- **WHEN** a user opens `scripts/README.md`
- **THEN** they can find every script listed with its purpose and how to run it

#### Scenario: GitLab day-2 scripts documented
- **WHEN** GitLab day-2 scripts are implemented
- **THEN** `scripts/README.md` documents backup, restore, upgrade, and debug scripts including confirmation flags and optional NFS-related env vars
