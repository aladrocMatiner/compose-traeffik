# scripts-docs Specification

## Purpose
TBD - created by archiving change add-scripts-docs. Update Purpose after archive.
## Requirements
### Requirement: Scripts documentation
The system SHALL document all operational scripts in `scripts/README.md`, including purpose, usage, required env vars, and side effects. New service bootstrap/render scripts (such as GitLab Omnibus config rendering) SHALL be included.

#### Scenario: Script inventory
- **WHEN** a user opens `scripts/README.md`
- **THEN** they can find every script listed with its purpose and how to run it

#### Scenario: GitLab scripts documented
- **WHEN** GitLab scripts are added
- **THEN** `scripts/README.md` includes `gitlab-bootstrap` and any GitLab config render helper scripts with required env vars and generated files

### Requirement: README link to scripts
The system SHALL link to `scripts/README.md` from the root README in a visible location.

#### Scenario: Discoverability
- **WHEN** a user reads the root README
- **THEN** they can navigate to the scripts documentation

### Requirement: Rocket.Chat helper scripts are documented
The system SHALL document Rocket.Chat bootstrap/render helper scripts in `scripts/README.md` with purpose, usage, and side effects.

#### Scenario: Operator looks up Rocket.Chat bootstrap script
- **WHEN** an operator reads `scripts/README.md`
- **THEN** they can find the Rocket.Chat helper script(s), the corresponding Make target(s), and the rendered artifact paths

### Requirement: Semaphore UI script documentation
The system SHALL document Semaphore UI operational scripts (including bootstrap) in `scripts/README.md`.

#### Scenario: Semaphore UI script discoverability
- **WHEN** a user reads `scripts/README.md`
- **THEN** they can find the Semaphore UI scripts, required inputs, and common usage flows

