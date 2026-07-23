# LEAD-93 需求与技术变更日志

> 用途：记录多个对话之间已经发生的需求、设计、接口、数据库和代码核对变化。
> 规则：本文件记录变化过程；当前是否已经确认，以 [未确认项与现状核对登记册](LEAD-93_Open_Questions_Register_CN.md) 和当前方案文档为准。
> 历史说明：本文件于 2026-07-23 建立。依据用户 2026-07-23 的明确要求，已对 2026-07-21 PRD v2.0 发布后至今的**已确认结论**做一次追溯汇总；未把无法由 PRD、Jira/OM 澄清、QA 证据或用户确认支撑的推测回填为基线。

## 当前工作入口

| 内容 | 文件 |
|---|---|
| 当前详细方案 | [LEAD-93_Template_Management_Solution_Design_CN_v3.md](LEAD-93_Template_Management_Solution_Design_CN_v3.md) |
| 当前评审稿 | [LEAD-93_Solution_Review_CN.md](LEAD-93_Solution_Review_CN.md) |
| 当前接口约定 | [LEAD-93_API_Contract_Clarification_CN.md](LEAD-93_API_Contract_Clarification_CN.md) |
| 当前开放项 | [LEAD-93_Open_Questions_Register_CN.md](LEAD-93_Open_Questions_Register_CN.md) |
| 内网代码调查 | [LEAD-93_Internal_Code_Verification_Checklist_CN.md](LEAD-93_Internal_Code_Verification_Checklist_CN.md) |
| 内网 AI 提示词 | [项目级提示词模板](../INTERNAL_AI_CODE_UPDATE_PROMPT_TEMPLATE_CN.md) |
| LEAD-93 分阶段实现提示词 | [LEAD-93_Internal_AI_Staged_Implementation_Prompt_CN.md](LEAD-93_Internal_AI_Staged_Implementation_Prompt_CN.md) |

## 变更总览

| 变更编号 | 日期 | 类型 | 摘要 | 状态 | 需要内网 AI |
|---|---|---|---|---|---|
| `CHG-20260721-01` | 2026-07-21 | 需求/范围/数据库 | PRD v2.0 基线、Email-only、分类字段与数据模型边界调整 | `IMPACT_ANALYZED` | 是：修改代码/SQL/测试 |
| `CHG-20260721-02` | 2026-07-21 | 需求/API/数据模型 | Copy and Create 定义为独立 Template B，并记录内部来源字段 | `IMPACT_ANALYZED` | 是：修改代码/测试 |
| `CHG-20260722-01` | 2026-07-22 | 数据模型/历史/查询 | Metadata 改为 Template 当前属性，历史与查询边界冻结 | `IMPACT_ANALYZED` | 是：修改代码/SQL/测试 |
| `CHG-20260722-02` | 2026-07-22 | API/兼容性/校验 | v1/v2 兼容、列表参数、Title/Tag/错误响应规则对齐 | `IMPACT_ANALYZED` | 是：修改代码/测试 |
| `CHG-20260723-01` | 2026-07-23 | 流程 | 建立多对话变更日志、影响分析和内网 AI 提示词流程 | `CONFIRMED` | 否 |
| `CHG-20260723-02` | 2026-07-23 | API/事务/删除流程 | 分类删除收拢为 NEW-12 单入口；新建和 Metadata 更新收拢为 EX-05/EX-06 外观聚合 | `IMPACT_ANALYZED` | 是：修改代码/测试 |

## 变更记录

### CHG-20260723-01：建立多对话变更管理机制

| 项目 | 内容 |
|---|---|
| 来源 | TL 工作方式确认 |
| 旧规则 | 变更分散在多个对话中，主要依赖人工记忆，无法快速判断是否需要同步内网代码 |
| 新规则 | 每次变化使用 `CHG-YYYYMMDD-NN` 编号；先记录变化，再分析文档、API、SQL、代码和测试影响；已确认代码变化才生成内网 AI 实现提示词 |
| 影响范围 | 项目流程、文档同步、内网代码协作 |
| 内网 AI 动作 | 不需要；这是流程变化 |
| 已同步 | 根目录 `AGENTS.md`、`PROJECT_CHANGE_CONTROL_CN.md`、内网 AI 提示词模板、LEAD-93 本日志 |
| 状态 | `CONFIRMED` |

