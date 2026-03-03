## ADDED Requirements

### Requirement: BIND lifecycle targets use deterministic compose wrapper
The system SHALL execute BIND lifecycle Make targets through the shared compose wrapper so project name and project directory remain deterministic regardless of current working directory.

#### Scenario: Operator runs command from alternate directory
- **WHEN** an operator executes `make bind-up` (or any BIND lifecycle target) from any CWD using the project Makefile
- **THEN** the command uses the pinned compose project settings
- **AND** reuses the expected project networks and volumes

#### Scenario: Profile and service scope are explicit
- **WHEN** a BIND lifecycle target is executed
- **THEN** compose is invoked with profile `bind`
- **AND** the target is scoped to BIND operations rather than unrelated services

