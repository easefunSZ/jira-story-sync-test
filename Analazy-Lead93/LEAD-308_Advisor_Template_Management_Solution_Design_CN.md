# LEAD-308 Adviser Template Management 技术解决方案设计

| 项目 | 内容 |
|---|---|
| Feature | LEAD-308 Advisor Template Management |
| 目标角色 | Adviser |
| 文档版本 | v0.1 Draft |
| 更新日期 | 2026-07-15 |
| 上游依赖 | LEAD-93 Template Management |
| 需求基线 | [PRD v1.1](PRD_LEAD-308%20Advisor-Template%20Management_v1.1.docx) |
| 设计基线 | [LEAD-93 中文技术方案](../Lead-93/LEAD-93_Template_Management_Solution_Design_CN_v2.md) |
| 当前结论 | 可冻结总体边界与主要查询语义；API Contract、排序评分和下游激活 Contract 尚未达到开发准入 |

## 1. 文档目的

本文定义 LEAD-308 Adviser 端 Template Library 的技术实现方案。LEAD-308 不重复建设 LEAD-93 已定义的模板创建、版本流转、Category/Subcategory、Tag、附件和发布能力，而是在其上提供只读的模板发现、筛选、预览和使用入口。

本文严格区分三类内容：

- **已确认**：来自 LEAD-93 已确认规则或 LEAD-308 PRD v1.1，可作为实现约束。
- **建议设计**：技术上推荐但尚需 API/内网代码核对，不得直接视为现有 Contract。
- **待确认**：缺少业务或代码证据；本文不做推测。

## 2. 决策摘要

| 决策 | 结论 | 状态 |
|---|---|---|
| 数据模型 | 复用 LEAD-93 的 Master、Version、Category/Subcategory、Tag 和附件模型 | 已确认 |
| 数据库变更 | LEAD-308 不新增表，不修改 Template 生命周期字段；仅新增/改造查询 | 已确认 |
| Adviser 可见版本 | 只返回有效、启用 Template 的 Active version (`version_status=1`) | 已确认 |
| Working Copy | 即使 Published Template 同时存在 Draft，Adviser 仍只看到 Active，不显示 Draft 提示 | 已确认 |
| Metadata | Category、Subcategory、Tag 必须读取当前 Active version 对齐的数据 | 已确认 |
| Adviser Filter | 只展示 Content Type、Trigger、Lifecycle Stage、Financial Need 四组 | 已确认 |
| Status Filter | Adviser 不展示也不能通过 API 传入 Status Filter | 已确认 |
| Preview | 只预览正文和 Metadata；只读、不持久化、不修改状态、不加载附件 | 已确认 |
| Preview Renderer | 复用现有 Renderer，不新增第二套渲染器 | 已确认方向，真实 API 待内网核对 |
| Use Template | 点击时必须重新解析当前最新 Active version，不能使用页面缓存 version | 已确认 |
| Email/Campaign 激活 | 根据 `is_campaign` 分流到 Email Composer 或 Campaign Builder | PRD 已要求；真实入口和 Contract 待确认 |
| Audit | PRD 的 Data Tracking 是 Nice to Have；本期不新增审计表或强制审计事件 | 已确认边界 |

## 3. 范围

### 3.1 In Scope

- Adviser Template Library 卡片列表、分页、加载和空状态。
- Active Category/Subcategory 只读导航与模板数量展示。
- Title、Description、Tag Name 关键词搜索。
- 四个 Mandatory Tag Group 的多选筛选。
- Search、Category、Tag Filter 的组合、Filter Chips 和 Clear All。
- Newest、Oldest、A-Z、Z-A 和 Most Relevant 排序入口。
- Published Template 正文与 Metadata 的只读 Preview。
- Template Detail / Context Information。
- `Use Template` 到 Email/Campaign 下游流程的激活入口。
- Web/Mobile 响应式交互、服务端权限和 Published-only 强制过滤。

### 3.2 Out of Scope

- Template 创建、编辑、Save Draft、Publish、Schedule、Cancel Schedule、Deactivate 和 Delete。
- Category/Subcategory/Tag 的维护。
- Adviser 查看 Draft、Schedule、Expired 或历史 version。
- Preview 附件、PDF、TXT、图片附件、音频、视频或其他文件。
- 新增 Template 生命周期状态、Redis Lock 或新的版本控制机制。
- 新增审计表。埋点仍为 Nice to Have，除非 PO 将其提升为交付范围。
- Campaign 管理流程本身；LEAD-308 只负责进入已确认的下游入口。

