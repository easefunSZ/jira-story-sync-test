# LEAD-308 Adviser Template Management 解决方案设计文档

| 项目 | 内容 |
|---|---|
| Feature | LEAD-308 Advisor Template Management |
| 文档版本 | v1.0 Review Draft |
| 更新日期 | 2026-07-17 |
| 需求基线 | `PRD_LEAD-308 Advisor-Template Management_v1.1 -updated July 14th.docx` |
| 上游需求 | LEAD-93 Template Management |
| 上游技术基线 | [LEAD-93 详细解决方案 V3](../Lead-93/LEAD-93_Template_Management_Solution_Design_CN_v3.md) |
| 上游接口基线 | [LEAD-93 Web v2 API Contract](../Lead-93/LEAD-93_API_Contract_Clarification_CN.md) |
| 本文状态 | 可冻结总体架构、可见性、选版、Preview 和基础接口复用；第 14 章未确认项按冻结点管理 |

> 本文只把有 PRD、LEAD-93 已确认设计或内网证据支持的内容写为开发基线。未确认内容集中登记，不以“建议字段”伪装成已冻结 Contract。

## 1. 文档目的

LEAD-308 建设 Adviser 端 Template Library 的浏览与消费体验。它不重新实现模板创建、版本状态机、分类、标签、附件或发布，而是读取 LEAD-93 产出的当前有效 Published Template，提供 Category 导航、Search、Filter、Sort、Preview、Context Information 和 Use Template 入口。

本文回答四个问题：

1. Adviser 可以看到哪一个 Template version，以及 Metadata 从哪里读取；
2. LEAD-308 哪些能力直接复用 LEAD-93，哪些需要新增前后端逻辑；
3. List、Detail、Preview 和 Use Template 通过哪些接口协作；
4. 哪些内容尚未冻结，不能由开发人员自行猜测。

## 2. 结论摘要

| 设计决策 | 结论 | 状态 |
|---|---|---|
| 数据模型 | 复用 LEAD-93 的 Master、Version、Category、Subcategory、Tag 和附件模型 | 已冻结 |
| 数据库改造 | LEAD-308 不新增表、不新增 DDL/DML；只增加/改造查询 | 已冻结 |
| Adviser 可见版本 | 只读取有效、启用 Template 的 Active version，即 `version_status=1` | 已冻结 |
| Metadata 归属 | 通过 `email_code + version` 读取当前 Active version 的 Category/Subcategory/Tag | 已冻结 |
| Working Copy | Active 与 Draft 共存时 Adviser 只看 Active，不显示 Draft 提示 | 已冻结 |
| List API | 复用 LEAD-93 `EX-01` v2 Published List，308 增量字段另行冻结 | 基础已冻结 |
| Detail API | 复用 `EX-04` Adviser Published Detail；客户端不能指定 version | 已冻结 |
| Taxonomy API | 复用 `NEW-01` Category Tree 与 `NEW-06` Tag Taxonomy | 基础已冻结 |
| Preview | 复用现有 Renderer；仅正文和 Metadata，不展示附件，不新增 Preview API | 已冻结 |
| Use Template | 点击时调用 `EX-04` 重新解析当前 Active，再按 `isCampaign` 进入既有下游 | 边界已冻结；下游路由待确认 |
| 审计 | Data Tracking 为 Nice to Have；本期不新增审计表或强制审计事件 | 已冻结 |
| Preview PRD 冲突 | 最新 308 PRD 的 PDF/TXT/媒体预览描述与已确认基线冲突；实现仍按“正文 + Metadata、无附件” | 设计已关闭；PRD 文本待 BA/PO 修正 |

## 3. As-Is 基线

### 3.1 LEAD-93 提供的数据基础

