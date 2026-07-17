# LEAD-93 Template Management 解决方案设计文档

> 技术方案评审版 v3  
> 状态：Draft for Technical Review  
> 需求基线：`DAE_PRD_LEAD-93 Template Management_v1 - updated July 14th.docx`（PRD v1.1）
> 说明：本文先固化 As-Is，再做 Gap Analysis，最后给出 To-Be 设计。未确认信息统一放在“待确认项”，不作为实施基线。
> 统一未确认项：[未确认项与现状核对登记册](LEAD-93_Open_Questions_Register_CN.md)。登记册中的开放项及状态为唯一有效索引。

## 1. 文档目的

本文描述 LEAD-93 Template Management 在现有 DAE 系统上的改造方案，目标是：

- 清楚说明当前 Template 数据模型、版本生命周期、页面查询和核心操作行为。
- 对比 PRD 目标，明确新增能力和现有能力之间的差异。
- 建立 Jira Story、As-Is/Gap、To-Be 设计和实施产物之间的双向可追溯关系。
- 在保留现有模板主表、版本表和生命周期机制的前提下，设计 Category/Subcategory、Tag、Search/Filter 和 Migration 方案。
- 为开发拆分、数据库变更、API 联调、测试和上线提供统一技术基线。

## 2. 结论摘要

本项目应定义为“现有 Template Management 能力增强”，不是新建模板系统。

核心设计结论如下：

1. 保留 `iic_msg_email_config` 和 `iic_msg_email_config_version`，不重建 Template 主模型和版本状态机。
2. `email_code` 继续作为逻辑模板的业务标识；Category/Subcategory/Tag metadata 按 `email_code + version` 随内容版本保存，支持 Active 与 Draft/Schedule 同时拥有不同 metadata。
3. 新增 Template 专用表 `iic_msg_email_category`，承载 Category/Subcategory 两级 taxonomy。
4. 在 `iic_msg_email_config_version` 增加 `category_id`；新增 Subcategory Relation、Tag Group、Tag Value 和 Template Tag Relation 表。
5. Published/Draft Tab 保留，Content Manager 保留 Status Filter 能力，但 Published Tab 不展示/不允许选择 Status Filter；搜索在现有 Tab 基础查询上叠加 Category、Tag、`is_campaign` 等条件。
6. 不新增数据库外键和 check constraint；关系完整性、层级合法性和必填校验由 Service 层保证。
7. 初始 Category、Tag 及存量模板映射由幂等 SQL 上线，DBA 执行；Tag 后续仍只允许通过 DB 脚本维护。
8. Subcategory 支持一次最多 5 条的原子批量创建；删除 Category/Subcategory 时由后端在同一事务中迁移 Active/Draft/Schedule Metadata 后软删除节点，Expired 历史版本不迁移。
9. 不新增 Template 编辑锁、revision token 或 Redis lock；复用现有 Version Conflict 检测和错误语义。
10. 一次性数据迁移使用独立 Migration Log 记录执行结果；该表不是运行时 Audit Log，也不替代用于回滚的 Migration Snapshot。

## 3. As-Is 现状分析

### 3.1 当前数据模型

![LEAD-93 As-Is 数据模型](diagrams/lead93-as-is-data-model.svg)

当前 Template 由主表与版本表共同构成：

| 表 | 当前职责 | 关键字段 |
|---|---|---|
| `iic_msg_email_config` | 逻辑模板主记录、启停状态和软删除状态 | `email_code`, `email_name`, `email_status`, `status`, `is_campaign` |
| `iic_msg_email_config_version` | 模板正文、附件引用、版本和生效状态 | `email_code`, `version`, `version_status`, `effective_from`, `effective_until`, `email_content`, `file_keys`, `status` |
| `iic_msg_file_upload` | 附件元数据及 S3 文件引用 | `file_key`, `file_name`, `file_type`, `size`, `obs_type`, `view_url` |

当前没有数据库外键。表间业务关系由应用代码维护。

图中只包含现有 Template Management 范围内的表，并只连接已有证据支持的关系：`iic_msg_email_config` 通过 `email_code` 对应多个 version，version 通过 `file_keys` 引用附件记录。

#### 3.1.1 Master 与 Version 字段归属

![LEAD-93 As-Is 记录归属](diagrams/lead93-as-is-record-ownership.svg)

- `iic_msg_email_config` 表示逻辑模板，保存名称、描述、Email/Campaign 类型、启停和软删除状态。
- `iic_msg_email_config_version` 表示内容版本，保存 Subject、正文、附件引用、生效时间和版本生命周期状态。
- 同一 `email_code` 可以同时存在一个 Active 和一个 Draft Working Copy；Draft 不影响当前 Active 内容。
- Publish 主要修改 version row；Deactivate/Active 只修改 config `email_status`；Delete 软删除 config 和所有 version，但不重写 `version_status`。

### 3.2 Template Identity

`email_code` 是邮件模板的业务标识编码，由后端使用 Snowflake 算法生成，现有业务查询、更新和关联都依赖该字段。

设计约束：

- LEAD-93 不改变 `email_code` 的业务含义和生成方式。
- 新增表使用 `email_code` 关联逻辑模板，不使用 version row `id` 作为 Template Identity。
- Search/Filter 返回结果按 `email_code` 去重。
- 新建模板首次 Save Draft 时由后端生成 `email_code`；更新请求使用已有 `email_code` 定位逻辑模板。
- 逻辑唯一性由服务和数据校验保证；不假设历史物理数据天然无重复。

### 3.3 状态字段语义

#### 3.3.1 主表状态

| 字段 | 值 | 含义 | 影响 |
|---|---:|---|---|
| `iic_msg_email_config.status` | `0` | 有效 | 记录可参与正常业务查询 |
| `iic_msg_email_config.status` | `-1` | 已软删除 | 从正常业务查询排除 |
| `iic_msg_email_config.email_status` | `1` | Enabled | 可出现在 Published 可用集合中 |
| `iic_msg_email_config.email_status` | `0` | Disabled | Deactivate 后的模板状态 |

#### 3.3.2 版本状态

| `version_status` | 状态 | 时间字段 | 触发方式 |
|---:|---|---|---|
| `0` | Schedule | 用户在 Publish 时指定未来 `effective_from`；不设置 `effective_until` | Publish 选择未来时间后进入；定时任务到点触发 |
| `1` | Active | `effective_from = now`；`effective_until = NULL` | Publish 或 `changeVersionStatusByEffectiveFrom()` 触发 |
| `2` | Expired | 保留原 `effective_from`；`effective_until = now` | 新版本发布或定时任务触发 |
| `3` | Draft | As-Is Save Draft 可保存用户输入的 `effective_from/effective_until`，但无论时间是否在未来都保持 Draft | 不参与自动状态流转 |

所有接口时间字段使用 `yyyy-MM-dd HH:mm:ss`，服务器、业务和用户统一按南非业务时区 `Africa/Johannesburg`（UTC+02:00）解释。

#### 3.3.3 状态维度关系

数据库样本中同时存在不同 `status`、`email_status` 和 `version_status` 组合，说明软删除、模板启停和版本生命周期是三个独立维度。软删除记录仍保留原生命周期值，任何查询或更新都不能用其中一个字段替代另一个字段。

### 3.4 当前状态流转

![LEAD-93 As-Is 状态流转](diagrams/lead93-as-is-state-flow.svg)

需要明确区分两类状态：

- `version_status` 描述内容版本的 Draft、Schedule、Active、Expired 生命周期。
- `email_status` 和 `status` 描述逻辑模板是否启用、是否软删除。

Deactivate 和 Delete 均不改变任何 version row 的 `version_status`。

### 3.5 当前页面 Tab 查询

#### 3.5.1 Published Tab

现有 Published list 的核心条件为 `version_status = 1`、`config.status = 0`、`config.email_status = 1`、`config.is_campaign != 1`。这些条件已由查询结果确认。

说明：

- `version.version_status = 1` 是现有 Published 查询和版本语义上的 Active 条件。
- `version_status = 1` 是版本语义上的 Active 状态，用于发布状态流转。
- 理论上一个 `email_code` 可能出现多个 `version_status = 1`，但现有代码保证不会发生，本期不新增状态机约束。

#### 3.5.2 Draft Tab

现有 Draft Tab 由 `email_status = 0`、非 V1 的 Draft/Schedule，以及 V1 的 Draft/Schedule 三个 OR 分支组成。三个分支和最终选版业务结果均已确认。

因此 Draft Tab 不是简单的 `version_status = 3`，还包含 Schedule 记录和部分 Disabled 模板。LEAD-93 Search/Filter 必须复用这套现有查询语义。

#### 3.5.3 Published/Draft 查询对照图

![LEAD-93 As-Is Tab 查询](diagrams/lead93-as-is-tab-query.svg)

Published 固定返回 Active version。Draft Tab 在命中其 OR 分支后返回最大数字版本 V(N)；Active version 本身一定是当前最大数字版本。组合结果如下：

| 数据组合 | Published Tab | Draft Tab |
|---|---|---|
| Active + Draft | Active | 最大版本 Draft |
| Active + Schedule | Active | 最大版本 Schedule |
| Disabled + Active | 不显示 | 最大版本 Active |
| Active + 多个 Expired | Active | 不显示 Expired |
| Disabled + 多个 Expired | 不显示 | 最大版本 Expired |
| Expired + Draft | 不显示 | 最大版本 Draft |

该矩阵是已确认的业务结果，选版规则不再作为业务待确认项。

### 3.6 当前核心操作行为

本节只作为 As-Is 事实基线，详细场景差异见第 5.2 节。

| 操作 | 当前数据库行为 | 状态变化 | 明确不修改 |
|---|---|---|---|
| Save Draft：无 version / 已有 Draft | V1 不存在则 Insert V1；已有 Draft V(N) 则 Update V(N) | 目标 version 保持 `version_status = 3`；用户输入的 `effective_from/effective_until` 写入 Draft row | 当前 Active 内容 |
| Save Draft：Active、无 Draft | Insert V(N+1) Working Copy | 新 version 为 Draft `3`；Active V(N) 保持 `1` | 当前 Active 内容和生效时间 |
| Save Draft：仅 Expired、无 Draft | 复用并 Update V(N)，不 Insert V(N+1) | 同一 version `2 → 3`；保留原 `effective_from/effective_until` | Template Identity |
| Save Draft：Schedule | 复用并 Update V(N)，不创建并存 Draft | 同一 version `0 → 3`；保留原 `effective_from/effective_until` | 旧 Active 和 Template Identity |
| Delete Scheduled Version | 按现有 Version Delete 路径软删除 Scheduled V(N) | `version.status → -1`；保留 `version_status = 0` 和原生效时间 | 旧 Active、config 和其他 version |
| Publish Now | 更新新旧 version 和 effective time | 旧 Active `1 → 2`；目标 Draft `3 → 1`；新 Active 的 `effective_from = now`、`effective_until = NULL` | `config.email_status` |
| Scheduled Activation | Java 定时任务 `changeVersionStatusByEffectiveFrom()` 处理到期版本 | Schedule `0 → 1`；旧 Active `1 → 2` | Template Identity |
| Deactivate | 只更新 `iic_msg_email_config.email_status: 1 → 0` | version 仍保持原 `version_status` | config `status` 和所有 version `version_status` |
| Delete | config 与该模板所有 version 级联软删除 | 修改 config/version 的软删除 `status` | 所有 version `version_status` |

现有 Template version 写操作未使用乐观锁、revision token 或 Redis lock，存在并发覆盖风险。本期将其登记为已知且接受的现状风险，不新增锁、token 或 `requestId`；Delete 不提供一键恢复。

### 3.7 当前附件机制

- 附件存储到 S3，文件元数据位于 `iic_msg_file_upload`。
- 单个附件最大 10 MB，对应现有 `size` 字段口径为 `size <= 10240 KB`。
- 附件格式维持现状，但明确排除多媒体、视频和音频。
- LEAD-93 不改变正文版本通过 `file_keys` 引用附件的方式。

### 3.8 As-Is 适用边界

第 3.1-3.7 节作为数据库与业务行为的现状基线。后续设计不得改写本章已确认的状态、选版和数据行为。

2026-07-16 QA 黑盒回归覆盖了 15 个本次交付范围内的现有接口及 2 个辅助查询接口，共完成 22 个有序调用场景。HTTP、公共包络、业务码和已记录状态结果符合预期。已实测的关键状态结果包括：新建 V1 Draft、更新 V1、同一 V1 立即 Publish、Deactivate/Reactivate、增加 V2 后 V2 Active/V1 Expired、Draft/Schedule version 删除成功、Active version 删除被拒绝，以及 Template Delete 成功。

