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
  const fromParts = path.dirname(path.resolve(outputPath)).split(path.sep).filter(Boolean);
  const targetParts = path.resolve(file).split(path.sep).filter(Boolean);
  let commonLength = 0;
  while (commonLength < fromParts.length
    && commonLength < targetParts.length
    && fromParts[commonLength].toLowerCase() === targetParts[commonLength].toLowerCase()) {
    commonLength += 1;
  }
  const relativeParts = [
    ...fromParts.slice(commonLength).map(() => ".."),
    ...targetParts.slice(commonLength)
  ];
  return relativeParts.join("/") || ".";
}

function artifactLink(file) {
  const fileName = path.basename(file);
  const parentDirectory = path.basename(path.dirname(file));
  if (parentDirectory === ".newman-private") return `../.newman-private/${fileName}`;
  if (parentDirectory === "reports") return fileName;
  return relativeLink(file);
}

function reasonHtml(value) {
  return String(value ?? "-")
    .split(" | ")
    .map(item => `<div class="reason-item">${escapeHtml(item)}</div>`)
    .join("");
}

const entries = fs.existsSync(manifestPath)
  ? fs.readFileSync(manifestPath, "utf8").trim().split("\n").filter(Boolean).map(line => {
      const [stage, type, status, ...files] = line.split("\t");
      return {stage, type, status, files};
    })
  : [];

const traceabilityPath = path.resolve(import.meta.dirname, "..", "..", "LEAD-93-405_AC_Traceability.json");
const traceability = JSON.parse(fs.readFileSync(traceabilityPath, "utf8"));
const scenarioPath = path.resolve(import.meta.dirname, "..", "..", "LEAD-93-405_Test_Scenarios.json");
const scenarioManifest = JSON.parse(fs.readFileSync(scenarioPath, "utf8"));
const codeModelPath = path.resolve(import.meta.dirname, "..", "..", "LEAD-93-405_API_Code_Models.json");
const codeModelManifest = JSON.parse(fs.readFileSync(codeModelPath, "utf8"));
const apiResults = new Map();
const dbResults = new Map();
const dbCheckpointErrors = new Map();

function executionEndpoint(execution) {
  const parts = execution.request?.url?.path;
  if (Array.isArray(parts)) return `/${parts.join("/")}`;
  const raw = String(execution.request?.url?.raw ?? "");
  const marker = raw.indexOf("/web/");
  return marker >= 0 ? raw.slice(marker).split("?")[0] : raw.split("?")[0];
}

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
      const httpStatus = Number(execution.response?.code ?? 0);
      const httpFailed = !httpStatus || httpStatus >= 400;
      const responseCode = (() => {
        const bytes = execution.response?.stream?.data;
        try { return Array.isArray(bytes) ? JSON.parse(Buffer.from(bytes).toString("utf8")).responseCode : undefined; } catch { return undefined; }
      })();
      const reason = [
        httpFailed ? `HTTP ${execution.response?.code ?? "n/a"}` : "",
        ...failedAssertions.map(assertion => `${assertion.assertion ?? "assertion"}: ${assertion.error?.message ?? JSON.stringify(assertion.error)}`)
      ].filter(Boolean).join("; ");
      apiResults.set(requestId, {
        status: assertionFailed || httpFailed ? "FAIL" : "PASS",
        reason,
        name: String(execution.item?.name ?? "").replace(/^\d+\s+/, ""),
        httpStatus,
        responseCode,
        endpoint: executionEndpoint(execution),
        failedAssertions: failedAssertions.map(assertion => assertion.assertion ?? "assertion")
      });
    }
  } catch { /* an unavailable raw report is represented as NOT RUN in the AC table */ }
}

function canonicalDbCheckId(value) {
  return String(value ?? "").match(/\bDB-\d+\b/)?.[0];
}

for (const entry of entries.filter(entry => entry.type === "db")) {
  try {
    const output = JSON.parse(fs.readFileSync(entry.files[0], "utf8"));
    for (const check of output.checks ?? []) {
      const checkId = canonicalDbCheckId(check.checkId);
      if (checkId) dbResults.set(checkId, {status: check.result, reason: check.evidence ?? ""});
    }
    if (output.error || entry.status !== "PASS") dbCheckpointErrors.set(entry.stage, output.error ?? "数据库检查点失败");
  } catch { /* an unavailable DB output is represented as NOT RUN in the AC table */ }
}

