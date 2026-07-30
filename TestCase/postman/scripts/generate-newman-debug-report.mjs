import fs from "node:fs";

const [input, output, ...argumentsAfterOutput] = process.argv.slice(2);
if (!input || !output) {
  console.error("Usage: node generate-newman-debug-report.mjs <raw-newman.json> <debug.html> [--private|--mock] [--db-result <db-checkpoint.json>]");
  process.exit(2);
}

let reportMode = "--private";
let databaseResultPath;
for (let index = 0; index < argumentsAfterOutput.length; index += 1) {
  const argument = argumentsAfterOutput[index];
  if (["--private", "--mock"].includes(argument)) {
    reportMode = argument;
  } else if (argument === "--db-result") {
    databaseResultPath = argumentsAfterOutput[index + 1];
    index += 1;
    if (!databaseResultPath) {
      console.error("Missing file path after --db-result");
      process.exit(2);
    }
  } else {
    console.error(`Unsupported argument: ${argument}`);
    process.exit(2);
  }
}

const sensitiveHeaders = new Set([
  "authorization",
  "cookie",
  "set-cookie",
  "x-api-key",
  "x-apigw-api-id"
]);

function escapeHtml(value) {
  return String(value ?? "")
    .replaceAll("&", "&amp;")
    .replaceAll("<", "&lt;")
    .replaceAll(">", "&gt;")
    .replaceAll('"', "&quot;")
    .replaceAll("'", "&#039;");
}

function decodeStream(stream) {
  const bytes = stream?.data;
  return Array.isArray(bytes) ? Buffer.from(bytes).toString("utf8") : "";
}

function pretty(value) {
  if (!value) return "(empty)";
  try {
    return JSON.stringify(JSON.parse(value), null, 2);
  } catch {
    return value;
  }
}

function prettyJson(value) {
  return JSON.stringify(value ?? null, null, 2);
}

function headerLines(headers = []) {
  if (!headers.length) return "(none)";
  return headers
    .filter(header => !header.disabled)
    .map(header => {
      const key = String(header.key ?? "");
      const value = sensitiveHeaders.has(key.toLowerCase()) ? "[REDACTED]" : header.value;
      return `${key}: ${value ?? ""}`;
    })
    .join("\n");
}

function urlOf(request) {
  const url = request?.url ?? {};
  const protocol = url.protocol ? `${url.protocol}://` : "";
  const host = Array.isArray(url.host) ? url.host.join(".") : String(url.host ?? "");
  const path = Array.isArray(url.path) ? `/${url.path.join("/")}` : "";
  const query = (url.query ?? [])
    .filter(item => !item.disabled)
    .map(item => `${encodeURIComponent(item.key ?? "")}=${encodeURIComponent(item.value ?? "")}`)
    .join("&");
  return `${protocol}${host}${path}${query ? `?${query}` : ""}`;
}

function stat(raw, name) {
  const value = raw.run?.stats?.[name];
  return value ? `${value.total ?? 0} total / ${value.failed ?? 0} failed` : "n/a";
}

const raw = JSON.parse(fs.readFileSync(input, "utf8"));
const databaseResult = databaseResultPath
  ? JSON.parse(fs.readFileSync(databaseResultPath, "utf8"))
  : null;
const executions = raw.run?.executions ?? [];
const generatedAt = new Date().toISOString();
const isMock = reportMode === "--mock";
const collectionName = raw.collection?.name || "LEAD-93 Newman Run";
const reportTitle = `${collectionName} - ${isMock ? "Contract Mock" : "Private"} Debug Report`;
const evidenceLabel = isMock
  ? "CONTRACT MOCK: Generated from the local mock server. This is expected request/response output, not QA or deployed-service evidence."
  : "PRIVATE: Contains actual URLs, request bodies and response bodies. Authorization, cookies and API keys are masked. Do not commit or share externally.";

const sections = executions.map((execution, index) => {
  const request = execution.request ?? {};
  const response = execution.response ?? {};
  const assertions = execution.assertions ?? [];
  const failures = assertions.filter(assertion => assertion.error);
  const assertionRows = assertions.length
    ? assertions.map(assertion => `
      <tr>
        <td class="${assertion.error ? "fail" : "pass"}">${assertion.error ? "FAIL" : "PASS"}</td>
        <td>${escapeHtml(assertion.assertion)}</td>
        <td><pre>${escapeHtml(assertion.error ? JSON.stringify(assertion.error, null, 2) : "")}</pre></td>
      </tr>`).join("")
    : '<tr><td colspan="3">No assertions</td></tr>';

  return `
  <section id="request-${index + 1}" class="request ${failures.length ? "has-failure" : ""}">
    <h2>${String(index + 1).padStart(2, "0")}. ${escapeHtml(execution.item?.name ?? "Unnamed request")}</h2>
    <div class="meta">
      <span class="method">${escapeHtml(request.method)}</span>
      <span>HTTP ${escapeHtml(response.code ?? "n/a")} ${escapeHtml(response.status ?? "")}</span>
      <span>${escapeHtml(response.responseTime ?? "n/a")} ms</span>
      <span>${failures.length ? `${failures.length} failed assertion(s)` : "Assertions passed"}</span>
    </div>
    <h3>URL</h3>
    <pre>${escapeHtml(urlOf(request))}</pre>
    <div class="columns">
      <div>
        <h3>Request Headers</h3>
        <pre>${escapeHtml(headerLines(request.header))}</pre>
      </div>
      <div>
        <h3>Response Headers</h3>
        <pre>${escapeHtml(headerLines(response.header))}</pre>
      </div>
    </div>
    <h3>Request Body</h3>
    <pre>${escapeHtml(pretty(request.body?.raw))}</pre>
    <h3>Response Body</h3>
    <pre>${escapeHtml(pretty(decodeStream(response.stream)))}</pre>
    <h3>Assertions</h3>
    <table>
      <thead><tr><th>Result</th><th>Assertion</th><th>Error</th></tr></thead>
      <tbody>${assertionRows}</tbody>
    </table>
  </section>`;
}).join("\n");

