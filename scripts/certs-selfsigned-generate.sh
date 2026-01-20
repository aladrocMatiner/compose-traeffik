# File: scripts/certs-selfsigned-generate.sh
#
# Generates a local self-signed CA and issues a leaf certificate for the DEV_DOMAIN.
# Designed for Mode A (local development).
#
# The generated certificates are stored in ${CERTS_DIR}/local-ca and ${CERTS_DIR}/local.
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

trim_value() {
    local val="$1"
    val="${val#"${val%%[![:space:]]*}"}"
    val="${val%"${val##*[![:space:]]}"}"
    printf "%s" "$val"
}

build_san_list() {
    local dns_list="$1"
    local ip_list="$2"
    local entry
    local trimmed
    local san_list=""

    IFS=',' read -r -a dns_entries <<< "$dns_list"
    for entry in "${dns_entries[@]}"; do
        trimmed=$(trim_value "$entry")
        [ -z "$trimmed" ] && continue
        san_list="${san_list:+${san_list},}DNS:${trimmed}"
    done

    IFS=',' read -r -a ip_entries <<< "$ip_list"
    for entry in "${ip_entries[@]}"; do
        trimmed=$(trim_value "$entry")
        [ -z "$trimmed" ] && continue
        san_list="${san_list:+${san_list},}IP:${trimmed}"
    done

    printf "%s" "$san_list"
}

CERTS_DIR=${CERTS_DIR:-shared/certs}
CA_DIR="${CERTS_DIR}/local-ca"
CERT_DIR="${CERTS_DIR}/local"
CA_KEY="${CA_DIR}/ca.key"
CA_CRT="${CA_DIR}/ca.crt"
LEAF_KEY="${CERT_DIR}/privkey.pem"
LEAF_CSR="${CERT_DIR}/cert.csr"
LEAF_CRT="${CERT_DIR}/fullchain.pem"

log_info "Ensuring certificate directories exist..."
mkdir -p "${CA_DIR}"
mkdir -p "${CERT_DIR}"

CA_NAME="${CA_NAME:-Local Dev CA}"
CA_SUBJECT_C="${CA_SUBJECT_C:-US}"
CA_SUBJECT_ST="${CA_SUBJECT_ST:-Local}"
CA_SUBJECT_L="${CA_SUBJECT_L:-Local}"
CA_SUBJECT_O="${CA_SUBJECT_O:-$CA_NAME}"
CA_SUBJECT_CN="${CA_SUBJECT_CN:-LocalDevRootCA}"

LEAF_SUBJECT_O="${LEAF_SUBJECT_O:-Local Dev}"
LEAF_SUBJECT_CN="${LEAF_SUBJECT_CN:-*.${DEV_DOMAIN}}"

LEAF_DNS="${LEAF_DNS:-whoami.${DEV_DOMAIN},traefik.${DEV_DOMAIN},step-ca.${DEV_DOMAIN},localhost}"
LEAF_IPS="${LEAF_IPS:-127.0.0.1}"

CA_SUBJECT="/C=${CA_SUBJECT_C}/ST=${CA_SUBJECT_ST}/L=${CA_SUBJECT_L}/O=${CA_SUBJECT_O}/CN=${CA_SUBJECT_CN}"
LEAF_SUBJECT="/C=${CA_SUBJECT_C}/ST=${CA_SUBJECT_ST}/L=${CA_SUBJECT_L}/O=${LEAF_SUBJECT_O}/CN=${LEAF_SUBJECT_CN}"

# ---
# Generate CA
# ---
if [ ! -f "${CA_KEY}" ] || [ ! -f "${CA_CRT}" ]; then
    log_info "Generating new Root CA private key and certificate..."
    openssl genrsa -out "${CA_KEY}" 4096
    openssl req -x509 -new -nodes -key "${CA_KEY}" -sha256 -days 3650 \
        -out "${CA_CRT}" -subj "${CA_SUBJECT}"
    log_success "Root CA generated in ${CA_DIR}"
else
    log_info "Root CA already exists in ${CA_DIR}. Skipping generation."
fi

# ---
# Generate Leaf Certificate
# ---
log_info "Generating leaf certificate for DEV_DOMAIN: ${DEV_DOMAIN}..."

# List of Subject Alternative Names (SANs)
SAN_DOMAINS=$(build_san_list "$LEAF_DNS" "$LEAF_IPS")

if [ -z "$SAN_DOMAINS" ]; then
    log_error "Leaf SAN list is empty. Set LEAF_DNS and/or LEAF_IPS in .env."
fi

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
    -subj "${LEAF_SUBJECT}"

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
