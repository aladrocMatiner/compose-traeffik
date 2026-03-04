# Change: Auto-Reconcile Running StepCA Dependents After StepCA Deploy

## Why
After deploying `traefik-stepca`, operators currently need to manually re-run each running StepCA-dependent Traefik project to ensure host aliases, StepCA trust material, and certificate issuance are converged.

## What Changes
- Add automatic dependent reconciliation in `deployment-project` after successful `project=traefik-stepca` deployment.
- Limit reconciliation to projects that:
  - declare dependency on `traefik-stepca`
  - declare `tls_mode=stepca-acme`
  - expose Traefik service
  - are already deployed and currently running in local demo context (QEMU/libvirt)
- Exclude `traefik-docling` from this demo flow.
- Add environment toggles for enable/disable and running-only behavior.

## Impact
- Affected specs: `deployment-project-system`
- Affected code:
  - `deployment/scripts/deployment-project.sh`
  - `deployment/scripts/README.md`
  - `deployment/tests/smoke/test_deployment_project_workflow_contract.sh`
