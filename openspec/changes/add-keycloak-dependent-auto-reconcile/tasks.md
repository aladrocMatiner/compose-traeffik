## 1. Implementation
- [x] 1.1 Add Keycloak-dependent project discovery and auto-reconcile flow to `deployment/scripts/deployment-project.sh`.
- [x] 1.2 Gate auto-reconcile with environment toggles and keep it idempotent/safe for re-runs.
- [x] 1.3 Update deployment scripts documentation with the new behavior and disable toggle.
- [x] 1.4 Extend smoke workflow-contract coverage for auto-reconcile markers/order.

## 2. Validation
- [x] 2.1 Run `openspec validate add-keycloak-dependent-auto-reconcile --strict`.
- [x] 2.2 Run `deployment/tests/smoke/test_deployment_project_workflow_contract.sh` (currently fails on existing `traefik-docling` guardrail assertion unrelated to this change).
