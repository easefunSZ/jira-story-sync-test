#!/usr/bin/env bash
set -euo pipefail

# Safe compatibility probe: {} is rejected by EmailAddBO Bean Validation before
# EmailController delegates to the Service, so it does not create Template data.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="${1:-"${SCRIPT_DIR}/pks-v1-validation.env"}"

if [[ ! -r "${CONFIG_FILE}" ]]; then
  echo "Configuration file not found: ${CONFIG_FILE}" >&2
  echo "Create it from ${SCRIPT_DIR}/pks-v1-validation.env.example." >&2
  exit 2
fi

# Parse a local KEY=VALUE file without evaluating it as shell. This accepts
# values such as "Bearer <token>" without requiring the user to quote them.
load_config() {
  local line key value line_number=0
  while IFS= read -r line || [[ -n "${line}" ]]; do
    line_number=$((line_number + 1))
    [[ -z "${line}" || "${line}" == \#* ]] && continue
    if [[ "${line}" != *=* ]]; then
      echo "Invalid configuration at line ${line_number}: expected KEY=VALUE." >&2
      exit 2
    fi
    key="${line%%=*}"
    value="${line#*=}"
    if [[ ! "${key}" =~ ^[A-Z][A-Z0-9_]*$ ]]; then
      echo "Invalid configuration key at line ${line_number}." >&2
      exit 2
    fi
    if [[ "${value}" =~ ^\".*\"$ || "${value}" =~ ^\'.*\'$ ]]; then
      value="${value:1:${#value}-2}"
    fi
    if [[ -z "${value}" && -n "${!key:-}" ]]; then
      continue
    fi
    printf -v "${key}" '%s' "${value}"
    export "${key}"
  done < "${CONFIG_FILE}"
}

load_config

: "${PKS_BASE_URL:?PKS_BASE_URL is required}"

endpoint_path="${PKS_ENDPOINT_PATH:-/iic-dae-msg/web/msg/template/email/v1/add}"
url="${PKS_BASE_URL%/}${PKS_GATEWAY_PREFIX:-}${endpoint_path}"
response_file="$(mktemp "${TMPDIR:-/tmp}/lead93-v1-validation.XXXXXX")"
header_file="$(mktemp "${TMPDIR:-/tmp}/lead93-v1-validation-headers.XXXXXX")"
trap 'rm -f "${response_file}" "${header_file}"' EXIT

curl_args=(
  --silent
  --show-error
  --max-time "${PKS_TIMEOUT_SECONDS:-20}"
  --output "${response_file}"
  --dump-header "${header_file}"
  --write-out '%{http_code}'
  --request POST "${url}"
  --header "Accept: ${PKS_ACCEPT:-application/json}"
  --header 'Content-Type: application/json'
  --header "User-Agent: ${PKS_USER_AGENT:-PostmanRuntime/7.43.0}"
  --header "language: ${PKS_LANGUAGE:-en-US}"
  --header "requestid: lead93-v1-validation-$(date +%s)"
  --data '{}'
)

if [[ -n "${PKS_AUTHORIZATION:-}" ]]; then
  curl_args+=(--header "authorization: ${PKS_AUTHORIZATION}")
fi
if [[ -n "${PKS_X_APIGW_API_ID:-}" ]]; then
  curl_args+=(--header "x-apigw-api-id: ${PKS_X_APIGW_API_ID}")
fi
if [[ "${PKS_CURL_INSECURE:-false}" == "true" ]]; then
  curl_args+=(--insecure)
fi
while IFS= read -r header_variable; do
  header_value="${!header_variable}"
  if [[ -n "${header_value}" ]]; then
    curl_args+=(--header "${header_value}")
  fi
done < <(compgen -v | grep '^PKS_HEADER_' || true)

echo "Probing V1 Bean Validation: ${url}"
if ! http_status="$(curl "${curl_args[@]}")"; then
  echo "Probe request failed. No Template write was attempted." >&2
  exit 1
fi

export EXPECTED_VALIDATION_DATA="${EXPECTED_VALIDATION_DATA:-[] Validation failed}"
node - "${response_file}" "${header_file}" "${http_status}" <<'NODE'
const fs = require('fs');
const [responseFile, headerFile, httpStatus] = process.argv.slice(2);
const rawBody = fs.readFileSync(responseFile, 'utf8');
const headers = fs.readFileSync(headerFile, 'utf8');
const contentType = (headers.match(/^content-type:\s*([^\r\n]+)/im) || [])[1] || 'unknown';
let body;

try {
  body = JSON.parse(rawBody);
} catch (error) {
  console.error(JSON.stringify({
    endpoint: 'V1 /add with empty JSON',
    httpStatus,
    contentType,
    result: 'FAIL',
    reason: 'Response is not valid JSON',
    bodyPreview: rawBody.replace(/\s+/g, ' ').slice(0, 240)
  }, null, 2));
  process.exit(1);
}

const expectedData = process.env.EXPECTED_VALIDATION_DATA;
const dataType = body.data === null ? 'null' : Array.isArray(body.data) ? 'array' : typeof body.data;
const failures = [];

if (httpStatus !== '200') failures.push(`HTTP status expected 200, received ${httpStatus}`);
if (body.responseCode !== '00000006') failures.push(`responseCode expected 00000006, received ${String(body.responseCode)}`);
if (dataType !== 'string') failures.push(`data type expected string, received ${dataType}`);
if (body.data !== expectedData) failures.push(`data expected ${JSON.stringify(expectedData)}, received ${JSON.stringify(body.data)}`);

console.log(JSON.stringify({
  endpoint: 'V1 /add with empty JSON',
  httpStatus,
  responseCode: body.responseCode,
  responseMessage: body.responseMessage,
  contentType,
  dataType,
  data: body.data,
  result: failures.length === 0 ? 'PASS' : 'FAIL'
}, null, 2));

if (failures.length > 0) {
  console.error(`FAIL: ${failures.join('; ')}`);
  process.exit(1);
}
NODE
