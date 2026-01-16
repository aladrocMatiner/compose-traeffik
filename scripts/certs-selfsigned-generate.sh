# File: scripts/certs-selfsigned-generate.sh
#
# Generates a local self-signed CA and issues a leaf certificate for the DEV_DOMAIN.
# Designed for Mode A (local development).
#
# The generated certificates are stored in shared/certs/local-ca/ and shared/certs/local.
#
# Usage: ./scripts/certs-selfsigned-generate.sh
#

SCRIPT_DIR=$(dirname "$0")
# shellcheck source=scripts/common.sh
. "$SCRIPT_DIR/common.sh"

load_env
check_env_var "DEV_DOMAIN"

log_info "Checking for openssl..."
check_command "openssl"

CA_DIR="shared/certs/local-ca"
CERT_DIR="shared/certs/local"
CA_KEY="${CA_DIR}/ca.key"
CA_CRT="${CA_DIR}/ca.crt"
LEAF_KEY="${CERT_DIR}/privkey.pem"
LEAF_CSR="${CERT_DIR}/cert.csr"
LEAF_CRT="${CERT_DIR}/fullchain.pem"

log_info "Ensuring certificate directories exist..."
mkdir -p "${CA_DIR}"
mkdir -p "${CERT_DIR}"

# ---
# Generate CA
# ---
if [ ! -f "${CA_KEY}" ] || [ ! -f "${CA_CRT}" ]; then
    log_info "Generating new Root CA private key and certificate..."
    openssl genrsa -out "${CA_KEY}" 4096
    openssl req -x509 -new -nodes -key "${CA_KEY}" -sha256 -days 3650 \
        -out "${CA_CRT}" -subj "/C=US/ST=Local/L=Local/O=Local Dev CA/CN=LocalDevRootCA"
    log_success "Root CA generated in ${CA_DIR}"
else
    log_info "Root CA already exists in ${CA_DIR}. Skipping generation."
fi

# ---
# Generate Leaf Certificate
# ---
log_info "Generating leaf certificate for DEV_DOMAIN: ${DEV_DOMAIN}..."

# List of Subject Alternative Names (SANs)
SAN_DOMAINS="DNS:whoami.${DEV_DOMAIN},DNS:traefik.${DEV_DOMAIN},DNS:step-ca.${DEV_DOMAIN},DNS:localhost,IP:127.0.0.1"

# Create a temporary OpenSSL configuration file for SANs
SAN_CONFIG=$(mktemp)
cat <<EOT > "$SAN_CONFIG"
[v3_ext]
subjectAltName = ${SAN_DOMAINS}
EOT

# Generate leaf private key
openssl genrsa -out "${LEAF_KEY}" 2048

# Generate Certificate Signing Request (CSR)
openssl req -new -key "${LEAF_KEY}" -out "${LEAF_CSR}" \
    -subj "/C=US/ST=Local/L=Local/O=Local Dev/CN=*.${DEV_DOMAIN}"

# Sign the CSR with the CA
openssl x509 -req -in "${LEAF_CSR}" -CA "${CA_CRT}" -CAkey "${CA_KEY}" \
    -CAcreateserial -out "${LEAF_CRT}" -days 365 \
    -sha256 -extfile "$SAN_CONFIG" -extensions v3_ext

rm "$SAN_CONFIG" # Clean up temporary file

if [ -f "${LEAF_CRT}" ] && [ -f "${LEAF_KEY}" ]; then
    log_success "Leaf certificate generated in ${CERT_DIR} for *.${DEV_DOMAIN}"
    log_info "Certificates are ready for Traefik Mode A."
    log_warn "IMPORTANT: To avoid browser warnings, you need to trust '${CA_CRT}'"
    log_warn "on your local machine. Refer to your OS documentation for specific steps."
else
    log_error "Failed to generate leaf certificate."
fi
