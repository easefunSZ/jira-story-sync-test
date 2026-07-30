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
HAS_CONTRACT_ISSUES=0

if [[ ! -f "$ENV_FILE" ]]; then
  echo "Environment file not found: $ENV_FILE" >&2
  exit 2
fi

mkdir -p "$REPORT_DIR" "$PRIVATE_DIR"
chmod 700 "$PRIVATE_DIR"
: > "$MANIFEST"

manifest_reference() {
  local artifact="$1"
  case "$artifact" in
    "$PRIVATE_DIR"/*) printf '%s' "${artifact#"$PRIVATE_DIR"/}" ;;
    "$REPORT_DIR"/*) printf '../reports/%s' "${artifact#"$REPORT_DIR"/}" ;;
    *) printf '%s' "$artifact" ;;
  esac
}

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
  local critical_ids="$3"
  local safe_stage="${stage// /_}"
  local raw="$PRIVATE_DIR/lead93-405-${STAMP}-${safe_stage}.raw.json"
  local debug="$PRIVATE_DIR/lead93-405-${STAMP}-${safe_stage}.debug.html"
  local summary="$REPORT_DIR/lead93-405-${STAMP}-${safe_stage}.summary.json"
  local classification="$PRIVATE_DIR/lead93-405-${STAMP}-${safe_stage}.classification.json"

  echo "== API phase: $stage =="
  set +e
  "${NEWMAN[@]}" run "$COLLECTION" -e "$RUNTIME_ENV" \
    --export-environment "$RUNTIME_ENV" \
    --folder "$folder" \
    --reporters cli,json \
    --reporter-json-export "$raw" \
    --timeout-request 30000
  local status=$?
  set -e

  if [[ -f "$raw" ]]; then
    node "$POSTMAN_DIR/scripts/generate-newman-debug-report.mjs" "$raw" "$debug" || true
    node "$POSTMAN_DIR/scripts/summarize-newman-report.mjs" "$raw" "$summary" || true
    node "$POSTMAN_DIR/scripts/classify-newman-stage.mjs" "$raw" "$classification" "$critical_ids"
  fi
  local result
  result="$(node -e 'const fs=require("fs"); const p=process.argv[1]; console.log(fs.existsSync(p) ? JSON.parse(fs.readFileSync(p,"utf8")).status : "BLOCKED")' "$classification")"
  printf '%s\tapi\t%s\t%s\t%s\t%s\t%s\n' "$stage" "$result" "$(manifest_reference "$raw")" "$(manifest_reference "$debug")" "$(manifest_reference "$summary")" "$(manifest_reference "$classification")" >> "$MANIFEST"
  if [[ "$result" == "BLOCKED" ]]; then
    echo "Blocking prerequisite failure in $stage; dependent phases are not executed." >&2
    exit 1
  fi
  if [[ "$result" == "ISSUES" || "$status" -ne 0 ]]; then
    HAS_CONTRACT_ISSUES=1
    echo "Contract assertion issues in $stage; continuing to the next independent phase." >&2
  fi
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
  printf '%s\tdb\t%s\t%s\n' "$checkpoint" "$result" "$(manifest_reference "$output")" >> "$MANIFEST"
  if [[ "$status" -ne 0 ]]; then
    HAS_CONTRACT_ISSUES=1
    echo "Database assertion issues in $checkpoint; continuing to the next API phase." >&2
  fi
}

refresh_debug_report_with_db() {
  local stage="$1"
  local checkpoint="$2"
  local safe_stage="${stage// /_}"
  local raw="$PRIVATE_DIR/lead93-405-${STAMP}-${safe_stage}.raw.json"
  local debug="$PRIVATE_DIR/lead93-405-${STAMP}-${safe_stage}.debug.html"
  local db_result="$PRIVATE_DIR/lead93-405-${STAMP}-db-${checkpoint}.json"
  [[ -f "$raw" && -f "$db_result" ]] || return 0
  node "$POSTMAN_DIR/scripts/generate-newman-debug-report.mjs" "$raw" "$debug" --private --db-result "$db_result" || true
}

run_api_phase "01 Preflight" "01 Preflight and Read APIs" "1"
run_api_phase "02 Category" "02 Category and Subcategory APIs" "6,7,8,12,13"
run_api_phase "03 Template and Metadata" "03 Template Create, Validation and Metadata APIs" "18,21"
run_db_checkpoint "template_metadata"
refresh_debug_report_with_db "03 Template and Metadata" "template_metadata"

run_api_phase "04A Copy Independence" "04A Copy Independence APIs" "32"
run_db_checkpoint "copy"
refresh_debug_report_with_db "04A Copy Independence" "copy"

run_api_phase "04B Version Lifecycle" "04B Version Lifecycle APIs" "41,42,43,45"
run_db_checkpoint "lifecycle"
refresh_debug_report_with_db "04B Version Lifecycle" "lifecycle"

run_api_phase "05 Reassignment and Delete" "05 Reassignment, Delete and Permission APIs" "47,51,54"
run_db_checkpoint "reassignment"
refresh_debug_report_with_db "05 Reassignment and Delete" "reassignment"

run_api_phase "99 Cleanup" "99 Cleanup" ""
run_db_checkpoint "cleanup"
refresh_debug_report_with_db "99 Cleanup" "cleanup"

if [[ "$HAS_CONTRACT_ISSUES" -eq 1 ]]; then
  echo "Completed with verification issues. See the combined report for every request and error." >&2
  exit 1
fi

echo "All API and database acceptance checks passed."
