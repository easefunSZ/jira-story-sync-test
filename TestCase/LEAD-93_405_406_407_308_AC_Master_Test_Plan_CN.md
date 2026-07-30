# LEAD-93、405、406、407、308 后端 AC 总测试流程

> 版本：2026-07-30。范围以 Jira 当日父子归属为准。本文是“应如何覆盖每个 Story AC”的主流程，不把尚未冻结的接口或纯前端行为伪造成已自动化通过。除已明确引用 `LEAD-93-405` 历史回归包的内容外，表中的 `FULL/BACKEND_SCOPE` 是**目标覆盖分类**，不是本轮实际运行结论。

## 1. 范围与来源

| Feature | Jira 子 Story | 主测试责任 | 来源状态 |
|---|---|---|---|
| LEAD-93 | LEAD-277、301、306、307 | Content Manager 基础模型、创建、目录维护 | 已有 68 条历史追溯中的 33 条，可按现有回归包执行。 |
| LEAD-405 | LEAD-276、278、293、300 | Content Manager 分类、Tag、Published 模板维护 | 已有 35 条历史追溯，可按现有回归包执行。 |
| LEAD-406 | LEAD-279、296、326、327、328 | 生命周期、删除、预览、搜索和迁移 | Jira Story 已读取；需扩展现有回归包。 |
| LEAD-308 | LEAD-312、313、314、315、316、317、318 | Adviser 发现、目录导航、搜索、筛选和排序 | Jira Story 已读取；多数为查询/API + UI 组合。 |
| LEAD-407 | LEAD-319、320、321 | Adviser 预览、上下文和激活 | Jira Story 已读取；激活下游接口尚未冻结。 |

**归属说明：**旧 `LEAD-93-405_*` 测试资产含八个 Story，是历史拆分前的共享回归包。当前 Jira 已将其中 LEAD-276/278/293/300 归属到 LEAD-405；本计划以当前 Jira 为准。

## 2. 全流程编排

```text
P0 读取基线与权限
 -> P1 Taxonomy 建立与校验
 -> P2 Template Draft / Metadata / Publish
 -> P3 Content Manager 维护与生命周期
 -> P4 Adviser 查询、导航、搜索和筛选
 -> P5 Preview / Activation / Migration
 -> P6 删除、软删除验证与 Cleanup
```

| 阶段 | 目标 | 主要 Story | API / DB 证据重点 | 失败处理 |
|---|---|---|---|---|
| P0 | 验证鉴权、基础列表和测试运行环境 | 全部 | API 响应包络、角色、可用 Published fixture | 认证/基础查询失败则停止后续依赖阶段。 |
| P1 | 创建、编辑、排序、删除 taxonomy | 93-301/307；405-293/300 | 分类树、唯一性、父子归属、Tag taxonomy、软删除关系 | taxonomy 创建失败，跳过需要其 ID 的后续写入。 |
| P2 | 创建 Draft、保存 Metadata、发布并确认可见性 | 93-277/306；406-279/326 | Draft/Published 状态、版本、必填校验、metadata relation | 发布 fixture 失败，Adviser 已发布查询以 `NOT RUN（缺少 fixture）` 标识。 |
| P3 | Published Copy、Draft 编辑、预约/取消预约、重分配 | 405-276/278；406-279 | 原 Published 不变、Working Copy、版本冲突、Metadata 变更不改状态 | 仅阻断依赖同一 Template 的后续步骤。 |
| P4 | Adviser list、目录、搜索、过滤和排序 | 308-312--318；406-327 | 只返回 Published 最新版本、关键词、分类/Tag AND/OR 过滤、排序字段 | 响应断言失败继续收集其余独立查询。 |
| P5 | CM/Adviser Preview、上下文、使用/激活、迁移 | 406-326/328；407-319--321 | Detail/Preview 数据、迁移后 mapping、下游 activation payload | 无冻结下游接口的项目为 `OPEN`，不能模拟通过。 |
| P6 | 删除与清理 | 93-307；406-296；405-276 | 引用保护、迁移、级联软删除、关系清理、测试数据 cleanup | Cleanup DB 失败必须显式 FAIL，不覆盖 API 的真实结果。 |

