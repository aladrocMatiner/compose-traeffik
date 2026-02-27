#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
CATALOG_PATH="${REPO_ROOT}/deployment/projects/catalog.json"

usage() {
  cat <<'USAGE'
Usage:
  deployment/scripts/deployment-project.sh list
  deployment/scripts/deployment-project.sh run --project <id> [--target <libvirt|qemu|proxmox>] [--os <selector>] [--init <openrc|systemd>]

Notes:
  - run uses ordered stages: provision -> wait -> system_bootstrap -> project deploy.
  - Defaults are target=qemu and os=ubuntu when used from make deployment-project.
  - Project manifests define profile/services and block ad-hoc service override.
USAGE
}

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

normalize_target() {
  local input="${1,,}"
  case "${input}" in
    qemu)
      printf 'libvirt\n'
      ;;
    libvirt|proxmox)
      printf '%s\n' "${input}"
      ;;
    *)
      die "Unsupported target '${1}'. Supported values: libvirt, qemu, proxmox"
      ;;
  esac
}

validate_catalog() {
  check_cmd jq
  [[ -f "${CATALOG_PATH}" ]] || die "Project catalog not found: ${CATALOG_PATH}"
  jq -e '
    has("projects") and
    (.projects | type == "array") and
    all(.projects[];
      (.id | type == "string" and length > 0) and
      (.manifest | type == "string" and length > 0)
    )
  ' "${CATALOG_PATH}" >/dev/null || die "Invalid project catalog schema: ${CATALOG_PATH}"
}

validate_manifest() {
  local manifest_path="$1"
  jq -e '
    (.id | type == "string" and length > 0) and
    (.description | type == "string" and length > 0) and
    (.repo_url | type == "string" and length > 0) and
    (.repo_ref | type == "string" and length > 0) and
    (.compose_profile | type == "string" and length > 0) and
    (.services | type == "array" and length > 0 and all(.[]; type == "string" and length > 0)) and
    (.deploy_playbook | type == "string" and length > 0) and
    (.required_env | type == "array" and all(.[]; type == "string" and length > 0)) and
    (.tls_mode | type == "string" and length > 0) and
    ((has("public_host") | not) or (.public_host | type == "string" and length > 0)) and
    ((has("depends_on_projects") | not) or (.depends_on_projects | type == "array" and all(.[]; type == "string" and length > 0)))
  ' "${manifest_path}" >/dev/null || die "Invalid project manifest schema: ${manifest_path}"
}

terraform_dir_for_target() {
  local t="$1"
  case "${t}" in
    libvirt) printf '%s\n' "${REPO_ROOT}/infra/terraform/targets/libvirt" ;;
    proxmox) printf '%s\n' "${REPO_ROOT}/infra/terraform/targets/proxmox" ;;
    *) die "Unsupported target for terraform resolution: ${t}" ;;
  esac
}

resolve_host_tuple() {
  local tf_dir="$1"
  check_cmd terraform
  [[ -d "${tf_dir}" ]] || die "Terraform directory not found: ${tf_dir}"
  host_ip="$(terraform -chdir="${tf_dir}" output -raw host_ip 2>/dev/null || true)"
  ssh_user="$(terraform -chdir="${tf_dir}" output -raw ssh_user 2>/dev/null || true)"
  [[ -n "${host_ip}" ]] || die "Unable to read 'host_ip' from terraform outputs in ${tf_dir}"
  [[ -n "${ssh_user}" ]] || die "Unable to read 'ssh_user' from terraform outputs in ${tf_dir}"
}

run_stage() {
  local stage="$1"
  shift
  if "$@"; then
    return 0
  fi

  printf 'ERROR: stage failed: %s\n' "${stage}" >&2
  printf 'INFO: Recovery guidance:\n' >&2
  printf 'INFO:   - Inspect VM logs and rerun: make deployment-project project=%s target=%s os=%s\n' "${PROJECT_ID}" "${TARGET_INPUT}" "${OS_SELECTOR}" >&2
  printf 'INFO:   - Destroy manually if needed: make deployment-destroy target=%s os=%s\n' "${TARGET_INPUT}" "${OS_SELECTOR}" >&2
  exit 1
}

