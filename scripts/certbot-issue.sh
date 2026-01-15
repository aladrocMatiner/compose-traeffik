# File: scripts/certbot-issue.sh
#
# Issues a new Let's Encrypt certificate using Certbot.
# This script requires the 'le' Docker Compose profile to be active and the 'certbot' service running.
#
# Usage: ./scripts/certbot-issue.sh
#
# This script will attempt to get certificates for DEV_DOMAIN and any subdomains
# specified implicitly by the Traefik configuration (e.g., whoami.${DEV_DOMAIN}).
#

SCRIPT_DIR=$(dirname "$0")
# shellcheck source=scripts/common.sh
. "$SCRIPT_DIR/common.sh"

load_env
check_env_var "DEV_DOMAIN"
check_env_var "ACME_EMAIL"
check_env_var "LETSENCRYPT_STAGING"

log_info "Checking for docker and docker compose..."
check_docker_compose

# Determine Certbot server based on LETSENCRYPT_STAGING
CERTBOT_SERVER="https://acme-v02.api.letsencrypt.org/directory"
if [ "${LETSENCRYPT_STAGING}" = "true" ]; then
    CERTBOT_SERVER="https://acme-staging-v02.api.letsencrypt.org/directory"
    log_warn "Using Let's Encrypt STAGING environment. Certificates will NOT be publicly trusted."
else
    log_info "Using Let's Encrypt PRODUCTION environment. Be aware of rate limits."
fi

log_info "Attempting to issue certificates for *.${DEV_DOMAIN} and specific subdomains..."

# Define the domains Certbot should attempt to issue for.
# These match what Traefik is expecting via labels or configuration.
# Note: For wildcard certs, DNS-01 challenge is typically required.
# For HTTP-01 (used here), you need explicit subdomains.
DOMAINS_TO_ISSUE="-d ${DEV_DOMAIN} -d whoami.${DEV_DOMAIN} -d traefik.${DEV_DOMAIN} -d step-ca.${DEV_DOMAIN}"

# Run certbot in the certbot container
CERTBOT_COMMAND="docker compose --env-file .env --profile le run --rm \
    -p 80:80 \
    -p 443:443 \
    certbot certonly \
    --webroot -w /var/www/certbot \
    ${DOMAINS_TO_ISSUE} \
    --email ${ACME_EMAIL} \
    --rsa-key-size 2048 \
    --agree-tos \
    --non-interactive \
    --cert-name ${DEV_DOMAIN//./-} \
    --server ${CERTBOT_SERVER}"

log_info "Executing Certbot command:"
log_info "${CERTBOT_COMMAND}"

# Execute certbot
if eval "${CERTBOT_COMMAND}"; then
    log_success "Certificates successfully issued for ${DEV_DOMAIN} via Certbot!"
    log_info "Certificates are stored in certbot/conf/live/${DEV_DOMAIN//./-}/"
    log_info "Traefik should automatically pick up these certificates."
    log_info "If using Traefik's ACME resolver, this step might not be strictly necessary, as Traefik will manage issuance."
    log_info "This script is primarily for demonstrating *Certbot's* role in issuance, if Traefik is configured to read from these files."
else
    log_error "Certbot certificate issuance failed."
    log_info "Check your domain DNS records, ensure ports 80/443 are open, and review certbot logs (\"
COMPOSE_PROFILES=le make logs certbot\")."
fi
