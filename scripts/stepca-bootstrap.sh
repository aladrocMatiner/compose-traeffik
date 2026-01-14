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

SCRIPT_DIR=$(dirname "$0")
# shellcheck source=scripts/common.sh
. "$SCRIPT_DIR/common.sh"

load_env
check_env_var "DEV_DOMAIN"
check_env_var "STEP_CA_NAME"
check_env_var "STEP_CA_ADMIN_PROVISIONER_PASSWORD"
check_env_var "STEP_CA_PASSWORD"

log_info "Checking for docker and docker compose..."
check_command "docker"
check_command "docker compose"

CA_CONTAINER_NAME="step-ca"
CA_CONFIG_DIR="/home/step/config"
CA_SECRETS_DIR="/home/step/secrets"

# --- Start Step-CA service if not already running ---
log_info "Ensuring step-ca service is running..."
# Use eval to allow COMPOSE_PROFILES_ARG to be empty if not set
if ! docker compose --env-file .env --profile stepca ps -q "$CA_CONTAINER_NAME" | grep -q .; then
    log_info "Starting $CA_CONTAINER_NAME with 'stepca' profile..."
    make stepca-up # Use make target to handle profiles
    sleep 5 # Give it a moment to start
fi

# --- Check if CA is already initialized ---
if docker compose --env-file .env --profile stepca exec -T "$CA_CONTAINER_NAME" test -f "${CA_CONFIG_DIR}/ca.json"; then
    log_warn "Step-CA appears to be already initialized. Skipping bootstrap."
    log_info "To re-bootstrap, stop step-ca and remove the 'stepca-data' volume and 'step-ca/config' directory."
    ACME_URL="https://step-ca.${DEV_DOMAIN}:9000/acme/acme/directory"
    log_info "Step-CA ACME Directory URL: ${ACME_URL}"
    log_info "To trust the CA, import ${CA_CONFIG_DIR}/ca.crt from the container."
    log_info "You can retrieve it with: docker compose --profile stepca cp step-ca:/home/step/config/ca.crt ./step-ca/config/ca.crt"
    exit 0
fi

log_info "Bootstrapping Step-CA server for the first time..."

# Use heredoc for multi-line command and pipe passwords securely
docker compose --env-file .env --profile stepca exec -T "$CA_CONTAINER_NAME" bash -c "
    step ca init \
        --name \"${STEP_CA_NAME}\" \
        --dns \"${STEP_CA_DNS}\" \
        --address ":9000" \
        --provisioner \"admin\" \
        --password-file /dev/stdin <<EOF
${STEP_CA_PASSWORD}
EOF
"

# Note: The above is a bit tricky with nested heredocs.
# Alternative: Write passwords to temp files in container if exec -T allows, then pass file paths.
# For simplicity in this dev environment, direct piping is usually okay.

log_info "Enabling ACME provisioner..."
# Add ACME provisioner (if not already added by init with default provisioner)
docker compose --env-file .env --profile stepca exec -T "$CA_CONTAINER_NAME" \
    step ca provisioner add acme --type ACME --ca-url https://step-ca.${DEV_DOMAIN}:9000

log_success "Step-CA server bootstrapped successfully!"

ACME_URL="https://step-ca.${DEV_DOMAIN}:9000/acme/acme/directory"
log_info "Step-CA ACME Directory URL: ${ACME_URL}"
log_warn "To use Step-CA, you must configure Traefik to use 'stepca-resolver' and trust the Step-CA root certificate."
log_info "The Step-CA root certificate is located at: ./step-ca/config/ca.crt (after retrieving from container)."
log_info "You can copy it out using: docker compose --profile stepca cp step-ca:/home/step/config/ca.crt ./step-ca/config/ca.crt"
log_info "Then trust './step-ca/config/ca.crt' on your local system."
log_info "Finally, restart the full stack with COMPOSE_PROFILES=stepca make up."