run_ansible_playbook() {
  local playbook_path="$1"
  shift
  check_cmd ansible-playbook

  local ssh_opts
  ssh_opts="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null"

  local cmd=(
    ansible-playbook
    -i "${host_ip},"
    -u "${ssh_user}"
    --ssh-common-args "${ssh_opts}"
    "${playbook_path}"
  )

  if [[ -n "${IDENTITY_PATH}" ]]; then
    [[ -f "${IDENTITY_PATH}" ]] || die "SSH identity file not found: ${IDENTITY_PATH}"
    cmd+=(--private-key "${IDENTITY_PATH}")
  fi

  if [[ "$#" -gt 0 ]]; then
    cmd+=("$@")
  fi

  ANSIBLE_CONFIG="${REPO_ROOT}/deployment/ansible/ansible.cfg" "${cmd[@]}"
}

check_dependencies_remote() {
  local -a deps=("$@")
  local missing=()

  if [[ "${#deps[@]}" -eq 0 ]]; then
    return 0
  fi

  check_cmd ssh

  local ssh_opts=(
    -o BatchMode=yes
    -o ConnectTimeout=8
    -o StrictHostKeyChecking=no
    -o UserKnownHostsFile=/dev/null
  )
  if [[ -n "${IDENTITY_PATH}" ]]; then
    ssh_opts+=(-i "${IDENTITY_PATH}")
  fi

  local dep
  for dep in "${deps[@]}"; do
    if ! ssh "${ssh_opts[@]}" -p "${SSH_PORT}" "${ssh_user}@${host_ip}" \
      "test -f ~/.compose-traeffik/deployment-project-state.json && grep -Fq '\"${dep}\"' ~/.compose-traeffik/deployment-project-state.json"; then
      missing+=("${dep}")
    fi
  done

  if [[ "${#missing[@]}" -gt 0 ]]; then
    die "Missing required project dependencies: ${missing[*]}. Recovery: deploy dependencies first (make deployment-project project=<dependency>) and retry project=${PROJECT_ID}."
  fi
}

list_projects() {
  validate_catalog
  jq -r '.projects[].id' "${CATALOG_PATH}"
}

