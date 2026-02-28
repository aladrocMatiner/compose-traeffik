#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"

usage() {
  cat <<'EOF'
Usage:
  deployment/scripts/infra-provision.sh <apply|plan|destroy|output|ssh> [--target <libvirt|qemu|proxmox>]
                            [--os <ubuntu|debian|debian12|debian13|gentoo|opensuse-leap|almalinux9|rockylinux9|fedora-cloud>]
                            [--init <openrc|systemd>]

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
  DEPLOYMENT_DEBIAN12_IMAGE_URL
  DEPLOYMENT_DEBIAN12_IMAGE_PATH
  DEPLOYMENT_DEBIAN12_IMAGE_SHA512
  DEPLOYMENT_DEBIAN12_SHA512SUMS_URL
  DEPLOYMENT_DEBIAN13_IMAGE_URL
  DEPLOYMENT_DEBIAN13_IMAGE_PATH
  DEPLOYMENT_DEBIAN13_IMAGE_SHA512
  DEPLOYMENT_DEBIAN13_SHA512SUMS_URL
  DEPLOYMENT_OPENSUSE_LEAP_IMAGE_URL
  DEPLOYMENT_OPENSUSE_LEAP_IMAGE_PATH
  DEPLOYMENT_OPENSUSE_LEAP_IMAGE_SHA256
  DEPLOYMENT_OPENSUSE_LEAP_SHA256SUMS_URL
  DEPLOYMENT_ALMALINUX9_IMAGE_URL
  DEPLOYMENT_ALMALINUX9_IMAGE_PATH
  DEPLOYMENT_ALMALINUX9_IMAGE_SHA256
  DEPLOYMENT_ALMALINUX9_SHA256SUMS_URL
  DEPLOYMENT_ROCKYLINUX9_IMAGE_URL
  DEPLOYMENT_ROCKYLINUX9_IMAGE_PATH
  DEPLOYMENT_ROCKYLINUX9_IMAGE_SHA256
  DEPLOYMENT_ROCKYLINUX9_SHA256SUMS_URL
  DEPLOYMENT_FEDORA_CLOUD_IMAGE_URL
  DEPLOYMENT_FEDORA_CLOUD_IMAGE_PATH
  DEPLOYMENT_FEDORA_CLOUD_IMAGE_SHA256
  DEPLOYMENT_FEDORA_CLOUD_SHA256SUMS_URL
  DEPLOYMENT_GENTOO_SYSTEMD_IMAGE_URL
  DEPLOYMENT_GENTOO_SYSTEMD_IMAGE_PATH
  DEPLOYMENT_GENTOO_OPENRC_IMAGE_URL
  DEPLOYMENT_GENTOO_OPENRC_IMAGE_PATH
  DEPLOYMENT_GENTOO_OPENRC_MANIFEST_PATH
  DEPLOYMENT_GENTOO_SYSTEMD_MANIFEST_PATH
  DEPLOYMENT_GENTOO_OPENRC_AUTO_BUILD
  DEPLOYMENT_LIBVIRT_URI
  DEPLOYMENT_LIBVIRT_POOL
  DEPLOYMENT_LIBVIRT_POOL_PATH
  DEPLOYMENT_LIBVIRT_NETWORK
  DEPLOYMENT_LIBVIRT_FIRMWARE
  DEPLOYMENT_LIBVIRT_MACHINE
  DEPLOYMENT_LIBVIRT_ATTACH_CLOUDINIT_AS_SCSI
  DEPLOYMENT_LIBVIRT_REMOVE_IDE_CONTROLLER
  DEPLOYMENT_TF_STATE_PATH
  PROXMOX_API_URL
  PROXMOX_API_TOKEN
  PROXMOX_TLS_INSECURE
  PROXMOX_NODE_NAME
  PROXMOX_TEMPLATE_VM_ID
  PROXMOX_VM_ID
  PROXMOX_CLONE_DATASTORE
  PROXMOX_DISK_DATASTORE
  PROXMOX_CLOUDINIT_DATASTORE
  PROXMOX_NETWORK_BRIDGE

Notes:
  - Interface supports --target libvirt|qemu|proxmox (`qemu` maps to `libvirt`).
  - Interface supports --os ubuntu|debian|debian12|debian13|gentoo|opensuse-leap|almalinux9|rockylinux9|fedora-cloud.
  - --os debian is treated as an alias of debian13 (current Debian profile).
  - --init is only valid with --os gentoo and defaults to openrc.
  - --target proxmox currently supports --os ubuntu.
  - Gentoo/openrc and Gentoo/systemd use project-built experimental qcow2 images (built on demand if missing).
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
  if [[ "$1" == "terraform" ]] && ! command -v terraform >/dev/null 2>&1; then
    local tf_local="${REPO_ROOT}/.tools/bin/terraform"
    if [[ -x "${tf_local}" ]]; then
      PATH="${REPO_ROOT}/.tools/bin:${PATH}"
    fi
  fi
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

sha512_file() {
  local file_path="$1"
  sha512sum "${file_path}" | awk '{print $1}'
}

sha256_file() {
  local file_path="$1"
  sha256sum "${file_path}" | awk '{print $1}'
}

fetch_checksum_from_sums() {
  local sums_url="$1"
  local image_name="$2"
  local algorithm="$3"
  local checksum
  checksum="$(
    curl -fsSL "${sums_url}" | awk -v f="${image_name}" -v algo="${algorithm}" '
      BEGIN { IGNORECASE=1 }
      $2 == f && $1 ~ /^[0-9A-Fa-f]{32,128}$/ {
        print tolower($1)
        exit
      }
      toupper($1) == toupper(algo) && $2 == "(" f ")" && $3 == "=" && $4 ~ /^[0-9A-Fa-f]{32,128}$/ {
        print tolower($4)
        exit
      }
    '
  )"
  [[ -n "${checksum}" ]] || return 1
  printf '%s\n' "${checksum}"
}

