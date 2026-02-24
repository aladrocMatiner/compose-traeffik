## MODIFIED Requirements
### Requirement: Compose profiles handling
The system SHALL translate `COMPOSE_PROFILES` into valid `docker compose --profile <name>` flags and ignore empty entries.

#### Scenario: Single profile
- **WHEN** `COMPOSE_PROFILES=stepca` is set
- **THEN** the command uses `--profile stepca` exactly once

#### Scenario: Multiple profiles with commas
- **WHEN** `COMPOSE_PROFILES=le,stepca` is set
- **THEN** the command uses `--profile le --profile stepca`

#### Scenario: Empty or trailing commas
- **WHEN** `COMPOSE_PROFILES=,stepca,` is set
- **THEN** empty entries are ignored and only `--profile stepca` is used
