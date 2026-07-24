#!/usr/bin/env bash
set -euo pipefail

POSTMAN_DIR="$(cd "$(dirname "$0")" && pwd)"
LEAD_DIR="$(cd "$POSTMAN_DIR/.." && pwd)"
MODE="contract"
FOLDER="${FOLDER:-}"
ITERATIONS="${ITERATIONS:-1}"

while [[ $# -gt 0 ]]; do
  case "$1" in
    contract|full)
      MODE="$1"
      shift
      ;;
    -n|--iterations|--iteration-count)
      ITERATIONS="$2"
      shift 2
      ;;
    -n=*|--iterations=*)
      ITERATIONS="${1#*=}"
      shift
      ;;
    -f|--folder|--request)
      FOLDER="$2"
      shift 2
      ;;
    -f=*|--folder=*|--request=*)
      FOLDER="${1#*=}"
      shift
      ;;
    [0-9]*)
      if [[ "$1" =~ ^[0-9]+$ ]]; then
        ITERATIONS="$1"
      fi
      shift
      ;;
    *)
      if [[ -z "$FOLDER" ]]; then
        FOLDER="$1"
      fi
      shift
      ;;
  esac
done

REPORT_DIR="${REPORT_DIR:-$POSTMAN_DIR/reports}"
PRIVATE_DIR="${NEWMAN_PRIVATE_DIR:-$POSTMAN_DIR/.newman-private}"
NPM_CACHE="${NPM_CONFIG_CACHE:-/private/tmp/lead93-npm-cache}"
MOCK_PORT="${LEAD93_MOCK_PORT:-8086}"
STAMP="$(date '+%Y-%m-%d_%H%M%S')"

if [[ "$MODE" == "full" ]]; then
  LABEL="v2-full-run-mock"
  COLLECTION="$POSTMAN_DIR/LEAD-93-v2-full-run.postman_collection.json"
else
  LABEL="v2-contract-mock"
  COLLECTION="$POSTMAN_DIR/LEAD-93-v2-contract-all-apis.postman_collection.json"
fi

ENV_FILE="$POSTMAN_DIR/LEAD-93-local-mock.postman_environment.json"
MOCK_SERVER="$LEAD_DIR/api-contract/mock/lead93-mock-server.mjs"
RAW_JSON="$PRIVATE_DIR/${LABEL}-${STAMP}.raw.json"
DEBUG_HTML="$REPORT_DIR/${LABEL}-${STAMP}.debug.html"
SUMMARY_JSON="$REPORT_DIR/${LABEL}-${STAMP}.summary.json"
SERVER_LOG="$PRIVATE_DIR/${LABEL}-${STAMP}.server.log"
SERVER_PID=""

cleanup() {
  if [[ -n "$SERVER_PID" ]]; then
    kill "$SERVER_PID" 2>/dev/null || true
    wait "$SERVER_PID" 2>/dev/null || true
  fi
}
trap cleanup EXIT

mkdir -p "$REPORT_DIR" "$PRIVATE_DIR" "$NPM_CACHE"
chmod 700 "$PRIVATE_DIR"

PORT="$MOCK_PORT" node "$MOCK_SERVER" >"$SERVER_LOG" 2>&1 &
SERVER_PID=$!

server_ready=false
for _ in {1..40}; do
  if node -e 'fetch(process.argv[1]).then(response => process.exit(response.status < 500 ? 0 : 1)).catch(() => process.exit(1))' "http://127.0.0.1:${MOCK_PORT}/iic-dae-msg/web/msg/template/email/v2/category/tree"; then
    server_ready=true
    break
  fi
  sleep 0.25
done

if [[ "$server_ready" != "true" ]]; then
  echo "Mock server did not start. See $SERVER_LOG" >&2
  exit 1
fi

if [[ "$MODE" == "full" ]]; then
  node "$POSTMAN_DIR/scripts/upgrade-v2-full-run.mjs"
fi

SKIP_ARGS=()
if [[ "$MODE" == "full" && -n "${SKIP_REQUEST_NAMES:-}" ]]; then
  SKIP_ARGS+=(--env-var "skipRequestNames=$SKIP_REQUEST_NAMES")
fi
if [[ "$MODE" == "full" && -n "${SKIP_STEPS:-}" ]]; then
  SKIP_ARGS+=(--env-var "skipSteps=$SKIP_STEPS")
fi

if command -v newman >/dev/null 2>&1; then
  NEWMAN=(newman)
elif command -v npx >/dev/null 2>&1; then
  NEWMAN=(npx --yes newman)
else
  NEWMAN=(npm exec --cache "$NPM_CACHE" --yes --package=newman -- newman)
fi

ITERATIONS="${ITERATIONS:-1}"

FOLDER_ARGS=()
if [[ -n "${FOLDER:-}" ]]; then
  RESOLVED_FOLDER=$(node -e '
    const fs = require("fs");
    const target = process.argv[1].toLowerCase();
    const col = JSON.parse(fs.readFileSync(process.argv[2], "utf8"));
    function search(items) {
      for (const item of items) {
        if (item.name && item.name.toLowerCase().includes(target)) return item.name;
        if (item.item) {
          const found = search(item.item);
          if (found) return found;
        }
      }
      return null;
    }
    const result = search(col.item || []);
    if (result) console.log(result);
  ' "$FOLDER" "$COLLECTION" 2>/dev/null || true)
  TARGET_FOLDER="${RESOLVED_FOLDER:-$FOLDER}"
  FOLDER_ARGS+=(--folder "$TARGET_FOLDER")
fi

newman_status=0
"${NEWMAN[@]}" run "$COLLECTION" -e "$ENV_FILE" \
  -n "$ITERATIONS" \
  ${FOLDER_ARGS[@]+"${FOLDER_ARGS[@]}"} \
  --env-var "baseUrl=http://127.0.0.1:${MOCK_PORT}" \
  --env-var "gatewayPrefix=" \
  --env-var "enableWriteTests=true" \
  ${SKIP_ARGS[@]+"${SKIP_ARGS[@]}"} \
  --bail failure \
  --reporters cli,json \
  --reporter-json-export "$RAW_JSON" \
  --timeout-request 30000 || newman_status=$?

if [[ -f "$RAW_JSON" ]]; then
  PROMPT_MD="${RAW_JSON%.raw.json}.ai-prompt.md"
  BENCHMARK_MD="${RAW_JSON%.raw.json}.benchmark.md"
  node "$POSTMAN_DIR/scripts/generate-newman-debug-report.mjs" "$RAW_JSON" "$DEBUG_HTML" --mock
  node "$POSTMAN_DIR/scripts/summarize-newman-report.mjs" "$RAW_JSON" "$SUMMARY_JSON" --mock
  node "$POSTMAN_DIR/scripts/generate-inner-ai-prompt.mjs" "$RAW_JSON" "$PROMPT_MD"
  node "$POSTMAN_DIR/scripts/benchmark-api-performance.mjs" "$RAW_JSON" "$BENCHMARK_MD"
  echo "V2 Contract Mock debug report (URL + request + response):"
  echo "  $DEBUG_HTML"
  echo "Mock summary:"
  echo "  $SUMMARY_JSON"
  echo "Inner AI Prompt (Markdown ready to copy):"
  echo "  $PROMPT_MD"
  echo "Performance Benchmark Report (Markdown):"
  echo "  $BENCHMARK_MD"
fi

if [[ "$newman_status" -ne 0 ]]; then
  echo "Newman finished with exit code $newman_status. Mock reports were preserved for diagnosis." >&2
  exit "$newman_status"
fi
