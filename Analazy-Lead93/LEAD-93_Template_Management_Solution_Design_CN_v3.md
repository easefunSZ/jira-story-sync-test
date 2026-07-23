# LEAD-93 / LEAD-405 / LEAD-406 Template Management 总体解决方案设计文档

> 技术方案评审版 v3  
> 状态：开发基线
> 需求基线：`DAE_PRD_LEAD-93 Template Management_v2.0 - updated July 21st.docx`（PRD v2.0）、2026-07-17 Jira Feature 拆分及 2026-07-21 LEAD-278 Jira/OM Copy and Create 澄清
> 交叉需求参考：`PRD_LEAD-308 Advisor-Template Management_v1.3 -updated July 20th.docx`
> 说明：本文先固化 As-Is，再做 Gap Analysis，最后给出 To-Be 设计。未确认信息统一放在“待确认项”，不作为实施基线。
> 统一未确认项：[未确认项与现状核对登记册](LEAD-93_Open_Questions_Register_CN.md)。登记册中的开放项及状态为唯一有效索引。

## 1. 文档目的

本文描述 LEAD-93、LEAD-405、LEAD-406 三个 Feature 在现有 DAE Template Management 上的总体改造方案，目标是：

- 清楚说明当前 Template 数据模型、版本生命周期、页面查询和核心操作行为。
- 对比 PRD 目标，明确新增能力和现有能力之间的差异。
- 建立 Jira Story、As-Is/Gap、To-Be 设计和实施产物之间的双向可追溯关系。
- 在保留现有模板主表、版本表和生命周期机制的前提下，设计 Category/Subcategory、Tag、Search/Filter 和 Migration 方案。
- 为开发拆分、数据库变更、API 联调、测试和上线提供统一技术基线。

三个 Feature 共享同一套 Master/Version、Metadata、Category、Tag 和生命周期设计，按 Jira 当前归属拆分交付：

| Feature | 定位 | Story |
|---|---|---|
| LEAD-93（1 of 3） | 数据模型、分类基础和新建草稿 | LEAD-277、LEAD-301、LEAD-306、LEAD-307 |
| LEAD-405（2 of 3） | 分类治理、Published 编辑和 Tag | LEAD-276、LEAD-278、LEAD-293、LEAD-300 |
| LEAD-406（3 of 3） | 发布、删除、预览、搜索和迁移 | LEAD-279、LEAD-296、LEAD-326、LEAD-327、LEAD-328 |

## 2. 结论摘要

本项目应定义为“现有 Template Management 能力增强”，不是新建模板系统。

核心设计结论如下：

1. 保留 `iic_msg_email_config` 和 `iic_msg_email_config_version`，不重建 Template 主模型和版本状态机。
2. `email_code` 继续作为逻辑模板的业务标识；Category、Subcategory、Tag 与模板基本信息均属于 Template 当前属性，按 `email_code` 保存，不随内容版本复制或切换。
3. 新增 Template 专用表 `iic_msg_email_category`，承载 Category/Subcategory 两级 taxonomy。
4. 在 `iic_msg_email_config` 增加 `category_id`；新增 Template 级 Subcategory Relation、Tag Group、Tag Value、Template Tag Relation、Template Change History 和 Category Change History 表。
5. Published/Draft Tab 保留，Content Manager 保留 Status Filter 能力，但 Published Tab 不展示/不允许选择 Status Filter；本期 Web Template Library 固定查询 Email（`is_campaign = 0`），搜索在现有 Tab 基础查询上叠加 Category、Tag 等条件。
6. 不新增数据库外键和 check constraint；关系完整性、层级合法性和必填校验由 Service 层保证。
7. 初始 Category、Tag 及存量模板映射由幂等 SQL 上线，DBA 执行；Tag 后续仍只允许通过 DB 脚本维护。
8. Subcategory 支持一次最多 5 条的原子批量创建；删除 Category/Subcategory 时，只要 Template 存在 Active、Draft 或 Schedule version，首次删除不写库并返回 `reassignRequired` 与 `affectedTemplateCount`；确认有效迁移目标后，后端才在同一事务中迁移该 Template 的当前 Metadata 后软删除节点。迁移目标不得是源节点自身或其子树；仅有 Expired version 的 Template 不迁移。
9. 不新增 Template 编辑锁、revision token 或 Redis lock；现有 Version Conflict 的精确触发条件尚未核实，不将推测的比较字段或触发时点写入本期基线。
10. Template 基本信息或 Metadata 每次成功修改都写入不可变的前后快照；Category/Subcategory 的创建、修改、排序和删除写逐节点 Change History，删除另写一条操作级 Audit，并为每个受影响 Template 写一条 Template Change History。一次性 Migration Log 只记录部署批次结果，四类记录用途不混用。
11. Template Title 非空、最长 120，仅允许字母、数字、空格及 `- , . & ' ’`；Copy 场景额外允许系统生成的结尾 ` (Copy)`；禁止 HTML 和 `@ # $ %`，并在同一主 Category 内保持唯一。
12. Trigger Tag 允许多选但每个 Template 最多选择 5 个；该上限是后端 Service 常量，并通过 Taxonomy API 返回，前后端执行同一规则。
13. 首次发布不额外插入版本行：同一 V1 从 Draft 变为 Active，并作为 V1 历史记录出现在 Version History 中。
14. Template Change History 记录 `email_name`、Description、Email/Campaign 类型（`is_campaign`）、Channel、Channel Name、Custom Branding、Category、Subcategory、Tag、`email_status` 与软删除状态；不新增独立 `format` 字段；Subject、正文、附件、生效时间和 `version_status` 继续由 Version History 表达。

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
- 正常页面流程允许同一 `email_code` 同时存在一个 Active 和一个 Draft Working Copy；Draft 不影响当前 Active 内容。一个 Draft 是前端流程约束，现有后端和数据库未强制该不变量。
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

该矩阵是已确认的页面查询结果，选版规则不再作为业务待确认项。它不代表 Save Draft Service 在异常多 Draft 数据下也一定选择最大版本；该代码路径见第 3.6 节风险说明。

### 3.6 当前核心操作行为

本节只作为 As-Is 事实基线，详细场景差异见第 5.2 节。

| 操作 | 当前数据库行为 | 状态变化 | 明确不修改 |
|---|---|---|---|
| Save Draft：无 version / 已有 Draft | V1 不存在则 Insert V1；已有 Draft V(N) 则 Update V(N) | 目标 version 保持 `version_status = 3`；用户输入的 `effective_from/effective_until` 写入 Draft row | 当前 Active 内容 |
| Save Draft：Active、无 Draft | Insert V(N+1) Working Copy | 新 version 为 Draft `3`；Active V(N) 保持 `1` | 当前 Active 内容和生效时间 |
| Save Draft：仅 Expired、无 Draft | 保留 Expired V(N)，Insert V(N+1) Draft | 旧 V(N) 保持 `2`；新 V(N+1) 为 `3` | Template Identity 和 Expired 历史版本 |
| Save Draft：Schedule | 复用并 Update V(N)，不创建并存 Draft | 同一 version `0 → 3`；保留原 `effective_from/effective_until` | 旧 Active 和 Template Identity |
| Delete Scheduled Version | 按现有 Version Delete 路径软删除 Scheduled V(N) | `version.status → -1`；保留 `version_status = 0` 和原生效时间 | 旧 Active、config 和其他 version |
| Publish Now | 更新新旧 version 和 effective time | 旧 Active `1 → 2`；目标 Draft `3 → 1`；新 Active 的 `effective_from = now`、`effective_until = NULL` | `config.email_status` |
| Scheduled Activation | Java 定时任务 `changeVersionStatusByEffectiveFrom()` 处理到期版本 | Schedule `0 → 1`；旧 Active `1 → 2` | Template Identity |
| Deactivate | 只更新 `iic_msg_email_config.email_status: 1 → 0` | version 仍保持原 `version_status` | config `status` 和所有 version `version_status` |
| Delete | config 与该模板所有 version 级联软删除 | 修改 config/version 的软删除 `status` | 所有 version `version_status` |

现有 Template version 写操作未使用乐观锁、revision token 或 Redis lock，存在并发覆盖风险。一个逻辑 Template 只能有一个 Draft 目前也只由前端页面限制：后端未做唯一 Draft 校验，数据库无对应唯一约束；直接调用接口、并发请求或既有异常数据可能产生多个 Draft。实测代码在已存在 V2/V3 Draft、请求 V4 不存在时，可能先查到较早 Draft，再按最大版本插入 V5。To-Be 暂时保持现状，不把多 Draft 作为正常状态机分支，仅登记为已接受风险；Delete 不提供一键恢复。

### 3.7 当前附件机制

- 附件存储到 S3，文件元数据位于 `iic_msg_file_upload`。
- 单个附件最大 10 MB，对应现有 `size` 字段口径为 `size <= 10240 KB`。
- 附件格式维持现状，但明确排除多媒体、视频和音频。
- LEAD-93 不改变正文版本通过 `file_keys` 引用附件的方式。

### 3.8 As-Is 适用边界

第 3.1-3.7 节作为数据库与业务行为的现状基线。后续设计不得改写本章已确认的状态、选版和数据行为。

2026-07-16 QA 黑盒回归覆盖了 15 个本次交付范围内的现有接口及 2 个辅助查询接口，共完成 22 个有序调用场景。HTTP、公共包络、业务码和已记录状态结果符合预期。已实测的关键状态结果包括：新建 V1 Draft、更新 V1、同一 V1 立即 Publish、Deactivate/Reactivate、增加 V2 后 V2 Active/V1 Expired、Draft/Schedule version 删除成功、Active version 删除被拒绝，以及 Template Delete 成功。

以下行为未由本轮黑盒回归覆盖，不能仅凭本次结果标记为接口事实已冻结：Publish Future、Scheduler 到点生效、Expired/Schedule Save Draft、Active 首次 Save Draft 创建 Working Copy，以及 Version Conflict。其后续内网代码核对已确认：仅 Expired 且无 Draft 时 Insert V(N+1) Draft；Schedule Save Draft 仍更新同一 V(N)。Version Conflict 仅确认“现有实现会返回业务失败”，其比较基线、触发命令、检测时点和真实错误码仍需专项核实。

本轮还确认：在 v1 `POST /version/add` 提交目标 `version="V2"`、`effectiveWay=0` 的完整 payload 后，可观察结果是 V2 Active、V1 Expired。该接口用于同一 Template 的内容版本增加：`effectiveWay=0` 时目标 Version 立即 Active、旧 Active Expired；`effectiveWay=1` 时目标 Version 先进入 Schedule、旧 Active 保持，由现有 Scheduler 到点完成切换。v2 只增加发布时对 Template 当前 Metadata 的校验，不把 Metadata 写入 Version。Copy and Create 是独立的新建命令：它以当前最新 Published/Active Version 为来源，首次 Save Draft 时通过新增 v2 API 创建新的 Template B，不能由 `/version/add` 承载。

## 4. 新需求摘要

LEAD-93、LEAD-405、LEAD-406 在保留现有 Template 主模型、版本生命周期和附件机制的基础上增加以下能力：

