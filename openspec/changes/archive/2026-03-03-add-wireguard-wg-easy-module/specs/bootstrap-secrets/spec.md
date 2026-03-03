## ADDED Requirements

### Requirement: WireGuard admin bootstrap secrets are persisted in .env
The system SHALL persist the WireGuard admin bootstrap values required by the chosen pinned `wg-easy` integration in `.env` and SHALL provide a dedicated workflow to populate them before first use.

#### Scenario: `make wg-bootstrap` populates missing WireGuard admin values
- **WHEN** `.env` exists and the documented WireGuard admin bootstrap `WG_*` variables are empty
- **AND** an operator runs `make wg-bootstrap`
- **THEN** the workflow generates secure values and writes them to `.env`
- **AND** the values are available for subsequent WireGuard onboarding runs

#### Scenario: WireGuard bootstrap is idempotent by default
- **WHEN** `.env` already contains the documented WireGuard admin bootstrap `WG_*` variables
- **AND** an operator reruns `make wg-bootstrap`
- **THEN** the workflow does not overwrite the existing values by default
- **AND** it reuses the persisted values unless an explicit rotation/force path is invoked

#### Scenario: Missing `.env` does not produce ambiguous secrets
- **WHEN** an operator runs `make wg-bootstrap` before `.env` is created
- **THEN** the workflow fails with a clear action (for example, run `make bootstrap` first) or follows a documented controlled path
- **AND** it does not silently create inconsistent bootstrap state

