# File: scripts/certbot-renew.sh
#
# Renews existing Let's Encrypt certificates using Certbot.
# This script requires the 'le' Docker Compose profile to be active and the 'certbot' service running.
#
# Usage: ./scripts/certbot-renew.sh
#
# This script is typically run as a scheduled task (e.g., cron job) to keep certificates updated.
#

SCRIPT_DIR=$(dirname "$0")
# shellcheck source=scripts/common.sh
. "$SCRIPT_DIR/common.sh"

load_env
check_env_var "LETSENCRYPT_STAGING"

log_info "Checking for docker and docker compose..."
check_command "docker"
check_command "docker compose"

# Determine Certbot server based on LETSENCRYPT_STAGING
CERTBOT_SERVER="https://acme-v02.api.letsencrypt.org/directory"
if [ "${LETSENCRYPT_STAGING}" = "true" ]; then
    CERTBOT_SERVER="https://acme-staging-v02.api.letsencrypt.org/directory"
    log_warn "Using Let's Encrypt STAGING environment for renewal."
else
    log_info "Using Let's Encrypt PRODUCTION environment for renewal."
fi

log_info "Attempting to renew certificates..."

# Run certbot in the certbot container
CERTBOT_COMMAND="docker compose --env-file .env --profile le run --rm \
    -p 80:80 \
    -p 443:443 \
    certbot renew \
    --webroot -w /var/www/certbot \
    --non-interactive \
    --server ${CERTBOT_SERVER}"

log_info "Executing Certbot command:"
log_info "${CERTBOT_COMMAND}"

# Execute certbot
if eval "${CERTBOT_COMMAND}"; then
    log_success "Certificates successfully renewed via Certbot!"
    log_info "Traefik should automatically pick up renewed certificates."
else
    log_error "Certbot certificate renewal failed."
    log_info "Check certbot logs (\"COMPOSE_PROFILES=le make logs certbot\")."
fi
