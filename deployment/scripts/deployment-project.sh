#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
CATALOG_PATH="${REPO_ROOT}/deployment/projects/catalog.json"
DEPLOYMENT_STATE_DIR="${REPO_ROOT}/deployment/state"
PROJECT_REGISTRY_PATH="${DEPLOYMENT_STATE_DIR}/projects.json"
STEPCA_ROOT_CERT_REMOTE_PATH="/opt/deployment-projects/traefik-stepca/services/step-ca/certs/root_ca.crt"

usage() {
  cat <<'USAGE'
Usage:
  deployment/scripts/deployment-project.sh list
  deployment/scripts/deployment-project.sh run --project <id> [--target <libvirt|qemu|proxmox>] [--os <selector>] [--init <openrc|systemd>] [--tls-mode <stepca-acme|letsencrypt-acme>]

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
    ((has("depends_on_projects") | not) or (.depends_on_projects | type == "array" and all(.[]; type == "string" and length > 0))) and
    (
      (.oidc? == null)
      or (
        (.oidc as $oidc
          | ($oidc | type == "object")
          and ($oidc.enabled | type == "boolean")
          and (($oidc.realm? == null) or ($oidc.realm | type == "string" and length > 0))
          and (($oidc.client_id? == null) or ($oidc.client_id | type == "string" and length > 0))
          and (($oidc.redirect_uris? == null) or ($oidc.redirect_uris | type == "array" and all(.[]; type == "string" and length > 0)))
          and (($oidc.web_origins? == null) or ($oidc.web_origins | type == "array" and all(.[]; type == "string" and length > 0)))
        )
      )
    )
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

tf_state_path_for_vm() {
  local target="$1"
  local vm_name="$2"
  printf '%s\n' "${REPO_ROOT}/infra/terraform/state/${target}/${vm_name}.tfstate"
}

default_vm_ip_for_project() {
  local project_id="$1"
  case "${project_id}" in
    traefik-stepca) printf '192.168.122.50\n' ;;
    traefik-keycloak) printf '192.168.122.51\n' ;;
    traefik-observability) printf '192.168.122.52\n' ;;
    traefik-wikijs) printf '192.168.122.53\n' ;;
    traefik-semaphoreui) printf '192.168.122.54\n' ;;
    traefik-rocketchat) printf '192.168.122.55\n' ;;
    traefik-gitlab) printf '192.168.122.56\n' ;;
    traefik-dns-bind) printf '192.168.122.57\n' ;;
    traefik-litellm) printf '192.168.122.58\n' ;;
    *)
      local hash octet
      hash="$(printf '%s' "${project_id}" | cksum | awk '{print $1}')"
      octet="$((60 + (hash % 130)))"
      printf '192.168.122.%s\n' "${octet}"
      ;;
  esac
}

default_vm_resources_for_project() {
  local project_id="$1"
  case "${project_id}" in
    traefik-gitlab)
      # GitLab omnibus needs more headroom than the other stacks.
      printf '4|6144|40\n'
      ;;
    *)
      # cpu|memory_mb|disk_gb
      printf '2|2048|20\n'
      ;;
  esac
}