## 2026-07-21 至 2026-07-23 追溯汇总

### CHG-20260721-01：PRD v2.0 范围与数据字段基线调整

| 项目 | 内容 |
|---|---|
| 来源 | `DAE_PRD_LEAD-93 Template Management_v2.0 - updated July 21st.docx`、用户确认、已冻结 SQL/方案记录 |
| 状态 | `CONFIRMED` / `IMPACT_ANALYZED` |
| 旧规则 | 旧 PRD/方案保留 Campaign 入口、Category Description、`format`、`category_code/category_level` 等候选字段；Category 的一级节点和软删除口径也未完全收敛。 |
| 新规则 | 本期 Web 恢复现状 Email-only，后端新建和查询固定 `is_campaign=0`；不提供 Campaign 页面/API。Category 不提供 Description，正式表使用 `id` 和 `parent_id=0` 表示一级节点，软删除统一为 `-1`。不新增 `format`、`category_code/category_level`、租户/国家或名称归一化列。 |
| 变更类型 | 需求、数据模型、SQL、API、查询 |
| 影响 Story/AC | LEAD-277、LEAD-293、LEAD-306、LEAD-327 |
| 影响文档 | V3 详细方案、评审稿、API Contract、开放项登记册、SQL Index |
| 影响接口 | EX-01/EX-02 固定 Email-only；Category Create/Update/Tree 不暴露 Description |
| 影响表和 SQL | `iic_msg_email_config`、`iic_msg_email_category`、Category/Config DDL、升级脚本与 Query/DML |
| 影响前端 | 不提供 Campaign 类型选择或 Description 输入；一级 Category 使用普通根节点展示 |
| 影响后端 | 固定 `is_campaign=0`、Service 校验 Category 层级与软删除条件 |
| 影响 QA | 回归 v1 不新增必填参数；验证 Category 字段、一级节点、软删除与 Email-only 查询 |
| 内网 AI 动作 | `修改代码`、`补 SQL`、`补测试` |
| 验证方式 | DDL 审阅、API 参数校验、Published/Draft List 回归、Category CRUD 回归 |
| 已完成同步 | V3、API Contract、SQL 结构和当前图已同步；评审稿/登记册本次同步 |
| 剩余问题 | `BUS-01` 正式存量 Mapping |

### CHG-20260721-02：Copy and Create 改为独立 Template B

| 项目 | 内容 |
|---|---|
| 来源 | 2026-07-21 LEAD-278 Jira/OM 澄清、用户确认 |
| 状态 | `CONFIRMED` / `IMPACT_ANALYZED` |
| 旧规则 | 容易将 Copy and Create 误解为 A 的 Working Copy 或调用 `/version/add` 创建新内容版本。 |
| 新规则 | 点击仅预填；首次 Save Draft 原子创建新 `email_code` 的 B、B.V1 Draft、B 当前 Metadata 和 CREATE History。B 保存 nullable `copy_from_email_code=A`，仅用于 B 发布前提醒 CM 按需停用 A；A/B 不建立页面导航、状态级联或共享 Version 关系。 |
| 变更类型 | 需求、API、数据模型、状态边界、测试 |
| 影响 Story/AC | LEAD-278 |
| 影响文档 | V3、评审稿、API Contract、登记册、Copy SVG、后端工作包 |
| 影响接口 | NEW-10；EX-16 在 `copyFromEmailCode` 非空时仅支持前端提醒，不增加发布前置条件 |
| 影响表和 SQL | `iic_msg_email_config.copy_from_email_code`、Template Change History、现有 relation 表 |
| 影响前端 | Copy 后不写库；B 发布前展示非阻断提示；A/B 在 Published List 独立出现 |
| 影响后端 | Copy Orchestrator 单事务写 B config/V1/relations/history；不得调用 `/version/add` 改 A |
| 影响 QA | A/B 同时 Published 可见、来源字段不在普通列表/Adviser Detail 暴露、任一写失败整体回滚 |
| 内网 AI 动作 | `修改代码`、`补测试` |
| 验证方式 | API 集成测试、数据库记录核验、A/B 生命周期回归 |
| 已完成同步 | V3、API Contract、SQL 设计、SVG 和 Story/工作包已同步 |
| 剩余问题 | 无业务开放项 |