## 4. LEAD-93 基础能力

### 4.1 可复用数据模型

| 数据 | 来源 | LEAD-308 用途 |
|---|---|---|
| Template Identity | `iic_msg_email_config.email_code` | Card、Preview、Use Template 的稳定业务标识 |
| Template Title | `iic_msg_email_config.email_name` | Card、搜索、A-Z/Z-A 排序 |
| Description | `iic_msg_email_config.description` | Card、Detail、搜索 |
| Format | `iic_msg_email_config.is_campaign` | `0=Email`、`1=Campaign`，用于展示和激活分流 |
| Enabled/Deleted | `email_status`、`status` | Adviser 可见性强制过滤 |
| Current Published Content | `iic_msg_email_config_version` 的 Active row | Subject、正文、缩略图、附件引用、发布时间候选字段 |
| Main Category | `iic_msg_email_config_version.category_id` | 当前 version 的主 Category |
| Subcategory | `iic_msg_template_category_rel` | 通过 `email_code + version` 读取 |
| Tag | `iic_msg_template_tag_rel` | 通过 `email_code + version` 读取 |
| Tag Taxonomy | `iic_msg_tag_group`、`iic_msg_tag_value` | Adviser Filter 和 Metadata 展示 |
| Thumbnail | `iic_msg_email_config_version.thumbnail_key` | Card 图片；URL 解析方式待内网核对 |
| Attachments | `version.file_keys` + `iic_msg_file_upload` + S3 | 仅供 Use Template 下游复用，不进入 Preview |

### 4.2 已确认生命周期语义

| `version_status` | 语义 | Adviser 是否可见 |
|---:|---|---|
| `0` | Schedule | 否 |
| `1` | Active / Published | 是，但还必须满足 Master 有效且启用 |
| `2` | Expired | 否 |
| `3` | Draft | 否 |

Adviser 页面不推导或展示 Working Copy 状态。当同一 `email_code` 同时存在 Active + Draft 时，只读取 Active version 及其 Metadata。

### 4.3 已确认 Preview 边界

- 复用现有 Preview/Renderer 能力。
- Preview 只展示正文和 Metadata。
- Preview 不读取、不下载、不渲染 `file_keys` 指向的附件。
- PDF、TXT、图片、音频、视频或其他附件均不在 Preview 范围。
- Preview 请求不持久化，不更新 Master/Version/Relation，不触发 Publish Validation。
- Preview 与 Use Template 是两条独立路径；Use Template 的下游流程可按现有机制加载附件。

## 5. 需求与 Gap Analysis

| Story | LEAD-93 已提供 | LEAD-308 增量设计 | 当前阻塞 |
|---|---|---|---|
| LEAD-312 View Library | Published-only 数据基础、Title/Description、缩略图字段 | Adviser Card View Model、分页、空状态、响应式、3 秒指标 | Card API、缩略图 URL |
| LEAD-313 Category Navigation | 两级 taxonomy、`sort_order`、version 分类关系 | 只读树、展开/折叠、选中态、Published Count | Count 口径 |
| LEAD-314 Search | Title/Description/Tag Name 查询语义 | 2 字符门槛、300ms 防抖、大小写不敏感、命中高亮 | 现有 Mapper/数据库执行计划 |
| LEAD-315 Filters | Tag taxonomy、组内 OR、跨组 AND | Adviser 仅四组、可用值/数量、即时刷新 | Filter Option API |
| LEAD-316 Active Chips | 通用单项移除原则 | Search/Category/Tag Chips 与 Filter Panel 双向同步 | 前端状态模型 |
| LEAD-317 Clear All | 清 Keyword/Filter 原则 | 同时恢复 All Templates 和默认排序 | 默认排序解释 |
| LEAD-318 Sort | 无 | 五种排序、稳定排序、session state | Most Relevant 评分、Published Date |
| LEAD-319 Preview | 现有 Renderer、正文和 Metadata | Adviser Published-only Preview、返回列表状态恢复 | 真实 Preview Contract |
| LEAD-320 Context | version-aligned Metadata | Card/Detail View Model、Tag 分组、`+N` 展示 | Published Date/Thumbnail 映射 |
| LEAD-321 Use Template | Active content、附件引用 | 激活时重读、按 Format 路由、错误恢复 | Email/Campaign 下游 Contract |

