import fs from "node:fs";

const [input, output] = process.argv.slice(2);
if (!input || !output) {
  console.error("Usage: node generate-inner-ai-prompt.mjs <raw-newman.json> <output-prompt.md>");
  process.exit(2);
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

function responseText(response) {
  const bytes = response?.stream?.data;
  if (!Array.isArray(bytes)) return "";
  return Buffer.from(bytes).toString("utf8");
}

function endpointOf(request) {
  const url = request?.url ?? {};
  const segments = Array.isArray(url.path) ? url.path : [];
  const serviceIndex = segments.indexOf("iic-dae-msg");
  const path = `/${segments.slice(serviceIndex >= 0 ? serviceIndex : 0).join("/")}`;
  const queryKeys = (url.query ?? []).filter(item => !item.disabled).map(item => `${item.key}=${item.value}`);
  return queryKeys.length ? `${path}?${queryKeys.join("&")}` : path;
}

function prettyJson(val) {
  if (val === undefined || val === null) return "null";
  if (typeof val === "string") {
    try {
      return JSON.stringify(JSON.parse(val), null, 2);
    } catch {
      return val;
    }
  }
  return JSON.stringify(val, null, 2);
}

const raw = JSON.parse(fs.readFileSync(input, "utf8"));
const executions = raw.run?.executions ?? [];

const failedExecutions = executions.filter(execution => {
  const hasFailedAssertion = (execution.assertions ?? []).some(a => a.error);
  const respBody = responseJson(execution.response);
  const isBizError = respBody && respBody.responseCode && respBody.responseCode !== "00000000";
  const isHttpError = execution.response?.code >= 400;
  return hasFailedAssertion || isBizError || isHttpError;
});

const timestamp = new Date().toISOString().slice(0, 10).replace(/-/g, "");
const promptHeader = `# 内网 AI 自动诊断提示词 (Newman 执行失败自动生成)

> 生成时间：${new Date().toLocaleString("zh-CN")}
> 失败步骤总计：${failedExecutions.length} 个
`;

if (failedExecutions.length === 0) {
  const cleanPrompt = `${promptHeader}
全量测试已 100% 通过，未检测到任何断言或接口响应失败。无需生成内网 AI 修复提示词。
`;
  fs.writeFileSync(output, cleanPrompt);
  console.log(`Generated prompt file: ${output}`);
  process.exit(0);
}

const details = failedExecutions.map((exec, idx) => {
  const stepName = exec.item?.name || `Step ${idx + 1}`;
  const method = exec.request?.method || "POST";
  const endpoint = endpointOf(exec.request);
  const reqBody = exec.request?.body?.raw ? prettyJson(exec.request.body.raw) : "(none)";
  const httpCode = exec.response?.code || "N/A";
  const respText = responseText(exec.response);
  const respFormatted = prettyJson(respText);

  const failedAssertions = (exec.assertions ?? [])
    .filter(a => a.error)
    .map(a => `- **断言**: \`${a.assertion}\`\n  **错误信息**: \`${a.error?.message || a.error}\``)
    .join("\n");

  return `### 失败项 ${idx + 1}：${stepName}

- **接口地址**：\`${method} ${endpoint}\`
- **HTTP 状态码**：\`${httpCode}\`

#### 1. 实际请求 Payload (Body)：
\`\`\`json
${reqBody}
\`\`\`

#### 2. 实际响应 Response：
\`\`\`json
${respFormatted}
\`\`\`

#### 3. 失败断言详情：
${failedAssertions || "- 无断言失败（接口返回非0业务码或HTTP状态码非200）"}
`;
}).join("\n---\n\n");

const investigationPrompt = `## 一、内网 AI 调查提示词（直接复制给内网 AI 进行诊断）

\`\`\`text
你是 DAE 项目的代码分析工程师。请只分析代码，不要修改任何文件。

变更编号：CHG-${timestamp}-FIX
Feature/Story：LEAD-93 / LEAD-278
业务背景：Newman 自动化测试脚本在内网执行时检测到以下接口交互/断言失败。请分析后端的实现逻辑，定位导致失败的代码位置。

【现网/内网实测失败证据】：

${failedExecutions.map(exec => {
  const stepName = exec.item?.name || "未知步骤";
  const method = exec.request?.method || "POST";
  const endpoint = endpointOf(exec.request);
  const respText = responseText(exec.response);
  const failedAssertions = (exec.assertions ?? []).filter(a => a.error).map(a => a.error?.message || a.assertion).join("; ");
  return `- 步骤 [${stepName}] (${method} ${endpoint})：
  实际返回：${respText.length > 200 ? respText.slice(0, 200) + "..." : respText}
  失败原因：${failedAssertions || "接口响应不符合预期"}`;
}).join("\n")}

本次调查目标：
1. 找到处理上述接口的 Controller、Service、Mapper、Entity 和 SQL 路径。
2. 说明当前请求从接口入口到数据库写表的完整调用链。
3. 排查代码中是否有硬编码状态、漏传/误用字段、时区解析问题或滥用 WHERE version_status 过滤条件。
4. 说明导致实测与预期结果不符的具体代码文件和行号。

请按以下格式返回：
一、代码证据
- 文件路径：
- 类/方法：
- 关键逻辑：
- Mapper/SQL：

二、当前真实行为与根因分析
三、影响范围与建议修改的文件（只给出建议，不修改代码）
\`\`\`
`;

const implementationPrompt = `## 二、内网 AI 实现提示词（待调查结论确认后复制使用）

\`\`\`text
你是 DAE 项目的后端开发工程师。请基于上述调查确定的代码根因，在现有代码上做最小范围实现。

变更编号：CHG-${timestamp}-FIX
Feature/Story：LEAD-93 / LEAD-278
确认来源：Newman 实测报告与契约规范 LEAD-93_API_Contract_Clarification_CN.md

本次实现范围：
- 必须修改：根据调查提示词定位到的 Service / Mapper 方法。
- 必须遵循的契约约束：
  1. 保持现有的响应包络 (requestId, responseCode, responseMessage, data)。
  2. 对于 Publish 接口，若 effectiveWay = 1（预约发布），必须将版本状态置为 versionStatus = 0 (Schedule)；成功时返回实体对象。
  3. 对于 Reassign 接口，元数据绑定在 emailCode 上，绝对不能强加 version_status = 1 (Active) 关联检查，确保对纯草稿模板也能正常 Reassign。
- 明确不修改：无关的结构、包路径、字典定义与接口声明。

请执行并返回：
一、修改前确认（文件与方法）
二、代码实现（修改关键片段）
三、验证方法
\`\`\`
`;

const finalMarkdown = `${promptHeader}

${investigationPrompt}

${implementationPrompt}

---

## 三、失败接口详细日志上下文

${details}
`;

fs.writeFileSync(output, finalMarkdown);
console.log(`\n==================================================`);
console.log(`[AI Prompt Generator] Newman failure prompts written to:`);
console.log(`file://${output}`);
console.log(`==================================================\n`);
