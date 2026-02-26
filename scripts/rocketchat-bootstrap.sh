#!/bin/bash
# Bootstrap Rocket.Chat rendered config artifacts from .env values.

set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

ENV_FILE=".env"
OUTPUT_FILE=""
KEYCLOAK_GUIDE_FILE=""

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
    --keycloak-output-file)
      KEYCLOAK_GUIDE_FILE="$2"
      shift 2
      ;;
    *)
      echo "ERROR: Unknown argument: $1" >&2
      exit 1
      ;;
  esac
done

cmd=("${SCRIPT_DIR}/rocketchat-render-config.sh" --env-file "$ENV_FILE")
if [ -n "$OUTPUT_FILE" ]; then
  cmd+=(--output-file "$OUTPUT_FILE")
fi
if [ -n "$KEYCLOAK_GUIDE_FILE" ]; then
  cmd+=(--keycloak-output-file "$KEYCLOAK_GUIDE_FILE")
fi

"${cmd[@]}"