validate_target_os_init() {
  TARGET="${TARGET,,}"
  OS_FAMILY="${OS_FAMILY,,}"
  if [[ -n "${INIT_SYSTEM}" ]]; then
    INIT_SYSTEM="${INIT_SYSTEM,,}"
  fi

  if [[ "${TARGET}" == "qemu" ]]; then
    TARGET="libvirt"
  fi
  case "${TARGET}" in
    libvirt|proxmox) ;;
    *) die "Unsupported --target '${TARGET}'. Supported values: libvirt, qemu, proxmox" ;;
  esac
  case "${OS_FAMILY}" in
    ubuntu|debian|debian12|debian13|gentoo|opensuse-leap|almalinux9|rockylinux9|fedora-cloud) ;;
    *) die "Unsupported --os '${OS_FAMILY}'. Supported values: ubuntu, debian, debian12, debian13, gentoo, opensuse-leap, almalinux9, rockylinux9, fedora-cloud" ;;
  esac

  if [[ "${OS_FAMILY}" == "debian" ]]; then
    warn "--os debian is currently an alias for --os debian13"
    OS_FAMILY="debian13"
  fi

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

  if [[ "${TARGET}" == "proxmox" && "${OS_FAMILY}" != "ubuntu" ]]; then
    die "Unsupported --os '${OS_FAMILY}' for --target proxmox in v1 (supported: ubuntu)"
  fi
}