| 数据 | 存储位置 | LEAD-308 读取方式 |
|---|---|---|
| Template Identity | `iic_msg_email_config.email_code` | Card、Detail、Preview 和 Use Template 的业务标识；前端按 String 处理 |
| Template Title | `iic_msg_email_config.email_name` | Card、Search、A-Z/Z-A |
| Description | `iic_msg_email_config.description` | Card、Detail、Search |
| Email/Campaign | `iic_msg_email_config.is_campaign` | `0=Email`、`1=Campaign` |
| Enabled/Delete | `email_status`、`status` | 后端强制 Adviser 可见性 |
| Version Content | `iic_msg_email_config_version` | 只选当前 Active row |
| Main Category | `iic_msg_email_config_version.category_id` | 与当前 Active version 一致 |
| Category Tree | `iic_msg_email_category` | 只读取 `is_deleted=0` 的两级树 |
| Subcategory | `iic_msg_template_category_rel` | 按 `email_code + version` 读取 |
| Tag Dictionary | `iic_msg_tag_group`、`iic_msg_tag_value` | Filter 和 Metadata 展示 |
| Tag Selection | `iic_msg_template_tag_rel` | 按 `email_code + version` 读取；同组可多选 |
| Thumbnail | `iic_msg_email_config_version.thumbnail_key` | Card 使用；URL 解析链路待内网核对 |
| Attachment | `file_keys`、文件表与 S3 | Preview 不加载；下游 Use Template 可按现有机制使用 |

### 3.2 状态与选版

| `version_status` | 含义 | Adviser 可见 |
|---:|---|---|
| `0` | Schedule | 否 |
| `1` | Active / Published | 是，还需 Master 有效且启用 |
| `2` | Expired | 否 |
| `3` | Draft | 否 |

LEAD-308 不引入新状态。List、Detail、Preview 和 Use Template 都必须由后端根据 `email_code` 重新解析当前 Active version，不能读取 Draft/Schedule/Expired，也不能信任客户端提交的 `version` 或 Status。

### 3.3 现有 v1 与目标 v2 的关系

现有 v1 `POST /iic-dae-msg/web/msg/template/email/v1/queryList` 硬编码 `is_campaign != 1`，不支持 Category/Subcategory/Tag Filter。LEAD-308 Web 新能力使用 LEAD-93 已冻结的 v2 `EX-01`；v1 保持不变，避免影响现有 Web/Mobile 调用。

LEAD-93 已确定“Mobile App 继续使用 v1，新增/增强能力仅由 Web v2 提供”，而 308 PRD 写明 Mobile、Web 均支持。两者的交付范围存在冲突，必须由 BA/PO 冻结，见 `SCOPE-01`。

## 4. 新需求摘要

| Story | 新需求 | 主要输出 |
|---|---|---|
| LEAD-312 | 以 Card 浏览全部可用 Published Template | 列表、缩略图、分页、Loading/Empty、Preview/Use 操作 |
| LEAD-313 | 按两级 Category/Subcategory 导航 | 有效树、排序、选择状态、模板数量 |
| LEAD-314 | 按 Title、Description、Tag Name 部分匹配 | 搜索、防抖、清除、前端高亮 |
| LEAD-315 | 按四个 Tag Group 多维筛选 | 同组 OR、跨组 AND、可用值 |
| LEAD-316 | 展示并单独移除 Active Filter Chips | 统一 Query State |
| LEAD-317 | Clear All | 清搜索/分类/标签并恢复默认状态 |
| LEAD-318 | Most Relevant、发布时间和标题排序 | 白名单排序、稳定次序 |
| LEAD-319 | 只读 Preview | 当前 Active 正文 + Metadata；不含附件 |
| LEAD-320 | Card/Detail 展示 Context Information | Category、Tags、Format、Published 信息 |
| LEAD-321 | Use Template | Email Composer / Campaign Builder 入口 |

## 5. Gap Analysis

![LEAD-93 与 LEAD-308 能力对齐图](diagrams/lead308-lead93-alignment.svg)

| 能力 | LEAD-93 已提供 | LEAD-308 新增或修改 | 是否冻结 |
|---|---|---|---|
| Published List | `EX-01` 选 Active、Metadata Filter、分页 | Adviser Card、强制 Published-only、无 Status、四组 Filter | 基础冻结；Card 增量待 Contract |
| Category | `NEW-01` 有效两级树 | Adviser 导航和 Published Count | Count 口径待确认 |
| Tag | `NEW-06` 返回六组 taxonomy | Adviser Filter 只显示四个 Mandatory Group，并限制可用值 | 可用值/Count 返回方式待确认 |
| Search | Title、Description、Tag Name | 2 字符、300ms debounce、前端高亮 | 前端规则冻结；数据库执行计划待验证 |
| Sort | `EX-01 sortField/isAsc` | 五个用户可见排序项 | Most Relevant、Published Date 待确认 |
| Detail | `EX-04` 当前 Active + Metadata | Adviser Detail Context 展示 | 基础冻结；Card/Detail字段待补 |
| Preview | 现有 Renderer、无独立 API | Adviser Modal/Page 状态恢复 | 冻结；PRD 文本待修正 |
| Use Template | `EX-04` 可重新解析最新 Active | 按 Format 进入 Email/Campaign 下游 | 下游路由和 Payload 待确认 |
| Database | 版本级 Metadata 模型与索引 | 只读查询和性能验证 | 冻结 |

