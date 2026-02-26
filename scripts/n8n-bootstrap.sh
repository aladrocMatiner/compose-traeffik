#!/bin/bash
# File: scripts/n8n-bootstrap.sh
# Render n8n runtime config artifacts and optional integration runbooks.

set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
# shellcheck source=scripts/common.sh
. "${SCRIPT_DIR}/common.sh"

"${SCRIPT_DIR}/n8n-render-config.sh"
log_success "n8n bootstrap artifacts rendered."