function checkpointForDbCheck(checkId) {
  const number = Number(String(checkId).match(/DB-(\d+)/)?.[1]);
  if (number >= 1 && number <= 7) return "template_metadata";
  if (number >= 8 && number <= 9) return "copy";
  if (number >= 10 && number <= 11) return "lifecycle";
  if ((number >= 12 && number <= 14) || (number >= 19 && number <= 22)) return "reassignment";
  if (number >= 15 && number <= 18) return "cleanup";
  return undefined;
}

function evaluateAc(ac) {
  if (ac.coverage === "UI") return {result: "N/A UI", css: "na", reason: "前端专属交互，不在后端 API/数据库回归范围。"};
  if (ac.coverage === "GAP") return {result: "NOT COVERED", css: "gap", reason: ac.note ?? "当前无可执行的确定性后端断言。"};
  const apiStates = (ac.api ?? []).map(id => ({id: `API-${id}`, ...apiResults.get(id)}));
  const dbStates = (ac.db ?? []).map(id => ({id, ...dbResults.get(canonicalDbCheckId(id))}));
  // A checkpoint may contain multiple independent DB assertions. Use the
  // individual assertion result whenever it exists; only mark it blocked when
  // the checkpoint failed before producing that specific DB-xx result.
  const blockedDb = (ac.db ?? []).map(checkId => ({checkId, checkpoint: checkpointForDbCheck(checkId)}))
    .filter(item => !dbResults.has(canonicalDbCheckId(item.checkId)) && item.checkpoint && dbCheckpointErrors.has(item.checkpoint));
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
  if (ac.coverage === "BACKEND_SCOPE") return {result: "PASS（后端范围）", css: "pass", reason: ac.note ?? "后端可验证规则已通过；其余为前端专属交互。"};
  return ac.coverage === "PARTIAL"
    ? {result: "PARTIAL PASS", css: "partial", reason: ac.note ?? "其余边界或前端部分未覆盖。"}
    : {result: "PASS", css: "pass", reason: "-"};
}

const acResults = traceability.map(ac => ({...ac, evaluation: evaluateAc(ac)}));

function acStepsHtml(references) {
  if (!references.length) return "-";
  return `<ol class="ac-step-list">${references.map(reference => `<li><strong>步骤 ${reference.stepNumber}</strong><br><span>${escapeHtml(reference.evidenceLabel)} · ${escapeHtml(reference.action)}</span></li>`).join("")}</ol>`;
}

function groupReferencesByScenario(references) {
  const groups = new Map();
  for (const reference of references) {
    const key = `${reference.scenario.number}:${reference.scenario.name}`;
    if (!groups.has(key)) groups.set(key, {scenario: reference.scenario, references: []});
    groups.get(key).references.push(reference);
  }
  return [...groups.values()];
}

function evidenceKey(evidence) {
  return `${evidence.type}:${evidence.id}`;
}

function evidenceLabel(evidence) {
  return evidence.type === "API" ? `API-${evidence.id}` : String(evidence.id);
}

function validateScenarioCoverage() {
  const scenarioStories = new Map((scenarioManifest.stories ?? []).map(story => [story.story, story]));
  const knownAcIds = new Set(traceability.map(ac => ac.id));
  const errors = [];
  for (const story of scenarioManifest.stories ?? []) {
    const scenarioNumbers = new Set();
    for (const [index, scenario] of (story.scenarios ?? []).entries()) {
      if (!Number.isInteger(scenario.number) || scenario.number < 1) {
        errors.push(`${story.story}/${scenario.name}: invalid scenario number`);
      } else if (scenarioNumbers.has(scenario.number)) {
        errors.push(`${story.story}: duplicate scenario number ${scenario.number}`);
      } else {
        scenarioNumbers.add(scenario.number);
      }
      if (scenario.number !== index + 1) {
        errors.push(`${story.story}/${scenario.name}: scenario number must be ${index + 1}`);
      }
      if (!(scenario.acIds ?? []).length) errors.push(`${story.story}/${scenario.name}: missing acIds`);
      for (const acId of scenario.acIds ?? []) if (!knownAcIds.has(acId)) errors.push(`${story.story}/${scenario.name}: unknown ${acId}`);
    }
  }
  for (const ac of traceability) {
    const story = scenarioStories.get(ac.story);
    if (!story) {
      errors.push(`${ac.story}: missing Story scenario definition`);
      continue;
    }
    const available = new Set((story.scenarios ?? [])
      .filter(scenario => (scenario.acIds ?? []).includes(ac.id))
      .flatMap(scenario => (scenario.steps ?? []).map(step => evidenceKey(step.evidence))));
    for (const id of ac.api ?? []) if (!available.has(`API:${id}`)) errors.push(`${ac.id}: missing API-${id}`);
    for (const id of ac.db ?? []) if (!available.has(`DB:${id}`)) errors.push(`${ac.id}: missing ${id}`);
  }
  if (errors.length) throw new Error(`Scenario traceability validation failed:\n${errors.join("\n")}`);
}

