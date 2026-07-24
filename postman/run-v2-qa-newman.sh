#!/usr/bin/env bash
set -euo pipefail

POSTMAN_DIR="$(cd "$(dirname "$0")" && pwd)"
ARG1="${1:-}"
ARG2="${2:-}"

MODE="full"
ENV_FILE=""

if [[ "$ARG1" == "contract" || "$ARG1" == "full" ]]; then
  MODE="$ARG1"
  ENV_FILE="$ARG2"
elif [[ "$ARG2" == "contract" || "$ARG2" == "full" ]]; then
  MODE="$ARG2"
  ENV_FILE="$ARG1"
else
  ENV_FILE="$ARG1"
  MODE="full"
fi

if [[ -n "$ENV_FILE" && ! -f "$ENV_FILE" && -f "$POSTMAN_DIR/$ENV_FILE" ]]; then
  ENV_FILE="$POSTMAN_DIR/$ENV_FILE"
fi

if [[ -z "$ENV_FILE" && -f "$POSTMAN_DIR/LEAD-93-QA.postman_environment.json" ]]; then
  ENV_FILE="$POSTMAN_DIR/LEAD-93-QA.postman_environment.json"
fi

REPORT_DIR="${REPORT_DIR:-$POSTMAN_DIR/reports}"
PRIVATE_DIR="${NEWMAN_PRIVATE_DIR:-$POSTMAN_DIR/.newman-private}"
NPM_CACHE="${NPM_CONFIG_CACHE:-${TMPDIR:-/tmp}/lead93-npm-cache}"
STAMP="$(date '+%Y-%m-%d_%H%M%S')"

if [[ "$MODE" == "contract" ]]; then
  COLLECTION="${COLLECTION_FILE:-$POSTMAN_DIR/LEAD-93-v2-contract-all-apis.postman_collection.json}"
  RUNTIME_ENV="$PRIVATE_DIR/v2-deployed-contract-${STAMP}.runtime.postman_environment.json"
  MAIN_RAW_JSON="$PRIVATE_DIR/v2-deployed-contract-${STAMP}.raw.json"
  MAIN_DEBUG_HTML="$PRIVATE_DIR/v2-deployed-contract-${STAMP}.debug.html"
  MAIN_SUMMARY_JSON="$REPORT_DIR/v2-deployed-contract-${STAMP}.summary.json"
else
  COLLECTION="${COLLECTION_FILE:-$POSTMAN_DIR/LEAD-93-v2-full-run.postman_collection.json}"
  RUNTIME_ENV="$PRIVATE_DIR/v2-deployed-full-run-${STAMP}.runtime.postman_environment.json"
  MAIN_RAW_JSON="$PRIVATE_DIR/v2-deployed-full-run-${STAMP}.raw.json"
  MAIN_DEBUG_HTML="$PRIVATE_DIR/v2-deployed-full-run-${STAMP}.debug.html"
  MAIN_SUMMARY_JSON="$REPORT_DIR/v2-deployed-full-run-${STAMP}.summary.json"
fi
CLEANUP_RAW_JSON="$PRIVATE_DIR/v2-deployed-cleanup-${STAMP}.raw.json"
CLEANUP_DEBUG_HTML="$PRIVATE_DIR/v2-deployed-cleanup-${STAMP}.debug.html"
CLEANUP_SUMMARY_JSON="$REPORT_DIR/v2-deployed-cleanup-${STAMP}.summary.json"

if [[ -z "$ENV_FILE" || ! -f "$ENV_FILE" ]]; then
  echo "Usage: $0 [contract|full] [environment.json]" >&2
  exit 2
fi

node -e '
  const fs = require("fs");
  const env = JSON.parse(fs.readFileSync(process.argv[1], "utf8"));
  const values = Object.fromEntries((env.values || []).filter(item => item.enabled !== false).map(item => [item.key, String(item.value || "")]));
  const required = ["baseUrl"];
  const missing = required.filter(key => !values[key]);
  if (missing.length) { console.error(`Missing environment values: ${missing.join(", ")}`); process.exit(2); }
