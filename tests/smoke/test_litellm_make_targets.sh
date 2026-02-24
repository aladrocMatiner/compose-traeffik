#!/bin/bash
# File: tests/smoke/test_litellm_make_targets.sh
#
# Smoke test: Validate Makefile LiteLLM target and help wiring.

set -euo pipefail

SCRIPT_DIR=$(dirname "$0")
# shellcheck source=scripts/common.sh
. "$SCRIPT_DIR/../../scripts/common.sh"

MAKEFILE="$SCRIPT_DIR/../../Makefile"

[ -f "$MAKEFILE" ] || log_error "Makefile not found."

grep -q '^\.PHONY:' "$MAKEFILE" || log_error ".PHONY declaration missing"
grep -q 'litellm-bootstrap' "$MAKEFILE" || log_error "litellm-bootstrap missing from Makefile/.PHONY"
grep -q '^litellm-up:' "$MAKEFILE"
grep -q '^litellm-down:' "$MAKEFILE"
grep -q '^litellm-restart:' "$MAKEFILE"
grep -q '^litellm-logs:' "$MAKEFILE"
grep -q '^litellm-status:' "$MAKEFILE"
grep -q '^litellm-standalone-up:' "$MAKEFILE"
grep -q '^litellm-standalone-down:' "$MAKEFILE"
grep -q '^litellm-standalone-logs:' "$MAKEFILE"
grep -q '^litellm-standalone-status:' "$MAKEFILE"
grep -Fq './scripts/litellm-bootstrap.sh $(LITELLM_BOOTSTRAP_ENV_ARGS) $(LITELLM_BOOTSTRAP_ARGS)' "$MAKEFILE"
grep -Fq 'COMPOSE_PROFILES=litellm ./scripts/compose.sh --profile litellm' "$MAKEFILE"
grep -Fq './scripts/traefik-render-dynamic.sh' "$MAKEFILE"
grep -Fq 'up -d traefik litellm' "$MAKEFILE"

help_output=$(make -s help)
echo "$help_output" | grep -q 'LiteLLM Router:'
echo "$help_output" | grep -q 'litellm-bootstrap'
echo "$help_output" | grep -q 'litellm-up'
echo "$help_output" | grep -q 'litellm-standalone-up'

log_success "LiteLLM Makefile wiring smoke test passed."
