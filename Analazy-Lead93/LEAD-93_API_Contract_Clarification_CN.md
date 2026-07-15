# LEAD-93 Template Management API Contract 澄清与回填

> 状态：Draft for Internal Code Clarification  
> 日期：2026-07-15  
> 适用范围：LEAD-93 Template Management 相关前端、Controller、Service、Mapper、权限与错误处理  
> 说明：本文定义必须对齐的 API 业务语义和内网回填格式。Method、Path、DTO 类名、响应包络和错误码在获得内网代码证据前均不得视为已确认。

## 1. 文档目标

本文件作为 LEAD-93 API Contract 的独立工作文档，用于：

1. 固化已经确认的接口行为，避免前后端重复讨论业务规则。
2. 收集现有 DAE API 的真实 Method、Path、DTO、响应、权限和异常规范。
3. 标出 Existing/Reused、Existing/Changed 和 New 能力。
4. 为前后端联调、自动化测试和 Technical Design Approval 提供统一基线。

主技术方案：[LEAD-93_Template_Management_Solution_Design_CN_v2.md](LEAD-93_Template_Management_Solution_Design_CN_v2.md)。数据库 SQL、状态机和 migration 规则仍以主技术方案及 [SQL Index](sql/README.md) 为准。

## 2. 确定性标记

| 标记 | 含义 | 可否直接开发 |
|---|---|---|
| `CONFIRMED` | 已由 TL/BA/PO、数据库事实或现状行为确认 | 可按业务语义开发 |
| `CODE-VERIFY` | 目标行为已确认，但必须在内网定位现有入口和公共规范 | 完成代码核对后冻结 Contract |
| `CANDIDATE` | 仅为能力边界或建议表达 | 不得直接创建 Controller |
| `BUSINESS-OPEN` | 仍需 BA/PO 决策 | 不得冻结前端流程 |
| `NOT-APPLICABLE` | 本操作不需要该字段或机制 | 无需实现 |

## 3. 已确认的跨接口规则

### 3.1 权限与数据范围

- 所有 Content Manager 写接口必须由后端强制权限校验，不能只依赖前端隐藏按钮。
- Adviser 查询必须由后端强制 Published-only、Enabled 和未软删除条件，不允许请求参数绕过。
- tenant/country 数据范围必须由后端现有机制强制执行；真实权限表达式、注解和条件待内网回填。

### 3.2 Template 与 Version 标识

- `email_code` 由后端 Snowflake 生成，是逻辑 Template 的全局唯一业务标识。
- `email_code + version` 标识具体内容和 Metadata 版本。
- 新建 Template 首次 Save Draft 时后端生成 `email_code`；更新操作不得生成新的 `email_code`。
- Reassign、Preview Detail、Discard、Publish 等涉及 Working Copy 的操作必须明确目标 version 或由现有代码以可证明的规则选中 version。

### 3.3 状态与时间

- Save Draft 始终保存为 `version_status = 3`；即使 `effective_from > now` 也不转 Schedule。
- Publish Now：旧 Active `1 → 2`，目标 Draft `3 → 1`。
- Schedule Publish：目标 Draft `3 → 0`；旧 Active 在到点前保持。
- Cancel Schedule：同一 version `0 → 3`，并清空 `effective_from/effective_until`。
- Active/Reactivate 只更新 `config.email_status: 0 → 1`，不重新执行 Publish Validation。
- Deactivate/Delete 均不得重写 version row 的 `version_status`。

### 3.4 Metadata

- 主 Category 存储在目标 version 的 `category_id`。
- Subcategory 和 Tag 按 `email_code + version` 保存。
- Draft/Schedule Metadata 不影响当前 Active；目标 version 生效时 Metadata 一并生效。
- 页面和普通 Detail 只展示当前 Active version 的 Metadata；不提供 Expired 历史 Metadata 查看。
- 首次从 Active 创建 Draft Working Copy 时复制 Active 的 Category/Subcategory/Tag，保存后 Draft 与 Active 独立维护。
- Published metadata-only 修改更新当前 Active version，保持 `version_status = 1` 并立即生效。
- 同一 Tag Group 对单个 Template Version 最多选择一个 Tag Value。

### 3.5 Validation 与附件

- Draft：Template Title 必填；Description、Category/Subcategory、发布必填 Tag 可暂缺。
- Publish：Title、Description、Format、主 Category、至少一个有效 Subcategory、4 个 Mandatory Tag Group 和正文必填。
- Email/Campaign 附件均可选；前端存在附件时校验大小和格式，后端沿用现有 `file_keys` 处理。
- 附件大小和格式由前端校验；后端不新增对应校验。Discard Draft 不清理 S3 对象或 `iic_msg_file_upload` row。
- Preview 复用现有能力，只展示正文和 Metadata，不读取、下载或渲染附件，不持久化请求内容。

