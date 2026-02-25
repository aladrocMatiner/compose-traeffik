## MODIFIED Requirements
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

### Requirement: Stateful service runbooks are available
The documentation SHALL provide operational runbooks for stateful services introduced in the repository (such as AWX), covering at least backup/restore/upgrade expectations and links to the concrete scripts/targets when available.

#### Scenario: AWX operator needs maintenance guidance
- **WHEN** a user opens the AWX service documentation or linked runbooks
- **THEN** they can find documented maintenance procedures and understand their scope and limitations