## 6. To-Be 总体架构

![LEAD-308 To-Be 总体架构](diagrams/lead308-solution-architecture.svg)

建议在现有 Template Management 模块内增加 Adviser 只读 Service/Facade，而不是让 Adviser 直接复用 Content Manager DTO：

1. **权限边界更清楚**：Adviser Contract 不接收 Status、目标 version 或任何写字段。
2. **View Model 更稳定**：Card、Category Count、Filter Option 和 Preview 可独立演进，不暴露 CM 内部字段。
3. **Published-only 可集中强制**：List、Detail、Preview、Use Template 共用同一 Visibility Guard。
4. **不复制领域逻辑**：底层仍复用 LEAD-93 Repository、Metadata 查询和 Renderer。

真实 Controller、Service、Mapper 名称必须由内网代码核对，不在本文中猜测。

## 7. Adviser 可见性与选版

### 7.1 可见 Template 定义

一个 Template 只有同时满足以下条件才能出现在 Adviser Library：

```text
config.status = 0
AND config.email_status = 1
AND version.status = 0
AND version.version_status = 1
AND main category is active
AND at least one active subcategory relation exists
AND four mandatory tag groups have active values
AND tenant / country / role scope matches the current user
```

其中租户、国家和角色的真实字段注入方式必须复用现有安全上下文，不允许信任客户端直接传入的身份范围。

### 7.2 查询管线

![Adviser Published-only 查询管线](diagrams/lead308-published-query-pipeline.svg)

查询必须先得到唯一的 `email_code + result_version`，再关联多值 Metadata。禁止在 Category/Tag 多表 Join 后直接分页，否则会产生重复 Card、错误 Count 和不稳定分页。

### 7.3 不可变式

- List、Detail、Preview 和 Use Template 必须使用同一 Adviser 可见性规则。
- Adviser 请求不能指定 `version_status` 或绕过 `email_status/status`。
- Preview 和 Use Template 只接收 `email_code`；服务端重新解析 Active version。
- Metadata 必须与解析出的 Active `version` 对齐，不能读取该 `email_code` 的 Draft Metadata。
- Active 不存在、Template Deactivate、Soft Delete 或 Category 失效时返回不可用，不回退到 Expired version。
- 理论上同一 `email_code` 只能存在一个 Active；若脏数据出现多个 Active，Service 必须拒绝并记录错误，不能任意选择。

## 8. 功能设计

### 8.1 Template Library Card

建议 Card View Model 至少包含：

| 字段 | 数据来源 | 说明 |
|---|---|---|
| `emailCode` | `config.email_code` | 仅作为后续只读操作标识 |
| `title` | `config.email_name` | Template Title |
| `description` | `config.description` | 前端截断并提供 Tooltip |
| `format` | `config.is_campaign` | 映射为 Email / Campaign |
| `thumbnailUrl` | `version.thumbnail_key` 经现有文件服务解析 | 无值时前端显示默认占位图 |
| `category` | Active version 的 `category_id` | 只返回有效节点 |
| `subcategories` | version-aligned relation | 只返回有效节点 |
| `tags` | version-aligned relation | Card 只需四个 Mandatory Group |
| `publishedDate` | 候选为 Active `effective_from` | 尚需业务确认后冻结 |
| `published` | 后端固定 `true` | 不接收/返回 Draft 状态 |
| `latestVersion` | 后端固定当前 Active | 不向 Adviser暴露历史列表 |

Card 上不展示 Draft Indicator。Description、Tag `+N`、Tooltip 和占位图属于展示逻辑，不改变后端结果。

### 8.2 Category/Subcategory Navigation

- 只返回 `category_level IN (1,2)` 且 `is_deleted=0` 的节点。
- 同级按 `sort_order, id` 稳定排序。
- Category 和 Subcategory 均显示 Published Template Count，包括 `0`。
- 选择 Category/Subcategory 后，与 Keyword 和 Tag Filter 使用 AND。
- Category Chip 被移除时回到 `All Templates`，保留其他筛选。
- Adviser 对 taxonomy 只有读权限。

**待确认：** Count 是固定的全局 Published 数量，还是随当前 Keyword/Tag Filter 联动变化。SQL 文件当前只固化全局 Published Count，未擅自实现动态 Facet Count。

### 8.3 Search

