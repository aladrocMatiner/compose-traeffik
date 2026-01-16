#!/bin/bash
# File: scripts/dns-provision.sh
#
# Provision DNS records in Technitium DNS Server based on repo endpoints.
#
# Usage:
#   ./scripts/dns-provision.sh [--env-file <path>] [--dry-run]
#

set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
REPO_ROOT=$(cd "${SCRIPT_DIR}/.." && pwd)

ENV_FILE_FLAG=""
DRY_RUN=false

print_usage() {
    cat << 'USAGE'
Usage:
  ./scripts/dns-provision.sh [--env-file <path>] [--dry-run]

Options:
  --env-file <path>  Path to env file (default: ENV_FILE, ./.env, or ./.env.example)
  --dry-run          Print intended actions without calling the DNS API
USAGE
}

log() {
    echo "$1"
}

fail() {
    echo "ERROR: $1" >&2
    exit 1
}

trim() {
    local value="$1"
    value="${value#${value%%[![:space:]]*}}"
    value="${value%${value##*[![:space:]]}}"
    printf '%s' "$value"
}

resolve_env_file() {
    if [ -n "$ENV_FILE_FLAG" ]; then
        echo "$ENV_FILE_FLAG"
        return
    fi
    if [ -n "${ENV_FILE:-}" ]; then
        echo "$ENV_FILE"
        return
    fi
    if [ -f "${REPO_ROOT}/.env" ]; then
        echo "${REPO_ROOT}/.env"
        return
    fi
    if [ -f "${REPO_ROOT}/.env.example" ]; then
        echo "${REPO_ROOT}/.env.example"
        return
    fi
    fail "No env file found. Provide --env-file or set ENV_FILE."
}

load_env_file() {
    local file="$1"
    if [ ! -f "$file" ]; then
        fail "Env file not found: $file"
    fi
    # shellcheck disable=SC1090
    set -a
    . "$file"
    set +a
}

validate_required_env() {
    if [ -z "${BASE_DOMAIN:-}" ]; then
        fail "BASE_DOMAIN is not set. Update the env file or set --env-file."
    fi
    if [ -z "${LOOPBACK_X:-}" ]; then
        fail "LOOPBACK_X is not set. Update the env file or set --env-file."
    fi
    if ! [[ "$LOOPBACK_X" =~ ^[0-9]+$ ]]; then
        fail "LOOPBACK_X must be an integer between 0 and 255."
    fi
    if [ "$LOOPBACK_X" -lt 0 ] || [ "$LOOPBACK_X" -gt 255 ]; then
        fail "LOOPBACK_X must be between 0 and 255."
    fi
    if [ "$DRY_RUN" = false ] && [ -z "${DNS_ADMIN_PASSWORD:-}" ]; then
        fail "DNS_ADMIN_PASSWORD is not set. Update the env file before provisioning."
    fi
}

normalize_endpoint() {
    local host="$1"
    local base_domain_value="$2"

    if [ -n "$base_domain_value" ]; then
        host="${host%.${base_domain_value}}"
    fi
    host="${host%.\${DEV_DOMAIN}}"
    host="${host%.\${BASE_DOMAIN}}"
    if [ -n "${DEV_DOMAIN:-}" ]; then
        host="${host%.${DEV_DOMAIN}}"
    fi

    if [[ "$host" == *.* ]]; then
        host="${host%%.*}"
    fi

    printf '%s' "$host"
}

parse_endpoints_from_env() {
    local raw="$1"
    local -a results=()
    local -a seen=()
    local entry

    IFS=',' read -r -a entries <<< "$raw"
    for entry in "${entries[@]}"; do
        entry=$(trim "$entry")
        if [ -z "$entry" ]; then
            continue
        fi
        if [[ " ${seen[*]} " == *" ${entry} "* ]]; then
            continue
        fi
        seen+=("$entry")
        results+=("$entry")
    done

    printf '%s\n' "${results[@]}"
}

parse_endpoints_from_compose() {
    local -a hosts=()
    local line
    local compose_file

    for compose_file in "${REPO_ROOT}/services"/*/compose.yml; do
        if [ ! -f "$compose_file" ]; then
            continue
        fi

        while IFS= read -r line; do
            line="${line#Host(\`}"
            line="${line%\`)}"
            if [ -n "$line" ]; then
                hosts+=("$line")
            fi
        done < <(grep -Eo 'Host\(`[^`]+`\)' "$compose_file" || true)
    done

    if [ "${#hosts[@]}" -eq 0 ]; then
        fail "No Host() labels found in service compose files. Set ENDPOINTS in the env file."
    fi

    local -a endpoints=()
    local -a seen=()
    local host
    local endpoint

    for host in "${hosts[@]}"; do
        endpoint=$(normalize_endpoint "$host" "${BASE_DOMAIN:-}")
        if [ -z "$endpoint" ]; then
            continue
        fi
        if [[ " ${seen[*]} " == *" ${endpoint} "* ]]; then
            continue
        fi
        seen+=("$endpoint")
        endpoints+=("$endpoint")
    done

    if [ "${#endpoints[@]}" -eq 0 ]; then
        fail "No endpoints derived from service compose files. Set ENDPOINTS in the env file."
    fi

    printf '%s\n' "${endpoints[@]}"
}

build_records() {
    local -a endpoints=("$@")
    local -a records=()
    local y=1
    local endpoint

    if [ "${#endpoints[@]}" -gt 253 ]; then
        fail "Too many endpoints (${#endpoints[@]}). Maximum is 253 with dns reservation."
    fi

    for endpoint in "${endpoints[@]}"; do
        records+=("${endpoint}.${BASE_DOMAIN}|127.0.${LOOPBACK_X}.${y}")
        y=$((y + 1))
    done

    printf '%s\n' "${records[@]}"
}

require_ok() {
    local response="$1"
    if ! echo "$response" | grep -q '"status":"ok"'; then
        fail "DNS API call failed: ${response}"
    fi
}

extract_token() {
    local response="$1"
    local token
    token=$(echo "$response" | sed -n 's/.*"token":"\([^"]*\)".*/\1/p' | head -n 1)
    if [ -z "$token" ]; then
        fail "Failed to parse token from DNS API response."
    fi
    printf '%s' "$token"
}

