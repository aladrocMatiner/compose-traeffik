#!/bin/bash
# File: tests/smoke/test_wg_bootstrap_env.sh
#
# Smoke test: Validate wg-bootstrap env population and idempotency.

set -euo pipefail

SCRIPT_DIR=$(dirname "$0")
# shellcheck source=scripts/common.sh
. "$SCRIPT_DIR/../../scripts/common.sh"

BOOTSTRAP_SCRIPT="$SCRIPT_DIR/../../scripts/wg-bootstrap.sh"

check_command "mktemp"
check_command "grep"
check_command "awk"

if [ ! -x "$BOOTSTRAP_SCRIPT" ]; then
    log_error "wg-bootstrap script missing or not executable: $BOOTSTRAP_SCRIPT"
fi

TMP_ENV=$(mktemp)
trap 'rm -f "$TMP_ENV"' EXIT
cp "$SCRIPT_DIR/../../.env.example" "$TMP_ENV"

# Ensure the bootstrap fields are blank/default to exercise generation.
awk '
    /^WG_INIT_PASSWORD=/ { print "WG_INIT_PASSWORD="; next }
    { print }
' "$TMP_ENV" > "$TMP_ENV.tmp" && mv "$TMP_ENV.tmp" "$TMP_ENV"

log_info "Running wg-bootstrap against temporary env file..."
"$BOOTSTRAP_SCRIPT" --env-file "$TMP_ENV" >/dev/null

pass1=$(grep -E '^WG_INIT_PASSWORD=' "$TMP_ENV" | tail -n1 | cut -d= -f2-)
user1=$(grep -E '^WG_INIT_USERNAME=' "$TMP_ENV" | tail -n1 | cut -d= -f2-)
if [ -z "$pass1" ]; then
    log_error "wg-bootstrap did not generate WG_INIT_PASSWORD."
fi
if [ "$user1" != "admin" ]; then
    log_error "wg-bootstrap did not ensure WG_INIT_USERNAME=admin by default."
fi

log_info "Checking idempotent re-run (no overwrite by default)..."
"$BOOTSTRAP_SCRIPT" --env-file "$TMP_ENV" >/dev/null
pass2=$(grep -E '^WG_INIT_PASSWORD=' "$TMP_ENV" | tail -n1 | cut -d= -f2-)
if [ "$pass1" != "$pass2" ]; then
    log_error "wg-bootstrap overwrote WG_INIT_PASSWORD on a default re-run."
fi

log_info "Checking explicit --force rotation updates password..."
"$BOOTSTRAP_SCRIPT" --env-file "$TMP_ENV" --force >/dev/null
pass3=$(grep -E '^WG_INIT_PASSWORD=' "$TMP_ENV" | tail -n1 | cut -d= -f2-)
if [ -z "$pass3" ] || [ "$pass3" = "$pass2" ]; then
    log_error "wg-bootstrap --force did not rotate WG_INIT_PASSWORD."
fi

log_info "Checking missing env file fails cleanly..."
if "$BOOTSTRAP_SCRIPT" --env-file "$TMP_ENV.missing" >/dev/null 2>&1; then
    log_error "wg-bootstrap should fail when env file is missing."
fi

log_success "wg-bootstrap env smoke test passed."