## 6. To-Be 总体方案

![LEAD-308 To-Be 总体架构](diagrams/lead308-solution-architecture.svg)

### 6.1 组件职责

| 组件 | 职责 | 改造类型 |
|---|---|---|
| Adviser Template Library UI | Card、Category、Search、Filter、Chip、Sort、Preview、Use | 新增/改造前端 |
| Template Query v2 | 复用 `EX-01`，执行可见性、选版、筛选、分页 | 增强后端 |
| Adviser Detail v2 | 复用 `EX-04`，按 `emailCode` 返回当前 Active | 复用/增强后端 |
| Category/Tag Read API | 复用 `NEW-01`、`NEW-06` | 复用后端 |
| Existing Renderer | 渲染正文；不读取附件 | 复用，不改核心逻辑 |
| Downstream Router | 根据 `isCampaign` 进入 Email/Campaign | 前端编排或既有服务；待内网确认 |
| LEAD-93 Repository | Master、Version、Category、Relation、Tag 查询 | 复用 |

### 6.2 核心不可变式

- Adviser 请求不得包含 `status`、`versionStatus`、目标 `version` 或 `includeDraft`。
- `config.status=0`、`config.email_status=1`、`version.status=0`、`version.version_status=1` 由后端强制。
- 先确定 `email_code + result_version`，再读取该 version 的 Metadata；禁止从 Draft 借用 Metadata。
- Active 不存在、Template 停用/删除、主 Category 失效时不返回 Expired 作为回退。
- 多个 Active 属于数据异常，服务端拒绝任意选取并记录错误。
- Preview 不持久化、不发布、不改变任何状态，也不下载附件。

## 7. 数据模型与查询设计

### 7.1 逻辑读模型

```text
iic_msg_email_config (Master)
  1 ── N iic_msg_email_config_version (只选 Active)
             N ── 1 iic_msg_email_category (Main Category)
             1 ── N iic_msg_template_category_rel ── 1 Subcategory
             1 ── N iic_msg_template_tag_rel ── 1 Tag Value
```

LEAD-308 没有独立 Metadata 表或副本。所有 Card/Detail 数据都来自 LEAD-93 当前 Active version 及其关系。

### 7.2 两阶段查询

![Adviser Published-only 查询管线](diagrams/lead308-published-query-pipeline.svg)

1. Base Query 按 Master/Version 状态、权限、国家和 `isCampaign` 选出唯一 `email_code + result_version`。
2. Metadata Query 在该 version 上应用 Category、Subcategory、Tag 和 Keyword 条件。
3. 使用 `EXISTS` 或先去重后的 Key Set 过滤多值关系。
4. 在去重结果上 Count、Sort 和 Pagination。
5. 再批量装配 Category、Subcategory、Tag，避免 N+1。

禁止直接对多张 relation Join 后分页，否则一个 Template 的多个 Subcategory/Tag 会扩行，导致重复 Card、错误总数和不稳定分页。

### 7.3 SQL 文件

LEAD-308 只提供 QUERY 模板：[QUERY_adviser_template_library.sql](sql/QUERY_adviser_template_library.sql)。

| 类型 | 文件 | 说明 |
|---|---|---|
| DDL | 无 | 表结构由 LEAD-93 交付 |
| DML | 无 | 308 不写 Template、Metadata 或 taxonomy |
| QUERY | `QUERY_adviser_template_library.sql` | Published scope、List、Category Count、Tag Facet、Detail/Use Active 解析 |

该 SQL 是设计模板，必须与真实 Mapper、权限条件、分页方言和 LEAD-93 最终索引合并后使用。

## 8. 功能设计

### 8.1 Template Library Card