api_get() {
    local path="$1"
    shift
    docker run --rm --network "${DNS_DOCKER_NETWORK}" curlimages/curl:8.5.0 -sS -G "${DNS_API_BASE_URL}${path}" "$@"
}

# Parse arguments
while [ "$#" -gt 0 ]; do
    case "$1" in
        --env-file)
            ENV_FILE_FLAG="$2"
            shift 2
            ;;
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        -h|--help)
            print_usage
            exit 0
            ;;
        *)
            fail "Unknown argument: $1"
            ;;
    esac
done

ENV_FILE_PATH=$(resolve_env_file)
load_env_file "$ENV_FILE_PATH"

DNS_UI_HOSTNAME=${DNS_UI_HOSTNAME:-dns}
DNS_API_BASE_URL=${DNS_API_BASE_URL:-http://dns:5380}
DNS_DOCKER_NETWORK=${DNS_DOCKER_NETWORK:-traefik-proxy}

validate_required_env

endpoints=()
if [ -n "${ENDPOINTS:-}" ]; then
    while IFS= read -r endpoint; do
        endpoints+=("$endpoint")
    done < <(parse_endpoints_from_env "$ENDPOINTS")
else
    while IFS= read -r endpoint; do
        endpoints+=("$endpoint")
    done < <(parse_endpoints_from_compose)
    IFS=$'\n' endpoints=($(printf '%s\n' "${endpoints[@]}" | sort))
    unset IFS
fi

filtered_endpoints=()
for endpoint in "${endpoints[@]}"; do
    if [ "$endpoint" = "$DNS_UI_HOSTNAME" ]; then
        continue
    fi
    filtered_endpoints+=("$endpoint")
done

mapfile -t records < <(build_records "${filtered_endpoints[@]}")

dns_ui_record="${DNS_UI_HOSTNAME}.${BASE_DOMAIN}|127.0.${LOOPBACK_X}.254"

if [ "$DRY_RUN" = true ]; then
    log "DRY RUN: would ensure zone ${BASE_DOMAIN}"
    for record in "${records[@]}"; do
        log "DRY RUN: would add A record ${record%|*} -> ${record#*|}"
    done
    log "DRY RUN: would add A record ${dns_ui_record%|*} -> ${dns_ui_record#*|}"
    exit 0
fi

if ! command -v docker >/dev/null 2>&1; then
    fail "docker is required to reach the DNS API."
fi

log "Logging into Technitium DNS API..."
login_response=$(api_get "/api/user/login" \
    --data-urlencode "user=admin" \
    --data-urlencode "pass=${DNS_ADMIN_PASSWORD}")
require_ok "$login_response"
TOKEN=$(extract_token "$login_response")

zones_response=$(api_get "/api/zones/list" --data-urlencode "token=${TOKEN}")
require_ok "$zones_response"

if ! echo "$zones_response" | grep -q "\"name\":\"${BASE_DOMAIN}\""; then
    log "Creating zone ${BASE_DOMAIN}..."
    create_response=$(api_get "/api/zones/create" \
        --data-urlencode "token=${TOKEN}" \
        --data-urlencode "zone=${BASE_DOMAIN}" \
        --data-urlencode "type=Primary")
    require_ok "$create_response"
else
    log "Zone ${BASE_DOMAIN} already exists."
fi

for record in "${records[@]}"; do
    fqdn="${record%|*}"
    ip="${record#*|}"
    log "Upserting A record ${fqdn} -> ${ip}"
    record_response=$(api_get "/api/zones/records/add" \
        --data-urlencode "token=${TOKEN}" \
        --data-urlencode "domain=${fqdn}" \
        --data-urlencode "zone=${BASE_DOMAIN}" \
        --data-urlencode "type=A" \
        --data-urlencode "ipAddress=${ip}" \
        --data-urlencode "overwrite=true")
    require_ok "$record_response"
done

log "Upserting A record ${dns_ui_record%|*} -> ${dns_ui_record#*|}"
record_response=$(api_get "/api/zones/records/add" \
    --data-urlencode "token=${TOKEN}" \
    --data-urlencode "domain=${dns_ui_record%|*}" \
    --data-urlencode "zone=${BASE_DOMAIN}" \
    --data-urlencode "type=A" \
    --data-urlencode "ipAddress=${dns_ui_record#*|}" \
    --data-urlencode "overwrite=true")
require_ok "$record_response"

log "DNS provisioning complete for ${BASE_DOMAIN}."
