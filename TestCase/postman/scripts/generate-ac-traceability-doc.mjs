import fs from "node:fs";
import path from "node:path";

const root = path.resolve(import.meta.dirname, "..", "..");
const input = process.argv[2] ?? path.join(root, "LEAD-93-405_AC_Traceability.json");
const output = process.argv[3] ?? path.join(root, "LEAD-93-405_AC_Traceability_CN.md");
const criteria = JSON.parse(fs.readFileSync(input, "utf8"));
const groups = new Map();
for (const criterion of criteria) {
  const group = groups.get(criterion.story) ?? [];
  group.push(criterion);
  groups.set(criterion.story, group);
}

const legend = [
  "- `FULL`：已有 API 和/或数据库断言，运行报告可计算 PASS/FAIL。",
  "- `PARTIAL`：需求的一部分是后端可测，剩余边界或 UI 行为没有在当前集合覆盖。",
  "- `CONDITIONAL`：需要额外登录态，例如 Adviser 权限负例。",
  "- `UI`：纯前端交互，不属于本后端回归集合。",
  "- `GAP`：后端可测但当前没有足够确定的接口断言，必须补充后才能宣称 AC 全覆盖。"
].join("\n");

const tables = [...groups].map(([story, rows]) => {
  const tableRows = rows.map(row => `| ${row.id.replace(`${story} `, "")} | ${row.requirement} | ${(row.api ?? []).map(id => `API-${id}`).join(", ") || "-"} | ${(row.db ?? []).join(", ") || "-"} | ${row.coverage} | ${row.note ?? "-"} |`).join("\n");
  return `## ${story}\n\n| AC | 后端验收要求 | Postman 用例 | 数据库断言 | 覆盖度 | 说明 |\n| --- | --- | --- | --- | --- | --- |\n${tableRows}`;
}).join("\n\n");

const readmeTables = [...groups].map(([story, rows]) => {
  const tableRows = rows.map(row => `| ${row.id.replace(`${story} `, "")} | ${row.requirement} | ${(row.api ?? []).map(id => `API-${id}`).join(", ") || "-"} | ${(row.db ?? []).join(", ") || "-"} | ${row.coverage} | ${row.note ?? "-"} |`).join("\n");
  return `### ${story}\n\n| AC | 具体验收内容 | Postman 用例 | 数据库断言 | 覆盖度 | 备注 |\n| --- | --- | --- | --- | --- | --- |\n${tableRows}`;
}).join("\n\n");

const outputText = `# LEAD-93 / LEAD-405 后端 AC 追溯矩阵\n\n本文件是 [后端 AC 回归包说明](LEAD-93-405-backend-ac-README_CN.md) 的逐条追溯附件。需求来源为当前 Jira Story；所有 API 编号对应 Postman Collection 中的请求编号，所有 DB 编号对应自动化只读 SQL 断言。\n\n## 判定口径\n\n${legend}\n\n${tables}\n`;
fs.writeFileSync(output, outputText);

const readmePath = path.join(root, "LEAD-93-405-backend-ac-README_CN.md");
const startMarker = "<!-- AC_TRACEABILITY_TABLE_START -->";
const endMarker = "<!-- AC_TRACEABILITY_TABLE_END -->";
if (fs.existsSync(readmePath)) {
  const readme = fs.readFileSync(readmePath, "utf8");
  const generatedSection = `${startMarker}\n\n## 逐条 AC 详细验收表\n\n下表直接列出每个 Story 的每条 AC、具体后端验收内容、对应 Postman 用例和数据库断言。执行后的实际结果与错误原因见一键生成的 HTML 报告。\n\n${readmeTables}\n\n${endMarker}`;
  const start = readme.indexOf(startMarker);
  const end = readme.indexOf(endMarker);
  if (start >= 0 && end > start) {
    fs.writeFileSync(readmePath, `${readme.slice(0, start)}${generatedSection}${readme.slice(end + endMarker.length)}`);
  }
}
console.log(`Generated AC traceability document: ${output}`);
