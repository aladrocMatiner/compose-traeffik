#!/bin/bash
# Bootstrap GitLab env defaults/secrets and render Omnibus config.

set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
REPO_ROOT=$(cd "${SCRIPT_DIR}/.." && pwd)

ENV_FILE="${REPO_ROOT}/.env"
FORCE=false

while [ "$#" -gt 0 ]; do
    case "$1" in
        --env-file)
            ENV_FILE="$2"
            shift 2
            ;;
        --force)
            FORCE=true
            shift
            ;;
        *)
            echo "ERROR: Unknown argument: $1" >&2
            exit 1
            ;;
    esac
done

if [ ! -f "${ENV_FILE}" ]; then
    if [ -f "${REPO_ROOT}/.env.example" ]; then
        cp "${REPO_ROOT}/.env.example" "${ENV_FILE}"
        echo "INFO: Created ${ENV_FILE} from .env.example"
    else
        echo "ERROR: Missing ${ENV_FILE} and .env.example" >&2
        exit 1
    fi
fi

random_string() {
    local length="${1:-40}"
    if command -v python3 >/dev/null 2>&1; then
        LENGTH="${length}" python3 - <<'PY'
import os
import secrets
import string

n = int(os.environ.get("LENGTH", "40"))
alphabet = string.ascii_letters + string.digits
print("".join(secrets.choice(alphabet) for _ in range(n)))
PY
        return
    fi
    if command -v openssl >/dev/null 2>&1; then
        local out
        out=$(openssl rand -base64 96 | tr -dc 'A-Za-z0-9' | head -c "${length}")
        if [ "${#out}" -ne "${length}" ]; then
            echo "ERROR: Failed to generate random secret." >&2
            exit 1
        fi
        printf '%s' "${out}"
        return
    fi
    echo "ERROR: Need python3 or openssl to generate secrets." >&2
    exit 1
}

trim_quotes() {
    local value="$1"
    value="${value#\"}"
    value="${value%\"}"
    value="${value#\'}"
    value="${value%\'}"
    printf '%s' "${value}"
}

get_env_value() {
    local key="$1"
    local line
    line=$(grep -E "^${key}=" "${ENV_FILE}" | tail -n 1 || true)
    if [ -z "${line}" ]; then
        printf ''
    else
        printf '%s' "${line#*=}"
    fi
}

set_env_value() {
    local key="$1"
    local value="$2"
    awk -v k="${key}" -v v="${value}" '
        BEGIN { found=0 }
        $0 ~ "^"k"=" { print k"="v; found=1; next }
        { print }
        END { if (!found) print k"="v }
    ' "${ENV_FILE}" > "${ENV_FILE}.tmp" && mv "${ENV_FILE}.tmp" "${ENV_FILE}"
}

set_default_if_empty() {
    local key="$1"
    local value="$2"
    local current
    current=$(trim_quotes "$(get_env_value "${key}")")
    if [ -z "${current}" ]; then
        set_env_value "${key}" "${value}"
        echo "INFO: Set ${key} default"
    fi
}

set_secret_if_empty() {
    local key="$1"
    local length="$2"
    local current
    current=$(trim_quotes "$(get_env_value "${key}")")
    if [ -n "${current}" ] && [ "${FORCE}" != true ]; then
        return
    fi
    local generated
    generated=$(random_string "${length}")
    set_env_value "${key}" "${generated}"
    if [ -n "${current}" ] && [ "${FORCE}" = true ]; then
        echo "INFO: Rotated ${key} due to --force"
    else
        echo "INFO: Generated ${key}"
    fi
}

set_default_if_empty "GITLAB_HOSTNAME" "gitlab"
set_default_if_empty "GITLAB_IMAGE" "gitlab/gitlab-ee"
set_default_if_empty "GITLAB_VERSION" "18.8.2-ee.0"
set_default_if_empty "GITLAB_SHM_SIZE" "256m"
set_default_if_empty "GITLAB_SSH_BIND_ADDRESS" "0.0.0.0"
set_default_if_empty "GITLAB_SSH_HOST_PORT" "2424"
set_default_if_empty "GITLAB_ROOT_EMAIL" "root@local.test"
set_default_if_empty "GITLAB_TRAEFIK_MIDDLEWARES" "security-headers@file"
set_default_if_empty "GITLAB_OIDC_ENABLED" "false"
set_default_if_empty "GITLAB_OIDC_PROVIDER_NAME" "keycloak"
set_default_if_empty "GITLAB_OIDC_SCOPES" "\"openid profile email\""
set_default_if_empty "GITLAB_OIDC_AUTO_LINK" "true"
set_default_if_empty "GITLAB_OIDC_BLOCK_AUTO_CREATED_USERS" "false"
set_default_if_empty "GITLAB_OIDC_BUTTON_LABEL" "Keycloak"
set_default_if_empty "GITLAB_OBSERVABILITY_ENABLED" "false"

set_secret_if_empty "GITLAB_ROOT_PASSWORD" 40

current_email=$(trim_quotes "$(get_env_value "GITLAB_ROOT_EMAIL")")
current_dev_domain=$(trim_quotes "$(get_env_value "DEV_DOMAIN")")
if [ -n "${current_dev_domain}" ] && [ "${current_email}" = "root@local.test" ]; then
    set_env_value "GITLAB_ROOT_EMAIL" "root@${current_dev_domain}"
    echo "INFO: Set GITLAB_ROOT_EMAIL from DEV_DOMAIN"
fi

"${SCRIPT_DIR}/gitlab-render-config.sh" --env-file "${ENV_FILE}"

echo "SUCCESS: GitLab bootstrap complete"
