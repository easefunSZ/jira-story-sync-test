#!/usr/bin/env bash
set -uo pipefail

POSTMAN_DIR="$(cd "$(dirname "$0")" && pwd)"
ENV_FILE="${1:-$POSTMAN_DIR/LEAD-93-405-backend-ac.postman_environment.json}"
REPORT_DIR="${REPORT_DIR:-$POSTMAN_DIR/reports}"
PRIVATE_DIR="${NEWMAN_PRIVATE_DIR:-$POSTMAN_DIR/.newman-private}"
STAMP="$(date '+%Y-%m-%d_%H%M%S')"
COLLECTION="$POSTMAN_DIR/LEAD-93-405-backend-ac.postman_collection.json"
ASSERTION_SQL="$POSTMAN_DIR/../sql/ASSERT_LEAD93_LEAD405_backend_ac.sql"
RUNTIME_ENV="$PRIVATE_DIR/lead93-405-backend-ac-${STAMP}.runtime.environment.json"
MANIFEST="$PRIVATE_DIR/lead93-405-backend-ac-${STAMP}.manifest.tsv"
FINAL_REPORT="$REPORT_DIR/lead93-405-backend-ac-with-db-${STAMP}.html"

if [[ ! -f "$ENV_FILE" ]]; then
  echo "Environment file not found: $ENV_FILE" >&2
  exit 2
fi

mkdir -p "$REPORT_DIR" "$PRIVATE_DIR"
chmod 700 "$PRIVATE_DIR"
: > "$MANIFEST"

finalize() {
  local status=$?
  node "$POSTMAN_DIR/scripts/generate-combined-ac-report.mjs" "$MANIFEST" "$FINAL_REPORT" || true
  echo "Combined report: $FINAL_REPORT"
  trap - EXIT
  exit "$status"
}
trap finalize EXIT

node "$POSTMAN_DIR/scripts/generate-lead93-lead405-ac-backend-suite.mjs"
node "$POSTMAN_DIR/scripts/prepare-newman-runtime-environment.mjs" "$ENV_FILE" "$RUNTIME_ENV"

if command -v newman >/dev/null 2>&1; then
  NEWMAN=(newman)
else
  NEWMAN=(npm exec --yes --package=newman -- newman)
fi

run_api_phase() {
  local stage="$1"
  local folder="$2"
  local safe_stage="${stage// /_}"
  local raw="$PRIVATE_DIR/lead93-405-${STAMP}-${safe_stage}.raw.json"
  local debug="$PRIVATE_DIR/lead93-405-${STAMP}-${safe_stage}.debug.html"
  local summary="$REPORT_DIR/lead93-405-${STAMP}-${safe_stage}.summary.json"

  echo "== API phase: $stage =="
  set +e
  "${NEWMAN[@]}" run "$COLLECTION" -e "$RUNTIME_ENV" \
    --export-environment "$RUNTIME_ENV" \
    --folder "$folder" \
    --bail failure \
    --reporters cli,json \
    --reporter-json-export "$raw" \
    --timeout-request 30000
  local status=$?
  set -e

  if [[ -f "$raw" ]]; then
    node "$POSTMAN_DIR/scripts/generate-newman-debug-report.mjs" "$raw" "$debug" || true
    node "$POSTMAN_DIR/scripts/summarize-newman-report.mjs" "$raw" "$summary" || true
  fi
  local result="PASS"
  [[ "$status" -eq 0 ]] || result="FAIL"
  printf '%s\tapi\t%s\t%s\t%s\t%s\n' "$stage" "$result" "$raw" "$debug" "$summary" >> "$MANIFEST"
  [[ "$status" -eq 0 ]] || exit "$status"
}

run_db_checkpoint() {
  local checkpoint="$1"
  local output="$PRIVATE_DIR/lead93-405-${STAMP}-db-${checkpoint}.json"

  echo "== Database checkpoint: $checkpoint =="
  set +e
  node "$POSTMAN_DIR/scripts/run-db-ac-checks.mjs" \
    --environment "$RUNTIME_ENV" \
    --template "$ASSERTION_SQL" \
    --checkpoint "$checkpoint" \
    --output "$output"
  local status=$?
  set -e
  local result="PASS"
  [[ "$status" -eq 0 ]] || result="FAIL"
  printf '%s\tdb\t%s\t%s\n' "$checkpoint" "$result" "$output" >> "$MANIFEST"
  [[ "$status" -eq 0 ]] || exit "$status"
}

run_api_phase "01 Preflight" "01 Preflight and Read APIs"
run_api_phase "02 Category" "02 Category and Subcategory APIs"
run_api_phase "03 Template and Metadata" "03 Template Create, Validation and Metadata APIs"
run_db_checkpoint "template_metadata"

run_api_phase "04A Copy Independence" "04A Copy Independence APIs"
run_db_checkpoint "copy"

run_api_phase "04B Version Lifecycle" "04B Version Lifecycle APIs"
run_db_checkpoint "lifecycle"

run_api_phase "05 Reassignment and Delete" "05 Reassignment, Delete and Permission APIs"
run_db_checkpoint "reassignment"

run_api_phase "99 Cleanup" "99 Cleanup"
run_db_checkpoint "cleanup"

echo "All API and database acceptance checks passed."
