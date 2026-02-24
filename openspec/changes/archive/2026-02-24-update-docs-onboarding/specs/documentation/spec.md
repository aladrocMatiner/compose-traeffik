## ADDED Requirements
### Requirement: Accurate clone and setup instructions
The documentation SHALL provide concrete clone and directory instructions that work without placeholders.

#### Scenario: New contributor follows quickstart
- **WHEN** a contributor reads the quickstart steps
- **THEN** the clone command and directory name are actionable without manual substitution

### Requirement: Documentation plan reflects current structure
The documentation plan SHALL reference the current docs file layout and not deprecated paths.

#### Scenario: Contributor uses the plan to find a doc
- **WHEN** a contributor follows a doc path in the plan
- **THEN** the referenced file exists in the repository
