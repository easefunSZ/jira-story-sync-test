# 后端 AC 自动化测试方法手册

> 适用范围：以 Jira Story/Acceptance Criteria（AC）为输入、以 HTTP API 和数据库事实为证据的后端集成测试。本文沉淀自 LEAD-93/405 的实际执行方式，可直接作为后续 Feature 的测试资产设计模板。

## 1. 目标与边界

目标不是“把接口逐个调通”，而是让每一条可由后端承担的 AC 都能追溯到可重复执行的证据：请求、响应、持久化结果和最终报告。

不把以下项目误报为后端通过：页面按钮、弹窗、跳转、富文本视觉渲染、筛选 chip 展示等纯前端行为；也不伪造未冻结的下游系统接口。

## 2. 输入与证据优先级

| 优先级 | 输入 | 用途 |
|---|---|---|
| 1 | 当前 Jira Story 与 AC | 测试范围和验收语义的唯一业务来源。 |
| 2 | 已冻结 API Contract | 请求、响应、错误码和字段类型。 |
| 3 | 已发布 DDL / 数据迁移脚本 | 数据库断言的表、状态和关系约束。 |
| 4 | 实际 API 调用与运行日志 | 校正契约与实现的偏差，不能反向篡改业务 AC。 |
| 5 | 技术方案 / PRD | 用于补充背景和跨 Story 依赖，不替代 Story 的明确 AC。 |

没有以上证据的结论必须标记为 `OPEN`，先调查，不写入断言或生产实现要求。

## 3. 固定追溯模型

每条测试资产都使用下列链路，编号稳定且可读：

```text
Feature -> Story -> AC -> 场景（SC-xx） -> 步骤（SC-xx.1/2/...）
        -> API 请求（API-xx） -> DB 检查点（DB-xx） -> HTML 证据
```

| 层级 | 必填内容 | 例子 |
|---|---|---|
| Story | Jira Key、标题、当前父 Feature | `LEAD-278`。 |
| AC | 原文或不改变语义的中文验收点、覆盖分类 | `AC6`：Copy B 发布不影响 A。 |
| 场景 | 一个完整业务目标和前置数据 | `SC-COPY-01`：从 Published A 创建并发布 B。 |
| 步骤 | 顺序、调用接口、关键断言、依赖关系 | `SC-COPY-01.3`：保存 B Draft。 |
| API | Method、URL、请求、响应码、字段断言 | `POST /v2/...`。 |
| DB | 只读 SQL、预期行、实际列和行 | `DB-COPY-01`。 |

一个 AC 可映射多个步骤；一个步骤也可为多个 AC 提供证据。关联必须在 Traceability JSON 中显式写出，不能按 API 编号区间推导。

## 4. 覆盖分类

| 分类 | 含义 | 报告规则 |
|---|---|---|
| `FULL` | API 和/或 DB 证据足以判定通过或失败。 | 计算 `PASS/FAIL`。 |
| `BACKEND_SCOPE` | 后端规则已验证，余项为纯 UI。 | 后端结果 `PASS（后端范围）`，UI 不计失败。 |
| `UI` | 完全是页面交互或视觉效果。 | `N/A UI`，转前端测试计划。 |
| `CONDITIONAL` | 依赖可选登录态、角色或外部系统。 | 未配置时 `NOT RUN（条件未满足）`；不能当成功。 |
| `OPEN` | 接口、字段、错误码、排序定义或外部行为未冻结。 | 不写伪造请求，登记待澄清。 |
| `GAP` | 后端应可测，但当前缺 API 或 DB 证据。 | 不能宣布全覆盖，必须补资产。 |

## 5. 设计流程

### 5.1 建立 AC 追溯表

先按 Story 将每条 AC 原子化。每行至少包含：`storyKey`、`acId`、验收点、分类、场景 ID、步骤 ID、API ID、DB ID、前置条件、未覆盖原因。

建议资产：

```text
<Feature>_AC_Traceability.json        # 机器可读唯一来源
<Feature>_AC_Traceability_CN.md       # 评审用表格，由 JSON 生成
<Feature>_Test_Scenarios.json         # 场景、步骤、阻断关系
<Feature>_API_Code_Models.json        # API 到 DTO/VO/Service 的排查提示
```

### 5.2 先设计数据生命周期，再设计接口顺序

对写入测试，推荐顺序如下；无依赖查询可放在最前：

1. 基线查询、鉴权与 taxonomy 读取。
2. 创建可清理的 Category / Subcategory / Tag 测试数据。
3. 创建 Template Draft，保存 Metadata，完成发布校验。
4. 发布、预约、取消预约、编辑和 Copy 等生命周期场景。
5. Search、Filter、Detail、Preview 数据读取以及 Adviser 可见性。
6. Reassignment、Category 删除迁移、软删除等破坏性场景。
7. DB checkpoint 验证后执行 Cleanup。