resolve_host_tuple() {
  local tf_dir="$1"
  local tf_state_path="$2"
  check_cmd terraform
  [[ -d "${tf_dir}" ]] || die "Terraform directory not found: ${tf_dir}"
  local -a tf_state_args=()
  if [[ -n "${tf_state_path}" ]]; then
    tf_state_args+=("-state=${tf_state_path}")
  fi
  host_ip="$(terraform -chdir="${tf_dir}" output "${tf_state_args[@]}" -raw host_ip 2>/dev/null || true)"
  ssh_user="$(terraform -chdir="${tf_dir}" output "${tf_state_args[@]}" -raw ssh_user 2>/dev/null || true)"
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

ensure_project_registry() {
  check_cmd jq
  mkdir -p "${DEPLOYMENT_STATE_DIR}"
  if [[ ! -f "${PROJECT_REGISTRY_PATH}" ]]; then
    printf '{\n  "projects": {}\n}\n' > "${PROJECT_REGISTRY_PATH}"
  fi
  jq -e '.projects | type == "object"' "${PROJECT_REGISTRY_PATH}" >/dev/null || \
    die "Invalid project registry schema: ${PROJECT_REGISTRY_PATH}"
}

check_dependencies_registry() {
  local -a deps=("$@")
  local missing=()

  if [[ "${#deps[@]}" -eq 0 ]]; then
    return 0
  fi

  local dep
  for dep in "${deps[@]}"; do
    if ! jq -e --arg dep "${dep}" '.projects[$dep].host_ip | type == "string" and length > 0' "${PROJECT_REGISTRY_PATH}" >/dev/null; then
      missing+=("${dep}")
    fi
  done

  if [[ "${#missing[@]}" -gt 0 ]]; then
    die "Missing required project dependencies in local registry (${PROJECT_REGISTRY_PATH}): ${missing[*]}. Recovery: deploy dependencies first (make deployment-project project=<dependency>) and retry project=${PROJECT_ID}."
  fi
}

record_project_deployment() {
  local project_id="$1"
  local target="$2"
  local os_selector="$3"
  local vm_name="$4"
  local tf_state_path="$5"
  local host_ip_value="$6"
  local ssh_user_value="$7"

  ensure_project_registry
  local tmp_file
  tmp_file="$(mktemp)"
  jq \
    --arg project_id "${project_id}" \
    --arg target "${target}" \
    --arg os "${os_selector}" \
    --arg vm_name "${vm_name}" \
    --arg tf_state_path "${tf_state_path}" \
    --arg host_ip "${host_ip_value}" \
    --arg ssh_user "${ssh_user_value}" \
    --arg deployed_at "$(date -u +"%Y-%m-%dT%H:%M:%SZ")" \
    '.projects[$project_id] = {
      target: $target,
      os: $os,
      vm_name: $vm_name,
      tf_state_path: $tf_state_path,
      host_ip: $host_ip,
      ssh_user: $ssh_user,
      deployed_at: $deployed_at
    }' \
    "${PROJECT_REGISTRY_PATH}" > "${tmp_file}"
  mv "${tmp_file}" "${PROJECT_REGISTRY_PATH}"
}

registry_get_project_field() {
  local project_id="$1"
  local field="$2"
  jq -r --arg id "${project_id}" --arg field "${field}" '.projects[$id][$field] // empty' "${PROJECT_REGISTRY_PATH}"
}

fetch_stepca_root_cert_from_dependency() {
  local stepca_host_ip="$1"
  local stepca_ssh_user="$2"
  local cert_cache_path="$3"

  check_cmd scp
  mkdir -p "$(dirname "${cert_cache_path}")"

  local -a scp_opts=(
    -o StrictHostKeyChecking=no
    -o UserKnownHostsFile=/dev/null
    -P "${SSH_PORT}"
  )
  if [[ -n "${IDENTITY_PATH}" ]]; then
    scp_opts+=(-i "${IDENTITY_PATH}")
  fi

  scp "${scp_opts[@]}" \
    "${stepca_ssh_user}@${stepca_host_ip}:${STEPCA_ROOT_CERT_REMOTE_PATH}" \
    "${cert_cache_path}"
}

sync_stepca_container_host_alias() {
  local stepca_host_ip="$1"
  local stepca_ssh_user="$2"
  local alias_host="$3"
  local alias_ip="$4"

  check_cmd ssh
  local -a ssh_opts=(
    -o BatchMode=yes
    -o ConnectTimeout=8
    -o StrictHostKeyChecking=no
    -o UserKnownHostsFile=/dev/null
    -p "${SSH_PORT}"
  )
  if [[ -n "${IDENTITY_PATH}" ]]; then
    ssh_opts+=(-i "${IDENTITY_PATH}")
  fi

  ssh "${ssh_opts[@]}" "${stepca_ssh_user}@${stepca_host_ip}" \
    "sudo docker exec -u 0 step-ca sh -lc \"grep -qE '[[:space:]]${alias_host}([[:space:]]|$)' /etc/hosts || printf '%s %s\\n' '${alias_ip}' '${alias_host}' >> /etc/hosts\""
}