| UI 字段 | 已知来源 | 状态 |
|---|---|---|
| Template Title | `config.email_name` | 已冻结 |
| Description | `config.description` | 已冻结 |
| Format | `config.is_campaign` | 已冻结 |
| Category/Subcategory/Tags | 当前 Active version Metadata | 已冻结 |
| Thumbnail | `version.thumbnail_key` | URL/缺省处理待内网核对 |
| Published Badge | Adviser 结果固定为 Published | 已冻结 |
| Published Date | 现有 `publishedTime` 或 Active `effective_from` | 待业务和代码确认 |

Card 不显示 Draft Indicator，也不开放版本历史。过长 Description/Tags 由前端截断并通过 Tooltip 或 `+N` 展示，不改变 API 数据。

### 8.2 Category Navigation

- 使用 `NEW-01` 返回的 `is_deleted=0` 两级树，按 `sortOrder` 展示。
- Category 单选；Subcategory 是否多选沿用最终 UX/Contract。
- Category/Subcategory 与 Search、Tag 之间使用 AND。
- Category Count 是否为全局 Published Count，还是随当前 Search/Tag 条件变化，当前未冻结。
- Category 失效后不再作为筛选项；关联 Template 的 Adviser 可见性按 LEAD-93 Category 删除迁移规则和当前有效关系决定。

### 8.3 Search

- 仅搜索 Template Title、Description、Tag Name。
- 不搜索 Email Subject、Category Name 或 Subcategory Name。
- 前端达到 2 个字符后 300ms debounce；Enter 立即执行。
- 清空 Search 保留其他 Filter；Clear All 才清空全部条件。
- 大小写不敏感由后端保证；高亮由前端在转义文本上完成。

### 8.4 Tag Filter

Adviser Filter 仅展示 `CONTENT_TYPE`、`TRIGGER`、`LIFECYCLE_STAGE`、`FINANCIAL_NEED`。`PROPOSITION` 和 `SOURCE` 可在 Detail Metadata 中显示，但不作为 308 Filter。

- 同组多个 Tag：OR / ANY。
- 不同 Tag Group：AND。
- Tag 与 Category、Search：AND。
- 请求重复值先去重，并校验 Tag 属于对应 Group。
- PRD 要求只提供被 Published Template 使用的有效值；是扩展 `NEW-06` 还是由 `EX-01` 返回 Facet，尚未冻结。

### 8.5 Query State、Chips 与 Clear All

前端使用一个 Query State 驱动 Filter Panel、Chips、URL/Router State 和 List Request：

```text
keyword, isCampaign, categoryId, subcategoryIds[], tagGroups[],
sortMode, pageNum, pageSize, scrollPosition
```

移除任一 Chip 后重置到第一页并保留其他条件。Clear All 清 Search、Category/Subcategory、Tag、Chip，恢复默认 Sort、第一页和 All Templates。从 Preview/Detail 返回时恢复 Query State 和滚动位置。

### 8.6 Sort

| 用户选项 | 服务端语义 | 状态 |
|---|---|---|
| Most Relevant | 搜索相关度 DESC + 稳定次序 | 评分规则待确认 |
| Newest First | Published Date DESC + `email_code` DESC | 日期字段待确认 |
| Oldest First | Published Date ASC + `email_code` ASC | 日期字段待确认 |
| Alphabetical A-Z | `email_name` ASC + `email_code` ASC | 可冻结 |
| Alphabetical Z-A | `email_name` DESC + `email_code` DESC | 可冻结 |

排序必须由后端白名单映射，不能把客户端文本直接拼到 `ORDER BY`。

### 8.7 Preview

![Preview 与 Use Template 分流](diagrams/lead308-preview-activation-flow.svg)

1. 点击 Preview 时调用 `EX-04`，只提交 `emailCode`。
2. 后端重新校验 Adviser 权限和 Published-only 可见性并解析最新 Active。
3. 前端复用现有 Renderer 渲染正文，并展示当前 Active 的 Metadata。
4. 不读取、不下载、不渲染 `fileKeys/fileInfos`；PDF、TXT、图片附件、音频和视频均不支持 Preview。
5. Preview 只读、不持久化、不改变状态；关闭后恢复 Library Query State。

最新 308 PRD 的 LEAD-319 描述仍包含 PDF/TXT/媒体预览。该文本与 LEAD-93 已确认 Preview 规则和本项目此前确认结论冲突。技术实现按本节执行，BA/PO 需同步修正 PRD，避免 QA 按错误 AC 验收。