resolve_base_image_config() {
  BASE_IMAGE_LABEL=""
  BASE_IMAGE_URL=""
  BASE_IMAGE_PATH=""
  BASE_IMAGE_SHA256=""
  BASE_IMAGE_SHA256SUMS_URL=""
  BASE_IMAGE_SHA512=""
  BASE_IMAGE_SHA512SUMS_URL=""
  BASE_IMAGE_EXPECTED_NAME=""
  TEMPLATE_OS_FAMILY="${OS_FAMILY}"

  case "${OS_FAMILY}" in
    ubuntu)
      BASE_IMAGE_LABEL="Ubuntu"
      BASE_IMAGE_URL="${DEPLOYMENT_UBUNTU_IMAGE_URL:-https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img}"
      BASE_IMAGE_PATH="${DEPLOYMENT_UBUNTU_IMAGE_PATH:-${REPO_ROOT}/infra/images/ubuntu/noble-server-cloudimg-amd64.img}"
      ;;
    debian12)
      BASE_IMAGE_LABEL="Debian 12 (genericcloud, pinned)"
      BASE_IMAGE_URL="${DEPLOYMENT_DEBIAN12_IMAGE_URL:-https://cloud.debian.org/images/cloud/bookworm/20260129-2372/debian-12-genericcloud-amd64-20260129-2372.qcow2}"
      BASE_IMAGE_PATH="${DEPLOYMENT_DEBIAN12_IMAGE_PATH:-${REPO_ROOT}/infra/images/debian/debian-12-genericcloud-amd64-20260129-2372.qcow2}"
      BASE_IMAGE_SHA512="${DEPLOYMENT_DEBIAN12_IMAGE_SHA512:-89ea4eb8f4c07f91ce4d7814e76d04b4beaa1385f8806899bc2918ec7f6bb2dfddf1f4861f72bcb0820392a29f390d3f2f0064cc9510464dce9f0d89f03843e4}"
      BASE_IMAGE_SHA512SUMS_URL="${DEPLOYMENT_DEBIAN12_SHA512SUMS_URL:-https://cloud.debian.org/images/cloud/bookworm/20260129-2372/SHA512SUMS}"
      BASE_IMAGE_EXPECTED_NAME="$(basename "${BASE_IMAGE_URL}")"
      TEMPLATE_OS_FAMILY="debian"
      ;;
    debian13)
      BASE_IMAGE_LABEL="Debian 13 (genericcloud, pinned)"
      BASE_IMAGE_URL="${DEPLOYMENT_DEBIAN13_IMAGE_URL:-https://cloud.debian.org/images/cloud/trixie/20260220-2394/debian-13-genericcloud-amd64-20260220-2394.qcow2}"
      BASE_IMAGE_PATH="${DEPLOYMENT_DEBIAN13_IMAGE_PATH:-${REPO_ROOT}/infra/images/debian/debian-13-genericcloud-amd64-20260220-2394.qcow2}"
      BASE_IMAGE_SHA512="${DEPLOYMENT_DEBIAN13_IMAGE_SHA512:-6da628d0f44ddcc8641d5ed1c7a1b4841ccf6608810a8f7aae860db51e9975e76b3c230728560337b615f8b610a34a760cf9d18e8ddb55c48608a06724ea0892}"
      BASE_IMAGE_SHA512SUMS_URL="${DEPLOYMENT_DEBIAN13_SHA512SUMS_URL:-https://cloud.debian.org/images/cloud/trixie/20260220-2394/SHA512SUMS}"
      BASE_IMAGE_EXPECTED_NAME="$(basename "${BASE_IMAGE_URL}")"
      TEMPLATE_OS_FAMILY="debian"
      ;;
    opensuse-leap)
      BASE_IMAGE_LABEL="openSUSE Leap (cloud image)"
      BASE_IMAGE_URL="${DEPLOYMENT_OPENSUSE_LEAP_IMAGE_URL:-https://download.opensuse.org/distribution/leap/15.6/appliances/openSUSE-Leap-15.6-Minimal-VM.x86_64-Cloud.qcow2}"
      BASE_IMAGE_PATH="${DEPLOYMENT_OPENSUSE_LEAP_IMAGE_PATH:-${REPO_ROOT}/infra/images/opensuse/openSUSE-Leap-15.6-Minimal-VM.x86_64-Cloud.qcow2}"
      BASE_IMAGE_SHA256="${DEPLOYMENT_OPENSUSE_LEAP_IMAGE_SHA256:-ba32ea4136812cb09a3a853723187b007f5cf0a2013a0123240a7d45f42ea4a9}"
      BASE_IMAGE_SHA256SUMS_URL="${DEPLOYMENT_OPENSUSE_LEAP_SHA256SUMS_URL:-https://download.opensuse.org/distribution/leap/15.6/appliances/openSUSE-Leap-15.6-Minimal-VM.x86_64-Cloud.qcow2.sha256}"
      BASE_IMAGE_EXPECTED_NAME="$(basename "${BASE_IMAGE_URL}")"
      TEMPLATE_OS_FAMILY="opensuse"
      ;;
    almalinux9)
      BASE_IMAGE_LABEL="AlmaLinux 9 (GenericCloud)"
      BASE_IMAGE_URL="${DEPLOYMENT_ALMALINUX9_IMAGE_URL:-https://repo.almalinux.org/almalinux/9/cloud/x86_64/images/AlmaLinux-9-GenericCloud-9.7-20251118.x86_64.qcow2}"
      BASE_IMAGE_PATH="${DEPLOYMENT_ALMALINUX9_IMAGE_PATH:-${REPO_ROOT}/infra/images/almalinux/AlmaLinux-9-GenericCloud-9.7-20251118.x86_64.qcow2}"
      BASE_IMAGE_SHA256="${DEPLOYMENT_ALMALINUX9_IMAGE_SHA256:-5ff9c048859046f41db4a33b1f1a96675711288078aac66b47d0be023af270d1}"
      BASE_IMAGE_SHA256SUMS_URL="${DEPLOYMENT_ALMALINUX9_SHA256SUMS_URL:-https://repo.almalinux.org/almalinux/9/cloud/x86_64/images/CHECKSUM}"
      BASE_IMAGE_EXPECTED_NAME="$(basename "${BASE_IMAGE_URL}")"
      TEMPLATE_OS_FAMILY="rhel"
      ;;
    rockylinux9)
      BASE_IMAGE_LABEL="Rocky Linux 9 (GenericCloud)"
      BASE_IMAGE_URL="${DEPLOYMENT_ROCKYLINUX9_IMAGE_URL:-https://dl.rockylinux.org/pub/rocky/9/images/x86_64/Rocky-9-GenericCloud-9.7-20251123.2.x86_64.qcow2}"
      BASE_IMAGE_PATH="${DEPLOYMENT_ROCKYLINUX9_IMAGE_PATH:-${REPO_ROOT}/infra/images/rocky/Rocky-9-GenericCloud-9.7-20251123.2.x86_64.qcow2}"
      BASE_IMAGE_SHA256="${DEPLOYMENT_ROCKYLINUX9_IMAGE_SHA256:-15d81d3434b298142b2fdd8fb54aef2662684db5c082cc191c3c79762ed6360c}"
      BASE_IMAGE_SHA256SUMS_URL="${DEPLOYMENT_ROCKYLINUX9_SHA256SUMS_URL:-https://dl.rockylinux.org/pub/rocky/9/images/x86_64/CHECKSUM}"
      BASE_IMAGE_EXPECTED_NAME="$(basename "${BASE_IMAGE_URL}")"
      TEMPLATE_OS_FAMILY="rhel"
      ;;
    fedora-cloud)
      BASE_IMAGE_LABEL="Fedora Cloud (qcow2)"
      BASE_IMAGE_URL="${DEPLOYMENT_FEDORA_CLOUD_IMAGE_URL:-https://download.fedoraproject.org/pub/fedora/linux/releases/41/Cloud/x86_64/images/Fedora-Cloud-Base-Generic.x86_64-41-1.4.qcow2}"
      BASE_IMAGE_PATH="${DEPLOYMENT_FEDORA_CLOUD_IMAGE_PATH:-${REPO_ROOT}/infra/images/fedora/Fedora-Cloud-Base-Generic.x86_64-41-1.4.qcow2}"
      BASE_IMAGE_SHA256="${DEPLOYMENT_FEDORA_CLOUD_IMAGE_SHA256:-6205ae0c524b4d1816dbd3573ce29b5c44ed26c9fbc874fbe48c41c89dd0bac2}"
      BASE_IMAGE_SHA256SUMS_URL="${DEPLOYMENT_FEDORA_CLOUD_SHA256SUMS_URL:-https://download.fedoraproject.org/pub/fedora/linux/releases/41/Cloud/x86_64/images/Fedora-Cloud-41-1.4-x86_64-CHECKSUM}"
      BASE_IMAGE_EXPECTED_NAME="$(basename "${BASE_IMAGE_URL}")"
      TEMPLATE_OS_FAMILY="fedora"
      ;;
    gentoo)
      if [[ "${INIT_SYSTEM}" == "systemd" ]]; then
        BASE_IMAGE_LABEL="Gentoo (systemd cloud-init, experimental)"
        BASE_IMAGE_URL="${DEPLOYMENT_GENTOO_SYSTEMD_IMAGE_URL:-}"
        BASE_IMAGE_PATH="${DEPLOYMENT_GENTOO_SYSTEMD_IMAGE_PATH:-${REPO_ROOT}/infra/images/gentoo/systemd/gentoo-systemd-cloudinit-hostkernel.qcow2}"
      else
        BASE_IMAGE_LABEL="Gentoo (openrc cloud-init, experimental)"
        BASE_IMAGE_URL="${DEPLOYMENT_GENTOO_OPENRC_IMAGE_URL:-}"
        BASE_IMAGE_PATH="${DEPLOYMENT_GENTOO_OPENRC_IMAGE_PATH:-${REPO_ROOT}/infra/images/gentoo/openrc/gentoo-openrc-cloudinit-hostkernel.qcow2}"
      fi
      ;;
  esac
}

