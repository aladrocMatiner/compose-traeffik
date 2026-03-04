# Change: Auto-Reconcile Keycloak OIDC Dependents After Keycloak Deploy

## Why
Operators currently need to manually re-run all OIDC-enabled projects after deploying `traefik-keycloak` to ensure client contracts are reconciled. This is repetitive and easy to forget.

## What Changes
- Add automatic dependent reconciliation in `deployment-project` after successful `project=traefik-keycloak` deployment.
- Limit reconciliation to projects that:
  - are declared as dependent on `traefik-keycloak`
  - declare `oidc.enabled=true`
  - already exist in local deployment registry state
- Add an environment toggle to disable auto-reconciliation when needed.
- Document the new behavior in deployment scripts README.

## Impact
- Affected specs: `deployment-project-system`
- Affected code:
  - `deployment/scripts/deployment-project.sh`
  - `deployment/scripts/README.md`
  - `deployment/tests/smoke/test_deployment_project_workflow_contract.sh`
