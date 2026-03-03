## MODIFIED Requirements

### Requirement: Scripts documentation
The system SHALL document all operational scripts in `scripts/README.md`, including purpose, usage, required env vars, and side effects. Documentation updates for new optional modules SHALL describe any new preflight validations, relevant environment variables, and recommended Make-based workflows.

#### Scenario: Script inventory
- **WHEN** a user opens `scripts/README.md`
- **THEN** they can find every script listed with its purpose and how to run it

#### Scenario: Optional module preflight is documented
- **WHEN** a new optional module introduces additional preflight validation (for example WireGuard `WG_*` guardrails)
- **THEN** `scripts/README.md` describes the relevant variables and validation behavior for operators
- **AND** it points users to the preferred Make targets/workflows for that module

### Requirement: README link to scripts
The system SHALL link to `scripts/README.md` from the root README in a visible location.

#### Scenario: Discoverability
- **WHEN** a user reads the root README
- **THEN** they can navigate to the scripts documentation