- 搜索字段严格为 Template Title、Description、Tag Name。
- 不搜索 Email Subject、Category Name 或 Subcategory Name。
- 前端输入达到 2 个字符后，采用 300ms debounce 发起查询；Enter 可立即触发并取消等待。
- 空字符串清除 Search，但保留 Category、Tag Filter 和显式 Sort。
- 大小写不敏感由后端强制，不能只依赖不同字段的数据库默认 Collation。
- 后端返回普通文本；匹配高亮由前端对已转义文本计算，后端不返回带 HTML 的高亮片段。
- Search 与 Category、每个 Tag Group 之间使用 AND。

### 8.4 Tag Filters

Adviser Filter Panel 只展示：

1. `CONTENT_TYPE`
2. `TRIGGER`
3. `LIFECYCLE_STAGE`
4. `FINANCIAL_NEED`

`PROPOSITION` 和 `SOURCE` 可保留在 Content Manager Metadata 中，但不进入 Adviser Filter Panel。

组合规则：

- 同一 Group 内多个 Tag Value：OR / ANY。
- 不同 Group：AND。
- Tag 与 Category、Search：AND。
- 后端对重复 Tag Code 去重，并校验 Tag 是否属于请求 Group。
- Filter Option 只返回至少被一个 Adviser 可见 Published Template 使用的有效值。

### 8.5 Chips 与 Clear All

前端维护单一 Query State，Filter Panel、Chips、URL/Router State 和请求参数都从该状态派生，避免两套状态不同步。

```text
TemplateLibraryQueryState
  keyword
  categoryId
  subcategoryIds[]
  tagFilters{ groupCode -> tagCodes[] }
  sort
  page
  pageSize
  scrollPosition
```

- 每个 Tag Value 一个 Chip，Search 和 Category 各自一个 Chip。
- 移除 Chip 立即同步取消对应控件并将 `page` 重置为第一页。
- Clear All 清除 Keyword、Category、Subcategory、Tag Filter、Chips，并恢复默认 Sort 和第一页。
- 从 Preview 返回时恢复 Clear 前/后的真实 Query State 和滚动位置。

### 8.6 Sort

| 枚举 | 预期排序 | 状态 |
|---|---|---|
| `NEWEST` | Published Date DESC + `email_code` DESC | Published Date 字段待确认 |
| `OLDEST` | Published Date ASC + `email_code` ASC | Published Date 字段待确认 |
| `TITLE_ASC` | Template Title ASC + `email_code` ASC | 可实现 |
| `TITLE_DESC` | Template Title DESC + `email_code` DESC | 可实现 |
| `MOST_RELEVANT` | Search relevance score DESC + 稳定次序 | 评分规则待确认 |

排序枚举必须由服务端白名单映射到固定 SQL，禁止把客户端字符串直接拼接到 `ORDER BY`。

PRD 中“CM-configured category order / Newest First”存在两种解释，尚未冻结：

- Category `sort_order` 优先，再按 Published Date DESC；或
- 默认只按 Published Date DESC，Category tree 自身按 `sort_order`。

在 PO/BA 确认前，不应把任一解释写死到 Mapper。

### 8.7 Preview

![Preview 与 Use Template 分流](diagrams/lead308-preview-activation-flow.svg)

Preview 流程：

1. 前端只提交 `emailCode`。
2. 后端执行 Adviser 权限、Tenant/Country 和 Published-only 校验。
3. 服务端重新解析当前 Active version。
4. 读取该 version 的正文与 Metadata，复用现有 Renderer。
5. 不选择或加载 `file_keys`；不调用附件下载接口。
6. 返回只读渲染结果和 Metadata，不持久化、不修改状态。
7. 关闭后前端恢复 Library Query State 与滚动位置。

Preview Metadata 包含 Title、Description、Category、Subcategory、四组 Mandatory Tags、Format 和 Published Date。Optional Tag 是否在 Detail/Preview 显示，PRD 表述为 all assigned tag groups，但 Adviser Filter 只要求四组；此处列为待确认，不自行扩大展示范围。

### 8.8 Detail / Context Information

- Card 展示四组 Mandatory Tags，过多时显示 `+N`。
- Format 显示 Email/Campaign。
- Published Badge 是固定信任标识，不代表 Adviser 可以切换状态。
- Detail 展示完整正文前的 Context Information，但仍只读。
- `Latest Version` 表示“当前服务端解析出的 Active version”，不代表开放版本历史。
- Category/Subcategory/Tag 失效后，Template 不应继续出现在 Adviser 列表；具体是过滤整条 Template 还是容忍部分 Optional Metadata 缺失，遵循 7.1 的已确认门禁。

