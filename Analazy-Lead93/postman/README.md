# LEAD-93 Postman 测试包

本目录提供相互独立的 v1 As-Is 和 v2 Contract Collection。Collection 内的 Endpoint 不硬编码 QA 外层路由；`gatewayPrefix` 仅由所选 Environment 提供。

## 1. 推荐文件

| 文件 | 接口范围 | 用途 |
|---|---:|---|
| `LEAD-93-v1-as-is-all-apis.postman_collection.json` | 18 个 v1 Endpoint | 查看和单独调用全部 LEAD-93 范围内 v1 As-Is API，包含 `getNextVersion` |
| `LEAD-93-v1-full-run.postman_collection.json` | 17 个 v1 Endpoint、23 个顺序场景 | 在 Dev/QA 执行 v1 生命周期回归；无依赖查询优先、依赖失败即停止、自动清理 |
| `LEAD-93-v1-contract-probes.postman_collection.json` | 16 个只读探针 | 验证分页绑定、Template Filter 和 `getNextVersion` 等文档差异 |
| `LEAD-93-v2-contract-all-apis.postman_collection.json` | 28 个 v2 Endpoint、30 个请求 | 按 API Contract 测试全部 Web v2 API，包括行为复用路由、增强接口和新增接口 |
| `LEAD-93-v2-full-run.postman_collection.json` | 28 个 v2 Endpoint、50 个顺序步骤 | Dev/QA 一键回归；无依赖查询优先、依赖失败即停止、自动清理 |
| `run-v2-qa-newman.sh` | Dev/QA 一键执行脚本 | 校验 Environment、运行全流程并生成调试报告和脱敏摘要 |
| `scripts/upgrade-v2-full-run.mjs` | v2 全流程编排配置 | 显式维护独立请求、顺序流程、清理流程和可选静态跳过名单 |
| `run-v1-newman.sh` | v1 一键执行脚本 | 运行只读探针、完整生命周期或两者；失败后使用运行时 ID 单独清理 |
| `LEAD-93-local-mock.postman_environment.json` | 本地环境 | 对本地 Mock 运行 v2 Collection；写测试默认开启 |
| `LEAD-93-QA.postman_environment.json` | QA 环境模板 | 对 QA 调用 v1，或在 v2 部署后调用 v2；不保存 Token/API ID |

旧的重复 Collection 已清理。后续单接口调用统一使用 `v1-as-is-all-apis`，顺序回归统一使用 `v1-full-run`。

## 2. v2 本地全量测试

### 2.1 启动 Mock

在项目根目录执行：

```bash
node Lead-93/api-contract/mock/lead93-mock-server.mjs
```

### 2.2 Postman 运行

1. 导入 `LEAD-93-v2-contract-all-apis.postman_collection.json`。
2. 导入并选择 `LEAD-93-local-mock.postman_environment.json`。
3. 确认 `baseUrl=http://localhost:31093`、`gatewayPrefix` 为空。
4. 点击 Collection 的 **Run**。
5. 保持全部 30 个请求勾选并运行一次。

期望结果：30 个请求全部 HTTP 200，176 个断言全部通过。

### 2.3 Newman 运行

```bash
npm exec --yes --package newman -- newman run Lead-93/postman/LEAD-93-v2-contract-all-apis.postman_collection.json -e Lead-93/postman/LEAD-93-local-mock.postman_environment.json --reporters cli
```

生成包含实际 Mock URL、Request 和 Response 的完整调试报告：

```bash
Lead-93/postman/run-v2-mock-newman.sh contract
```

报告输出到 `Lead-93/postman/reports/v2-contract-mock-*.debug.html`，并明确标记为 Contract Mock，不得作为 QA 或已部署服务的实测证据。Mock 中业务失败同样返回 HTTP 200，`QA_TESTED_ERROR_CODE` 只是占位值，不能作为真实错误码使用。

当前输出样例：[V2 Contract Mock Debug Report](reports/v2-contract-mock-2026-07-21_162015.debug.html)。