' "$ENV_FILE"

mkdir -p "$REPORT_DIR" "$PRIVATE_DIR" "$NPM_CACHE"
chmod 700 "$PRIVATE_DIR"

if command -v newman >/dev/null 2>&1; then
  NEWMAN=(newman)
else
  NEWMAN=(npm exec --cache "$NPM_CACHE" --yes --package=newman -- newman)
fi

SKIP_ARGS=()
if [[ -n "${SKIP_REQUEST_NAMES:-}" ]]; then
  SKIP_ARGS+=(--env-var "skipRequestNames=$SKIP_REQUEST_NAMES")
fi
if [[ -n "${SKIP_STEPS:-}" ]]; then
  SKIP_ARGS+=(--env-var "skipSteps=$SKIP_STEPS")
fi

generate_reports() {
  local raw_json="$1"
  local debug_html="$2"
  local summary_json="$3"
  local prompt_md="${raw_json%.raw.json}.ai-prompt.md"
  if [[ -f "$raw_json" ]]; then
    node "$POSTMAN_DIR/scripts/generate-newman-debug-report.mjs" "$raw_json" "$debug_html"
    node "$POSTMAN_DIR/scripts/summarize-newman-report.mjs" "$raw_json" "$summary_json"
    node "$POSTMAN_DIR/scripts/generate-inner-ai-prompt.mjs" "$raw_json" "$prompt_md"
    echo "Private Dev/QA debug report (URL + request + response):"
    echo "  $debug_html"
    echo "Sanitized Dev/QA summary:"
    echo "  $summary_json"
    echo "Inner AI Prompt (Markdown ready to copy):"
    echo "  $prompt_md"
  fi
}

if [[ "$MODE" == "full" ]]; then
  node "$POSTMAN_DIR/scripts/upgrade-v2-full-run.mjs"
fi

newman_status=0
"${NEWMAN[@]}" run "$COLLECTION" -e "$ENV_FILE" \
  --env-var "enableWriteTests=true" \
  ${SKIP_ARGS[@]+"${SKIP_ARGS[@]}"} \
  --bail failure \
  --reporters cli,json \
  --reporter-json-export "$MAIN_RAW_JSON" \
  --export-environment "$RUNTIME_ENV" \
  --timeout-request 30000 || newman_status=$?

generate_reports "$MAIN_RAW_JSON" "$MAIN_DEBUG_HTML" "$MAIN_SUMMARY_JSON"

if [[ "$newman_status" -ne 0 ]]; then
  if [[ "${CLEAN_ON_FAILURE:-false}" == "true" ]]; then
    echo "Main workflow stopped at failure. CLEAN_ON_FAILURE=true; starting cleanup..." >&2
    cleanup_status=0
    if [[ -f "$RUNTIME_ENV" ]]; then
      "${NEWMAN[@]}" run "$COLLECTION" -e "$RUNTIME_ENV" \
        --folder "99 Cleanup" \
        --env-var "enableWriteTests=true" \
        ${SKIP_ARGS[@]+"${SKIP_ARGS[@]}"} \
        --reporters cli,json \
        --reporter-json-export "$CLEANUP_RAW_JSON" \
        --export-environment "$RUNTIME_ENV" \
        --timeout-request 30000 || cleanup_status=$?
      generate_reports "$CLEANUP_RAW_JSON" "$CLEANUP_DEBUG_HTML" "$CLEANUP_SUMMARY_JSON"
      if [[ "$cleanup_status" -ne 0 ]]; then
        echo "Cleanup completed with failures. Inspect the cleanup debug report for residual test data." >&2
      else
        echo "Cleanup completed after the failed main workflow." >&2
      fi
    else
      echo "Runtime Environment was not exported; automatic cleanup could not start." >&2
    fi
  else
    echo "Main workflow stopped at first failure. Skipping cleanup to preserve test state for diagnosis." >&2
  fi
  exit "$newman_status"
fi

echo "Dev/QA run completed. The final requests removed the temporary Templates and Categories."