### 8.9 Use Template

Use Template 与 Preview 共用 Visibility Guard，但不共用响应模型：

1. 用户从 Card、Detail 或 Preview 点击 Use Template。
2. 前端只发送 `emailCode`。
3. 后端在点击时重新查询最新 Active version，保证不使用旧页面缓存。
4. `is_campaign=0` 路由到 Email Composer；`is_campaign=1` 路由到 Campaign Builder。
5. 下游初始化可读取正文、正文图片和 `file_keys` 附件引用。
6. 如果 Template 已被 Deactivate/Delete、Active 不存在或下游初始化失败，前端停留原页并显示可重试错误。
7. 成功后由下游模块接管可编辑副本；不得反向修改 Library Template。

当前尚未确认 Campaign 管理入口、Email/Campaign 初始化 API、Payload、附件 URL/Token 获取方式以及失败错误码。因此本节只能冻结调用边界，不能冻结接口字段。

## 9. API 设计

### 9.1 API 能力对比

| 能力 | LEAD-93 / Existing | LEAD-308 变化 |
|---|---|---|
| Published List | CM Published Tab；支持版本 Metadata 查询 | 新增 Adviser Card View、强制权限、无 Status、无 Draft indicator |
| Category Tree | CM taxonomy tree | 增加 Published Count，只读 |
| Filter Options | 固定 taxonomy | 仅四组且只返回 Published 使用中的值 |
| Detail | CM Detail 可能选 Draft/Active | Adviser 永远重新解析 Active |
| Preview | 复用正文 Renderer | Adviser Published-only + Metadata；不含附件 |
| Use Template | 不属于 CM 管理方案 | 新增激活解析和下游路由 |

### 9.2 建议端点

以下路径仅表示能力拆分，不是冻结 API Contract：

| Method | 建议 Endpoint | 用途 | Contract 状态 |
|---|---|---|---|
| `GET` | `/adviser/template-library/templates` | List/Search/Filter/Sort/Page | 待现有 Controller/DTO 核对 |
| `GET` | `/adviser/template-library/categories` | Category tree + Count | Count 口径待确认 |
| `GET` | `/adviser/template-library/filter-options` | 四组 Tag Filter Option | 返回 Count 与否待确认 |
| `GET` | `/adviser/template-library/templates/{emailCode}` | Active Detail | 待核对 |
| `POST` | `/adviser/template-library/templates/{emailCode}/preview` | Active 正文 + Metadata Preview | Renderer Contract 待核对 |
| `POST` | `/adviser/template-library/templates/{emailCode}/use` | 重读 Active 并初始化下游 | 下游 Contract 待确认 |

### 9.3 List Request 建议模型

```json
{
  "isCampaign": 0,
  "keyword": "retirement",
  "categoryId": 1001,
  "subcategoryIds": [1101],
  "tagFilters": {
    "CONTENT_TYPE": ["CONTENT_TYPE_EMAIL"],
    "FINANCIAL_NEED": ["FINANCIAL_NEED_RETIREMENT"]
  },
  "sort": "NEWEST",
  "page": 1,
  "pageSize": 20
}
```

`isCampaign` 在 LEAD-93 查询中被定义为必传，但 LEAD-308 Library 同时包含 Email 和 Campaign 的产品表现尚未确认。上例只表达现有单类型查询，不代表最终 Adviser Contract。

请求中不得出现 `status`、`versionStatus`、`version`、`emailStatus` 或 `includeDraft`。

### 9.4 List Response 建议模型

```json
{
  "items": [
    {
      "emailCode": "815645091883520000",
      "title": "Retirement planning",
      "description": "Template description",
      "format": "EMAIL",
      "thumbnailUrl": null,
      "publishedDate": "2026-07-15T09:30:00+02:00",
      "category": {"id": 1001, "name": "Retirement"},
      "subcategories": [{"id": 1101, "name": "Planning"}],
      "tags": [
        {"groupCode": "FINANCIAL_NEED", "groupName": "Financial Need", "tagCode": "RETIREMENT", "tagName": "Retirement"}
      ],
      "published": true,
      "latestVersion": true
    }
  ],
  "page": 1,
  "pageSize": 20,
  "total": 1
}
```

样例值只用于说明结构，真实响应包络、时间格式、字段命名和空值规则必须由 API Contract 冻结。