v2 Collection 覆盖全部 28 个 Web Endpoint。`POST /v2/publish` 分别覆盖立即发布已有 Draft、预约发布已有 Draft 和直接发布新 Template，因此 Collection 请求总数为 30。`POST /v2/add` 只覆盖 Save Draft；`NEW-10 Copy and Create` 在首次 Save Draft 时创建独立 Template B。

### 2.4 v2 完整顺序回归

使用 `LEAD-93-v2-full-run.postman_collection.json` 并保持 50 个步骤的顺序不变。正常流程执行 48 个请求；Unused/Source Category 两个备用清理请求在主流程已完成删除时自动跳过。

Collection 会自动读取现有 Category Tree 和 Tag Taxonomy，动态生成测试 Category、Subcategory、Template、Copy Template、Version 和未来预约时间。所有业务 ID 都来自前序响应，不使用固定示例 ID。

前 5 步均为无测试数据依赖的查询接口：Channel List、Published List、Draft/Admin List、Category Tree、Tag Taxonomy。第 6 步起才创建数据并进入有依赖的生命周期流程。

Newman 主流程使用 fail-fast：任一 HTTP、业务码、响应结构或业务断言失败时立即停止，后续依赖请求不再执行。Runner 随后只运行 `99 Cleanup`，根据失败前已保存的动态 ID 清理已创建数据，并单独生成 Cleanup 报告。

### 2.5 v2 请求编排与 Dev 跳过配置

`scripts/upgrade-v2-full-run.mjs` 是 v2 Full Run 的编排入口，按名称显式维护：

1. `independentNames`：无本次测试数据 ID 依赖、最先执行的请求；
2. `workflowNames`：严格按数组顺序执行的生命周期请求；
3. `cleanupNames`：失败后仍可单独执行的受保护清理请求；
4. `skippedNames`：需要长期跳过的请求，默认必须为空。

Dev 临时不可用的请求优先通过 Environment 配置，不修改基线顺序：

```text
skipRequestNames=Check Unused Category Delete Impact,Check Referenced Source Category Impact
skipSteps=13,42
```

两个变量可以任选其一。`skipRequestNames` 使用升级脚本中的完整基础名称，不包含前面的步骤编号；`skipSteps` 使用升级后显示的两位步骤编号。Runner 每次运行前自动执行升级脚本，因此数组调整会立即反映到 Collection。

也可以不修改 Environment，直接在当前命令前临时指定：

```bash
SKIP_STEPS=13,42 Lead-93/postman/run-v2-qa-newman.sh /absolute/path/environment.json
```

或按名称指定：

```bash
SKIP_REQUEST_NAMES="Check Unused Category Delete Impact,Check Referenced Source Category Impact" \
Lead-93/postman/run-v2-qa-newman.sh /absolute/path/environment.json
```

跳过请求在 Newman 中记录为 `skipped`，不算测试通过。`99 Cleanup` 中的请求即使被写入跳过配置也不会跳过。若跳过产生 Category ID、Tag 数据、`emailCode` 或 Version 状态的前置请求，必须同时评估并跳过其依赖场景；否则后续请求会按 fail-fast 停止并进入 Cleanup。

本地 Mock 验证结果：48 个请求成功、289 个断言通过、28 个唯一 Endpoint 全部覆盖；临时 Template 和 Category 全部清理。Contract Collection 仍保留为逐接口样例和独立调试入口。

## 3. v2 全流程测试

导入 `LEAD-93-v2-full-run.postman_collection.json`，并选择 `LEAD-93 Local Mock` Environment。

运行前确认：

1. `enableWriteTests=true`；
2. 保持 50 个步骤和三个 Folder 的顺序不变；
3. 测试账号具有 Category、Template、Publish、Schedule、Reassign 和 Delete 权限；
4. 不需要手工填写 Category ID、Subcategory ID、emailCode、Version 或 effectiveFrom。

全流程依次执行：

