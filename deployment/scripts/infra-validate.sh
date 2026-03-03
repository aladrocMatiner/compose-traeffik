#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"

log() {
  printf 'INFO: %s\n' "$*"
}

die() {
  printf 'ERROR: %s\n' "$*" >&2
  exit 1
}

check_cmd() {
  if [[ "$1" == "terraform" ]] && ! command -v terraform >/dev/null 2>&1; then
    local tf_local="${REPO_ROOT}/.tools/bin/terraform"
    if [[ -x "${tf_local}" ]]; then
      PATH="${REPO_ROOT}/.tools/bin:${PATH}"
    fi
  fi
  command -v "$1" >/dev/null 2>&1 || die "Missing required command: $1"
}

run_target_validate() {
  local target="$1"
  local dir="${REPO_ROOT}/infra/terraform/targets/${target}"
  [[ -d "${dir}" ]] || die "Missing terraform target directory: ${dir}"

  log "terraform fmt -check (target=${target})"
  terraform -chdir="${dir}" fmt -recursive -check

  log "terraform init (target=${target})"
  terraform -chdir="${dir}" init -upgrade=false -backend=false >/dev/null

  log "terraform validate (target=${target})"
  terraform -chdir="${dir}" validate >/dev/null
}

main() {
  check_cmd terraform
  run_target_validate "libvirt"
  run_target_validate "proxmox"
  log "Terraform validation completed for libvirt and proxmox targets"
}

main "$@"
