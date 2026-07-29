# LEAD-93 / LEAD-405 后端 AC 回归包

## 用途

本包只验证 Jira AC 中可由后端观察的行为：API 响应、状态机、事务原子性、当前 Metadata、软删除、查询可见性和数据库落库。它不测试页面路由、弹窗文本/按钮、拖拽手势、富文本工具栏、Preview 视觉效果等前端专属 AC。

## 运行

1. 在 `LEAD-93-405-backend-ac.postman_environment.json` 填入 `baseUrl`、网关前缀、Content Manager 登录头和 AES Key。
2. 导入 `LEAD-93-405-backend-ac.postman_collection.json`，运行整个 Collection；或执行：

```bash
cd /Users/qthitsz/DAE-workspace/om/Lead-93/TestCase/postman
./run-lead93-lead405-ac-newman.sh LEAD-93-405-backend-ac.postman_environment.json
```

3. Newman 会执行完整集合，不会因单个响应格式或字段断言失败而中断；所有断言错误会写入 Request/Response Debug HTML 与脱敏 Summary JSON，并生成一份 API-only 的逐条 AC HTML 表格。HTML 按 Story → 场景编号与名称 → 固定步骤 → AC 映射展示；场景编号在每个 Story 内从 1 连续编号，场景定义来自 `LEAD-93-405_Test_Scenarios.json`，不根据执行结果临时推导。失败步骤还会根据 `LEAD-93-405_API_Code_Models.json` 显示请求 BO/DTO、成功响应 VO 以及优先排查层次；标为“代码快照”的类名必须在修改代码前重新核对。仅当关键前置调用无法成功创建后续依赖的数据时，分阶段脚本才停止后续依赖阶段。API-only 表格中要求数据库证据的步骤会显示 `NOT RUN`；使用下一节的一键脚本可补齐数据库验证。即使完整执行，若存在断言或数据库验证问题，脚本仍会在报告生成后返回非零退出码，便于 CI 或命令行识别失败。默认保留现场方便排查；清理可在 Postman 单独运行 `99 Cleanup`。
4. 从导出的运行环境取得 `acActiveEmailCode`、目录 ID 等值，填入 [数据库校验脚本](sql/QUERY_LEAD93_LEAD405_backend_ac_validation.sql) 的参数区执行。

### 内网一键 API + 数据库回归

内网测试机同时可访问应用和测试 MySQL 时，使用以下入口。脚本按检查点保留运行时 ID，依次执行 API、只读数据库断言，最后生成合并 HTML 报告。响应契约或数据库断言失败会继续执行并写入报告；只有关键前置 API 请求未成功、无法生成后续依赖数据时才标记 `BLOCKED` 并停止后续依赖阶段。所有已执行请求的错误原因都保留在报告中。

```bash
cd /path/to/Lead-93/TestCase/postman
./run-lead93-lead405-ac-with-db.sh LEAD-93-405-backend-ac.postman_environment.json
```

将 [`mysql-test.env.example`](postman/mysql-test.env.example) 复制为 `postman/mysql-test.env` 后填写 `MYSQL_HOST`、`MYSQL_PORT`、`MYSQL_USER`、`MYSQL_PWD` 和 `MYSQL_DATABASE`。这是普通文件名，适用于 Windows；脚本优先读取它，并兼容旧 `postman/.env`。也可通过 `MYSQL_ENV_FILE=/secure/path/mysql.env` 指定其他位置。进程环境变量优先于文件配置，连接信息不写入报告。

输出位置：

- `postman/reports/lead93-405-backend-ac-with-db-*.html`：最终合并报告。
- `postman/reports/lead93-405-backend-ac-api-only-*.html`：无数据库连接时生成的逐条 AC API 验证报告。
- `postman/reports/*.summary.json`：脱敏 API 摘要。
- `postman/.newman-private/`：运行时环境、完整请求/响应 Debug HTML 与数据库原始结果，仅限测试机本地保存。

> 所有写测试只使用自动生成的 `LEAD93 AC ...` 数据。不要在生产环境运行。

### PKS V1 参数校验兼容性探针

该探针只向 V1 `/add` 发送空 JSON `{}`。`EmailAddBO` 的 Bean Validation 会在进入 Service 前拦截请求，因此不会创建 Template 或写入数据库。它用于确认 PKS 的 V1 公共异常包络是否仍是 HTTP `200`、`responseCode=00000006`、`data="[] Validation failed"`。

