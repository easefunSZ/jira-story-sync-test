import fs from "node:fs";

const [input, output, reportMode = "--qa"] = process.argv.slice(2);
if (!input || !output) {
  console.error("Usage: node summarize-newman-report.mjs <raw-newman.json> <safe-summary.json> [--qa|--mock]");
  process.exit(2);
}

if (!["--qa", "--mock"].includes(reportMode)) {
  console.error(`Unsupported report mode: ${reportMode}`);
  process.exit(2);
}

function typeOf(value) {
  if (value === null) return "null";
  if (Array.isArray(value)) return "array";
  return typeof value;
}

function schemaOf(value, depth = 0) {
  const type = typeOf(value);
  if (depth >= 3 || !["object", "array"].includes(type)) return type;
  if (type === "array") {
    return {type: "array", item: value.length ? schemaOf(value[0], depth + 1) : "unknown"};
  }
  return {
    type: "object",
    fields: Object.fromEntries(Object.keys(value).sort().map(key => [key, schemaOf(value[key], depth + 1)]))
  };
}

function parseJson(text) {
  if (!text) return undefined;
  try {
    return JSON.parse(text);
  } catch {
    return undefined;
  }
}

function responseJson(response) {
  const bytes = response?.stream?.data;
  if (!Array.isArray(bytes)) return undefined;
  return parseJson(Buffer.from(bytes).toString("utf8"));
}

function endpointOf(request) {
  const url = request?.url ?? {};
  const segments = Array.isArray(url.path) ? url.path : [];
  const serviceIndex = segments.indexOf("iic-dae-msg");
  const path = `/${segments.slice(serviceIndex >= 0 ? serviceIndex : 0).join("/")}`;
  const queryKeys = (url.query ?? []).filter(item => !item.disabled).map(item => item.key);
  return queryKeys.length ? `${path}?${queryKeys.map(key => `${key}={value}`).join("&")}` : path;
}

const raw = JSON.parse(fs.readFileSync(input, "utf8"));
const executions = (raw.run?.executions ?? []).map(execution => {
  const requestBody = parseJson(execution.request?.body?.raw);
  const responseBody = responseJson(execution.response);
  return {
    name: execution.item?.name,
    method: execution.request?.method,
    endpoint: endpointOf(execution.request),
    httpStatus: execution.response?.code,
    responseTimeMs: execution.response?.responseTime,
    businessCode: responseBody?.responseCode,
    requestBodySchema: requestBody === undefined ? null : schemaOf(requestBody),
    responseEnvelopeFields: responseBody && typeof responseBody === "object" ? Object.keys(responseBody).sort() : [],
    responseDataSchema: responseBody ? schemaOf(responseBody.data) : null,
    assertions: (execution.assertions ?? []).map(assertion => ({
      name: assertion.assertion,
      passed: !assertion.error,
      skipped: Boolean(assertion.skipped)
    }))
  };
});

const summary = {
  generatedAt: new Date().toISOString(),
  source: reportMode === "--mock"
    ? "Newman local Contract Mock execution; not QA or deployed-service evidence"
    : "Newman QA execution; credentials, hosts, identifiers, payload values and response values removed",
  stats: raw.run?.stats,
  executions
};

fs.writeFileSync(output, `${JSON.stringify(summary, null, 2)}\n`);
console.log(`Generated sanitized summary: ${output}`);