verify_base_image_integrity() {
  [[ -f "${BASE_IMAGE_PATH}" ]] || die "${BASE_IMAGE_LABEL} image file not found: ${BASE_IMAGE_PATH}"

  if [[ -n "${BASE_IMAGE_SHA256SUMS_URL}" && -n "${BASE_IMAGE_EXPECTED_NAME}" ]]; then
    local sums_sha256
    sums_sha256="$(fetch_checksum_from_sums "${BASE_IMAGE_SHA256SUMS_URL}" "${BASE_IMAGE_EXPECTED_NAME}" "SHA256")" || \
      die "Failed to resolve SHA256 for ${BASE_IMAGE_EXPECTED_NAME} from ${BASE_IMAGE_SHA256SUMS_URL}"
    if [[ -n "${BASE_IMAGE_SHA256}" && "${BASE_IMAGE_SHA256}" != "${sums_sha256}" ]]; then
      die "Configured SHA256 for ${BASE_IMAGE_EXPECTED_NAME} does not match upstream sums file (${BASE_IMAGE_SHA256SUMS_URL})"
    fi
    BASE_IMAGE_SHA256="${sums_sha256}"
  fi

  if [[ -n "${BASE_IMAGE_SHA256}" ]]; then
    check_cmd sha256sum
    local actual_sha256
    actual_sha256="$(sha256_file "${BASE_IMAGE_PATH}")"
    [[ "${actual_sha256}" == "${BASE_IMAGE_SHA256}" ]] || \
      die "${BASE_IMAGE_LABEL} checksum mismatch for ${BASE_IMAGE_PATH}: expected ${BASE_IMAGE_SHA256}, got ${actual_sha256}"
    log "Verified ${BASE_IMAGE_LABEL} SHA256 (${actual_sha256})"
  fi

  if [[ -n "${BASE_IMAGE_SHA512SUMS_URL}" && -n "${BASE_IMAGE_EXPECTED_NAME}" ]]; then
    local sums_sha512
    sums_sha512="$(fetch_checksum_from_sums "${BASE_IMAGE_SHA512SUMS_URL}" "${BASE_IMAGE_EXPECTED_NAME}" "SHA512")" || \
      die "Failed to resolve SHA512 for ${BASE_IMAGE_EXPECTED_NAME} from ${BASE_IMAGE_SHA512SUMS_URL}"
    if [[ -n "${BASE_IMAGE_SHA512}" && "${BASE_IMAGE_SHA512}" != "${sums_sha512}" ]]; then
      die "Configured SHA512 for ${BASE_IMAGE_EXPECTED_NAME} does not match upstream sums file (${BASE_IMAGE_SHA512SUMS_URL})"
    fi
    BASE_IMAGE_SHA512="${sums_sha512}"
  fi

  if [[ -n "${BASE_IMAGE_SHA512}" ]]; then
    check_cmd sha512sum
    local actual_sha512
    actual_sha512="$(sha512_file "${BASE_IMAGE_PATH}")"
    [[ "${actual_sha512}" == "${BASE_IMAGE_SHA512}" ]] || \
      die "${BASE_IMAGE_LABEL} checksum mismatch for ${BASE_IMAGE_PATH}: expected ${BASE_IMAGE_SHA512}, got ${actual_sha512}"
    log "Verified ${BASE_IMAGE_LABEL} SHA512 (${actual_sha512})"
  fi
}