run_project() {
  validate_catalog

  [[ -n "${PROJECT_ID}" ]] || die "Missing required selector: --project <id>"

  local manifest_rel
  manifest_rel="$(jq -r --arg id "${PROJECT_ID}" '.projects[] | select(.id == $id) | .manifest' "${CATALOG_PATH}" | head -n1)"
  if [[ -z "${manifest_rel}" || "${manifest_rel}" == "null" ]]; then
    local supported
    supported="$(jq -r '.projects[].id' "${CATALOG_PATH}" | xargs)"
    die "Unsupported project '${PROJECT_ID}'. Supported: ${supported}"
  fi

  local manifest_path="${REPO_ROOT}/${manifest_rel}"
  [[ -f "${manifest_path}" ]] || die "Project manifest file not found: ${manifest_path}"

  validate_manifest "${manifest_path}"

  local manifest_id
  manifest_id="$(jq -r '.id' "${manifest_path}")"
  [[ "${manifest_id}" == "${PROJECT_ID}" ]] || die "Manifest id mismatch. expected=${PROJECT_ID} got=${manifest_id}"

  local manifest_repo_url manifest_repo_ref manifest_profile manifest_services manifest_tls_mode
  manifest_repo_url="$(jq -r '.repo_url' "${manifest_path}")"
  manifest_repo_ref="$(jq -r '.repo_ref' "${manifest_path}")"
  manifest_profile="$(jq -r '.compose_profile' "${manifest_path}")"
  manifest_services="$(jq -r '.services | join(",")' "${manifest_path}")"
  manifest_tls_mode="$(jq -r '.tls_mode' "${manifest_path}")"

  log "Selected project=${PROJECT_ID} target=${TARGET_INPUT} os=${OS_SELECTOR}"
  log "Manifest source=${manifest_path}"
  log "Repo=${manifest_repo_url} ref=${manifest_repo_ref} profile=${manifest_profile} services=${manifest_services} tls_mode=${manifest_tls_mode}"

  local target_normalized
  target_normalized="$(normalize_target "${TARGET_INPUT}")"
  local tf_dir
  tf_dir="$(terraform_dir_for_target "${target_normalized}")"

  local deployment_vm_name
  deployment_vm_name="${PROJECT_ID}-${OS_SELECTOR}"
  if [[ -n "${INIT_ARG}" ]]; then
    deployment_vm_name="${deployment_vm_name}-${INIT_ARG}"
  fi

  local -a provision_cmd=("${REPO_ROOT}/deployment/scripts/infra-provision.sh" apply --target "${TARGET_INPUT}" --os "${OS_SELECTOR}")
  local -a wait_cmd=("${REPO_ROOT}/deployment/scripts/host-wait-ssh.sh" --target "${TARGET_INPUT}" --os "${OS_SELECTOR}")
  if [[ -n "${INIT_ARG}" ]]; then
    provision_cmd+=(--init "${INIT_ARG}")
    wait_cmd+=(--init "${INIT_ARG}")
  fi

  log "Resolved deployment VM name=${deployment_vm_name}"
  run_stage provision env \
    "DEPLOYMENT_VM_NAME=${deployment_vm_name}" \
    "DEPLOYMENT_HOSTNAME=${deployment_vm_name}" \
    "${provision_cmd[@]}"
  run_stage wait "${wait_cmd[@]}"

  resolve_host_tuple "${tf_dir}"
  log "Resolved host tuple: ${ssh_user}@${host_ip}:${SSH_PORT}"

  mapfile -t deps < <(jq -r '.depends_on_projects[]?' "${manifest_path}")
  if [[ "${#deps[@]}" -gt 0 ]]; then
    check_dependencies_remote "${deps[@]}"
  fi

  run_stage system_bootstrap run_ansible_playbook "${REPO_ROOT}/deployment/ansible/playbooks/system_bootstrap.yml"

  run_stage project_deploy run_ansible_playbook \
    "${REPO_ROOT}/deployment/ansible/playbooks/project_deploy.yml" \
    --extra-vars "deployment_project_manifest=${manifest_path}" \
    --extra-vars "deployment_project_target=${TARGET_INPUT}" \
    --extra-vars "deployment_project_os=${OS_SELECTOR}"

  log "Project deployment finished successfully for project=${PROJECT_ID}"
}

COMMAND=""
PROJECT_ID=""
TARGET_INPUT="qemu"
OS_SELECTOR="ubuntu"
INIT_ARG=""
IDENTITY_PATH="${DEPLOYMENT_SSH_PRIVATE_KEY_PATH:-}"
SSH_PORT="${DEPLOYMENT_SSH_PORT:-22}"

if [[ "$#" -eq 0 ]]; then
  usage
  exit 1
fi

COMMAND="$1"
shift

while [[ $# -gt 0 ]]; do
  case "$1" in
    --project)
      [[ $# -ge 2 ]] || die "--project requires a value"
      PROJECT_ID="$2"
      shift 2
      ;;
    --target)
      [[ $# -ge 2 ]] || die "--target requires a value"
      TARGET_INPUT="$2"
      shift 2
      ;;
    --os)
      [[ $# -ge 2 ]] || die "--os requires a value"
      OS_SELECTOR="$2"
      shift 2
      ;;
    --init)
      [[ $# -ge 2 ]] || die "--init requires a value"
      INIT_ARG="$2"
      shift 2
      ;;
    --help|-h)
      usage
      exit 0
      ;;
    *)
      die "Unknown argument: $1"
      ;;
  esac
done

case "${COMMAND}" in
  list)
    list_projects
    ;;
  run)
    run_project
    ;;
  *)
    die "Unknown command '${COMMAND}'. Supported commands: list, run"
    ;;
esac
