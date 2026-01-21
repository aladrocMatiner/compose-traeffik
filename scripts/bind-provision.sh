#!/bin/bash
# File: scripts/bind-provision.sh
#
# Generate a BIND zone file from ENDPOINTS for local development.
#
# Usage:
#   ./scripts/bind-provision.sh [--env-file <path>] [--dry-run]
#

set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
REPO_ROOT=$(cd "${SCRIPT_DIR}/.." && pwd)

ENV_FILE_FLAG=""
DRY_RUN=false

print_usage() {
    cat << 'USAGE'
Usage:
  ./scripts/bind-provision.sh [--env-file <path>] [--dry-run]

Options:
  --env-file <path>  Path to env file (default: ENV_FILE, ./.env, or ./.env.example)
  --dry-run          Print the zone file content without writing to disk
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
    if [ -z "${ENDPOINTS:-}" ]; then
        fail "ENDPOINTS is not set. Update the env file or set --env-file."
    fi
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
        if [ "$entry" = "bind" ]; then
            continue
        fi
        if [[ " ${seen[*]} " == *" ${entry} "* ]]; then
            continue
        fi
        seen+=("$entry")
        results+=("$entry")
    done

    if [ "${#results[@]}" -eq 0 ]; then
        fail "ENDPOINTS did not include any usable entries."
    fi

    printf '%s\n' "${results[@]}"
}

build_zone() {
    local base_domain="$1"
    local loopback_x="$2"
    shift 2
    local -a endpoints=("$@")
    local serial
    local y=1

    serial=$(date -u +%Y%m%d%H)

    cat <<ZONE
\$TTL 1h
@   IN  SOA ns1.${base_domain}. hostmaster.${base_domain}. (
        ${serial} ; serial
        1h ; refresh
        15m ; retry
        1w ; expire
        1h ; minimum
)

@   IN  NS  ns1.${base_domain}.
ns1 IN  A   127.0.${loopback_x}.254
bind IN  A  127.0.${loopback_x}.254
ZONE

    for endpoint in "${endpoints[@]}"; do
        printf '%s IN  A   127.0.%s.%s\n' "$endpoint" "$loopback_x" "$y"
        y=$((y + 1))
    done
}

while [ "$#" -gt 0 ]; do
    case "$1" in
        --env-file)
            if [ -n "${2:-}" ]; then
                ENV_FILE_FLAG="$2"
                shift 2
            else
                fail "Missing value for --env-file."
            fi
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
validate_required_env

mapfile -t ENDPOINT_LIST < <(parse_endpoints_from_env "$ENDPOINTS")

ZONE_CONTENT=$(build_zone "$BASE_DOMAIN" "$LOOPBACK_X" "${ENDPOINT_LIST[@]}")
ZONE_DIR="${REPO_ROOT}/services/dns-bind/zones"
ZONE_FILE="${ZONE_DIR}/db.${BASE_DOMAIN}"

if [ "$DRY_RUN" = true ]; then
    printf '%s\n' "$ZONE_CONTENT"
    exit 0
fi

mkdir -p "$ZONE_DIR"
printf '%s\n' "$ZONE_CONTENT" > "$ZONE_FILE"
log "Wrote zone file: ${ZONE_FILE}"