strip_wrapping_quotes() {
  local value="$1"
  value="${value%\"}"
  value="${value#\"}"
  value="${value%\'}"
  value="${value#\'}"
  printf '%s\n' "${value}"
}

manifest_get_scalar() {
  local manifest_path="$1"
  local key="$2"
  local line
  line="$(awk -v key="${key}" '
    $1 == key ":" {
      sub("^[^:]+:[[:space:]]*", "", $0)
      print
      exit
    }
  ' "${manifest_path}")"
  strip_wrapping_quotes "${line}"
}

validate_gentoo_manifest() {
  [[ "${OS_FAMILY}" == "gentoo" ]] || return 0

  local manifest_path manifest_variant
  if [[ "${INIT_SYSTEM}" == "systemd" ]]; then
    manifest_path="${DEPLOYMENT_GENTOO_SYSTEMD_MANIFEST_PATH:-${REPO_ROOT}/experiments/gentoo-qemu/manifests/gentoo-systemd-stage3-hostkernel-20260222T170100Z.yaml}"
    manifest_variant="systemd"
  else
    manifest_path="${DEPLOYMENT_GENTOO_OPENRC_MANIFEST_PATH:-${REPO_ROOT}/experiments/gentoo-qemu/manifests/gentoo-openrc-stage3-hostkernel-20260222T170100Z.yaml}"
    manifest_variant="openrc"
  fi

  [[ -f "${manifest_path}" ]] || die "Gentoo ${manifest_variant} manifest missing: ${manifest_path}"

  local manifest_id manifest_os manifest_init cloud_init_support qemu_gate
  manifest_id="$(manifest_get_scalar "${manifest_path}" "id")"
  manifest_os="$(manifest_get_scalar "${manifest_path}" "os")"
  manifest_init="$(manifest_get_scalar "${manifest_path}" "init_system")"
  cloud_init_support="$(manifest_get_scalar "${manifest_path}" "cloud_init_support")"
  qemu_gate="$(manifest_get_scalar "${manifest_path}" "qualified_qemu_provisioning")"

  [[ -n "${manifest_id}" ]] || die "Gentoo ${manifest_variant} manifest is missing required field: id (${manifest_path})"
  [[ "${manifest_os}" == "gentoo" ]] || die "Gentoo ${manifest_variant} manifest has invalid os='${manifest_os}' (${manifest_path})"
  [[ "${manifest_init}" == "${manifest_variant}" ]] || \
    die "Gentoo ${manifest_variant} manifest has init_system='${manifest_init}' (expected '${manifest_variant}') (${manifest_path})"
  [[ -n "${cloud_init_support}" && "${cloud_init_support}" != "none" ]] || \
    die "Gentoo ${manifest_variant} manifest declares cloud-init unsupported (${manifest_path})"
  [[ "${qemu_gate,,}" == "true" ]] || \
    die "Gentoo ${manifest_variant} profile exists but is not qualified for qemu provisioning (qualified_qemu_provisioning=${qemu_gate:-unset})"

  log "Validated Gentoo ${manifest_variant} manifest: ${manifest_id}"
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

ensure_gentoo_systemd_image_built() {
  local builder_path="${REPO_ROOT}/experiments/gentoo-qemu/scripts/build-systemd-cloud-image.sh"
  local auto_build="${DEPLOYMENT_GENTOO_SYSTEMD_AUTO_BUILD:-true}"

  if [[ -f "${BASE_IMAGE_PATH}" ]]; then
    return 0
  fi

  if [[ "${auto_build}" != "true" ]]; then
    die "Gentoo systemd image missing and auto-build disabled (DEPLOYMENT_GENTOO_SYSTEMD_AUTO_BUILD=${auto_build}): ${BASE_IMAGE_PATH}"
  fi

  [[ -x "${builder_path}" ]] || die "Gentoo systemd image builder not found or not executable: ${builder_path}"
  log "Building Gentoo systemd cloud-init image (experimental) at ${BASE_IMAGE_PATH}"
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

TF_DIR="${REPO_ROOT}/infra/terraform/targets/${TARGET}"
[[ -d "${TF_DIR}" ]] || die "Missing Terraform target dir: ${TF_DIR}"

deployment_libvirt_pool_explicit=false
if [[ -n "${DEPLOYMENT_LIBVIRT_POOL+x}" ]]; then
  deployment_libvirt_pool_explicit=true
fi
deployment_libvirt_pool_path_explicit=false
if [[ -n "${DEPLOYMENT_LIBVIRT_POOL_PATH+x}" ]]; then
  deployment_libvirt_pool_path_explicit=true
fi

if [[ "${TARGET}" == "proxmox" && ("${ACTION}" == "apply" || "${ACTION}" == "plan") ]]; then
  [[ -n "${PROXMOX_API_URL:-${DEPLOYMENT_PROXMOX_API_URL:-}}" ]] || die "Missing Proxmox API URL (set PROXMOX_API_URL or DEPLOYMENT_PROXMOX_API_URL)"
  [[ -n "${PROXMOX_API_TOKEN:-${DEPLOYMENT_PROXMOX_API_TOKEN:-}}" ]] || die "Missing Proxmox API token (set PROXMOX_API_TOKEN or DEPLOYMENT_PROXMOX_API_TOKEN)"
  [[ -n "${PROXMOX_NODE_NAME:-${DEPLOYMENT_PROXMOX_NODE_NAME:-}}" ]] || die "Missing Proxmox node name (set PROXMOX_NODE_NAME or DEPLOYMENT_PROXMOX_NODE_NAME)"
  local_template_vm_id="${PROXMOX_TEMPLATE_VM_ID:-${DEPLOYMENT_PROXMOX_TEMPLATE_VM_ID:-0}}"
  [[ "${local_template_vm_id}" =~ ^[0-9]+$ ]] || die "Invalid PROXMOX_TEMPLATE_VM_ID value: ${local_template_vm_id}"
  (( local_template_vm_id > 0 )) || die "Missing Proxmox template VM id (set PROXMOX_TEMPLATE_VM_ID or DEPLOYMENT_PROXMOX_TEMPLATE_VM_ID)"
fi

if [[ "${ACTION}" == "apply" || "${ACTION}" == "plan" ]]; then
  if [[ "${TARGET}" == "libvirt" ]]; then
    check_cmd curl
  fi
fi

if [[ -z "${DEPLOYMENT_VM_NAME:-}" ]]; then
  case "${OS_FAMILY}" in
    ubuntu) DEPLOYMENT_VM_NAME="compose-traeffik-ubuntu" ;;
    debian12) DEPLOYMENT_VM_NAME="compose-traeffik-debian12" ;;
    debian13) DEPLOYMENT_VM_NAME="compose-traeffik-debian13" ;;
    opensuse-leap) DEPLOYMENT_VM_NAME="compose-traeffik-opensuse-leap" ;;
    almalinux9) DEPLOYMENT_VM_NAME="compose-traeffik-almalinux9" ;;
    rockylinux9) DEPLOYMENT_VM_NAME="compose-traeffik-rockylinux9" ;;
    fedora-cloud) DEPLOYMENT_VM_NAME="compose-traeffik-fedora-cloud" ;;
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
    debian12) DEPLOYMENT_SSH_USER="debian" ;;
    debian13) DEPLOYMENT_SSH_USER="debian" ;;
    opensuse-leap) DEPLOYMENT_SSH_USER="opensuse" ;;
    almalinux9) DEPLOYMENT_SSH_USER="cloud-user" ;;
    rockylinux9) DEPLOYMENT_SSH_USER="rocky" ;;
    fedora-cloud) DEPLOYMENT_SSH_USER="fedora" ;;
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
DEPLOYMENT_GENTOO_OPENRC_MANIFEST_PATH="${DEPLOYMENT_GENTOO_OPENRC_MANIFEST_PATH:-${REPO_ROOT}/experiments/gentoo-qemu/manifests/gentoo-openrc-stage3-hostkernel-20260222T170100Z.yaml}"
DEPLOYMENT_GENTOO_SYSTEMD_MANIFEST_PATH="${DEPLOYMENT_GENTOO_SYSTEMD_MANIFEST_PATH:-${REPO_ROOT}/experiments/gentoo-qemu/manifests/gentoo-systemd-stage3-hostkernel-20260222T170100Z.yaml}"
DEPLOYMENT_TF_STATE_PATH="${DEPLOYMENT_TF_STATE_PATH:-}"

