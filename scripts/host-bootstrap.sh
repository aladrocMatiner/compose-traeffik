#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

usage() {
  cat <<'EOF'
Usage:
  scripts/host-bootstrap.sh [--host IP] [--user USER] [--port PORT] [--identity PATH]
                           [--target libvirt] [--os <ubuntu|debian|gentoo>]
                           [--init <openrc|systemd>] [--terraform-dir DIR]

Defaults:
  - Resolves host/user from Terraform outputs in infra/terraform/targets/libvirt
  - Uses current SSH agent / default SSH keys unless --identity is provided

This script installs Docker Engine and Docker Compose plugin on a provisioned host.
Current implementation supports Ubuntu only.
EOF
}

log() {
  printf 'INFO: %s\n' "$*"
}

warn() {
  printf 'WARN: %s\n' "$*" >&2
}

die() {
  printf 'ERROR: %s\n' "$*" >&2
  exit 1
}

check_cmd() {
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
    die "Docker bootstrap is not implemented for --os gentoo --init ${INIT_SYSTEM} in v1 (current implementation: ubuntu only)"
  fi
  die "Docker bootstrap is not implemented for --os ${OS_FAMILY} in v1 (current implementation: ubuntu only)"
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
  -o StrictHostKeyChecking=accept-new
)
if [[ -n "${IDENTITY_PATH}" ]]; then
  [[ -f "${IDENTITY_PATH}" ]] || die "SSH identity file not found: ${IDENTITY_PATH}"
  SSH_OPTS+=(-i "${IDENTITY_PATH}")
fi

log "Bootstrapping Docker on ${ssh_user}@${host_ip}:${SSH_PORT}"

ssh "${SSH_OPTS[@]}" -p "${SSH_PORT}" "${ssh_user}@${host_ip}" "bash -s -- $(printf '%q' "${ssh_user}")" <<'REMOTE'
set -euo pipefail

target_user="${1:?missing-target-user}"
export DEBIAN_FRONTEND=noninteractive

log() {
  printf '[remote] %s\n' "$*"
}

run_root() {
  if command -v sudo >/dev/null 2>&1; then
    sudo "$@"
  elif [ "$(id -u)" -eq 0 ]; then
    "$@"
  else
    echo "[remote] ERROR: sudo is required for non-root bootstrap" >&2
    exit 1
  fi
}

arch="$(dpkg --print-architecture)"
. /etc/os-release
if [ "${ID:-}" != "ubuntu" ]; then
  echo "[remote] ERROR: unsupported distro '${ID:-unknown}', expected ubuntu" >&2
  exit 1
fi

log "Installing prerequisite packages"
run_root apt-get update -y
run_root apt-get install -y ca-certificates curl gnupg

log "Configuring Docker apt repository"
run_root install -m 0755 -d /etc/apt/keyrings
if [ ! -f /etc/apt/keyrings/docker.asc ]; then
  run_root curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
  run_root chmod a+r /etc/apt/keyrings/docker.asc
fi

repo_line="deb [arch=${arch} signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu ${VERSION_CODENAME} stable"
if [ ! -f /etc/apt/sources.list.d/docker.list ] || ! grep -Fxq "${repo_line}" /etc/apt/sources.list.d/docker.list; then
  printf '%s\n' "${repo_line}" | run_root tee /etc/apt/sources.list.d/docker.list >/dev/null
fi

log "Installing Docker Engine + Compose plugin"
run_root apt-get update -y
run_root apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
run_root systemctl enable --now docker

if ! getent group docker >/dev/null 2>&1; then
  run_root groupadd docker
fi

if id "${target_user}" >/dev/null 2>&1; then
  if id -nG "${target_user}" | tr ' ' '\n' | grep -qx docker; then
    log "User '${target_user}' already in docker group"
  else
    run_root usermod -aG docker "${target_user}"
    log "Added '${target_user}' to docker group (new SSH session needed to apply group membership)"
  fi
else
  echo "[remote] WARN: target user '${target_user}' not found; skipped docker group membership" >&2
fi

log "Verifying Docker service and CLI"
run_root systemctl is-active --quiet docker
docker --version
docker compose version
run_root docker info >/dev/null

log "Docker bootstrap complete"
REMOTE

log "Bootstrap completed on ${ssh_user}@${host_ip}. If group membership changed, reconnect before running docker commands without sudo."
