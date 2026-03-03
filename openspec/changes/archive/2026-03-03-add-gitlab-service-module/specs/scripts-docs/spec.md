## MODIFIED Requirements

### Requirement: Scripts documentation
The system SHALL document all operational scripts in `scripts/README.md`, including purpose, usage, required env vars, and side effects. New service bootstrap/render scripts (such as GitLab Omnibus config rendering) SHALL be included.

#### Scenario: Script inventory
- **WHEN** a user opens `scripts/README.md`
- **THEN** they can find every script listed with its purpose and how to run it

#### Scenario: GitLab scripts documented
- **WHEN** GitLab scripts are added
- **THEN** `scripts/README.md` includes `gitlab-bootstrap` and any GitLab config render helper scripts with required env vars and generated files