1. 执行 Channel List、Published List 和 Draft/Admin List 无依赖查询；
2. 读取完整 Category Tree 与 Tag Taxonomy，保存现有顺序并自动选择有效 Tag；
3. 创建 Source、Target、Unused Category 和对应 Subcategory；
4. 提交包含全部现有一级节点的完整排序，并删除无引用 Category；
5. 创建 V1 Draft、保存 Metadata、发布、启停并验证查询；
6. 执行 Copy and Create、Version Add、Working Draft、Schedule、Cancel Schedule、Publish 和 Discard；
7. 执行批量 Reassignment、Category Impact、迁移并删除；
8. 进入 Cleanup Folder，软删除两个临时 Template，删除临时 Category，并验证无残留。

本地 Newman 命令：

```bash
npm exec --yes --package newman -- newman run Lead-93/postman/LEAD-93-v2-full-run.postman_collection.json -e Lead-93/postman/LEAD-93-local-mock.postman_environment.json --reporters cli
```

当前验证结果：48 个实际请求、289 个断言、0 个失败；覆盖 28 个唯一 Endpoint。

## 4. QA 环境

导入 `LEAD-93-QA.postman_environment.json` 后填写当前值：

| 变量 | QA 设置 |
|---|---|
| `baseUrl` | `https://api.adviser.qa.oldmutual.co.za` |
| `gatewayPrefix` | `/dae`；仅为 QA 环境级路由，不属于 Endpoint Contract |
| `authorization` | 可选；环境启用认证时填写完整 `Bearer ...` |
| `xApigwApiId` | 可选；经过 API Gateway 且要求该 Header 时填写 |
| `language` | `en-US` |
| `enableWriteTests` | 默认 `false` |

不要把浏览器 `sec-ch-*` Header 手工复制到 Postman/Newman。Token 和 API Gateway ID 只填写在本机 Postman Current Value，不提交到文件。

v2 Full Run 只能在 v2 部署完成后运行。除登录凭据外，测试数据和参数全部由 Collection 自动生成。

首次准备一个 Environment；Dev 不要求认证时，`authorization/xApigwApiId` 保持为空：

```bash
Lead-93/postman/run-v2-qa-newman.sh /absolute/path/LEAD-93-DEV.private.postman_environment.json
```

凭据为空时 Collection 会直接移除 `authorization` 和 `x-apigw-api-id` Header，不发送空 Header 或本地 Mock 占位值。QA 如果启用了网关认证，只需在 Environment 中填写这两个值，命令不变。

脚本会生成：

- `.newman-private/v2-deployed-full-run-*.debug.html`：实际 URL、Request、Response 和断言，敏感 Header 自动打码；
- `reports/v2-deployed-full-run-*.summary.json`：可共享的脱敏摘要。

主流程遇到第一个请求或断言失败时立即停止；Runner 使用导出的运行时 Environment 单独执行 Cleanup Folder，不会继续运行其他依赖业务步骤。若进程被强制终止、网络完全中断或服务不可用，无法保证服务端清理完成；恢复连接后应重新查询名称前缀 `LEAD93 QA` 并处理残留数据。

## 5. 写操作保护

两个 Collection 的 Create、Update、Delete、Publish、Schedule 和 Metadata 修改请求都包含写操作保护：

- `enableWriteTests=false`：跳过写请求；
- `enableWriteTests=true`：允许执行写请求。

本地 Mock Environment 默认是 `true`，因为 Mock 不持久化数据。QA Environment 默认是 `false`。在 QA 开启前必须确认 `emailCode`、version 和 Category ID 都是隔离测试数据。

## 6. v1 使用方式

### 6.1 单接口验证

使用 `LEAD-93-v1-as-is-all-apis.postman_collection.json`。该 Collection 按以下目录整理：

1. Template Queries；
2. Template Writes；
3. Version APIs；
4. Supporting Lookups。

读取已有 Template 前，在 Collection Variables 中设置：

- `emailCode`；
- `activeVersion`；
- `draftVersion`。

