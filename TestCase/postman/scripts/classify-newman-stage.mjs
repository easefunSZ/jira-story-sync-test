import fs from "node:fs";

const [rawPath, outputPath, criticalIdsCsv = ""] = process.argv.slice(2);
if (!rawPath || !outputPath) {
  console.error("Usage: node classify-newman-stage.mjs <raw-newman.json> <classification.json> [critical-request-ids]");
  process.exit(2);
}

function responseJson(response) {
  const bytes = response?.stream?.data;
  if (!Array.isArray(bytes)) return undefined;
  try {
    return JSON.parse(Buffer.from(bytes).toString("utf8"));
  } catch {
    return undefined;
  }
}

function requestId(name) {
  return Number(String(name ?? "").match(/^(\d+)\s/)?.[1]);
}

const criticalIds = new Set(
  criticalIdsCsv.split(",").map(value => Number(value.trim())).filter(Number.isFinite)
);
const raw = JSON.parse(fs.readFileSync(rawPath, "utf8"));
const executions = raw.run?.executions ?? [];
const assertionIssues = [];
const blockingFailures = [];

for (const execution of executions) {
  const name = execution.item?.name ?? "Unnamed request";
  const id = requestId(name);
  const response = execution.response;
  const json = responseJson(response);
  const failedAssertions = (execution.assertions ?? [])
    .filter(assertion => assertion.error)
    .map(assertion => ({
      assertion: assertion.assertion ?? "Unnamed assertion",
      message: assertion.error?.message ?? String(assertion.error)
    }));

  if (failedAssertions.length) {
    assertionIssues.push({
      requestId: id || null,
      request: name,
      httpStatus: response?.code ?? null,
      responseCode: json?.responseCode ?? null,
      assertions: failedAssertions
    });
  }

  if (!criticalIds.has(id)) continue;
  const reason = response?.code !== 200
    ? `HTTP ${response?.code ?? "no response"}`
    : !json
      ? "Response is not JSON"
      : json.responseCode !== "00000000"
        ? `responseCode ${json.responseCode ?? "missing"}`
        : null;
  if (reason) {
    blockingFailures.push({
      requestId: id,
      request: name,
      reason,
      httpStatus: response?.code ?? null,
      responseCode: json?.responseCode ?? null
    });
  }
}

const classification = {
  status: blockingFailures.length ? "BLOCKED" : assertionIssues.length ? "ISSUES" : "PASS",
  blockingFailures,
  assertionIssues,
  executionCount: executions.length
};

fs.writeFileSync(outputPath, `${JSON.stringify(classification, null, 2)}\n`);
console.log(`Stage classification: ${classification.status}; blocking=${blockingFailures.length}; assertionIssues=${assertionIssues.length}`);
