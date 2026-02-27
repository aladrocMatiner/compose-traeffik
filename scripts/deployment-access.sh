#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

usage() {
  cat <<'USAGE'
Usage:
  scripts/deployment-access.sh list --target <qemu|proxmox>
  scripts/deployment-access.sh ssh  --target <qemu|proxmox> --name <vm-name>

Notes:
  - target=qemu maps to local libvirt.
  - target=proxmox is currently a placeholder and returns a clear unsupported message.
  - For backward-compatible Terraform-state SSH, use: make deployment-ssh
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
    qemu|libvirt)
      printf 'qemu\n'
      ;;
    proxmox)
      printf 'proxmox\n'
      ;;
    *)
      die "Unsupported target '${1}'. Supported: qemu, proxmox"
      ;;
  esac
}

managed_name_match() {
  local vm_name="$1"
  local prefix="${DEPLOYMENT_MANAGED_PREFIX:-compose-traeffik-}"
  [[ "${vm_name}" == "${prefix}"* ]]
}

list_qemu() {
  check_cmd virsh
  local rows
  rows="$(virsh list --all --name 2>/dev/null | sed '/^$/d' || true)"
  if [[ -z "${rows}" ]]; then
    log "No libvirt domains found"
    return 0
  fi

  local prefix="${DEPLOYMENT_MANAGED_PREFIX:-compose-traeffik-}"
  local found=0
  log "Managed filter: name prefix '${prefix}'"
  printf '%-42s %-12s %-16s\n' "NAME" "STATE" "IP"
  while IFS= read -r vm; do
    [[ -n "${vm}" ]] || continue
    if ! managed_name_match "${vm}"; then
      continue
    fi
    found=1
    local state
    local ip=""
    state="$(virsh domstate "${vm}" 2>/dev/null | tr -d '\r' | xargs || true)"
    if [[ "${state}" == "running" ]]; then
      ip="$(resolve_ip_from_domifaddr "${vm}" agent 2>/dev/null || true)"
      if [[ -z "${ip}" ]]; then
        ip="$(resolve_ip_from_domifaddr "${vm}" lease 2>/dev/null || true)"
      fi
      if [[ -z "${ip}" ]]; then
        ip="$(resolve_ip_from_domifaddr "${vm}" arp 2>/dev/null || true)"
      fi
      if [[ -z "${ip}" ]]; then
        ip="$(resolve_ip_from_dhcp_leases "${vm}" 2>/dev/null || true)"
      fi
    fi
    printf '%-42s %-12s %-16s\n' "${vm}" "${state:-unknown}" "${ip:--}"
  done <<<"${rows}"
  if [[ "${found}" -eq 0 ]]; then
    log "No managed qemu/libvirt deployments found (prefix: ${prefix})"
    return 0
  fi
}

resolve_ip_from_domifaddr() {
  local vm_name="$1"
  local source="$2"
  local ip
  ip="$(virsh domifaddr "${vm_name}" --source "${source}" 2>/dev/null | awk '/ipv4/ {print $4}' | cut -d/ -f1 | head -n1)"
  [[ -n "${ip}" ]] || return 1
  printf '%s\n' "${ip}"
}

resolve_ip_from_dhcp_leases() {
  local vm_name="$1"
  local mac
  mac="$(virsh domiflist "${vm_name}" 2>/dev/null | awk '/[0-9a-fA-F]{2}(:[0-9a-fA-F]{2}){5}/ {print tolower($5); exit}')"
  [[ -n "${mac}" ]] || return 1

  local network
  network="$(virsh domiflist "${vm_name}" 2>/dev/null | awk 'NR>2 && $1 != "" {print $3; exit}')"
  [[ -n "${network}" ]] || network="default"

  local ip
  ip="$(virsh net-dhcp-leases "${network}" 2>/dev/null | awk -v m="${mac}" 'tolower($3)==m {print $5; exit}' | cut -d/ -f1)"
  [[ -n "${ip}" ]] || return 1
  printf '%s\n' "${ip}"
}

ssh_qemu() {
  check_cmd virsh
  check_cmd ssh
  local vm_name="$1"
  [[ -n "${vm_name}" ]] || die "Missing --name for target=qemu"

  virsh dominfo "${vm_name}" >/dev/null 2>&1 || die "VM '${vm_name}' not found in libvirt"

  local ip=""
  local source=""
  if ip="$(resolve_ip_from_domifaddr "${vm_name}" agent)"; then
    source="domifaddr(agent)"
  elif ip="$(resolve_ip_from_domifaddr "${vm_name}" lease)"; then
    source="domifaddr(lease)"
  elif ip="$(resolve_ip_from_domifaddr "${vm_name}" arp)"; then
    source="domifaddr(arp)"
  elif ip="$(resolve_ip_from_dhcp_leases "${vm_name}")"; then
    source="net-dhcp-leases"
  else
    die "Unable to resolve IP for '${vm_name}'. Recovery: virsh console ${vm_name}"
  fi

  local ssh_user="${DEPLOYMENT_SSH_USER:-${DEPLOYMENT_HOST_USER:-}}"
  if [[ -z "${ssh_user}" ]]; then
    if ! command -v terraform >/dev/null 2>&1; then
      local tf_local="${REPO_ROOT}/.tools/bin/terraform"
      if [[ -x "${tf_local}" ]]; then
        PATH="${REPO_ROOT}/.tools/bin:${PATH}"
      fi
    fi
    if command -v terraform >/dev/null 2>&1 && [[ -d "${REPO_ROOT}/infra/terraform/targets/libvirt" ]]; then
      ssh_user="$(terraform -chdir="${REPO_ROOT}/infra/terraform/targets/libvirt" output -raw ssh_user 2>/dev/null || true)"
    fi
  fi
  ssh_user="${ssh_user:-ubuntu}"

  log "Resolved ${vm_name} -> ${ip} via ${source}; connecting as ${ssh_user}"
  exec ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null "${ssh_user}@${ip}"
}

ACTION="${1:-}"
[[ -n "${ACTION}" ]] || { usage; exit 1; }
shift || true

TARGET=""
NAME=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --target)
      [[ $# -ge 2 ]] || die "--target requires a value"
      TARGET="$2"
      shift 2
      ;;
    --name)
      [[ $# -ge 2 ]] || die "--name requires a value"
      NAME="$2"
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

TARGET="$(normalize_target "${TARGET:-qemu}")"

case "${ACTION}" in
  list)
    if [[ "${TARGET}" == "qemu" ]]; then
      list_qemu
    else
      die "target=proxmox listing is not implemented yet in deployment-access.sh (use infra-provision outputs/SSH path)"
    fi
    ;;
  ssh)
    if [[ "${TARGET}" == "qemu" ]]; then
      ssh_qemu "${NAME}"
    else
      die "target=proxmox SSH resolution is not implemented yet in deployment-access.sh (use make deployment-ssh target=proxmox without name, backed by terraform outputs)"
    fi
    ;;
  *)
    die "Unknown action '${ACTION}'. Supported: list, ssh"
    ;;
esac
