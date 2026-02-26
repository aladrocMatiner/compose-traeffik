## ADDED Requirements

### Requirement: Wiki.js helper scripts are documented
The system SHALL document Wiki.js helper scripts in `scripts/README.md`, including their purpose, usage, required env vars, and rendered artifact paths.

#### Scenario: Operator looks up the Wiki.js bootstrap workflow
- **WHEN** an operator reads `scripts/README.md`
- **THEN** they can find the Wiki.js helper script(s), the related Make targets, and the rendered output locations
