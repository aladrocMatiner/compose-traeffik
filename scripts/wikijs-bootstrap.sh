#!/bin/bash
# File: scripts/wikijs-bootstrap.sh
# Render Wiki.js runtime config artifacts and optional integration runbooks.

set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
# shellcheck source=scripts/common.sh
. "${SCRIPT_DIR}/common.sh"

check_command "bash"

"${SCRIPT_DIR}/wikijs-render-config.sh"
log_success "Wiki.js bootstrap artifacts rendered."