validateScenarioCoverage();

function stepStatus(step) {
  if (step.evidence.type === "API") {
    const result = apiResults.get(Number(step.evidence.id));
    if (!result) return {label: "NOT RUN", css: "na", reason: "未取得该接口的执行记录。"};
    if (result.status === "PASS") {
      const response = result.responseCode ? `responseCode=${result.responseCode}` : "响应已通过断言";
      return {label: "PASS", css: "pass", reason: `HTTP ${result.httpStatus}; ${response}`};
    }
    return {label: "FAIL", css: "fail", reason: result.reason || "接口执行或断言失败。"};
  }
  const result = dbResults.get(canonicalDbCheckId(step.evidence.id));
  if (!result) return {label: "NOT RUN", css: "na", reason: "未取得该数据库检查的执行记录。"};
  return result.status === "PASS"
    ? {label: "PASS", css: "pass", reason: result.reason || "数据库断言通过。"}
    : {label: "FAIL", css: "fail", reason: result.reason || "数据库断言失败。"};
}

function scenarioResult(steps) {
  const statuses = steps.map(step => stepStatus(step).label);
  if (statuses.includes("FAIL")) return {label: "FAIL", css: "fail"};
  if (statuses.every(status => status === "NOT RUN")) return {label: "NOT RUN", css: "na"};
  if (statuses.includes("NOT RUN")) return {label: "PARTIAL", css: "partial"};
  return {label: "PASS", css: "pass"};
}

function codeModelForEndpoint(endpoint) {
  return Object.entries(codeModelManifest.endpoints ?? {})
    .find(([pathSuffix]) => String(endpoint ?? "").endsWith(pathSuffix))?.[1];
}

function failureFocus(result) {
  const assertions = result?.failedAssertions ?? [];
  const hints = [];
  const includes = pattern => assertions.some(name => pattern.test(name));
  if (includes(/Business response|successful/i)) hints.push("Service 业务校验或状态流转");
  if (includes(/field errors|invalid fields|validation has no payload|displayable/i)) hints.push("错误响应 data 组装；不是成功 VO");
  if (includes(/identifier|numeric|schema|field|returned/i)) hints.push("成功响应 VO 的字段赋值与序列化");
  if (includes(/appears|filter|finds|list/i)) hints.push("查询 Service/Mapper 与列表项 VO");
  if ((result?.httpStatus ?? 0) >= 400) hints.push("Controller、鉴权或网关");
  return [...new Set(hints)].join("；") || "根据失败断言检查响应组装";
}

function codeLocatorHtml(step, status) {
  if (step.evidence.type !== "API" || status.label !== "FAIL") return "-";
  const result = apiResults.get(Number(step.evidence.id));
  const model = codeModelForEndpoint(result?.endpoint);
  if (!model) return '<span class="model-open">当前 Endpoint 尚无代码模型映射</span>';
  const request = model.requestModel ? `<code>${escapeHtml(model.requestModel)}</code>` : '<span class="model-open">待当前代码核对</span>';
  const response = model.successDataModel ? `<code>${escapeHtml(model.successDataModel)}</code>` : '<span class="model-open">待当前代码核对</span>';
  const verificationLabel = {
    VERIFIED: "已确认",
    CODE_SNAPSHOT: "代码快照",
    MIXED: "部分已确认",
    OPEN: "待核对"
  }[model.verification] ?? model.verification;
  return `<div class="model-locator"><div><strong>请求：</strong>${request}</div><div><strong>成功 data：</strong>${response}</div><div><strong>优先排查：</strong>${escapeHtml(failureFocus(result))}</div><div class="model-source">${escapeHtml(verificationLabel)} · ${escapeHtml(model.source)}</div></div>`;
}

