#!/usr/bin/env bash
set -uo pipefail

POSTMAN_DIR="$(cd "$(dirname "$0")" && pwd)"
ENV_FILE="${1:-$POSTMAN_DIR/LEAD-93-405-backend-ac.postman_environment.json}"
STAMP="$(date '+%Y-%m-%d_%H%M%S')"
ROOT_REPORT_DIR="${REPORT_DIR:-$POSTMAN_DIR/reports}"
ROOT_PRIVATE_DIR="${NEWMAN_PRIVATE_DIR:-$POSTMAN_DIR/.newman-private}"
RUN_REPORT_DIR="$ROOT_REPORT_DIR/lead93-405-406-407-308-$STAMP"
RUN_PRIVATE_DIR="$ROOT_PRIVATE_DIR/lead93-405-406-407-308-$STAMP"
BASE_RUNNER="$POSTMAN_DIR/run-lead93-lead405-ac-with-db.sh"
ADVISER_COLLECTION="$POSTMAN_DIR/LEAD-308-407-adviser-ac.postman_collection.json"
ADVISER_RAW="$RUN_PRIVATE_DIR/lead308-407-adviser.raw.json"
ADVISER_DEBUG="$RUN_PRIVATE_DIR/lead308-407-adviser.debug.html"
ADVISER_SUMMARY="$RUN_REPORT_DIR/lead308-407-adviser.summary.json"
MASTER_REPORT="$RUN_REPORT_DIR/lead93-405-406-407-308-ac-overview.html"

if [[ ! -f "$ENV_FILE" ]]; then
  echo "Environment file not found: $ENV_FILE" >&2
  exit 2
fi

mkdir -p "$RUN_REPORT_DIR" "$RUN_PRIVATE_DIR"
chmod 700 "$RUN_PRIVATE_DIR"

echo "== Phase 1: LEAD-93 / LEAD-405 API and database AC verification =="
set +e
REPORT_DIR="$RUN_REPORT_DIR" NEWMAN_PRIVATE_DIR="$RUN_PRIVATE_DIR" "$BASE_RUNNER" "$ENV_FILE"
CORE_STATUS=$?
set -e

CORE_REPORT="$(find "$RUN_REPORT_DIR" -maxdepth 1 -name 'lead93-405-backend-ac-with-db-*.html' -print -quit)"
RUNTIME_ENV="$(find "$RUN_PRIVATE_DIR" -maxdepth 1 -name '*.runtime.environment.json' -print -quit)"
if [[ -z "$CORE_REPORT" || -z "$RUNTIME_ENV" ]]; then
  echo "LEAD-93/405 prerequisites did not produce report/runtime environment; Adviser phase cannot run." >&2
  exit 1
fi

echo "== Phase 2: LEAD-308 / LEAD-407 Adviser read-contract verification =="
node "$POSTMAN_DIR/scripts/generate-lead308-numbered-ac-suite.mjs"
if command -v newman >/dev/null 2>&1; then NEWMAN=(newman); else NEWMAN=(npm exec --yes --package=newman -- newman); fi
set +e
"${NEWMAN[@]}" run "$ADVISER_COLLECTION" -e "$RUNTIME_ENV" \
  --reporters cli,json --reporter-json-export "$ADVISER_RAW" --timeout-request 30000
ADVISER_STATUS=$?
set -e

node "$POSTMAN_DIR/scripts/generate-newman-debug-report.mjs" "$ADVISER_RAW" "$ADVISER_DEBUG" --private
node "$POSTMAN_DIR/scripts/summarize-newman-report.mjs" "$ADVISER_RAW" "$ADVISER_SUMMARY"
node "$POSTMAN_DIR/scripts/generate-five-feature-ac-overview.mjs" "$CORE_REPORT" "$ADVISER_SUMMARY" "$ADVISER_DEBUG" "$MASTER_REPORT" "$CORE_STATUS"

echo "LEAD-93/405 detailed report: $CORE_REPORT"
echo "LEAD-308/407 debug report: $ADVISER_DEBUG"
echo "Five-feature overview: $MASTER_REPORT"

if [[ "$CORE_STATUS" -ne 0 || "$ADVISER_STATUS" -ne 0 ]]; then
  echo "Completed with verification issues; detailed evidence remains available in the reports above." >&2
  exit 1
fi
echo "All executable API and database checks passed. OPEN/UI ACs remain visible in the five-feature overview."