function databaseCheckSection(result) {
  if (!result) return "";

  const checks = Array.isArray(result.checks) ? result.checks : [];
  const statements = Array.isArray(result.statements) ? result.statements : [];
  const checkRows = checks.length
    ? checks.map(check => `
      <tr>
        <td>${escapeHtml(check.checkId ?? "n/a")}</td>
        <td class="${check.result === "PASS" ? "pass" : "fail"}">${escapeHtml(check.result ?? "n/a")}</td>
        <td>${escapeHtml(check.evidence ?? check.error ?? "")}</td>
      </tr>`).join("")
    : '<tr><td colspan="3">No DB check summary was recorded.</td></tr>';
  const statementBlocks = statements.length
    ? statements.map((statement, index) => `
      <details class="db-statement"${index === 0 ? " open" : ""}>
        <summary>SQL ${index + 1}: ${escapeHtml((statement.sql ?? "").replaceAll(/\s+/g, " ").trim())}</summary>
        <h3>SQL</h3>
        <pre>${escapeHtml(statement.sql ?? "")}</pre>
        <div class="columns">
          <div>
            <h3>Returned Columns</h3>
            <pre>${escapeHtml(prettyJson(statement.columns ?? []))}</pre>
          </div>
          <div>
            <h3>Returned Rows</h3>
            <pre>${escapeHtml(prettyJson(statement.rows ?? []))}</pre>
          </div>
        </div>
      </details>`).join("\n")
    : `<p class="db-note">This is a legacy DB result without captured SQL statements. Run this checkpoint again to collect SQL and returned rows.</p>`;

  return `
  <section id="database-check" class="request database-check ${result.status === "PASS" ? "" : "has-failure"}">
    <h2>Database Check: ${escapeHtml(result.checkpoint ?? "checkpoint")}</h2>
    <div class="meta">
      <span class="${result.status === "PASS" ? "pass" : "fail"}">${escapeHtml(result.status ?? "n/a")}</span>
      <span>Executed: ${escapeHtml(result.generatedAt ?? "n/a")}</span>
      <span>${statements.length} SQL statement(s)</span>
    </div>
    ${result.error ? `<p class="db-error">${escapeHtml(result.error)}</p>` : ""}
    <h3>Check Summary</h3>
    <table>
      <thead><tr><th>Check</th><th>Result</th><th>Evidence</th></tr></thead>
      <tbody>${checkRows}</tbody>
    </table>
    <h3>Executed SQL and Returned Results</h3>
    ${statementBlocks}
  </section>`;
}

const databaseSection = databaseCheckSection(databaseResult);

const times = executions.map(e => e.response?.responseTime).filter(t => typeof t === "number");
const avgTime = times.length ? Math.round(times.reduce((a,b) => a+b, 0) / times.length) : 0;
const maxTime = times.length ? Math.max(...times) : 0;

const requestNavigation = executions.map((execution, index) => {
  const failures = (execution.assertions ?? []).filter(assertion => assertion.error).length;
  const time = execution.response?.responseTime;
  const timeLabel = time !== undefined ? `${time}ms` : "n/a";
  const timeBadgeColor = time > 2000 ? "#b42318" : (time > 1000 ? "#b54708" : "#176b45");
  return `<li>
    <a href="#request-${index + 1}" style="overflow:hidden;text-overflow:ellipsis;white-space:nowrap;max-width:180px;" title="${escapeHtml(execution.item?.name ?? '')}">${String(index + 1).padStart(2, "0")}. ${escapeHtml(execution.item?.name ?? "Unnamed request")}</a>
    <div style="display:flex;gap:6px;align-items:center;flex-shrink:0;">
      <span style="font-size:11px;font-family:monospace;padding:1px 5px;border-radius:3px;background:#e8eef3;color:${timeBadgeColor};font-weight:600;">${timeLabel}</span>
      <span class="${failures ? "fail" : "pass"}">${failures ? "FAIL" : "PASS"}</span>
    </div>
  </li>`;
}).join("\n");

