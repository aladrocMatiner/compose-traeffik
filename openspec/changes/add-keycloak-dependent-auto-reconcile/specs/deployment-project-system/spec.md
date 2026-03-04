## ADDED Requirements
### Requirement: Keycloak deployment SHALL auto-reconcile deployed OIDC dependents
The system SHALL automatically reconcile already deployed OIDC-enabled dependent projects after a successful `project=traefik-keycloak` run.

#### Scenario: Reconcile only deployed Keycloak OIDC dependents
- **WHEN** `make deployment-project project=traefik-keycloak` completes successfully
- **THEN** the workflow discovers projects declaring `depends_on_projects` that include `traefik-keycloak`
- **AND** only projects with `oidc.enabled=true` and present in local deployment registry state are auto-reconciled
- **AND** projects not yet deployed are skipped with explicit logs

#### Scenario: Operator disables auto-reconcile
- **WHEN** `DEPLOYMENT_PROJECT_AUTO_RECONCILE_KEYCLOAK_DEPENDENTS=false` is set
- **THEN** no dependent auto-reconciliation runs after `traefik-keycloak` deployment
- **AND** the workflow logs that auto-reconciliation is disabled