```bash
cd /path/to/Lead-93/TestCase/scripts
cp pks-v1-validation.env.example pks-v1-validation.env
# 填写 PKS_BASE_URL、认证头和网关 ID（如环境需要）
./probe-v1-bean-validation.sh pks-v1-validation.env
```

配置文件按普通 `KEY=VALUE` 读取，`PKS_AUTHORIZATION=Bearer <token>` 可直接填写，不会作为 Shell 命令执行；文件被 Git 忽略，不能提交 Token。非空进程环境变量会补充配置文件中的空值，可用于临时注入网关头。若 PKS 使用自签名 HTTPS，可将 `PKS_CURL_INSECURE=true`；只限受控测试环境。

如网关要求浏览器来源上下文，可设置 `PKS_ACCEPT`，并按 `PKS_HEADER_01`、`PKS_HEADER_02` 的形式添加 Origin、Referer 或其他已获准的请求头；脚本会原样透传，不会打印其敏感值。

## Story / AC 追溯

每条 Jira AC 不再混在 Story 摘要中。请以逐条表格 [LEAD-93-405_AC_Traceability_CN.md](LEAD-93-405_AC_Traceability_CN.md) 为准；一键报告会使用同一份追溯数据，在每次执行后对每条 AC 输出 `PASS`、`FAIL`、`PARTIAL PASS`、`NOT RUN`、`NOT COVERED` 或 `N/A UI`。

| Story | 逐条 AC 数 | 后端全覆盖 | 部分/待补 | 前端专属/条件执行 |
| --- | ---: | ---: | ---: | ---: |
| LEAD-277 | 14 | 9 | 4 | 1 |
| LEAD-301 | 9 | 3 | 5 | 1 |
| LEAD-306 | 5 | 2 | 1 | 2 |
| LEAD-307 | 5 | 0 | 3 | 2 |
| LEAD-276 | 10 | 5 | 3 | 2 |
| LEAD-278 | 7 | 2 | 2 | 3 |
| LEAD-293 | 9 | 3 | 4 | 2 |
| LEAD-300 | 9 | 5 | 3 | 1 |

<!-- AC_TRACEABILITY_TABLE_START -->

## 逐条 AC 详细验收表

下表直接列出每个 Story 的每条 AC、具体后端验收内容、对应 Postman 用例和数据库断言。执行后的实际结果与错误原因见一键生成的 HTML 报告。

### LEAD-277

| AC | 具体验收内容 | Postman 用例 | 数据库断言 | 覆盖度 | 备注 |
| --- | --- | --- | --- | --- | --- |
| AC1 | 模板核心字段可被创建、读取和持久化 | API-21, API-22 | DB-01, DB-04, DB-05 | FULL | - |
| AC2 | 字段约束：模板名称、分类单选、子分类多选且归属正确 | API-17, API-20, API-28, API-29 | DB-04, DB-06 | PARTIAL | 已覆盖必填、单分类和归属；名称/描述最大长度须另补专用边界用例。 |
| AC3 | Save Draft 允许 Metadata 未完成，状态为 Draft | API-18, API-19 | DB-01 | FULL | - |
| AC4 | 草稿未选必填 Tag Group 时填充默认值 | API-18 | - | GAP | 当前基线仅确认草稿允许空 Tag；默认值的具体持久化形态未冻结。 |
| AC5 | Publish 校验标题、分类、子分类、四组 Tag 和正文 | API-20, API-21 | DB-03, DB-05 | FULL | - |
| AC6 | 发布失败被阻止并返回可定位字段错误 | API-20 | DB-03 | FULL | - |
| AC7 | 校验只在用户点击 Publish 时触发 | - | - | UI | 触发时机属于页面交互；后端只验证 Publish 请求。 |
| AC8 | 模板名称必填且不超过 120 字符 | API-17 | - | PARTIAL | 已覆盖必填；120 字符边界须另补。 |
| AC9 | Publish 必须选择 Category | API-20 | DB-03 | FULL | - |
| AC10 | Publish 必须选择至少一个 Subcategory | API-20 | DB-03 | FULL | - |
| AC11 | Publish 每个必填 Tag Group 至少一个值 | API-1, API-20 | DB-05 | FULL | - |
| AC12 | Publish 正文不能为空 | API-20 | DB-03 | FULL | - |
| AC13 | Draft 发布为 Published；Published Copy 为独立 Draft | API-18, API-21, API-32, API-41, API-45 | DB-01, DB-08, DB-10, DB-11 | FULL | - |
| AC14 | 所有发布入口复用一致的发布校验 | API-20, API-45 | - | PARTIAL | 已覆盖首次发布和 Version 发布；Preview 页面入口属于前端专属。 |

