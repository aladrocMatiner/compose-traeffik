## ADDED Requirements

### Requirement: BIND lifecycle commands are discoverable in docs
The documentation SHALL present `bind-up`, `bind-down`, `bind-logs`, `bind-status`, and `bind-restart` as the canonical operational commands for DNS service management in the `dns-bind` branch.

#### Scenario: Contributor follows BIND quick operations
- **WHEN** a contributor reads the DNS/BIND operation docs
- **THEN** they find the full lifecycle command set with short purpose descriptions
- **AND** the commands match the Makefile targets

#### Scenario: Restart flow is explicit
- **WHEN** a contributor needs to restart BIND after configuration updates
- **THEN** docs provide `make bind-restart` as the direct command
- **AND** expected behavior is consistent with stop/start lifecycle semantics

