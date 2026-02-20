## ADDED Requirements

### Requirement: Make lifecycle interface for BIND operations
The system SHALL expose BIND lifecycle operations through Make targets `bind-up`, `bind-down`, `bind-logs`, `bind-status`, and `bind-restart`.

#### Scenario: Start BIND service
- **WHEN** an operator runs `make bind-up`
- **THEN** compose starts the BIND workload with profile `bind`
- **AND** the command targets the BIND service flow for this branch

#### Scenario: Restart BIND service quickly
- **WHEN** an operator runs `make bind-restart`
- **THEN** the command performs a stop/start cycle equivalent to the documented BIND lifecycle operations
- **AND** avoids requiring manual sequencing in daily operations

#### Scenario: Inspect BIND runtime
- **WHEN** an operator runs `make bind-status` or `make bind-logs`
- **THEN** the command outputs only BIND-relevant status/log information
- **AND** does not depend on legacy DNS service naming

