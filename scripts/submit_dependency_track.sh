#!/usr/bin/env bash
set -euo pipefail
: "${DT_URL:?Defina DT_URL}"
: "${DT_TOKEN:?Defina DT_TOKEN como secret}"
: "${DT_PROJECT_UUID:?Defina DT_PROJECT_UUID}"
SBOM="${1:-sbom.cdx.json}"
base64 -w 0 "$SBOM" | jq -Rs --arg project "$DT_PROJECT_UUID" '{project: $project, bom: .}' \
  | curl --fail-with-body --silent --show-error \
      -X PUT "${DT_URL%/}/api/v1/bom" \
      -H "X-Api-Key: $DT_TOKEN" \
      -H "Content-Type: application/json" \
      --data-binary @-
