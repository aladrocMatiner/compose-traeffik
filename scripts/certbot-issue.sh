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

CERTBOT_CERT_NAME=${CERTBOT_CERT_NAME:-${DEV_DOMAIN}}
CERTBOT_WEBROOT=${CERTBOT_WEBROOT:-/var/www/certbot}
CERTBOT_DOMAINS=${CERTBOT_DOMAINS:-}

# Determine Certbot server (prefer LETSENCRYPT_CA_SERVER if set)
CERTBOT_SERVER="${LETSENCRYPT_CA_SERVER:-}"
if [ -z "$CERTBOT_SERVER" ]; then
    CERTBOT_SERVER="https://acme-v02.api.letsencrypt.org/directory"
    if [ "${LETSENCRYPT_STAGING}" = "true" ]; then
        CERTBOT_SERVER="https://acme-staging-v02.api.letsencrypt.org/directory"
        log_warn "Using Let's Encrypt STAGING environment. Certificates will NOT be publicly trusted."
    else
        log_info "Using Let's Encrypt PRODUCTION environment. Be aware of rate limits."
    fi
else
    log_info "Using ACME server from LETSENCRYPT_CA_SERVER."
fi

log_info "Attempting to issue certificates for configured domains..."

trim() {
    local value="$1"
    value="${value#"${value%%[![:space:]]*}"}"
    value="${value%"${value##*[![:space:]]}"}"
    printf '%s' "$value"
}

# Define the domains Certbot should attempt to issue for.
# These match what Traefik is expecting via labels or configuration.
# Note: For wildcard certs, DNS-01 challenge is typically required.
# For HTTP-01 (used here), you need explicit subdomains.
DOMAINS_TO_ISSUE=""
if [ -n "${CERTBOT_DOMAINS}" ]; then
    IFS=',' read -r -a domain_parts <<< "${CERTBOT_DOMAINS}"
    for domain in "${domain_parts[@]}"; do
        domain=$(trim "$domain")
        if [ -n "$domain" ]; then
            DOMAINS_TO_ISSUE="${DOMAINS_TO_ISSUE} -d ${domain}"
        fi
    done
else
    DOMAINS_TO_ISSUE="-d ${DEV_DOMAIN} -d whoami.${DEV_DOMAIN} -d traefik.${DEV_DOMAIN} -d step-ca.${DEV_DOMAIN}"
fi

CERTBOT_COMMAND="./scripts/compose.sh --profile le run --rm \
    certbot certonly \
    --webroot -w ${CERTBOT_WEBROOT} \
    ${DOMAINS_TO_ISSUE} \
    --email ${ACME_EMAIL} \
    --rsa-key-size 2048 \
    --agree-tos \
    --non-interactive \
    --cert-name ${CERTBOT_CERT_NAME} \
    --server ${CERTBOT_SERVER}"

log_info "Executing Certbot command:"
log_info "${CERTBOT_COMMAND}"

# Execute certbot
if eval "${CERTBOT_COMMAND}"; then
    log_success "Certificates successfully issued for ${DEV_DOMAIN} via Certbot!"
    log_info "Certificates are stored in services/certbot/conf/live/${CERTBOT_CERT_NAME}/"
    log_info "Traefik should automatically pick up these certificates."
    log_info "If using Traefik's ACME resolver, this step might not be strictly necessary, as Traefik will manage issuance."
    log_info "This script is primarily for demonstrating *Certbot's* role in issuance, if Traefik is configured to read from these files."
else
    log_error "Certbot certificate issuance failed."
    log_info "Check your domain DNS records, ensure ports 80/443 are open, and review certbot logs (\"
COMPOSE_PROFILES=le make logs certbot\")."
fi
