#!/bin/bash
# File: scripts/stepca-bootstrap.sh
#
# Bootstraps the Smallstep 'step-ca' server.
# This initializes the CA, creates an admin provisioner, and enables the ACME provisioner.
# Requires the 'stepca' Docker Compose profile to be active and the 'step-ca' service running.
#
# Usage: ./scripts/stepca-bootstrap.sh
#
# IMPORTANT: Passwords (STEP_CA_ADMIN_PROVISIONER_PASSWORD, STEP_CA_PASSWORD)
#            are read from the .env file and only used during this bootstrap process.
#            The running step-ca service does NOT use these environment variables.
#

set -euo pipefail

SCRIPT_DIR=$(dirname "$0")
# shellcheck source=scripts/common.sh
. "$SCRIPT_DIR/common.sh"

load_env
check_env_var "DEV_DOMAIN"
check_env_var "STEP_CA_ADMIN_PROVISIONER_PASSWORD"
check_env_var "STEP_CA_PASSWORD"

CA_NAME="${CA_NAME:-${STEP_CA_NAME:-}}"
if [ -z "${CA_NAME}" ]; then
    log_error "CA_NAME or STEP_CA_NAME must be set in .env."
fi

CA_DNS_RAW="${CA_DNS:-}"
CA_IPS_RAW="${CA_IPS:-}"
STEP_CA_DNS="${STEP_CA_DNS:-}"

if [ -z "${CA_DNS_RAW}" ] && [ -z "${CA_IPS_RAW}" ]; then
    if [ -z "${STEP_CA_DNS}" ]; then
        STEP_CA_DNS="step-ca,localhost,127.0.0.1,step-ca.${DEV_DOMAIN}"
        log_warn "CA_DNS/CA_IPS and STEP_CA_DNS are not set. Defaulting to '${STEP_CA_DNS}'."
    fi
    CA_DNS_LIST="${STEP_CA_DNS}"
else
    CA_DNS_LIST="${CA_DNS_RAW}"
    if [ -n "${CA_IPS_RAW}" ]; then
        if [ -n "${CA_DNS_LIST}" ]; then
            CA_DNS_LIST="${CA_DNS_LIST},${CA_IPS_RAW}"
        else
            CA_DNS_LIST="${CA_IPS_RAW}"
        fi
    fi
fi

if [ -z "${CA_DNS_LIST}" ]; then
    log_error "CA_DNS/CA_IPS or STEP_CA_DNS is empty. Set it in .env before bootstrapping."
fi

STEP_CA_ENABLE_SSH="${STEP_CA_ENABLE_SSH:-false}"
if [ "${STEP_CA_ENABLE_SSH}" != "true" ] && [ "${STEP_CA_ENABLE_SSH}" != "false" ]; then
    log_error "STEP_CA_ENABLE_SSH must be 'true' or 'false'."
fi

log_info "Checking for docker and docker compose..."
check_docker_compose

CA_CONTAINER_NAME="step-ca"
CA_CONFIG_DIR="/home/step/config"
CA_SECRETS_DIR="/home/step/secrets"

# --- Start Step-CA service if not already running ---
log_info "Ensuring step-ca service is running..."
# Use eval to allow COMPOSE_PROFILES_ARG to be empty if not set
if ! ./scripts/compose.sh --profile stepca ps -q "$CA_CONTAINER_NAME" | grep -q .; then
    log_info "Starting $CA_CONTAINER_NAME with 'stepca' profile..."
    make stepca-up # Use make target to handle profiles
    sleep 5 # Give it a moment to start
fi

# --- Check if CA is already initialized ---
if ./scripts/compose.sh --profile stepca exec -T "$CA_CONTAINER_NAME" test -f "${CA_CONFIG_DIR}/ca.json"; then
    log_warn "Step-CA appears to be already initialized. Skipping bootstrap."
    log_info "To re-bootstrap, stop step-ca and remove the 'stepca-data' volume and 'services/step-ca/config' directory."
    ACME_URL="https://step-ca.${DEV_DOMAIN}:9000/acme/acme/directory"
    log_info "Step-CA ACME Directory URL: ${ACME_URL}"
    log_info "To trust the CA, import ${CA_CONFIG_DIR}/ca.crt from the container."
    log_info "You can retrieve it with: ./scripts/compose.sh --profile stepca cp step-ca:/home/step/config/ca.crt services/step-ca/config/ca.crt"
    exit 0
fi

log_info "Bootstrapping Step-CA server for the first time..."

ssh_flag=""
if [ "${STEP_CA_ENABLE_SSH}" = "true" ]; then
    ssh_flag="--ssh"
fi

bootstrap_cmd=$(cat <<EOF
set -euo pipefail
tmp_ca="/tmp/ca_password.txt"
tmp_admin="/tmp/admin_password.txt"
printf '%s' "${STEP_CA_PASSWORD}" > "\${tmp_ca}"
printf '%s' "${STEP_CA_ADMIN_PROVISIONER_PASSWORD}" > "\${tmp_admin}"
step ca init \
  --name "${CA_NAME}" \
  --dns "${CA_DNS_LIST}" \
  --address ":9000" \
  --provisioner "admin" \
  --password-file "\${tmp_ca}" \
  --provisioner-password-file "\${tmp_admin}" \
  ${ssh_flag}
rm -f "\${tmp_ca}" "\${tmp_admin}"
EOF
)

./scripts/compose.sh --profile stepca exec -T "$CA_CONTAINER_NAME" bash -c "${bootstrap_cmd}"

if ! ./scripts/compose.sh --profile stepca exec -T "$CA_CONTAINER_NAME" test -f "${CA_CONFIG_DIR}/ca.json"; then
    log_error "Step-CA initialization failed; ${CA_CONFIG_DIR}/ca.json was not created."
fi

log_info "Enabling ACME provisioner..."
./scripts/compose.sh --profile stepca exec -T "$CA_CONTAINER_NAME" \
    step ca provisioner add acme --type ACME --ca-url https://step-ca.${DEV_DOMAIN}:9000

log_success "Step-CA server bootstrapped successfully!"

ACME_URL="https://step-ca.${DEV_DOMAIN}:9000/acme/acme/directory"
log_info "Step-CA ACME Directory URL: ${ACME_URL}"
log_warn "To use Step-CA, you must configure Traefik to use 'stepca-resolver' and trust the Step-CA root certificate."
log_info "The Step-CA root certificate is located at: services/step-ca/config/ca.crt (after retrieving from container)."
log_info "You can copy it out using: ./scripts/compose.sh --profile stepca cp step-ca:/home/step/config/ca.crt services/step-ca/config/ca.crt"
log_info "Then trust './step-ca/config/ca.crt' on your local system."
log_info "Finally, restart the full stack with COMPOSE_PROFILES=stepca make up."