if [[ "${TARGET}" == "libvirt" && "${deployment_libvirt_pool_explicit}" != "true" && -n "${DEPLOYMENT_TF_STATE_PATH}" && "$(command -v jq || true)" != "" ]]; then
  for state_candidate in "${DEPLOYMENT_TF_STATE_PATH}" "${DEPLOYMENT_TF_STATE_PATH}.backup"; do
    [[ -f "${state_candidate}" ]] || continue
    recovered_pool="$(jq -r '[.resources[]? | select(.type=="libvirt_volume" or .type=="libvirt_cloudinit_disk") | .instances[]?.attributes.pool | select(type=="string" and length>0)] | first // empty' "${state_candidate}" 2>/dev/null || true)"
    if [[ -n "${recovered_pool}" ]]; then
      DEPLOYMENT_LIBVIRT_POOL="${recovered_pool}"
      if [[ "${deployment_libvirt_pool_path_explicit}" != "true" ]]; then
        DEPLOYMENT_LIBVIRT_POOL_PATH="/var/lib/libvirt/images/${DEPLOYMENT_LIBVIRT_POOL}"
      fi
      log "Recovered libvirt pool '${DEPLOYMENT_LIBVIRT_POOL}' from ${state_candidate}"
      break
    fi
  done
fi

if [[ "${TARGET}" == "libvirt" && "${deployment_libvirt_pool_explicit}" != "true" && "$(command -v virsh || true)" != "" ]]; then
  if ! virsh pool-info "${DEPLOYMENT_LIBVIRT_POOL}" >/dev/null 2>&1; then
    detected_pool=""
    while IFS= read -r pool_name; do
      pool_name="$(printf '%s' "${pool_name}" | xargs)"
      [[ -n "${pool_name}" ]] || continue
      if virsh pool-info "${pool_name}" 2>/dev/null | grep -q "^State:[[:space:]]*running$"; then
        detected_pool="${pool_name}"
        break
      fi
      if [[ -z "${detected_pool}" ]]; then
        detected_pool="${pool_name}"
      fi
    done < <(virsh pool-list --all --name 2>/dev/null || true)

    if [[ -n "${detected_pool}" ]]; then
      DEPLOYMENT_LIBVIRT_POOL="${detected_pool}"
      if [[ "${deployment_libvirt_pool_path_explicit}" != "true" ]]; then
        detected_pool_path="$(virsh pool-dumpxml "${detected_pool}" 2>/dev/null | awk -F'[<>]' '/<path>/{print $3; exit}' || true)"
        if [[ -n "${detected_pool_path}" ]]; then
          DEPLOYMENT_LIBVIRT_POOL_PATH="${detected_pool_path}"
        else
          DEPLOYMENT_LIBVIRT_POOL_PATH="/var/lib/libvirt/images/${DEPLOYMENT_LIBVIRT_POOL}"
        fi
      fi
      warn "Configured libvirt pool '${DEPLOYMENT_LIBVIRT_POOL}' (default pool not available)"
    fi
  fi