### 9.5 错误语义

| 场景 | 建议语义 | 待核对 |
|---|---|---|
| 无 Adviser 权限 | `403 Forbidden` | 现有权限框架错误码/包络 |
| Template 不存在或不可见 | `404 Not Found` | 是否统一隐藏 Deactivate/Delete 原因 |
| Keyword 少于 2 字符 | `400 Validation Error` 或前端不发请求 | 需统一 Contract |
| 非法 Sort/Tag/Category | `400 Validation Error` | 字段级错误格式 |
| Preview Renderer 失败 | 可重试业务错误 | 现有 Renderer 错误码 |
| Use Template 下游失败 | 保持当前页并返回可重试错误 | 下游初始化错误码 |
| 多个 Active 脏数据 | 服务端错误并告警，不返回任意一条 | 日志/告警规范 |

## 10. 数据库与 SQL 设计

### 10.1 变更结论

LEAD-308 本身不新增数据库实体，也不改变 LEAD-93 的表结构和写流程：

- **DDL：无。**
- **DML：无。**
- **QUERY：新增 Adviser Published-only List、Count、Facet、Detail、Preview 和 Activation 查询。**

查询设计见 [QUERY_adviser_template_library.sql](sql/QUERY_adviser_template_library.sql)。该文件把已确认条件和未确认决策分开标注；在 P0 项关闭前不能直接绑定生产 Mapper。

### 10.2 索引复用

优先复用 LEAD-93 已设计索引：

- `iic_msg_email_config(status, email_status, is_campaign, updated_date, email_code)`
- `iic_msg_email_config_version(version_status, status, email_code, updated_date)`
- `iic_msg_email_config_version(category_id, version_status, status, email_code)`
- Category relation 的 `email_code + version + status` 和 `subcategory_id` 索引。
- Tag relation 的 `group_code + tag_code + status + email_code + version` 索引。

上线前必须对真实 List、Count、Category Count、Filter Option 和 Activation SQL 执行 `EXPLAIN`。在没有生产数据量和现有索引证据前，本文不新增猜测性索引。

### 10.3 数据一致性检查

- 同一 `email_code` 不得存在多个有效 Active version。
- Active version 的主 Category 必须有效。
- Active version 至少有一个有效 Subcategory relation。
- Active version 必须有四组 Mandatory Tag 的有效关系。
- Relation 的 `version` 必须真实存在且未软删除。
- Adviser List Count 必须按逻辑 Template 去重，不能按 Join 行数计算。

## 11. 权限与安全

- 后端通过现有认证上下文识别 Adviser；禁止前端声明角色。
- Adviser API 仅开放读和激活入口，不复用任何 CM 写 DTO。
- 所有入口统一强制 Tenant/Country 数据范围。
- Preview 使用现有正文净化策略，不执行不可信脚本。
- Search Highlight 由前端在转义后的文本上实现，避免注入。
- Sort 只允许后端枚举映射。
- `emailCode` 不可用于越权读取 Draft 或其他 Tenant 数据。
- Preview 响应不包含 `file_keys`、S3 Key 或附件下载 URL。

真实 Adviser Authority Code、Spring Security/Annotation 表达式和 Tenant/Country 注入方式待内网代码回填。

## 12. 性能与缓存

PRD 要求 Template Library 页面在不超过 3 秒内完成可用展示。建议拆分指标：

| 指标 | 建议目标 | 状态 |
|---|---|---|
| List API P95 | 小于 2 秒 | 需结合现有网关和数据量确认 |
| 首屏可用 | 小于等于 3 秒 | PRD 已要求 |
| Search debounce | 300ms | 方案决定 |
| Preview loading | 明确 Loading 状态 | PRD 已要求 |

首版不引入 Redis Cache，避免 Category/Tag/Publish 后产生一致性问题。若性能测试证明数据库查询不能达标，再单独设计带版本或短 TTL 的只读缓存；不能在没有数据证据前加入缓存。

## 13. 前端状态与交互

- Template Library 使用统一 Query State，任何筛选变化将页码重置到第一页。
- 请求采用 latest-response-wins 或取消前一个请求，防止快速输入造成旧结果覆盖新结果。
- Loading、Empty、No Search Result、No Filter Result 和 Error 分开呈现。
- Preview 使用 Modal 还是独立 Route 由现有前端框架和 Figma 决定，但返回时必须恢复 Query State 和滚动位置。
- Web/Mobile 共享数据 Contract；布局差异不改变查询语义。
- Description Tooltip、Tag `+N`、Search Highlight 必须处理长文本和移动端换行。