### 3.6 删除留痕边界

- 只有 [LEAD-307](https://oldmutualig.atlassian.net/browse/LEAD-307) 明确要求 Category/Subcategory 软删除记录 `Deleted By`、`Deleted Date and Time`，并保留原 ID、Name。
- 数据库使用 `deleted_by/deleted_date` 满足该要求；不新增独立审计表或审计事件。
- 其他操作不增加 LEAD-93 专用 Audit Contract。

## 4. 公共 Contract 待回填

以下项目必须从内网同类 API 和公共组件中提取，不能由本文件自行发明：

| 项目 | 内网必须回填 | 状态 |
|---|---|---|
| Base Path / Gateway Prefix | 服务统一前缀、版本号和网关路由 | `CODE-VERIFY` |
| Response Envelope | success/data/code/message/traceId 等真实结构 | `CODE-VERIFY` |
| Pagination | page/pageSize 或 current/size，total 类型，默认值和上限 | `CODE-VERIFY` |
| Date/Time | ISO 格式、时区、序列化规则和 Schedule 入参格式 | `CODE-VERIFY` |
| Validation Error | 字段级错误结构，是否支持多个字段错误 | `CODE-VERIFY` |
| Authentication | 用户、tenant、country 从 token/header/context 的获取方式 | `CODE-VERIFY` |
| Authorization | Content Manager/Adviser/Publish/Delete 的权限表达式 | 后端强制已确认；表达式 `CODE-VERIFY` |
| Idempotency | 幂等键、重复请求处理和重复 Active/Discard 行为 | `CODE-VERIFY` |
| Concurrency | revision/token/updated_date/DB id 及冲突响应 | `CODE-VERIFY` |

## 5. 接口清单与冻结门禁

| 操作 | 类型 | 已确认业务行为 | Contract 冻结前必须回填 |
|---|---|---|---|
| Published List | Existing/Changed | Active + Enabled；增加 `is_campaign` 和 Metadata Filter | 真实 List/Count SQL、Path、分页、排序、响应 version |
| Draft List | Existing/Changed | 保留现有三个 OR 分支；增加 Filter | 完整括号、List/Count、最终 result version |
| Template Detail | Existing/Changed | 普通查看返回 Active Metadata；编辑 Working Copy 返回 Draft Metadata | Active/Draft/Schedule 共存时选版 |
| Save Draft | Existing/Changed | 保存 version 及其 Metadata；状态保持 Draft | Insert/Update 入口、DTO、事务、并发 token |
| Publish Now | Existing/Changed | 统一 Validation；原子切换新旧版本 | 真实入口、事务、错误和冲突响应 |
| Schedule Publish | Existing/Changed | Validation 后目标 Draft `3 → 0` | effective time DTO、时区和真实入口 |
| Cancel Schedule | Existing/Reused | 同一 version `0 → 3` 并清空时间 | 真实入口和幂等响应；Scheduler 本身不改 |
| Active/Reactivate | Existing/Reused | 只恢复 `email_status = 1` | 真实 API、权限和重复请求行为 |
| Deactivate/Delete | Existing/Changed | 保持现有状态语义；Delete 扩展 relation 软删除 | 真实 API、事务和幂等行为 |
| Category Tree/CRUD/Reorder | New/Reuse | 两级 taxonomy、全局重名、受控软删除；有效节点为 `is_deleted=0 AND category_level IN (1,2)`；Delete 写 `deleted_by/deleted_date` | 现有 Category 能力复用范围和公共 API 规范 |
| Tag Taxonomy | New | 只读固定字典 | Path、响应模型和缓存策略（如现有） |
| Reassign Metadata | New | 更新指定 version；不新建 version、不改状态 | DTO、目标 version 校验和事务 |
| Preview | Existing/Reused | 复用现有能力；临时正文 + Metadata，只读、不含附件 | 真实 Renderer 入口、sanitize、请求/响应模型 |
| Discard Draft | Existing/Changed | 区分 Working Copy、新建 Draft、未保存编辑；不清理 S3/file row | 真实 API和幂等响应 |
| Attachment Upload/Delete | Existing/Reused | 可选、10 MB、格式限制、S3；前端校验 | 现有 API 和 `file_keys` 写入方式 |

## 6. 业务字段模型

以下名称是业务字段，不代表真实 DTO 属性名。内网回填时必须给出实际名称、类型、必填性和差异。

### 6.1 Template Summary / Detail

| 业务字段 | 来源 | 规则 |
|---|---|---|
| Template Title | `config.email_name` | Draft/Publish 必填 |
| Description | `config.description` | Draft 可空，Publish 必填 |
| Format | `config.is_campaign` | `0=Email`, `1=Campaign` |
| Email Subject | `version.title` | 发布校验按 PRD执行 |
| Version | `version.version` | Metadata 关联键 |
| Lifecycle Status | `version.version_status` | `0/1/2/3` |
| Content | version content fields | 随 version 保存 |
| Effective Time | version effective fields | Save Draft 可暂存；Publish 决定 Schedule |
| Attachment Keys | `version.file_keys` | 可选 |
| Primary Category | `version.category_id` | Draft 可空，Publish 必填 |
| Subcategory IDs | relation table | Publish 至少一个有效值 |
| Tags | relation table | 每组单选；4 个组 Publish 必填 |

### 6.2 Search / Filter Request

| 业务字段 | 规则 | 状态 |
|---|---|---|
| Tab | Published/Draft | `CONFIRMED` |
| `is_campaign` | 必传，`0/1` | `CONFIRMED` |
| Keyword | 只匹配 Template Title、Description、Tag Name | `CONFIRMED` |
| Category | 单选 | `CONFIRMED` |
| Subcategory | 多选；必须属于所选 Category | `CONFIRMED` |
| Tags | 同维度或同 Group 多值 OR/ANY；跨维度 AND | `CONFIRMED` |
| Status Filter | Published 不允许；Draft/Content Manager 保留现有能力 | `CONFIRMED` |
| Page/Sort | 真实字段名、默认值、上限和排序待回填 | `CODE-VERIFY` |

### 6.3 Save Draft / Publish Request

| 字段组 | Save Draft | Publish |
|---|---|---|
| `email_code` | 新建首次保存由后端生成；更新时使用已有值 | 必须定位已有 Template |
| `version` | 必须明确目标或由现有规则可证明地选择 | 必须明确目标 Draft/Schedule |
| Master Fields | 保存 Template Title/Description/Format | 执行发布必填校验 |
| Version Content | 保存 | 执行发布必填校验 |
| Effective Time | 可暂存，仍为 Draft | 决定立即 Active 或 Schedule |
| Category/Subcategory/Tags | 可不完整；缺失 Mandatory Tag 使用 Unclassified | 必须完整有效 |
| Attachments | 可选；前端校验 | 可选；前端校验 |
| Concurrency Token | 待内网确定 | 待内网确定；冲突不得覆盖 |

## 7. 操作级 Contract 回填表

每一行必须附代码证据和至少一组脱敏 Request/Response。`NOT_FOUND` 不能改为 `CONFIRMED`，除非提供文件路径、类/方法或 Mapper ID。

| 操作 | Method + Path | Controller/Client | Request DTO | Response DTO | Validation/Error | 权限 | 事务/并发 | 证据 | 状态 |
|---|---|---|---|---|---|---|---|---|---|
| Published List | 待回填 | 待回填 | 待回填 | 待回填 | 待回填 | 后端强制；表达式待回填 | N/A | 待回填 | `NOT_FOUND` |
| Draft List | 待回填 | 待回填 | 待回填 | 待回填 | 待回填 | 后端强制；表达式待回填 | N/A | 待回填 | `NOT_FOUND` |
| Template Detail | 待回填 | 待回填 | 待回填 | 待回填 | 待回填 | 后端强制；表达式待回填 | 待回填 | 待回填 | `NOT_FOUND` |
| Save Draft | 待回填 | 待回填 | 待回填 | 待回填 | 待回填 | 后端强制；表达式待回填 | 待回填 | 待回填 | `NOT_FOUND` |
| Publish Now | 待回填 | 待回填 | 待回填 | 待回填 | 待回填 | 后端强制；表达式待回填 | 待回填 | 待回填 | `NOT_FOUND` |
| Schedule Publish | 待回填 | 待回填 | 待回填 | 待回填 | 待回填 | 后端强制；表达式待回填 | 待回填 | 待回填 | `NOT_FOUND` |
| Cancel Schedule | 待回填 | 待回填 | 待回填 | 待回填 | 待回填 | 后端强制；表达式待回填 | 待回填 | 待回填 | `NOT_FOUND` |
| Active/Reactivate | 待回填 | 待回填 | 待回填 | 待回填 | 待回填 | 后端强制；表达式待回填 | 待回填 | 待回填 | `NOT_FOUND` |
| Deactivate | 待回填 | 待回填 | 待回填 | 待回填 | 待回填 | 后端强制；表达式待回填 | 待回填 | 待回填 | `NOT_FOUND` |
| Delete Template | 待回填 | 待回填 | 待回填 | 待回填 | 待回填 | 后端强制；表达式待回填 | 待回填 | 待回填 | `NOT_FOUND` |
| Category Tree | 待回填 | 待回填 | 待回填 | 待回填 | 待回填 | 后端强制；表达式待回填 | N/A | 待回填 | `NOT_FOUND` |
| Category Create/Update | 待回填 | 待回填 | 待回填 | 待回填 | 待回填 | 后端强制；表达式待回填 | 待回填 | 待回填 | `NOT_FOUND` |
| Category Reorder | 待回填 | 待回填 | 待回填 | 待回填 | 待回填 | 后端强制；表达式待回填 | 待回填 | 待回填 | `NOT_FOUND` |
| Category Delete | 待回填 | 待回填 | 待回填 | 待回填 | 待回填 | 后端强制；表达式待回填 | 待回填 | 待回填 | `NOT_FOUND` |
| Tag Taxonomy | 待回填 | 待回填 | 待回填 | 待回填 | 待回填 | 后端强制；表达式待回填 | N/A | 待回填 | `NOT_FOUND` |
| Reassign Metadata | 待回填 | 待回填 | 待回填 | 待回填 | 待回填 | 后端强制；表达式待回填 | 待回填 | 待回填 | `NOT_FOUND` |
| Preview | 待回填 | 待回填 | 待回填 | 待回填 | 待回填 | 后端强制；表达式待回填 | 不持久化 | 待回填 | `NOT_FOUND` |
| Discard Draft | 待回填 | 待回填 | 待回填 | 待回填 | 待回填 | 后端强制；表达式待回填 | 待回填 | 待回填 | `NOT_FOUND` |
| Attachment Upload/Delete | 待回填 | 待回填 | 待回填 | 待回填 | 待回填 | 后端强制；表达式待回填 | 待回填 | 待回填 | `NOT_FOUND` |

## 8. 语义错误目录

下表只定义错误语义，不冻结正式 code/HTTP status。

| 错误语义 | 触发条件 | 必须保证的结果 | 正式表达 |
|---|---|---|---|
| Validation Failed | Publish 必填字段或关系不完整 | Draft 和旧 Active 不变；返回字段级错误 | `CODE-VERIFY` |
| Version Conflict | 并发 token/状态不再匹配 | 不覆盖最新版本；提示重新加载 | `CODE-VERIFY` |
| Schedule Exists | Schedule 期间 Save Draft | 不创建 Draft；提示先 Cancel Schedule | `CODE-VERIFY` |
| Invalid Category Hierarchy | Subcategory 不属于主 Category | 整体拒绝，不做部分保存 | `CODE-VERIFY` |
| Category In Use | Active/Draft/Schedule 引用目标节点 | Category/Subcategory 均保持 | `CODE-VERIFY` |
| Category Not Found | 节点不存在或已软删除 | 不写入关系 | `CODE-VERIFY` |
| No Draft | 重复 Discard 或目标 Draft 不存在 | 幂等成功或明确错误，保持现状 | `CODE-VERIFY` |
| Invalid Campaign Type | `is_campaign` 缺失或非法 | 不执行无类型全量查询 | `CODE-VERIFY` |
| Attachment Invalid | 前端检测到大小或格式非法 | 不提交保存/发布请求 | `CONFIRMED` |
| Permission Denied | 后端权限或数据范围失败 | 不返回或修改越权数据 | `CODE-VERIFY` |

## 9. 脱敏样例要求

每个接口至少提供：

1. 正常 Request/Response。
2. Validation Failure。
3. Permission/Data Scope Failure。
4. 写接口的重复请求结果。
5. Save Draft/Publish/Reassign 的 Version Conflict 样例。

脱敏时保留字段名、类型、空值、枚举、嵌套和分页结构；Template Title、正文、邮箱、用户和业务值使用占位符。

## 10. 内网 AI 回填指令

> 阅读 DAE Template Management 前端 API client、Controller、DTO、Service、Mapper、统一响应/异常处理和权限代码。按本文第 4、5、7、8、9 节逐项回填。每个结论必须提供模块、文件路径、类/方法或 Mapper ID；SQL 保留 JOIN/WHERE/ORDER BY，样例做业务数据脱敏。区分 CONFIRMED、PARTIAL、NOT_FOUND 和 BUSINESS_DECISION。不得根据候选 URL 或命名猜测实现，不得修改代码。

## 11. Contract 冻结条件

满足以下条件后，API Contract 才可以进入前后端联调基线：

- Published/Draft List、Count、Detail 的 result version 规则已提供代码证据。
- Save Draft/Publish 的真实入口、事务和并发字段已确认。
- 公共 Response、Pagination、Date/Time 和 Error 模型已确认。
- 后端权限与 tenant/country 数据范围已确认。
- Preview 复用及附件前端校验/不清理边界已确认；真实接口模型已完成内网回填。
- 每个本期接口至少有一组脱敏正常和失败样例。
- 前端字段模型与后端 DTO 完成签字确认。

Campaign 创建后的管理页面/路由当前为 `BUSINESS-OPEN`，不阻止后端 Contract 事实调查，但阻止相关前端导航和页面流转冻结。
