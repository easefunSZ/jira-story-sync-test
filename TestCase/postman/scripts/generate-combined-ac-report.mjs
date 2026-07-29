import fs from "node:fs";
import path from "node:path";

const [manifestPath, outputPath] = process.argv.slice(2);
if (!manifestPath || !outputPath) {
  console.error("Usage: node generate-combined-ac-report.mjs <manifest.tsv> <report.html>");
  process.exit(2);
}

function escapeHtml(value) {
  return String(value ?? "")
    .replaceAll("&", "&amp;")
    .replaceAll("<", "&lt;")
    .replaceAll(">", "&gt;")
    .replaceAll('"', "&quot;")
    .replaceAll("'", "&#039;");
}

function relativeLink(file) {
  return path.relative(path.dirname(outputPath), file).split(path.sep).join("/");
}

const entries = fs.existsSync(manifestPath)
  ? fs.readFileSync(manifestPath, "utf8").trim().split("\n").filter(Boolean).map(line => {
      const [stage, type, status, ...files] = line.split("\t");
      return {stage, type, status, files};
    })
  : [];

const traceabilityPath = path.resolve(import.meta.dirname, "..", "..", "LEAD-93-405_AC_Traceability.json");
const traceability = JSON.parse(fs.readFileSync(traceabilityPath, "utf8"));
const apiResults = new Map();
const dbResults = new Map();
const dbCheckpointErrors = new Map();

for (const entry of entries.filter(entry => entry.type === "api")) {
  const [raw] = entry.files;
  try {
    const executions = JSON.parse(fs.readFileSync(raw, "utf8")).run?.executions ?? [];
    for (const execution of executions) {
      const match = String(execution.item?.name ?? "").match(/^(\d+)\s/);
      if (!match) continue;
      const requestId = Number(match[1]);
      const failedAssertions = (execution.assertions ?? []).filter(assertion => assertion.error);
      const assertionFailed = failedAssertions.length > 0;
      const httpFailed = Number(execution.response?.code ?? 0) >= 400;
      const reason = [
        httpFailed ? `HTTP ${execution.response?.code ?? "n/a"}` : "",
        ...failedAssertions.map(assertion => `${assertion.assertion ?? "assertion"}: ${assertion.error?.message ?? JSON.stringify(assertion.error)}`)
      ].filter(Boolean).join("; ");
      apiResults.set(requestId, {status: assertionFailed || httpFailed ? "FAIL" : "PASS", reason});
    }
  } catch { /* an unavailable raw report is represented as NOT RUN in the AC table */ }
}

for (const entry of entries.filter(entry => entry.type === "db")) {
  try {
    const output = JSON.parse(fs.readFileSync(entry.files[0], "utf8"));
    for (const check of output.checks ?? []) dbResults.set(check.checkId, {status: check.result, reason: check.evidence ?? ""});
    if (output.error || entry.status !== "PASS") dbCheckpointErrors.set(entry.stage, output.error ?? "数据库检查点失败");
  } catch { /* an unavailable DB output is represented as NOT RUN in the AC table */ }
}

function checkpointForDbCheck(checkId) {
  const number = Number(String(checkId).match(/DB-(\d+)/)?.[1]);
  if (number >= 1 && number <= 7) return "template_metadata";
  if (number >= 8 && number <= 9) return "copy";
  if (number >= 10 && number <= 11) return "lifecycle";
  if (number >= 12 && number <= 14) return "reassignment";
  if (number >= 15 && number <= 17) return "cleanup";
  return undefined;
}

