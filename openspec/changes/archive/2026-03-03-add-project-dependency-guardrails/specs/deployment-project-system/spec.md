## ADDED Requirements

### Requirement: Project manifest supports inter-project dependencies
The system SHALL support an optional `depends_on_projects` field in project manifests, containing project ids required before deploying the selected project.

#### Scenario: Manifest declares dependencies
- **WHEN** a project manifest includes `depends_on_projects`
- **THEN** each entry is interpreted as a required project dependency
- **AND** non-list or malformed values are rejected as invalid manifest input

### Requirement: Deployment project workflow performs dependency preflight checks
The system SHALL validate declared project dependencies before running bootstrap and project deploy stages.

#### Scenario: Missing dependencies are detected
- **WHEN** `deployment-project` is executed for a project whose declared dependencies are not satisfied
- **THEN** the workflow fails before project deployment
- **AND** the error output lists missing dependency project ids
- **AND** the output includes explicit recovery guidance to deploy dependencies first

#### Scenario: Dependencies are satisfied
- **WHEN** all declared dependencies are satisfied
- **THEN** the workflow continues to baseline bootstrap and project deployment stages
- **AND** no dependency error is emitted

#### Scenario: Security dependencies gate Traefik-published app deployment
- **WHEN** a project published behind Traefik declares security dependencies (for example StepCA and Keycloak)
- **THEN** dependency preflight must pass before app deployment is allowed
- **AND** deployment is blocked if those declared security dependencies are not satisfied