fi

if [[ "${TARGET}" == "libvirt" ]]; then
  resolve_base_image_config
  validate_gentoo_manifest
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

if [[ "${TARGET}" == "libvirt" && ("${ACTION}" == "apply" || "${ACTION}" == "plan") && "${SKIP_IMAGE_FETCH}" != "true" ]]; then
  if [[ "${OS_FAMILY}" == "gentoo" && "${INIT_SYSTEM}" == "openrc" ]]; then
    ensure_gentoo_openrc_image_built
  elif [[ "${OS_FAMILY}" == "gentoo" && "${INIT_SYSTEM}" == "systemd" ]]; then
    ensure_gentoo_systemd_image_built
  fi
  mkdir -p "$(dirname "${BASE_IMAGE_PATH}")"
  if [[ ! -f "${BASE_IMAGE_PATH}" ]]; then
    [[ -n "${BASE_IMAGE_URL}" ]] || die "${BASE_IMAGE_LABEL} image file not found locally and no URL configured: ${BASE_IMAGE_PATH}"
    log "Downloading ${BASE_IMAGE_LABEL} image to ${BASE_IMAGE_PATH}"
    curl -fL "${BASE_IMAGE_URL}" -o "${BASE_IMAGE_PATH}"
  else
    log "Using existing ${BASE_IMAGE_LABEL} image: ${BASE_IMAGE_PATH}"
  fi
  verify_base_image_integrity
fi

if [[ "${TARGET}" == "libvirt" && ("${ACTION}" == "apply" || "${ACTION}" == "plan") ]]; then
  verify_base_image_integrity
fi

terraform -chdir="${TF_DIR}" init -upgrade=false >/dev/null

TF_STATE_ARGS=()
if [[ -n "${DEPLOYMENT_TF_STATE_PATH}" ]]; then
  mkdir -p "$(dirname "${DEPLOYMENT_TF_STATE_PATH}")"
  TF_STATE_ARGS+=("-state=${DEPLOYMENT_TF_STATE_PATH}")
fi

