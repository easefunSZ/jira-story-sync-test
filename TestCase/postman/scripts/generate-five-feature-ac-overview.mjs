import fs from "node:fs";
import path from "node:path";

const [existingReport, adviserSummaryPath, adviserDebug, outputPath, coreStatusArgument = "1"] = process.argv.slice(2);
if (![existingReport, adviserSummaryPath, adviserDebug, outputPath].every(Boolean)) {
  console.error("Usage: node generate-five-feature-ac-overview.mjs <93-405-report.html> <adviser-summary.json> <adviser-debug.html> <output.html>");
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

function linkTo(target) {
  return path.relative(path.dirname(path.resolve(outputPath)), path.resolve(target)).split(path.sep).join("/");
}

let adviser = {stats: {assertions: {failed: 1}}, executions: []};
try { adviser = JSON.parse(fs.readFileSync(adviserSummaryPath, "utf8")); } catch { /* visible as failed evidence below */ }
const failed = Number(adviser.stats?.assertions?.failed ?? 1);
const executed = Number(adviser.stats?.requests?.total ?? 0);
const adviserStatus = executed > 0 && failed === 0 ? "PASS" : "FAIL";
const adviserCss = adviserStatus === "PASS" ? "pass" : "fail";
const coreStatus = Number(coreStatusArgument) === 0 ? "PASS" : "FAIL";
const rows = [
  ["LEAD-93", "LEAD-277, 301, 306, 307", "基础模型、创建、分类维护", coreStatus, "详细 API + DB AC 报告", "详见 LEAD-93/405 报告"],
  ["LEAD-405", "LEAD-276, 278, 293, 300", "重分配、Copy、分类、Tag", coreStatus, "详细 API + DB AC 报告", "详见 LEAD-93/405 报告"],
  ["LEAD-406", "LEAD-279, 296, 326, 327, 328", "生命周期、删除、预览、搜索、迁移", "部分已执行", "生命周期/发布校验复用 93/405；其余按 OPEN 管理", "Delete、迁移、搜索精确契约待冻结"],
  ["LEAD-308", "LEAD-312--318", "Adviser 列表、目录、搜索、筛选、排序", adviserStatus, `${executed} requests, ${failed} failed assertions`, "排序规则待冻结；页面交互由前端验收"],
  ["LEAD-407", "LEAD-319, 320, 321", "Adviser 预览、上下文、激活", adviserStatus, "复用 Adviser Detail / Preview 数据验证", "Activation 下游 Contract 未冻结"],
];

const executionRows = (adviser.executions ?? []).map(execution => {
  const status = (execution.assertions ?? []).some(assertion => !assertion.passed && !assertion.skipped) ? "FAIL" : "PASS";
  return `<tr><td>${escapeHtml(execution.name)}</td><td><code>${escapeHtml(execution.method)} ${escapeHtml(execution.endpoint)}</code></td><td class="${status === "PASS" ? "pass" : "fail"}">${status}</td><td>${escapeHtml(execution.businessCode ?? "-")}</td></tr>`;
}).join("");

const html = `<!doctype html><html lang="zh-CN"><head><meta charset="utf-8"><title>LEAD-93/405/406/407/308 后端 AC 验证总览</title>
<style>body{margin:0;background:#f5f7f8;color:#17212b;font:14px Arial,sans-serif}header{padding:24px 32px;background:#17324d;color:#fff}main{max-width:1560px;margin:auto;padding:24px}section{margin:20px 0;padding:20px;background:#fff;border:1px solid #d7dde3;border-radius:6px}h1,h2{margin-top:0}table{width:100%;border-collapse:collapse}th,td{padding:9px;text-align:left;vertical-align:top;border:1px solid #d7dde3}th{background:#edf2f5}.pass{color:#176b45;font-weight:700}.fail{color:#b42318;font-weight:700}.partial{color:#9a6700;font-weight:700}.open{color:#7a1e00;font-weight:700}.note{color:#6b3c00;background:#fff0c2;padding:12px;border-radius:4px}a{color:#145d92}code{overflow-wrap:anywhere}</style></head><body>
<header><h1>LEAD-93 / 405 / 406 / 407 / 308 后端 AC 验证总览</h1><p>执行证据按 LEAD-93/405 的 Newman、DB checkpoint、阶段 Debug 和联合报告标准生成。</p></header><main>
<section><h2>范围结论</h2><p class="note">本页是跨 Feature 导航页，不替代逐条 AC 报告。LEAD-93/405 的每条 AC、场景、步骤和 DB 证据位于详细报告；Adviser 请求的 URL、请求、响应和断言位于阶段 Debug。没有冻结后端 Contract 的 AC 保持 OPEN，纯页面行为保持 N/A UI。</p><table><thead><tr><th>Feature</th><th>Story</th><th>范围</th><th>本轮状态</th><th>执行证据</th><th>边界/待确认</th></tr></thead><tbody>${rows.map(row => `<tr><td>${row[0]}</td><td>${row[1]}</td><td>${row[2]}</td><td class="${row[3] === "PASS" ? "pass" : row[3] === "FAIL" ? "fail" : "partial"}">${row[3]}</td><td>${row[4]}</td><td>${row[5]}</td></tr>`).join("")}</tbody></table></section>
<section><h2>详细证据</h2><ul><li><a href="${escapeHtml(linkTo(existingReport))}">LEAD-93/405 逐条 AC、场景、API 和 DB 报告</a></li><li><a href="${escapeHtml(linkTo(adviserDebug))}">LEAD-308/407 Adviser 阶段 Debug（请求、响应和断言）</a></li></ul></section>
<section><h2>Adviser 请求结果</h2><table><thead><tr><th>请求</th><th>Endpoint</th><th>结果</th><th>业务码</th></tr></thead><tbody>${executionRows || '<tr><td colspan="4" class="fail">未取得 Adviser Newman Summary。</td></tr>'}</tbody></table></section>
</main></body></html>`;
fs.mkdirSync(path.dirname(path.resolve(outputPath)), {recursive: true});
fs.writeFileSync(outputPath, html);
console.log(`Generated ${outputPath}`);