## 14. 异常与边界场景

| 场景 | 预期行为 |
|---|---|
| Active + Draft 共存 | 只显示 Active，不显示 Draft Indicator |
| 页面加载后发布了新版本 | List 可暂时显示旧快照；Preview/Use 点击时重新解析新 Active |
| 页面加载后 Deactivate/Delete | Preview/Use 返回不可用，前端刷新当前列表 |
| Category 被软删除 | Active/Schedule/Draft 会阻止删除；若存在脏数据，Adviser 查询过滤并告警 |
| Filter Value 被停用 | 不再出现在 Option；已有 URL/State 值返回校验错误或被忽略，Contract 待定 |
| 无匹配结果 | 返回空 `items` 和 `total=0`，不是业务异常 |
| 缩略图不存在/加载失败 | 前端显示默认占位图，不影响 Preview/Use |
| Preview 无附件能力 | 正文和 Metadata 正常显示，不出现附件错误 |
| Use Template 附件失败 | 下游初始化失败或按下游容错处理；不得影响 Library Template |
| 多个 Active | 不任意选择；记录数据一致性错误并返回服务端异常 |

## 15. 测试策略

### 15.1 后端

- Published-only 条件和 Adviser 权限不可绕过。
- Active + Draft、Active + Schedule、Expired-only、Deactivate、Soft Delete 组合。
- Metadata 必须来自 Active version。
- Keyword 三字段、2 字符门槛、大小写不敏感和特殊字符转义。
- 同 Group OR、跨 Group AND、Category/Search/Tag 联合条件。
- 多 Relation 去重、List/Count 一致和稳定分页。
- 五种 Sort 的枚举校验；Most Relevant 在规则冻结后补齐。
- Preview 不读取附件、不写数据库。
- Use Template 点击时重读 Active。
- Tenant/Country/Role 越权测试。

### 15.2 前端

- Card 内容、截断、Tooltip、缩略图占位和 Tag `+N`。
- Category 展开/折叠、Count、选中态和 Chip 同步。
- Search debounce、Enter、取消请求、Highlight、Clear。
- Filter Panel 与 Chips 双向同步。
- Clear All 同时恢复 Category、Sort、Page。
- Preview Close/Back 恢复搜索、筛选、排序和滚动位置。
- Web/Mobile 视口下无重叠、溢出或不可操作控件。
- 空状态、Loading、Renderer Error、Activation Error。

### 15.3 集成与性能

- 与 LEAD-93 Publish 联调：发布后 Adviser 只看到新 Active Metadata。
- 与 Deactivate/Delete 联调：不可继续 Preview/Use。
- Email Composer 初始化和可编辑副本隔离。
- Campaign Builder 初始化和可编辑副本隔离。
- 附件仅在 Use Template 下游加载，Preview 不发起附件请求。
- 首屏、Category 切换、Search、Filter 和 Sort 的 P95 性能。

## 16. 上线与兼容

- LEAD-308 不改变 CM 的 Save Draft、Publish、Schedule、Cancel Schedule、Deactivate 或 Delete。
- 新 Adviser API 建议独立灰度，避免改变现有 Published Tab 响应。
- 若复用现有 List Mapper，必须通过新 Service 强制 Adviser Scope，不能仅依赖前端参数。
- LEAD-93 数据迁移和 Seed 必须先完成，LEAD-308 才能正确显示 Category/Tag。
- 回滚 LEAD-308 时只回滚 Adviser 前端和只读 API，不回滚 LEAD-93 Metadata 数据。

## 17. 开发前待确认

### 17.1 P0：未关闭前不能冻结实现

