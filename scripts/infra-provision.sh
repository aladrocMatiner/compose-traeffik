#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

usage() {
  cat <<'EOF'
Usage:
  scripts/infra-provision.sh <apply|plan|destroy|output|ssh> [--target libvirt]
                            [--os <ubuntu|debian|gentoo>] [--init <openrc|systemd>]

Environment overrides (selected):
  DEPLOYMENT_VM_NAME
  DEPLOYMENT_HOSTNAME
  DEPLOYMENT_VM_IP
  DEPLOYMENT_VM_CIDR_PREFIX
  DEPLOYMENT_VM_GATEWAY
  DEPLOYMENT_DNS_SERVERS
  DEPLOYMENT_SSH_USER
  DEPLOYMENT_SSH_PUBKEY_PATH
  DEPLOYMENT_INIT
  DEPLOYMENT_UBUNTU_IMAGE_URL
  DEPLOYMENT_UBUNTU_IMAGE_PATH
  DEPLOYMENT_GENTOO_SYSTEMD_IMAGE_URL
  DEPLOYMENT_GENTOO_SYSTEMD_IMAGE_PATH
  DEPLOYMENT_GENTOO_OPENRC_IMAGE_URL
  DEPLOYMENT_GENTOO_OPENRC_IMAGE_PATH
  DEPLOYMENT_GENTOO_OPENRC_AUTO_BUILD
  DEPLOYMENT_LIBVIRT_URI
  DEPLOYMENT_LIBVIRT_POOL
  DEPLOYMENT_LIBVIRT_POOL_PATH
  DEPLOYMENT_LIBVIRT_NETWORK
  DEPLOYMENT_LIBVIRT_FIRMWARE
  DEPLOYMENT_LIBVIRT_MACHINE
  DEPLOYMENT_LIBVIRT_ATTACH_CLOUDINIT_AS_SCSI
  DEPLOYMENT_LIBVIRT_REMOVE_IDE_CONTROLLER

Notes:
  - Interface supports --os ubuntu|debian|gentoo.
  - --init is only valid with --os gentoo and defaults to openrc.
  - Gentoo/openrc uses a project-built experimental qcow2 image (built on demand if missing).
  - The wrapper auto-detects a local SSH public key if DEPLOYMENT_SSH_PUBKEY_PATH is not set.
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

resolve_ssh_pubkey_path() {
  if [[ -n "${DEPLOYMENT_SSH_PUBKEY_PATH:-}" ]]; then
    printf '%s\n' "${DEPLOYMENT_SSH_PUBKEY_PATH}"
    return 0
  fi

  local candidates=(
    "${HOME}/.ssh/id_ed25519.pub"
    "${HOME}/.ssh/id_ecdsa.pub"
    "${HOME}/.ssh/id_rsa.pub"
  )
  local candidate
  for candidate in "${candidates[@]}"; do
    if [[ -f "${candidate}" ]]; then
      printf '%s\n' "${candidate}"
      return 0
    fi
  done

  local first_pub=""
  if first_pub="$(compgen -G "${HOME}/.ssh/*.pub" | head -n 1)"; then
    if [[ -n "${first_pub}" ]]; then
      printf '%s\n' "${first_pub}"
      return 0
    fi
  fi

  return 1
}

derive_mac_from_ip() {
  local ip="$1"
  local a b c d
  IFS='.' read -r a b c d <<<"${ip}"
  [[ -n "${a:-}" && -n "${b:-}" && -n "${c:-}" && -n "${d:-}" ]] || return 1
  printf '52:54:%02x:%02x:%02x:%02x\n' "${a}" "${b}" "${c}" "${d}"
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

resolve_base_image_config() {
  BASE_IMAGE_LABEL=""
  BASE_IMAGE_URL=""
  BASE_IMAGE_PATH=""

  case "${OS_FAMILY}" in
    ubuntu)
      BASE_IMAGE_LABEL="Ubuntu"
      BASE_IMAGE_URL="${DEPLOYMENT_UBUNTU_IMAGE_URL:-https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img}"
      BASE_IMAGE_PATH="${DEPLOYMENT_UBUNTU_IMAGE_PATH:-${REPO_ROOT}/infra/images/ubuntu/noble-server-cloudimg-amd64.img}"
      ;;
    debian)
      die "Debian provisioning is not implemented yet in v1 (interface is available, image profile pending)"
      ;;
    gentoo)
      if [[ "${INIT_SYSTEM}" == "systemd" ]]; then
        BASE_IMAGE_LABEL="Gentoo (systemd cloud-init)"
        BASE_IMAGE_URL="${DEPLOYMENT_GENTOO_SYSTEMD_IMAGE_URL:-https://distfiles.gentoo.org/releases/amd64/autobuilds/20260222T170100Z/di-amd64-cloudinit-20260222T170100Z.qcow2}"
        BASE_IMAGE_PATH="${DEPLOYMENT_GENTOO_SYSTEMD_IMAGE_PATH:-${REPO_ROOT}/infra/images/gentoo/systemd/di-amd64-cloudinit-20260222T170100Z.qcow2}"
      else
        BASE_IMAGE_LABEL="Gentoo (openrc cloud-init, experimental)"
        BASE_IMAGE_URL="${DEPLOYMENT_GENTOO_OPENRC_IMAGE_URL:-}"
        BASE_IMAGE_PATH="${DEPLOYMENT_GENTOO_OPENRC_IMAGE_PATH:-${REPO_ROOT}/infra/images/gentoo/openrc/gentoo-openrc-cloudinit-hostkernel.qcow2}"
      fi
      ;;
  esac
}

ensure_gentoo_openrc_image_built() {
  local builder_path="${REPO_ROOT}/experiments/gentoo-qemu/scripts/build-openrc-cloud-image.sh"
  local auto_build="${DEPLOYMENT_GENTOO_OPENRC_AUTO_BUILD:-true}"

  if [[ -f "${BASE_IMAGE_PATH}" ]]; then
    return 0
  fi

  if [[ "${auto_build}" != "true" ]]; then
    die "Gentoo OpenRC image missing and auto-build disabled (DEPLOYMENT_GENTOO_OPENRC_AUTO_BUILD=${auto_build}): ${BASE_IMAGE_PATH}"
  fi

  [[ -x "${builder_path}" ]] || die "Gentoo OpenRC image builder not found or not executable: ${builder_path}"
  log "Building Gentoo OpenRC cloud-init image (experimental) at ${BASE_IMAGE_PATH}"
  "${builder_path}" --output "${BASE_IMAGE_PATH}"
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

ACTION="${1:-apply}"
[[ $# -gt 0 ]] && shift || true
TARGET="libvirt"
OS_FAMILY="ubuntu"
INIT_SYSTEM="${DEPLOYMENT_INIT:-}"
AUTO_APPROVE=true
SKIP_IMAGE_FETCH=false

while [[ $# -gt 0 ]]; do
  case "$1" in
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
    --no-auto-approve)
      AUTO_APPROVE=false
      shift
      ;;
    --skip-image-fetch)
      SKIP_IMAGE_FETCH=true
      shift
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
case "${ACTION}" in
  apply|plan|destroy|output|ssh) ;;
  *) die "Unknown action '${ACTION}'";;
esac

check_cmd terraform

TF_DIR="${REPO_ROOT}/infra/terraform/targets/libvirt"
[[ -d "${TF_DIR}" ]] || die "Missing Terraform target dir: ${TF_DIR}"

if [[ "${ACTION}" == "apply" || "${ACTION}" == "plan" ]]; then
  check_cmd curl
fi

if [[ -z "${DEPLOYMENT_VM_NAME:-}" ]]; then
  case "${OS_FAMILY}" in
    ubuntu) DEPLOYMENT_VM_NAME="compose-traeffik-ubuntu" ;;
    debian) DEPLOYMENT_VM_NAME="compose-traeffik-debian" ;;
    gentoo)
      if [[ "${INIT_SYSTEM}" == "systemd" ]]; then
        DEPLOYMENT_VM_NAME="compose-traeffik-gentoo-systemd"
      else
        DEPLOYMENT_VM_NAME="compose-traeffik-gentoo-openrc"
      fi
      ;;
  esac
fi
DEPLOYMENT_HOSTNAME="${DEPLOYMENT_HOSTNAME:-${DEPLOYMENT_VM_NAME}}"
DEPLOYMENT_VM_IP="${DEPLOYMENT_VM_IP:-192.168.122.50}"
DEPLOYMENT_VM_CIDR_PREFIX="${DEPLOYMENT_VM_CIDR_PREFIX:-24}"
DEPLOYMENT_VM_GATEWAY="${DEPLOYMENT_VM_GATEWAY:-192.168.122.1}"
DEPLOYMENT_DNS_SERVERS="${DEPLOYMENT_DNS_SERVERS:-1.1.1.1,8.8.8.8}"
if [[ -z "${DEPLOYMENT_SSH_USER:-}" ]]; then
  case "${OS_FAMILY}" in
    ubuntu) DEPLOYMENT_SSH_USER="ubuntu" ;;
    debian) DEPLOYMENT_SSH_USER="debian" ;;
    gentoo) DEPLOYMENT_SSH_USER="gentoo" ;;
  esac
fi
DEPLOYMENT_GUEST_INTERFACE="${DEPLOYMENT_GUEST_INTERFACE:-ens3}"
DEPLOYMENT_VM_CPU="${DEPLOYMENT_VM_CPU:-2}"
DEPLOYMENT_VM_MEMORY_MB="${DEPLOYMENT_VM_MEMORY_MB:-2048}"
DEPLOYMENT_VM_DISK_GB="${DEPLOYMENT_VM_DISK_GB:-20}"
DEPLOYMENT_LIBVIRT_URI="${DEPLOYMENT_LIBVIRT_URI:-qemu:///system}"
DEPLOYMENT_LIBVIRT_POOL="${DEPLOYMENT_LIBVIRT_POOL:-default}"
DEPLOYMENT_LIBVIRT_POOL_PATH="${DEPLOYMENT_LIBVIRT_POOL_PATH:-/var/lib/libvirt/images/${DEPLOYMENT_LIBVIRT_POOL}}"
DEPLOYMENT_LIBVIRT_NETWORK="${DEPLOYMENT_LIBVIRT_NETWORK:-default}"
DEPLOYMENT_LIBVIRT_AUTOSTART="${DEPLOYMENT_LIBVIRT_AUTOSTART:-false}"
DEPLOYMENT_LIBVIRT_CPU_MODE="${DEPLOYMENT_LIBVIRT_CPU_MODE:-host-passthrough}"
DEPLOYMENT_LIBVIRT_FIRMWARE="${DEPLOYMENT_LIBVIRT_FIRMWARE:-}"
DEPLOYMENT_LIBVIRT_MACHINE="${DEPLOYMENT_LIBVIRT_MACHINE:-}"
DEPLOYMENT_LIBVIRT_ATTACH_CLOUDINIT_AS_SCSI="${DEPLOYMENT_LIBVIRT_ATTACH_CLOUDINIT_AS_SCSI:-false}"
DEPLOYMENT_LIBVIRT_REMOVE_IDE_CONTROLLER="${DEPLOYMENT_LIBVIRT_REMOVE_IDE_CONTROLLER:-false}"
DEPLOYMENT_UBUNTU_IMAGE_URL="${DEPLOYMENT_UBUNTU_IMAGE_URL:-https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img}"
DEPLOYMENT_UBUNTU_IMAGE_PATH="${DEPLOYMENT_UBUNTU_IMAGE_PATH:-${REPO_ROOT}/infra/images/ubuntu/noble-server-cloudimg-amd64.img}"

resolve_base_image_config

if [[ "${OS_FAMILY}" == "gentoo" && "${INIT_SYSTEM}" == "systemd" ]]; then
  # Gentoo official cloud-init qcow2 boots reliably with UEFI/q35 on this host.
  DEPLOYMENT_LIBVIRT_FIRMWARE="${DEPLOYMENT_LIBVIRT_FIRMWARE:-/usr/share/OVMF/OVMF_CODE_4M.fd}"
  DEPLOYMENT_LIBVIRT_MACHINE="${DEPLOYMENT_LIBVIRT_MACHINE:-q35}"
  DEPLOYMENT_LIBVIRT_ATTACH_CLOUDINIT_AS_SCSI="true"
  DEPLOYMENT_LIBVIRT_REMOVE_IDE_CONTROLLER="true"
fi

if [[ -z "${DEPLOYMENT_VM_MAC:-}" ]]; then
  DEPLOYMENT_VM_MAC="$(derive_mac_from_ip "${DEPLOYMENT_VM_IP}")" || die "Unable to derive MAC from DEPLOYMENT_VM_IP=${DEPLOYMENT_VM_IP}"
fi

if [[ "${ACTION}" == "apply" || "${ACTION}" == "plan" ]]; then
  SSH_PUBKEY_PATH="$(resolve_ssh_pubkey_path)" || die "No SSH public key found under ${HOME}/.ssh. Create one or set DEPLOYMENT_SSH_PUBKEY_PATH."
  [[ -f "${SSH_PUBKEY_PATH}" ]] || die "SSH public key not found: ${SSH_PUBKEY_PATH}"
  SSH_PUBKEY_CONTENT="$(tr -d '\n' < "${SSH_PUBKEY_PATH}")"
elif [[ "${ACTION}" == "destroy" ]]; then
  SSH_PUBKEY_PATH=""
  SSH_PUBKEY_CONTENT="destroy-placeholder"
else
  SSH_PUBKEY_PATH=""
  SSH_PUBKEY_CONTENT=""
fi

if [[ ("${ACTION}" == "apply" || "${ACTION}" == "plan") && "${SKIP_IMAGE_FETCH}" != "true" ]]; then
  if [[ "${OS_FAMILY}" == "gentoo" && "${INIT_SYSTEM}" == "openrc" ]]; then
    ensure_gentoo_openrc_image_built
  fi
  mkdir -p "$(dirname "${BASE_IMAGE_PATH}")"
  if [[ ! -f "${BASE_IMAGE_PATH}" ]]; then
    [[ -n "${BASE_IMAGE_URL}" ]] || die "${BASE_IMAGE_LABEL} image file not found locally and no URL configured: ${BASE_IMAGE_PATH}"
    log "Downloading ${BASE_IMAGE_LABEL} image to ${BASE_IMAGE_PATH}"
    curl -fL "${BASE_IMAGE_URL}" -o "${BASE_IMAGE_PATH}"
  else
    log "Using existing ${BASE_IMAGE_LABEL} image: ${BASE_IMAGE_PATH}"
  fi
fi

if [[ "${ACTION}" == "apply" || "${ACTION}" == "plan" ]]; then
  [[ -f "${BASE_IMAGE_PATH}" ]] || die "${BASE_IMAGE_LABEL} image file not found: ${BASE_IMAGE_PATH}"
fi

terraform -chdir="${TF_DIR}" init -upgrade=false >/dev/null

TF_VARS=(
  "-var=libvirt_uri=${DEPLOYMENT_LIBVIRT_URI}"
  "-var=libvirt_pool=${DEPLOYMENT_LIBVIRT_POOL}"
  "-var=libvirt_pool_path=${DEPLOYMENT_LIBVIRT_POOL_PATH}"
  "-var=libvirt_network_name=${DEPLOYMENT_LIBVIRT_NETWORK}"
  "-var=vm_name=${DEPLOYMENT_VM_NAME}"
  "-var=hostname=${DEPLOYMENT_HOSTNAME}"
  "-var=vm_ip=${DEPLOYMENT_VM_IP}"
  "-var=vm_cidr_prefix=${DEPLOYMENT_VM_CIDR_PREFIX}"
  "-var=vm_gateway=${DEPLOYMENT_VM_GATEWAY}"
  "-var=dns_servers_csv=${DEPLOYMENT_DNS_SERVERS}"
  "-var=vm_mac=${DEPLOYMENT_VM_MAC}"
  "-var=guest_interface_name=${DEPLOYMENT_GUEST_INTERFACE}"
  "-var=ssh_user=${DEPLOYMENT_SSH_USER}"
  "-var=ssh_public_key=${SSH_PUBKEY_CONTENT}"
  "-var=os_family=${OS_FAMILY}"
  "-var=init_system=${INIT_SYSTEM}"
  "-var=ubuntu_image_path=${BASE_IMAGE_PATH}"
  "-var=vm_cpu=${DEPLOYMENT_VM_CPU}"
  "-var=vm_memory_mb=${DEPLOYMENT_VM_MEMORY_MB}"
  "-var=vm_disk_gb=${DEPLOYMENT_VM_DISK_GB}"
  "-var=autostart=${DEPLOYMENT_LIBVIRT_AUTOSTART}"
  "-var=libvirt_cpu_mode=${DEPLOYMENT_LIBVIRT_CPU_MODE}"
  "-var=libvirt_firmware=${DEPLOYMENT_LIBVIRT_FIRMWARE}"
  "-var=libvirt_machine=${DEPLOYMENT_LIBVIRT_MACHINE}"
  "-var=libvirt_attach_cloudinit_as_scsi=${DEPLOYMENT_LIBVIRT_ATTACH_CLOUDINIT_AS_SCSI}"
  "-var=libvirt_remove_ide_controller=${DEPLOYMENT_LIBVIRT_REMOVE_IDE_CONTROLLER}"
)

case "${ACTION}" in
  plan)
    log "Planning ${OS_FAMILY}${INIT_SYSTEM:+ (${INIT_SYSTEM})} VM '${DEPLOYMENT_VM_NAME}' on ${TARGET}"
    terraform -chdir="${TF_DIR}" plan "${TF_VARS[@]}"
    ;;
  apply)
    log "Applying ${OS_FAMILY}${INIT_SYSTEM:+ (${INIT_SYSTEM})} VM '${DEPLOYMENT_VM_NAME}' on ${TARGET}"
    APPLY_ARGS=()
    if [[ "${AUTO_APPROVE}" == "true" ]]; then
      APPLY_ARGS+=("-auto-approve")
    fi
    terraform -chdir="${TF_DIR}" apply "${APPLY_ARGS[@]}" "${TF_VARS[@]}"
    log "Provisioned VM. Connection command:"
    terraform -chdir="${TF_DIR}" output -raw ssh_command || true
    printf '\n'
    ;;
  destroy)
    log "Destroying ${OS_FAMILY}${INIT_SYSTEM:+ (${INIT_SYSTEM})} VM '${DEPLOYMENT_VM_NAME}' on ${TARGET}"
    DESTROY_ARGS=()
    if [[ "${AUTO_APPROVE}" == "true" ]]; then
      DESTROY_ARGS+=("-auto-approve")
    fi
    terraform -chdir="${TF_DIR}" destroy "${DESTROY_ARGS[@]}" "${TF_VARS[@]}"
    ;;
  output)
    terraform -chdir="${TF_DIR}" output -json
    ;;
  ssh)
    check_cmd ssh
    host_ip="$(terraform -chdir="${TF_DIR}" output -raw host_ip)"
    ssh_user="$(terraform -chdir="${TF_DIR}" output -raw ssh_user)"
    exec ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null "${ssh_user}@${host_ip}"
    ;;
esac
