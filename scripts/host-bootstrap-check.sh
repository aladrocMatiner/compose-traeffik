#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

usage() {
  cat <<'EOF'
Usage:
  scripts/host-bootstrap-check.sh [--host IP] [--user USER] [--port PORT] [--identity PATH]
                                 [--target libvirt] [--os <ubuntu|debian|gentoo>]
                                 [--init <openrc|systemd>] [--terraform-dir DIR]

Checks SSH reachability and Docker readiness on a provisioned host.
Current implementation supports Ubuntu Docker checks only.
EOF
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

validate_target_os_init() {
  TARGET="${TARGET,,}"
  OS_FAMILY="${OS_FAMILY,,}"
  if [[ -n "${INIT_SYSTEM}" ]]; then
    INIT_SYSTEM="${INIT_SYSTEM,,}"
  fi

  [[ "${TARGET}" == "libvirt" ]] || die "Unsupported --target '${TARGET}'. Supported values: libvirt"
  case "${OS_FAMILY}" in
    ubuntu|debian|gentoo) ;;
    *) die "Unsupported --os '${OS_FAMILY}'. Supported values: ubuntu, debian, gentoo" ;;
  esac

  if [[ "${OS_FAMILY}" == "gentoo" ]]; then
    if [[ -z "${INIT_SYSTEM}" ]]; then
      INIT_SYSTEM="openrc"
    fi
    case "${INIT_SYSTEM}" in
      openrc|systemd) ;;
      *) die "Unsupported --init '${INIT_SYSTEM}' for --os gentoo. Supported values: openrc, systemd" ;;
    esac
  elif [[ -n "${INIT_SYSTEM}" ]]; then
    die "--init is only valid with --os gentoo (got --os ${OS_FAMILY}, --init ${INIT_SYSTEM})"
  fi
}

resolve_from_terraform() {
  local tf_dir="$1"
  check_cmd terraform
  [[ -d "${tf_dir}" ]] || die "Terraform directory not found: ${tf_dir}"
  host_ip="$(terraform -chdir="${tf_dir}" output -raw host_ip 2>/dev/null || true)"
  ssh_user="$(terraform -chdir="${tf_dir}" output -raw ssh_user 2>/dev/null || true)"
  [[ -n "${host_ip}" ]] || die "Unable to read 'host_ip' from terraform outputs in ${tf_dir}"
  [[ -n "${ssh_user}" ]] || die "Unable to read 'ssh_user' from terraform outputs in ${tf_dir}"
}

HOST_IP="${DEPLOYMENT_HOST_IP:-}"
SSH_USER="${DEPLOYMENT_HOST_USER:-}"
SSH_PORT="${DEPLOYMENT_SSH_PORT:-22}"
IDENTITY_PATH="${DEPLOYMENT_SSH_PRIVATE_KEY_PATH:-}"
TARGET="${DEPLOYMENT_TARGET:-libvirt}"
OS_FAMILY="${DEPLOYMENT_OS:-ubuntu}"
INIT_SYSTEM="${DEPLOYMENT_INIT:-}"
TF_DIR="${REPO_ROOT}/infra/terraform/targets/libvirt"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --host)
      [[ $# -ge 2 ]] || die "--host requires a value"
      HOST_IP="$2"
      shift 2
      ;;
    --user)
      [[ $# -ge 2 ]] || die "--user requires a value"
      SSH_USER="$2"
      shift 2
      ;;
    --port)
      [[ $# -ge 2 ]] || die "--port requires a value"
      SSH_PORT="$2"
      shift 2
      ;;
    --identity)
      [[ $# -ge 2 ]] || die "--identity requires a value"
      IDENTITY_PATH="$2"
      shift 2
      ;;
    --target)
      [[ $# -ge 2 ]] || die "--target requires a value"
      TARGET="$2"
      shift 2
      ;;
    --os)
      [[ $# -ge 2 ]] || die "--os requires a value"
      OS_FAMILY="$2"
      shift 2
      ;;
    --init)
      [[ $# -ge 2 ]] || die "--init requires a value"
      INIT_SYSTEM="$2"
      shift 2
      ;;
    --terraform-dir)
      [[ $# -ge 2 ]] || die "--terraform-dir requires a value"
      TF_DIR="$2"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      die "Unknown argument: $1"
      ;;
  esac
done

validate_target_os_init
if [[ "${OS_FAMILY}" != "ubuntu" ]]; then
  if [[ "${OS_FAMILY}" == "gentoo" ]]; then
    die "Docker readiness checks are not implemented for --os gentoo --init ${INIT_SYSTEM} in v1 (current implementation: ubuntu only)"
  fi
  die "Docker readiness checks are not implemented for --os ${OS_FAMILY} in v1 (current implementation: ubuntu only)"
fi

check_cmd ssh

if [[ -z "${HOST_IP}" || -z "${SSH_USER}" ]]; then
  resolve_from_terraform "${TF_DIR}"
else
  host_ip="${HOST_IP}"
  ssh_user="${SSH_USER}"
fi

SSH_OPTS=(
  -o BatchMode=yes
  -o ConnectTimeout=10
  -o StrictHostKeyChecking=no
  -o UserKnownHostsFile=/dev/null
)
if [[ -n "${IDENTITY_PATH}" ]]; then
  [[ -f "${IDENTITY_PATH}" ]] || die "SSH identity file not found: ${IDENTITY_PATH}"
  SSH_OPTS+=(-i "${IDENTITY_PATH}")
fi

log "Checking host readiness on ${ssh_user}@${host_ip}:${SSH_PORT}"

ssh "${SSH_OPTS[@]}" -p "${SSH_PORT}" "${ssh_user}@${host_ip}" 'bash -s' <<'REMOTE'
set -euo pipefail

run_root() {
  if command -v sudo >/dev/null 2>&1; then
    sudo "$@"
  elif [ "$(id -u)" -eq 0 ]; then
    "$@"
  else
    echo "[remote] ERROR: sudo is required for non-root checks" >&2
    exit 1
  fi
}

echo "[remote] SSH OK: $(whoami)@$(hostname -f 2>/dev/null || hostname)"
python3 --version
docker --version
docker compose version
run_root systemctl is-active --quiet docker
echo "[remote] Docker service active"
REMOTE

log "Host is ready for Ansible/bootstrap follow-up"