| ID | 问题 | 为什么必须确认 | Owner |
|---|---|---|---|
| P0-01 | Adviser Library 是 Email/Campaign 混合列表，还是按类型切换/分开请求？ | LEAD-93 当前要求 `is_campaign` 必传，PRD 页面同时描述两种 Format | BA/PO + FE/BE |
| P0-02 | Most Relevant 的字段权重、匹配方式和稳定次序是什么？ | 直接决定 SQL/搜索实现与验收结果 | BA/PO |
| P0-03 | 默认“category order / Newest First”的准确排序优先级是什么？ | PRD 存在两种可执行解释 | BA/PO |
| P0-04 | Published Date 是否固定映射 Active version 的 `effective_from`？ | 影响 Card、Detail 和 Newest/Oldest | BA/PO |
| P0-05 | Campaign Builder 的入口、初始化 API、Payload 和失败 Contract 是什么？ | LEAD-321 Campaign 路径无法开发 | Campaign Owner |
| P0-06 | Email Composer 的现有入口、Payload、附件和正文图片加载 Contract 是什么？ | LEAD-321 Email 路径无法联调 | Email Owner |
| P0-07 | Adviser List/Detail/Preview 的真实 Controller、DTO、Response Envelope 和权限 Code 是什么？ | 不能根据建议端点修改代码 | 内网代码核对 |
| P0-08 | 现有 Renderer 的入口、输入、净化、输出和错误码是什么？ | Preview 必须复用而非重写 | 内网代码核对 |

### 17.2 P1：对应功能完成前确认

| ID | 问题 | 影响范围 |
|---|---|---|
| P1-01 | Category Count 是全局 Published Count 还是随 Search/Tag Filter 联动？ | Category API/SQL/交互 |
| P1-02 | Filter Option 是否返回 Count，零值是隐藏还是禁用？ | Filter Panel |
| P1-03 | Preview/Detail 是否展示 Optional `Proposition`、`Source`？ | Metadata View Model |
| P1-04 | `thumbnail_key` 如何解析 URL，缺失和失效如何处理？ | Card Thumbnail |
| P1-05 | Keyword 少于 2 字符由后端拒绝还是仅前端不请求？ | API Error Contract |
| P1-06 | Filter Value 在请求期间失效时拒绝、忽略还是返回空结果？ | 并发与错误语义 |
| P1-07 | Data Tracking 是否进入本期；若进入，事件平台和字段是什么？ | Nice-to-Have 埋点 |

### 17.3 已确认不再询问

- Preview 只展示正文和 Metadata，不支持附件预览。
- Use Template 的附件预加载要求保留，与 Preview 边界不冲突。
- Adviser 只看 Active/Published，不看 Draft/Schedule/Expired。
- Metadata 按 version 保存并按 Active version 读取。
- Adviser 不展示 Status Filter。
- Adviser Filter Panel 使用四个 Mandatory Tag Group。
- LEAD-308 不新增独立数据库状态，不修改现有 Template 生命周期。
- 本期不新增审计表或强制审计事件。

## 18. 内网代码核对清单

请内网 AI 或开发人员只回填代码事实，并为每项提供模块、文件、类/方法、Mapper ID 和脱敏样例：

1. Published List/Count 的真实 Controller、DTO、Service、Mapper 和完整过滤条件。
2. Adviser 权限 Code、注解/表达式和 Tenant/Country 数据范围注入。
3. Active Detail 选版逻辑以及多个 Active 脏数据的现有处理。
4. `thumbnail_key` 到可访问 URL 的真实解析链路。
5. Category tree、Tag taxonomy 现有接口和缓存行为。
6. Preview/Renderer 的真实入口、Input/Output、正文净化和错误码，并证明不加载附件。
7. Email Composer 的初始化入口、正文、图片和附件 Payload。
8. Campaign Builder 的初始化入口、正文、图片和附件 Payload。
9. 前端 Template Library 现有路由、状态管理、API Client 和权限组件。
10. 网关响应包络、分页格式、统一错误模型和日志规范。

在 P0-07/P0-08 完成前，本文的建议 Endpoint 和 JSON 只能用于对齐能力边界，不能视为最终 API Contract。

## 19. 开发准入结论

当前可以开始以下不依赖 P0 决策的工作：

- Adviser 页面框架、Card/Loading/Empty/Responsive 基础组件。
- Query State、Chips、Clear All 和前端筛选组合单元测试。
- 后端 Published-only Visibility Guard 的测试设计。
- LEAD-93 数据模型复用与 SQL `EXPLAIN` 准备。
- Preview UI 按“正文 + Metadata、无附件”实现 Mock。

以下工作应等待相应 P0 关闭：

- 最终 List API 和 Email/Campaign 混合查询。
- Most Relevant 和默认排序 Mapper。
- Published Date 字段绑定。
- Preview 与现有 Renderer 的真实集成。
- Email/Campaign Use Template 的端到端集成。

因此，本方案已经能够清楚界定 LEAD-308 的架构和增量范围，但在 P0 项完成之前还不能认定为可直接全面开发的冻结版本。