### LEAD-301

| AC | 具体验收内容 | Postman 用例 | 数据库断言 | 覆盖度 | 备注 |
| --- | --- | --- | --- | --- | --- |
| AC1 | 页面展示 Category 下拉和禁用态 Subcategory 多选 | - | - | UI | - |
| AC2 | 仅可选当前 Category 下 Subcategory，切换 Category 清空选择 | API-29 | DB-06 | PARTIAL | 后端覆盖跨分类子分类拒绝；页面清空行为属于前端。 |
| AC3 | Draft 可不选 Category/Subcategory，状态保持 Draft | API-18, API-19 | DB-01 | FULL | - |
| AC4 | Category 与同父 Subcategory 可排序，不能跨父移动 | API-15 | - | PARTIAL | 已覆盖完整同级排序写入；拖拽禁用与跨父交互属于前端。 |
| AC5 | Category/Subcategory 持久化，并可在列表、搜索和导航定位 | API-22, API-23, API-26, API-31 | DB-04, DB-06 | FULL | - |
| AC6 | Draft 修改分类后立即保存并更新位置 | - | - | GAP | 当前集合仅验证 Draft 初次创建，未覆盖已有 Draft 的 Metadata 更新。 |
| AC7 | Published 修改分类为 Metadata 变更且仍为 Published | API-24, API-25, API-26 | DB-04 | FULL | - |
| AC8 | Category/Subcategory 名称必填且最长 100 字符 | API-5, API-10, API-11 | - | PARTIAL | 已覆盖空名称；100 字符边界须另补。 |
| AC9 | Category/Subcategory 重名被拒绝且不落部分数据 | API-9, API-11 | DB-07 | PARTIAL | 已覆盖 Category 重名和批量原子性；Subcategory 重名的正式唯一性范围仍有文档冲突。 |

### LEAD-306

| AC | 具体验收内容 | Postman 用例 | 数据库断言 | 覆盖度 | 备注 |
| --- | --- | --- | --- | --- | --- |
| AC1 | Create New 路由、首次保存后 URL、离页确认 | - | - | UI | - |
| AC2 | 创建页可提交 Category、Subcategory 与 Tags | API-21, API-22 | DB-04, DB-05 | FULL | - |
| AC3 | 首次 Save Draft 创建唯一 Template ID，状态为 Draft | API-18, API-19 | DB-01 | FULL | - |
| AC4 | Publish 严格校验、Draft 转 Published、Adviser 可见、Copy 复用规则 | API-20, API-21, API-23, API-32, API-45 | DB-03, DB-10 | PARTIAL | 后端状态和可见性查询已覆盖；页面消息和 Adviser UI 不在本套范围。 |
| AC5 | 仅 Content Manager 可创建 Template | API-56 | - | CONDITIONAL | 需配置 adviserAuthorization 并将 runPermissionTests=true。 |

### LEAD-307

| AC | 具体验收内容 | Postman 用例 | 数据库断言 | 覆盖度 | 备注 |
| --- | --- | --- | --- | --- | --- |
| AC1 | 删除 Category 前显示确认对话框 | - | - | UI | - |
| AC2 | 确认对话框展示不可逆、级联和引用影响说明 | - | - | UI | - |
| AC3 | 有引用时阻止直接删除并提供迁移选择 | API-50, API-51 | DB-12, DB-13 | PARTIAL | 当前 Contract 采用两阶段影响评估和迁移删除，不是仅人工迁移后重试。 |
| AC4 | 无引用 Category 级联软删除子节点并从树隐藏 | API-16, API-51, API-53 | DB-12 | PARTIAL | 软删除和树隐藏已覆盖；删除留痕未纳入当前后端测试基线。 |
| AC5 | 无引用 Subcategory 单独软删除且不影响父 Category | API-48, API-49 | - | PARTIAL | 叶节点删除和父节点保留已覆盖；有引用 Subcategory 的单独迁移分支未单测。 |

### LEAD-276

