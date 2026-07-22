#!/usr/bin/env bash
set -euo pipefail

POSTMAN_DIR="$(cd "$(dirname "$0")" && pwd)"
MODE="${1:-probes}"
ENV_FILE="${2:-$POSTMAN_DIR/LEAD-93-QA.postman_environment.json}"
REPORT_DIR="${REPORT_DIR:-$POSTMAN_DIR/reports}"
PRIVATE_DIR="${NEWMAN_PRIVATE_DIR:-$POSTMAN_DIR/.newman-private}"
NPM_CACHE="${NPM_CONFIG_CACHE:-${TMPDIR:-/tmp}/lead93-npm-cache}"
STAMP="$(date '+%Y-%m-%d_%H%M%S')"
PROBE_COLLECTION="$POSTMAN_DIR/LEAD-93-v1-contract-probes.postman_collection.json"
FULL_COLLECTION="$POSTMAN_DIR/LEAD-93-v1-full-run.postman_collection.json"

case "$MODE" in
  probes|full|all) ;;
  *)
    echo "Usage: $0 <probes|full|all> <environment.json>" >&2
    exit 2
    ;;
esac

if [[ ! -f "$ENV_FILE" ]]; then
  echo "Environment file not found: $ENV_FILE" >&2
  exit 2
fi

node -e '
  const fs = require("fs");
  const env = JSON.parse(fs.readFileSync(process.argv[1], "utf8"));
  const values = Object.fromEntries((env.values || []).filter(item => item.enabled !== false).map(item => [item.key, String(item.value || "")]));
  const missing = ["baseUrl"].filter(key => !values[key]);
  if (missing.length) { console.error(`Missing environment values: ${missing.join(", ")}`); process.exit(2); }
' "$ENV_FILE"

mkdir -p "$REPORT_DIR" "$PRIVATE_DIR" "$NPM_CACHE"
chmod 700 "$PRIVATE_DIR"

if command -v newman >/dev/null 2>&1; then
  NEWMAN=(newman)
else
  NEWMAN=(npm exec --cache "$NPM_CACHE" --yes --package=newman -- newman)
fi

generate_reports() {
  local raw_json="$1"
  local debug_html="$2"
  local summary_json="$3"
  if [[ -f "$raw_json" ]]; then
    node "$POSTMAN_DIR/scripts/generate-newman-debug-report.mjs" "$raw_json" "$debug_html"
    node "$POSTMAN_DIR/scripts/summarize-newman-report.mjs" "$raw_json" "$summary_json"
    echo "Private debug report (URL + request + response):"
    echo "  $debug_html"
    echo "Sanitized summary:"
    echo "  $summary_json"
  fi
}

run_probes() {
  local raw_json="$PRIVATE_DIR/v1-contract-probes-${STAMP}.raw.json"
  local debug_html="$PRIVATE_DIR/v1-contract-probes-${STAMP}.debug.html"
  local summary_json="$REPORT_DIR/v1-contract-probes-${STAMP}.summary.json"
  local status=0

  node "$POSTMAN_DIR/scripts/generate-v1-contract-probes.mjs"
  "${NEWMAN[@]}" run "$PROBE_COLLECTION" -e "$ENV_FILE" \
    --bail failure \
    --reporters cli,json \
    --reporter-json-export "$raw_json" \
    --timeout-request 30000 || status=$?
  generate_reports "$raw_json" "$debug_html" "$summary_json"
  return "$status"
}

run_full() {
  local runtime_env="$PRIVATE_DIR/v1-full-run-${STAMP}.runtime.postman_environment.json"
  local main_raw="$PRIVATE_DIR/v1-full-run-${STAMP}.raw.json"
  local main_debug="$PRIVATE_DIR/v1-full-run-${STAMP}.debug.html"
  local main_summary="$REPORT_DIR/v1-full-run-${STAMP}.summary.json"
  local cleanup_raw="$PRIVATE_DIR/v1-cleanup-${STAMP}.raw.json"
  local cleanup_debug="$PRIVATE_DIR/v1-cleanup-${STAMP}.debug.html"
  local cleanup_summary="$REPORT_DIR/v1-cleanup-${STAMP}.summary.json"
  local status=0

  node "$POSTMAN_DIR/scripts/upgrade-v1-full-run.mjs"
  "${NEWMAN[@]}" run "$FULL_COLLECTION" -e "$ENV_FILE" \
    --env-var "enableWriteTests=true" \
    --bail failure \
    --reporters cli,json \
    --reporter-json-export "$main_raw" \
    --export-environment "$runtime_env" \
    --timeout-request 30000 || status=$?
  generate_reports "$main_raw" "$main_debug" "$main_summary"

  if [[ "$status" -ne 0 ]]; then
    echo "Main workflow stopped at the first failed request or assertion. Starting cleanup only." >&2
    local cleanup_status=0
    if [[ -f "$runtime_env" ]]; then
      "${NEWMAN[@]}" run "$FULL_COLLECTION" -e "$runtime_env" \
        --folder "99 Cleanup" \
        --env-var "enableWriteTests=true" \
        --reporters cli,json \
        --reporter-json-export "$cleanup_raw" \
        --export-environment "$runtime_env" \
        --timeout-request 30000 || cleanup_status=$?
      generate_reports "$cleanup_raw" "$cleanup_debug" "$cleanup_summary"
      if [[ "$cleanup_status" -ne 0 ]]; then
        echo "Cleanup completed with failures. Inspect the cleanup debug report for residual test data." >&2
      else
        echo "Cleanup completed after the failed main workflow." >&2
      fi
    else
      echo "Runtime Environment was not exported; automatic cleanup could not start." >&2
    fi
  fi
  return "$status"
}

if [[ "$MODE" == "probes" ]]; then
  run_probes
elif [[ "$MODE" == "full" ]]; then
  run_full
else
  run_probes
  run_full
fi

echo "Detailed reports remain in $PRIVATE_DIR and must not be committed or shared without review."
