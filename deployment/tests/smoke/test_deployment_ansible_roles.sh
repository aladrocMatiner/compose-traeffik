#!/bin/bash
# File: deployment/tests/smoke/test_deployment_ansible_roles.sh
#
# Smoke test: Validate deployment Ansible roles syntax/lint and OS coverage wiring.
#
# Usage: ./deployment/tests/smoke/test_deployment_ansible_roles.sh
#
# Returns 0 on success, 1 on failure.
#

set -euo pipefail

SCRIPT_DIR=$(dirname "$0")
# shellcheck source=scripts/common.sh
. "$SCRIPT_DIR/../../../scripts/common.sh"

ANSIBLE_DIR="$SCRIPT_DIR/../../ansible"
SYSTEM_UPDATE_TASKS="$ANSIBLE_DIR/roles/system_update/tasks/main.yml"
SYSTEM_UPDATE_DEFAULTS="$ANSIBLE_DIR/roles/system_update/defaults/main.yml"
DOCKER_GIT_DEFAULTS="$ANSIBLE_DIR/roles/docker_git/defaults/main.yml"
SYSTEM_UPDATE_PLAYBOOK="$ANSIBLE_DIR/playbooks/system_update.yml"
DOCKER_GIT_PLAYBOOK="$ANSIBLE_DIR/playbooks/docker_git.yml"
SYSTEM_BOOTSTRAP_PLAYBOOK="$ANSIBLE_DIR/playbooks/system_bootstrap.yml"
PROJECT_DEPLOY_PLAYBOOK="$ANSIBLE_DIR/playbooks/project_deploy.yml"
PROJECT_DEPLOY_ROLE_DIR="$ANSIBLE_DIR/roles/project_deploy"
LOCAL_INVENTORY="$ANSIBLE_DIR/inventory/localhost.ini"

check_command "ansible-playbook"
check_command "ansible-lint"
check_command "grep"

for path in \
    "$SYSTEM_UPDATE_TASKS" \
    "$SYSTEM_UPDATE_DEFAULTS" \
    "$DOCKER_GIT_DEFAULTS" \
    "$SYSTEM_UPDATE_PLAYBOOK" \
    "$DOCKER_GIT_PLAYBOOK" \
    "$SYSTEM_BOOTSTRAP_PLAYBOOK" \
    "$PROJECT_DEPLOY_PLAYBOOK" \
    "$PROJECT_DEPLOY_ROLE_DIR/tasks/main.yml" \
    "$PROJECT_DEPLOY_ROLE_DIR/defaults/main.yml" \
    "$LOCAL_INVENTORY"; do
    if [ ! -f "$path" ]; then
        log_error "Required Ansible artifact not found: ${path}"
    fi
done

# Validate syntax for both playbooks.
ANSIBLE_CONFIG="$ANSIBLE_DIR/ansible.cfg" \
ansible-playbook -i "$LOCAL_INVENTORY" "$SYSTEM_UPDATE_PLAYBOOK" --syntax-check >/dev/null

ANSIBLE_CONFIG="$ANSIBLE_DIR/ansible.cfg" \
ansible-playbook -i "$LOCAL_INVENTORY" "$DOCKER_GIT_PLAYBOOK" --syntax-check >/dev/null

ANSIBLE_CONFIG="$ANSIBLE_DIR/ansible.cfg" \
ansible-playbook -i "$LOCAL_INVENTORY" "$SYSTEM_BOOTSTRAP_PLAYBOOK" --syntax-check >/dev/null

ANSIBLE_CONFIG="$ANSIBLE_DIR/ansible.cfg" \
ansible-playbook -i "$LOCAL_INVENTORY" "$PROJECT_DEPLOY_PLAYBOOK" --syntax-check >/dev/null

# Validate lint for both roles and playbooks.
ANSIBLE_CONFIG="$ANSIBLE_DIR/ansible.cfg" \
ansible-lint -p \
    "$SYSTEM_UPDATE_PLAYBOOK" \
    "$DOCKER_GIT_PLAYBOOK" \
    "$SYSTEM_BOOTSTRAP_PLAYBOOK" \
    "$PROJECT_DEPLOY_PLAYBOOK" \
    "$ANSIBLE_DIR/roles/system_update" \
    "$ANSIBLE_DIR/roles/docker_git" \
    "$PROJECT_DEPLOY_ROLE_DIR" >/dev/null

# Validate selector coverage in role defaults.
for selector in ubuntu debian12 debian13 debian gentoo opensuse-leap almalinux9 rockylinux9 fedora-cloud; do
    if ! grep -Eq "^[[:space:]]*-[[:space:]]*${selector}$" "$SYSTEM_UPDATE_DEFAULTS"; then
        log_error "system_update defaults missing selector: ${selector}"
    fi
    if ! grep -Eq "^[[:space:]]*${selector}:[[:space:]]*$" "$DOCKER_GIT_DEFAULTS"; then
        log_error "docker_git package mapping missing selector: ${selector}"
    fi
done

# Validate update flow includes all package manager families.
for os_family in Debian RedHat Suse Gentoo; do
    if ! grep -q "ansible_os_family == \"${os_family}\"" "$SYSTEM_UPDATE_TASKS"; then
        log_error "system_update task flow missing os family branch: ${os_family}"
    fi
done

# Validate composed bootstrap order.
if ! grep -Eq "^[[:space:]]*-[[:space:]]*role:[[:space:]]*system_update$" "$SYSTEM_BOOTSTRAP_PLAYBOOK"; then
    log_error "system_bootstrap playbook missing system_update role."
fi
if ! grep -Eq "^[[:space:]]*-[[:space:]]*role:[[:space:]]*docker_git$" "$SYSTEM_BOOTSTRAP_PLAYBOOK"; then
    log_error "system_bootstrap playbook missing docker_git role."
fi

system_update_line="$(grep -n -E "^[[:space:]]*-[[:space:]]*role:[[:space:]]*system_update$" "$SYSTEM_BOOTSTRAP_PLAYBOOK" | head -n1 | cut -d: -f1)"
docker_git_line="$(grep -n -E "^[[:space:]]*-[[:space:]]*role:[[:space:]]*docker_git$" "$SYSTEM_BOOTSTRAP_PLAYBOOK" | head -n1 | cut -d: -f1)"
if [ "$system_update_line" -ge "$docker_git_line" ]; then
    log_error "system_bootstrap role order must be system_update then docker_git."
fi

log_success "Deployment Ansible roles smoke test passed."