### CHG-20260722-01：Metadata、修改历史与分类/标签模型冻结

| 项目 | 内容 |
|---|---|
| 来源 | 用户确认、PRD v2.0、已确认 SQL 结构与数据模型讨论 |
| 状态 | `CONFIRMED` / `IMPACT_ANALYZED` |
| 旧规则 | Category/Tag 一度按 Version 保存或由独立 Metadata 入口与 Version 写流程分散维护；历史字段和 Category 审计边界不完整。 |
| 新规则 | Category/Subcategory/Tag 按 `email_code` 保存一套当前值，不绑定 Version；Version History 继续只表达正文/附件/生效时间。Template 主信息、当前 Metadata、启停和软删除写 Template Change History；Category 节点 Create/Update/Reorder/Delete 写节点 Change History，删除另写操作级 Audit，共享 `operation_id`。Tag 固定 4 组、可多选，Trigger 最多 5；Draft 可空，Publish 必填。 |
| 变更类型 | 数据模型、审计、发布校验、查询、SQL |
| 影响 Story/AC | LEAD-277、LEAD-293、LEAD-300、LEAD-301、LEAD-307、LEAD-328 |
| 影响文档 | V3、评审稿、API Contract、登记册、ER/Taxonomy/Metadata SVG、SQL Index |
| 影响接口 | Detail/List 返回当前 Metadata；Publish 读取当前 Metadata；Tag Taxonomy 只读；不新增 Metadata History 页面/API |
| 影响表和 SQL | config `category_id`、Subcategory/Tag relation、Tag Group/Value、Template/Category History、Delete Audit、Migration Log |
| 影响前端 | Metadata 展示为“当前值”，不得宣称是历史 Version 快照；Tag 控件按 Taxonomy 动态返回 |
| 影响后端 | 关系全量替换、History 快照、当前值过滤、Publish 完整性校验、固定 Seed |
| 影响 QA | 验证 Draft 空 Metadata、Publish 必填、Trigger 上限、历史快照、当前 Metadata 查询和删除审计 |
| 内网 AI 动作 | `修改代码`、`补 SQL`、`补测试` |
| 验证方式 | DDL/DML 校验、Publish/Detail/List/Category Delete 集成测试、Migration Log 校验 |
| 已完成同步 | V3、API Contract、SQL 设计和 SVG 已同步 |
| 剩余问题 | `BUS-01`/`MIG-01`/`MIG-02` 存量 Mapping |

### CHG-20260722-02：v1/v2 兼容、列表契约与校验响应对齐

| 项目 | 内容 |
|---|---|
| 来源 | QA/Postman 实测、`real_code_ananly/api-v1.md`、`api-v2.md`、用户确认 |
| 状态 | `CONFIRMED` / `IMPACT_ANALYZED` |
| 旧规则 | v2 曾按新字段替换 v1 List 参数；错误响应曾设计为所有失败返回扩展 Error Detail；Title/Tag 边界与 QA 证据未完全统一。 |
| 新规则 | v1 是不可破坏基线；v2 `queryList/templateList` 保留 v1 必填字段并追加筛选。业务失败仍 HTTP 200 + `IICResponseModel`；普通失败 `data=null`，仅需字段定位的接口返回 `fieldErrors/invalidFieldCount`。Title 非空、最长 120、白名单；同一 Category 内唯一；实际 `responseCode/responseMessage` 由 QA 登记。 |
| 变更类型 | API、兼容性、校验、测试 |
| 影响 Story/AC | LEAD-277、LEAD-279、LEAD-327 |
| 影响文档 | v1 As-Is、V3、API Contract、登记册、Postman/Mock 说明 |
| 影响接口 | EX-01、EX-02、EX-05、EX-06、EX-16、NEW-08、NEW-11 |
| 影响表和 SQL | List/Count 查询和名称冲突 Query；无新表 |
| 影响前端 | 保留 v1 传参；只在字段定位场景解析 `fieldErrors`，不按 `responseMessage` 分支 |
| 影响后端 | 复用现有包络和鉴权，补 v2 DTO/参数、校验与错误适配 |
| 影响 QA | 对 v1 回归、v2 参数兼容、字段错误聚合、普通失败和 Version Conflict 分别验证 |
| 内网 AI 动作 | `修改代码`、`补测试` |
| 验证方式 | QA/Postman 实测、Contract JSON Schema/示例校验、v1/v2 回归 |
| 已完成同步 | V3、API Contract 和登记册本次同步 |
| 剩余问题 | 真实业务失败码继续按 `API-06` 由 QA/实现回填 |

