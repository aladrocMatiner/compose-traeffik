#!/bin/bash
# File: scripts/common.sh
#
# Common functions and utilities for the Traefik Docker Compose Edge Stack scripts.
#

# --- Logging Functions ---
log_info() {
    echo "INFO: $1"
}

log_success() {
    echo "SUCCESS: $1"
}

log_warn() {
    echo "WARN: $1"
}

log_error() {
    echo "ERROR: $1" >&2
    exit 1
}

# --- Environment Variable Handling ---
load_env() {
    if [ -f .env ]; then
        log_info "Loading environment variables from .env"
        # Export variables from .env
        set -a
        . ./.env
        set +a
    else
        log_warn "'.env' file not found. Ensure it exists or create from '.env.example'."
    fi
}

check_env_var() {
    local var_name="$1"
    if [ -z "${!var_name}" ]; then
        log_error "Environment variable '${var_name}' is not set. Please set it in your .env file."
    fi
}

# --- Command Existence Check ---
check_command() {
    local cmd_name="$1"
    if ! command -v "$cmd_name" &> /dev/null; then
        log_error "Command '${cmd_name}' not found. Please install it."
    fi
}

check_docker_compose() {
    check_command "docker"
    if ! docker compose version >/dev/null 2>&1; then
        log_error "Docker Compose plugin not available. Please install Docker Compose v2."
    fi
}
