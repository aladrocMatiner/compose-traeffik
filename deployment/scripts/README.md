# Deployment Scripts

This directory contains scripts used by the `make deployment-*` workflow.

- `infra-provision.sh`
- `infra-validate.sh`
- `deployment-access.sh`
- `host-wait-ssh.sh`
- `host-bootstrap.sh`
- `host-bootstrap-check.sh`

`Makefile` resolves them through `DEPLOYMENT_SCRIPTS_DIR`.