function storyAnchor(story) {
  return `story-${String(story).replaceAll(/[^A-Za-z0-9_-]/g, "-")}`;
}

function storyOverview(story) {
  const all = acResults.filter(ac => ac.story === story);
  const applicable = all.filter(ac => ac.coverage !== "UI");
  const outcomes = applicable.map(ac => ac.evaluation.result);
  const passed = outcomes.filter(result => result === "PASS" || result === "PASS（后端范围）").length;
  if (!applicable.length) return {label: "N/A UI", css: "na", summary: `AC ${all.length}；均为前端范围`};
  if (outcomes.includes("FAIL")) return {label: "FAIL", css: "fail", summary: `AC ${all.length}；后端已通过 ${passed}/${applicable.length}`};
  if (outcomes.includes("NOT RUN")) return {label: "NOT RUN", css: "na", summary: `AC ${all.length}；后端已通过 ${passed}/${applicable.length}`};
  if (outcomes.includes("PARTIAL PASS") || outcomes.includes("NOT COVERED")) {
    return {label: "PARTIAL PASS", css: "partial", summary: `AC ${all.length}；后端已通过 ${passed}/${applicable.length}`};
  }
  if (outcomes.includes("NOT RUN (OPTIONAL)")) {
    return {label: "PASS（条件项未执行）", css: "partial", summary: `AC ${all.length}；后端已通过 ${passed}/${applicable.length}`};
  }
  return {label: "PASS", css: "pass", summary: `AC ${all.length}；后端已通过 ${passed}/${applicable.length}`};
}

const storySections = (scenarioManifest.stories ?? []).map(storyDefinition => {
  const story = storyDefinition.story;
  const storyAcs = acResults.filter(ac => ac.story === story);
  const stepReferences = [];
  const scenarioBlocks = (storyDefinition.scenarios ?? []).map(scenario => {
    const result = scenarioResult(scenario.steps ?? []);
    const rows = (scenario.steps ?? []).map((step, index) => {
      const reference = {
        scenario,
        stepNumber: index + 1,
        evidenceLabel: evidenceLabel(step.evidence),
        action: step.action,
        evidenceKey: evidenceKey(step.evidence)
      };
      stepReferences.push(reference);
      const status = stepStatus(step);
      return `<tr><td>步骤 ${index + 1}</td><td>${escapeHtml(reference.evidenceLabel)}</td><td>${escapeHtml(step.action)}</td><td class="${status.css}">${status.label}</td><td class="reason">${reasonHtml(status.reason)}</td><td>${codeLocatorHtml(step, status)}</td></tr>`;
    }).join("\n");
    return `<section class="scenario"><h3><span class="scenario-number">场景 ${scenario.number}</span>${escapeHtml(scenario.name)} <span class="${result.css}">${result.label}</span></h3><p class="precondition"><strong>前置条件：</strong>${escapeHtml(scenario.precondition)}</p><table><thead><tr><th>步骤</th><th>执行证据</th><th>测试动作</th><th>步骤结果</th><th>执行说明</th><th>代码定位</th></tr></thead><tbody>${rows}</tbody></table></section>`;
  }).join("\n");
  const acRows = storyAcs.map(ac => {
    const evidence = [
      ...(ac.api ?? []).map(id => ({type: "API", id})),
      ...(ac.db ?? []).map(id => ({type: "DB", id}))
    ];
    const expectedKeys = new Set(evidence.map(evidenceKey));
    const references = stepReferences.filter(reference =>
      (reference.scenario.acIds ?? []).includes(ac.id) && expectedKeys.has(reference.evidenceKey)
    );
    const groups = groupReferencesByScenario(references);
    const rows = groups.length ? groups : [{scenario: null, references: []}];
    return rows.map((group, index) => {
      const shared = index === 0
        ? `<td rowspan="${rows.length}">${escapeHtml(ac.id.replace(`${story} `, ""))}</td><td rowspan="${rows.length}">${escapeHtml(ac.requirement)}</td>`
        : "";
      const outcome = index === 0
        ? `<td rowspan="${rows.length}" class="${ac.evaluation.css}">${escapeHtml(ac.evaluation.result)}</td><td rowspan="${rows.length}" class="reason">${reasonHtml(ac.evaluation.reason)}</td>`
        : "";
      const scenarioName = group.scenario
        ? `<strong>场景 ${group.scenario.number}</strong><br>${escapeHtml(group.scenario.name)}`
        : "-";
      return `<tr>${shared}<td class="scenario-name">${scenarioName}</td><td>${acStepsHtml(group.references)}</td>${outcome}</tr>`;
    }).join("\n");
  }).join("\n");
  return `<section id="${escapeHtml(storyAnchor(story))}" class="story"><h2>${escapeHtml(story)}</h2><p class="story-note">以下场景和步骤来自显式测试场景基线；API 和数据库执行证据可以被多个 AC 复用，但步骤顺序不会动态改变。</p>${scenarioBlocks || '<p class="note">该 Story 当前没有可执行的后端场景。</p>'}<h3>AC 与固定场景步骤映射</h3><div class="scroll"><table><thead><tr><th>AC</th><th>验收要求</th><th>关联场景</th><th>对应步骤</th><th>AC 结果</th><th>结论依据</th></tr></thead><tbody>${acRows}</tbody></table></div></section>`;
}).join("\n");

