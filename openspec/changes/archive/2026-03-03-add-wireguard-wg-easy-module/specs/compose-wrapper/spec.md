## ADDED Requirements

### Requirement: WireGuard lifecycle targets use deterministic compose wrapper
The system SHALL execute WireGuard lifecycle Make targets through the shared compose wrapper so compose project name and project directory remain deterministic regardless of current working directory.

#### Scenario: Operator runs WireGuard target from alternate directory
- **WHEN** an operator executes `make wg-up` (or another `wg-*` lifecycle target) from any CWD using the project Makefile
- **THEN** the command uses the pinned compose project settings
- **AND** reuses the expected project networks and volumes

#### Scenario: Profile and service scope are explicit for WireGuard
- **WHEN** a WireGuard lifecycle target is executed
- **THEN** compose is invoked with profile `wg`
- **AND** the target is scoped to the `wg-easy` service rather than unrelated services

### Requirement: Compose layering parity includes WireGuard service fragment
The system SHALL include the WireGuard service compose fragment in both compose invocation paths used by the project (`scripts/compose.sh` and `Makefile` compose file list) so profile-specific and general commands operate on the same layered graph.

#### Scenario: Wrapper and Makefile lists stay aligned
- **WHEN** a contributor inspects the compose file list used by `scripts/compose.sh` and the `COMPOSE_FILES` list in `Makefile`
- **THEN** both lists include `services/wg-easy/compose.yml`
- **AND** general commands (such as `make ps`) and `wg-*` targets observe the same service graph
