## 1. Implementation
- [x] 1.1 Add StepCA-dependent project discovery and post-`traefik-stepca` auto-reconcile flow to `deployment/scripts/deployment-project.sh`.
- [x] 1.2 Restrict auto-reconcile to deployed running projects in local libvirt/qemu context and exclude `traefik-docling`.
- [x] 1.3 Add env toggles for StepCA auto-reconcile behavior.
- [x] 1.4 Update deployment scripts README.
- [x] 1.5 Extend workflow-contract smoke assertions for new StepCA auto-reconcile markers.

## 2. Validation
- [x] 2.1 Run `openspec validate add-stepca-dependent-cert-reconcile --strict`.
- [x] 2.2 Run shell syntax check for `deployment/scripts/deployment-project.sh`.