read_keycloak_admin_credentials() {
  local keycloak_host_ip="$1"
  local keycloak_ssh_user="$2"

  check_cmd ssh
  local -a ssh_opts=(
    -o BatchMode=yes
    -o ConnectTimeout=8
    -o StrictHostKeyChecking=no
    -o UserKnownHostsFile=/dev/null
    -p "${SSH_PORT}"
  )
  if [[ -n "${IDENTITY_PATH}" ]]; then
    ssh_opts+=(-i "${IDENTITY_PATH}")
  fi

  ssh "${ssh_opts[@]}" "${keycloak_ssh_user}@${keycloak_host_ip}" "bash -lc '
    set -euo pipefail
    env_file=/opt/deployment-projects/traefik-keycloak/.env
    admin_user=\$(grep -E \"^KEYCLOAK_ADMIN=\" \"\${env_file}\" | tail -n1 | cut -d= -f2- | xargs)
    admin_pass=\$(grep -E \"^KEYCLOAK_ADMIN_PASSWORD=\" \"\${env_file}\" | tail -n1 | cut -d= -f2- | xargs)
    [ -n \"\${admin_user}\" ] && [ -n \"\${admin_pass}\" ]
    printf \"%s|%s\\n\" \"\${admin_user}\" \"\${admin_pass}\"
  '"
}

read_keycloak_bootstrap_username() {
  local keycloak_host_ip="$1"
  local keycloak_ssh_user="$2"

  check_cmd ssh
  local -a ssh_opts=(
    -o BatchMode=yes
    -o ConnectTimeout=8
    -o StrictHostKeyChecking=no
    -o UserKnownHostsFile=/dev/null
    -p "${SSH_PORT}"
  )
  if [[ -n "${IDENTITY_PATH}" ]]; then
    ssh_opts+=(-i "${IDENTITY_PATH}")
  fi

  ssh "${ssh_opts[@]}" "${keycloak_ssh_user}@${keycloak_host_ip}" "bash -lc '
    set -euo pipefail
    env_file=/opt/deployment-projects/traefik-keycloak/.env
    bootstrap_user=\$(grep -E \"^KEYCLOAK_BOOTSTRAP_USERNAME=\" \"\${env_file}\" | tail -n1 | cut -d= -f2- | xargs || true)
    if [[ -z \"\${bootstrap_user}\" ]]; then
      bootstrap_user=jose.romero
    fi
    printf \"%s\\n\" \"\${bootstrap_user}\"
  '"
}

list_projects() {
  validate_catalog
  jq -r '.projects[].id' "${CATALOG_PATH}"
}

run_project() {
  validate_catalog
  ensure_project_registry

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
  local manifest_public_host
  manifest_repo_url="$(jq -r '.repo_url' "${manifest_path}")"
  manifest_repo_ref="$(jq -r '.repo_ref' "${manifest_path}")"
  manifest_profile="$(jq -r '.compose_profile' "${manifest_path}")"
  manifest_services="$(jq -r '.services | join(",")' "${manifest_path}")"
  manifest_tls_mode="$(jq -r '.tls_mode' "${manifest_path}")"
  manifest_public_host="$(jq -r '.public_host // empty' "${manifest_path}")"
  local effective_tls_mode="${manifest_tls_mode}"
  if [[ -n "${TLS_MODE_OVERRIDE}" ]]; then
    effective_tls_mode="${TLS_MODE_OVERRIDE}"
  fi

  log "Selected project=${PROJECT_ID} target=${TARGET_INPUT} os=${OS_SELECTOR}"
  if [[ -n "${TLS_MODE_OVERRIDE}" ]]; then
    log "Requested tls_mode override=${TLS_MODE_OVERRIDE}"
  fi
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
  local deployment_vm_ip
  deployment_vm_ip="${DEPLOYMENT_VM_IP:-$(default_vm_ip_for_project "${PROJECT_ID}")}"
  local deployment_vm_cpu deployment_vm_memory_mb deployment_vm_disk_gb
  IFS='|' read -r deployment_vm_cpu deployment_vm_memory_mb deployment_vm_disk_gb <<<"$(default_vm_resources_for_project "${PROJECT_ID}")"
  deployment_vm_cpu="${DEPLOYMENT_VM_CPU:-${deployment_vm_cpu}}"
  deployment_vm_memory_mb="${DEPLOYMENT_VM_MEMORY_MB:-${deployment_vm_memory_mb}}"
  deployment_vm_disk_gb="${DEPLOYMENT_VM_DISK_GB:-${deployment_vm_disk_gb}}"
  local deployment_tf_state_path
  deployment_tf_state_path="$(tf_state_path_for_vm "${target_normalized}" "${deployment_vm_name}")"

  local -a provision_cmd=("${REPO_ROOT}/deployment/scripts/infra-provision.sh" apply --target "${TARGET_INPUT}" --os "${OS_SELECTOR}")
  local -a wait_cmd=("${REPO_ROOT}/deployment/scripts/host-wait-ssh.sh" --target "${TARGET_INPUT}" --os "${OS_SELECTOR}")
  if [[ -n "${INIT_ARG}" ]]; then
    provision_cmd+=(--init "${INIT_ARG}")
    wait_cmd+=(--init "${INIT_ARG}")
  fi

  log "Resolved deployment VM name=${deployment_vm_name}"
  log "Resolved deployment VM IP=${deployment_vm_ip}"
  log "Resolved deployment VM resources: cpu=${deployment_vm_cpu} memory_mb=${deployment_vm_memory_mb} disk_gb=${deployment_vm_disk_gb}"
  log "Resolved Terraform state=${deployment_tf_state_path}"
  run_stage provision env \
    "DEPLOYMENT_VM_NAME=${deployment_vm_name}" \
    "DEPLOYMENT_HOSTNAME=${deployment_vm_name}" \
    "DEPLOYMENT_VM_IP=${deployment_vm_ip}" \
    "DEPLOYMENT_VM_CPU=${deployment_vm_cpu}" \
    "DEPLOYMENT_VM_MEMORY_MB=${deployment_vm_memory_mb}" \
    "DEPLOYMENT_VM_DISK_GB=${deployment_vm_disk_gb}" \
    "DEPLOYMENT_TF_STATE_PATH=${deployment_tf_state_path}" \
    "${provision_cmd[@]}"
  run_stage wait env "DEPLOYMENT_TF_STATE_PATH=${deployment_tf_state_path}" "${wait_cmd[@]}"

  resolve_host_tuple "${tf_dir}" "${deployment_tf_state_path}"
  log "Resolved host tuple: ${ssh_user}@${host_ip}:${SSH_PORT}"

  mapfile -t deps < <(jq -r '.depends_on_projects[]?' "${manifest_path}")
  if [[ "${#deps[@]}" -gt 0 ]]; then
    check_dependencies_registry "${deps[@]}"
  fi

  local stepca_dependency_host_ip=""
  local stepca_dependency_ssh_user=""
  local stepca_dependency_root_cert_path=""
  local keycloak_dependency_host_ip=""
  local keycloak_dependency_ssh_user=""
  local keycloak_dependency_admin_user=""
  local keycloak_dependency_admin_password=""
  local keycloak_bootstrap_username="jose.romero"
  local keycloak_realm="local.test"
  local keycloak_grafana_client_id="grafana"
  local keycloak_grafana_client_secret="${DEPLOYMENT_KEYCLOAK_GRAFANA_CLIENT_SECRET:-}"
  local keycloak_oidc_base_url=""
  local oidc_enabled="false"
  oidc_enabled="$(jq -r '.oidc.enabled // false' "${manifest_path}")"
  if [[ "${oidc_enabled}" == "true" ]]; then
    keycloak_realm="$(jq -r '.oidc.realm // "local.test"' "${manifest_path}")"
    keycloak_grafana_client_id="$(jq -r '.oidc.client_id // "grafana"' "${manifest_path}")"
  fi
  local has_stepca_service
  has_stepca_service="$(jq -r '.services | index("step-ca") != null' "${manifest_path}")"
  if [[ "${effective_tls_mode}" == "stepca-acme" && "${has_stepca_service}" != "true" ]]; then
    stepca_dependency_host_ip="$(registry_get_project_field "traefik-stepca" "host_ip")"
    stepca_dependency_ssh_user="$(registry_get_project_field "traefik-stepca" "ssh_user")"
    [[ -n "${stepca_dependency_host_ip}" ]] || die "Missing traefik-stepca host_ip in ${PROJECT_REGISTRY_PATH}"
    [[ -n "${stepca_dependency_ssh_user}" ]] || die "Missing traefik-stepca ssh_user in ${PROJECT_REGISTRY_PATH}"
    stepca_dependency_root_cert_path="${DEPLOYMENT_STATE_DIR}/certs/traefik-stepca-root_ca.crt"
    fetch_stepca_root_cert_from_dependency "${stepca_dependency_host_ip}" "${stepca_dependency_ssh_user}" "${stepca_dependency_root_cert_path}"
    log "Fetched StepCA root cert from dependency traefik-stepca (${stepca_dependency_host_ip})"
    local project_public_host
    if [[ -n "${manifest_public_host}" ]]; then
      project_public_host="${manifest_public_host}"
    else
      project_public_host="${PROJECT_ID}.local.test"
    fi
    local project_domain project_id_suffix whoami_public_host traefik_public_host grafana_public_host keycloak_public_host prometheus_public_host loki_public_host tempo_public_host pyroscope_public_host alloy_public_host wikijs_public_host semaphoreui_public_host rocketchat_public_host gitlab_public_host
    project_domain="${project_public_host#*.}"
    project_id_suffix="${PROJECT_ID#traefik-}"
    whoami_public_host="whoami-${project_id_suffix}.${project_domain}"
    traefik_public_host="traefik-${project_id_suffix}.${project_domain}"
    grafana_public_host="grafana.${project_domain}"
    keycloak_public_host="keycloak.${project_domain}"
    prometheus_public_host="prometheus.${project_domain}"
    loki_public_host="loki.${project_domain}"
    tempo_public_host="tempo.${project_domain}"
    pyroscope_public_host="pyroscope.${project_domain}"
    alloy_public_host="alloy.${project_domain}"
    wikijs_public_host="wikijs.${project_domain}"
    semaphoreui_public_host="semaphoreui.${project_domain}"
    rocketchat_public_host="rocketchat.${project_domain}"
    gitlab_public_host="gitlab.${project_domain}"
    sync_stepca_container_host_alias "${stepca_dependency_host_ip}" "${stepca_dependency_ssh_user}" "${project_public_host}" "${host_ip}"
    log "Synced StepCA container host alias ${project_public_host} -> ${host_ip}"
    if [[ "${manifest_services}" == *"whoami"* ]]; then
      sync_stepca_container_host_alias "${stepca_dependency_host_ip}" "${stepca_dependency_ssh_user}" "${whoami_public_host}" "${host_ip}"
      log "Synced StepCA container host alias ${whoami_public_host} -> ${host_ip}"
    fi
    if [[ "${manifest_services}" == *"traefik"* ]]; then
      sync_stepca_container_host_alias "${stepca_dependency_host_ip}" "${stepca_dependency_ssh_user}" "${traefik_public_host}" "${host_ip}"
      log "Synced StepCA container host alias ${traefik_public_host} -> ${host_ip}"
    fi
    if [[ "${manifest_services}" == *"grafana"* ]]; then
      sync_stepca_container_host_alias "${stepca_dependency_host_ip}" "${stepca_dependency_ssh_user}" "${grafana_public_host}" "${host_ip}"
      log "Synced StepCA container host alias ${grafana_public_host} -> ${host_ip}"
    fi
    if [[ "${manifest_services}" == *"keycloak"* ]]; then
      sync_stepca_container_host_alias "${stepca_dependency_host_ip}" "${stepca_dependency_ssh_user}" "${keycloak_public_host}" "${host_ip}"
      log "Synced StepCA container host alias ${keycloak_public_host} -> ${host_ip}"
    fi
    if [[ "${manifest_services}" == *"prometheus"* ]]; then
      sync_stepca_container_host_alias "${stepca_dependency_host_ip}" "${stepca_dependency_ssh_user}" "${prometheus_public_host}" "${host_ip}"
      log "Synced StepCA container host alias ${prometheus_public_host} -> ${host_ip}"
    fi
    if [[ "${manifest_services}" == *"loki"* ]]; then
      sync_stepca_container_host_alias "${stepca_dependency_host_ip}" "${stepca_dependency_ssh_user}" "${loki_public_host}" "${host_ip}"
      log "Synced StepCA container host alias ${loki_public_host} -> ${host_ip}"
    fi
    if [[ "${manifest_services}" == *"tempo"* ]]; then
      sync_stepca_container_host_alias "${stepca_dependency_host_ip}" "${stepca_dependency_ssh_user}" "${tempo_public_host}" "${host_ip}"
      log "Synced StepCA container host alias ${tempo_public_host} -> ${host_ip}"
    fi
    if [[ "${manifest_services}" == *"pyroscope"* ]]; then
      sync_stepca_container_host_alias "${stepca_dependency_host_ip}" "${stepca_dependency_ssh_user}" "${pyroscope_public_host}" "${host_ip}"
      log "Synced StepCA container host alias ${pyroscope_public_host} -> ${host_ip}"
    fi
    if [[ "${manifest_services}" == *"alloy"* ]]; then
      sync_stepca_container_host_alias "${stepca_dependency_host_ip}" "${stepca_dependency_ssh_user}" "${alloy_public_host}" "${host_ip}"
      log "Synced StepCA container host alias ${alloy_public_host} -> ${host_ip}"
    fi
    if [[ "${manifest_services}" == *"wikijs"* ]]; then
      sync_stepca_container_host_alias "${stepca_dependency_host_ip}" "${stepca_dependency_ssh_user}" "${wikijs_public_host}" "${host_ip}"
      log "Synced StepCA container host alias ${wikijs_public_host} -> ${host_ip}"
    fi
    if [[ "${manifest_services}" == *"semaphoreui"* ]]; then
      sync_stepca_container_host_alias "${stepca_dependency_host_ip}" "${stepca_dependency_ssh_user}" "${semaphoreui_public_host}" "${host_ip}"
      log "Synced StepCA container host alias ${semaphoreui_public_host} -> ${host_ip}"
    fi
    if [[ "${manifest_services}" == *"rocketchat"* ]]; then
      sync_stepca_container_host_alias "${stepca_dependency_host_ip}" "${stepca_dependency_ssh_user}" "${rocketchat_public_host}" "${host_ip}"
      log "Synced StepCA container host alias ${rocketchat_public_host} -> ${host_ip}"
    fi
    if [[ "${manifest_services}" == *"gitlab"* ]]; then
      sync_stepca_container_host_alias "${stepca_dependency_host_ip}" "${stepca_dependency_ssh_user}" "${gitlab_public_host}" "${host_ip}"
      log "Synced StepCA container host alias ${gitlab_public_host} -> ${host_ip}"
    fi
  fi

  if jq -e '.depends_on_projects | index("traefik-keycloak") != null' "${manifest_path}" >/dev/null 2>&1; then
    keycloak_dependency_host_ip="$(registry_get_project_field "traefik-keycloak" "host_ip")"
    keycloak_dependency_ssh_user="$(registry_get_project_field "traefik-keycloak" "ssh_user")"
    [[ -n "${keycloak_dependency_host_ip}" ]] || die "Missing traefik-keycloak host_ip in ${PROJECT_REGISTRY_PATH}"
    [[ -n "${keycloak_dependency_ssh_user}" ]] || die "Missing traefik-keycloak ssh_user in ${PROJECT_REGISTRY_PATH}"

    local project_public_host_for_oidc project_domain_for_oidc
    if [[ -n "${manifest_public_host}" ]]; then
      project_public_host_for_oidc="${manifest_public_host}"
    else
      project_public_host_for_oidc="${PROJECT_ID}.local.test"
    fi
    project_domain_for_oidc="${project_public_host_for_oidc#*.}"
    keycloak_oidc_base_url="https://keycloak.${project_domain_for_oidc}"

    local keycloak_admin_pair
    keycloak_admin_pair="$(read_keycloak_admin_credentials "${keycloak_dependency_host_ip}" "${keycloak_dependency_ssh_user}")"
    keycloak_dependency_admin_user="${keycloak_admin_pair%%|*}"
    keycloak_dependency_admin_password="${keycloak_admin_pair#*|}"
    keycloak_bootstrap_username="$(read_keycloak_bootstrap_username "${keycloak_dependency_host_ip}" "${keycloak_dependency_ssh_user}")"
    [[ -n "${keycloak_dependency_admin_user}" ]] || die "Missing KEYCLOAK_ADMIN from traefik-keycloak dependency."
    [[ -n "${keycloak_dependency_admin_password}" ]] || die "Missing KEYCLOAK_ADMIN_PASSWORD from traefik-keycloak dependency."
    [[ -n "${keycloak_bootstrap_username}" ]] || die "Missing KEYCLOAK_BOOTSTRAP_USERNAME from traefik-keycloak dependency."
  fi

  run_stage system_bootstrap run_ansible_playbook "${REPO_ROOT}/deployment/ansible/playbooks/system_bootstrap.yml"

  run_stage project_deploy run_ansible_playbook \
    "${REPO_ROOT}/deployment/ansible/playbooks/project_deploy.yml" \
    --extra-vars "deployment_project_manifest=${manifest_path}" \
    --extra-vars "deployment_project_target=${TARGET_INPUT}" \
    --extra-vars "deployment_project_os=${OS_SELECTOR}" \
    --extra-vars "deployment_project_tls_mode_override=${TLS_MODE_OVERRIDE}" \
    --extra-vars "deployment_project_stepca_dependency_host_ip=${stepca_dependency_host_ip}" \
    --extra-vars "deployment_project_stepca_dependency_root_cert_path=${stepca_dependency_root_cert_path}" \
    --extra-vars "deployment_project_keycloak_dependency_host_ip=${keycloak_dependency_host_ip}" \
    --extra-vars "deployment_project_keycloak_oidc_base_url=${keycloak_oidc_base_url}" \
    --extra-vars "deployment_project_keycloak_realm=${keycloak_realm}" \
    --extra-vars "deployment_project_keycloak_grafana_client_id=${keycloak_grafana_client_id}" \
    --extra-vars "deployment_project_keycloak_grafana_client_secret=${keycloak_grafana_client_secret}" \
    --extra-vars "deployment_project_keycloak_admin_username=${keycloak_dependency_admin_user}" \
    --extra-vars "deployment_project_keycloak_admin_password=${keycloak_dependency_admin_password}" \
    --extra-vars "deployment_project_keycloak_bootstrap_username=${keycloak_bootstrap_username}"

  record_project_deployment "${PROJECT_ID}" "${TARGET_INPUT}" "${OS_SELECTOR}" "${deployment_vm_name}" "${deployment_tf_state_path}" "${host_ip}" "${ssh_user}"
  log "Project deployment finished successfully for project=${PROJECT_ID}"
}

COMMAND=""
PROJECT_ID=""
TARGET_INPUT="qemu"
OS_SELECTOR="ubuntu"
INIT_ARG=""
IDENTITY_PATH="${DEPLOYMENT_SSH_PRIVATE_KEY_PATH:-}"
SSH_PORT="${DEPLOYMENT_SSH_PORT:-22}"
TLS_MODE_OVERRIDE=""

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
    --tls-mode)
      [[ $# -ge 2 ]] || die "--tls-mode requires a value"
      TLS_MODE_OVERRIDE="$2"
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