以下行为未由本轮黑盒回归覆盖，不能仅凭本次结果标记为接口事实已冻结：Publish Future、Scheduler 到点生效、Expired/Schedule Save Draft、Active 首次 Save Draft 创建 Working Copy，以及 Version Conflict。上述行为继续以已确认业务规则、数据库证据和代码核对为基线。

本轮还确认：在 v1 `POST /version/add` 提交目标 `version="V2"` 的完整 payload 后，可观察结果是 V2 Active、V1 Expired。该接口保留“增加版本并切换 Active”的现有语义，并在 v2 中接入版本 Metadata 和 Published Validation。Copy and Create 的业务对象、复制范围、持久化时点及是否新增 v2 API 尚未确认，不能从 `/version/add` 或 Working Copy 流程推导。

## 4. 新需求摘要

LEAD-93 在保留现有 Template 主模型、版本生命周期和附件机制的基础上增加以下能力：

| 能力域 | 新需求 | 关键业务规则 | 主要影响范围 | 验收关注点 |
|---|---|---|---|---|
| Category/Subcategory | 提供可管理的两级 Template 分类树 | 仅允许两级；名称在 Template taxonomy 内全局唯一；Subcategory 必须归属有效 Category；单次原子批量创建最多 5 条；删除前自动迁移 Active/Draft/Schedule Metadata | 前端管理页面、Category API、新增 `iic_msg_email_category`、Metadata relation | 层级合法、全局重名、批量原子性、迁移与软删除原子性、排序稳定 |
| Tag Taxonomy | 提供固定 Tag Group 和 Tag Value | 4 个必填组、2 个可选组；每个 Group 可多选；Draft 缺失必填值时使用 `Unclassified`；不提供 Tag 管理 UI | Tag 只读 API、新增 Tag 字典表、DBA seed | 固定值完整、组内多选、必填组至少一项、上线后仅 DB 脚本维护 |
| Template Metadata | 建立 Template Version 与主 Category、Subcategory、Tag 的结构化关系 | 主 Category 直接存入 version row；Subcategory/Tag 按 `email_code + version` 保存；Metadata 生命周期跟随目标 version | 扩展 version 表、Save Draft/Publish/编辑流程、新增 relation 表 | 同版本关系一致、无孤儿和重复关系 |
| Search/Filter | 支持按 PRD 定义的 Title、Description、Tag Name 关键词，以及 Category、Subcategory、6 个 Tag Group、Status、`is_campaign` 组合查询 | `is_campaign` 为必传；Published Tab 禁用 Status Filter；跨维度 AND，同维度 OR/ANY；关联当前结果 version 的 metadata | 列表 API、Mapper SQL、前端筛选器和索引 | 关键词范围不超出 PRD、版本 metadata 匹配正确、Count 与分页准确 |
| Published 编辑 | 编辑 Published Template 时区分直接 metadata-only 变更与 Draft Working Copy 变更 | 直接修改 Active 版本 metadata 时立即生效；通过 Draft 保存的 metadata 只对 Draft 生效，Publish 后再替换 Active metadata | 编辑页面、Save Draft、metadata API、Publish validation | Active 内容不中断、Working Copy 隔离、Discard 边界明确 |
| Template 可见性 | 统一 Content Manager Tab 与 Adviser View 的可见性规则 | Adviser 只能读取 Enabled + Active Published 内容；Draft/Schedule 不可见；Deactivate/Delete 保持现有生命周期语义 | Published/Draft 查询、Adviser 查询、权限控制 | 不可通过参数绕过 Published-only；Deactivate 后不可见 |
| Publish Validation | 发布前增加 Title、Description、Category、Mandatory Tag 和正文完整性校验 | 附件不必填且由前端校验；后端不新增附件校验；业务校验失败不修改旧 Active | Publish API、定时任务、错误响应 | 状态更新原子、旧 Active 安全、错误信息可定位 |
| Migration | 对存量模板进行分类、标签映射和必要的数据清理 | PO/BA 提供 79 个模板的保留/合并/淘汰与映射；DBA 执行幂等、可校验、可回滚 SQL；独立记录一次性迁移执行日志 | Staging、Snapshot、Migration Log、DDL/DML/QUERY、上线流程 | 数量对账、重复/孤儿检查、Mandatory Tag 完整、批次与执行结果可追踪 |
| 附件约束 | 延续 S3 和 `file_keys` 机制并收紧文件边界 | Email/Campaign 附件均为可选；单个附件最大 10 MB；维持现有格式能力，排除多媒体、视频和音频 | 前端校验、复用现有附件接口、测试 | 不上传附件可正常发布；非法文件在前端阻止提交 |

明确不在本期范围：

| 排除项 | 本期处理原则 |
|---|---|
| 重建 Template 主表和版本表 | 继续复用 `iic_msg_email_config` 和 `iic_msg_email_config_version` |
| 重写 Draft/Published 状态机 | 保留 Draft、Schedule、Active、Expired 及现有 version control |
| Tag 管理 UI | Tag 首次固定 seed，后续仅通过受控 DB 脚本维护 |
| 乐观锁、revision token、编辑锁、Redis lock、`requestId` | 本期不新增；继续复用现有 Version Conflict 检测 |
| Elasticsearch | 本期使用数据库查询；数据量显著增长后再评估 |
| 一键恢复已删除模板 | Delete 继续按现有软删除语义，不提供业务恢复入口 |
| 多媒体、视频和音频附件 | 明确禁止上传和发布 |

## 5. Gap Analysis

### 5.1 能力差异总览

![LEAD-93 Gap Analysis](diagrams/lead93-gap-analysis.svg)

| 能力 | As-Is | LEAD-93 Gap | 设计决策 |
|---|---|---|---|
| Category | Template Management 当前没有 Category/Subcategory 数据模型或管理流程 | 需要 Category/Subcategory 管理、批量创建和删除前自动迁移 | 新增专用表 `iic_msg_email_category`、管理 API 及原子 Reassign-and-Delete 命令 |
| Tag | 无 Template 固定标签体系 | 需要固定组和值及模板关联 | 新增 Tag 字典和关系表，SQL seed |
| Template Metadata | 核心字段分布于主表/版本表 | Version 缺少主 Category，且没有 Subcategory/Tag 结构化关系 | version 表增加 `category_id`，新增 Subcategory/Tag 关系表 |
| Search/Filter | Published/Draft 各自有复杂过滤 | 需要组合过滤但不能改变存量语义 | 复用 Tab Base Query 后扩展 join |
| Lifecycle / Effective Time | Save Draft 保存时间并得到 Draft：Active 无 Draft时 Insert V(N+1)，Expired/Schedule 则复用 V(N) 并分别执行 `2 → 3`/`0 → 3`；Publish 才根据未来时间转 Schedule；Scheduled version 也可通过 Version Delete 软删除 | 无生命周期或 effective-time 行为 Gap；LEAD-93 只需把版本 metadata 接入现有 Save Draft、Publish、Version Delete 和定时任务 | 保留现有版本选择与状态触发边界；不新增独立 Cancel Schedule API |
| Migration | 无新 taxonomy 映射 | 需初始化及映射存量模板，并保留一次性执行结果 | DBA 执行幂等 SQL、Migration Log 和校验报告 |

### 5.2 场景状态机对比

本节对比各业务场景的 As-Is 基线、To-Be 保持项及新增差异。对于生命周期及生效时间规则，To-Be 保持现状；LEAD-93 主要新增版本级 Metadata、发布校验及事务一致性处理。第 8 章不再重复状态对比，只定义 To-Be 实现规则。

#### 5.2.1 新建、保存草稿与发布

![新建、保存草稿与发布](diagrams/lead93-scenario-create-publish.svg)

本场景的生命周期没有 As-Is/To-Be 状态差异，因此图中只保留一条共同状态机，并单独对比状态流转外围的数据和校验变化。共同状态机明确区分 Active、Expired、Schedule 三类 Save Draft 分支；To-Be 的核心增量是把版本级 Metadata 与现有分支一起保存，并在 Publish 前增加 Metadata 完整性校验。

业务流转边界、`email_code` 后端生成和 Insert/Update 结果矩阵已确认。现状无独立 Cancel Schedule API，Scheduler 只需在上线前做回归验证。

#### 5.2.2 编辑 Published、Working Copy、Discard 与重新发布

![编辑 Published 与 Working Copy](diagrams/lead93-scenario-edit-published.svg)

本场景继续使用第 3.4 节的 Active/Draft/Schedule/Expired 状态结果：Active 与 Draft Working Copy 可共存，Discard 不影响 Active，Publish 才切换新旧版本。To-Be 差异仅包括 Working Copy 同步承载版本级 Metadata、Publish/Discard 对新增关系数据的一致处理，以及由 Active + Draft 组合派生 “Draft in Progress” 提示；不新增生命周期状态。

Active/Draft 隔离、Discard 和发布结果已确认；Discard 不清理附件，Publish 继续复用现有 Version Conflict 响应。Copy and Create 是否使用相同冲突规则取决于 `COPY-01`。

#### 5.2.3 Deactivate 与 Delete

![Deactivate 与 Delete](diagrams/lead93-scenario-deactivate-delete.svg)

本场景的 As-Is 基线直接复用第 3.4 节 Template 可用性与软删除泳道。Deactivate/Active 的 To-Be 保持现有数据库语义：只切换 `config.email_status`，不修改任何 version row 的 `version_status`；页面状态由 config 与 version 组合派生。唯一的数据范围差异是 Delete 需要同步软删除新增的 Subcategory/Tag relations；主 Category 位于 version row，随 version 软删除，但不得删除 Category taxonomy 节点。

#### 5.2.4 Category、Subcategory 与 Tag 元数据修改

![Metadata 修改](diagrams/lead93-scenario-metadata.svg)

As-Is 只确认 Template Master 与 Version 的字段归属，现有系统没有已确认的 Template Category/Subcategory/Tag 版本关系，因此不构造现状 Metadata 状态机。To-Be 新增 Metadata 按 `email_code + version` 保存：页面只展示当前 Active metadata；首次创建 Working Copy 时从 Active 复制到 Draft，之后两者独立维护；Draft/Schedule Metadata 在对应版本生效前不影响 Active。

#### 5.2.5 页面状态派生

![页面状态派生](diagrams/lead93-scenario-derived-ui-state.svg)

As-Is 查询部分直接复用第 3.5 节：Published Tab 使用已确认的 Active 硬编码条件，Draft Tab 保留 Disabled、Draft、Schedule 三类语义和三个 OR 分支。To-Be 只在现有 Tab base query 上叠加 `is_campaign`、Category/Subcategory、Tag 和 Keyword 条件，并由 Active + Draft 组合显示 “Draft in Progress”；不得把 Draft Tab 简化为 `version_status = 3`，也不得新增独立数据库状态。

#### 5.2.6 Category/Subcategory 生命周期

![Category 生命周期](diagrams/lead93-scenario-category-lifecycle.svg)

As-Is Template Management 没有两级 taxonomy、版本关系或删除迁移流程，因此本场景不存在可复用的 As-Is 状态机。图中 To-Be 流程整体属于新增能力，使用专用表 `iic_msg_email_category`，重点展示一次最多 5 条 Subcategory 的原子创建，以及删除前自动迁移 Active/Draft/Schedule Metadata、再级联软删除节点；Expired 历史版本保持不变。

两级结构、有效条件、全局名称唯一、软删除后同名重建、批量创建和 Reassign-and-Delete 规则均已确认。

### 5.3 Jira Story 与 To-Be Solution 可追溯关系

本节作为 Gap Analysis 与 To-Be Design 之间的导航层，差异来源以当前第 5 章、PRD v1.1 和对应 Jira Story 为准。矩阵中的实心圆表示该 Story 的主要解决方案，空心圆表示复用、依赖或间接影响；空白表示没有直接改造。矩阵只用于快速定位，下面的明细表是开发和评审使用的正式追踪入口。

![Jira Story 与 Solution 覆盖矩阵](diagrams/lead93-story-solution-traceability.svg)

