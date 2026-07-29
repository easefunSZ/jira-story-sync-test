#!/usr/bin/env bash
set -euo pipefail

POSTMAN_DIR="$(cd "$(dirname "$0")" && pwd)"
ENV_FILE="${1:-$POSTMAN_DIR/LEAD-93-405-backend-ac.postman_environment.json}"
REPORT_DIR="${REPORT_DIR:-$POSTMAN_DIR/reports}"
PRIVATE_DIR="${NEWMAN_PRIVATE_DIR:-$POSTMAN_DIR/.newman-private}"
STAMP="$(date '+%Y-%m-%d_%H%M%S')"
COLLECTION="$POSTMAN_DIR/LEAD-93-405-backend-ac.postman_collection.json"
RAW_JSON="$PRIVATE_DIR/lead93-405-backend-ac-${STAMP}.raw.json"
DEBUG_HTML="$PRIVATE_DIR/lead93-405-backend-ac-${STAMP}.debug.html"
SUMMARY_JSON="$REPORT_DIR/lead93-405-backend-ac-${STAMP}.summary.json"

if [[ ! -f "$ENV_FILE" ]]; then
  echo "Environment file not found: $ENV_FILE" >&2
  exit 2
fi

node "$POSTMAN_DIR/scripts/generate-lead93-lead405-ac-backend-suite.mjs"
mkdir -p "$REPORT_DIR" "$PRIVATE_DIR"
chmod 700 "$PRIVATE_DIR"

if command -v newman >/dev/null 2>&1; then
  NEWMAN=(newman)
else
  NEWMAN=(npm exec --yes --package=newman -- newman)
fi

set +e
"${NEWMAN[@]}" run "$COLLECTION" -e "$ENV_FILE" \
  --env-var 'enableWriteTests=true' \
  --bail failure \
  --reporters cli,json \
  --reporter-json-export "$RAW_JSON" \
  --timeout-request 30000
STATUS=$?
set -e

node "$POSTMAN_DIR/scripts/generate-newman-debug-report.mjs" "$RAW_JSON" "$DEBUG_HTML"
node "$POSTMAN_DIR/scripts/summarize-newman-report.mjs" "$RAW_JSON" "$SUMMARY_JSON"
echo "Debug report: $DEBUG_HTML"
echo "Summary: $SUMMARY_JSON"
exit "$STATUS"
