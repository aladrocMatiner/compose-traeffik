#!/bin/bash
# File: scripts/dns-configure-ubuntu.sh
#
# Configure Ubuntu 24.04 systemd-resolved for split-DNS routing of BASE_DOMAIN.
#
# Usage:
#   ./scripts/dns-configure-ubuntu.sh [--env-file <path>] [--dry-run] <apply|remove|status>
#

set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
REPO_ROOT=$(cd "${SCRIPT_DIR}/.." && pwd)

ENV_FILE_FLAG=""
DRY_RUN=false
SUBCOMMAND=""

print_usage() {
    cat << 'USAGE'
Usage:
  ./scripts/dns-configure-ubuntu.sh [--env-file <path>] [--dry-run] <apply|remove|status>

Subcommands:
  apply   Configure systemd-resolved split-DNS for BASE_DOMAIN
  remove  Revert systemd-resolved configuration for the default interface
  status  Show current systemd-resolved status for the default interface

Options:
  --env-file <path>  Path to env file (default: ENV_FILE, ./.env, or ./.env.example)
  --dry-run          Print intended resolvectl commands without executing
USAGE
}

log() {
    echo "$1"
}

fail() {
    echo "ERROR: $1" >&2
    exit 1
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
}

get_default_iface() {
    local iface
    iface=$(ip route show default 0.0.0.0/0 | awk '{print $5; exit}')
    if [ -z "$iface" ]; then
        fail "Could not detect default network interface."
    fi
    printf '%s' "$iface"
}

run_or_print() {
    if [ "$DRY_RUN" = true ]; then
        log "DRY RUN: $*"
        return
    fi
    "$@"
}

print_verify_instructions() {
    log "Verify with:"
    log "  resolvectl status"
    log "  dig @127.0.0.1 dns.${BASE_DOMAIN}"
    log "  getent hosts whoami.${BASE_DOMAIN}"
}

# Parse arguments
while [ "$#" -gt 0 ]; do
    case "$1" in
        apply|remove|status)
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

if [ -z "$SUBCOMMAND" ]; then
    print_usage
    exit 1
fi

ENV_FILE_PATH=$(resolve_env_file)
load_env_file "$ENV_FILE_PATH"
validate_required_env

if ! command -v resolvectl >/dev/null 2>&1; then
    fail "resolvectl not found. Install systemd-resolved or configure DNS manually."
fi

IFACE=$(get_default_iface)

case "$SUBCOMMAND" in
    apply)
        log "Configuring split-DNS for ${BASE_DOMAIN} on ${IFACE}..."
        run_or_print resolvectl dns "$IFACE" 127.0.0.1
        run_or_print resolvectl domain "$IFACE" "~${BASE_DOMAIN}"
        print_verify_instructions
        ;;
    remove)
        log "Reverting systemd-resolved settings on ${IFACE}..."
        run_or_print resolvectl revert "$IFACE"
        print_verify_instructions
        ;;
    status)
        log "systemd-resolved status for ${IFACE}:"
        resolvectl status "$IFACE"
        print_verify_instructions
        ;;
    *)
        fail "Unknown subcommand: ${SUBCOMMAND}"
        ;;
esac