| Jira Story | 解决方案摘要 | As-Is / Gap 来源 | To-Be 设计位置 | 主要实施产物 | 当前状态 |
|---|---|---|---|---|---|
| [LEAD-277](https://oldmutualig.atlassian.net/browse/LEAD-277) Template Data Model & Validation | 保留 Master/Version；增加版本主 Category、Subcategory/Tag relations 和统一 Publish Validation | 3.1、3.3、5.1 | 7.1-7.6、8.3、11 | [Version DDL](sql/DDL_iic_msg_email_config_version.sql)、[Mandatory Tag QUERY](sql/QUERY_iic_msg_tag_group.sql)、[API Contract](LEAD-93_API_Contract_Clarification_CN.md) | DTO 与新增错误键已冻结；统一字段错误 HTTP 映射仍待 `API-02` |
| [LEAD-293](https://oldmutualig.atlassian.net/browse/LEAD-293) Create Category/Subcategories | 新增专用 Category 表构建两级树；全局重名；后端生成 `category_code`；支持一次最多 5 条 Subcategory 原子批量创建 | 3.1、5.2.6 | 7.2、9.2.1、11 | [Category DDL](sql/DDL_iic_msg_email_category.sql)、[Runtime CRUD DML](sql/DML_iic_msg_email_category_runtime.sql)、[Taxonomy 图](diagrams/lead93-tobe-taxonomy-management.svg) | 业务规则和 Endpoint Contract 已冻结 |
| [LEAD-306](https://oldmutualig.atlassian.net/browse/LEAD-306) Create New Template | 首次 Save Draft 后端生成 `email_code` 并 Insert V1；Draft 允许不完整；Publish 执行严格校验 | 3.2、3.6、5.2.1 | 8.1-8.3、11 | [Write Pipeline 图](diagrams/lead93-tobe-write-command-pipeline.svg)、[Version Runtime DML](sql/DML_iic_msg_email_config_version_runtime.sql) | 核心规则已确认；Campaign 管理入口 `BUSINESS-OPEN` |
| [LEAD-307](https://oldmutualig.atlassian.net/browse/LEAD-307) Delete Category/Subcategory | 后端原子迁移 Active/Draft/Schedule Metadata 后级联软删除；Expired 不迁移；记录删除人和时间 | 5.2.6 | 7.2、8.4、9.2.1、11 | [Category Delete 图](diagrams/lead93-tobe-category-delete-design.svg)、[Delete DML](sql/DML_iic_msg_email_category_delete.sql)、[Reference QUERY](sql/QUERY_iic_msg_email_category.sql) | 业务、Endpoint 和新增错误键已冻结 |
| [LEAD-301](https://oldmutualig.atlassian.net/browse/LEAD-301) Assign & Edit Category | Category/Subcategory 按 version 保存；Active metadata-only 修改立即生效；Draft 修改保持隔离 | 5.2.4 | 9.1、9.2.1、11 | [Metadata 图](diagrams/lead93-tobe-template-reassignment.svg)、[API Contract](LEAD-93_API_Contract_Clarification_CN.md)、[Category Relation DML](sql/DML_iic_msg_template_category_rel_runtime.sql) | 业务规则和 Contract 已冻结 |
| [LEAD-276](https://oldmutualig.atlassian.net/browse/LEAD-276) Template Reassignment | Reassignment 复用 Metadata Update；显式指定 version；Category/Subcategory/Tag 全量快照替换 | 5.2.4 | 9.1、11 | [Reassignment 图](diagrams/lead93-tobe-template-reassignment.svg)、[API Contract](LEAD-93_API_Contract_Clarification_CN.md)、[Tag Relation DML](sql/DML_iic_msg_template_tag_rel_runtime.sql) | 目标行为和 Contract 已冻结 |
| [LEAD-278](https://oldmutualig.atlassian.net/browse/LEAD-278) Edit Published Template | 保留 Active/Draft 隔离、Discard Version Delete 和现有 Version Conflict；Copy and Create 的目标对象与复制范围单独待确认 | 3.6、5.2.2 | 6.2、8.1-8.4、11 | [Published Edit 场景图](diagrams/lead93-scenario-edit-published.svg)、[Command Pipeline](diagrams/lead93-tobe-write-command-pipeline.svg)、[Version Runtime DML](sql/DML_iic_msg_email_config_version_runtime.sql) | Working Copy 行为已确认；Copy and Create 见 `COPY-01` |
| [LEAD-300](https://oldmutualig.atlassian.net/browse/LEAD-300) Select/Assign/Edit Tags | 固定 Tag Taxonomy；每组多选；按 version 保存 relation；Mandatory Group 发布校验 | 5.2.4 | 7.5、8.3、9.1、9.2.2、10、11 | [Tag 管理图](diagrams/lead93-tobe-tag-taxonomy-management.svg)、[Tag Relation DDL](sql/DDL_iic_msg_template_tag_rel.sql)、[Tag DML](sql/DML_iic_msg_template_tag_rel_runtime.sql)、[Tag QUERY](sql/QUERY_iic_msg_template_tag_rel.sql) | 业务规则已确认；完整 Seed DML 待开发补齐 |
| [LEAD-279](https://oldmutualig.atlassian.net/browse/LEAD-279) Draft & Publish Workflow | 保持现有 Insert/Update 和状态机；Publish Now/Future 统一校验并原子切换；失败保留旧 Active | 3.4、3.6、5.2.1-5.2.2 | 8.1-8.4、11 | [As-Is State Flow](diagrams/lead93-as-is-state-flow.svg)、[Command Pipeline](diagrams/lead93-tobe-write-command-pipeline.svg)、[Version Runtime DML](sql/DML_iic_msg_email_config_version_runtime.sql) | 状态结果已确认；真实事务入口 `CODE-VERIFY` |
| [LEAD-296](https://oldmutualig.atlassian.net/browse/LEAD-296) Delete Template | 复用 Template Delete 级联软删除；扩展删除 Subcategory/Tag relations；不重写 `version_status` | 3.6、5.2.3 | 6.2、8.2、8.4、11 | [Delete 场景图](diagrams/lead93-scenario-deactivate-delete.svg)、[Category Relation DML](sql/DML_iic_msg_template_category_rel_runtime.sql)、[Tag Relation DML](sql/DML_iic_msg_template_tag_rel_runtime.sql) | 业务规则已确认；真实事务入口 `CODE-VERIFY` |
| [LEAD-326](https://oldmutualig.atlassian.net/browse/LEAD-326) Template Preview | 完全复用现有 Preview；展示当前临时正文和 Metadata；不持久化、不预览附件 | 5.1 | 6.2、8.3、10.1、11 | [API Contract](LEAD-93_API_Contract_Clarification_CN.md)；复用现有 Preview API/Renderer，无新增 SQL | 复用边界已确认；本期不改 Preview |
| [LEAD-327](https://oldmutualig.atlassian.net/browse/LEAD-327) Search & Filter | 先确定 Tab 的 `email_code + result_version`，再应用 Metadata Filter；同组 OR、跨组 AND | 3.5、5.2.5 | 10、11 | [Search Pipeline 图](diagrams/lead93-search-filter-query-pipeline.svg)、[Template QUERY SQL](sql/QUERY_iic_msg_email_config.sql)、[API Contract](LEAD-93_API_Contract_Clarification_CN.md) | 查询语义已确认；真实 Mapper 合并 `CODE-VERIFY` |
| [LEAD-328](https://oldmutualig.atlassian.net/browse/LEAD-328) Data Migration | Staging、Snapshot、Migration Log、Seed、版本级 Mapping、Validation 和受控回滚 | 5.1 | 12.1-12.9 | [SQL Index](sql/README.md)、[Staging DML](sql/DML_lead93_staging.sql)、[Snapshot DML](sql/DML_iic_msg_template_migration_snapshot.sql)、[Migration Log DML](sql/DML_iic_msg_template_migration_log.sql) | 脚本框架已确定；最终业务 Mapping 和目标版本范围 `BUSINESS-OPEN` |

追踪原则：Story 只作为需求来源和导航，不复制其 AC 到每个技术章节；同一技术规则只在一个 To-Be 章节定义，其他 Story 通过本表引用。实现期间如 Story AC、PRD 或 API Contract 发生变化，必须同步更新对应行的设计位置、实施产物和状态。

## 6. To-Be 总体方案

### 6.1 目标架构

![LEAD-93 To-Be 总体方案](diagrams/lead93-to-be-solution.svg)

目标方案分为三层：

- UI/API 层增加 Category、Tag、Metadata 和 Search 能力。
- Template Lifecycle Service 继续负责 Save Draft、Publish、Deactivate 和 Delete。
- 数据层复用 Template Master、Version 和 File 表；Version 增加 `category_id`，同时新增专用 Category、relation 和 Tag 表。

API 采用双版本兼容策略：现有 v1 作为 Web/Mobile App 共享的不可破坏基线；10 个增强接口和 9 个新增接口统一使用 v2。`EX-06/07/12/14/15` 五个完全不变的能力继续复用 v1，不在 v2 重复实现。v1/v2 共享底层 Template/Version 数据，因此通过 v2 Publish、通过复用 v1 Deactivate 以及正式数据迁移产生的业务数据变化仍会被 v1 客户端看到。

| API 层 | 范围 | 处理 |
|---|---|---|
| v1 | 现有 App/Web 及 5 个不变接口 | 请求、响应和必填规则保持现状；详见 [v1 As-Is 基线](LEAD-93_API_V1_AsIs_CN.md) |
| v2 增强 | `EX-01`—`EX-05`、`EX-08`—`EX-11`、`EX-13` | 复用现有 Service 行为，增加 Metadata、Filter 和校验 |
| v2 新增 | `NEW-01`—`NEW-09` | Category、Tag、Metadata 新能力 |

图中的 Service/API 方框表示逻辑能力边界，不要求新增同名 Java Service、Controller 或独立部署模块；实现应优先复用现有模块。

后续章节按一种固定阅读路径组织，每类决策只在一个章节定义：

| 关注点 | 唯一设计位置 |
|---|---|
| 数据存在哪里、表之间如何关联 | 第 7 章 数据模型与归属 |
| Save Draft、Publish、Delete 如何写入 | 第 8 章 Template 写模型与生命周期 |
| Category、Tag、Assignment 如何管理 | 第 9 章 Taxonomy 与 Metadata |
| List、Detail、Preview、Search 如何选 version 和返回 Metadata | 第 10 章 Template 读模型 |
| 哪些 API、Controller、Service、Mapper 需要修改 | 第 11 章 实施影响 |
| SQL 如何组织、迁移和回退 | 第 12 章 Migration 与 SQL 执行 |

### 6.2 现有能力与改造边界

**Jira Coverage：** LEAD-278、LEAD-296、LEAD-326

| 能力 | 本期处理 | 明确边界 |
|---|---|---|
| Schedule Scheduler | Unchanged | 不修改 `changeVersionStatusByEffectiveFrom()`；只验证到点后的既有状态结果 |
| Preview | Unchanged | 复用现有 API/Renderer/DTO；只展示正文和 Metadata，不持久化、不预览附件 |
| Attachment Upload/S3 | Reused | Email/Campaign 附件均可选；10 MB 和格式规则由前端校验，后端继续保存 `file_keys` |
| Active/Deactivate | Reused | 只切换 `config.email_status`，不改 version、不重新 Publish |
| Version Delete | Reused/Changed | 复用现有 API，并在同一事务扩展软删除目标 version 的新增 relations |
| Template Delete | Reused/Changed | 复用现有级联软删除，并扩展全部新增 relations |
| Existing Version Control | Reused | 保留现有 Version Conflict 检测；不新增 Redis lock、锁字段或独立 revision token |

附件继续按 version 隔离：Working Copy 新附件不修改旧 Active `file_keys`；Publish 成功后沿用现有保留策略；Discard/Delete 不删除 S3 对象或 `iic_msg_file_upload` row，也不新增延迟清理和 orphan 状态。


### 6.3 组件与职责边界

第 5 章已经按业务场景说明 As-Is 与 To-Be 差异。本节只定义逻辑组件及职责归属；具体写、管理和读规则分别在第 8-10 章定义。

![To-Be 应用组件与职责边界](diagrams/lead93-tobe-application-components.svg)

图中的组件名称表示逻辑职责，不要求必须新增同名代码类。正式接口地址、请求响应字段和错误语义以[接口约定](LEAD-93_API_Contract_Clarification_CN.md)为准。

| 逻辑组件 | 类型 | To-Be 职责 |
|---|---|---|
| Content Manager UI | Changed | Category 管理、Tag Group 多选、Metadata 编辑、Search/Filter、Working Copy 操作 |
| Adviser View | Changed | 只读取 Enabled + Active Published Template，并展示当前 Active Metadata |
| Template API / Controller | Changed | 保留现有 Template 命令入口，接入统一校验、目标 version 定位和新增 Metadata 字段 |
| Metadata API | New | 对明确的 `email_code + version` 执行 Category/Subcategory/Tag 全量快照更新 |
| Taxonomy API | New | Category CRUD/Reorder/Delete；Tag Group/Value 只读查询 |
| Template Command Orchestrator | Changed | 编排 Save Draft、Publish、Version Delete、Template Delete、Active/Deactivate |
| Version Selector | Changed | 依据已确认矩阵定位或创建目标 V(N)，不由前端猜测 version |
| Metadata Service | New | 校验并写入 `category_id`、Subcategory relations 和多选 Tag relations |
| Taxonomy Service | New | Category 两级规则、原子批量创建、排序、Reassign-and-Delete，以及 Tag Group/Value 有效性校验 |
| Validator | Changed | 区分 Draft、Active Metadata Update 和 Publish 的完整性规则 |
| Repository / Mapper | Changed/New | 复用 config/version Mapper，新增 Category/Tag 字典及 relation Mapper |
| Scheduler / Preview / Attachment | Reused | Scheduler、Preview Renderer 和附件后端机制保持现状，仅接入已保存的 To-Be 数据 |


## 7. 数据模型与归属

本章按已确认方案设计：新增 Template 专用 Category 表 `iic_msg_email_category`。该表只承载 Email/Campaign Template taxonomy，不复用或改造其他业务模块的 Category 表。

### 7.1 数据库设计全景

**Jira Coverage：** LEAD-277、LEAD-293、LEAD-307、LEAD-300、LEAD-328

本节先用三种视角建立数据库设计直觉，再进入逐表字段和约束：

1. **改造范围全景图**回答哪些表复用、修改或新增。
2. **逻辑 ER 图**回答表之间通过哪些业务键关联，以及业务基数是什么。
3. **版本级 Metadata 实例图**回答 Active 与 Draft/Schedule 如何隔离，以及 Draft 如何从 Active 初始化 Metadata。

#### 7.1.1 数据库改造范围

![LEAD-93 数据库改造范围全景](diagrams/lead93-db-change-landscape.svg)

颜色只表示数据库改造类型，不表示 Template 生命周期状态：灰色为 Existing/Reused，黄色为 Existing/Changed，蓝色为 New，紫色为 Migration Support。核心改造路径是 `Template Master → Template Version → Version-Aligned Metadata`；`iic_msg_file_upload` 继续沿用现有附件引用方式，Migration Snapshot/Log 均不参与运行时查询。

#### 7.1.2 To-Be 逻辑 ER 图

![LEAD-93 To-Be 逻辑 ER 图](diagrams/lead93-db-logical-erd.svg)

ER 图中的 `1:N`、`N:1` 表示业务基数，不表示数据库已经存在物理 FK。本方案明确不新增 FK/check constraint，图中虚线关系由 Service 层校验，并由业务事务保证一致性：

- `iic_msg_email_config.email_code` 与多个 version row 建立逻辑一对多关系。
- `version.category_id` 指向主 Category；`iic_msg_template_category_rel` 保存同一 version 的多个 Subcategory。
- `iic_msg_template_tag_rel` 按 version 保存每个 Tag Group 的多选结果，`group_code` 和 `tag_code` 分别关联固定字典。
- `version.file_keys` 仍是逗号分隔的现有附件引用，不在本期重构为标准关系表。
- Migration Snapshot 保存 Seed/Mapping 修改前数据，Migration Log 保存一次性执行结果；二者都不是运行时 Template ER 模型，因此不出现在逻辑 ER 图中。

#### 7.1.3 版本级 Metadata 数据实例

![LEAD-93 版本级 Metadata 数据实例](diagrams/lead93-db-versioned-metadata-example.svg)

同一 `email_code` 下，Active V1 与 Draft/Schedule V2 分别通过自己的 `email_code + version` 保存 Category、Subcategory 和 Tag。创建 Draft V2 时从当前 Active V1 复制 Metadata，后续独立编辑；Publish 不再次复制 Metadata，而是切换目标 version row 的 `version_status`，其既有关联自然成为新的当前 Metadata。Expired version 数据保留，但产品/API 不提供其 Metadata 查看。

主 Category 直接保存在 version row；Active、Draft 和 Schedule 分别读取各自 version 的 `category_id`，Draft 初始化、状态切换、Discard 和 Delete 均遵循 version row 的既有边界。

#### 7.1.4 表变更总览

| 表 | 类型 | 用途 | 业务键/关联键 |
|---|---|---|---|
| `iic_msg_email_config` | Existing / Reused | Template Master | `email_code` |
| `iic_msg_email_config_version` | Existing / Changed | Template Version / Content / 主 Category | `email_code`, `version` |
| `iic_msg_file_upload` | Existing / Reused | S3 附件元数据 | `file_key` |
| `iic_msg_email_category` | New | Category/Subcategory taxonomy | `id`, `category_code` |
| `iic_msg_template_category_rel` | New | Template Version 与 Subcategory 多选关系 | `email_code`, `version`, `subcategory_id` |
| `iic_msg_tag_group` | New | Tag 分组字典 | `group_code` unique |
| `iic_msg_tag_value` | New | Tag 值字典 | `group_code`, `tag_code` |
| `iic_msg_template_tag_rel` | New | Template Version 与 Tag Value 的多选关系 | `email_code`, `version`, `group_code`, `tag_code` unique |

### 7.2 新增 `iic_msg_email_category`

该表是 Template Management 专用的两级 Category/Subcategory 字典。字段类型和索引仍需 DBA Review：

| 字段 | 用途 |
|---|---|
| `id` | 自增物理主键；version/relation 使用该 ID 关联 |
| `tenant_id`, `dae_country_code` | Template 数据范围 |
| `category_code` | 后端生成的全局唯一 Snowflake 业务编码 |
| `category_name` | Category/Subcategory 显示名称 |
| `parent_id` | Subcategory 所属 Category；一级节点为 `NULL` |
| `category_level` | `1 = Category`, `2 = Subcategory` |
| `normalized_name` | 大小写、空格归一化后的名称，用于重复校验 |
| `description` | 描述 |
| `sort_order` | 同级排序 |
| `is_deleted` | `0 = 有效`, `1 = 已软删除` |
| `created_by`, `created_date`, `updated_by`, `updated_date` | 创建与修改信息 |
| `deleted_by`, `deleted_date` | [LEAD-307](https://oldmutualig.atlassian.net/browse/LEAD-307) 明确要求的删除人和删除时间 |
| `active_normalized_name` | 生成列；仅有效节点产生值，用于有效名称全局唯一约束 |

所有 row 都属于 Template taxonomy，`category_level` 必须为 `1/2`；Service 层校验该枚举和父子层级。数据库不新增 FK 或 CHECK constraint。

创建 Category/Subcategory 时，后端生成全局唯一 Snowflake `category_code` 并写入数据库。该字段不由前端传入、编辑或展示；前端操作节点使用数据库 `id`。
首次上线 seed 使用预先生成并经审批的固定 `category_code`；上线后的运行时 Create 使用后端 Snowflake，两者都满足同一唯一约束。

Service 层必须校验：

- 只允许两级结构。
- Subcategory 的 parent 必须为有效一级 Category。
- 有效 Category/Subcategory 名称在全部 `category_level=1/2` 节点中全局唯一，大小写和首尾空格归一化后比较。
- 删除一级 Category 前检查该 Category 及全部有效 Subcategory 是否存在模板关系；无引用时在同一事务级联软删除子节点。
- 软删除节点不参与名称唯一校验，允许创建同名新节点；原 row 保留 ID、Name、删除人和删除时间，以满足 LEAD-307 Data Retention。

对应 SQL：[DDL_iic_msg_email_category.sql](sql/DDL_iic_msg_email_category.sql)。

### 7.3 `iic_msg_email_config_version` 扩展

在现有 version 表增加 `category_id` 保存主 Category，使其与对应 Template Version 保持相同生命周期。

| 字段 | 约束/说明 |
|---|---|
| `category_id` | 主 Category ID；Draft 可为空，Publish 校验必填 |

这样设计的原因：

- Active、Draft、Schedule、Expired 通过既有 version row 天然隔离 Category。
- Publish 只切换 `version_status`，目标 version 的 `category_id` 自动成为当前值，无需复制 metadata。
- 创建 Draft 时可直接从当前 Active version 的 `category_id` 初始化主 Category。
- Discard/Delete 软删除 version 后，不会遗留独立 metadata row 或双重软删除状态。
- Search/Filter 本来就需要选中结果 version，可直接读取 `category_id`，减少一次 JOIN。

Published metadata-only 修改会更新 Active version 的 `category_id` 和 `updated_date`；是否影响现有列表排序以真实 Mapper 规则为准。

对应 SQL：[DDL_iic_msg_email_config_version.sql](sql/DDL_iic_msg_email_config_version.sql)。

### 7.4 `iic_msg_template_category_rel`

用于一个 Template Version 关联多个 Subcategory。唯一性由 `email_code + version + subcategory_id` 保证。

在无 FK 情况下，写入前由 Service 校验 `email_code`、Category 层级和节点有效性。

对应 SQL：[DDL_iic_msg_template_category_rel.sql](sql/DDL_iic_msg_template_category_rel.sql)。

### 7.5 Tag Taxonomy

| 分组 | 必填性 | Draft 默认值 |
|---|---|---|
| Content Type | Mandatory | Unclassified |
| Trigger | Mandatory | Unclassified |
| Lifecycle Stage | Mandatory | Unclassified |
| Financial Need | Mandatory | Unclassified |
| Proposition | Optional | 无 |
| Source | Optional | 无 |

设计规则：

- `iic_msg_tag_group` 保存分组、必填标记和排序。
- `iic_msg_tag_value` 保存固定 Tag 值；`tag_code` 全局唯一。
- `iic_msg_template_tag_rel` 按 `email_code + version` 保存选择结果，同一 Tag Group 可关联多个 Tag Value。
- 同一 Template Version、Tag Group 和 Tag Value 不得重复；唯一性由 `email_code + version + group_code + tag_code` 保证。
- 不提供 Tag 管理 UI。
- 首次上线固定 seed，后续仅允许 DB 脚本维护。
- Publish 前校验 4 个 Mandatory Group 均存在有效选择；Draft 缺失时补 `Unclassified`。

版本化 SQL 已同步：主 Category 直接更新目标 version 的 `category_id`，Subcategory relation 和 Tag relation 使用 `email_code + version`。Migration staging 必须显式提供目标 `version`，脚本不会猜测并复制一套 metadata 到所有历史版本。具体 mapping 数据仍待 `BUS-01`。

对应 SQL：[DDL_iic_msg_tag_group.sql](sql/DDL_iic_msg_tag_group.sql)、[DDL_iic_msg_tag_value.sql](sql/DDL_iic_msg_tag_value.sql)、[DDL_iic_msg_template_tag_rel.sql](sql/DDL_iic_msg_template_tag_rel.sql) 及相应 DML 文件。

### 7.6 数据库约束策略

DBA 不允许新增 FK 和 check constraint，因此采用：

- DB：主键、普通索引、必要的唯一索引和软删除字段。
- Service：父子层级、枚举值、关系存在性、必填组、重复关系校验。
- Transaction：version 的 `category_id`、category relation 和 tag relation 的保存必须原子提交。
- Migration Validation：上线脚本后检查孤儿关系、重复关系、缺失 Mandatory Tag 和无效 Category。


## 8. Template 写模型与生命周期


### 8.1 Save Draft 目标版本定位与写入规则

**Jira Coverage：** LEAD-306、LEAD-278、LEAD-279

本节对应第 3.6 节 As-Is Save Draft 数据库行为，并由第 5.2.1 节说明需求差异。To-Be 保持现有目标版本选择、Insert/Update 和状态变化规则，仅在同一目标 version 上增加版本级 Metadata 写入。Master、Version 和 Metadata relation 的字段归属遵循第 7.1 节数据库设计。

新模板首次 Save Draft 时由后端生成全局唯一 Snowflake `email_code`；前端不得生成。点击 Published Edit 不立即插入 Draft，只有首次 Save Draft 才持久化 Working Copy。

| As-Is 持久化现状 | As-Is Version 写入 | As-Is 状态结果 | To-Be 新增 Metadata 写入 |
|---|---|---|---|
| 尚无 version | Insert V1 | V1 Draft (`3`) | 按 `email_code + V1` 保存请求快照 |
| Draft 已存在，包括 Active + Draft | Update 当前 Draft | 保持 Draft (`3`) | 更新当前 Draft 快照，不再从 Active 覆盖 |
| Active、无 Draft | Insert V(N+1) | 新 Draft (`3`)，Active 保持 (`1`) | 首次从 Active 复制 Metadata，再应用请求修改 |
| 仅 Expired、无 Draft | Update 最大数字版本 V(N) | 同一 version `2 → 3` | 保留有效 Metadata 并应用请求修改 |
| Schedule 存在 | Update Scheduled V(N) | 同一 version `0 → 3` | 保留时间和有效 Metadata 并应用请求修改 |

Expired/Schedule 复用 V(N) 时保留原 `effective_from/effective_until`；即使 `effective_from > now`，Save Draft 也不会自动生成 Schedule。Schedule 期间不得再创建并存 Draft。

### 8.2 生命周期命令与统一写入管线

**Jira Coverage：** LEAD-306、LEAD-278、LEAD-279、LEAD-296

所有 Template 写命令都遵循同一处理管线：识别命令、读取最新持久化状态、定位目标 version、执行命令级校验、在事务中写入 Master/Version/Relations，最后提交或整体回滚。

![To-Be 统一写命令管线](diagrams/lead93-tobe-write-command-pipeline.svg)

| 命令 | 前置条件/目标 | Version 状态写入 | Master/Relations 写入 | 结果与边界 |
|---|---|---|---|---|
| Save Draft | 按 8.1 矩阵定位目标 version | 结果为 Draft (`3`) | 更新 Master、Version 和目标 version Metadata | Future time 只保存，不生成 Schedule |
| Publish Now | 目标为有效 Draft | 旧 Active `1 → 2`；目标 Draft `3 → 1` | 不复制 Metadata | `effective_from <= now`；校验和状态切换原子完成 |
| Publish Future | 目标为有效 Draft | 目标 Draft `3 → 0` | 不复制 Metadata | `effective_from > now`；旧 Active 到点前保持 |
| Schedule → Save Draft | 目标为 Scheduled V(N) | `0 → 3` | 更新同一 version Metadata | 保留 `effective_from/effective_until` |
| Version Delete | 明确目标 Draft/Schedule version | 不修改 `version_status`；version `status → -1` | 同步软删除该 version 的 Subcategory/Tag relations | Published Working Copy Discard 和 Scheduled Delete 复用此命令 |
| Deactivate | 逻辑 Template 存在 | 不修改 version row | `config.email_status: 1 → 0` | Active version 保留，仅从可见范围排除 |
| Active/Reactivate | Disabled Template 存在 | 不修改 version row | `config.email_status: 0 → 1` | 不重新执行 Publish Validation |
| Template Delete | 明确逻辑 Template | 不修改 `version_status`；config/version `status → -1` | 同步软删除全部新增 relations | 沿用级联软删除语义 |

Publish 只有在命令执行时才根据 `effective_from` 决定立即 Active 或 Schedule。目标 Draft/Schedule 的 Metadata 已按 `email_code + version` 保存，Publish 不再次复制 Category/Subcategory/Tag。

`changeVersionStatusByEffectiveFrom()` 继续负责 Scheduled version 到点生效，本期不修改其调度逻辑。上线前仅通过现有测试、日志或黑盒用例验证状态结果；回归失败时再依据真实代码差异评审改造范围。

#### 8.2.1 Discard 与 Working Copy

Discard 是前端业务动作，不新增 `/discard` API：

| UI 情况 | 后端处理 | 保留内容 |
|---|---|---|
| 编辑页面尚未 Save Draft | 只丢弃客户端内容，不调用后端 | 全部持久化数据 |
| Published + 已持久化 Working Copy | 复用 Version Delete 软删除 Draft version 及其 relations | Active version、主表字段和附件对象 |
| 新建且从未 Published 的 Draft | 页面不提供 Discard；删除时复用 Template Delete | 不增加专用处理 |
| Schedule | 使用 Save Draft `0 → 3` 或 Version Delete | 旧 Active 保持 |

`email_name`、`description`、`is_campaign` 是主表字段，Discard Working Copy 不回滚这些已经独立持久化的修改。

Copy and Create 不在本节推导：当前方向是复制选中版本的基本信息和版本内容并创建新的 Template；若最终确认需要后端承载，则新增 v2 API。源版本范围、目标 `email_code`、复制字段、附件策略、持久化时点和 Endpoint/DTO 均由 `COPY-01` 统一确认。


### 8.3 统一校验设计

**Jira Coverage：** LEAD-277、LEAD-306、LEAD-300、LEAD-279、LEAD-326

Validator 按命令类型执行不同完整性规则，不能把 Publish 的严格校验提前应用到 Save Draft，也不能允许 Active Metadata Update 破坏当前 Published 完整性。

历史 Active Template 不享受兼容豁免：Active Metadata Update 和重新 Publish 都必须读取请求以外的已持久化主表/版本字段并执行完整 Published Validation。缺少 PRD v1.1 新必填 Metadata 的历史数据必须补齐后才能完成更新或重新发布。

| 校验项 | Save Draft | Active Metadata Update | Publish Now/Future |
|---|---|---|---|
| Template Title (`config.email_name`) | 必填 | 不在 Metadata 请求中修改 | 必填 |
| Description (`config.description`) | 可空 | 不在 Metadata 请求中修改 | 必填 |
| Format (`config.is_campaign`) | 按现有创建/编辑逻辑保存 | 不在 Metadata 请求中修改 | 必填 |
| 主 Category | 可空 | 必须是有效一级 Category | 必须是有效一级 Category |
| Subcategory | 可空 | 至少一个且全部属于主 Category | 至少一个且全部属于主 Category |
| 4 个 Mandatory Tag Group | 缺失时写 `Unclassified` | 每组至少一个有效 Tag Value | 每组至少一个有效 Tag Value |
| Optional Tag Group | 可空；同组可多选 | 可空；同组可多选 | 可空；同组可多选 |
| Email Subject / 正文 | 可暂不完整 | 不在 Metadata 请求中修改 | 按 PRD 完整性校验 |
| `effective_from` | 可暂存但不改变状态 | 不涉及 | Publish 时决定 Now/Future |
| 附件 | 可选；前端校验 | 不涉及 | 可选；前端校验 |

公共校验顺序为：请求 Schema → 目标 Template/version 存在性 → 当前状态是否允许该命令 → Taxonomy 有效性和归属 → 命令级完整性。任何校验失败都必须在数据库写入前返回字段级错误；同组重复 `tag_code`、无效 Category/Tag、Subcategory 跨父节点或目标 version 不存在均不得产生部分更新。

Preview 不执行 Publish 状态更新，也不持久化请求内容。它复用现有 Renderer 展示正文和 Metadata；附件不进入 Preview。

### 8.4 事务、失败与并发边界

**Jira Coverage：** LEAD-307、LEAD-279、LEAD-296

| 命令 | 同一数据库事务内必须完成的写入 | 失败保证 |
|---|---|---|
| Save Draft | config 主表、目标 version、`category_id`、Subcategory/Tag relations | 不允许 version 与 Metadata 部分成功 |
| Metadata Update | 目标 `version.category_id`、Subcategory/Tag 全量替换 | Update 影响 0 行或任一 relation 失败时整体回滚 |
| Publish Now | 旧 Active 过期、目标 Draft 生效 | 旧 Active 必须保持在线直到事务成功提交 |
| Publish Future | 目标 Draft 转 Schedule | 校验或写入失败时仍保持 Draft |
| Version Delete | 目标 version 软删除及其新增 relations 软删除 | 目标不匹配或影响 0 行时返回失败 |
| Template Delete | config、全部 version 和新增 relations 软删除 | 任一写入失败时整体回滚 |
| Batch Subcategory Create | 校验 1-5 条输入并批量创建全部节点 | 任一名称/层级/Insert 失败时整批回滚，不返回部分成功 |
| Category Reassign-and-Delete | 锁定源/目标节点及受影响 version、迁移 Active/Draft/Schedule Metadata、软删除节点 | 任一 version 或 relation 更新失败时整体回滚；Expired 保持不变 |

附件对象上传和 S3 生命周期不属于上述数据库事务；只有附件上传成功后才保存 `file_keys`。Discard、Version Delete 和 Publish 成功后均不新增 S3 物理清理。

![To-Be Publish Failure、Retry 与并发边界](diagrams/lead93-tobe-publish-failure-retry.svg)

- Validation Failure 发生在业务写入前，返回字段级错误并保留 Draft/旧 Active。
- Transaction Failure 必须回滚全部数据库写入；Retry 重新读取最新持久化状态并重新执行 Validation，不能直接重放旧事务。
- 现有代码已经提供 Version Conflict 检测，本期复用其触发条件和错误语义；不新增乐观锁字段、revision token、编辑锁、Redis lock 或 `requestId`。
- Category Delete 与 Category/Metadata 写入使用数据库 row lock 和固定锁顺序保护 Taxonomy 引用，不代表新增 Template 编辑锁。
- 本期不新增 Publish、Metadata 或 Tag 维护审计事件；沿用现有日志和异常规范。Category/Subcategory 删除仅保留 PRD 明确要求的 `deleted_by/deleted_date`。



## 9. Taxonomy 与 Metadata

### 9.1 Metadata 版本化与 Template Assignment

**Jira Coverage：** LEAD-301、LEAD-276、LEAD-278、LEAD-300

Metadata Service 统一处理 Template Version 与 Category/Subcategory/Tag 的关联。单个 Template Reassignment 复用 Metadata Update API；Category/Subcategory 删除触发的批量迁移由独立 Reassign-and-Delete 命令处理，不能由前端循环调用单条 Metadata Update。

![To-Be Template Metadata 写入](diagrams/lead93-tobe-template-reassignment.svg)

| 操作 | 目标 version | Metadata 行为 | 对当前 Active 的影响 |
|---|---|---|---|
| Active 首次创建 Working Copy | 新 V(N+1) Draft | 复制 Active 的 `category_id`、Subcategory 和全部 Tag relations，再应用请求修改 | 无 |
| 更新已有 Draft | 当前 Draft | 只更新 Draft 快照，不再从 Active 覆盖 | 无 |
| Active metadata-only 修改 | 当前 Active | 更新 Active version 的 Category/Subcategory/Tag | 立即影响导航、Search/Filter 和 Adviser |
| Draft Publish | 目标 Draft | 不复制 Metadata，仅切换 version 状态 | Draft Metadata 自然成为当前值 |
| Working Copy Discard | 目标 Draft | 随 Version Delete 软删除该 version relations | Active Metadata 保持 |
| Template Delete | 全部 version | 同步软删除全部新增 relations | Template 不再可见 |

Metadata Update 使用 `PUT` 全量替换语义：

1. 请求必须显式携带 `email_code + version`、完整 `category_id`、`subcategory_ids[]` 和全部 Tag Group 快照；后端不得自动猜测目标 version。
2. 主 Category 单选，Subcategory 多选；切换主 Category 后，前端清空原 Subcategory，后端仍要拒绝不属于新 Category 的残留 ID。
3. 每个 Tag Group 使用 `tag_codes[]` 表达多选；同组 `tag_code` 不得重复，Tag 必须有效且属于所声明 Group。
4. `subcategory_ids=[]` 或某组 `tag_codes=[]` 表示清空对应关系；字段缺失不得解释为“保持原值”。
5. Draft 允许 Category/Subcategory 不完整；Mandatory Tag 缺失时写入该 Group 的 `Unclassified`。Active Metadata Update 必须满足 Published 完整性。
6. 同一事务更新 `version.category_id`，并全量替换目标 version 的 Subcategory/Tag relations；Update 影响 0 行或任一 relation 写入失败时整体回滚。
7. Metadata Update 不创建 version、不修改 `version_status`，也不新增审计事件。

API 使用分组 JSON 数组传输多选 Tag，数据库使用 `iic_msg_template_tag_rel` 逐项存储，从而支持 Tag Name Search、跨 Group AND、同 Group OR/ANY、唯一键和字典归属校验。

当 Active 与 Draft 共存时，Active metadata-only 修改不自动同步 Draft；后续 Publish 可以由 Draft 自己保存的 Metadata 覆盖当前 Active。各读取入口的 version 和 Metadata 选择规则见 10.1。

### 9.2 Category 与 Tag Taxonomy 管理

**Jira Coverage：** LEAD-293、LEAD-307、LEAD-300

Category 与 Tag 都属于 Template Taxonomy，但维护方式不同：Category/Subcategory 由 Content Manager 通过管理页面维护；Tag Group/Value 没有管理页面和写 API，只允许通过受控 DB 脚本维护，并通过只读 API 提供给 Template 编辑和筛选页面。

![To-Be Category 与 Tag Taxonomy 管理边界](diagrams/lead93-tobe-taxonomy-management.svg)

#### 9.2.1 Category/Subcategory 管理

Category 管理包括 Create、Edit/Rename、Reorder 和 Delete。所有操作只处理 `iic_msg_email_category` 中 `category_level IN (1, 2)` 的节点，并由 Content Manager 权限保护。

创建与编辑规则：

- 只允许两级结构；一级 Category 的 `parent_id` 为空，二级 Subcategory 必须指向有效一级 Category。
- Name 必填、纯文本、最长 100 字符；归一化后在整个 Template taxonomy 内全局唯一，不只在同一 parent 下唯一。
- `category_code` 由后端使用 Snowflake 生成，对前端不可见；前端使用节点 `id` 执行 Edit/Reorder/Delete。
- 单个 Category Create 继续使用单条接口；Subcategory 支持一次提交 1-5 条。后端先完成全部名称、层级和重复校验，再在同一事务批量 Insert；任一条失败时整批回滚，不返回部分成功。
- Created By/Created Date 使用 `iic_msg_email_category.created_by/created_date`，由后端写入并在管理列表/树响应中返回。
- 创建成功后立即出现在 Category Tree、模板编辑下拉框和筛选器中。
- Rename 只修改节点本身；Template 通过 ID 关联，因此无需批量更新模板关系，但导航、筛选和搜索应立即展示新名称。
- 本期不支持把既有 Subcategory 移动到另一个 Category；如需调整，先新建节点并迁移模板关系，再删除旧节点。

排序规则：

- Category 只能在一级节点之间排序；Subcategory 只能在同一 parent 下排序，不允许通过拖拽改变父节点。
- Reorder API 一次提交同级完整 ID 顺序，后端校验节点集合和 parent 一致后，在同一事务批量更新 `sort_order`。
- 本期不新增 revision token、乐观锁或 Redis lock。请求缺少节点、包含重复 ID、跨 parent 或批量 Update 影响行数与节点数不一致时整体失败并回滚。

删除采用“迁移后级联软删除”：后端先将受影响的 Active/Draft/Schedule Metadata 原子迁移到请求指定的有效目标 Category/Subcategory，再软删除目标节点；不修改任何 Template 的 `version_status`。Expired 历史版本保持原 Metadata，不参与迁移。

![To-Be Category/Subcategory Delete 实现设计](diagrams/lead93-tobe-category-delete-design.svg)

以下是 **To-Be Reassign-and-Delete 流程**。`SELECT ... FOR UPDATE`、受影响 version 锁定、批量关系更新和父子软删除必须位于同一事务；正式错误码和权限表达式在 API Contract 中冻结：

1. 页面先调用只读 Delete Impact API 获取 Active/Draft/Schedule 影响计数并展示确认/目标选择；该结果只用于提示。
2. 正式命令校验 Content Manager 权限，并按 `category_level IN (1, 2)` 加载源节点和请求指定的目标节点。
3. 在数据库事务中按固定顺序锁定源节点、Level 1 的全部未删除子节点及目标 Category/Subcategory；节点不存在、已软删除、层级错误或目标位于待删除子树时整体失败。
4. 重新查询并锁定所有引用待删除节点且 `version_status IN (0,1,3)` 的有效 Template Version，不依赖第 1 步的预览计数。
5. 对每个受影响 version 更新 Category/Subcategory 快照：Level 1 删除将主 Category 改为目标 Category，并将 Subcategory 替换为请求中的目标集合；Level 2 删除仅移除该 Subcategory 并加入同一父 Category 下的目标 Subcategory，其他有效同级 Subcategory 保留。
6. 校验每个受影响 version 的更新结果、目标层级和 relation 数量。任一 version 更新影响 0 行、目标失效或 relation 写入失败时整体回滚，节点保持有效。
7. Metadata 迁移全部成功后，Level 1 在同一事务软删除父节点和全部子节点；Level 2 只软删除目标节点，父 Category 保持不变。
8. 每个被删除节点记录 `deleted_by`、`deleted_date` 和更新时间；原 row 的 ID 和 Name 保留。该字段级删除留痕直接满足 LEAD-307，不新增运行时审计事件或审计表。
9. 事务提交后 Category Tree、Search/Filter 和编辑下拉框立即排除已删除节点；软删除节点不参与唯一校验，允许创建同名新节点。

版本范围与可见性规则：

- Active、Draft、Schedule version 属于当前或待生效业务数据，必须在删除事务中完成迁移；Disabled Template 只要 config/version 未软删除仍计入。
- Expired version 不迁移，原 `category_id` 和 relation 保留；本期产品/API 不展示其 Metadata。
- 已软删除 Template Version 不迁移。
- Reassign-and-Delete 只修改版本级 Category/Subcategory Metadata，不修改 Tag、Template 主表字段或任何 `version_status`。

并发控制：新增或修改 Template Category/Subcategory relation 时，也必须在同一事务中锁定目标 Category/Subcategory row 并确认 `is_deleted = 0`。Reassign-and-Delete 按“源节点及子节点 → 目标节点 → 受影响 version”固定顺序加数据库行锁，使删除与普通 Metadata 写入串行；不新增 Redis lock。

SQL 已同步到 [QUERY_iic_msg_email_category.sql](sql/QUERY_iic_msg_email_category.sql) 和 [DML_iic_msg_email_category_delete.sql](sql/DML_iic_msg_email_category_delete.sql)：受影响版本限定 `version_status IN (0,1,3)`，有效节点限定 `is_deleted=0 AND category_level IN (1,2)`，Expired version 保持不变。

#### 9.2.2 Tag Group/Value 管理

![To-Be Tag Group/Value 管理与多选关联](diagrams/lead93-tobe-tag-taxonomy-management.svg)

| 能力 | To-Be 设计 |
|---|---|
| Tag Group | 固定 6 个 Group：4 个 Mandatory、2 个 Optional |
| Tag Value | 只能从预定义字典选择；`tag_code` 全局唯一并归属一个有效 Group |
| Template Assignment | 每个 Group 可选择多个 Tag Value；关联按 `email_code + version + group_code + tag_code` 唯一 |
| 管理页面 | 本期不提供 Tag Group/Value 管理 UI |
| 运行时 API | 新增只读 Tag Taxonomy API，仅返回 `status = 0` 的有效 Group/Value |
| 首次初始化 | 上线时由 DBA 执行固定、幂等 Seed SQL |
| 后续维护 | 只能通过审核后的 DB 脚本新增、修改或停用，不提供运行时写 API |
| Mandatory 默认值 | 4 个 Mandatory Group 分别配置一个 `Unclassified` Tag Value |
| 删除策略 | 不物理删除字典 row；通过 `status` 停用并保留既有历史关系；Mandatory Group 及其 `Unclassified` 默认值不得停用 |

Tag Group/Value 维护脚本在停用前必须检查 Template Version 引用：

- Active、Draft、Schedule version 的有效 Tag relation 阻止停用对应 Tag Value；停用 Group 时检查该 Group 下全部 Value 的引用。
- 4 个 Mandatory Group 及其 `Unclassified` 默认 Tag 属于 Publish/Draft 基础约束，本期维护脚本必须拒绝停用。
- Expired version 引用不阻止停用，历史 relation 保留；本期产品/API 不展示 Expired Metadata。
- 已软删除 Template Version 或已软删除 relation 不计入有效引用。
- 停用失败不得修改字典或 Template relation；管理员必须先完成 Template Metadata 调整。
- 运行时新建或更新 relation 时，必须重新校验 Group/Value 均为有效状态以及二者归属关系，不能只依赖前端选项。

Tag 初始化、维护和校验 SQL 分别引用 [DML_iic_msg_tag_group.sql](sql/DML_iic_msg_tag_group.sql)、[DML_iic_msg_tag_value.sql](sql/DML_iic_msg_tag_value.sql)、[QUERY_iic_msg_tag_value.sql](sql/QUERY_iic_msg_tag_value.sql) 和 [QUERY_iic_msg_tag_group.sql](sql/QUERY_iic_msg_tag_group.sql)。


## 10. Template 读模型与 Search / Filter

### 10.1 Version 与 Metadata 选择

所有读取入口必须先确定 `email_code + result_version`，再从同一 version 读取主 Category、Subcategory 和 Tag，禁止从其他 version 拼接 Metadata。

| 读取入口 | result version | Metadata 规则 |
|---|---|---|
| Published Tab / Published Detail | 当前 Active (`version_status=1`) | 返回 Active version Metadata |
| Adviser View | Enabled Template 的当前 Active | 后端强制 Published-only，返回 Active version Metadata |
| Draft Tab / Working Copy Edit | 复用第 3.5 节现有 Draft/Schedule/Disabled 选版结果 | 返回该 `result_version` 的 Metadata |
| 普通 Template Detail | 当前 Active；编辑 Working Copy 时显式使用目标 Draft/Schedule version | 不在 Active 与 Working Copy 之间混用 Metadata |
| Preview | 当前页面正文和 Metadata 输入 | 仅渲染，不持久化；不包含附件 |
| Version History | 保持当前 Active 版本 Metadata 可见范围 | 历史字段和 Expired Metadata 扩展依赖登记册 `REQ-03/REQ-04`，未确认前不扩大返回范围 |

Published、Draft、Detail 和 Adviser 可以复用不同 Base Query，但必须遵守同一个“先选 version、后读 Metadata”规则。Search/Filter 在已选出的 `result_version` 上执行，不能反过来由 relation 表决定 version。

### 10.2 查询构造

**Jira Coverage：** LEAD-300、LEAD-327

![Search / Filter 两阶段查询管线](diagrams/lead93-search-filter-query-pipeline.svg)

该图定义查询阶段和组合语义。核心原则是先得到符合现有 Tab 语义的 `email_code + result_version`，再按该 version 应用 Metadata Filter。

查询分两步：

1. 先复用现有 Published 或 Draft Tab Base Query，确定符合 Tab 状态语义的 `email_code + result_version` 集合。
2. 从结果 version 读取 `category_id`，再按 `email_code + result_version` 关联 category relation 和 tag relation，叠加搜索条件。

最终按 Tab 的逻辑模板语义去重并分页。不能先对多张 relation 表直接 join 后再分页，否则 Subcategory/Tag 会导致重复行和分页数量失真。

### 10.3 Published 场景

保留现有 Published 的 config/version 状态条件，但不再硬编码 `is_campaign != 1`。新查询要求前端必须传入 `is_campaign`：`0 = Email`、`1 = Campaign`；缺失、`NULL` 或非法值返回参数校验错误，不执行无类型的全量查询。

Adviser View 必须强制 Published-only，不允许通过请求参数绕过。

### 10.4 Draft 场景

复用现有 Draft Tab 多分支条件，不将其简化为 `version_status = 3`。

### 10.5 推荐实现

- 主查询先产出 distinct `email_code` 或使用 `EXISTS` 过滤多值关系。
- Category、Subcategory、Tag relation 建立以 `email_code + version` 开头的索引。
- Keyword 仅部分匹配 PRD 定义的 Template Title (`iic_msg_email_config.email_name`)、Description (`iic_msg_email_config.description`) 和 Tag Name，不搜索 Email Subject 或 Category/Subcategory Name。
- 排序必须稳定；最终沿用现有 List/Count 排序并增加确定性的末级排序键，避免改变 Tab 的既有顺序。

### 10.6 Search / Filter SQL 文件

Search/Filter 的 SQL 设计模板位于 [QUERY_iic_msg_email_config.sql](sql/QUERY_iic_msg_email_config.sql)。该文件描述增量查询结构，开发时必须与现有 List/Count/排序和 Mapper 合并，不能直接替换现有查询。模板包括：

- Published Base Scope 与强制 Published-only 条件。
- Draft Tab 已确认的三个 OR 分支。
- `is_campaign` 类型条件、Category/Subcategory/Tag Filter，以及 Template Title/Description/Tag Name Keyword 组合过滤。
- 按 `email_code` 去重、稳定排序、分页和 Count。
- 使用 `FIELD()` 恢复详情 mapper 的分页顺序。
- 组内 ANY 的动态 SQL 模板。

其他表的查询与一致性校验文件统一见 12.8，本章不重复维护 SQL 清单。

参数由 MyBatis/JDBC 安全绑定，`IN` 列表必须展开为独立占位符。Category、Subcategory、Tag、Keyword 之间固定使用 AND；同一维度或同一 Tag Group 内多选固定使用 OR/ANY，即任一选中值匹配即可。

`LIKE %keyword%` 无法有效利用普通 B-Tree 索引。本期模板数量较小，接受数据库扫描；数据量显著增长时再评估全文索引或搜索引擎。

### 10.7 查询交互与边界场景

- Category 未选择时，Subcategory Filter 禁用或仅显示空集合；切换 Category 后自动清除不属于新 Category 的已选 Subcategory。
- 每个已选条件显示为可单独移除的筛选标签；Clear All 同时清除 Keyword 和全部 Filter，并恢复当前 Tab 默认查询。
- 无匹配结果时返回空列表和 `total = 0`，不是业务异常；前端显示统一空状态。
- Content Manager 保留 Published/Draft Tab 和 Status Filter 能力，但 Published Tab 不展示/不允许 Status Filter。后端不得因额外参数改变 Published-only 语义；正式请求模型和错误行为在 API Contract 中冻结。Adviser 不展示 Status Filter，后端强制 Published-only。
- Filter Panel 展示 4 个 Mandatory Tag Group 以及 Optional `Proposition`/`Source`。
- Keyword 与 Filter 组合使用 AND；同一维度内多值使用 OR/ANY；请求包含重复值时后端先去重。
- 实时搜索的防抖属于前端行为；后端必须支持请求取消后安全完成，且不得改变任何数据。

## 11. 实施影响与 API 摘要

完整接口地址、字段模型和错误语义见[LEAD-93 接口约定](LEAD-93_API_Contract_Clarification_CN.md)。本章只保留能力变更摘要，避免在两份文档中重复定义。

**Jira Coverage：** LEAD-277、LEAD-293、LEAD-306、LEAD-307、LEAD-301、LEAD-276、LEAD-278、LEAD-300、LEAD-279、LEAD-296、LEAD-326、LEAD-327

### 11.1 API 变更摘要

下表中所有“增加、扩展、新增”的接口行为均由 v2 提供；v1 保持 [As-Is 基线](LEAD-93_API_V1_AsIs_CN.md)。Deactivate、Update Master、Get Max Version、Version History 和 Channel List 继续复用 v1。

| 能力 | As-Is | To-Be API 变更 | 兼容策略 |
|---|---|---|---|
| Published List | 现有硬编码排除 `is_campaign=1` | 增加 `is_campaign`、Category/Tag/Search 参数，不再无条件排除 Campaign | 保留原 config/version 状态条件 |
| Draft List | 现有多分支查询 | 增加 `is_campaign`、Category/Tag/Search 参数 | 复用原 Base Query，metadata 关联返回 version |
| Save Draft | 无 version Insert V1；Draft Update；Active 无 Draft Insert V(N+1)；Expired/Schedule 复用 V(N) 并转 Draft且保留时间 | 同一业务操作保存 version metadata；Active 新 Working Copy 首次复制 metadata，复用 V(N) 时更新同版本 metadata | 不改变现有版本选择逻辑 |
| Publish | 更新 version lifecycle | 增加 Category/Tag publish validation | 状态流转保持不变 |
| Scheduled Version Save/Delete | Save Draft 执行同一 version `0 → 3` 并保留时间；Version Delete 将 Scheduled row 软删除 | 两条路径均同步处理目标 version 的 metadata；不新增独立 Cancel Schedule API | 不修改旧 Active，不新增 version |
| Deactivate | 更新 `email_status` | 无核心变更 | 保持现状 |
| Delete | config/version 软删除 | 同步软删除 Subcategory/Tag relations | 不修改 `version_status` |
| Category | 无 Template 两级管理 API | 新增 tree/create/update/delete/reorder | 新增专用表 `iic_msg_email_category` |
| Batch Subcategory Create | 无 | 新增一次 1-5 条、后端单事务的批量创建 API | 不允许前端循环单条 Create 模拟成功 |
| Category Reassign-and-Delete | 无 | 新增后端原子命令：迁移 Active/Draft/Schedule Metadata 后软删除节点 | Expired 不迁移；失败整体回滚 |
| Category Delete Impact | 无 | 新增只读影响计数 API，供删除确认弹窗使用 | 仅作提示；正式命令在事务中重新查询 |
| Tag | 无 Template Tag API | 新增只读 taxonomy API | 无 Tag 管理 API |
| Metadata Update / Reassign | 无版本级结构化 Metadata API | 新增一个 `PUT` 全量替换 API；Reassignment 复用该接口 | 显式指定 version；不创建 version、不修改状态 |
| Preview | 已确认可复用现有正文和 Metadata 预览能力 | 无 API 或实现变更 | 完全保持现状；不支持附件 |
| Discard Draft | 已有 Version Delete、Template Delete | 未保存编辑仅前端丢弃；Published Working Copy 复用 Version Delete；新建 Draft 只使用 Template Delete | 不新增 Discard API；不回滚 config 主表字段 |
| Copy and Create | 需求范围未冻结 | 不与 `/version/add` 或同一 Template Working Copy 流程关联 | 若确认由后端承载则新增 v2 API；`COPY-01` 关闭前不冻结 Endpoint/DTO，当前 24 个接口不包含该能力 |

#### 11.1.1 Story 与接口影响索引

下表只统计本期方案中的运行时完整接口。同一接口可能同时支持多个 Story，因此各 Story 的接口数仅表示影响范围，不能相加作为接口总数。

| Story | 直接涉及的接口 | 保持不变/复用 | 修改现有 | 新增 | 本 Story 涉及数 |
|---|---|---:|---:|---:|---:|
| LEAD-277 数据模型与发布校验 | `EX-03`、`EX-04`、`EX-05`、`EX-10`、`EX-13`、`NEW-07` | 0 | 5 | 1 | 6 |
| LEAD-293 创建和管理分类/子分类 | `NEW-01`、`NEW-02`、`NEW-03`、`NEW-05`、`NEW-08` | 0 | 0 | 5 | 5 |
| LEAD-306 创建新模板 | `EX-05` | 0 | 1 | 0 | 1 |
| LEAD-307 删除分类/子分类 | `NEW-01`、`NEW-04`、`NEW-09` | 0 | 0 | 3 | 3 |
| LEAD-301 分配和编辑分类 | `EX-03`、`EX-10`、`NEW-01`、`NEW-07` | 0 | 2 | 2 | 4 |
| LEAD-276 模板重新分类 | `NEW-01`、`NEW-07` | 0 | 0 | 2 | 2 |
| LEAD-278 编辑已发布模板 | `EX-03`、`EX-05`、`EX-09`、`EX-10`、`EX-11`、`EX-12`、`EX-14` | 2 | 5 | 0 | 7 |
| LEAD-300 选择、分配和编辑标签 | `EX-03`、`EX-05`、`EX-10`、`EX-13`、`NEW-06`、`NEW-07` | 0 | 4 | 2 | 6 |
| LEAD-279 草稿与发布流程 | `EX-05`、`EX-09`、`EX-10`、`EX-11` | 0 | 4 | 0 | 4 |
| LEAD-296 删除模板 | `EX-08` | 0 | 1 | 0 | 1 |
| LEAD-326 模板预览 | 复用前端现有预览流程，无 LEAD-93 运行时接口 | 0 | 0 | 0 | 0 |
| LEAD-327 搜索与筛选 | `EX-01`、`EX-02` | 0 | 2 | 0 | 2 |
| LEAD-328 数据迁移 | 使用数据库脚本，无运行时接口 | 0 | 0 | 0 | 0 |
| 跨 Story 现有公共能力 | `EX-06`、`EX-07`、`EX-15` | 3 | 0 | 0 | 3 |

去重后的当前设计共包含 24 个完整接口：5 个保持不变/复用、10 个修改现有接口和 9 个新增接口。范围尚未确认的 Copy and Create 不计入本表，待 `COPY-01` 关闭后再决定是否调整接口数量。

### 11.2 Contract 管理

本期新增 Category Tree/CRUD/Reorder、Batch Subcategory Create、Category Delete Impact、Category Reassign-and-Delete、Tag Taxonomy 和 Metadata Update；Search/Filter、Detail、Save Draft、Publish、Version Delete 和 Template Delete 改造现有 API。Preview、Active/Deactivate 和附件接口保持现状。

接口地址、字段模型、错误语义和权限统一维护在[LEAD-93 接口约定](LEAD-93_API_Contract_Clarification_CN.md)。发布校验是现有发布接口的内部步骤；放弃草稿、取消预约和单个模板重新分配不新增独立接口。分类或子分类删除触发的批量迁移使用独立的“迁移并删除”接口。

### 11.3 分层代码改造清单

| 层级 | 保持不变/复用 | 修改 | 新增 |
|---|---|---|---|
| Frontend | Preview、附件上传组件 | Template Edit、Tag Group 多选、Search/Filter、Discard 路由 | Category 管理页面 |
| API/Controller | Preview、Attachment、Active/Deactivate | List/Detail、Save Draft、Publish、Version/Template Delete | Category CRUD/Reorder、Batch Subcategory、Delete Impact、Reassign-and-Delete、Tag Taxonomy Read、Metadata Update |
| Service | Scheduler、现有附件逻辑、Version Conflict 检测 | Template 命令编排、版本定位、Publish Validation、删除级联 | Metadata Service、Taxonomy Service、Reassign-and-Delete Orchestrator |
| Mapper/Repository | config/version/file Mapper | Published/Draft 查询、现有 Delete DML | Category/Tag 字典和 Subcategory/Tag relation Mapper |
| Database | `iic_msg_email_config`、附件表 | `iic_msg_email_config_version` | `iic_msg_email_category`、两张 relation、Tag Group/Value、Migration Snapshot、Migration Log |
| Release SQL | 现有发布执行机制 | config/version migration 与索引评审 | Category/Tag seed、mapping、snapshot、migration log、validation/rollback SQL |
| Scheduler | `changeVersionStatusByEffectiveFrom()` | 无 | 无 |

详细字段见第 7 章；Search/Filter 查询构造见第 10 章；正式 Endpoint、DTO 和错误码见本章摘要及 [API Contract](LEAD-93_API_Contract_Clarification_CN.md)。


## 12. Migration 与 SQL 执行设计

### 12.1 执行方式

**Jira Coverage：** LEAD-328

DBA 在上线前或上线窗口执行 SQL：

1. Schema change。
2. 加载 Staging，并在所有 Seed/Mapping DML 前生成 Migration Snapshot；在独立日志事务登记 Migration STARTED。
3. Category/Subcategory 与 Tag Group/Value 固定 seed。
4. 按存量目标 version 的 `email_code + version` 更新 `version.category_id`，并写入 Subcategory/Tag relation。
5. 执行一致性校验 SQL。
6. 写入 Migration SUCCESS/FAILED 结果，输出 migration report，并由 PO/BA/Tech 共同确认。

### 12.2 脚本要求

- Schema DDL：由版本化 migration 单次执行，执行门禁和前置检查见 12.5-12.9。
- Seed/Mapping DML：幂等，重复执行不会产生重复数据。
- 可追踪：`iic_msg_template_migration_snapshot` 保存修改前快照；`iic_msg_template_migration_log` 保存一次性执行目标、动作和结果。两者都不是运行时 Audit Log，Template 业务表不保存部署批次。
- 可校验：每一步有 count、duplicate、orphan 和 mandatory-tag 检查。
- 可回滚：回滚只针对 LEAD-93 新增/改造数据，不恢复被业务删除的模板。
- 不直接修改现有 `version_status` 生命周期数据。

完整 SQL 见 [SQL Index](sql/README.md)。

### 12.3 业务输入

PO/BA 需提供并确认：

- 79 个存量模板的保留、合并或淘汰结论。
- 每个保留模板对应的 Category、Subcategory 和 Tag。
- 重复/过期模板的目标 `email_code` 及处理方式。
- Deactivate/淘汰原因写入 Staging `action_note` 和一次性 Migration Log `action_reason`，用于迁移报告，不在 Template Library 页面或运行时 API 展示。

### 12.4 Migration 失败恢复与重跑

- 正式执行前必须运行 dry-run/pre-check，输出 staging 数量、未知 `email_code`、重复映射、缺失 Category/Subcategory/Tag 和目标名称冲突。
- 阶段开始、成功、失败和数量写入 `iic_msg_template_migration_log` 并同步输出 Migration Report；日志写入使用独立事务，业务迁移失败回滚后仍可登记 FAILED。
- 重跑使用同一批次时必须幂等；需要修正 mapping 时使用新批次，并保留旧批次报告。
- Snapshot 必须在任何 Seed、关系写入或存量 config/version 更新前完成；Snapshot 不完整时禁止执行后续 DML。
- Validation Report 未经 PO/BA/Tech 签字，不开放新 UI 和 Adviser 新分类入口。

### 12.5 SQL 文件组织与执行约定

所有 SQL 以 [SQL Index](sql/README.md) 为入口，按 `DDL_<table>.sql`、`DML_<table>.sql`、`QUERY_<table>.sql` 分类。SQL 文件是执行内容的唯一来源，本文不再复制 SQL，避免设计文档与部署脚本漂移。

- MySQL 8.0、InnoDB、`utf8mb4_bin`。
- 不创建 FK/check constraint。
- DDL 由 DBA 以版本化脚本单次执行。
- Seed/Mapping DML 使用业务唯一键保证幂等；`source_batch_id` 只保存在一次性 Migration Snapshot 和 Migration Log，不进入运行时 Template 业务表。
- DML 回滚由 `@lead93_rollback = 1` 显式启用。
- Deactivate migration 由 `@lead93_apply_deactivate = 1` 显式启用；只在业务 mapping 审批后开启，实际仅更新 `email_status = 0`。
- [SQL Index](sql/README.md) 的 `Readiness` 是执行门禁：标记为 Partially Updated 或 Blocked 的文件不得进入部署包。
- Search/Filter SQL 中已写入确认后的增量规则、`config.email_name` Template Title 条件和 Draft 选版矩阵；在完整 List/Count/排序及真实 Mapper 对接完成前，不作为最终 Mapper SQL。
- `iic_msg_email_config` 和版本表的候选索引必须使用实际列表、总数和定时任务查询执行 `EXPLAIN`，并与现有索引比较后由数据库管理员批准。

### 12.6 DDL 文件

| 目标表 | 变更 | SQL |
|---|---|---|
| `iic_msg_email_category` | 新建 Template 专用 taxonomy 表、有效名称/Category Code 唯一键和树索引 | [DDL_iic_msg_email_category.sql](sql/DDL_iic_msg_email_category.sql) |
| `iic_msg_email_config` | Published 查询复合索引 | [DDL_iic_msg_email_config.sql](sql/DDL_iic_msg_email_config.sql) |
| `iic_msg_email_config_version` | 增加 `category_id`、修正 Draft 注释、增加 Active/Schedule/Category 候选索引 | [DDL_iic_msg_email_config_version.sql](sql/DDL_iic_msg_email_config_version.sql) |
| `iic_msg_template_category_rel` | 新建 Subcategory 关系表 | [DDL_iic_msg_template_category_rel.sql](sql/DDL_iic_msg_template_category_rel.sql) |
| `iic_msg_tag_group` | 新建 Tag Group 表 | [DDL_iic_msg_tag_group.sql](sql/DDL_iic_msg_tag_group.sql) |
| `iic_msg_tag_value` | 新建 Tag Value 表 | [DDL_iic_msg_tag_value.sql](sql/DDL_iic_msg_tag_value.sql) |
| `iic_msg_template_tag_rel` | 新建 Template Tag 关系表 | [DDL_iic_msg_template_tag_rel.sql](sql/DDL_iic_msg_template_tag_rel.sql) |
| `iic_msg_template_migration_snapshot` | 新建 migration snapshot 表 | [DDL_iic_msg_template_migration_snapshot.sql](sql/DDL_iic_msg_template_migration_snapshot.sql) |
| `iic_msg_template_migration_log` | 新建一次性 migration execution log；不用于运行时审计 | [DDL_iic_msg_template_migration_log.sql](sql/DDL_iic_msg_template_migration_log.sql) |

### 12.7 DML 文件

| 目标/用途 | 内容 | SQL |
|---|---|---|
| Staging | Mapping 临时表定义 | [DML_lead93_staging.sql](sql/DML_lead93_staging.sql) |
| `iic_msg_tag_group` | 固定 Group seed、引用保护的受控停用与回滚 | [DML_iic_msg_tag_group.sql](sql/DML_iic_msg_tag_group.sql) |
| `iic_msg_tag_value` | Unclassified seed、引用保护的受控停用与回滚 | [DML_iic_msg_tag_value.sql](sql/DML_iic_msg_tag_value.sql) |
| `iic_msg_email_category` | Category/Subcategory seed 与回滚 | [DML_iic_msg_email_category.sql](sql/DML_iic_msg_email_category.sql) |
| `iic_msg_email_category` Runtime CRUD | 后端 Snowflake Create、一次最多 5 条 Subcategory 原子批量 Create、Rename/Edit、同级 Reorder Mapper 模板；不属于部署执行序列 | [DML_iic_msg_email_category_runtime.sql](sql/DML_iic_msg_email_category_runtime.sql) |
| `iic_msg_email_category` Runtime Delete | Active/Draft/Schedule Metadata 原子迁移后 Category/Subcategory 软删除 Mapper 模板；不属于部署执行序列 | [DML_iic_msg_email_category_delete.sql](sql/DML_iic_msg_email_category_delete.sql) |
| `iic_msg_template_migration_snapshot` | 所有 Seed/Mapping 前记录目标业务键、`INSERT/UPDATE` 类型和修改前快照 | [DML_iic_msg_template_migration_snapshot.sql](sql/DML_iic_msg_template_migration_snapshot.sql) |
| `iic_msg_template_migration_log` | 在独立日志事务记录一次性迁移 STARTED/SUCCESS/FAILED 结果 | [DML_iic_msg_template_migration_log.sql](sql/DML_iic_msg_template_migration_log.sql) |
| `iic_msg_template_category_rel` | Subcategory mapping 与回滚 | [DML_iic_msg_template_category_rel.sql](sql/DML_iic_msg_template_category_rel.sql) |
| `iic_msg_template_tag_rel` | Tag mapping 与回滚 | [DML_iic_msg_template_tag_rel.sql](sql/DML_iic_msg_template_tag_rel.sql) |
| `iic_msg_email_config` | 名称/描述/受控 Deactivate migration 与恢复 | [DML_iic_msg_email_config.sql](sql/DML_iic_msg_email_config.sql) |
| `iic_msg_email_config_version` | 版本主 Category、Email Subject mapping 与恢复 | [DML_iic_msg_email_config_version.sql](sql/DML_iic_msg_email_config_version.sql) |
| `iic_msg_email_config_version` Runtime | Active 首次 Save Draft 新建 Working Copy；Metadata 全量替换主 Category；Expired/Schedule Save Draft 复用 V(N)；Scheduled Version Delete | [DML_iic_msg_email_config_version_runtime.sql](sql/DML_iic_msg_email_config_version_runtime.sql) |
| `iic_msg_template_category_rel` Runtime | Working Copy 初始化；Metadata 全量替换 Subcategory；Version Delete/Working Copy Discard 和 Template Delete 软删除 relations | [DML_iic_msg_template_category_rel_runtime.sql](sql/DML_iic_msg_template_category_rel_runtime.sql) |
| `iic_msg_template_tag_rel` Runtime | Working Copy 初始化；Metadata 全量替换 Tag；Version Delete/Working Copy Discard 和 Template Delete 软删除 relations | [DML_iic_msg_template_tag_rel_runtime.sql](sql/DML_iic_msg_template_tag_rel_runtime.sql) |

### 12.8 QUERY 与校验文件

| 主表 | 用途 | SQL |
|---|---|---|
| `iic_msg_email_category` | 重复检查、树查询、层级校验 | [QUERY_iic_msg_email_category.sql](sql/QUERY_iic_msg_email_category.sql) |
| `iic_msg_email_config` | Published/Draft Search 与分页 | [QUERY_iic_msg_email_config.sql](sql/QUERY_iic_msg_email_config.sql) |
| `iic_msg_email_config_version` | 多 Active/Draft、时间字段一致性和 Schedule 扫描 | [QUERY_iic_msg_email_config_version.sql](sql/QUERY_iic_msg_email_config_version.sql) |
| `iic_msg_template_category_rel` | Subcategory 与主 Category 一致性 | [QUERY_iic_msg_template_category_rel.sql](sql/QUERY_iic_msg_template_category_rel.sql) |
| `iic_msg_tag_value` | 固定 taxonomy 查询与 Tag Value 停用前引用检查 | [QUERY_iic_msg_tag_value.sql](sql/QUERY_iic_msg_tag_value.sql) |
| `iic_msg_template_tag_rel` | Tag group/value 一致性 | [QUERY_iic_msg_template_tag_rel.sql](sql/QUERY_iic_msg_template_tag_rel.sql) |
| `iic_msg_tag_group` | Published Mandatory Tag 缺失校验与 Group 停用前引用检查 | [QUERY_iic_msg_tag_group.sql](sql/QUERY_iic_msg_tag_group.sql) |
| `iic_msg_template_migration_log` | 按 batch、结果和目标 version 查询一次性迁移执行结果 | [QUERY_iic_msg_template_migration_log.sql](sql/QUERY_iic_msg_template_migration_log.sql) |

### 12.9 执行顺序

1. 仅运行引用现有表和现有字段的 pre-DDL 检查，不提前查询 LEAD-93 新表或新字段。
2. 仅执行已解除 `Readiness/REVIEW GATE` 门禁并经 DBA 批准的 DDL；Partially Updated 或 Blocked 文件不得执行。
3. 运行新表和新字段的基线校验，包括 `QUERY_iic_msg_email_category.sql`，异常数量必须为零。
4. 设置 [SQL Index](sql/README.md) 中的 migration variables 并加载 staging。
5. 执行 snapshot DML，并在独立日志事务写入 STARTED。
6. 执行 Tag seed、Category seed。
7. 执行 version Category、relation 和 config migration DML。
8. 执行全部 post-migration 一致性校验，并在独立日志事务写入 SUCCESS；失败回滚后写入 FAILED。
9. 仅在批准回滚时设置 `@lead93_rollback = 1` 并按 DML 逆序执行。


## 13. 风险与待确认项

本章只保留影响方案评审的摘要。完整问题、Owner、冻结点和关闭记录统一维护在[未确认项与现状核对登记册](LEAD-93_Open_Questions_Register_CN.md)，不得仅在本章关闭问题。

### 13.1 已接受风险

| 风险 | 处理方式 |
|---|---|
| 现有 Template version 写操作不使用新增乐观锁字段、revision token、编辑锁或 Redis lock | 复用现有 Version Conflict 检测和错误语义；本期不扩展锁/token，纳入回归测试 |
| `LIKE %keyword%` 在数据增长后可能产生扫描开销 | 本期基于现有数据量使用数据库查询；上线前执行 `EXPLAIN`，后续按容量评估全文索引或搜索引擎 |
| 新增表不使用外键和 check constraint | Service 层在事务中校验层级、状态、唯一性和关系完整性，并通过校验 SQL 发现异常 |
| 应用回滚后旧版本不识别新增 Metadata | 新增表和字段保持向后兼容；应用回滚不删除新增数据，也不重写现有 version lifecycle |

### 13.2 业务待确认

| ID | 问题 | 当前处理 | 冻结点 |
|---|---|---|---|
| COPY-01 | Copy and Create 是同一 Template 的版本操作，还是复制选中版本并创建新 Template；复制范围和独立 v2 API 均未确认 | 不与 `/version/add` 或 Working Copy 流程关联，当前 24 个接口不包含该能力 | Copy and Create 开发及接口统计冻结前 |
| BUS-01 | 79 个存量模板的分类、标签、重复和过期映射 | 由 PO/BA 提供并签字确认 | Migration 数据脚本执行前 |
| BUS-02 | 在 Template Library 创建 Campaign 后进入哪个页面查看和继续管理 | 后端按 `is_campaign=1` 支持查询；页面入口、路由和导航归属由 BA/PO 决定 | Campaign 前端流程开发前 |
| BUS-03 | Expired V(N) 复用为 Draft 时，原 Metadata 引用了已删除/失效节点 | 暂按“只保留有效值；清空失效 Category/Subcategory；失效 Mandatory Tag 改为 `Unclassified`；Publish 前重新校验”实现 | 该分支上线前由 BA/PO 最终签字 |
| BUS-04 | 一次性数据迁移应覆盖哪些 version | 当前 SQL 只处理 Mapping 明确提供的 `email_code + version`，不自动推导；候选范围为 Active/Draft/Schedule，Expired 暂不迁移 | Migration Mapping 冻结及正式脚本执行前 |
