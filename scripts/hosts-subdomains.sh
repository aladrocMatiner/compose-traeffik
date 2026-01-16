#!/bin/bash
# File: scripts/hosts-subdomains.sh
#
# Manage loopback subdomain mappings for local development.
#
# Usage:
#   ./scripts/hosts-subdomains.sh [--env-file <path>] [--hosts-file <path>] [--dry-run] [--project-tag <tag>] <generate|apply|remove|status>
#
# Requirements:
#   BASE_DOMAIN, LOOPBACK_X
# Optional:
#   ENDPOINTS, HOSTS_FILE, ENV_FILE

set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
REPO_ROOT=$(cd "${SCRIPT_DIR}/.." && pwd)

SUBCOMMAND=""
ENV_FILE_FLAG=""
HOSTS_FILE_FLAG=""
DRY_RUN=false
PROJECT_TAG="edge-stack"

print_usage() {
    cat << 'USAGE'
Usage:
  ./scripts/hosts-subdomains.sh [--env-file <path>] [--hosts-file <path>] [--dry-run] [--project-tag <tag>] <generate|apply|remove|status>

Subcommands:
  generate   Print managed hosts block to stdout
  apply      Insert or update managed block in hosts file
  remove     Remove managed block from hosts file
  status     Show whether managed block exists and list entries

Flags:
  --env-file <path>   Path to env file (default: ENV_FILE, ./.env, or ./.env.example)
  --hosts-file <path> Path to hosts file (default: HOSTS_FILE or /etc/hosts)
  --dry-run           Print intended changes without modifying hosts file
  --project-tag <tag> Override the project tag used in block markers
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

resolve_hosts_file() {
    if [ -n "$HOSTS_FILE_FLAG" ]; then
        echo "$HOSTS_FILE_FLAG"
        return
    fi
    if [ -n "${HOSTS_FILE:-}" ]; then
        echo "$HOSTS_FILE"
        return
    fi
    echo "/etc/hosts"
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

build_block() {
    local -a endpoints=("$@")

    if [ "${#endpoints[@]}" -eq 0 ]; then
        fail "No endpoints available. Set ENDPOINTS in the env file."
    fi

    local block_begin="# BEGIN ${PROJECT_TAG} HOSTS"
    local block_end="# END ${PROJECT_TAG} HOSTS"
    local lines=()
    local y=1
    local entry

    if [ "${#endpoints[@]}" -gt 254 ]; then
        fail "Too many endpoints (${#endpoints[@]}). Maximum is 254."
    fi

    for entry in "${endpoints[@]}"; do
        if [ "$y" -gt 254 ]; then
            fail "Too many endpoints for loopback assignment."
        fi
        lines+=("127.0.${LOOPBACK_X}.${y} ${entry}.${BASE_DOMAIN}")
        y=$((y + 1))
    done

    printf '%s\n' "$block_begin" "# Managed by scripts/hosts-subdomains.sh" "${lines[@]}" "$block_end"
}

block_exists() {
    local hosts_file="$1"
    local block_begin="# BEGIN ${PROJECT_TAG} HOSTS"
    grep -q "^${block_begin}$" "$hosts_file"
}

apply_block() {
    local hosts_file="$1"
    local block="$2"
    local block_begin="# BEGIN ${PROJECT_TAG} HOSTS"
    local block_end="# END ${PROJECT_TAG} HOSTS"
    local tmp_file
    local block_file

    if [ ! -f "$hosts_file" ]; then
        fail "Hosts file not found: ${hosts_file}"
    fi

    if [ "$DRY_RUN" = true ]; then
        log "DRY RUN: would apply managed block to ${hosts_file}"
        log "${block}"
        return
    fi

    tmp_file=$(mktemp)
    block_file=$(mktemp)
    printf '%s\n' "$block" > "$block_file"

    if block_exists "$hosts_file"; then
        awk -v begin="$block_begin" -v end="$block_end" -v block_file="$block_file" '
            BEGIN {
                while ((getline line < block_file) > 0) {
                    block = block line "\n"
                }
                close(block_file)
            }
            $0 == begin { printf "%s", block; in_block=1; next }
            $0 == end { in_block=0; next }
            !in_block { print }
        ' "$hosts_file" > "$tmp_file"
    else
        cat "$hosts_file" > "$tmp_file"
        printf '\n%s\n' "$block" >> "$tmp_file"
    fi

    mv "$tmp_file" "$hosts_file"
    rm -f "$block_file"
}

remove_block() {
    local hosts_file="$1"
    local block_begin="# BEGIN ${PROJECT_TAG} HOSTS"
    local block_end="# END ${PROJECT_TAG} HOSTS"
    local tmp_file

    if [ ! -f "$hosts_file" ]; then
        fail "Hosts file not found: ${hosts_file}"
    fi

    if [ "$DRY_RUN" = true ]; then
        if block_exists "$hosts_file"; then
            log "DRY RUN: would remove managed block from ${hosts_file}"
            awk -v begin="$block_begin" -v end="$block_end" '
                $0 == begin { in_block=1; next }
                $0 == end { in_block=0; next }
                in_block { print }
            ' "$hosts_file"
        else
            log "DRY RUN: no managed block found in ${hosts_file}"
        fi
        return
    fi

    if ! block_exists "$hosts_file"; then
        log "No managed block found in ${hosts_file}."
        return
    fi

    tmp_file=$(mktemp)
    awk -v begin="$block_begin" -v end="$block_end" '
        $0 == begin { in_block=1; next }
        $0 == end { in_block=0; next }
        !in_block { print }
    ' "$hosts_file" > "$tmp_file"

    mv "$tmp_file" "$hosts_file"
}

status_block() {
    local hosts_file="$1"
    local block_begin="# BEGIN ${PROJECT_TAG} HOSTS"
    local block_end="# END ${PROJECT_TAG} HOSTS"

    if [ ! -f "$hosts_file" ]; then
        fail "Hosts file not found: ${hosts_file}"
    fi

    if block_exists "$hosts_file"; then
        log "Managed block present in ${hosts_file}"
        awk -v begin="$block_begin" -v end="$block_end" '
            $0 == begin { in_block=1; next }
            $0 == end { in_block=0; next }
            in_block && $0 !~ /^#/ { print }
        ' "$hosts_file"
    else
        log "Managed block not found in ${hosts_file}"
    fi
}

# Parse arguments
while [ "$#" -gt 0 ]; do
    case "$1" in
        generate|apply|remove|status)
            if [ -n "$SUBCOMMAND" ]; then
                fail "Multiple subcommands provided."
            fi
            SUBCOMMAND="$1"
            shift
            ;;
        --env-file)
            ENV_FILE_FLAG="$2"
            shift 2
            ;;
        --hosts-file)
            HOSTS_FILE_FLAG="$2"
            shift 2
            ;;
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --project-tag)
            PROJECT_TAG="$2"
            shift 2
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

if [ -z "$SUBCOMMAND" ]; then
    print_usage
    exit 1
fi

PROJECT_TAG=$(trim "$PROJECT_TAG")
PROJECT_TAG=${PROJECT_TAG// /-}

ENV_FILE_PATH=$(resolve_env_file)
HOSTS_FILE_PATH=$(resolve_hosts_file)

load_env_file "$ENV_FILE_PATH"
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

block=$(build_block "${endpoints[@]}")

case "$SUBCOMMAND" in
    generate)
        printf '%s\n' "$block"
        ;;
    apply)
        apply_block "$HOSTS_FILE_PATH" "$block"
        ;;
    remove)
        remove_block "$HOSTS_FILE_PATH"
        ;;
    status)
        status_block "$HOSTS_FILE_PATH"
        ;;
    *)
        fail "Unknown subcommand: ${SUBCOMMAND}"
        ;;
esac