function evaluateAc(ac) {
  if (ac.coverage === "UI") return {result: "N/A UI", css: "na", reason: "前端专属交互，不在后端 API/数据库回归范围。"};
  if (ac.coverage === "GAP") return {result: "NOT COVERED", css: "gap", reason: ac.note ?? "当前无可执行的确定性后端断言。"};
  const apiStates = (ac.api ?? []).map(id => ({id: `API-${id}`, ...apiResults.get(id)}));
  const dbStates = (ac.db ?? []).map(id => ({id, ...dbResults.get(id)}));
  const blockedDb = (ac.db ?? []).map(checkId => ({checkId, checkpoint: checkpointForDbCheck(checkId)})).filter(item => item.checkpoint && dbCheckpointErrors.has(item.checkpoint));
  const failed = [...apiStates, ...dbStates].filter(state => state.status === "FAIL");
  if (failed.length || blockedDb.length) {
    const reasons = [
      ...failed.map(state => `${state.id}: ${state.reason || "验证失败"}`),
      ...blockedDb.map(item => `${item.checkId}: ${dbCheckpointErrors.get(item.checkpoint)}`)
    ];
    return {result: "FAIL", css: "fail", reason: reasons.join(" | ")};
  }
  const missing = [...apiStates, ...dbStates].filter(state => state.status === undefined);
  if (missing.length) {
    const prefix = ac.coverage === "CONDITIONAL" ? "条件用例未执行" : "未取得执行证据";
    return {result: ac.coverage === "CONDITIONAL" ? "NOT RUN (OPTIONAL)" : "NOT RUN", css: "na", reason: `${prefix}: ${missing.map(state => state.id).join(", ")}`};
  }
  return ac.coverage === "PARTIAL"
    ? {result: "PARTIAL PASS", css: "partial", reason: ac.note ?? "其余边界或前端部分未覆盖。"}
    : {result: "PASS", css: "pass", reason: "-"};
}

const acResults = traceability.map(ac => ({...ac, evaluation: evaluateAc(ac)}));
const acRows = acResults.map(ac => `<tr><td>${escapeHtml(ac.story)}</td><td>${escapeHtml(ac.id.replace(`${ac.story} `, ""))}</td><td>${escapeHtml(ac.requirement)}</td><td>${escapeHtml((ac.api ?? []).map(id => `API-${id}`).join(", ") || "-")}</td><td>${escapeHtml((ac.db ?? []).join(", ") || "-")}</td><td>${escapeHtml(ac.coverage)}</td><td class="${ac.evaluation.css}">${escapeHtml(ac.evaluation.result)}</td><td>${escapeHtml(ac.evaluation.reason)}</td></tr>`).join("\n");
const coverageGaps = acResults.filter(ac => ["GAP", "PARTIAL"].includes(ac.coverage)).length;
const hardFailures = acResults.filter(ac => ac.coverage === "FULL" && ac.evaluation.result !== "PASS").length;

const apiRows = entries.filter(entry => entry.type === "api").map(entry => {
  const [raw, debug, summary] = entry.files;
  let stats = {};
  try { stats = JSON.parse(fs.readFileSync(raw, "utf8")).run?.stats ?? {}; } catch { /* report keeps the stage even after a partial failure */ }
  const requests = stats.requests ? `${stats.requests.total ?? 0}/${stats.requests.failed ?? 0} failed` : "n/a";
  const assertions = stats.assertions ? `${stats.assertions.total ?? 0}/${stats.assertions.failed ?? 0} failed` : "n/a";
  return `<tr><td>${escapeHtml(entry.stage)}</td><td class="${entry.status === "PASS" ? "pass" : "fail"}">${escapeHtml(entry.status)}</td><td>${requests}</td><td>${assertions}</td><td><a href="${escapeHtml(relativeLink(debug))}">Private Debug</a> | <a href="${escapeHtml(relativeLink(summary))}">Sanitized Summary</a></td></tr>`;
}).join("\n");

