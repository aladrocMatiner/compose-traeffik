# Deployment Scripts

This directory contains scripts used by the `make deployment-*` workflow.

- `infra-provision.sh`
- `infra-validate.sh`
- `deployment-access.sh`
- `deployment-project.sh`
- `host-wait-ssh.sh`
- `host-bootstrap.sh`
- `host-bootstrap-check.sh`

`Makefile` resolves them through `DEPLOYMENT_SCRIPTS_DIR`.

Project orchestration entrypoints:

- `make deployment-project-list` -> `deployment-project.sh list`
- `make deployment-project project=<id> [target=<qemu>] [os=<ubuntu>]`

Hostname contract for web projects:

- Default public host: `<project-id>.<BASE_DOMAIN>`
- Optional manifest override: `public_host`