## 3. Story 到测试场景的完整映射

### 3.1 LEAD-93：基础能力

| Story | Jira 验收重点 | 场景 | 后端证据 | 目标覆盖分类 |
|---|---|---|---|---|
| LEAD-277 Template data model and validation framework | Draft 可不完整；Publish 校验名称、标题、正文、分类、子分类和四组 Tag；字段错误可定位。 | `SC-93-01 Draft vs Publish validation` | 创建/更新/发布 API；版本、Metadata relation、错误包络 DB/API。 | `FULL`，离页触发时机为 `UI`。 |
| LEAD-301 Assign & Edit Category & subcategory | 一个 Template 一主分类、多同父子分类；跨分类子分类拒绝；编辑同步显示及排序。 | `SC-93-02 Metadata assignment`; `SC-93-03 Taxonomy edit/reorder` | Metadata update、category tree、list/filter 查询、relation DB。 | `BACKEND_SCOPE`，下拉禁用/自动清空是 `UI`。 |
| LEAD-306 Create a new template | 首次 Save Draft 生成唯一 ID；Draft 仅 CM 可见；完成必填后 Publish 后 Adviser 可见。 | `SC-93-04 Create draft and publish` | add/update/publish、CM/Adviser list、config/version/metadata DB。 | `FULL`；页面路由和离页提示为 `UI`。 |
| LEAD-307 Delete category/subcategory | 有引用时阻止或迁移；无引用时级联软删除；删除节点不可再选。 | `SC-93-05 Delete taxonomy with/without references` | delete/reassign、tree/filter、category/relation status DB。 | `FULL`；确认弹窗文案为 `UI`。 |

已有逐条证据见：[LEAD-93/405 追溯矩阵](LEAD-93-405_AC_Traceability_CN.md)。

### 3.2 LEAD-405：Content Manager 维护

| Story | Jira 验收重点 | 场景 | 后端证据 | 目标覆盖分类 |
|---|---|---|---|---|
| LEAD-276 Template Reassignment | 编辑表单重新指定一主分类和多个同父子分类；改分类后旧子分类不得保留；Published/Draft 状态不改变。 | `SC-405-01 Reassign metadata` | metadata update、detail、list/filter 和 relation DB。 | `FULL/BACKEND_SCOPE`。 |
| LEAD-278 Published template copied, edited and republished | Published A 创建独立 Working Copy B；A 持续可用；B 保存/发布/丢弃不意外改变 A。 | `SC-405-02 Copy working copy lifecycle` | copy、Draft save、publish、discard、A/B config/version DB。 | `FULL`，WYSIWYG、离页弹窗是 `UI`。 |
| LEAD-293 Create category/subcategories | 建立两层 taxonomy；名称/数量/唯一性校验；失败不部分落库；创建后立即可用。 | `SC-405-03 Create taxonomy` | create/update/tree、唯一性负例、category DB。 | `FULL/BACKEND_SCOPE`。 |
| LEAD-300 Select, assign and edit tags | 读取固定 taxonomy；多选、回显、增删；Draft 不强制，Publish 必须四组完整；Published 改 Tag 不改状态。 | `SC-405-04 Tag metadata lifecycle` | tag taxonomy、metadata update、publish validation、tag relation DB。 | `FULL`，角色负例为 `CONDITIONAL`。 |

### 3.3 LEAD-406：运营控制