TF_VARS=()
if [[ "${TARGET}" == "libvirt" ]]; then
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
    "-var=os_family=${TEMPLATE_OS_FAMILY}"
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
else
  TF_VARS=(
    "-var=vm_name=${DEPLOYMENT_VM_NAME}"
    "-var=hostname=${DEPLOYMENT_HOSTNAME}"
    "-var=vm_ip=${DEPLOYMENT_VM_IP}"
    "-var=vm_cidr_prefix=${DEPLOYMENT_VM_CIDR_PREFIX}"
    "-var=vm_gateway=${DEPLOYMENT_VM_GATEWAY}"
    "-var=dns_servers_csv=${DEPLOYMENT_DNS_SERVERS}"
    "-var=ssh_user=${DEPLOYMENT_SSH_USER}"
    "-var=ssh_public_key=${SSH_PUBKEY_CONTENT}"
    "-var=vm_cpu=${DEPLOYMENT_VM_CPU}"
    "-var=vm_memory_mb=${DEPLOYMENT_VM_MEMORY_MB}"
    "-var=vm_disk_gb=${DEPLOYMENT_VM_DISK_GB}"
    "-var=proxmox_api_url=${PROXMOX_API_URL:-${DEPLOYMENT_PROXMOX_API_URL:-}}"
    "-var=proxmox_api_token=${PROXMOX_API_TOKEN:-${DEPLOYMENT_PROXMOX_API_TOKEN:-}}"
    "-var=proxmox_tls_insecure=${PROXMOX_TLS_INSECURE:-${DEPLOYMENT_PROXMOX_TLS_INSECURE:-false}}"
    "-var=proxmox_node_name=${PROXMOX_NODE_NAME:-${DEPLOYMENT_PROXMOX_NODE_NAME:-}}"
    "-var=proxmox_template_vm_id=${PROXMOX_TEMPLATE_VM_ID:-${DEPLOYMENT_PROXMOX_TEMPLATE_VM_ID:-0}}"
    "-var=proxmox_vm_id=${PROXMOX_VM_ID:-${DEPLOYMENT_PROXMOX_VM_ID:-0}}"
    "-var=proxmox_clone_datastore_id=${PROXMOX_CLONE_DATASTORE:-${DEPLOYMENT_PROXMOX_CLONE_DATASTORE:-local-lvm}}"
    "-var=proxmox_disk_datastore_id=${PROXMOX_DISK_DATASTORE:-${DEPLOYMENT_PROXMOX_DISK_DATASTORE:-local-lvm}}"
    "-var=proxmox_cloudinit_datastore_id=${PROXMOX_CLOUDINIT_DATASTORE:-${DEPLOYMENT_PROXMOX_CLOUDINIT_DATASTORE:-local-lvm}}"
    "-var=proxmox_network_bridge=${PROXMOX_NETWORK_BRIDGE:-${DEPLOYMENT_PROXMOX_NETWORK_BRIDGE:-vmbr0}}"
  )
fi

case "${ACTION}" in
  plan)
    log "Planning ${OS_FAMILY}${INIT_SYSTEM:+ (${INIT_SYSTEM})} VM '${DEPLOYMENT_VM_NAME}' on ${TARGET}"
    terraform -chdir="${TF_DIR}" plan "${TF_STATE_ARGS[@]}" "${TF_VARS[@]}"
    ;;
  apply)
    log "Applying ${OS_FAMILY}${INIT_SYSTEM:+ (${INIT_SYSTEM})} VM '${DEPLOYMENT_VM_NAME}' on ${TARGET}"
    APPLY_ARGS=()
    if [[ "${AUTO_APPROVE}" == "true" ]]; then
      APPLY_ARGS+=("-auto-approve")
    fi
    terraform -chdir="${TF_DIR}" apply "${TF_STATE_ARGS[@]}" "${APPLY_ARGS[@]}" "${TF_VARS[@]}"
    log "Provisioned VM. Connection command:"
    terraform -chdir="${TF_DIR}" output "${TF_STATE_ARGS[@]}" -raw ssh_command || true
    printf '\n'
    ;;
  destroy)
    log "Destroying ${OS_FAMILY}${INIT_SYSTEM:+ (${INIT_SYSTEM})} VM '${DEPLOYMENT_VM_NAME}' on ${TARGET}"
    DESTROY_ARGS=()
    if [[ "${AUTO_APPROVE}" == "true" ]]; then
      DESTROY_ARGS+=("-auto-approve")
    fi
    terraform -chdir="${TF_DIR}" destroy "${TF_STATE_ARGS[@]}" "${DESTROY_ARGS[@]}" "${TF_VARS[@]}"
    ;;
  output)
    terraform -chdir="${TF_DIR}" output "${TF_STATE_ARGS[@]}" -json
    ;;
  ssh)
    check_cmd ssh
    host_ip="$(terraform -chdir="${TF_DIR}" output "${TF_STATE_ARGS[@]}" -raw host_ip)"
    ssh_user="$(terraform -chdir="${TF_DIR}" output "${TF_STATE_ARGS[@]}" -raw ssh_user)"
    exec ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null "${ssh_user}@${host_ip}"
    ;;
esac