### 8.8 Context Information

- Card 至少显示四组 Mandatory Tag、Format 和 Published 标识。
- Detail 可显示当前 Active version 的全部有效 Metadata；是否展示两个 Optional Group 由 UX 最终确认。
- `Latest Version` 只表示当前解析出的 Active，不开放历史版本。
- Adviser 不查看 Draft、Schedule、Expired 或历史 Metadata。

### 8.9 Use Template

1. 从 Card、Preview 或 Detail 点击 Use Template。
2. 前端再次调用 `EX-04`，不使用页面缓存 version。
3. 返回可见 Active 后，根据 `isCampaign` 分流。
4. Email 进入现有 Email Composer；Campaign 进入 Campaign 创建流程。
5. 下游基于返回正文和现有附件机制初始化自己的可编辑副本，不回写 Library Template。
6. Template 已停用/删除、Active 不存在或初始化失败时保留 Library 页面并提示刷新/重试。

本期不新增 `/use` 后端接口，除非内网下游证明必须由服务端编排。Email/Campaign 的真实路由、初始化 API、Payload 和失败码见 `USE-01/USE-02`。

## 9. API 设计摘要

完整约定见 [LEAD-308 API Contract](LEAD-308_API_Contract_Clarification_CN.md)。

| LEAD-93 ID | Endpoint | 308 使用方式 | 是否修改 |
|---|---|---|---|
| `EX-01` | `POST /iic-dae-msg/web/msg/template/email/v2/queryList` | List/Search/Filter/Sort/Page | 基础查询复用；Card、Sort、Facet 等 PRD Gap 待扩展 |
| `EX-04` | `POST /iic-dae-msg/web/msg/template/email/v2/published/detail` | Detail、Preview、Use 前重解析 | 接口不改，只增加 308 调用场景 |
| `NEW-01` | `GET /iic-dae-msg/web/msg/template/email/v2/category/tree` | 两级 Category Navigation | Tree 复用；Published Count 待扩展 |
| `NEW-06` | `GET /iic-dae-msg/web/msg/template/email/v2/tag/taxonomy` | 四组 Adviser Tag Filter | Taxonomy 复用；可用值/Count 待扩展 |

LEAD-308 当前不新增独立 Preview API 或 Use API，也不再创建第二套 `A308-*` 编号。Card 增量字段、Facet 和排序枚举只有在 API Contract 对应 Gap 关闭后才能进入开发冻结。

公共约定沿用 LEAD-93：`IICResponseModel<T>` 包络、成功码 `00000000`、`pageNum/pageSize`、南非时区 `Africa/Johannesburg`、时间格式 `yyyy-MM-dd HH:mm:ss`、64 位 ID 使用 String。

## 10. 权限、安全与数据隔离

- 后端沿用现有登录态并强制 Adviser 角色和数据范围，不能信任客户端传入 tenant/country/role。
- Supported Country 为 South Africa；真实范围字段和注入点由内网权限组件确认。
- 不返回 Draft、Schedule、Expired、Inactive 或 Soft Deleted Template。
- 不向 Adviser 暴露写接口、Category 管理接口或 Status Filter。
- `emailContent` 继续沿用现有加密/解密和正文净化机制；308 不创建第二套实现。
- Thumbnail/附件 URL 必须使用现有短期授权机制，不返回 S3 credential。

## 11. 性能与容量

- List 先按唯一 Template Key 分页，再批量装配 Metadata，避免 Join 扩行和 N+1。
- List 与 Count 必须复用完全相同的过滤条件。
- Keyword `LIKE %keyword%` 在当前数据量下可接受；上线前对真实 SQL 执行 `EXPLAIN`。
- Category/Tag taxonomy 可按现有缓存策略缓存；计数若为上下文 Facet 不应与静态 taxonomy 使用同一缓存值。
- 快速连续查询使用前端 debounce 和请求取消；旧响应不能覆盖新 Query State。
- PRD 的 3 秒加载目标需在 QA 规模数据和目标网络条件下验收。

## 12. 异常与边界场景

