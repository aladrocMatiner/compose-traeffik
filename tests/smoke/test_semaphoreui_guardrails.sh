#!/bin/bash
# Smoke test: Validate Semaphore UI guardrails.

set -euo pipefail
SCRIPT_DIR=$(dirname "$0")
REPO_ROOT=$(cd "$SCRIPT_DIR/../.." && pwd)
VALIDATOR="$REPO_ROOT/scripts/validate-env.sh"
TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

run_case() {
  local name="$1" content="$2" expect_ok="$3"
  printf '%s\n' "$content" > "$TMPDIR/.env"
  if (cd "$TMPDIR" && env -i PATH="$PATH" HOME="${HOME:-}" "$VALIDATOR" >/tmp/${name}.out 2>&1); then
    [ "$expect_ok" = "true" ] || { cat /tmp/${name}.out >&2; echo "expected failure: $name" >&2; exit 1; }
  else
    [ "$expect_ok" = "false" ] || { cat /tmp/${name}.out >&2; echo "expected success: $name" >&2; exit 1; }
  fi
}

BASE_OK='DEV_DOMAIN=local.test
TRAEFIK_DASHBOARD=false
COMPOSE_PROFILES=semaphoreui
SEMAPHOREUI_HOSTNAME=semaphore
SEMAPHOREUI_ADMIN_PASSWORD=goodpass
SEMAPHOREUI_DB_PASSWORD=gooddbpass
SEMAPHOREUI_COOKIE_HASH=abc123abc123abc123abc123abc123abc123abc123abc123
SEMAPHOREUI_COOKIE_ENCRYPTION=abc123abc123abc123abc123abc123ab
SEMAPHOREUI_ACCESS_KEY_ENCRYPTION=abc123abc123abc123abc123abc123ab
SEMAPHOREUI_OIDC_ENABLED=false
SEMAPHOREUI_PASSWORD_LOGIN_DISABLED=false
SEMAPHOREUI_OBSERVABILITY_ENABLED=false
SEMAPHOREUI_OBSERVABILITY_DISCOVERY=labels
SEMAPHOREUI_OBSERVABILITY_PUBLIC_METRICS=false'

run_case placeholder_admin "${BASE_OK//$'goodpass'/changeme}" false
run_case bad_hostname "${BASE_OK//$'SEMAPHOREUI_HOSTNAME=semaphore'/SEMAPHOREUI_HOSTNAME=bad_host}" false
run_case bad_obsv_public "${BASE_OK//$'SEMAPHOREUI_OBSERVABILITY_PUBLIC_METRICS=false'/SEMAPHOREUI_OBSERVABILITY_PUBLIC_METRICS=true}" false
run_case oidc_missing_secret "${BASE_OK//$'SEMAPHOREUI_OIDC_ENABLED=false'/SEMAPHOREUI_OIDC_ENABLED=true}
SEMAPHOREUI_OIDC_PROVIDER_URL=https://keycloak.local.test/realms/master
SEMAPHOREUI_OIDC_CLIENT_ID=semaphore" false
run_case oidc_ok "${BASE_OK//$'SEMAPHOREUI_OIDC_ENABLED=false'/SEMAPHOREUI_OIDC_ENABLED=true}
SEMAPHOREUI_OIDC_PROVIDER_URL=https://keycloak.local.test/realms/master
SEMAPHOREUI_OIDC_CLIENT_ID=semaphore
SEMAPHOREUI_OIDC_CLIENT_SECRET=secretvalue" true
run_case base_ok "$BASE_OK" true

echo "SUCCESS: Semaphore UI guardrails test passed."
