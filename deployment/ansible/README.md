# Deployment Ansible Roles

This directory contains baseline multi-OS Ansible roles for deployment hosts.

## Included roles

- `system_update`: refresh package metadata and apply system updates.
- `docker_git`: install Docker and Git and ensure Docker service state.

Supported selectors:

- `ubuntu`
- `debian12`
- `debian13`
- `debian` (generic Debian fallback)
- `gentoo`
- `opensuse-leap`
- `almalinux9`
- `rockylinux9`
- `fedora-cloud`

## Quick usage

From repository root:

```bash
make deployment-ansible-syntax
make deployment-ansible-lint
```

Manual syntax checks:

```bash
ansible-playbook -i deployment/ansible/inventory/localhost.ini deployment/ansible/playbooks/system_update.yml --syntax-check
ansible-playbook -i deployment/ansible/inventory/localhost.ini deployment/ansible/playbooks/docker_git.yml --syntax-check
```

Example execution:

```bash
ansible-playbook -i deployment/ansible/inventory/localhost.ini deployment/ansible/playbooks/system_update.yml --limit local
ansible-playbook -i deployment/ansible/inventory/localhost.ini deployment/ansible/playbooks/docker_git.yml --limit local
```

## Role variables

`system_update` defaults:

- `system_update_apply_upgrades` (default: `true`)
- `system_update_apt_upgrade_mode` (default: `dist`)
- `system_update_apt_cache_valid_time` (default: `3600`)

`docker_git` defaults:

- `docker_git_manage_service` (default: `true`)
- `docker_git_enable_service` (default: `true`)
- `docker_git_start_service` (default: `true`)
- `docker_git_apt_cache_valid_time` (default: `3600`)

## Notes

- `docker_git` uses distro package names from `docker_git_packages_by_selector`.
- For environments where Docker package naming differs, override `docker_git_packages_by_selector` at playbook or inventory level.
- `system_update` handles Gentoo updates through `emerge` commands and skips those commands in `check_mode`.