| 能力域 | 新需求 | 关键业务规则 | 主要影响范围 | 验收关注点 |
|---|---|---|---|---|
| Category/Subcategory | 提供可管理的两级 Template 分类树 | 仅允许两级；名称在 Template taxonomy 内全局唯一；Subcategory 必须归属有效 Category；单次原子批量创建最多 5 条；删除按有效引用分流：无引用直接软删除，有引用才迁移 Active/Draft/Schedule Metadata | 前端管理页面、Category API、新增 `iic_msg_email_category`、Metadata relation | 层级合法、全局重名、批量原子性、直接删除与迁移删除原子性、排序稳定 |
| Tag Taxonomy | 提供固定 Tag Group 和 Tag Value | 4 个必填组；每个 Group 可多选，Trigger 最多 5 个；Draft 可不选择 Tag，Publish 时再校验 4 个必填组；不提供 Tag 管理 UI | Tag 只读 API、新增 Tag 字典表、DBA seed | 固定值完整、组内多选、Trigger 上限、Draft 空值、Publish 必填、上线后仅 DB 脚本维护 |
| Template Metadata | 建立 Template 与主 Category、Subcategory、Tag 的结构化当前关系 | 主 Category 存入 config；Subcategory/Tag 按 `email_code` 保存；与 Version 生命周期解耦 | 扩展 config、新增 relation 与 Template Change History 表 | 当前关系一致、历史快照完整、无孤儿和重复关系 |
| Search/Filter | 支持按 PRD 定义的 Template Name、Email Subject、Description、Tag Name 关键词，以及 Category、Subcategory、4 个 Tag Group、Status 组合查询 | Web 查询固定 `is_campaign=0`；Published Tab 禁用 Status Filter；跨维度 AND，同维度 OR/ANY；Email Subject 来自结果 version，Metadata 来自 Template 当前关系 | 列表 API、Mapper SQL、前端筛选器和索引 | 四类关键词字段均可命中、Template Metadata 匹配正确、Count 与分页准确 |
| Template 主信息与 Metadata 编辑 | 新建时通过聚合 Save Draft 一次提交；已有 Template 通过统一 Update 命令保存当前 Category/Subcategory/Tag 并记录修改历史 | 不创建 Draft、不修改 `version_status`；Version 状态不决定 Metadata 归属 | 编辑页面、聚合 Template API、Change History、Publish validation | 创建无孤儿草稿、Library 位置立即更新、Version 生命周期保持、历史快照完整 |
| Template 可见性 | 统一 Content Manager Tab 与 Adviser View 的可见性规则 | Adviser 只能读取 Enabled + Active Published 内容；Draft/Schedule 不可见；Deactivate/Delete 保持现有生命周期语义 | Published/Draft 查询、Adviser 查询、权限控制 | 不可通过参数绕过 Published-only；Deactivate 后不可见 |
| Publish Validation | 发布前增加 Title、Description、Category、Mandatory Tag 和正文完整性校验 | Title 非空、最长 120、字符白名单、同一主 Category 内唯一；Trigger 最多 5 个；附件不必填且由前端校验；失败返回错误数量和字段错误，本次页面内容不保存 | Publish API、定时任务、错误响应 | 原 Draft/旧 Active 不变、不产生版本条目、字段错误可定位 |
| Migration | 对存量模板进行分类、标签映射和必要的数据清理 | `BUS-01` 确认后生成一次性 Mapping DML，按 SQL 发布清单执行 | Migration Log、DDL、固定 Seed、Mapping DML | 迁移结果可追踪 |
| 附件约束 | 延续 S3 和 `file_keys` 机制并收紧文件边界 | Email/Campaign 附件均为可选；单个附件最大 10 MB；维持现有格式能力，排除多媒体、视频和音频 | 前端校验、复用现有附件接口、测试 | 不上传附件可正常发布；非法文件在前端阻止提交 |
| Copy and Create | 从当前最新 Published/Active Version 复制出独立的新 Template | 点击时仅预填；首次 Save Draft 调用新增 API 原子创建 B 的主记录、V1 Draft、当前 Metadata 和历史，并写 `copy_from_email_code=A`；附件复用原 `file_keys`；B 发布前仅提示 CM 按需停用 A | 新增 Copy API、主表来源字段、创建事务、Metadata relation、Template Change History、前端 Publish Popup | A/B 独立查询、发布和版本管理；A 未停用时 CM/Adviser 均看到两条；不自动修改 A；失败不产生残留 B；不物理复制 S3 对象 |

明确不在本期范围：

| 排除项 | 本期处理原则 |
|---|---|
| 重建 Template 主表和版本表 | 继续复用 `iic_msg_email_config` 和 `iic_msg_email_config_version` |
| 重写 Draft/Published 状态机 | 保留 Draft、Schedule、Active、Expired 及现有 version control |
| Tag 管理 UI | Tag 首次固定 seed，后续仅通过受控 DB 脚本维护 |
| 乐观锁、revision token、编辑锁、Redis lock、`requestId` | 本期不新增；现有 Version Conflict 的精确行为列为待核实风险 |
| Elasticsearch | 本期使用数据库查询；数据量显著增长后再评估 |
| 一键恢复已删除模板 | Delete 继续按现有软删除语义，不提供业务恢复入口 |
| 多媒体、视频和音频附件 | 明确禁止上传和发布 |

## 5. Gap Analysis

### 5.1 能力差异总览

![LEAD-93 Gap Analysis](diagrams/lead93-gap-analysis.svg)

| 能力 | As-Is | LEAD-93 Gap | 设计决策 |
|---|---|---|---|
| Category | Template Management 当前没有 Category/Subcategory 数据模型或管理流程 | 需要 Category/Subcategory 管理、批量创建和按有效引用分流的删除 | 新增专用表 `iic_msg_email_category`、Template 当前关系、统一删除入口：先返回影响，再同事务迁移并软删除 |
| Tag | 无 Template 固定标签体系 | 需要固定组和值及模板关联 | 新增 Tag 字典和关系表，SQL seed |
| Template Metadata | 基本信息位于主表，但没有 Category/Subcategory/Tag 结构化关系及统一修改历史 | 需要可查询的当前关系，并保留每次修改前后值 | config 增加 `category_id`；按 `email_code` 新增关系表；新增 Template Change History 快照表 |
| Search/Filter | Published/Draft 各自有复杂过滤 | 需要组合过滤但不能改变存量语义 | 复用 Tab Base Query 后扩展 join |
| Lifecycle / Effective Time | Save Draft 保存时间并得到 Draft：Active 无 Draft时 Insert V(N+1)；仅 Expired 且无 Draft时保留 Expired V(N) 并 Insert V(N+1)；Schedule 则复用 V(N) 执行 `0 → 3`；Publish 才根据未来时间转 Schedule；Scheduled version 也可通过 Version Delete 软删除 | Version 生命周期无行为 Gap；首次创建 Save Draft 在同事务落入当前 Metadata，后续 Version 操作不触碰 Metadata | 保留现有版本选择与状态触发边界；Publish 只读取当前 Metadata 做校验；不新增 Cancel Schedule API |
| Migration | 无新 taxonomy 映射 | 需初始化及映射存量模板，并保留一次性执行结果 | DBA 执行幂等 SQL、Migration Log 和校验报告 |

### 5.2 场景状态机对比

本节对比各业务场景的 As-Is 基线、To-Be 保持项及新增差异。生命周期及生效时间规则保持现状；LEAD-93 的主要增量是 Template 当前 Metadata、修改历史、发布校验及分类删除事务。第 8 章不再重复状态对比，只定义 To-Be 实现规则。

#### 5.2.1 新建、保存草稿与发布

![新建、保存草稿与发布](diagrams/lead93-scenario-create-publish.svg)

本场景的生命周期没有 As-Is/To-Be 状态差异，因此图中只保留一条共同状态机，并单独标出外围差异。**首次创建** Save Draft 通过 EX-05 在同一事务写 Template Master、V1 Draft 和当前 Metadata；已有 Template 的 Save Draft 仍只写目标 Version。Publish 前读取 Template 当前 Metadata 进行完整性校验，但不复制或切换 Metadata。

业务流转边界、`email_code` 后端生成和 Insert/Update 结果矩阵已确认。现状无独立 Cancel Schedule API，Scheduler 只需在上线前做回归验证。

#### 5.2.2 Cancel 边界

5.2.1 已定义 Save Draft 的目标版本定位、Insert/Update 和发布状态流转，本节不重复该状态机。Cancel 只是离开当前编辑流程的页面动作，不新增 Version 状态、后端 Endpoint 或 Metadata 语义：

| Cancel 时点 | 后端行为 | 不受影响的数据 |
|---|---|---|
| 首次 Save Draft 之前 | 不调用后端，仅丢弃页面输入 | 所有已持久化 Template/Version 数据 |
| 已保存 Working Copy | 复用 Version Delete 软删除目标 Draft | Active Version、Template 当前 Metadata、主表字段、附件对象 |
| Scheduled Version | 复用 Save Draft `0 → 3` 或 Version Delete | 旧 Active 与 Template 当前 Metadata |

Cancel 不回滚独立持久化的 Template 主表字段，也不复制、回滚或清理 Category/Subcategory/Tag。Copy and Create 不属于 Working Copy 的分支，见 5.2.7 和 9.2.2。

#### 5.2.3 Deactivate 与 Delete

![Deactivate 与 Delete](diagrams/lead93-scenario-deactivate-delete.svg)

本场景的 As-Is 基线直接复用第 3.4 节 Template 可用性与软删除泳道。Deactivate/Active 仍只切换 `config.email_status`，Template Delete 仍软删除 config/version 且不重写 `version_status`。新增要求是为启停和删除写 Template Change History；Category/Subcategory/Tag 当前关系保留以支持历史追溯，不删除 taxonomy 节点。

#### 5.2.4 Category、Subcategory 与 Tag 元数据修改

![Metadata 修改](diagrams/lead93-scenario-metadata.svg)

As-Is 只确认 Template Master 与 Version 的字段归属，现有系统没有 Template Category/Subcategory/Tag 关系。To-Be 为每个 `email_code` 保存一套当前 Metadata，并在每次修改时保存完整前后快照。Metadata 不属于 Draft 或任何内容 Version：首次创建由 EX-05 聚合写入；已有 Template 的主信息和 Metadata 由 EX-06 一次保存；Publish、Cancel 和 Version Delete 均不写入它。EX-06 不使用 `version`，也不改变 `version_status`。Published Template 修改 Category/Subcategory 后立即更新当前 Metadata，Template 继续保持 Published，不创建 Draft 或新的 Version。

#### 5.2.5 页面状态派生

![页面状态派生](diagrams/lead93-scenario-derived-ui-state.svg)

As-Is 查询部分直接复用第 3.5 节：Published Tab 使用已确认的 Active 硬编码条件，Draft Tab 保留 Disabled、Draft、Schedule 三类语义和三个 OR 分支。To-Be 在现有 Tab base query 上固定 `is_campaign = 0`，再叠加 Category/Subcategory、Tag 和列表关键字条件（Adviser 参数为 `emailName`，CM 参数为 `keyWords`）；不得把 Draft Tab 简化为 `version_status = 3`，也不得新增独立数据库状态。

#### 5.2.6 Category/Subcategory 生命周期

![Category 生命周期](diagrams/lead93-scenario-category-lifecycle.svg)

As-Is Template Management 没有两级 taxonomy、Template 关系或删除迁移流程，因此本场景不存在可复用的 As-Is 状态机。To-Be 使用专用表 `iic_msg_email_category`，支持一次最多 5 条 Subcategory 的原子创建。删除统一调用 NEW-12：第一次请求先评估影响；无 Active/Draft/Schedule 引用时在同一入口直接软删除；存在引用时返回影响并要求提交迁移目标，重提后在同一事务迁移当前 Metadata、写修改历史和软删除。仅有 Expired Version 的 Template 不阻止删除也不迁移。

两级结构、有效条件、全局名称唯一、软删除后同名重建、批量创建，以及统一删除入口的影响评估/迁移删除规则均已确认。

#### 5.2.7 Copy and Create 独立模板

![Copy and Create 独立模板](diagrams/lead93-scenario-copy-and-create.svg)

As-Is 的 `/version/add` 在同一 `email_code` 下增加内容 Version：立即生效时切换 Active，预约生效时先进入 Schedule，不能用于本需求。To-Be 的 Copy and Create 从 A 的当前最新 Active Version 预填编辑页面，点击动作不写数据库；首次 Save Draft 才调用新增 Copy API，一次性创建新 `email_code` 的 Template B、V1 Draft、当前 Category/Subcategory/Tag 和修改历史，并在 B 主记录保存 `copy_from_email_code=A`。该字段只是不可变的内部来源追踪值，不形成父子、替代、可见性或级联状态关系。B 从创建起拥有独立生命周期；A、B 后续均 Published 且 A 未停用时，Content Manager 和 Adviser 都按普通独立模板看到两条。B 点击 Publish 时前端显示非阻断提醒，说明发布 B 不会自动停用 A，CM 可继续发布并按需通过现有 Deactivate 操作单独停用 A。

### 5.3 Jira Story 与 To-Be Solution 可追溯关系

本节作为 Gap Analysis 与 To-Be Design 之间的导航层，覆盖 LEAD-93、LEAD-405、LEAD-406 三个 Feature 的 13 个 Story。差异来源以当前第 5 章、PRD v2.0、对应 Jira Story及已确认的方案决策为准。矩阵中的实心圆表示该 Story 的主要解决方案，空心圆表示复用、依赖或间接影响；空白表示没有直接改造。矩阵只用于快速定位，下面的明细表是开发和评审使用的正式追踪入口。

下表列出需要特别关注的 Jira/PRD 规则及其已确认实现口径；仅实际不一致的项需要作为需求管理动作同步：

| Story | Jira / PRD 规则 | 已确认总体方案 |
|---|---|---|
| LEAD-307 | 有关联 Template 时阻止删除 | 统一 NEW-12：无 Active/Draft/Schedule 引用时直接软删除；有引用时返回影响并在重提目标后迁移当前 Metadata 后软删除；Expired 不阻止、不迁移 |
| LEAD-301 AC7 | Published 修改 Category/Subcategory 后，Template 保持 Published；分类变更属于 Metadata 修改 | 已对齐：EX-06 直接更新 Template 当前 Metadata 和 Change History；不创建 Draft、不新增 Version、不修改 Active `version_status` |
| LEAD-277 Trigger | 字段规则为最多 5 个，但错误文案出现最多 4 个 | 统一为最多 5 个，错误文案同步为 5 个 |
| LEAD-278 / PRD v2.0 | Copy and Create 的业务结果为独立 Template B，发布后 A/B 均可保持可见 | A/B 是两个独立 Template；B 保存独立 V1 Draft，发布后 A/B 均可见；只保存内部 `copy_from_email_code` 并在 B 发布前提醒 CM 按需停用 A，不改变内容级版本管理 |

![Jira Story 与 Solution 覆盖矩阵](diagrams/lead93-story-solution-traceability.svg)