每次运行生成唯一前缀与运行时 ID。不得使用固定生产数据作为断言对象。

### 5.3 失败与阻断规则

- 断言失败要记录并继续执行无依赖步骤，避免一次字段差异遮蔽后续问题。
- 仅当创建夹具、取得关键 ID、发布前置状态等真正失败，才跳过依赖步骤；跳过原因必须写入报告。
- API 请求成功但响应结构不符合 Contract：该 API 步骤为 `FAIL`，后续只要不依赖缺失字段仍继续。
- DB 连接、执行或证据解析失败：对应 DB 步骤和关联 AC 为 `FAIL`，不是 `NOT RUN`。
- `NOT RUN` 只表示没有执行记录或刻意未启用的条件用例。

## 6. 数据库校验规则

1. SQL 只允许 `SELECT`、会话 `SET` 或必要的只读元数据查询；校验执行器必须拒绝 DML/DDL。
2. 每个 checkpoint 在测试数据仍存在时执行；Cleanup 后仅验证软删除/关系清理结果。
3. SQL 必须使用运行时变量，跨表字符串比较需要处理实际数据库的 collation 差异。
4. 每个结果保存检查编号、实际 SQL、列名、返回行、PASS/FAIL 和简短 evidence。
5. 联合报告只显示 DB 摘要与链接；阶段 Debug 报告展示完整 SQL 与返回行，便于把 API 请求、响应和 DB 事实放在一起排查。

## 7. 运行与报告分层

| 产物 | 面向对象 | 内容 |
|---|---|---|
| Newman raw JSON | 自动化工具 | 原始请求、响应、断言。敏感信息放私有目录。 |
| 阶段 `*.debug.html` | 开发 / QA 排障 | URL、请求、响应、逐条断言、该阶段 DB SQL 与返回。 |
| 联合 AC 报告 | 评审 / 发布决策 | Story 总览跳转、场景步骤、AC 判定、DB 摘要、条件未执行清单。 |
| Traceability Markdown | BA / QA / 开发 | Story-AC-场景-步骤-证据的静态说明。 |

联合报告顶端必须有每个 Story 的总览和锚点，详细内容按“Story -> 场景 -> 步骤 -> AC”呈现。不要把所有错误堆在一列文本中。

## 8. 跨平台与安全运行

- 运行 Manifest 只存相对路径；报告生成器兼容历史 Windows Git Bash `/d/...` 路径。
- 凭证、Token、私有 raw JSON 和数据库返回不提交版本库。
- 本机 MySQL CLI 不存在时可使用 Python PyMySQL 回退；使用标准 `MYSQL_HOST`、`MYSQL_PORT`、`MYSQL_USER`、`MYSQL_DATABASE`、`MYSQL_PWD` 配置。缺包时安装 `PyMySQL`，不要把密码写入脚本。
- API 与 DB 可分机器运行：API 结果和 DB checkpoint 通过 Manifest 汇合，不能因 DB 失败丢失已完成的 API 结果。

## 9. 新 Feature 复制清单

1. 从 Jira 读取当前 Feature、子 Story、AC 和依赖；记录读取日期。
2. 先写 `Traceability.json`，逐项标明 `FULL/BACKEND_SCOPE/UI/CONDITIONAL/OPEN/GAP`。
3. 定义唯一测试数据前缀、创建链路和 Cleanup 责任。
4. 按依赖生成 Postman Collection：查询先行，写入按生命周期排序。
5. 为状态、关系、软删除、可见性和迁移结果添加只读 DB checkpoint。
6. 为每个 API 添加正例、负例、错误包络和关键字段断言。
7. 配置“仅真正前置失败才阻断”的场景控制；不要使用全局 fail-fast/bail。
8. 运行一次，检查 Debug 报告能看到真实请求/响应/SQL，联合报告能定位到 Story、场景、步骤和 AC。
9. 将 UI、条件权限、外部系统和未冻结 Contract 的项单列，交给对应责任人，不以“未测”掩盖。

## 10. 当前参考实现

- [LEAD-93/405 后端 AC 追溯矩阵](LEAD-93-405_AC_Traceability_CN.md)
- [LEAD-93/405 后端回归包说明](LEAD-93-405-backend-ac-README_CN.md)
- [Postman、运行器、报告生成器和 SQL](postman/)
- [跨 Feature 主测试流程](LEAD-93_405_406_407_308_AC_Master_Test_Plan_CN.md)

本文是测试方法，不是业务需求基线。新的 Story/AC 进入自动化前，仍须遵循项目变更控制和当前 API/DDL 基线。
