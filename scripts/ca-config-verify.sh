#!/bin/bash
# File: scripts/ca-config-verify.sh
#
# Validate effective CA configuration derived from .env.
#
# Usage: ./scripts/ca-config-verify.sh

set -euo pipefail

SCRIPT_DIR=$(dirname "$0")
# shellcheck source=scripts/common.sh
. "$SCRIPT_DIR/common.sh"

load_env
check_env_var "DEV_DOMAIN"

trim_value() {
    local val="$1"
    val="${val#"${val%%[![:space:]]*}"}"
    val="${val%"${val##*[![:space:]]}"}"
    printf "%s" "$val"
}

CA_NAME="${CA_NAME:-${STEP_CA_NAME:-}}"
if [ -z "${CA_NAME}" ]; then
    log_error "CA_NAME or STEP_CA_NAME must be set in .env."
fi

CA_SUBJECT_C="${CA_SUBJECT_C:-US}"
CA_SUBJECT_ST="${CA_SUBJECT_ST:-Local}"
CA_SUBJECT_L="${CA_SUBJECT_L:-Local}"
CA_SUBJECT_O="${CA_SUBJECT_O:-$CA_NAME}"
CA_SUBJECT_CN="${CA_SUBJECT_CN:-LocalDevRootCA}"

LEAF_SUBJECT_O="${LEAF_SUBJECT_O:-Local Dev}"
LEAF_SUBJECT_CN="${LEAF_SUBJECT_CN:-*.${DEV_DOMAIN}}"

LEAF_DNS="${LEAF_DNS:-whoami.${DEV_DOMAIN},traefik.${DEV_DOMAIN},step-ca.${DEV_DOMAIN},localhost}"
LEAF_IPS="${LEAF_IPS:-127.0.0.1}"

CA_DNS_RAW="${CA_DNS:-}"
CA_IPS_RAW="${CA_IPS:-}"
STEP_CA_DNS="${STEP_CA_DNS:-}"

CA_DNS_LIST=""
if [ -n "${CA_DNS_RAW}" ] || [ -n "${CA_IPS_RAW}" ]; then
    CA_DNS_LIST="${CA_DNS_RAW}"
    if [ -n "${CA_IPS_RAW}" ]; then
        if [ -n "${CA_DNS_LIST}" ]; then
            CA_DNS_LIST="${CA_DNS_LIST},${CA_IPS_RAW}"
        else
            CA_DNS_LIST="${CA_IPS_RAW}"
        fi
    fi
elif [ -n "${STEP_CA_DNS}" ]; then
    CA_DNS_LIST="${STEP_CA_DNS}"
else
    CA_DNS_LIST="step-ca,localhost,127.0.0.1,step-ca.${DEV_DOMAIN}"
    log_warn "CA_DNS/CA_IPS and STEP_CA_DNS are not set. Using default '${CA_DNS_LIST}'."
fi

LEAF_DNS="$(trim_value "$LEAF_DNS")"
LEAF_IPS="$(trim_value "$LEAF_IPS")"
if [ -z "${LEAF_DNS}" ] && [ -z "${LEAF_IPS}" ]; then
    log_error "LEAF_DNS and LEAF_IPS are empty. Set at least one in .env."
fi

log_success "Effective CA configuration:"
log_info "CA_NAME=${CA_NAME}"
log_info "CA_SUBJECT=/C=${CA_SUBJECT_C}/ST=${CA_SUBJECT_ST}/L=${CA_SUBJECT_L}/O=${CA_SUBJECT_O}/CN=${CA_SUBJECT_CN}"
log_info "CA_DNS_LIST=${CA_DNS_LIST}"
log_info "LEAF_SUBJECT=/C=${CA_SUBJECT_C}/ST=${CA_SUBJECT_ST}/L=${CA_SUBJECT_L}/O=${LEAF_SUBJECT_O}/CN=${LEAF_SUBJECT_CN}"
log_info "LEAF_DNS=${LEAF_DNS}"
log_info "LEAF_IPS=${LEAF_IPS}"