| Story | Jira 验收重点 | 场景 | 需要的后端验证 | 目标覆盖/当前缺口 |
|---|---|---|---|---|
| LEAD-279 Manage Draft & Publish Workflow | Draft、Publish、Schedule、Cancel Schedule、版本冲突和 Published 可见性。 | `SC-406-01 Version lifecycle` | V1/V2 状态迁移、时间字段、版本选择、冲突返回、DB version 状态。 | 需从现有版本生命周期阶段抽取为正式 AC 追溯。 |
| LEAD-296 Delete template | 模板删除/停用、关联数据处理、对 Adviser/CM 可见性的影响。 | `SC-406-02 Template delete` | 现有 delete/deactivate API、config/version/relation 软删除 DB、list 不可见性。 | `OPEN`：需以 Jira AC 和当前 Contract 冻结“删除/停用”的精确区别。 |
| LEAD-326 Template preview and validation | 发布前验证、CM Preview 与真实内容/Metadata。 | `SC-406-03 Preview and publish validation` | preview/detail/read-only 响应，发布负例。 | 后端数据校验可测；实际 HTML/附件渲染为 `UI`。 |
| LEAD-327 Search and filter templates | 名称、标题、描述、Tag 的局部匹配；分类/Tag 组合筛选；仅 Published。 | `SC-406-04 Search/filter semantics` | list/query API；正反例 fixture；分页/总数/过滤 DB。 | `GAP`：需将当前 API 的精确字段、AND/OR 与排序映射到 AC。 |
| LEAD-328 Data alignment/template migration | 将既有模板映射至 taxonomy/Tag；保留/停用按映射执行；可重复运行和记录结果。 | `SC-406-05 Migration verification` | migration script/API（如有）、mapping log、迁移前后只读 SQL。 | `OPEN`：需要冻结 mapping 文件、执行入口、幂等规则和迁移日志契约。 |

### 3.4 LEAD-308：Adviser 发现与筛选

| Story | Jira 验收重点 | 场景 | 后端证据 | 目标覆盖分类 |
|---|---|---|---|---|
| LEAD-312 View Template Library | 只显示 Published Template；卡片具备 Title、Description、Thumbnail、Tags、Preview/Use 数据。 | `SC-308-01 Published library list` | Adviser list、detail、Published/latest version DB。 | API 字段与可见性 `FULL`；卡片布局为 `UI`。 |
| LEAD-313 Navigate Template Categories | 选择 Category/Subcategory 更新结果；树可展开/收起。 | `SC-308-02 Category navigation` | category tree、按 Category/Subcategory 查询、计数。 | 查询 `FULL`；展开/收起 `UI`。Jira 原文仍有 “Add Acceptance Criteria” 占位，需 BA 补充。 |
| LEAD-314 Search a template | Title、Metadata 等关键词部分匹配，结果随条件更新。 | `SC-308-03 Keyword search` | `keyWords` 查询正反例、仅 Published、DB 搜索事实。 | `FULL/BACKEND_SCOPE`；动态输入节流/高亮为 `UI`。 |
| LEAD-315 Select Template Filters | Category/Subcategory 和四组 Tag 多选；跨维度 AND、同维度 OR。 | `SC-308-04 Filter logic` | tag taxonomy、组合 filter 查询、正反例 fixture。 | `GAP`：需冻结每个 filter 参数与同组 OR 的 Contract。 |
| LEAD-316 View active filters | 已选条件显示 chips，删除 chip 后刷新结果。 | `SC-308-05 Remove one filter` | 去除一个查询参数后的列表结果。 | 参数结果可 `BACKEND_SCOPE`；chip 显示为 `UI`。 |
| LEAD-317 Clear filters | 清空关键词/筛选后恢复完整 Published list。 | `SC-308-06 Clear all` | 无过滤条件查询与基线结果比较。 | `BACKEND_SCOPE`；按钮和页面状态为 `UI`。 |
| LEAD-318 Sort Templates | Relevant、发布时间、字母升降序的排序。 | `SC-308-07 Sort` | sort field/direction、稳定分页、排序前后结果。 | `OPEN`：Most Relevant 规则和 Published Date 字段尚未冻结，不发送猜测参数。 |

### 3.5 LEAD-407：Adviser 评估与激活

| Story | Jira 验收重点 | 场景 | 后端证据 | 目标覆盖分类 |
|---|---|---|---|---|
| LEAD-319 Preview Template | Published 模板只读预览，展示实际内容和格式；可从 Preview 进入 Send Email。 | `SC-407-01 Adviser preview` | Adviser detail/preview 仅返回 Published latest version；权限负例。 | 数据读取 `FULL`；窗口/真实渲染为 `UI`；下游入口见 LEAD-321。 |
| LEAD-320 View Template Context Information | Category、Subcategory、Tag、Format、Published 状态在 card/detail 可用。 | `SC-407-02 Context data` | Adviser list/detail Metadata 字段和 DB relation。 | 数据字段 `FULL`；页面呈现为 `UI`。 |
| LEAD-321 Template Usage & Activation | 从 Card/Preview/Detail 发起 Email 或 Campaign；使用当下最新 Published 版本。 | `SC-407-03 Activate latest published template` | activation endpoint、format route、latest version snapshot、下游 payload。 | `OPEN`：当前下游 Email/Campaign 激活接口与 payload 未冻结，不能用虚构 API 测试。 |