### CHG-20260723-02：接口外观聚合与统一分类删除入口

| 项目 | 内容 |
|---|---|
| 来源 | 用户 2026-07-23 明确确认；当前 Web v2 Contract 重构 |
| 状态 | `CONFIRMED` / `IMPACT_ANALYZED` |
| 旧规则 | 新建 Template 是 EX-05 后调用独立 NEW-07 Metadata 的两步链式流程；EX-06 只改主信息。分类删除被拆为 Impact、Direct Delete、Reassign-and-Delete 多个 Endpoint。 |
| 新规则 | EX-05 在 `emailCode` 为空时采用外观聚合：同一事务生成 ID、写 config/V1 Draft、写 Category/Subcategory/Tag relations 和 CREATE History，失败整体回滚。EX-06 聚合更新已有 Template 的名称、描述与完整 Metadata 快照，不触发 Version 状态机。NEW-12 成为唯一分类删除入口：首次评估；有引用时返回影响并在带目标重提后同事务迁移并软删除。 |
| 变更类型 | API、事务、数据一致性、删除流程、文档 |
| 影响 Story/AC | LEAD-306、LEAD-301、LEAD-276、LEAD-300、LEAD-307 |
| 影响文档 | V3、API Contract、评审稿、登记册、API/工作量/删除 SVG、本文变更日志 |
| 影响接口 | EX-05、EX-06、EX-16、NEW-11、NEW-12；移除 NEW-04、NEW-07、NEW-09；去重后 25 个 Endpoint |
| 影响表和 SQL | 无新表；复用 config、Version、Category/Tag relation、Template/Category History 与 Delete Audit 的事务写入 |
| 影响前端 | 新建页面只调用 EX-05；已有 Template 一次调用 EX-06；删除弹窗对 NEW-12 的 `reassignRequired/impact` 进行二次提交 |
| 影响后端 | 新增/重构 Facade Service、单事务边界、字段错误聚合、统一 Delete Orchestrator；不改 Version 状态机 |
| 影响 QA | 覆盖创建整体回滚、EX-06 不改 Version、NEW-12 无引用直接删/有引用迁移删/并发复核、25 Endpoint Contract |
| 内网 AI 动作 | `修改代码`、`补测试` |
| 验证方式 | API Contract JSON 示例校验、事务集成测试、数据库前后比对、Mock/Postman 回归 |
| 已完成同步 | V3、API Contract、核心 SVG、评审稿与登记册本次同步 |
| 剩余问题 | HTTP/Mock/Postman Collection、英文文档和 DOCX 尚未按 25 Endpoint 重生成；真实错误码由 QA 回填 |

### CHG-20260723-03：PRD评审反馈规则补充（删除目标防环、修改分类归属与权限控制）

