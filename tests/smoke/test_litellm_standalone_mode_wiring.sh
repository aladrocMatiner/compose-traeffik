#!/bin/bash
# File: tests/smoke/test_litellm_standalone_mode_wiring.sh
#
# Smoke test: Validate standalone LiteLLM edge mode wiring (traefik + litellm only).

set -euo pipefail

SCRIPT_DIR=$(dirname "$0")
# shellcheck source=scripts/common.sh
. "$SCRIPT_DIR/../../scripts/common.sh"

MAKEFILE="$SCRIPT_DIR/../../Makefile"
[ -f "$MAKEFILE" ] || log_error "Makefile not found."

standalone_block=$(awk '
  $0 ~ /^litellm-standalone-up:/ { in_block=1 }
  in_block { print }
  in_block && /^litellm-standalone-down:/ { exit }
' "$MAKEFILE")

echo "$standalone_block" | grep -q './scripts/validate-env.sh'
echo "$standalone_block" | grep -q './scripts/traefik-render-dynamic.sh'
echo "$standalone_block" | grep -q 'COMPOSE_PROFILES=litellm ./scripts/compose.sh --profile litellm'
echo "$standalone_block" | grep -q 'up -d traefik litellm'

# Ensure standalone targets do not implicitly start whoami/dns/stepca in their compose commands.
if echo "$standalone_block" | grep -Eq '\bwhoami\b|\bdns\b|\bstep-ca\b'; then
  log_error "Standalone LiteLLM mode should not start whoami/dns/step-ca."
fi

log_success "LiteLLM standalone mode wiring smoke test passed."