| 场景 | 处理 |
|---|---|
| List 加载后 Template 被 Deactivate/Delete | Preview/Use 重解析失败，刷新当前列表 |
| Active 与 Draft 共存 | 只显示 Active 和 Active Metadata |
| 无 Active | 不返回，不回退到 Expired |
| 多个 Active | 服务端拒绝任意选择并记录数据异常 |
| Category/Tag 失效 | 只使用有效 taxonomy；关键 Metadata 不完整时按可见性规则排除 |
| 搜索无结果 | 返回空分页，不是业务异常 |
| 快速切换筛选 | 取消旧请求或按 request sequence 丢弃旧响应 |
| Preview 正文失败 | 保留 Library 状态并提供重试；不加载附件作为替代 |
| Use 下游失败 | 不修改 Template；保留当前页面并提示重试 |
| 64 位 ID 精度 | 全链路 String，不转 JavaScript Number |

## 13. 测试与发布

### 13.1 后端测试

- Published-only 四个状态条件与 Adviser 权限不可绕过。
- Active + Draft、Schedule、Expired、Inactive、Soft Delete、无 Active 和多 Active。
- Category/Tag 绑定当前 Active version，不能混入 Draft Metadata。
- Keyword 字段范围、大小写、特殊字符、同组 OR、跨组 AND。
- 多关系去重、List/Count 一致、分页稳定排序。
- `EX-04` 在 Preview/Use 点击时重新解析当前 Active。

### 13.2 前端测试

- Card、Loading、Empty、错误和响应式布局。
- Query State、Chip 单项移除、Clear All、Back/Close 状态恢复。
- Debounce、请求取消和旧响应抑制。
- 五种 Sort UI 与请求映射。
- Preview 只显示正文和 Metadata，不渲染附件。
- Use Template 的 Email/Campaign 路由和失败恢复。

### 13.3 集成与回归

- 与 LEAD-93 Publish、Deactivate、Delete、Category Reassign/Delete 联动。
- v1 Web/Mobile 接口请求和响应保持不变。
- QA 使用接近生产规模的数据执行 `EXPLAIN`、分页一致性和 3 秒性能测试。
- PRD Preview AC 修正后，QA 用例必须以“正文 + Metadata、无附件”为准。

## 14. 风险与待确认项

完整 Owner、冻结点和关闭记录见 [LEAD-308 未确认项登记册](LEAD-308_Open_Questions_Register_CN.md)。当前开发前关键项：

| ID | 问题 | 当前处理 |
|---|---|---|
| `SCOPE-01` | PRD 写 Mobile + Web，而 LEAD-93 v2 只支持 Web | Mobile 新功能不进入基线，等待 BA/PO 冻结 |
| `LIST-01` | 同一 Library 是否混合 Email/Campaign；`EX-01 isCampaign` 当前必传 | 不做无类型全量查询 |
| `FACET-01` | Category/Tag Count 是全局还是随当前条件联动 | 不冻结响应字段和缓存 |
| `SORT-01` | Most Relevant 评分规则 | 不实现猜测性评分 |
| `SORT-02` | Published Date 映射 | 不将 `modifiedTime` 或 `effective_from` 擅自定为发布时间 |
| `CARD-01` | `thumbnail_key` 的 URL 解析和缺省规则 | 待内网核对 |
| `USE-01` | Email Composer 的真实路由/API/Payload | 只冻结按 `isCampaign=0` 分流边界 |
| `USE-02` | Campaign 创建入口/API/Payload | 只冻结按 `isCampaign=1` 分流边界 |
| `PRD-01` | LEAD-319 PDF/TXT/媒体 Preview 文本错误 | 实现已按无附件冻结；BA/PO 修订 PRD |

## 15. 开发准入结论

可立即开始：Adviser 页面框架、Card/Loading/Empty、统一 Query State、Chip/Clear All、四组 Filter UI、Published-only 查询骨架、`EX-04` 详情与正文 Preview 集成、基础测试。

需等待对应问题关闭：Mobile 新功能、混合 Email/Campaign 列表、Facet Count、Most Relevant、Published Date、Thumbnail URL、Email/Campaign 下游端到端 Use Template。

因此本方案已经冻结 LEAD-308 与 LEAD-93 的架构和数据边界，但不是所有 Story 的接口字段都已冻结。开发必须按[API Contract](LEAD-308_API_Contract_Clarification_CN.md)的“开发基线 / Pending Delta”标记分阶段实施。
