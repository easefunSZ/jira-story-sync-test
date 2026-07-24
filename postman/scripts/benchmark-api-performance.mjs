import fs from "node:fs";

const [input, output] = process.argv.slice(2);
if (!input) {
  console.error("Usage: node benchmark-api-performance.mjs <raw-newman.json> [benchmark-report.md]");
  process.exit(2);
}

function endpointOf(request) {
  const url = request?.url ?? {};
  const segments = Array.isArray(url.path) ? url.path : [];
  const serviceIndex = segments.indexOf("iic-dae-msg");
  const path = `/${segments.slice(serviceIndex >= 0 ? serviceIndex : 0).join("/")}`;
  const queryKeys = (url.query ?? []).filter(item => !item.disabled).map(item => `${item.key}`);
  return queryKeys.length ? `${path}?${queryKeys.map(k => `${k}={val}`).join("&")}` : path;
}

function calculateStats(times) {
  if (!times || times.length === 0) return { min: 0, max: 0, avg: 0, p50: 0, p95: 0 };
  const sorted = [...times].sort((a, b) => a - b);
  const sum = sorted.reduce((acc, val) => acc + val, 0);
  const avg = Math.round(sum / sorted.length);
  const min = sorted[0];
  const max = sorted[sorted.length - 1];
  const p50 = sorted[Math.floor(sorted.length * 0.5)];
  const p95 = sorted[Math.floor(sorted.length * 0.95)] || max;
  return { min, max, avg, p50, p95 };
}

const raw = JSON.parse(fs.readFileSync(input, "utf8"));
const executions = raw.run?.executions ?? [];
const iterationsCount = raw.run?.stats?.iterations?.total || 1;

const apiMap = new Map();

for (const exec of executions) {
  const name = exec.item?.name || "Unnamed Request";
  const method = exec.request?.method || "POST";
  const endpoint = endpointOf(exec.request);
  const key = `${method} ${name}`;

  if (!apiMap.has(key)) {
    apiMap.set(key, {
      name,
      method,
      endpoint,
      times: [],
      successCount: 0,
      failCount: 0
    });
  }

  const record = apiMap.get(key);
  const respTime = exec.response?.responseTime;
  if (typeof respTime === "number") {
    record.times.push(respTime);
  }

  const failures = (exec.assertions ?? []).filter(a => a.error).length;
  const isHttpErr = (exec.response?.code || 200) >= 400;
  if (failures === 0 && !isHttpErr) {
    record.successCount++;
  } else {
    record.failCount++;
  }
}

const results = [];
for (const [key, record] of apiMap.entries()) {
  const stats = calculateStats(record.times);
  const totalExecs = record.times.length;
  const successRate = totalExecs > 0 ? ((record.successCount / totalExecs) * 100).toFixed(1) : "0.0";
  results.push({
    name: record.name,
    method: record.method,
    endpoint: record.endpoint,
    totalExecs,
    successRate: `${successRate}%`,
    ...stats
  });
}

// Console output table
console.log(`\n========================================================================================`);
console.log(` API Performance Benchmark Summary (${iterationsCount} Iteration(s), Total ${executions.length} Executions)`);
console.log(`========================================================================================`);
console.table(results.map(r => ({
  "API Name": r.name.length > 30 ? r.name.slice(0, 27) + "..." : r.name,
  "Method": r.method,
  "Runs": r.totalExecs,
  "Avg (ms)": r.avg,
  "Min (ms)": r.min,
  "Max (ms)": r.max,
  "P95 (ms)": r.p95,
  "Pass Rate": r.successRate
})));

if (output) {
  const mdRows = results.map(r => 
    `| ${r.name} | \`${r.method}\` | \`${r.endpoint}\` | ${r.totalExecs} | **${r.avg} ms** | ${r.min} ms | ${r.max} ms | ${r.p95} ms | ${r.successRate} |`
  ).join("\n");

  const mdReport = `# API 多次测试性能基准报告 (Performance Benchmark Report)

> 测试生成时间：${new Date().toLocaleString("zh-CN")}
> 测试迭代轮数：**${iterationsCount} 轮**
> 累计 API 调用数：**${executions.length} 次**

## 各 API 响应耗时统计表 (按耗时平均值降序)

| API 名称 | Method | Endpoint | 采样次数 | 平均耗时 (Avg) | 最小耗时 (Min) | 最大耗时 (Max) | P95 耗时 | 成功率 |
|---|---|---|:---:|:---:|:---:|:---:|:---:|:---:|
${mdRows}

---

*注：平均耗时 (Avg) 代表多轮测试下的算术平均值；P95 代表 95% 的请求低于该响应时间。*
`;

  fs.writeFileSync(output, mdReport);
  console.log(`Benchmark Markdown report written to: file://${output}\n`);
}