| AC | 具体验收内容 | Postman 用例 | 数据库断言 | 覆盖度 | 备注 |
| --- | --- | --- | --- | --- | --- |
| AC1 | 编辑页回显已选 Category/Subcategory | API-22, API-26, API-28 | DB-04 | PARTIAL | 后端 Detail 回显已覆盖；选中态渲染属于前端。 |
| AC2 | 改 Category 清空旧 Subcategory 并刷新候选项 | API-29 | DB-06 | PARTIAL | 后端拒绝跨分类关系；页面自动清空与刷新属于前端。 |
| AC3 | 只修改 Subcategory 时 Category 保持不变 | API-27, API-28 | DB-04 | FULL | - |
| AC4 | 一个 Template 仅一个 Category，可多个同父 Subcategory | API-21, API-27, API-29 | DB-04, DB-06 | FULL | - |
| AC5 | Template 重新分类仅通过编辑表单，不通过拖拽 | - | - | UI | - |
| AC6 | Published Metadata 修改不改变发布状态 | API-24, API-25 | DB-04 | FULL | - |
| AC7 | Draft 修改分类后立即保存 | - | - | GAP | 当前集合未覆盖已有 Draft 的 EX-06 更新。 |
| AC8 | 重新分类后搜索、筛选和位置同步更新 | API-23, API-31, API-47, API-52 | DB-13 | FULL | - |
| AC9 | Publish 必填分类，Draft 可为空 | API-18, API-20 | DB-01, DB-03 | FULL | - |
| AC10 | 仅 Content Manager 可修改分类 | API-57 | - | CONDITIONAL | 需配置 adviserAuthorization 并将 runPermissionTests=true。 |

### LEAD-278

| AC | 具体验收内容 | Postman 用例 | 数据库断言 | 覆盖度 | 备注 |
| --- | --- | --- | --- | --- | --- |
| AC1 | 从 Published Copy 创建独立 Draft，原模板保持可用 | API-32, API-34 | DB-08, DB-09 | PARTIAL | 独立 Copy 与原模板状态已覆盖；WYSIWYG 预填渲染属于前端。 |
| AC2 | WYSIWYG 格式化能力 | - | - | UI | - |
| AC3 | 手动 Save Draft 保存 B，原模板不受影响 | API-33, API-34 | DB-08, DB-09 | PARTIAL | 保存和原模板不变已覆盖；页面成功消息与 Version History 文案属于前端。 |
| AC4 | 离开未保存编辑时确认 Save/Cancel/Back | - | - | UI | - |
| AC5 | 手动 Preview 显示未保存内容 | - | - | UI | - |
| AC6 | Copy B 发布为独立 Published，原模板仅显式停用时变化 | API-34, API-35, API-36, API-37, API-38, API-45 | DB-09, DB-10 | FULL | - |
| AC7 | Discard/Cancel 删除 B，原 Published 不变 | API-39, API-40 | DB-15, DB-16 | FULL | - |

### LEAD-293

| AC | 具体验收内容 | Postman 用例 | 数据库断言 | 覆盖度 | 备注 |
| --- | --- | --- | --- | --- | --- |
| AC1 | Content Manager 可进入创建分类功能 | - | - | UI | - |
| AC2 | 创建 Category/Subcategory 名称，最长 100 字符 | API-6, API-12, API-13 | - | PARTIAL | 创建已覆盖；100 字符边界须另补。 |
| AC3 | 空/重复名称失败，单次最多五个 Subcategory，无部分落库 | API-5, API-9, API-10, API-11 | DB-07 | PARTIAL | 已覆盖空名称、Category 重名、上限和原子性；Subcategory 重名范围待确认。 |
| AC4 | 创建后立即在下拉和导航可用 | API-2, API-6, API-12, API-13 | - | PARTIAL | Tree API 可见性已覆盖；页面下拉渲染属于前端。 |
| AC5 | 新分类默认有效并可立即被 Template 使用 | API-6, API-21 | DB-04 | FULL | - |
| AC6 | 创建失败无部分数据 | API-10, API-11 | DB-07 | FULL | - |
| AC7 | 仅 Content Manager 可创建/编辑 Category | API-55 | - | CONDITIONAL | 需配置 Adviser 登录态。 |
| AC8 | 创建人和创建时间被保存 | - | - | GAP | 数据库字段存在，但自动断言未覆盖创建人/创建时间。 |
| AC9 | 两层分类结构，Template 一主分类多子分类 | API-2, API-12, API-13, API-21, API-27 | DB-04 | FULL | - |

### LEAD-300

