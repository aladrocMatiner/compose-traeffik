## ADDED Requirements
### Requirement: StepCA deployment SHALL auto-reconcile running StepCA-dependent Traefik projects
The system SHALL automatically reconcile running, already deployed StepCA-dependent Traefik projects after a successful `project=traefik-stepca` deployment.

#### Scenario: Reconcile only running deployed StepCA dependents
- **WHEN** `make deployment-project project=traefik-stepca` completes successfully
- **THEN** the workflow discovers projects that depend on `traefik-stepca`, declare `tls_mode=stepca-acme`, and include `traefik` service
- **AND** only projects already present in local deployment registry state are considered
- **AND** in local libvirt/qemu context, only running VMs are auto-reconciled
- **AND** non-running or undeployed projects are skipped with explicit logs

#### Scenario: Demo excludes docling from StepCA auto-reconcile
- **WHEN** StepCA dependent auto-reconcile runs in demo mode defaults
- **THEN** project `traefik-docling` is excluded from automatic reconciliation

#### Scenario: Operator disables StepCA dependent auto-reconcile
- **WHEN** `DEPLOYMENT_PROJECT_AUTO_RECONCILE_STEPCA_DEPENDENTS=false` is set
- **THEN** no StepCA dependent auto-reconciliation runs after `traefik-stepca` deployment
- **AND** the workflow logs that StepCA dependent auto-reconciliation is disabled