const navigation = `${requestNavigation}${databaseResult ? `
  <li class="db-nav">
    <a href="#database-check">Database Check: ${escapeHtml(databaseResult.checkpoint ?? "checkpoint")}</a>
    <span class="${databaseResult.status === "PASS" ? "pass" : "fail"}">${escapeHtml(databaseResult.status ?? "n/a")}</span>
  </li>` : ""}`;

const html = `<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>${escapeHtml(reportTitle)}</title>
  <style>
    :root { color-scheme: light; font-family: Arial, sans-serif; color: #17212b; background: #f4f6f8; }
    body { margin: 0; }
    header { padding: 24px 32px; color: #fff; background: #17324d; }
    header h1 { margin: 0 0 8px; font-size: 24px; }
    header p { margin: 4px 0; }
    .warning { padding: 12px 32px; color: #6b3c00; background: #fff0c2; border-bottom: 1px solid #e3c26b; font-weight: 700; }
    main { display: grid; grid-template-columns: minmax(280px, 340px) minmax(0, 1fr); gap: 20px; max-width: 1600px; margin: 0 auto; padding: 20px; }
    nav { position: sticky; top: 12px; align-self: start; max-height: calc(100vh - 24px); overflow: auto; background: #fff; border: 1px solid #d7dde3; border-radius: 6px; }
    nav h2 { margin: 0; padding: 16px; font-size: 16px; border-bottom: 1px solid #d7dde3; }
    nav ul { margin: 0; padding: 8px; list-style: none; }
    nav li { display: flex; gap: 8px; justify-content: space-between; align-items: center; padding: 7px 8px; border-bottom: 1px solid #edf0f2; }
    nav a { color: #1b5e92; text-decoration: none; }
    .request { margin-bottom: 20px; padding: 20px; background: #fff; border: 1px solid #d7dde3; border-radius: 6px; }
    .request.has-failure { border-color: #c62828; }
    .database-check { border-color: #3d6d91; }
    .db-nav { background: #edf5fa; }
    .db-statement { display: block; margin: 12px 0; border: 1px solid #d7dde3; border-radius: 4px; overflow: hidden; }
    .db-statement summary { padding: 10px 12px; cursor: pointer; color: #17324d; background: #edf2f5; font-family: monospace; font-size: 12px; }
    .db-statement h3, .db-statement > pre, .db-statement .columns { margin-left: 12px; margin-right: 12px; }
    .db-statement .columns { margin-bottom: 12px; }
    .db-note { padding: 10px 12px; color: #6b3c00; background: #fff7df; border-left: 4px solid #e3c26b; }
    .db-error { padding: 10px 12px; color: #b42318; background: #fff0f0; border-left: 4px solid #c62828; }
    h2 { margin-top: 0; font-size: 20px; }
    h3 { margin: 18px 0 6px; font-size: 14px; }
    .meta { display: flex; flex-wrap: wrap; gap: 8px; margin-bottom: 12px; }
    .meta span { padding: 4px 8px; background: #e8eef3; border-radius: 4px; font-size: 12px; }
    .meta .method { color: #fff; background: #176b45; font-weight: 700; }
    .meta .time { background: #d0e1fd; color: #0b4582; font-weight: 700; font-family: monospace; }
    .columns { display: grid; grid-template-columns: repeat(2, minmax(0, 1fr)); gap: 16px; }
    pre { box-sizing: border-box; max-height: 420px; margin: 0; padding: 12px; overflow: auto; color: #d9e4ee; background: #17212b; border-radius: 4px; white-space: pre-wrap; overflow-wrap: anywhere; }
    table { width: 100%; border-collapse: collapse; }
    th, td { padding: 8px; text-align: left; vertical-align: top; border: 1px solid #d7dde3; }
    th { background: #edf2f5; }
    td pre { max-height: 120px; padding: 6px; }
    .pass { color: #176b45; font-weight: 700; }
    .fail { color: #b42318; font-weight: 700; }
    @media (max-width: 900px) { main, .columns { grid-template-columns: 1fr; } nav { position: static; max-height: none; } }
  </style>
</head>
<body>
  <header>
    <h1>${escapeHtml(reportTitle)}</h1>
    <p>Generated: ${escapeHtml(generatedAt)}</p>
    <p>Evidence: ${isMock ? "Local Contract Mock / NOT QA EVIDENCE" : "Executed Newman result"}</p>
    <p>Requests: ${escapeHtml(stat(raw, "requests"))}; Assertions: ${escapeHtml(stat(raw, "assertions"))}</p>
    <p><strong>Response Time Stats:</strong> Average: <code style="background:#0d2338;padding:2px 6px;border-radius:3px;">${avgTime} ms</code> | Max: <code style="background:#0d2338;padding:2px 6px;border-radius:3px;">${maxTime} ms</code></p>
  </header>
  <div class="warning">${escapeHtml(evidenceLabel)}</div>
  <main>
    <nav><h2>Requests (with Duration)</h2><ul>${navigation}</ul></nav>
    <div>${sections}${databaseSection}</div>
  </main>
</body>
</html>
`;

fs.writeFileSync(output, html);
console.log(`Generated ${isMock ? "contract mock" : "private"} debug report: ${output}`);
