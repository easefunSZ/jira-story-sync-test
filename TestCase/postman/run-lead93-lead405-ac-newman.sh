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
CLASSIFICATION_JSON="$PRIVATE_DIR/lead93-405-backend-ac-${STAMP}.classification.json"
MANIFEST="$PRIVATE_DIR/lead93-405-backend-ac-${STAMP}.manifest.tsv"
AC_REPORT="$REPORT_DIR/lead93-405-backend-ac-api-only-${STAMP}.html"

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
  --reporters cli,json \
  --reporter-json-export "$RAW_JSON" \
  --timeout-request 30000
STATUS=$?
set -e

node "$POSTMAN_DIR/scripts/generate-newman-debug-report.mjs" "$RAW_JSON" "$DEBUG_HTML"
node "$POSTMAN_DIR/scripts/summarize-newman-report.mjs" "$RAW_JSON" "$SUMMARY_JSON"
node "$POSTMAN_DIR/scripts/classify-newman-stage.mjs" "$RAW_JSON" "$CLASSIFICATION_JSON" "6,7,8,12,13,18,21,32,41,42,43,45,47,51,54"
echo "Debug report: $DEBUG_HTML"
echo "Summary: $SUMMARY_JSON"
echo "Classification: $CLASSIFICATION_JSON"

CLASSIFICATION_STATUS="$(node -e 'const fs=require("fs"); console.log(JSON.parse(fs.readFileSync(process.argv[1],"utf8")).status)' "$CLASSIFICATION_JSON")"
printf '%s\tapi\t%s\t%s\t%s\t%s\t%s\n' "API-only full collection" "$CLASSIFICATION_STATUS" "$RAW_JSON" "$DEBUG_HTML" "$SUMMARY_JSON" "$CLASSIFICATION_JSON" > "$MANIFEST"
node "$POSTMAN_DIR/scripts/generate-combined-ac-report.mjs" "$MANIFEST" "$AC_REPORT"
echo "AC traceability report: $AC_REPORT"
if [[ "$CLASSIFICATION_STATUS" == "BLOCKED" ]]; then
  echo "Completed with blocking prerequisite failures. See the debug report." >&2
  exit 1
fi
if [[ "$CLASSIFICATION_STATUS" == "ISSUES" || "$STATUS" -ne 0 ]]; then
  echo "Completed with contract assertion issues. All requests were executed; see the debug report." >&2
  exit 1
fi