| AC | 具体验收内容 | Postman 用例 | 数据库断言 | 覆盖度 | 备注 |
| --- | --- | --- | --- | --- | --- |
| 1 | 返回 Tag Group 与 Required 标识 | API-1 | DB-05 | PARTIAL | 后端 Taxonomy 已覆盖；页面展示属于前端。 |
| 2 | Tag 仅可从预置多选 taxonomy 选择，不接受自由文本 | API-1, API-30 | DB-05 | FULL | - |
| 3 | Publish 缺少任一必填 Tag Group 时阻止发布 | API-1, API-20 | DB-03, DB-05 | FULL | - |
| 4 | Save Draft 不强制 Tag，未选值使用默认表示 | API-18 | DB-01 | PARTIAL | Draft 宽松已覆盖；默认值具体落库表示未冻结。 |
| 5 | 每个 Tag Group 支持多选 | API-1, API-24, API-26 | DB-05 | FULL | - |
| 6 | 可回显并增删已分配 Tag | API-24, API-26 | DB-05 | FULL | - |
| 7 | Tag 是 Metadata；修改 Published Tag 不改变状态且不受分类限制 | API-24, API-25 | DB-04, DB-05 | PARTIAL | 状态不变已覆盖；跨所有分类的 Tag 可用性由 taxonomy 数据决定，未做枚举组合测试。 |
| 8 | 仅 Content Manager 可编辑 Tag，Adviser 只读 | API-57 | - | CONDITIONAL | 需配置 adviserAuthorization 并将 runPermissionTests=true。 |
| 9 | 已分配 Tag 立即可用于列表筛选 | API-31 | DB-05 | FULL | - |

<!-- AC_TRACEABILITY_TABLE_END -->

## 已明确的边界

- `LEAD-307` 的 Jira Acceptance Criteria 自定义字段为空；集合将其视为 `Description + 当前 API Contract` 的暂定后端覆盖，不把未编号文字误称为已冻结 AC。
- `LEAD-300` 中“阻止 saving”的歧义按当前冻结规则解释为“阻止 Publish”；Save Draft 允许缺少 Tag。
- 软删除后同名 Category 重建按当前技术基线验证“仅有效节点重名冲突”。若 BA 将 `LEAD-293 AC3` 的“全局唯一”重新冻结，必须删除/改写第 45 步和 SQL 第 10 节。
- 权限需要两套登录态：`authorization` 为 Content Manager；配置 `adviserAuthorization` 且 `runPermissionTests=true` 后才执行 Adviser 写操作拒绝测试。

## 执行前待确认

- `NEW-05` 的当前 API Contract 请求体为 `[{categoryId, sortOrder}]`；此前设计讨论曾提出 `{parentCategoryId, orderedCategoryIds[]}`。本集合严格按当前 API Contract 生成，未猜测或兼容两种 DTO。若接口最终采用后一种 DTO，先更新 Contract，再重新生成集合。
- `Category/Subcategory` 的唯一性范围在现有方案文本中存在“全局唯一”与“有效同级唯一”两种表述；本集合只验证“同名有效根 Category 拒绝、软删除后可重建”，不对跨父节点同名作未经确认的断言。

## 文件

| 文件 | 作用 |
|---|---|
| `LEAD-93-405-backend-ac.postman_collection.json` | 62 条按依赖顺序组织的 API 测试。 |
| `LEAD-93-405_Test_Scenarios.json` | 按 Story 维护的连续场景编号、业务场景名称、固定步骤、前置条件及 API/DB 执行证据。 |
| `LEAD-93-405_API_Code_Models.json` | 报告使用的 Endpoint → 请求 BO/DTO → 成功响应 VO 定位表，并标记当前代码核对状态。 |
| `LEAD-93-405-backend-ac.postman_environment.json` | 无凭证模板环境。 |
| `postman/mysql-test.env.example` | 内网测试 MySQL 配置样例；实际 `mysql-test.env` 不纳入版本控制。 |
| `run-lead93-lead405-ac-newman.sh` | 生成集合、运行 Newman、产出调试报告。 |
| `run-lead93-lead405-ac-with-db.sh` | 内网一键执行 API 分阶段回归、只读 MySQL 断言和合并报告。 |
| `scripts/generate-lead93-lead405-ac-backend-suite.mjs` | 从当前全量 v2 Collection 复用真实 Endpoint/Header 生成测试集合。 |
| `LEAD-93-405_AC_Traceability.json` / `LEAD-93-405_AC_Traceability_CN.md` | 逐条 Jira AC、Postman 用例、数据库断言与覆盖缺口的唯一追溯来源。 |
| `sql/ASSERT_LEAD93_LEAD405_backend_ac.sql` | 供一键脚本调用的数据库 PASS/FAIL 断言模板。 |
| `sql/QUERY_LEAD93_LEAD405_backend_ac_validation.sql` | 与运行时 ID 对应的只读 MySQL 校验。 |