| 项目 | 内容 |
|---|---|
| 来源 | 2026-07-23 PRD 评审会反馈、用户明确确认 |
| 状态 | `CONFIRMED` / `IMPACT_ANALYZED` |
| 旧规则 | NEW-12 未显式说明目标分类不能为自身或待删除子树；EX-06 对子分类归属关系的错误定位未单独列出语义码；权限控制机制未做统一定义。 |
| 新规则 | 1. NEW-12 增加目标节点合法性强校验：`targetCategoryId` 不能等于被删除节点 ID，也不能为被删除节点树下子节点，违反时抛出 `INVALID_MIGRATION_TARGET`。未指定目标时返回 `data.reassignRequired` 与 `data.affectedTemplateCount`，字段以 API Clarification 为准。<br>2. EX-06 显式补充 `INVALID_SUBCATEGORY_BELONGING`（子分类不属于主分类）字段级错误码，定位 `field: "subCategoryIds"`。<br>3. EX-16 保持单次返回全部不合规字段列表（`fieldErrors[]`），由前端在页面顶部拉出统一错误提示。<br>4. 权限控制明确为“前端路由隐蔽入口 + 后端 URL/Token 拦截兜底”的双层控制模型。 |
| 变更类型 | API、校验、防环规则、错误码、权限、文档 |
| 影响 Story/AC | LEAD-301、LEAD-307、LEAD-277、LEAD-300 |
| 影响文档 | V3、API Contract、评审稿、登记册、本文变更日志 |
| 影响接口 | EX-06、EX-16、NEW-12 |
| 影响表和 SQL | 无新表；在后端 Service 校验增加防环逻辑 |
| 影响前端 | 删除弹窗限制目标下拉框剔除自身及子树；发布页面顶部统一展示 fieldErrors[] 列表；分类归属错误定位标红 |
| 影响后端 | NEW-12 增加目标分类拓扑防环校验；EX-06 增加父子分类归属校验并映射对应 Code |
| 影响 QA | 验证删除迁移选自身/子节点拦截；验证子分类不匹配报错定位；验证发布多错误列表 |
| 内网 AI 动作 | `修改代码`、`补测试` |
| 验证方式 | API Contract 格式核验、后端单元测试、Postman 参数边界回归 |
| 已完成同步 | API Contract、V3 方案和本文变更日志同步 |
| 剩余问题 | 无 |

## 2026-07-23 收尾

```text
今日新增变更：CHG-20260723-01、CHG-20260723-02、CHG-20260723-03；并按用户要求追溯汇总 CHG-20260721-01、CHG-20260721-02、CHG-20260722-01、CHG-20260722-02。
今日已确认：PRD v2.0 的 Email-only/字段边界、独立 Copy B、Template 当前 Metadata 与审计边界、v1/v2 兼容、EX-05/EX-06 外观聚合、NEW-12 统一删除入口及防环校验、EX-16 错误统一提示、双层权限模型。
今日仍开放：BUS-01/MIG-01/MIG-02 正式存量 Mapping；API-06 真实业务失败码；DOC-03 v2 HTTP/Mock/Postman 重生成；DOC-04 英文与 DOCX 派生交付同步。
需要内网 AI 调查：API-06 的 IICException/全局异常处理和真实 responseCode 映射。
需要内网 AI 实现：已确认的 EX-05/EX-06 聚合事务、NEW-12 统一删除与防环校验、DTO/Mapper/Service/集成测试，以及 25 Endpoint Mock/Postman 重生成。
已完成验证：当前中文 API Contract 为 25 Endpoint；Contract 全部 JSON 示例可解析；更新 Markdown 通过格式检查；核心 SVG 已同步文字并完成视觉检查。
```


## 待登记模板

以后每次新增变更复制以下模板，先填日志，再更新其他文档：

```markdown
### CHG-YYYYMMDD-NN：<一句话标题>

| 项目 | 内容 |
|---|---|
| 来源 | <PRD/Jira/BA/PO/TL/QA/内网 AI；日期和链接> |
| 状态 | `OPEN` / `PROVISIONAL` / `CONFIRMED` |
| 旧规则 | <变更前行为或方案> |
| 新规则 | <变更后行为或方案> |
| 变更类型 | <需求/状态机/数据库/API/查询/迁移/测试/文档/流程> |
| 影响 Story/AC | <...> |
| 影响文档 | <...> |
| 影响接口 | <...> |
| 影响表和 SQL | <...> |
| 影响前端 | <...> |
| 影响后端 | <...> |
| 影响 QA | <...> |
| 内网 AI 动作 | `不需要` / `只分析` / `修改代码` / `补测试` / `补 SQL` |
| 验证方式 | <...> |
| 已完成同步 | <...> |
| 剩余问题 | <开放项编号或“无”> |
```

## 每日收尾

```text
今日新增变更：
今日已确认：
今日仍开放：
需要内网 AI 调查：
需要内网 AI 实现：
已完成验证：
```
