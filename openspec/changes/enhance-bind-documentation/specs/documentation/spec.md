## MODIFIED Requirements

### Requirement: Accurate clone and setup instructions
The documentation SHALL provide concrete clone and directory instructions that work without placeholders and SHALL reflect the current branch workflow for DNS operations.

#### Scenario: New contributor follows quickstart
- **WHEN** a contributor reads the quickstart steps
- **THEN** the clone command and directory name are actionable without manual substitution
- **AND** DNS-related operational examples align with current branch commands

### Requirement: Documentation plan reflects current structure
The documentation plan SHALL reference the current docs file layout and not deprecated paths.

#### Scenario: Contributor uses the plan to find a doc
- **WHEN** a contributor follows a doc path in the plan
- **THEN** the referenced file exists in the repository
- **AND** the path points to current BIND-oriented docs for this branch