const storyOverviewRows = (scenarioManifest.stories ?? []).map(storyDefinition => {
  const summary = storyOverview(storyDefinition.story);
  return `<tr><td><a href="#${escapeHtml(storyAnchor(storyDefinition.story))}">${escapeHtml(storyDefinition.story)}</a></td><td>${escapeHtml(summary.summary)}</td><td class="${summary.css}">${escapeHtml(summary.label)}</td><td><a href="#${escapeHtml(storyAnchor(storyDefinition.story))}">查看详细场景与 AC</a></td></tr>`;
}).join("\n");
const coverageGaps = acResults.filter(ac => ["GAP", "PARTIAL"].includes(ac.coverage)).length;
const hardFailures = acResults.filter(ac => ac.coverage === "FULL" && ac.evaluation.result !== "PASS").length;

const apiRows = entries.filter(entry => entry.type === "api").map(entry => {
  const [raw, debug, summary, classification] = entry.files;
  let stats = {};
  let classificationDetail = {};
  try { stats = JSON.parse(fs.readFileSync(raw, "utf8")).run?.stats ?? {}; } catch { /* report keeps the stage even after a partial failure */ }
  try { classificationDetail = JSON.parse(fs.readFileSync(classification, "utf8")); } catch { /* report shows unavailable evidence below */ }
  const requests = stats.requests ? `${stats.requests.total ?? 0}/${stats.requests.failed ?? 0} failed` : "n/a";
  const assertions = stats.assertions ? `${stats.assertions.total ?? 0}/${stats.assertions.failed ?? 0} failed` : "n/a";
  const issueCount = classificationDetail.assertionIssues?.length ?? 0;
  const blocking = classificationDetail.blockingFailures?.map(item => `${item.request}: ${item.reason}`).join(" | ") || "-";
  const css = entry.status === "PASS" ? "pass" : entry.status === "ISSUES" ? "partial" : "fail";
  return `<tr><td>${escapeHtml(entry.stage)}</td><td class="${css}">${escapeHtml(entry.status)}</td><td>${requests}</td><td>${assertions}</td><td>${issueCount}</td><td class="reason">${reasonHtml(blocking)}</td><td><a href="${escapeHtml(artifactLink(debug))}">Private Debug</a> | <a href="${escapeHtml(artifactLink(summary))}">Sanitized Summary</a></td></tr>`;
}).join("\n");

const debugReportByStage = new Map(entries
  .filter(entry => entry.type === "api")
  .map(entry => [entry.stage, entry.files[1]]));

function stageForCheckpoint(checkpoint) {
  return {
    template_metadata: "03 Template and Metadata",
    copy: "04A Copy Independence",
    lifecycle: "04B Version Lifecycle",
    reassignment: "05 Reassignment and Delete",
    cleanup: "99 Cleanup"
  }[checkpoint];
}