## 4. 新统一自动化包的落地顺序

在 LEAD-406/308/407 的 API Contract 冻结后，创建下列资产，不覆盖现有 `LEAD-93-405` 回归包：

```text
Lead-93/TestCase/
  LEAD-93-405-406-407-308_AC_Traceability.json
  LEAD-93-405-406-407-308_AC_Traceability_CN.md
  LEAD-93-405-406-407-308_Test_Scenarios.json
  postman/LEAD-93-405-406-407-308-backend-ac.postman_collection.json
  sql/ASSERT_LEAD-93-405-406-407-308_backend_ac.sql
  postman/run-lead93-405-406-407-308-ac-with-db.sh
```

执行顺序采用本文件第 2 章的 P0--P6。报告仍复用现有“阶段 Debug + 联合 AC 报告”的分层结构；每个新 Story 必须先有稳定 `SC-...` 与 AC 映射，再加入 Collection。

当前已提供的统一入口为 [`postman/run-lead93-405-406-407-308-ac-with-db.sh`](postman/run-lead93-405-406-407-308-ac-with-db.sh)：它复用现有 LEAD-93/405 逐条 AC 与 DB 报告，追加 LEAD-308/407 Adviser 只读 Contract 阶段，并输出跨 Feature 总览。第 5 章的开放项冻结后，再将它们提升为新的逐条 Traceability 和数据库断言，不能先以占位请求替代。

## 5. 开工前必须补齐的内容

| 编号 | 缺口 | 影响 Story | 所需确认/输入 |
|---|---|---|---|
| O-01 | LEAD-296 的 Delete 与 Deactivate 的最终 AC/接口差异。 | 406 | Jira AC 原文与当前 API Contract 的明确映射。 |
| O-02 | LEAD-327 的搜索字段、filter 参数、同维度 OR/跨维度 AND 和分页规则。 | 406、308 | 冻结 API Contract 后生成正反例。 |
| O-03 | LEAD-328 的 mapping 来源、执行入口、幂等性、失败处理、迁移日志表。 | 406 | 已批准 mapping 文件及迁移方案。 |
| O-04 | LEAD-313 中的 “Add Acceptance Criteria” 占位。 | 308 | BA 补充正式 AC。 |
| O-05 | LEAD-318 的 Most Relevant 计算、Published Date 来源、可接受 sort 枚举。 | 308 | PO/BA/后端共同冻结。 |
| O-06 | LEAD-321 的 Email/Campaign activation endpoint、授权、payload 和版本快照规则。 | 407 | 下游系统 Contract；未确认前仅验证库内 latest Published 查询。 |
| O-07 | Adviser 与 Content Manager 的角色测试凭证。 | 306、300、405、407 | 测试环境可用的最小权限 Token/账户，不写入版本库。 |

## 6. 通过门槛

只有当每个 Jira AC 都在 Traceability 中标为 `FULL`、`BACKEND_SCOPE`、`UI`、`CONDITIONAL` 或已批准的 `OPEN`，且 `FULL` 项都有真实 API/DB 运行证据时，才能发布测试结论。

`OPEN`、`GAP` 或 `CONDITIONAL` 未配置不等于通过；它们必须在报告总览和发布风险中单独显示。

## 7. 参考资料

- [后端 AC 自动化测试方法手册](BACKEND_AC_AUTOMATION_TESTING_PLAYBOOK_CN.md)
- [LEAD-93/405 历史逐条 AC 追溯](LEAD-93-405_AC_Traceability_CN.md)
- [LEAD-308 本地 Story 原文](../../Jira-conflunce-mcp-analazy/features/LEAD-308_Template_Library_Usage_Adviser/stories/)
- [当前测试资产目录](postman/)
