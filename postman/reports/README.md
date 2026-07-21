# LEAD-93 Postman 报告索引

## 当前有效的 v2 Mock 基线

| 报告 | 范围 | 结果 |
|---|---|---|
| `v2-contract-mock-2026-07-21_150839.debug.html` | 28 个唯一 Web v2 Endpoint、30 个请求 | 30/30 请求、176/176 断言通过 |
| `v2-full-run-mock-2026-07-21_160522.debug.html` | 50 个顺序步骤、28 个唯一 Endpoint | 48 个实际请求、289/289 断言通过；2 个备用清理请求按预期跳过 |

两份 Debug HTML 均包含 URL、Request、Response、耗时和断言。它们来自本地 Contract Mock，只用于前端联调和契约排查，不代表 QA 或已部署 v2 服务实测。

更早的 `v2-contract-mock-*` 文件属于 20 Endpoint 旧版或中间失败运行，只保留作过程排查，不作为当前交付基线。