const dbBlocks = entries.filter(entry => entry.type === "db").map(entry => {
  const [resultPath] = entry.files;
  let result = {status: entry.status, checks: [{checkId: "DB output unavailable", result: "FAIL", evidence: resultPath ?? ""}]};
  try { result = JSON.parse(fs.readFileSync(resultPath, "utf8")); } catch { /* handled by fallback */ }
  const rows = (result.checks ?? []).map(check => `<tr><td>${escapeHtml(check.checkId)}</td><td class="${check.result === "PASS" ? "pass" : "fail"}">${escapeHtml(check.result)}</td><td><code>${escapeHtml(check.evidence)}</code></td></tr>`).join("\n");
  const error = result.error ? `<p class="fail">检查点错误：${escapeHtml(result.error)}</p>` : "";
  const stage = stageForCheckpoint(entry.stage);
  const debugReport = stage ? debugReportByStage.get(stage) : undefined;
  const detailLink = debugReport
    ? `<p class="db-detail-link"><a href="${escapeHtml(artifactLink(debugReport))}#database-check">查看 ${escapeHtml(stage)} 的完整 API + SQL 调试证据</a></p>`
    : '<p class="note">未找到对应阶段调试报告，无法跳转查看完整 SQL 证据。</p>';
  return `<section><h3>${escapeHtml(entry.stage)} <span class="${result.status === "PASS" ? "pass" : "fail"}">${escapeHtml(result.status)}</span></h3>${error}<table><thead><tr><th>Check</th><th>Result</th><th>Evidence</th></tr></thead><tbody>${rows}</tbody></table>${detailLink}</section>`;
}).join("\n");

const optionalRows = acResults.filter(ac => ac.coverage === "CONDITIONAL").map(ac => {
  const evidence = [
    ...(ac.api ?? []).map(id => `API-${id}`),
    ...(ac.db ?? [])
  ].join("、") || "-";
  const executed = (ac.api ?? []).some(id => apiResults.has(id))
    || (ac.db ?? []).some(id => dbResults.has(canonicalDbCheckId(id)));
  const status = executed ? ac.evaluation.result : "NOT RUN (OPTIONAL)";
  const reason = executed
    ? ac.evaluation.reason
    : "本轮未启用权限测试。";
  return `<tr><td>${escapeHtml(ac.story)}</td><td>${escapeHtml(ac.id.replace(`${ac.story} `, ""))}</td><td>${escapeHtml(ac.requirement)}</td><td>${escapeHtml(evidence)}</td><td class="${ac.evaluation.css}">${escapeHtml(status)}</td><td class="reason">${reasonHtml(reason)}</td><td class="reason">${reasonHtml(ac.note ?? "需按测试环境配置启用。")}</td></tr>`;
}).join("\n");