| Jira Story | 解决方案摘要 | As-Is / Gap 来源 | To-Be 设计位置 | 主要实施产物 | 当前状态 |
|---|---|---|---|---|---|
| [LEAD-277](https://oldmutualig.atlassian.net/browse/LEAD-277) Template Data Model & Validation | 保留 Master/Version；在 Master 增加当前主 Category，按 Template 增加 Subcategory/Tag relations 与修改历史；Trigger 最多 5 个；统一 Publish Validation | 3.1、3.3、5.1 | 7.1-7.6、9.3、11 | [Config DDL](sql/required/DDL_iic_msg_email_config.sql)、[Change History DDL](sql/required/DDL_iic_msg_email_template_change_history.sql)、[API Contract](LEAD-93_API_Contract_Clarification_CN.md) | 数据归属已确认；字段错误通过 `IICException` 交由 API 统一返回 |
| [LEAD-293](https://oldmutualig.atlassian.net/browse/LEAD-293) Create Category/Subcategories | 新增专用 Category 表构建两级树；全局重名由 Service 校验；支持一次最多 5 条 Subcategory 原子批量创建 | 3.1、5.2.6 | 7.2、8.2.1、11 | [Category DDL](sql/required/DDL_iic_msg_email_category.sql)、[Taxonomy 图](diagrams/lead93-tobe-taxonomy-management.svg) | 业务规则和 Endpoint Contract 已冻结 |
| [LEAD-306](https://oldmutualig.atlassian.net/browse/LEAD-306) Create New Template | 首次 Save Draft 后端生成 `email_code` 并 Insert V1；Draft 允许内容和 Metadata 不完整；首次 Publish 将同一 V1 激活并产生 Version History 记录 | 3.2、3.6、5.2.1 | 9.1-9.3、10.3、11 | [Write Pipeline 图](diagrams/lead93-tobe-write-command-pipeline.svg) | 本期 Web 固定 Email-only，后端新建主记录固定 `is_campaign=0` |
| [LEAD-307](https://oldmutualig.atlassian.net/browse/LEAD-307) Delete Category/Subcategory | 无 Active/Draft/Schedule 引用时直接级联软删除；有引用时原子迁移当前 Metadata 后删除；Expired 不阻止、不迁移；记录删除人和时间 | 5.2.6 | 7.2、8.2、9.4、11 | [Category Delete 图](diagrams/lead93-tobe-category-delete-design.svg) | 删除分流规则已冻结 |
| [LEAD-301](https://oldmutualig.atlassian.net/browse/LEAD-301) Assign & Edit Category | Category/Subcategory/Tag 按 Template 保存；首次创建由 EX-05 聚合写入，已有 Template 由 EX-06 聚合更新并写历史 | 5.2.4 | 8.1、8.2、11 | [Metadata 图](diagrams/lead93-tobe-template-reassignment.svg)、[API Contract](LEAD-93_API_Contract_Clarification_CN.md) | 不以 Draft 状态定义 Metadata；已有 Template 的 Save Draft 不接收 Metadata |
| [LEAD-276](https://oldmutualig.atlassian.net/browse/LEAD-276) Template Reassignment | 单个 Template 的主信息与 Metadata 使用 EX-06；批量 Reassignment 使用 NEW-11；Category/Subcategory/Tag 当前值全量替换并写历史 | 5.2.4 | 8.1、11 | [Reassignment 图](diagrams/lead93-tobe-template-reassignment.svg)、[API Contract](LEAD-93_API_Contract_Clarification_CN.md) | 目标行为和 Contract 已冻结 |
| [LEAD-278](https://oldmutualig.atlassian.net/browse/LEAD-278) Edit Published Template / Copy and Create | Working Copy 保留现有同一 Template 版本管理；Copy and Create 首次 Save Draft 创建独立 B，并写内部来源字段；B 发布前提醒 CM 按需停用 A，发布后不自动归档或隐藏 A | 3.6、5.2.2、5.2.7 | 6.2、7.3、9.1-9.4、11 | [Working Copy 场景图](diagrams/lead93-scenario-edit-published.svg)、[Copy 场景图](diagrams/lead93-scenario-copy-and-create.svg)、[Config DDL](sql/required/DDL_iic_msg_email_config.sql)、[API Contract](LEAD-93_API_Contract_Clarification_CN.md) | 2026-07-21 Jira/OM 结论已冻结；A/B 内容级版本管理保持独立 |
| [LEAD-300](https://oldmutualig.atlassian.net/browse/LEAD-300) Select/Assign/Edit Tags | 固定 Tag Taxonomy；每组多选；按 Template 保存当前 relation；Mandatory Group 发布校验；修改写历史 | 5.2.4 | 7.5、8.1-8.2、9.3、10、11 | [Tag 管理图](diagrams/lead93-tobe-tag-taxonomy-management.svg)、[Tag Relation DDL](sql/required/DDL_iic_msg_template_tag_rel.sql) | 业务规则、29 个初始 Tag Value 和 Seed DML 已确定 |
| [LEAD-279](https://oldmutualig.atlassian.net/browse/LEAD-279) Draft & Publish Workflow | 保持现有 Insert/Update 和状态机；Publish Now/Future 统一校验；失败不保存本次内容并保留原 Draft/旧 Active | 3.4、3.6、5.2.1-5.2.2 | 9.1-9.4、11 | [As-Is State Flow](diagrams/lead93-as-is-state-flow.svg)、[Command Pipeline](diagrams/lead93-tobe-write-command-pipeline.svg) | 旧 Active→Expired、Draft→Active，不覆盖旧 row |
| [LEAD-296](https://oldmutualig.atlassian.net/browse/LEAD-296) Delete Template | 复用 Template Delete 级联软删除；保留当前 Metadata relations，增加删除历史；不重写 `version_status` | 3.6、5.2.3 | 6.2、8.1、9.2、9.4、11 | [Delete 场景图](diagrams/lead93-scenario-deactivate-delete.svg) | 业务规则已确认；在现有 Delete 事务中增加历史写入 |
| [LEAD-326](https://oldmutualig.atlassian.net/browse/LEAD-326) Template Preview | 完全复用现有 Preview；展示当前临时正文和 Metadata；不持久化、不预览附件 | 5.1 | 6.2、9.3、10.3、11 | [API Contract](LEAD-93_API_Contract_Clarification_CN.md)；复用现有 Preview API/Renderer，无新增 SQL | 复用边界已确认；本期不改 Preview |
| [LEAD-327](https://oldmutualig.atlassian.net/browse/LEAD-327) Search & Filter | 先确定 Tab 的 `email_code + result_version`，再按 `email_code` 应用当前 Metadata Filter；同组 OR、跨组 AND | 3.5、5.2.5 | 10、11 | [Search Pipeline 图](diagrams/lead93-search-filter-query-pipeline.svg)、[API Contract](LEAD-93_API_Contract_Clarification_CN.md) | 查询语义已确认；开发时合并到现有 Mapper |
| [LEAD-328](https://oldmutualig.atlassian.net/browse/LEAD-328) Data Migration | 固定 Seed、批次 Migration Log、Template 级 Mapping | 5.1 | 12 | [必交付 SQL 包](sql/required/README.md) | 正式业务 Mapping 由 `BUS-01` 管理 |

追踪原则：Story 只作为需求来源和导航，不复制其 AC 到每个技术章节；同一技术规则只在一个 To-Be 章节定义，其他 Story 通过本表引用。实现期间如 Story AC、PRD 或 API Contract 发生变化，必须同步更新对应行的设计位置、实施产物和状态。

## 6. To-Be 总体方案

### 6.1 目标架构

![LEAD-93 To-Be 总体方案](diagrams/lead93-to-be-solution.svg)

目标方案分为三层：

- UI/API 层增加 Category、Tag、Metadata 和 Search 能力。
- Template Lifecycle Service 继续负责 Save Draft、Publish、Deactivate 和 Delete。
- 数据层复用 Template Master、Version 和 File 表；Master 增加 `category_id`，同时新增专用 Category、Template 级 relation、Tag 和 Template Change History 表。

API 采用双版本兼容策略：Mobile App 不属于本期交付，现有 v1 仅作为不可破坏兼容基线；Web 端 25 个接口统一使用 v2。`EX-07/12/14/15` 仅增加 v2 Controller 路由并复用现有 Service/DTO 行为；EX-05/EX-06 为本期聚合改造，不复制业务逻辑。v1/v2 共享底层 Template/Version 数据，因此通过 v2 Publish、Deactivate 或正式数据迁移产生的业务数据变化仍会被 v1 客户端看到。

| API 层 | 范围 | 处理 |
|---|---|---|
| v1 | Mobile App 兼容基线（不交付 LEAD-93 新能力） | Endpoint、请求和响应保持现状；详见 [v1 As-Is 基线](LEAD-93_API_V1_AsIs_CN.md) |
| v2 行为复用 | `EX-07/12/14/15` | 新增 v2 路由，复用现有 Service/DTO，不改变核心行为 |
| v2 增强 | `EX-01`—`EX-06`、`EX-08`—`EX-11`、`EX-13`、`EX-16` | 复用现有能力并增加 Metadata、Filter、变更历史、校验或明确发布命令 |
| v2 新增 | `NEW-01/02/03/05/06/08/10/11/12` | Category、Tag、批量 Reassign、统一删除和独立 Template Copy 新能力 |

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
| Version Delete | Reused | 复用现有 API；Template 当前 Metadata 与 Version 无关，不清理 relations |
| Template Delete | Reused/Changed | 复用现有级联软删除；保留当前 Metadata 关系并写一条 Template 删除历史 |
| Existing Version Control | Reused / Risk | 不新增 Redis lock、锁字段或独立 revision token；现有 Conflict 的精确触发条件待专项核实 |

附件继续按 version 隔离：Working Copy 新附件不修改旧 Active `file_keys`；Publish 成功后沿用现有保留策略；Cancel/Delete 不删除 S3 对象或 `iic_msg_file_upload` row，也不新增延迟清理和 orphan 状态。


### 6.3 组件与职责边界

第 5 章已经按业务场景说明 As-Is 与 To-Be 差异。本节只定义逻辑组件及职责归属；具体写、管理和读规则分别在第 8-10 章定义。

![To-Be 应用组件与职责边界](diagrams/lead93-tobe-application-components.svg)

图中的组件名称表示逻辑职责，不要求必须新增同名代码类。正式接口地址、请求响应字段和错误语义以[接口约定](LEAD-93_API_Contract_Clarification_CN.md)为准。

| 逻辑组件 | 类型 | To-Be 职责 |
|---|---|---|
| Content Manager UI | Changed | Category 管理、Tag Group 多选、Metadata 编辑、Search/Filter、Working Copy 操作 |
| Adviser View | Changed | 只读取 Enabled + Active Published Template，并展示 Template 当前 Metadata |
| Template API / Controller | Changed | 保留现有 Template 命令入口，接入统一校验、目标 version 定位和 Template 当前 Metadata；写接口由后端 URL/Token 鉴权兜底，不能只依赖前端隐藏入口 |
| Template Facade API | Changed | 首次创建聚合写入 Master/V1/Metadata；已有 Template 聚合更新主信息和当前 Metadata，并写 Template Change History |
| Taxonomy API | New | Category CRUD/Reorder/Delete；Tag Group/Value 只读查询 |
| Template Command Orchestrator | Changed | 编排聚合创建、Save Draft、聚合更新、Publish、Version Delete、Template Delete、Active/Deactivate；业务可见主记录修改写历史 |
| Version Selector | Changed | 依据已确认矩阵定位或创建目标 V(N)，不由前端猜测 version |
| Metadata Service | New | 校验并写入 `config.category_id`、Template Subcategory/Tag relations，并生成完整前后快照 |
| Taxonomy Service | New | Category 两级规则、原子批量创建、排序、统一删除入口（影响评估/迁移并删除），以及 Tag Group/Value 有效性校验 |
| Validator | Changed | 区分 Template Metadata Update 与 Publish 的完整性规则；Metadata 可暂时不完整，Publish 才执行完整校验 |
| Repository / Mapper | Changed/New | 复用 config/version Mapper，新增 Category/Tag 字典及 relation Mapper |
| Scheduler / Preview / Attachment | Reused | Scheduler、Preview Renderer 和附件后端机制保持现状，仅接入已保存的 To-Be 数据 |


## 7. 数据模型与归属

本章按已确认方案设计：新增 Template 专用 Category 表 `iic_msg_email_category`。该表只承载 Email/Campaign Template taxonomy，不复用或改造其他业务模块的 Category 表。

### 7.1 数据库设计全景

**Jira Coverage：** LEAD-277、LEAD-293、LEAD-307、LEAD-300、LEAD-328

本节先用三种视角建立数据库设计直觉，再进入逐表字段和约束：

1. **改造范围全景图**回答哪些表复用、修改或新增。
2. **逻辑 ER 图**回答表之间通过哪些业务键关联，以及业务基数是什么。
3. **Template Metadata 与修改历史实例图**回答当前关系和历史快照如何配合，以及一对多关系如何完整记录。

#### 7.1.1 数据库改造范围

![LEAD-93 数据库改造范围全景](diagrams/lead93-db-change-landscape.svg)

颜色只表示数据库改造类型，不表示 Template 生命周期状态：灰色为 Existing/Reused，黄色为 Existing/Changed，蓝色为 New，紫色为 Migration Support。核心改造路径是 `Template Master → Current Metadata Relations → Template Change History`；Version 继续独立承载内容和生命周期，Migration Log 不参与运行时查询。

#### 7.1.2 To-Be 逻辑 ER 图

![LEAD-93 To-Be 逻辑 ER 图](diagrams/lead93-db-logical-erd.svg)

ER 图中的 `1:N`、`N:1` 表示业务基数，不表示数据库已经存在物理 FK。本方案明确不新增 FK/check constraint，图中虚线关系由 Service 层校验，并由业务事务保证一致性：

- `iic_msg_email_config.email_code` 与多个 version row 建立逻辑一对多关系。
- `iic_msg_email_config.copy_from_email_code` 是 Copy and Create 时写入 B 的 nullable 内部来源值；它不建立物理 FK，也不参与 A/B 的查询、状态或 Version 级联。
- `config.category_id` 指向当前主 Category；`iic_msg_template_category_rel` 按 `email_code` 保存多个当前 Subcategory。
- `iic_msg_email_category.id` 是 Category/Subcategory 唯一持久化标识；正式表、API 和历史快照均不保存 `category_code`。一次性 Mapping DML 以内嵌的 Category/Subcategory 名称查询并解析数据库 `id`，不使用 `seed_key`，也不创建临时表。
- `iic_msg_template_tag_rel` 按 `email_code` 保存当前多选结果；relation 冗余保存 `group_code`，Service 写入时校验它与 `iic_msg_tag_value.group_code` 一致。
- `version.file_keys` 仍是逗号分隔的现有附件引用，不在本期重构为标准关系表。
- Template Change History 保存 Template 每次业务修改的完整前后快照；Category Change History 保存每个 Category/Subcategory 节点的创建、修改、排序和删除快照；Category Delete Audit 保存一次删除操作的范围和结果；Migration Log 只保存一次性执行批次。四类记录均不参与 Template 列表、详情或 Search/Filter 主查询。

#### 7.1.3 Template 当前 Metadata 与修改历史实例

![LEAD-93 Template Metadata 与修改历史实例](diagrams/lead93-db-versioned-metadata-example.svg)

同一 `email_code` 始终只有一套当前 Category、Subcategory 和 Tag。Active V1、Draft/Schedule V2 共享这套 Template 当前属性；Save Draft、Publish、Cancel Schedule、Cancel 和 Version Delete 都不会复制、切换或删除 Metadata。

每次成功修改 Template 基本信息或 Metadata 时，后端读取修改前的完整聚合，完成当前表更新，再写入同一 `operation_id` 下的 `before_snapshot` 与 `after_snapshot`。Subcategory 和 Tag 这类一对多值在快照中使用数组保存，并同时记录 ID/Code 与当时显示名称，使后续 taxonomy Rename/Delete 不会改写历史含义。

#### 7.1.4 表变更总览

| 表 | 类型 | 用途 | 业务键/关联键 |
|---|---|---|---|
| `iic_msg_email_config` | Existing / Changed | Template Master、当前主 Category、Copy 来源追踪 | `email_code`, `category_id`, `copy_from_email_code` |
| `iic_msg_email_config_version` | Existing / Reused | Template Version / Content / Lifecycle | `email_code`, `version` |
| `iic_msg_file_upload` | Existing / Reused | S3 附件元数据 | `file_key` |
| `iic_msg_email_category` | New | Category/Subcategory taxonomy | `id`, `parent_id` |
| `iic_msg_template_category_rel` | New | Template 与当前 Subcategory 多选关系 | `email_code`, `subcategory_id` |
| `iic_msg_tag_group` | New | Tag 分组字典 | `group_code` |
| `iic_msg_tag_value` | New | Tag 值字典 | `group_code`, `tag_code` |
| `iic_msg_template_tag_rel` | New | Template 与当前 Tag Value 的多选关系 | `email_code`, `tag_code` |
| `iic_msg_email_template_change_history` | New | Template 基本信息和 Metadata 的不可变前后快照 | `operation_id`, `email_code` |
| `iic_msg_email_category_change_history` | New | Category/Subcategory 节点的不可变生命周期快照 | `operation_id`, `category_id` |
| `iic_msg_email_category_delete_audit` | New | Category/Subcategory 成功删除的操作级审计 | `operation_id` |

### 7.2 新增 `iic_msg_email_category`

该表是 Template Management 专用的两级 Category/Subcategory 字典。字段类型和索引仍需 DBA Review：

| 字段 | 用途 |
|---|---|
| `id` | 自增物理主键；config/relation 使用该 ID 关联 |
| `category_name` | Category/Subcategory 显示名称 |
| `parent_id` | Subcategory 所属 Category；一级节点为 `0` |
| `sort_order` | 同级排序 |
| `is_deleted` | `0 = 有效`, `-1 = 已软删除` |
| `created_by`, `created_date`, `updated_by`, `updated_date` | 创建与修改信息 |
| `deleted_by`, `deleted_date` | [LEAD-307](https://oldmutualig.atlassian.net/browse/LEAD-307) 明确要求的删除人和删除时间 |

节点层级由 `parent_id` 推导：`parent_id = 0` 为 Category，非 `0` 为 Subcategory。Service 层只允许两级结构，并校验 Subcategory 的 parent 是有效一级节点；数据库不新增 FK 或 CHECK constraint。

Service 层必须校验：

- 只允许两级结构。
- Subcategory 的 parent 必须为有效一级 Category。
- 有效 Category/Subcategory 的 `category_name` 在全部未删除节点中全局唯一；Service 在 Create/Update 前按 `LOWER(TRIM(category_name))` 查询校验，忽略大小写和首尾空格。数据库保留 `utf8mb4_bin` 字段定义，但不设名称归一化列或唯一约束。
- 删除时先锁定受影响 Template 当前关系；仅对存在 Active/Draft/Schedule version 的 Template 执行一次迁移，再在同一事务软删除源节点。一级 Category 同时软删除全部有效子节点；仅有 Expired version 的 Template 不迁移。
- 软删除节点不参与名称唯一校验，允许创建同名新节点；原 row 保留 ID、Name、删除人和删除时间，以满足 LEAD-307 Data Retention。

对应必交付 SQL：[DDL_iic_msg_email_category.sql](sql/required/DDL_iic_msg_email_category.sql)。

### 7.3 `iic_msg_email_config` 扩展与 Template Change History

在现有 Template Master 增加 `category_id` 保存当前主 Category，并增加 nullable `copy_from_email_code` 保存 Copy and Create 来源。`iic_msg_email_config_version` 不增加 Category/Tag 或 Copy 来源字段，继续只负责 Subject、正文、附件引用、生效时间和版本生命周期。

`iic_msg_email_category` 使用自增 `id` 作为唯一节点标识。运行时创建由数据库生成 `id`，前端不提交业务编码；一次性 Mapping DML 将批准的 Category/Subcategory 名称内嵌在自身 SQL 中，在同一次执行内查询并解析为数据库 `id`，不保存 `seed_key`，也不创建临时表。

| 表/字段 | 约束/说明 |
|---|---|
| `iic_msg_email_config.category_id` | 当前主 Category ID；可为空，Publish 时校验必填 |
| `iic_msg_email_config.copy_from_email_code` | nullable `varchar(100)`，与现有 `email_code` 类型/字符集一致；普通新建为 `NULL`，Copy 首次 Save Draft 时固定写 A 的 `email_code`，后续不可修改；不建 FK 或索引，不作为列表筛选和生命周期关联 |
| `iic_msg_email_template_change_history.operation_id` | 一次业务操作标识；Category 批量删除时关联操作级 Audit |
| `before_snapshot` / `after_snapshot` | 完整 Template 聚合 JSON；Create 可无 before，Delete 可无 after |
| `change_type` | `CREATE`、`BASIC_INFO`、`METADATA`、`STATUS`、`CATEGORY_REASSIGNMENT`、`DELETE` 等稳定业务类型 |

完整快照包含：`emailCode`、Template Name、Description、Email/Campaign 类型（`isCampaign`，来源为 `is_campaign`）、Channel/Channel Name、Custom Branding、`email_status`、软删除状态、Category、Subcategory 数组和按 Group 组织的 Tag 数组。不存在独立 `format` 快照字段。Subject、正文、附件、生效时间、Version Number 和 `version_status` 不进入该表，它们继续由 Version 数据表达。

```json
{
  "emailCode": "E10001",
  "templateName": "Welcome Email",
  "description": "...",
  "isCampaign": 0,
  "channel": "EMAIL",
  "channelName": "Email",
  "customBranding": "0",
  "emailStatus": 1,
  "status": 0,
  "category": {"id": "1001", "name": "Client Engagement"},
  "subcategories": [{"id": "1101", "name": "Advice Review"}],
  "tagGroups": [{"groupCode": "TRIGGER", "groupName": "Trigger", "values": [{"tagCode": "T01", "tagName": "Annual Review"}]}]
}
```

快照字段使用稳定业务名，不直接序列化整个 Entity/DTO，避免后续新增技术字段时无意扩大历史范围。现有表字段已确认为 `channel`、`channel_name` 和 `is_custom_branding`；历史快照分别保存 Channel Code、当时显示名称和 Custom Branding 值。

当前关系使用列和关系表，历史才使用 JSON，原因是两类数据的访问模式不同：当前值需要列表筛选、关联校验和批量迁移；历史值只需按 Template/时间回放，不参与运行时筛选。这样既避免在 JSON 上承担高频搜索，也避免为每次历史修改复制多张 history detail 表。

Category 生命周期使用独立 `iic_msg_email_category_change_history`，不混入 Template Change History：其快照固定包含 `id`、`parentId`、`categoryName`、`sortOrder`、`isDeleted`，Delete 后快照另含 `deletedBy` 与 `deletedDate`。Category 删除时，所有节点级 `DELETE` 记录、受影响 Template 的 `CATEGORY_REASSIGNMENT` 记录和一条 Delete Audit 使用同一个 `operation_id`；前两者用于逐条追溯，Audit 用于查看整次删除操作的汇总。

对应必交付 SQL：[DDL_iic_msg_email_config.sql](sql/required/DDL_iic_msg_email_config.sql)、[DDL_iic_msg_email_template_change_history.sql](sql/required/DDL_iic_msg_email_template_change_history.sql)、[DDL_iic_msg_email_category_change_history.sql](sql/required/DDL_iic_msg_email_category_change_history.sql)。

### 7.4 `iic_msg_template_category_rel`

用于一个 Template 关联多个当前 Subcategory。唯一性由 `email_code + subcategory_id` 保证。

在无 FK 情况下，写入前由 Service 校验 `email_code`、`config.category_id`、Category 层级和节点有效性。全量替换采用软替换：原有效关系更新为 `status=-1`，本次选中关系新增或恢复为 `status=0`。

对应必交付 SQL：[DDL_iic_msg_template_category_rel.sql](sql/required/DDL_iic_msg_template_category_rel.sql)。

### 7.5 Tag Taxonomy

| 分组 | 必填性 | 最大选择数 | Draft 默认值 |
|---|---|---:|---|
| Content Type | Mandatory | 不限制 | 可空 |
| Trigger | Mandatory | 5 | 可空 |
| Lifecycle Stage | Mandatory | 不限制 | 可空 |
| Financial Need | Mandatory | 不限制 | 可空 |

设计规则：

- `iic_msg_tag_group` 只保存分组、必填标记和排序；Trigger 最多 5 个是 Service 常量，不持久化为字典字段。
- `iic_msg_tag_value` 保存固定 Tag 值及可选 Description；`tag_code` 全局唯一。Description 来自批准后的 Tag Taxonomy 数据文件，并由只读 Taxonomy API 返回。
- `iic_msg_template_tag_rel` 按 `email_code` 保存当前选择结果，同一 Tag Group 可关联多个 Tag Value；relation 冗余保存 `group_code` 以支持筛选并减少额外解析。
- 同一 Template 和 Tag Value 不得重复；唯一性由 `email_code + tag_code` 保证。写入时必须校验 relation `group_code` 与 Tag Value 归属一致；删除使用 `status=-1` 软删除。
- 不提供 Tag 管理 UI。
- 首次上线固定 seed，后续仅允许 DB 脚本维护。
- Draft 缺失 Tag Group 时不补默认值，以零条 relation row 表示未选择；Publish 前校验 4 个 Mandatory Group 均至少存在一个选择。

Migration SQL 只为每个 `email_code` 写一套当前 Category/Subcategory/Tag，不再要求目标 `version`。一次性初始迁移只写 `iic_msg_template_migration_log`，不写 Template Change History；具体 mapping 数据仍待 `BUS-01`。

对应必交付 SQL：[DDL_iic_msg_tag_group.sql](sql/required/DDL_iic_msg_tag_group.sql)、[DDL_iic_msg_tag_value.sql](sql/required/DDL_iic_msg_tag_value.sql)、[DDL_iic_msg_template_tag_rel.sql](sql/required/DDL_iic_msg_template_tag_rel.sql) 及固定 Seed DML。

### 7.6 数据库约束策略

DBA 不允许新增 FK 和 check constraint，因此采用：

- DB：主键、普通索引、必要的唯一索引和软删除字段。
- Service：父子层级、枚举值、关系存在性、必填组、重复关系校验。
- Transaction：config 的 `category_id`、category relation、tag relation 和 Template Change History 必须原子提交。
- Migration Validation：上线脚本后检查孤儿关系、重复关系、缺失 Mandatory Tag 和无效 Category。


## 8. Taxonomy 与当前 Metadata

### 8.1 聚合写入与当前 Metadata

**Jira Coverage：** LEAD-301、LEAD-276、LEAD-278、LEAD-300

Category、Subcategory 和 Tag 是以 `email_code` 为粒度的 **Template 当前属性**，不属于内容 Version。数据库仍保持 Master/Version 解耦：`config.category_id` 保存主 Category，Subcategory 和 Tag 关系逐项落表，Template Change History 保存每次业务修改的前后快照。

| 操作 | 入口 | 当前关系行为 | 对 Version 的影响 |
| --- | --- | --- | --- |
| 首次创建并 Save Draft | EX-05 `/v2/add` | 与 config、V1 Draft 在同一事务写入完整 Metadata 快照 | Insert V1 Draft |
| 保存已有 Draft / Cancel Schedule | EX-05 `/v2/add` | 不接收、不修改 Metadata | 保持现有选版和状态规则 |
| 修改已有 Template 主信息与 Metadata | EX-06 `/v2/update` | 全量替换 `category_id`、Subcategory/Tag relations，并写 History | 不创建、不修改 Version |
| 批量重新分类 | NEW-11 `/v2/reassign` | 对每个 Template 全量替换当前关系 | 不创建、不修改 Version |
| Publish / Schedule 到点 | EX-16 / Scheduler | 只读取当前 Metadata 做校验 | 只切换 `version_status` |
| Cancel / Version Delete / Template Delete | 现有 Version/Template 命令 | Version Delete 不改当前 Metadata；Template Delete 保留关系供追溯 | 复用现有软删除语义 |

**EX-05 首次创建的事务顺序**

1. 校验主信息、Draft 内容、Category/Subcategory 层级、Tag Group/Value 和 Trigger 上限。
2. 生成 `email_code`，Insert `iic_msg_email_config` 和 V1 Draft。
3. 写 `category_id`、Subcategory relation 和 Tag relation。
4. 写 `CREATE` Template Change History。
5. 提交事务；任一步失败均回滚，前端不得得到可继续编辑的 `emailCode`。

Draft 可以暂时不选 Category 或 Tag，但首次创建仍必须在同一个请求中携带完整 Metadata **快照**（允许 `categoryId=null` 和空数组）。这样保留“Draft 可不完整”的业务规则，同时消除两步调用造成的孤儿草稿。

**EX-06 聚合更新规则**

1. 以 `emailCode` 定位已有 Template；请求同时携带 `emailName`、`description`、`categoryId`、`subCategoryIds` 和全部 `tagGroups`。
2. 校验名称、Category/Subcategory 层级、Tag 有效性、Tag Group 完整性和 Trigger 上限；聚合全部可同时发现的字段错误。
3. 在一个事务中更新 config 主字段和 `category_id`，全量替换关系表，写一条完整 before/after Change History。
4. 不接收 `version`，不改 Subject、正文、附件、生效时间和 `version_status`。Published Template 修改 Category/Subcategory 后仍保持 Published。

![To-Be Template Metadata 写入](diagrams/lead93-tobe-template-reassignment.svg)

Tag 多选以分组 JSON 传输、关系表逐项存储，支持 Tag Name Search、跨 Group AND、同 Group OR/ANY、字典归属校验和关系唯一性。历史快照以数组保存 `{category, subcategories, tagGroups}`，只用于追溯，不作为 Search/Filter 数据源。

### 8.2 Category/Subcategory 与 Tag Taxonomy 管理

**Jira Coverage：** LEAD-293、LEAD-307、LEAD-300

Category/Subcategory 由 Content Manager 在管理页面维护；Tag Group/Value 不提供运行时写 API，只读 Taxonomy API 返回固定 Seed，后续只通过受控 DB 脚本维护。

![To-Be Category 与 Tag Taxonomy 管理边界](diagrams/lead93-tobe-taxonomy-management.svg)

**Category/Subcategory 管理规则**

- 只允许两级：一级 `parent_id=0`，二级必须归属有效一级 Category。
- Name 必填、纯文本、最长 100 字符；归一化后在整个 Template taxonomy 内全局唯一。
- 单个 Category 使用 Create/Update，Subcategory 支持 1-5 条原子批量创建；任一项不合法时整个批次不创建。
- Reorder 一次提交同一 parent 下全部有效节点，后端在事务内锁定、校验集合并写连续 `sort_order`；并发过期时要求前端重新加载。
- Create、Update、Reorder、Delete 都写 `iic_msg_email_category_change_history`；批量操作共享 `operation_id`。

**统一删除入口（NEW-12）**

`POST /v2/category/delete` 是唯一删除接口，不再拆分 Direct Delete、Delete Impact 与 Reassign-and-Delete Endpoint：

1. 前端首次只提交 `sourceCategoryId`。后端锁定源节点并重新判断 Active/Draft/Schedule 的有效引用。
2. 无有效引用时，在当前事务直接级联软删除源节点；仅 Expired 或已软删除 Template 不阻止删除，也不迁移。
3. 存在有效引用时不写库，返回 `CATEGORY_IN_USE` 与 `data.reassignRequired=true`、`data.affectedTemplateCount`；该数值仅用于前端提示，不是删除许可。
4. 前端确认迁移后以同一 Endpoint 重提 `sourceCategoryId`、`targetCategoryId` 和 `targetSubcategoryIds`。`targetCategoryId` 不得等于源节点、不得位于源节点子树内；违反时返回 `INVALID_MIGRATION_TARGET`。后端重新锁定源、目标和受影响 Template，迁移当前 Metadata、逐 Template 写 Change History、软删除源节点并写 Category Change History/删除审计，最后一起提交。
5. 目标不存在、已删除或层级不匹配时返回 `CATEGORY_TARGET_INVALID`；两次请求之间引用或节点发生变化时返回 `CATEGORY_CONCURRENT_MODIFICATION`。任一 relation、history、audit 或软删除失败均回滚；不修改 Tag 或任何 `version_status`。

![To-Be Category/Subcategory Delete 实现设计](diagrams/lead93-tobe-category-delete-design.svg)

### 8.3 Tag Group/Value 管理

| 能力 | To-Be 设计 |
| --- | --- |
| Tag Group | 固定 4 个 Mandatory Group |
| Tag Value | 只能从预定义字典选择；`tag_code` 全局唯一并归属一个有效 Group |
| Template Assignment | 每个 Group 可多选；当前关联按 `email_code + tag_code` 唯一，冗余保存 `group_code` 并校验归属 |
| 选择数量上限 | Trigger 最多 5 个，由 Service 校验并由 Taxonomy API 返回 |
| 管理页面 | 本期不提供 Tag Group/Value 管理 UI |
| 运行时 API | 新增只读 Tag Taxonomy API；单模板更新归入 EX-06，批量更新使用 NEW-11 |
| 首次初始化与后续维护 | 由受控、幂等 DB 脚本维护；不提供运行时 CRUD |
| Draft 空值 | 任意 Group 可为空；不生成默认 Tag relation；Publish 再校验 4 个必填组 |

## 9. Template 写模型与生命周期


### 9.1 Save Draft 目标版本定位与写入规则

**Jira Coverage：** LEAD-306、LEAD-278、LEAD-279

本节对应第 3.6 节 As-Is Save Draft 数据库行为，并由第 5.2.1 节说明需求差异。To-Be 完整保留现有目标版本选择、Insert/Update 和状态变化规则。Category/Subcategory/Tag 是 Template 当前属性，不属于 Version：**首次创建**时由 EX-05 与 config/V1 Draft 聚合写入；已有 Template 的 Save Draft 不接收、不修改 Metadata。Save Draft 若实际新增或修改 config 基本信息，仍要写 `CREATE` 或 `BASIC_INFO` Template Change History。

新模板首次 Save Draft 时由后端生成全局唯一 Snowflake `email_code`；前端不得生成。Published 页面不提供 Edit 操作；进入其他合法编辑流程不写数据库，只有首次 Save Draft 才持久化 Working Copy。

| 持久化现状 | Version 写入 | 状态结果 | Template Metadata 影响 |
|---|---|---|---|
| 尚无 version | Insert V1 | V1 Draft (`3`) | EX-05 同事务写入当前 Category/Subcategory/Tag 快照并写 `CREATE` History；失败整体回滚 |
| Draft 已存在，包括 Active + Draft | Update 当前 Draft | 保持 Draft (`3`) | 不修改 Category/Tag；config 基本信息有变化时写 `BASIC_INFO` History |
| Active、无 Draft | Insert V(N+1) | 新 Draft (`3`)，Active 保持 (`1`) | 不复制 Category/Tag；config 基本信息有变化时写 History |
| 仅 Expired、无 Draft | 保留最大数字版本 V(N)，Insert V(N+1) | V(N) 保持 Expired (`2`)；V(N+1) 为 Draft (`3`) | 不复制 Category/Tag；config 基本信息有变化时写 History |
| Schedule 存在 | Update Scheduled V(N) | 同一 version `0 → 3` | 不修改 Category/Tag；config 基本信息有变化时写 History |

Expired 分支不复用或改写旧 V(N)，而是新建 V(N+1) Draft；Schedule 分支复用 V(N) 并保留原 `effective_from/effective_until`。即使 `effective_from > now`，Save Draft 也不会自动生成 Schedule。正常页面在已有 Draft 或 Schedule 时禁止再次创建 Draft；现有后端不新增相同约束。

### 9.2 生命周期命令与统一写入管线

**Jira Coverage：** LEAD-306、LEAD-278、LEAD-279、LEAD-296

所有 Template 写命令都遵循同一处理管线：识别命令、读取最新持久化状态、定位目标 version、执行命令级校验、在事务中写入目标表，最后提交或整体回滚。Version 命令与 Template Metadata 命令分别持有自己的事务边界。

![To-Be 统一写命令管线](diagrams/lead93-tobe-write-command-pipeline.svg)

| 命令 | 前置条件/目标 | Version 状态写入 | Master/Relations 写入 | 结果与边界 |
|---|---|---|---|---|
| Save Draft | 按 9.1 矩阵定位目标 version | 结果为 Draft (`3`) | 首次创建时聚合写 Master/V1/Metadata；已有 Template 按现有逻辑更新 Master/Version，不写 Metadata；Master 有变化时写 History | Future time 只保存，不生成 Schedule |
| Publish Now | 目标为有效 Draft | 旧 Active `1 → 2`；目标 Draft `3 → 1` | 读取当前 Metadata 校验，不复制、不更新 | `effective_from <= now`；校验和状态切换原子完成 |
| Publish Future | 目标为有效 Draft | 目标 Draft `3 → 0` | 读取当前 Metadata 校验，不复制、不更新 | `effective_from > now`；旧 Active 到点前保持 |
| Schedule → Save Draft | 目标为 Scheduled V(N) | `0 → 3` | 不修改 Metadata | 保留 `effective_from/effective_until` |
| Version Delete | 明确目标 Draft/Schedule version | 不修改 `version_status`；version `status → -1` | 不修改 Metadata relations | Published Working Copy Cancel 和 Scheduled Delete 复用此命令 |
| Deactivate | 逻辑 Template 存在 | 不修改 version row | `config.email_status: 1 → 0`；写状态变更历史 | Active version 保留，仅从可见范围排除 |
| Active/Reactivate | Disabled Template 存在 | 不修改 version row | `config.email_status: 0 → 1`；写状态变更历史 | 不重新执行 Publish Validation |
| Template Delete | 明确逻辑 Template | 不修改 `version_status`；config/version `status → -1` | 保留当前 relations，写删除历史 | 沿用主记录级联软删除语义 |

Publish 只有在命令执行时才根据 `effective_from` 决定立即 Active 或 Schedule。发布校验读取 `email_code` 对应的 Template 当前 Category/Subcategory/Tag；状态切换不会生成 Metadata 历史，除非同一请求实际修改了 Template 当前字段。

上表的旧 Active `1 → 2`、目标 Draft `3 → 1` 是已确认的 As-Is 和 To-Be，不表示覆盖或删除旧 Version row。版本编辑器可以展示按 `email_code` 读取的 Template 当前 Metadata，但不得把该数据标记或暗示为所选历史 Version 的 Metadata 快照；本期不实现物理 row 替换或历史 Metadata 绑定。

首次发布时没有旧 Active：同一 V1 只执行 `version_status: 3 → 1`，不 Insert V2 或额外历史 row。发布完成后，该 V1 作为 Active 版本进入现有 Version History 查询结果；“产生历史记录”指现有版本记录可被历史页面查询，不表示复制一条新的数据库版本。

`changeVersionStatusByEffectiveFrom()` 继续负责 Scheduled version 到点生效，本期不修改其调度逻辑。上线前仅通过现有测试、日志或黑盒用例验证状态结果；回归失败时再依据真实代码差异评审改造范围。

#### 9.2.1 Cancel 与 Working Copy

Cancel 是前端业务动作，不新增 `/cancel` API：

| UI 情况 | 后端处理 | 保留内容 |
|---|---|---|
| 编辑页面尚未 Save Draft | 只丢弃客户端内容，不调用后端 | 全部持久化数据 |
| Published + 已持久化 Working Copy | 复用 Version Delete 软删除 Draft version | Active version、Template 当前 Metadata、主表字段和附件对象 |
| 新建且从未 Published 的 Draft | 页面不提供 Cancel；删除时复用 Template Delete | 不增加专用处理 |
| Schedule | 使用 Save Draft `0 → 3` 或 Version Delete | 旧 Active 保持 |

`email_name`、`description`、`is_campaign` 是主表字段，Cancel 已保存 Working Copy 不回滚这些已经独立持久化的修改。

Copy and Create 不是 Cancel 或 Working Copy 的分支，也不复用 `/version/add`，其独立创建规则见 9.2.2。

#### 9.2.2 Copy and Create

Copy and Create 创建与来源 A 完全独立的新 Template B。来源只能是 A 的当前最新 Published/Active Version；Expired、Draft 和 Schedule 不能作为来源。点击 Copy and Create 时，前端加载并预填全部可编辑数据，不调用写接口；用户首次点击 Save Draft 时调用新增 v2 Copy API。

| 数据范围 | B 的创建规则 |
|---|---|
| Template 主记录 | 后端生成新 `email_code`；复制并允许提交前编辑 Template Name、Description、Channel 和 Custom Branding；`is_campaign` 不由页面/API 提交，后端固定写 `0`；默认名称为原名称加 `(Copy)` |
| Version 内容 | 创建独立 `V1 Draft`；复制 Email Subject、正文、`edit_mode`、缩略图和附件 `file_keys`；不复制来源的 version 编号、状态、生效时间和发送统计 |
| 当前 Metadata | 复制并允许提交前编辑主 Category、全部 Subcategory 和全部 Tag；只保存当前仍有效的 Category/Tag ID |
| 附件 | B 的 V1 复用同一组 S3 `file_keys` 引用；不复制 S3 对象，也不新增附件上传记录 |
| 来源追踪 | B 的 `copy_from_email_code` 固定保存 A 的 `email_code`；普通新建为 `NULL`。该字段只支持管理端发布前提醒，不形成可导航、可筛选、可级联的 A→B 业务关系 |
| 历史 | B 只写自己的 `CREATE` 修改历史，不继承 A 的 Version History 或 Template Change History；`copy_from_email_code` 不扩展为独立关系表或历史版本关系 |

B 首次 Save Draft 成功后，管理端 Detail 返回 `copyFromEmailCode`。B 点击 Publish 时，前端在调用普通 Publish API 前显示非阻断确认框，说明发布 B 不会自动停用 A；用户可取消或继续发布。继续发布不增加确认字段、不调用新的后端接口，也不要求 A 已停用。A 是否停用由 CM 通过现有 Deactivate 操作独立决定。

B 的 Save Draft、Publish、Schedule、Deactivate、Delete 和 Version History 与普通 Template 完全一致。`copy_from_email_code` 不参与选版、Version Conflict、旧 Active 过期、Advisor 可见性或 Template Delete 级联。

新增 Copy API 必须在单一数据库事务内完成：重新确认来源仍为当前最新 Active → 校验 B 的 Draft 字段和 Template Name 唯一性 → Insert B config → Insert B V1 Draft → Insert B 的 Subcategory/Tag relations → Insert B CREATE History。任一步失败均整体回滚，不允许留下只有 config 或只有 version 的半成品。默认名称重名时返回字段错误，由用户修改后重试；后端不自动生成 `(Copy 2)`。A 在整个事务中只读，状态、内容、Metadata 和附件引用均不得被修改。


### 9.3 统一校验设计

**Jira Coverage：** LEAD-277、LEAD-306、LEAD-300、LEAD-279、LEAD-326

Validator 按命令类型执行不同完整性规则，不能把 Publish 的严格校验提前应用到 Save Draft。EX-06 以 `email_code` 为唯一业务目标，同时更新主信息和当前 Metadata，不依赖 Draft/Schedule/Active 的 Version 状态；Metadata 可以暂时不完整，Publish 时再执行严格校验。

历史 Active Template 不享受发布兼容豁免：重新 Publish 必须读取已持久化 Template 当前值和目标 Version 内容，重新执行完整 Published Validation。缺少 PRD v2.0 新必填 Metadata 的历史数据必须补齐后才能重新发布。

| 校验项 | Save Draft / 首次创建 | EX-06 主信息与 Metadata 更新 | Publish Now/Future |
|---|---|---|---|
| Template Title (`config.email_name`) | 必填；最长 120 字符；字符白名单 | 必填；最长 120 字符；字符白名单；当前主 Category 内唯一 | 必填；最长 120 字符；字符白名单；同一主 Category 内唯一 |
| Description (`config.description`) | 可空 | 可修改；Draft 可空 | 必填 |
| `is_campaign`（内部字段） | 新建固定写 `0`；已有 Template 保持原值 | 不由页面/API 提交或修改 | 不由页面/API 提交或校验 |
| 主 Category | 首次创建接收；可为空，非空时必须是有效一级 Category；已有 Save Draft 不接收 | 可为空；非空时必须是有效一级 Category | 必须是有效一级 Category |
| Subcategory | 首次创建接收；可空，非空时全部属于主 Category；已有 Save Draft 不接收 | 可空；非空时全部属于主 Category | 至少一个且全部属于主 Category |
| 4 个 Mandatory Tag Group | 首次创建接收；可空；Trigger 最多 5 个；已有 Save Draft 不接收 | 可空；Trigger 最多 5 个 | 每组至少一个有效 Tag Value；Trigger 最多 5 个 |
| Email Subject / 正文 | 可暂不完整 | 不修改；属于 Version 内容 | 按 PRD 完整性校验 |
| `effective_from` | 可暂存但不改变状态 | 不涉及 | Publish 时决定 Now/Future |
| 附件 | 可选；前端校验 | 不涉及 | 可选；前端校验 |

公共校验顺序为：请求 Schema → 目标 Template/version 存在性 → 当前状态是否允许该命令 → Taxonomy 有效性和归属 → 命令级完整性。任何 Publish 校验失败都必须在数据库写入前返回失败字段数量和字段级错误，本次页面内容不保存到 Draft，config、version 和 history 均不写入；原 Draft 与旧 Active 保持原数据库状态。同组重复 `tag_code`、无效 Category/Tag、Subcategory 跨父节点或目标对象不存在也不得产生部分更新。

所有 Web v2 业务失败通过现有 `IICResponseModel` 返回 HTTP 200。普通失败只返回 `responseCode/responseMessage/data=null`；EX-05、EX-06、EX-16、NEW-08、NEW-11 的可定位校验失败通过 `data.fieldErrors[]` 与 `invalidFieldCount` 返回。`responseCode` 继续使用平台既有错误码并由 QA 登记实际值，前端不得以 `responseMessage` 文本分支。字段错误使用请求 JSON 路径定位控件，例如 `emailName`、`subCategoryIds[1]`、`templates[0].categoryId`；EX-06 的 Subcategory 不属于当前主 Category 时使用 `field="subCategoryIds"`，业务语义为 `INVALID_SUBCATEGORY_BELONGING`。事务/并发错误不暴露 SQL 或内部异常。完整逐接口错误清单见 [API Contract 第 7 章](LEAD-93_API_Contract_Clarification_CN.md#7-业务失败响应约定)。

Title 字符白名单为英文字母、数字、空格及 `- , . & ' ’`，Copy and Create 额外允许系统生成的固定结尾 ` (Copy)`；其他位置的括号仍拒绝，任何 HTML 标记、换行和 `@ # $ %` 均拒绝。Title 必须非空且最长 120 字符。Category 已选择时，EX-05 首次创建、EX-06 更新和 Publish 均检查 Title 在同一主 Category 下是否被其他未软删除且存在 Active/Draft/Schedule version 的 Template 使用；比较时排除当前 `email_code`，仅 Expired 历史 Template 不构成冲突。该比较规则由 Service 实现，数据库不增加名称归一化列或唯一约束。

Trigger 上限按去重后的 `tag_code` 数量计算。超过 Service 常量 `5` 时，EX-05 首次创建、EX-06 更新和 Publish 均在写库前返回字段级错误，不截断、不部分保存；其他 Group 当前不设置数量上限。

Preview 不执行 Publish 状态更新，也不持久化请求内容。它复用现有 Renderer 展示正文和 Metadata；附件不进入 Preview。

### 9.4 事务、失败与并发边界

**Jira Coverage：** LEAD-277、LEAD-307、LEAD-279、LEAD-296

| 命令 | 同一数据库事务内必须完成的写入 | 失败保证 |
|---|---|---|
| Save Draft | 首次创建：生成 emailCode、config、V1 Draft、Category/Subcategory/Tag relations 与 `CREATE` History；已有 Template：config/目标 version 与必要 History | 首次创建任一写入失败整体回滚；已有 Template 不修改当前 Metadata |
| Template Master + Metadata Update | config 当前字段和 `category_id`、Subcategory/Tag 全量替换及一条 Template Change History | Update 影响 0 行、任一 relation 或 history 写入失败时整体回滚 |
| Publish Now | 旧 Active 过期、目标 Draft 生效 | 旧 Active 必须保持在线直到事务成功提交 |
| Publish Future | 目标 Draft 转 Schedule | 校验或写入失败时仍保持 Draft |
| Version Delete | 目标 version 软删除 | 不修改 Template 当前 Metadata；目标不匹配或影响 0 行时返回失败 |
| Template Delete | config、全部 version 软删除和一条 Template Change History | relations 保留；任一写入失败时整体回滚 |
| Batch Subcategory Create | 校验 1-5 条输入并批量创建全部节点 | 任一名称/层级/Insert 失败时整批回滚，不返回部分成功 |
| Category Delete（统一 NEW-12） | 首次请求锁定并评估；无引用直接软删除；有引用时重提目标并锁定源/目标/受影响 Template、迁移当前 Metadata、写 History/Audit 后软删除 | 任一 Template、relation、History、Audit 或软删除失败时整体回滚；仅 Expired 的 Template 不迁移 |
| Copy and Create | Insert 新 config（含 `copy_from_email_code=A`）、V1 Draft、Subcategory/Tag relations 和一条 Template CREATE History | 来源不是当前最新 Active、名称冲突、Metadata 失效或任一 Insert 失败时整体回滚；来源 A 不修改；来源字段不得在后续普通 Update 中被覆盖 |

附件对象上传和 S3 生命周期不属于上述数据库事务；只有附件上传成功后才保存 `file_keys`。Cancel、Version Delete 和 Publish 成功后均不新增 S3 物理清理。

![To-Be Publish Failure、Retry 与并发边界](diagrams/lead93-tobe-publish-failure-retry.svg)

- Validation Failure 发生在业务写入前，返回失败字段数量和字段级错误；本次页面修改不保存，原 Draft/旧 Active 保持原数据库状态，不创建 Version History 条目。
- Transaction Failure 必须回滚全部数据库写入；Retry 重新读取最新持久化状态并重新执行 Validation，不能直接重放旧事务。
- 现有代码存在 Version Conflict 失败路径，但其比较基线、触发命令、检测时点和真实错误码尚未完成专项核实；本期不新增乐观锁字段、revision token、编辑锁、Redis lock 或 `requestId`，也不以推测行为编写验收用例。
- Category Delete 与 Category/Metadata 写入使用数据库 row lock 和固定锁顺序保护 Taxonomy 引用；统一 NEW-12 的 Impact 结果不是删除许可，重提时仍必须复核，不代表新增 Template 编辑锁。
- 每次 Template 基本信息、Metadata、启停或删除成功都写 Template Change History。每次 Category/Subcategory 创建、修改、排序或删除成功都写逐节点 Category Change History。Category/Subcategory 成功删除还必须在同一事务写入 `iic_msg_email_category_delete_audit`，并继续维护业务节点的 `deleted_by/deleted_date`。



## 10. 查询设计

### 10.1 Category Tree 与 Taxonomy 查询

用户进入 Template Library 后，先读取 Category Tree 和 Tag Taxonomy，用于左侧目录、Filter Panel 和列表中的 Tag 显示。

![Template Library 分类树与标签字典读取流程](diagrams/lead93-taxonomy-read-flow.svg)

Category Tree 读取有效节点，并返回 `publishedTemplateCount`：按 `is_deleted=0, parent_id, sort_order, id` 排序后一次取全量，在 Java 以 `id/parent_id` 组装两级 `children`。数量按 Adviser `emailName` 与 Tag 条件、唯一 `email_code` 计算；不受 Category/Subcategory 选择影响。现有 `idx_email_category_tree (is_deleted, parent_id, sort_order)` 已覆盖树节点读取路径；数量查询复用 Published 候选集，不能按父节点逐层查询。

Tag Taxonomy 独立读取固定 Group/Value；列表 `tagMap` 只返回 Tag Code，显示名称由前端已加载的 Taxonomy 映射，不在每页列表中重复 Join Tag Value。

### 10.2 Template List 查询

**Jira Coverage：** LEAD-300、LEAD-327

列表查询固定遵循四步，先选出本页唯一的 Template Key，再补充多值 Metadata。Published、Draft、Adviser 的差异只发生在第一步的范围和 Version 选择规则；不会改变后续分页和组装方式。

```text
1. 确定范围和结果 Version
2. 叠加 Search / Filter 条件
3. Count + 分页查本页 Key
4. 批量补充主数据、Subcategory、Tag，并组装 DTO
```

#### 10.2.1 第一步：确定范围和结果 Version

本期 Web Template Library 不交付 Campaign 管理或筛选入口。Adviser `queryList` 为保持 v1 请求兼容，前端必须传 `isCampaign=0`，后端拒绝其他值并固定追加 `config.is_campaign = 0`；CM `templateList` 复用 UMS 的既有权限范围和筛选语义。两个列表均保持 Email-only，响应 DTO 不返回 `isCampaign`。

| 页面范围 | 查询规则 | `result_version` |
|---|---|---|
| Published / Adviser | Published 使用现有 Published 状态条件；Adviser 后端强制 Published-only，不允许请求参数绕过 | 当前 Active Version |
| CM 权限模板列表 | 复用现有 Draft Tab 多分支条件，不简化为 `version_status = 3`。保留 UMS 的 `keyWords/templateStatus/channelList/emailStatusList/sortField/isAsc` 语义，并追加 Metadata Filter；该权限模板列表由 UMS 服务提供范围，`templateList` 的 v2 参数与查询改造须在 UMS 代码库实现，消息中心不复制权限筛选逻辑。 | 由现有 Draft 选版规则确定 |

#### 10.2.2 第二步：叠加 Search / Filter 条件

- Category、Subcategory、Tag 与列表关键字之间使用 AND；同一 Subcategory 或同一 Tag Group 内多选使用 OR/ANY。Adviser 使用 v1 字段名 `emailName`，CM 使用 v1 字段名 `keyWords`。
- Subcategory 和 Tag Filter 使用 `EXISTS`。每个已选 Tag Group 生成一个 `EXISTS`，从而保证跨 Group 为 AND，且不放大 Template 行数。
- Global Search 的字段范围、组合规则和未定义边界见 [10.2.6](#1026-全局搜索关键词条件)。

#### 10.2.3 第三步：Count 与分页 Key

- `selectPageKeys` 先按前两步产生候选集，返回唯一的 `email_code + result_version`，再按现有 Tab 语义排序并以 `email_code` 作为稳定末级排序键分页。
- `countPageKeys` 必须复用完全相同的范围和条件，仅将最终输出改为 `COUNT(*)`。
- 现有 API 保留 `pageNum/pageSize/totalCount`，因此本期使用 Offset 分页；数据量增长且产品允许变更分页 Contract 时，再评估 Cursor 分页。

#### 10.2.4 第四步：批量补充并组装列表数据

| Mapper 查询 | 读取内容 |
|---|---|
| `selectSummariesByPageKeys` | 本页 Template 主数据、结果 Version 与主 Category |
| `selectSubcategoriesByEmailCodes` | 本页全部 Subcategory |
| `selectTagsByEmailCodes` | 本页全部 Tag Code，按 `email_code + group_code` 组装 `tagMap` |

后三个查询只针对本页 `email_code IN (...)` 批量执行；Java 按 `email_code` 分组，并按第三步 Key 的顺序恢复 DTO。禁止按 Template 循环查 Subcategory 或 Tag，也不使用 `GROUP_CONCAT`、JSON 聚合或大 Join 拼接多值关系。

#### 10.2.5 典型场景：Published List 按分类、Tag 和关键字查询

![Published List 分页与 Tag 批量查询](diagrams/lead93-published-list-query-example.svg)

用户在 Published Tab 输入：主 Category `1001`、Subcategory `1101/1102`、Content Type=`CONTENT_TYPE_EMAIL`、Trigger=`TRIGGER_ANNUAL_REVIEW` 或 `TRIGGER_REVIEW`、`emailName=retirement`，请求第 2 页、每页 20 条。

**第一步：只查询本页 Template Key。** Mapper 先固定 Published 范围：`config.status=0`、`config.email_status=1`、`config.is_campaign=0`、`version.status=0`、`version.version_status=1`。再叠加下列条件：

```text
config.category_id = 1001
AND EXISTS (subcategory_id IN [1101, 1102])
AND EXISTS (group=CONTENT_TYPE AND tag_code=CONTENT_TYPE_EMAIL)
AND EXISTS (group=TRIGGER AND tag_code IN [TRIGGER_ANNUAL_REVIEW, TRIGGER_REVIEW])
AND (email_name / active title / description / tag_name matches "retirement")
```

该查询只返回唯一的 `email_code + result_version`，按既有列表排序字段和 `email_code` 排序，再执行 `LIMIT 20 OFFSET 20`。`countPageKeys` 复用相同范围和全部条件，只将最终输出改为 `COUNT(*)`。

**第二步：批量补充本页数据。** 对第一步的最多 20 个 Key，一次查询 Template 主数据、结果 Version 和主 Category；再分别以 `email_code IN (...)` 查询 Subcategory 与 Tag。Java 按 `email_code` 分组，形成 `subCategoryIds/subCategoryNames` 与 `tagMap`，最后按第一步 Key 的顺序返回。

**为什么不能一条大 Join。** 假设某 Template 同时命中 2 个 Subcategory、2 个 Trigger Tag，则 `category_rel × tag_rel` 会生成至少 4 行相同 Template。若在这个结果上分页，用户可能在一页看到重复 Template，另一个 Template 被挤到下一页，`totalCount` 也会错误。`EXISTS` 负责“是否匹配”，本页批量查询负责“返回哪些多值数据”，两者不能混用。

#### 10.2.6 全局搜索：一个文本条件，叠加当前筛选

**需求来源：** LEAD-327 的 Global Search 用户旅程、AC2（匹配范围与部分匹配）和 AC7（Search 与 Filter 使用 AND 组合）。

![全局搜索与筛选的查询逻辑](diagrams/lead93-global-search-query-logic.svg)

| 关键规则 | 结论 |
|---|---|
| 接口与范围 | 列表关键字不是独立 API：Adviser `queryList` 使用 `emailName`，CM `templateList` 使用 `keyWords`。两者都只在当前 Tab 已有的选版结果内搜索，不改变 `result_version`。 |
| 匹配内容 | Template Name、结果 Version 的 Email Subject、Description、当前 Template 的 Tag Name。输入 `ret` 必须命中 `Retirement Planning`。 |
| 不匹配内容 | Category/Subcategory Name、附件、Tag Code、Version History、Change History。 |
| 与 Filter 组合 | Keyword 与 Category/Subcategory/Tag/Status 取 AND；结构化 Filter 维持“跨维度 AND、同维度 OR/ANY”。 |
| 空输入与无结果 | `null`、空字符串或空格不附加搜索条件；无命中返回空列表与 `totalCount=0`，不是业务错误。 |

**实现约束。** `selectPageKeys` 与 `countPageKeys` 必须复用同一个关键词条件；Tag Name 用 `EXISTS` 匹配有效 relation 和 Tag Value，不能 Join 到列表主结果。输入先 `trim`，并将 `%`、`_`、`\\` 作为普通字符转义后绑定参数。

**性能结论。** 为满足 AC2 的部分匹配，关键字采用 `LIKE '%value%'`；普通 B-Tree 无法优化前置 `%`。先使用 UMS 管理态、Category、Tag 等条件缩小候选集，发布前以真实数据执行 `EXPLAIN ANALYZE`；未证明存在瓶颈前，不增加 Fulltext、搜索服务或缓存。

**待确认。** PRD 未定义多个词是完整短语还是拆词 AND、是否忽略大小写。开发前需由业务确认，Mapper 不自行决定。

### 10.3 Version 内容与 Template Metadata 选择

用户从列表进入详情、Version History 或 Preview 时，后端按下列规则分别读取内容和 Metadata。

**一句话规则：** 先选择要展示的内容 Version；再用同一个 `email_code` 读取一套当前 Category、Subcategory 和 Tag。内容跟着 Version 走，Metadata 不跟着 Version 走。

![内容 Version 与当前 Metadata 的读取方式](diagrams/lead93-read-model-boundary.svg)

```text
key = selectResultVersion(request)              // emailCode + resultVersion
content = findVersion(key.emailCode, key.resultVersion)
metadata = findCurrentMetadata(key.emailCode)   // Category + Subcategory + Tag
return assemble(content, metadata)
```

| 场景 | `resultVersion` 从哪里来 | Metadata 从哪里来 |
|---|---|---|
| Published / Adviser | 当前 Active Version | 同一 `emailCode` 的当前 Metadata |
| Draft / Admin | 现有 Draft/Schedule/Disabled 选版规则 | 同一 `emailCode` 的当前 Metadata |
| Detail / History | 当前 Active 或用户指定的 Version | 同一 `emailCode` 的当前 Metadata；History 页面不得把它标为历史 Version 快照 |
| Preview | 当前页面输入，不持久化 | 当前页面输入，不持久化 |

因此 Search/Filter 也必须先保持 Tab 的选版语义，再按 `emailCode` 使用当前 Metadata 过滤；Category/Tag relation 不能反过来决定结果 Version。

## 11. 实施影响与 API 摘要

完整接口地址、字段模型和错误语义见[LEAD-93 接口约定](LEAD-93_API_Contract_Clarification_CN.md)。本章只保留能力变更摘要，避免在两份文档中重复定义。

**Jira Coverage：** LEAD-277、LEAD-293、LEAD-306、LEAD-307、LEAD-301、LEAD-276、LEAD-278、LEAD-300、LEAD-279、LEAD-296、LEAD-326、LEAD-327

### 11.1 API 变更摘要

下表中的 Web 接口均由 v2 提供；Mobile App 不属于本期交付，继续保持既有 v1 行为而不接入 LEAD-93 新能力。Deactivate、Update Master、Get Max Version、Version History 和 Channel List 通过 v2 路由复用现有 Service 行为。

| 能力 | As-Is | To-Be API 变更 | 兼容策略 |
|---|---|---|---|
| Published List | 现有硬编码排除 `is_campaign=1` | 固定 `is_campaign=0`，增加 Category/Tag/Search 参数 | 保持 Email-only 和原 config/version 状态条件 |
| Draft List | 现有多分支查询 | 固定 `is_campaign=0`，增加 Category/Tag/Search 参数 | 复用原 Base Query；Version 返回内容，Template 返回当前 Metadata |
| Save Draft / Create Template | 无 version Insert V1；Draft Update；Active 或仅 Expired 且无 Draft时 Insert V(N+1)；Schedule 复用 V(N) 并转 Draft且保留时间 | 首次创建通过 EX-05 聚合写入主信息、V1 Draft 和 Metadata；已有 Template 不接收 Metadata | 不改变现有版本选择逻辑；一个 Draft 仍由前端限制 |
| Publish | 原 `/add` 同时承载保存和发布语义 | 新增独立 `EX-16 /v2/publish`，增加 Category/Tag 发布校验 | 状态流转保持不变；`/v2/add` 只保存 Draft |
| Scheduled Version Save/Delete | Save Draft 执行同一 version `0 → 3` 并保留时间；Version Delete 将 Scheduled row 软删除 | 两条路径均不修改 Template 当前 Metadata；不新增独立 Cancel Schedule API | 不修改旧 Active，不新增 version |
| Deactivate | 更新 `email_status` | 无核心变更 | 保持现状 |
| Delete | config/version 软删除 | 保留 Subcategory/Tag relations并写 Template 删除历史 | 不修改 `version_status` |
| Category | 无 Template 两级管理 API | 新增 tree/create/update/delete/reorder | 新增专用表 `iic_msg_email_category` |
| Batch Subcategory Create | 无 | 新增一次 1-5 条、后端单事务的批量创建 API | 不允许前端循环单条 Create 模拟成功 |
| Category Delete（统一入口） | 无 | NEW-12 首次评估影响；无引用直接软删除；有引用时返回影响并在重提目标后同事务迁移、写 History/Audit、软删除 | 仅 Expired 的 Template 不迁移；Impact 结果在正式删除时重新核验 |
| Tag | 无 Template Tag API | 新增只读 taxonomy API | 无 Tag 管理 API |
| Template Master + Metadata Update / Reassign | 无结构化 Metadata API | EX-06 统一单模板主信息与 Metadata 全量更新；NEW-11 批量重新分配 | 不创建 version、不修改状态；写修改历史 |
| Preview | 已确认可复用现有正文和 Metadata 预览能力 | 无 API 或实现变更 | 完全保持现状；不支持附件 |
| Cancel Draft | 已有 Version Delete、Template Delete | 未保存编辑仅前端丢弃；Published Working Copy 复用 Version Delete；新建 Draft 只使用 Template Delete | 不新增 Cancel API；不回滚 config 主表字段 |
| Copy and Create | 无独立接口；`/version/add` 只处理同一 Template 的版本增加 | 新增 v2 Copy API；首次 Save Draft 时原子创建独立 Template B 和 V1 Draft，并记录 `copy_from_email_code` | 来源只允许当前最新 Active；复制可编辑字段、当前 Metadata 和附件引用；A/B 生命周期独立；B 发布前仅做 Deactivate A 提醒 |

#### 11.1.1 Story 与接口影响索引

下表只统计本期方案中的运行时完整接口。同一接口可能同时支持多个 Story，因此各 Story 的接口数仅表示影响范围，不能相加作为接口总数。

| Story | 直接涉及的接口 | 保持不变/复用 | 修改现有 | 新增 | 本 Story 涉及数 |
|---|---|---:|---:|---:|---:|
| LEAD-277 数据模型和发布校验 | `EX-03`、`EX-04`、`EX-05`、`EX-06`、`EX-10`、`EX-13` | 0 | 6 | 0 | 6 |
| LEAD-293 创建和管理分类/子分类 | `NEW-01`、`NEW-02`、`NEW-03`、`NEW-05`、`NEW-08` | 0 | 0 | 5 | 5 |
| LEAD-306 创建新模板 | `EX-05` | 0 | 1 | 0 | 1 |
| LEAD-307 删除分类/子分类 | `NEW-12` | 0 | 0 | 1 | 1 |
| LEAD-301 分配和编辑分类 | `EX-03`、`EX-06`、`EX-10`、`NEW-01` | 0 | 3 | 1 | 4 |
| LEAD-276 模板重新分类 | `EX-06`、`NEW-01`、`NEW-11` | 0 | 1 | 2 | 3 |
| LEAD-278 编辑已发布模板与 Copy and Create | `EX-03`、`EX-05`、`EX-09`、`EX-10`、`EX-11`、`EX-12`、`EX-14`、`EX-16`、`NEW-10` | 2 | 6 | 1 | 9 |
| LEAD-300 选择、分配和编辑标签 | `EX-03`、`EX-05`、`EX-06`、`EX-10`、`EX-13`、`NEW-06` | 0 | 5 | 1 | 6 |
| LEAD-279 草稿与发布流程 | `EX-05`、`EX-09`、`EX-10`、`EX-11` | 0 | 4 | 0 | 4 |
| LEAD-296 删除模板 | `EX-08` | 0 | 1 | 0 | 1 |
| LEAD-326 模板预览 | 复用前端现有预览流程，无 LEAD-93 运行时接口 | 0 | 0 | 0 | 0 |
| LEAD-327 搜索与筛选 | `EX-01`、`EX-02` | 0 | 2 | 0 | 2 |
| LEAD-328 数据迁移 | 使用数据库脚本，无运行时接口 | 0 | 0 | 0 | 0 |
| 跨 Story 现有公共能力 | `EX-07`、`EX-12`、`EX-14`、`EX-15` | 4 | 0 | 0 | 4 |

去重后的当前设计共包含 25 个 Web v2 完整接口：4 个仅升级路由并复用行为、12 个增强现有能力、9 个新增接口。完整清单和字段以接口约定为准。

### 11.2 Contract 管理

本期新增 Category Tree/CRUD/Reorder、Batch Subcategory Create、统一 Category Delete、Tag Taxonomy、Batch Reassign 和 Copy and Create；EX-05 首次创建聚合写入 Metadata，EX-06 聚合维护 Template 主信息与当前 Metadata；Search/Filter、Detail、Publish 和 Template Delete 接入当前 Metadata 或修改历史。已有 Template 的 Save Draft、Version Delete、Preview 和附件不接入 Metadata；Copy and Create 仅在独立 Template 首次保存时写入提交的当前 Metadata 和 `copy_from_email_code`。Admin Detail 返回该来源字段供前端 Publish Popup 判断，普通列表和 Adviser Detail 不返回。Active/Deactivate 使用 v2 Endpoint 复用现有 Service 行为，但后端事务增加 Template Change History。

接口地址、字段模型、错误语义和权限统一维护在[LEAD-93 接口约定](LEAD-93_API_Contract_Clarification_CN.md)。发布校验是现有发布接口的内部步骤；放弃草稿、取消预约不新增独立接口。单个模板的主信息与 Metadata 使用 EX-06；分类或子分类删除始终使用 NEW-12，先评估影响，再按需要迁移并删除。

### 11.3 分层代码改造清单

| 层级 | 保持不变/复用 | 修改 | 新增 |
|---|---|---|---|
| Frontend | Preview、附件上传组件 | Template Edit、Tag Group 多选、Search/Filter、Cancel 路由、Copy 模板 Publish 前 Deactivate A 提醒 | Category 管理页面、Copy and Create 预填和首次保存调用 |
| API/Controller | Preview、Attachment、Active/Deactivate | List/Detail、EX-05 聚合创建/Save Draft、EX-06 聚合更新、Publish、Version/Template Delete；Admin Detail 返回 `copyFromEmailCode` | Category CRUD/Reorder、Batch Subcategory、统一 Category Delete、Tag Taxonomy Read、Batch Reassign、Copy and Create |
| Service | Scheduler、现有附件逻辑、Save Draft 选版、待核实的 Version Conflict 失败路径 | Template 聚合命令编排、Publish Validation、Template Delete/启停历史 | Metadata Service、Template Change History Service、Taxonomy Service、统一 Category Delete Orchestrator、Template Copy Orchestrator（写来源字段） |
| Mapper/Repository | config/version/file Mapper | Published/Draft 查询、现有 Delete DML | Category/Tag 字典和 Subcategory/Tag relation Mapper |
| Database | `iic_msg_email_config_version`、附件表 | `iic_msg_email_config` 增加 `category_id`、`copy_from_email_code` | `iic_msg_email_category`、两张 Template relation、Tag Group/Value、Template Change History、Migration Log、Delete Audit |
| Release SQL | 现有发布执行机制 | config migration | Category/Tag seed、Template mapping、batch log、validation SQL |
| Scheduler | `changeVersionStatusByEffectiveFrom()` | 无 | 无 |

详细字段见第 7 章；Search/Filter 查询构造见第 10 章；正式 Endpoint、DTO 和错误处理约定见本章摘要及 [API Contract](LEAD-93_API_Contract_Clarification_CN.md)。

### 11.4 后端工作包与估算

本节用于开发计划、任务拆分和内部资源协调，不作为对 PO 的方案评审结论。

![前后端交付与后端工作量](diagrams/lead93-frontend-api-backend-workload.svg)

上图从页面操作、接口、后端工作包和数据库四个视角展示交付边界。后端工作量除接口开发外，还包括现有选版规则兼容、两阶段查询、跨表事务、生命周期状态、迁移脚本和一致性校验。

| 后端工作包 | 前端可见结果 | 后端具体改造 | 主要接口/数据 | 关联需求 | 估算 |
|---|---|---|---|---|---:|
| 列表、详情、搜索与筛选 | 页签内容与 Template 当前分类标签正确组合 | 保留现有页签选版；按 `email_code` 增加当前关系过滤、去重、总数、分页、排序和详情组装 | `EX-01`—`EX-04`；config、版本表和两张关系表 | LEAD-327 | 3 人天 |
| 模板写入、生命周期与复制创建 | 保存草稿、立即/未来发布、复制创建、发布前来源提醒和放弃行为一致 | EX-05 首次创建原子写 Master/V1/Metadata；保留选版；发布读取当前 Metadata 校验；Copy Orchestrator 原子创建独立 B、V1 Draft、关系和历史并写来源字段；Admin Detail 返回来源供前端 Popup 判断 | `EX-03`、`EX-05`、`EX-09`—`EX-11`、`EX-16`、`NEW-10` | LEAD-278、279、296 | 6 人天 |
| Template 主信息、Metadata 与修改历史 | 支持当前分类、子分类和标签查询/更新并可追溯 | EX-06 全量替换当前值；校验 taxonomy；基本信息、Metadata、启停和删除写前后快照 | `EX-06`、`NEW-06`；关系表和 Change History | LEAD-277、300、301 | 3 人天 |
| 分类和子分类管理 | 分类树、新增、重命名、排序和批量子分类可用 | 两级树规则、有效名称唯一、同级排序事务、批量 1-5 条整体回滚 | `NEW-01`—`NEW-03`、`NEW-05`、`NEW-08`；分类表 | LEAD-293、307 | 3 人天 |
| 分类影响评估与迁移删除 | 同一删除入口先返回影响，再迁移并删除 | NEW-12 锁定源/目标节点及受影响 Template；迁移当前值、逐 Template 写历史、软删除和操作审计原子提交 | `NEW-12`；分类、config、关系、历史及删除审计表 | LEAD-307 | 4 人天 |
| 表结构和一次性数据迁移 | 无运行时页面；为上线准备数据 | 表结构、初始数据、Template 当前映射、批次迁移日志、校验和事务回退 | 1 张现有表扩展、7 张新业务表及迁移批次表 | LEAD-328 | 3 人天 |
| 联调与缺陷修正 | 前后端主流程可联调，现有行为不回归 | 列表、保存、发布、分类和删除主流程的集成修正 | 跨工作包 | 全部 | 3 人天 |
| **合计** |  |  |  |  | **25 人天** |

后端开发估算基线为 **25 人天**，按上述工作包统计。


## 12. SQL 发布清单

**Jira Coverage：** LEAD-328

运维只执行 [required](sql/required/README.md) 中的文件。上线交付时按下表的序号为文件增加前缀，并按序执行。

| 顺序 | 上线文件名 | 用途 |
|---:|---|---|
| 01 | `DDL_iic_msg_email_category.sql` | 新建 Template Category/Subcategory 表 |
| 02 | `DDL_iic_msg_tag_group.sql` | 新建 Tag Group 表 |
| 03 | `DDL_iic_msg_tag_value.sql` | 新建 Tag Value 表 |
| 04 | `DDL_iic_msg_email_config.sql` | 扩展 Template 主表 |
| 05 | `DDL_iic_msg_template_category_rel.sql` | 新建 Template Subcategory 关系表 |
| 06 | `DDL_iic_msg_template_tag_rel.sql` | 新建 Template Tag 关系表 |
| 07 | `DDL_iic_msg_email_template_change_history.sql` | 新建 Template 修改历史表 |
| 08 | `DDL_iic_msg_email_category_change_history.sql` | 新建 Category/Subcategory 生命周期修改历史表 |
| 09 | `DDL_iic_msg_template_migration_log.sql` | 新建一次性数据迁移日志表 |
| 10 | `DDL_iic_msg_email_category_delete_audit.sql` | 新建 Category 删除记录表 |
| 11 | `DML_iic_msg_tag_group.sql` | 初始化 Tag Group |
| 12 | `DML_iic_msg_tag_value.sql` | 初始化 Tag Value |
| 13 | `DML_LEAD93_template_mapping_<batch>.sql` | 待 `BUS-01` Mapping 确认后生成；迁移存量 Template 数据 |

第 13 个文件当前不生成、不提交。其余运行时查询和数据更新由后端应用代码实现，不属于运维 SQL 交付。


## 13. 风险与待确认项

本章只保留影响方案评审的摘要。完整问题、Owner、冻结点和关闭记录统一维护在[未确认项与现状核对登记册](LEAD-93_Open_Questions_Register_CN.md)，不得仅在本章关闭问题。

### 13.1 已接受风险

| 风险 | 处理方式 |
|---|---|
| 现有 Version Conflict 的比较基线、触发命令、检测时点和真实错误码尚未专项验证 | 本期不扩展锁/token；开发前补充代码定位和并发 QA 用例，未核实前不得把推测规则写成接口验收标准 |
| 一个 Draft 仅由前端页面限制，后端/数据库不保证；异常请求可能产生多个 Draft，甚至按最大版本继续 Insert | To-Be 暂时保持现状；前端有 Draft/Schedule 时禁止创建新 Draft，后端风险通过查询 SQL 监测，不把异常数据纳入正常状态机 |
| 列表关键字的 `LIKE '%value%'` 在数据增长后可能产生扫描开销 | 本期基于现有数据量使用数据库查询；上线前执行 `EXPLAIN`，后续按容量评估全文索引或搜索引擎 |
| 新增表不使用外键和 check constraint | Service 层在事务中校验层级、状态、唯一性和关系完整性，并通过校验 SQL 发现异常 |
| 应用回滚后旧版本不识别新增 Metadata | 新增表和字段保持向后兼容；应用回滚不删除新增数据，也不重写现有 version lifecycle |

### 13.2 业务待确认

| ID | 问题 | 当前处理 | 冻结点 |
|---|---|---|---|
| BUS-01 | 79 个存量模板的分类、标签、重复和过期映射 | 由 PO/BA 提供并签字确认 | Migration 数据脚本执行前 |

### 13.3 后续体验与查询优化（不属于本期开发基线）

| 主题 | 后续需要完成的工作 | 当前处理 |
|---|---|---|
| Category/Folder 浏览 | 明确先展示目录树、按节点展开加载模板、模板计数和空目录展示的交互；再评估是否需要树节点延迟加载和独立计数查询 | 本期仍按现有 Tab 列表 + Filter 查询，不新增目录浏览协议 |
| Search / Filter 性能 | 基于实际数据量和 `EXPLAIN` 评估分页、关键词检索、关系过滤和 Count 查询；数据增长后再决定全文索引、搜索服务或分层查询方案 | 本期保留数据库组合查询与现有分页语义 |
