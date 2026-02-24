#!/bin/bash
# File: tests/smoke/test_litellm_config_template.sh
#
# Smoke test: Validate LiteLLM config template structure and env placeholder usage.

set -euo pipefail

SCRIPT_DIR=$(dirname "$0")
# shellcheck source=scripts/common.sh
. "$SCRIPT_DIR/../../scripts/common.sh"

CONFIG_FILE="$SCRIPT_DIR/../../services/litellm/config.yaml"

[ -f "$CONFIG_FILE" ] || log_error "LiteLLM config template not found."

grep -q '^model_list:' "$CONFIG_FILE"
grep -q '^general_settings:' "$CONFIG_FILE"
grep -Fq 'master_key: os.environ/LITELLM_MASTER_KEY' "$CONFIG_FILE"
grep -Fq 'model_name: os.environ/LITELLM_LOCAL_MODEL_ALIAS' "$CONFIG_FILE"
grep -Fq 'model: os.environ/LITELLM_LOCAL_MODEL_REF' "$CONFIG_FILE"
grep -Fq 'api_base: os.environ/LITELLM_LOCAL_API_BASE' "$CONFIG_FILE"
grep -Fq 'api_key: os.environ/OPENAI_API_KEY' "$CONFIG_FILE"
grep -Fq 'api_key: os.environ/ANTHROPIC_API_KEY' "$CONFIG_FILE"
grep -Fq 'api_key: os.environ/OPENROUTER_API_KEY' "$CONFIG_FILE"

# Ensure no obvious literal secrets are committed in the template.
if grep -Eq 'api_key:[[:space:]]*(sk-|hf_|AIza)' "$CONFIG_FILE"; then
  log_error "LiteLLM config template contains a literal-looking API key."
fi

log_success "LiteLLM config template smoke test passed."