const hasBlocked = entries.some(entry => entry.type === "api" && entry.status === "BLOCKED");
const hasIssues = entries.some(entry => entry.status === "ISSUES");
const hasVerificationFailures = hardFailures || entries.some(entry => entry.type === "db" && entry.status !== "PASS");
const pipelinePass = entries.length > 0 && !hasBlocked;
const overallLabel = hasBlocked ? "BLOCKED" : hasVerificationFailures ? "COMPLETED WITH VERIFICATION FAILURES" : hasIssues ? "COMPLETED WITH CONTRACT ISSUES" : coverageGaps ? "PASS WITH COVERAGE GAPS" : "PASS";
const overallCss = overallLabel === "PASS" ? "pass" : overallLabel.includes("ISSUES") || overallLabel.includes("GAPS") ? "partial" : "fail";
const report = `<!doctype html>
<html lang="zh-CN"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1"><title>LEAD-93 / LEAD-405 后端 AC 联合报告</title>
<style>body{margin:0;background:#f5f7f8;color:#17212b;font:14px Arial,sans-serif}header{padding:24px 32px;background:#17324d;color:#fff}main{max-width:1560px;margin:auto;padding:24px}section{margin:20px 0;padding:20px;background:#fff;border:1px solid #d7dde3;border-radius:6px}h1,h2,h3{margin-top:0}table{width:100%;border-collapse:collapse}th,td{padding:9px;text-align:left;vertical-align:top;border:1px solid #d7dde3}th{background:#edf2f5}.pass{color:#176b45;font-weight:700}.fail{color:#b42318;font-weight:700}.partial{color:#9a6700;font-weight:700}.na{color:#5c6b78;font-weight:700}.gap{color:#7a1e00;font-weight:700}code{overflow-wrap:anywhere}a{color:#145d92}.note{color:#6b3c00;background:#fff0c2;padding:12px;border-radius:4px}.story-overview{border-top:4px solid #17324d}.story-overview td:first-child{font-weight:700;white-space:nowrap}.db-detail-link{margin:12px 0 0;padding:10px 12px;background:#edf5fa;border-left:4px solid #2b6f95}.scroll{overflow-x:auto}.story{border-top:4px solid #2b6f95;scroll-margin-top:16px}.story-note{margin:-4px 0 16px;color:#51616f}.scenario{margin:14px 0;padding:14px;border:1px solid #cddae3;background:#fbfdfe;overflow-x:auto}.scenario h3{margin:0 0 8px}.scenario-number{display:inline-block;min-width:58px;margin-right:10px;color:#145d92;font-size:12px;font-weight:700}.precondition{margin:0 0 12px;color:#43515c}.reason{min-width:240px;line-height:1.45;overflow-wrap:anywhere}.reason-item+.reason-item{margin-top:7px;padding-top:7px;border-top:1px solid #edf0f2}.scenario-name{min-width:180px;background:#f7fafb;line-height:1.4}.scenario-name strong{color:#145d92}.ac-step-list{min-width:300px;margin:0;padding-left:20px}.ac-step-list li{margin:0 0 8px;line-height:1.4}.ac-step-list li:last-child{margin-bottom:0}.ac-step-list span{color:#43515c}.model-locator{min-width:260px;line-height:1.45}.model-locator>div+div{margin-top:4px}.model-source{margin-top:7px!important;color:#5c6b78;font-size:12px}.model-open{color:#9a6700}</style></head>
<body><header><h1>LEAD-93 / LEAD-405 后端 AC 联合报告</h1><p>生成时间：${escapeHtml(new Date().toISOString())}</p><p>总结果：<strong class="${overallCss}">${overallLabel}</strong></p></header>
<main><p class="note">本报告不保存密码、Token 或完整请求/响应。场景和固定步骤来自 LEAD-93-405_Test_Scenarios.json；失败步骤的代码模型来自 LEAD-93-405_API_Code_Models.json。“代码快照”表示类名尚未用当前远程源码复核，不得当作最终重命名依据。完整 API 调试证据位于测试机私有目录，链接仅适用于同一目录结构。</p>
<section class="story-overview"><h2>Story 总览</h2><p>结论以本轮后端 API 与数据库证据为准；前端专属 AC 不计为后端失败，条件权限用例未启用时单独标识。</p><table><thead><tr><th>Story</th><th>AC 覆盖摘要</th><th>本轮结论</th><th>跳转</th></tr></thead><tbody>${storyOverviewRows || '<tr><td colspan="4">尚未定义 Story 场景。</td></tr>'}</tbody></table></section>
${storySections}
<section><h2>API 阶段</h2><p><strong>ISSUES</strong> 表示请求已继续执行，但响应格式或其他断言不符合约定；<strong>BLOCKED</strong> 表示关键前置调用未成功，后续依赖阶段已停止，以避免无效请求或脏数据。</p><table><thead><tr><th>阶段</th><th>结果</th><th>Requests</th><th>Assertions</th><th>契约问题数</th><th>阻断原因</th><th>证据</th></tr></thead><tbody>${apiRows || '<tr><td colspan="7">尚未执行 API 阶段</td></tr>'}</tbody></table></section>
<section><h2>数据库只读断言</h2><p>本页只保留检查结论和证据摘要；逐条 SQL、返回列和原始返回行请进入对应阶段的 Private Debug 报告查看。</p>${dbBlocks || '<p>尚未执行数据库断言。</p>'}</section>
<section><h2>可选项未测试</h2><p>仅列出需要额外 Adviser 登录态或显式开关的条件用例；前端专属 AC 不计入本表。</p><div class="scroll"><table><thead><tr><th>Story</th><th>AC</th><th>验收要求</th><th>关联证据</th><th>本轮状态</th><th>未执行/结果说明</th><th>启用条件</th></tr></thead><tbody>${optionalRows || '<tr><td colspan="7">本轮没有条件用例。</td></tr>'}</tbody></table></div></section></main></body></html>`;

fs.writeFileSync(outputPath, report);
console.log(`Generated combined report: ${outputPath}`);