### 6.2 v1 全生命周期回归

使用 `LEAD-93-v1-full-run.postman_collection.json`：

1. 选择 `LEAD-93 QA` Environment；
2. 保持三个 Folder 和 23 个场景的顺序不变；
3. 使用 Newman 脚本时无需手工设置 `enableWriteTests`；
4. 不需要填写 `testEmailCode`、`testEmailName` 或 Version；
5. 直接在 Postman 手工运行写场景时，才需要设置 `enableWriteTests=true`。

前 4 步是无测试数据依赖的只读查询。第 5 步开始创建临时 Template，依次完成 Draft、Publish、Version 和状态验证；`99 Cleanup` 最后执行软删除并确认该 `emailCode` 不再返回。Send Email 和 Usage Report 明确不在 Collection 中。

Newman 主流程在首个 HTTP、业务码、响应结构或业务断言失败时停止，后续依赖步骤不会继续执行。Runner 会导出失败前产生的运行时 `emailCode`，随后只运行 `99 Cleanup` 并生成独立报告。

## 7. Newman Dev/QA 证据

### 7.1 准备私有 Environment

从 Postman 导出当前 Dev/QA Environment，确保以下值存在：

- `baseUrl`
- `gatewayPrefix`：Dev 可为空，QA 当前为 `/dae`
- `language=en-US`

`authorization` 和 `xApigwApiId` 是可选值。Dev 不要求认证时保持为空，Collection 会移除对应 Header；QA 经过网关认证时再填写。

Environment 文件包含凭据，只保存在本机，不提交到 Git。脚本不会把这些值写入可提交报告。

### 7.2 只读 Contract Probe

```bash
Lead-93/postman/run-v1-newman.sh probes /absolute/path/LEAD-93-QA.private.postman_environment.json
```

该模式不创建或修改模板，验证：

1. `pageNum` 与错误字段 `pageNo` 的 A/B 行为；
2. `templateStatus/channelList/emailStatusList/sortField/isAsc` 过滤；
3. `/version/getNextVersion` 的存在性和 `Vn` 返回格式。

### 7.3 完整生命周期回归

```bash
Lead-93/postman/run-v1-newman.sh full /absolute/path/LEAD-93-QA.private.postman_environment.json
```

该模式创建隔离 Template，执行 Draft、Publish、Add Version、状态切换和删除校验，最后软删除测试 Template。脚本自动启用本次隔离写测试，不再需要额外的写入确认参数。

同时运行两组：

```bash
Lead-93/postman/run-v1-newman.sh all /absolute/path/LEAD-93-QA.private.postman_environment.json
```

### 7.4 报告与安全边界

- `postman/.newman-private/*.debug.html`：排查问题的完整可读报告。按请求展示实际 URL、Request Headers、Request Body、HTTP 状态、Response Headers、Response Body、耗时和断言；认证、Cookie 和 API Key 自动打码。
- `postman/reports/*.summary.json`：字段结构、状态码和断言的机器可读脱敏摘要。
- `postman/.newman-private/`：原始 JSON、运行时 Environment 和详细调试报告，可能包含正文、业务数据和个人数据，已由 `.gitignore` 排除，不得提交或外发。
- `postman/scripts/`：Collection 整理脚本、Probe Collection 生成器、私有调试报告生成器和 Newman 摘要生成器。

即使 Newman 出现 HTTP、业务码或断言失败，脚本也会先生成上述报告，再以非零状态结束。完整生命周期失败时还会生成独立的 `v1-cleanup-*` 报告。终端输出中的 `Private debug report` 即为优先排查入口。

## 8. Contract 对应关系

- v1 Collection 基线：[LEAD-93 v1 As-Is API](../LEAD-93_API_V1_AsIs_CN.md)
- v2 Collection 基线：[LEAD-93 Web v2 API Contract](../LEAD-93_API_Contract_Clarification_CN.md)
- v2 Mock 实现：[lead93-mock-server.mjs](../api-contract/mock/lead93-mock-server.mjs)
