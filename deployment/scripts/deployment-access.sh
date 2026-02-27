#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"

usage() {
  cat <<'USAGE'
Usage:
  deployment/scripts/deployment-access.sh list --target <qemu|proxmox>
  deployment/scripts/deployment-access.sh ssh  --target <qemu|proxmox> --name <vm-name>

Notes:
  - target=qemu maps to local libvirt.
  - target=proxmox uses Proxmox API (requires PROXMOX_API_URL + PROXMOX_API_TOKEN).
  - For Terraform-state SSH, use: make deployment-ssh [target=<libvirt|proxmox>]
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

resolve_terraform_host_tuple() {
  local tf_target="$1"
  local vm_name="$2"
  local tf_dir="${REPO_ROOT}/infra/terraform/targets/${tf_target}"
  [[ -d "${tf_dir}" ]] || return 1

  if ! command -v terraform >/dev/null 2>&1; then
    local tf_local="${REPO_ROOT}/.tools/bin/terraform"
    if [[ -x "${tf_local}" ]]; then
      PATH="${REPO_ROOT}/.tools/bin:${PATH}"
    else
      return 1
    fi
  fi

  local host_json
  host_json="$(terraform -chdir="${tf_dir}" output -json host 2>/dev/null || true)"
  [[ -n "${host_json}" ]] || return 1
  check_cmd jq

  local tf_vm_name tf_ip tf_user
  tf_vm_name="$(jq -r '.vm_name // empty' <<<"${host_json}")"
  tf_ip="$(jq -r '.ip // empty' <<<"${host_json}")"
  tf_user="$(jq -r '.ssh_user // empty' <<<"${host_json}")"
  [[ -n "${tf_vm_name}" && "${tf_vm_name}" == "${vm_name}" ]] || return 1
  [[ -n "${tf_ip}" ]] || return 1
  printf '%s|%s\n' "${tf_ip}" "${tf_user}"
}

proxmox_api_get() {
  local path="$1"
  check_cmd curl
  local base token
  base="${PROXMOX_API_URL:-${DEPLOYMENT_PROXMOX_API_URL:-}}"
  token="${PROXMOX_API_TOKEN:-${DEPLOYMENT_PROXMOX_API_TOKEN:-}}"
  [[ -n "${base}" ]] || die "Missing Proxmox API URL (set PROXMOX_API_URL or DEPLOYMENT_PROXMOX_API_URL)"
  [[ -n "${token}" ]] || die "Missing Proxmox API token (set PROXMOX_API_TOKEN or DEPLOYMENT_PROXMOX_API_TOKEN)"
  base="${base%/}"
  if [[ "${base}" != */api2/json ]]; then
    base="${base}/api2/json"
  fi

  local curl_opts=(-fsSL -H "Authorization: PVEAPIToken=${token}")
  local tls_insecure="${PROXMOX_TLS_INSECURE:-${DEPLOYMENT_PROXMOX_TLS_INSECURE:-false}}"
  if [[ "${tls_insecure}" == "true" ]]; then
    curl_opts+=(-k)
  fi

  curl "${curl_opts[@]}" "${base}${path}"
}

managed_proxmox_match() {
  local vm_name="$1"
  local tags="$2"
  if managed_name_match "${vm_name}"; then
    return 0
  fi
  [[ ";${tags};" == *";compose-traeffik;"* ]]
}

resolve_proxmox_guest_ip() {
  local node="$1"
  local vmid="$2"
  check_cmd jq

  local response ip
  response="$(proxmox_api_get "/nodes/${node}/qemu/${vmid}/agent/network-get-interfaces" 2>/dev/null || true)"
  [[ -n "${response}" ]] || return 1
  ip="$(
    jq -r '
      .data.result[]?
      | select(.name != "lo")
      | .["ip-addresses"][]?
      | select(.["ip-address-type"] == "ipv4")
      | .["ip-address"]
      | select((startswith("127.") | not) and (startswith("169.254.") | not))
    ' <<<"${response}" | head -n1
  )"
  [[ -n "${ip}" ]] || return 1
  printf '%s\n' "${ip}"
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

list_proxmox() {
  check_cmd jq
  local rows
  rows="$(proxmox_api_get "/cluster/resources?type=vm" | jq -c '.data[] | select(.type=="qemu")')"
  if [[ -z "${rows}" ]]; then
    log "No Proxmox qemu VMs found"
    return 0
  fi

  local prefix="${DEPLOYMENT_MANAGED_PREFIX:-compose-traeffik-}"
  local found=0
  log "Managed filter: name prefix '${prefix}' or tag 'compose-traeffik'"
  printf '%-42s %-10s %-10s %-8s %-16s\n' "NAME" "STATE" "NODE" "VMID" "IP"

  while IFS= read -r row; do
    [[ -n "${row}" ]] || continue
    local name state node vmid tags ip
    name="$(jq -r '.name // empty' <<<"${row}")"
    state="$(jq -r '.status // "unknown"' <<<"${row}")"
    node="$(jq -r '.node // "-"' <<<"${row}")"
    vmid="$(jq -r '.vmid // "-"' <<<"${row}")"
    tags="$(jq -r '.tags // ""' <<<"${row}")"
    [[ -n "${name}" ]] || continue

    if ! managed_proxmox_match "${name}" "${tags}"; then
      continue
    fi

    found=1
    ip="-"
    if [[ "${state}" == "running" && "${node}" != "-" && "${vmid}" != "-" ]]; then
      ip="$(resolve_proxmox_guest_ip "${node}" "${vmid}" 2>/dev/null || true)"
      ip="${ip:--}"
    fi
    printf '%-42s %-10s %-10s %-8s %-16s\n' "${name}" "${state}" "${node}" "${vmid}" "${ip}"
  done <<<"${rows}"

  if [[ "${found}" -eq 0 ]]; then
    log "No managed Proxmox deployments found (prefix: ${prefix}, tag: compose-traeffik)"
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

ssh_proxmox() {
  check_cmd jq
  check_cmd ssh
  local vm_name="$1"
  [[ -n "${vm_name}" ]] || die "Missing --name for target=proxmox"

  local vm_row
  vm_row="$(
    proxmox_api_get "/cluster/resources?type=vm" \
      | jq -c --arg n "${vm_name}" '.data[] | select(.type=="qemu" and .name == $n)' \
      | head -n1
  )"
  [[ -n "${vm_row}" ]] || die "VM '${vm_name}' not found in Proxmox inventory"

  local node vmid
  node="$(jq -r '.node // empty' <<<"${vm_row}")"
  vmid="$(jq -r '.vmid // empty' <<<"${vm_row}")"
  [[ -n "${node}" && -n "${vmid}" ]] || die "Incomplete Proxmox VM metadata for '${vm_name}'"

  local ip="" source="" tf_tuple=""
  if tf_tuple="$(resolve_terraform_host_tuple "proxmox" "${vm_name}" 2>/dev/null || true)"; then
    if [[ -n "${tf_tuple}" ]]; then
      ip="${tf_tuple%%|*}"
      source="terraform(host)"
    fi
  fi
  if [[ -z "${ip}" ]]; then
    ip="$(resolve_proxmox_guest_ip "${node}" "${vmid}" 2>/dev/null || true)"
    if [[ -n "${ip}" ]]; then
      source="proxmox-agent"
    fi
  fi
  [[ -n "${ip}" ]] || die "Unable to resolve IP for '${vm_name}' (node=${node}, vmid=${vmid}). Recovery: use Proxmox web console for this VM."

  local ssh_user="${DEPLOYMENT_SSH_USER:-${DEPLOYMENT_HOST_USER:-}}"
  if [[ -z "${ssh_user}" && -n "${tf_tuple}" ]]; then
    ssh_user="${tf_tuple#*|}"
  fi
  ssh_user="${ssh_user:-ubuntu}"

  log "Resolved ${vm_name} -> ${ip} via ${source}; connecting as ${ssh_user}"
  exec ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null "${ssh_user}@${ip}"
}

ACTION="${1:-}"
if [[ "${ACTION}" == "-h" || "${ACTION}" == "--help" || -z "${ACTION}" ]]; then
  usage
  exit 0
fi
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
      list_proxmox
    fi
    ;;
  ssh)
    if [[ "${TARGET}" == "qemu" ]]; then
      ssh_qemu "${NAME}"
    else
      ssh_proxmox "${NAME}"
    fi
    ;;
  *)
    die "Unknown action '${ACTION}'. Supported: list, ssh"
    ;;
esac