const dbBlocks = entries.filter(entry => entry.type === "db").map(entry => {
  const [resultPath] = entry.files;
  let result = {status: entry.status, checks: [{checkId: "DB output unavailable", result: "FAIL", evidence: resultPath ?? ""}]};
  try { result = JSON.parse(fs.readFileSync(resultPath, "utf8")); } catch { /* handled by fallback */ }
  const rows = (result.checks ?? []).map(check => `<tr><td>${escapeHtml(check.checkId)}</td><td class="${check.result === "PASS" ? "pass" : "fail"}">${escapeHtml(check.result)}</td><td><code>${escapeHtml(check.evidence)}</code></td></tr>`).join("\n");
  const error = result.error ? `<p class="fail">检查点错误：${escapeHtml(result.error)}</p>` : "";
  return `<section><h3>${escapeHtml(entry.stage)} <span class="${result.status === "PASS" ? "pass" : "fail"}">${escapeHtml(result.status)}</span></h3>${error}<table><thead><tr><th>Check</th><th>Result</th><th>Evidence</th></tr></thead><tbody>${rows}</tbody></table></section>`;
}).join("\n");

const pipelinePass = entries.length > 0 && entries.every(entry => entry.status === "PASS");
const overallLabel = !pipelinePass || hardFailures ? "FAIL / INCOMPLETE" : coverageGaps ? "PASS WITH COVERAGE GAPS" : "PASS";
const overallCss = overallLabel === "PASS" ? "pass" : overallLabel === "PASS WITH COVERAGE GAPS" ? "partial" : "fail";
const report = `<!doctype html>
<html lang="zh-CN"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1"><title>LEAD-93 / LEAD-405 后端 AC 联合报告</title>
<style>body{margin:0;background:#f5f7f8;color:#17212b;font:14px Arial,sans-serif}header{padding:24px 32px;background:#17324d;color:#fff}main{max-width:1440px;margin:auto;padding:24px}section{margin:20px 0;padding:20px;background:#fff;border:1px solid #d7dde3;border-radius:6px}h1,h2,h3{margin-top:0}table{width:100%;border-collapse:collapse}th,td{padding:9px;text-align:left;vertical-align:top;border:1px solid #d7dde3}th{background:#edf2f5}.pass{color:#176b45;font-weight:700}.fail{color:#b42318;font-weight:700}.partial{color:#9a6700;font-weight:700}.na{color:#5c6b78;font-weight:700}.gap{color:#7a1e00;font-weight:700}code{overflow-wrap:anywhere}a{color:#145d92}.note{color:#6b3c00;background:#fff0c2;padding:12px;border-radius:4px}.scroll{overflow-x:auto}</style></head>
<body><header><h1>LEAD-93 / LEAD-405 后端 AC 联合报告</h1><p>生成时间：${escapeHtml(new Date().toISOString())}</p><p>总结果：<strong class="${overallCss}">${overallLabel}</strong></p></header>
<main><p class="note">本报告不保存密码、Token 或完整请求/响应。完整 API 调试证据位于测试机私有目录，链接仅适用于同一目录结构。</p>
<section><h2>逐条 Acceptance Criteria 评估</h2><p>FULL 表示当前后端 AC 已映射到 API/数据库断言；PARTIAL 和 NOT COVERED 是明确可见的测试缺口，N/A UI 表示该 AC 只能由前端验收。失败原因来自 Newman 实际断言或数据库检查结果。</p><div class="scroll"><table><thead><tr><th>Story</th><th>AC</th><th>验收要求</th><th>Postman 用例</th><th>数据库断言</th><th>覆盖度</th><th>验证结果</th><th>错误原因 / 未执行原因</th></tr></thead><tbody>${acRows}</tbody></table></div></section>
<section><h2>API 阶段</h2><table><thead><tr><th>阶段</th><th>结果</th><th>Requests</th><th>Assertions</th><th>证据</th></tr></thead><tbody>${apiRows || '<tr><td colspan="5">尚未执行 API 阶段</td></tr>'}</tbody></table></section>
<section><h2>数据库只读断言</h2>${dbBlocks || '<p>尚未执行数据库断言。</p>'}</section></main></body></html>`;

fs.writeFileSync(outputPath, report);
console.log(`Generated combined report: ${outputPath}`);
