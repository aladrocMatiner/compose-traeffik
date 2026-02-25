#!/bin/bash
# Render GitLab Omnibus config from .env values.

set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
REPO_ROOT=$(cd "${SCRIPT_DIR}/.." && pwd)

ENV_FILE="${REPO_ROOT}/.env"
TEMPLATE_FILE="${REPO_ROOT}/services/gitlab/config/gitlab.rb.tmpl"
OUTPUT_FILE="${REPO_ROOT}/services/gitlab/rendered/gitlab.rb"

while [ "$#" -gt 0 ]; do
    case "$1" in
        --env-file)
            ENV_FILE="$2"
            shift 2
            ;;
        --output-file)
            OUTPUT_FILE="$2"
            shift 2
            ;;
        --template-file)
            TEMPLATE_FILE="$2"
            shift 2
            ;;
        *)
            echo "ERROR: Unknown argument: $1" >&2
            exit 1
            ;;
    esac
done

if [ ! -f "${TEMPLATE_FILE}" ]; then
    echo "ERROR: GitLab template not found: ${TEMPLATE_FILE}" >&2
    exit 1
fi

if [ -f "${ENV_FILE}" ]; then
    set -a
    # shellcheck disable=SC1090
    . "${ENV_FILE}"
    set +a
elif [ -f "${REPO_ROOT}/.env.example" ]; then
    set -a
    # shellcheck disable=SC1091
    . "${REPO_ROOT}/.env.example"
    set +a
else
    echo "ERROR: No env file found (${ENV_FILE}) and .env.example missing." >&2
    exit 1
fi

if ! command -v python3 >/dev/null 2>&1; then
    echo "ERROR: python3 is required to render GitLab config." >&2
    exit 1
fi

mkdir -p "$(dirname "${OUTPUT_FILE}")"

export TEMPLATE_FILE OUTPUT_FILE
python3 <<'PY'
import os
from pathlib import Path


def ruby_escape(value: str) -> str:
    return value.replace("\\", "\\\\").replace('"', '\\"')


template_path = Path(os.environ["TEMPLATE_FILE"])
output_path = Path(os.environ["OUTPUT_FILE"])
text = template_path.read_text(encoding="utf-8")

dev_domain = os.environ.get("DEV_DOMAIN", "local.test")
gitlab_hostname = os.environ.get("GITLAB_HOSTNAME", "gitlab")
external_url = f"https://{gitlab_hostname}.{dev_domain}"
ssh_port = os.environ.get("GITLAB_SSH_HOST_PORT", "2424")
root_password = os.environ.get("GITLAB_ROOT_PASSWORD", "")

oidc_enabled = os.environ.get("GITLAB_OIDC_ENABLED", "false").lower() == "true"
obs_enabled = os.environ.get("GITLAB_OBSERVABILITY_ENABLED", "false").lower() == "true"

oidc_block = "# OIDC is disabled by default."
if oidc_enabled:
    provider_label = os.environ.get("GITLAB_OIDC_PROVIDER_NAME", "keycloak")
    issuer = os.environ.get("GITLAB_OIDC_ISSUER", "")
    client_id = os.environ.get("GITLAB_OIDC_CLIENT_ID", "")
    client_secret = os.environ.get("GITLAB_OIDC_CLIENT_SECRET", "")
    scopes = os.environ.get("GITLAB_OIDC_SCOPES", "openid profile email")
    button_label = os.environ.get("GITLAB_OIDC_BUTTON_LABEL", "Keycloak")
    auto_link = os.environ.get("GITLAB_OIDC_AUTO_LINK", "true").lower() == "true"
    block_auto = os.environ.get("GITLAB_OIDC_BLOCK_AUTO_CREATED_USERS", "false").lower() == "true"
    auto_link_ruby = "['openid_connect']" if auto_link else "[]"
    callback = f"https://{gitlab_hostname}.{dev_domain}/users/auth/openid_connect/callback"
    oidc_block = "\n".join(
        [
            "gitlab_rails['omniauth_enabled'] = true",
            "gitlab_rails['omniauth_allow_single_sign_on'] = ['openid_connect']",
            f"gitlab_rails['omniauth_auto_link_user'] = {auto_link_ruby}",
            f"gitlab_rails['omniauth_block_auto_created_users'] = {'true' if block_auto else 'false'}",
            "gitlab_rails['omniauth_providers'] = [",
            "  {",
            "    name: 'openid_connect',",
            f"    label: '{ruby_escape(provider_label)}',",
            "    args: {",
            "      name: 'openid_connect',",
            f"      scope: '{ruby_escape(scopes)}',",
            "      response_type: 'code',",
            "      discovery: true,",
            "      client_auth_method: 'query',",
            "      uid_field: 'preferred_username',",
            f"      issuer: '{ruby_escape(issuer)}',",
            "      client_options: { "
            f"identifier: '{ruby_escape(client_id)}', "
            f"secret: '{ruby_escape(client_secret)}', "
            f"redirect_uri: '{ruby_escape(callback)}' "
            "}",
            "    }",
            "  }",
            "]",
            "gitlab_rails['omniauth_sync_email_from_provider'] = 'openid_connect'",
            "gitlab_rails['omniauth_sync_profile_from_provider'] = ['openid_connect']",
            "gitlab_rails['omniauth_sync_profile_attributes'] = ['email']",
            "gitlab_rails['gitlab_signin_enabled'] = true",
            f"gitlab_rails['signin_text'] = 'Sign in with {ruby_escape(button_label)} or local account'",
        ]
    )

obs_lines = [
    "# Observability hooks (internal-only by default)",
    "# Health endpoints remain available on the main application surface.",
]
if not obs_enabled:
    obs_lines.extend(
        [
            "# Disable bundled Prometheus/exporters unless observability integration is enabled.",
            "prometheus_monitoring['enable'] = false",
            "gitlab_exporter['enable'] = false",
            "node_exporter['enable'] = false",
            "redis_exporter['enable'] = false",
            "postgres_exporter['enable'] = false",
        ]
    )
else:
    obs_lines.append(
        "# Bundled Prometheus/exporters keep internal defaults; do not publish them publicly without an explicit override."
    )
obs_block = "\n".join(obs_lines)

replacements = {
    "__GITLAB_EXTERNAL_URL__": ruby_escape(external_url),
    "__GITLAB_SSH_PORT__": ssh_port,
    "__GITLAB_ROOT_PASSWORD__": ruby_escape(root_password),
    "__GITLAB_OIDC_BLOCK__": oidc_block,
    "__GITLAB_OBSERVABILITY_BLOCK__": obs_block,
}

for key, value in replacements.items():
    text = text.replace(key, value)

output_path.write_text(text, encoding="utf-8")
PY

echo "INFO: Rendered GitLab config: ${OUTPUT_FILE}"
