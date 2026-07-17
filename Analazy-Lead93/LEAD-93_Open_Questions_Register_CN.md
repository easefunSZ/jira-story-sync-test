# LEAD-93 未确认项与现状核对登记册

> 状态：Active
> 更新日期：2026-07-17
> 适用范围：LEAD-93、与 LEAD-308 交叉的 Template Library/History 需求
> 详细方案：[V3 解决方案](LEAD-93_Template_Management_Solution_Design_CN_v3.md)
> 规则：本文件是所有未确认需求、未确认现状、待冻结 Contract 和实施门禁的统一索引。其他文档可以保留摘要，但状态与结论以本文件为准。

## 1. 使用规则

### 1.1 状态

| 状态 | 含义 |
|---|---|
| `OPEN-BUSINESS` | 需要 BA/PO 确认需求或验收口径 |
| `OPEN-UX` | 需要 UX/BA 确认页面展示或交互 |
| `OPEN-CODE` | 业务规则已确定，但真实内网实现尚未定位 |
| `OPEN-CONTRACT` | API 行为已确定，但 Endpoint、DTO 或 Error Code 未冻结 |
| `BLOCKED-DATA` | 设计框架已确定，但缺少正式业务数据或 Mapping |
| `PROVISIONAL` | 已有临时实现建议，但未获得最终签字 |
| `RESOLVED` | 已确认并已同步到设计基线 |

### 1.2 管理要求

1. 任何新不确定项必须先登记，再进入会议纪要、方案或开发任务。
2. 不允许把 `PROVISIONAL`、`CANDIDATE` 或 `TBD` 当成已批准需求。
3. 每项关闭时必须记录最终结论、确认人/来源、日期和受影响文档。
4. 业务问题与代码事实分开：代码不能替代 BA/PO 决策，业务决策也不能伪造 As-Is 代码证据。
5. “不阻塞全项目”不等于可以删除；必须写明它阻塞的具体功能或阶段。

## 2. P0：2026-07-16 站会新增问题

以下问题来自 LEAD-93 + LEAD-308 开发方案讨论，会直接改变当前 Master/Version 边界，应在修改数据模型前确认。

| ID | 未确认问题 | 当前已知事实 | 临时处理 | 影响 | Owner/冻结点 | 状态 |
|---|---|---|---|---|---|---|
| `REQ-01` | “Template 基本信息进入历史层级”具体包含哪些字段 | 当前已知 Master 字段至少包括 Template Name/Title=`config.email_name`、Description=`config.description`、Template Type/Format 候选字段=`config.is_campaign`（准确 UI 含义待确认）；其他 UI Basic Information 字段是否纳入未知 | 不假设字段范围，不修改 DDL | Version DDL、Save Draft、Publish、History、Search、Migration | BA/PO；Master/Version 模型修改前 | `OPEN-BUSINESS` |
| `REQ-02` | Template Name、Description、Format 版本化后，`iic_msg_email_config` 继续保存什么 | 当前方案把这三项作为 Master；站会方向与现方案冲突 | 候选方案是 config 只保留 Identity/状态，或保留当前 Active 投影兼容旧代码；尚未选择 | 读写 Source of Truth、双写一致性、旧接口兼容 | TL + BA/PO + 内网代码核对；DDL/API 开发前 | `OPEN-BUSINESS` |
| `REQ-03` | “记录到 Template History 层级”只要求数据库保存，还是 Version History 页面/API 也必须展示 | 当前方案保存 Category/Subcategory/Tag 到 version，但明确不展示 Expired Metadata | 在确认前不扩展 History API/UX | LEAD-308 History/Library UX、History DTO、查询 | BA/PO + UX；History 开发前 | `OPEN-BUSINESS` |
| `REQ-04` | 版本历史需要展示哪些基本信息和 Metadata | Template Name 是否必显已被提出；Description、Format、Category、Subcategory、Tag、Subject、正文等范围未知 | 不猜测 History 字段清单 | History Response、页面列/详情、权限 | BA/PO + UX；History Contract 冻结前 | `OPEN-BUSINESS` |
| `REQ-05` | 已有历史版本是否需要回填基本信息和 Category/Subcategory/Tag | 当前 Migration 候选只处理明确 Mapping 的 version，Q8 尚未冻结；历史版本没有可靠旧分类来源 | 不自动把当前值复制到全部历史版本 | Migration Mapping、历史真实性、数据量 | BA/PO + Data Owner；Migration Mapping 前 | `OPEN-BUSINESS` |
| `REQ-06` | 删除 Category/Subcategory 时是否移动历史版本 | 2026-07-15 与 Tracey 沟通结论及整体理解：不影响历史；当前方案只迁移 Active/Draft/Schedule，Expired 不迁移 | 继续保留当前实现建议，等待当天确认 | Reassign-and-Delete SQL、History 展示 | BA/PO/Tracey；2026-07-16 确认 | `PROVISIONAL` |
| `REQ-07` | Category 被软删除后，History 如何显示旧 Category/Subcategory 名称 | Category row 会保留 ID/Name；但当前有效树查询使用 `is_deleted=0`，不能直接复用于历史查询 | 若 History 要展示 Metadata，历史查询必须允许解析已软删除节点 | History Query/API/UX | BA/PO 确认 REQ-03 后由 Backend 冻结 | `OPEN-BUSINESS` |
| `REQ-08` | Category Description 最终是否属于需求，UX 是否展示/编辑 | 当前 AC 有该字段；DDL/API 已按 nullable optional 字段设计；计划下周确认 | 后端方案暂时保留 nullable `description`，不假设 UX 必须展示 | Category DDL、Create/Update DTO、UX | BA/PO + UX；2026-07-20 当周 | `PROVISIONAL` |
| `COPY-01` | Copy and Create 是否按当前方向复制选中版本的基本信息和版本内容并创建新的 Template，以及准确复制范围 | 当前仅确认它不能与 `/version/add` 或 Working Copy 创建直接等同；若最终确认需要后端承载，则新增 v2 Copy API | 不冻结源版本范围、复制字段、目标 `email_code`、附件策略、持久化时点和 Endpoint/DTO；当前 24 个接口不包含该能力 | Template 创建、版本详情、接口数量、Metadata/附件复制 | BA/PO + UX + Backend；Copy and Create 开发前 | `OPEN-BUSINESS` |

### 2.1 REQ-01 字段确认模板

BA/PO 应逐项勾选，不应只回复“基本信息全部版本化”：

| 候选字段 | 当前物理归属 | 是否进入 Version History | 是否在 History UX 展示 | 最终结论 |
|---|---|---|---|---|
| Template Name/Title (`email_name`) | config | 待确认 | 待确认 | OPEN |
| Description (`description`) | config | 待确认 | 待确认 | OPEN |
| Template Type/Format (`is_campaign`，UI 含义待确认) | config | 待确认 | 待确认 | OPEN |
| Email Subject (`version.title`) | version | 已在 version | 待确认 | OPEN-UX |
| Body/Text Content | version | 已在 version | 待确认 | OPEN-UX |
| Attachment Keys | version | 已在 version | 待确认 | OPEN-UX |
| Category/Subcategory/Tag | To-Be version metadata | 已在 version | 待确认 | OPEN-UX |
| 其他 Basic Information 页面字段 | 待内网/UX 列表 | 待确认 | 待确认 | OPEN |

## 3. 既有业务与 UX 待确认

| ID | 未确认问题 | 当前建议/临时规则 | 影响 | Owner/冻结点 | 状态 |
|---|---|---|---|---|---|
| `BUS-01`（原 `Q5`） | 79 个存量 Template 的分类、Tag、重复和淘汰 Mapping | PO/BA/Data Owner 提供逐条 Mapping 并签字 | 阻塞正式 Migration DML | PO/BA；Migration 执行前 | `BLOCKED-DATA` |
| `BUS-02`（原 `Q6`） | 在 Template Library 创建 Campaign 后进入哪个页面继续管理 | 后端统一支持 `is_campaign=1` 查询；不猜测前端入口 | 只阻塞 Campaign 前端流程 | BA/PO + UX；前端开发前 | `OPEN-UX` |
| `BUS-03`（原 `Q7`） | Expired V(N) 复用为 Draft 时，原 Metadata 引用已删除/失效节点如何处理 | 暂按：移除失效 Category/Subcategory；Mandatory Tag 使用 `Unclassified`；Publish 前重新校验 | Save Draft 边缘分支 | BA/PO；该分支开发前 | `PROVISIONAL` |
| `BUS-04`（原 `Q8`） | 一次性迁移覆盖哪些 version | 当前候选 Active/Draft/Schedule；SQL 只处理明确 `email_code + version` Mapping，不自动推导 | 阻塞 Mapping 和正式脚本 | BA/PO/Data Owner；Migration Mapping 前 | `OPEN-BUSINESS` |

## 4. API Contract 待冻结

行为已确定但字段未冻结的接口，不应被误报为业务需求不明确。

| ID | 待冻结内容 | 当前边界 | 影响 | 状态 |
|---|---|---|---|---|
| `API-02` | 字段级 Validation Error 结构 | 必须让前端定位字段；正式 JSON/HTTP Status 未冻结 | 所有新增校验 | `OPEN-CONTRACT` |
| `API-03` | Version Conflict 正式 Error Code/Payload | 复用现有行为，不新增锁/token；本轮确认的 `10000121` 是 Active version 删除拒绝，不是 Version Conflict | Publish、并发测试；Copy and Create 是否使用该错误取决于 `COPY-01` | `OPEN-CONTRACT` |
| `API-11` | History API 是否返回版本基本信息和历史 Metadata | 依赖 REQ-01 至 REQ-07 | LEAD-308 History | `OPEN-BUSINESS` |

正式字段和候选 Endpoint 详见 [API Contract](LEAD-93_API_Contract_Clarification_CN.md)。

## 5. As-Is 内网代码待核对

以下是“现有系统事实尚未取得代码证据”，不是重新讨论已确认业务规则。

| ID | 待核对现状 | 需要的证据 | 状态 |
|---|---|---|---|
| `C01` | Template 管理前端 Client、Controller、Service、Mapper、Entity 的完整入口 | 文件路径、类/方法、调用链 | `OPEN-CODE` |
| `C02` | Published List 完整 JOIN、过滤、Count、排序、分页、tenant/country | Mapper ID、完整 SQL、脱敏响应 | `OPEN-CODE` |
| `C03` | Draft List 三个 OR 分支括号、List/Count 一致性、最大数字版本实现 | Mapper ID、完整 SQL | `OPEN-CODE` |
| `C04` | Active/Draft/Schedule 共存时 Detail 如何选 version | API、Service、选版 SQL | `OPEN-CODE` |
| `C05` | Save Draft 五个状态分支和 `email_code` 生成点 | Service 分支、Mapper、请求和测试 | `OPEN-CODE` |
| `C06` | 现有 Version Conflict 的触发条件、事务范围、Update 0 行映射 | 状态判断、Update WHERE、异常类、响应 | `OPEN-CODE` |
| `C07` | Publish 校验、旧 Active 过期、Now/Future 状态和时间赋值顺序 | Service、Mapper、事务 | `OPEN-CODE` |
| `C08` | Schedule Save Draft/Delete 的真实入口及 relation 扩展点 | Controller、Service、Mapper | `OPEN-CODE` |
| `C09` | Active/Deactivate/Template Delete 的真实 API、幂等和调用点 | API、Service、Mapper、前端调用 | `OPEN-CODE` |
| `C10` | 附件上传/删除 API、S3 Key 与 `file_keys` 写入位置 | Controller、Service、配置 | `OPEN-CODE` |
| `C11` | Content Manager/Adviser/Publish/Delete/Category 权限和数据范围 | 注解、拦截器、角色常量、SQL | `OPEN-CODE` |
| `C12` | Reassign-and-Delete 如何接入操作者、事务和行锁 | Service/Mapper、事务、字段赋值 | `OPEN-CODE` |
| `C13` | 部署环境 Entity/ResultMap/索引是否与设计 DDL 一致 | Entity、Mapper、真实 DDL、`EXPLAIN` | `OPEN-CODE` |
| `C14` | 其余现有错误码和统一异常映射 | Base Path、v1 包络、必要 Header、DTO 字段、分页结构和南非业务时区已由 QA 验证；未覆盖错误仍需异常处理器证据 | `PARTIAL-CODE` |
| `C15` | 测试框架、fixture、feature control、Scheduler 开关和部署清单 | 测试、配置和部署文件 | `OPEN-CODE` |
| `C17` | 新增 Category CRUD/Reorder/Delete 应挂接到现有 Template 模块的哪些 Controller、Service、Mapper | 模块入口、事务、Mapper 和索引 | `OPEN-CODE` |
| `C18` | 已确认业务字段在 Form、DTO、Entity、Mapper 中的真实名称 | 字段映射和脱敏请求 | `OPEN-CODE` |
| `C19` | LEAD-308 当前 Version History/Template Library 实际 API、字段和页面数据来源 | 前端调用、Controller/DTO/Mapper | `OPEN-CODE` |

### 5.1 App 使用接口与共享数据影响核对

用户已确认 Mobile App 与 Web 当前使用同一套 Template API。现有代码材料仍只覆盖 Web 前端，但后端兼容边界可以按“App 与 Web 共享 `/web/msg/template/email/v1`”确定：

| 核对项 | 当前证据 | 结论 |
|---|---|---|
| PRD 平台范围 | 最新 PRD 写明 `Mobile、Web`；Adviser 可搜索、筛选、查看和使用 Published Template | Mobile 在需求基线内；若改为 Web-only，必须由 BA/PO 明确变更范围 |
| 已核对后端入口 | `iic-dae-message-center` 的 `EmailController`，前缀 `/web/msg/template/email/v1` | App 与 Web 共用该现有 API 入口 |
| 已核对前端 | `iic-dae-admin-sub-web`，包含 Content Manager 和 Adviser 页面 | 这是 Web 子应用，不作为 Mobile App 实现证据 |
| Mobile App Endpoint | 用户确认 App 当前使用与 Web 相同的 API | 不存在可独立修改而不影响 App 的现有 v1 Contract；Web-only 变更必须进入 v2 |
| 共享数据源 | Template 服务使用 `iic_msg_email_config`、`iic_msg_email_config_version`；LEAD-93 在同一库新增 Category/Tag 关系 | 不论 App 使用 v1 还是独立接口，只要读取同一数据，运行时和迁移数据变化都可能影响 App |

共享数据影响清单：

| 变更 | App 影响判断 | 控制要求 |
|---|---|---|
| 新增 `iic_msg_email_category`、Tag/Relation 表 | 对未查询新表的旧 App 无直接影响 | 旧 v1 查询不得因新增 INNER JOIN 丢失没有 Metadata 的记录 |
| `iic_msg_email_config_version.category_id` 新增为 nullable | DDL 本身向后兼容；Entity/ResultMap 是否兼容仍需代码核对 | v1 旧 DTO 不新增必填依赖，旧 Mapper 保持可运行 |
| 新增索引、修正字段注释 | 无业务行为影响 | 上线前核对重复索引和执行计划 |
| Web v2 增强及新增接口 | App 不调用时无直接接口契约影响 | 10 个增强接口和 9 个新增接口统一使用 v2；v1 不新增必填字段或 Metadata 依赖 |
| v1 `queryList` 增加必传 `is_campaign` | 如果 App 调用该接口且不传参数，会直接失败 | v1 不得新增必传；缺失时沿用旧默认语义，严格规则只放 v2 |
| v1 List/Detail 响应 | v1 不增加 Metadata 字段、不改变包络和现有 DTO | App 不需要适配 v2 字段；v1 回归作为兼容门禁 |
| Save Draft、Category/Tag 编辑 Draft | 在 Publish 前不应影响当前 Active 内容 | 所有写操作必须绑定明确 version，禁止覆盖 Active Metadata |
| Publish/定时生效切换 Active version | App 若读取 Published/Active，会看到新版本；这是共享业务结果，不受 API 前缀隔离 | 保持现有 Active 选择和 Published-only 语义 |
| Category 删除后的 Active Metadata Reassignment | 旧 App 不展示 Metadata 时内容不变；新查询会看到新分类 | 不修改正文、主表状态或 `version_status` |
| 一次性迁移修改 `email_name/description` | App 若展示这些字段，会立即看到变化 | 必须纳入 App 回归和业务 Mapping 审批 |
| 一次性迁移设置 `email_status=0` | App Published 查询若过滤 Enabled，会立即隐藏模板 | 属于明确的跨端业务影响，不能靠 `/v2` 隔离 |

已确认 Web 新能力统一使用 v2，Mobile App 继续使用现有 v1。该策略隔离了请求/响应契约失败和格式不兼容风险，但共享 Active 数据和一次性迁移仍会跨端生效，因此只能声明“App 接口兼容”，不能声明“App 业务数据完全无影响”。

详细证据回填格式见 [内网代码核对清单](LEAD-93_Internal_Code_Verification_Checklist_CN.md)。

## 6. 数据库、SQL 与 Migration 门禁

| ID | 未完成项 | 当前处理 | 冻结点 | 状态 |
|---|---|---|---|---|
| `DB-01` | 新表 `iic_msg_email_category`、version 新字段的最终类型/长度/索引 | 已形成候选 DDL，需 DBA Review 并核对关联 ID 类型与索引 | DBA DDL Review | `OPEN-CODE` |
| `DB-02` | Published/Draft/Search/Scheduler 新旧索引 `EXPLAIN` | 不在无真实 SQL 时批准索引 | DBA DDL Review | `OPEN-CODE` |
| `DB-03` | `QUERY_iic_msg_email_config.sql` 与真实 List/Count Mapper 合并 | 当前只有增量模板，不可直接替换现有 SQL | Mapper 开发前 | `OPEN-CODE` |
| `DB-04` | 完整 Tag Value Seed | 当前只有 Group/Unclassified 基础脚本，最终固定值待业务清单 | 发布脚本冻结前 | `BLOCKED-DATA` |
| `MIG-01` | 正式 Template Mapping 数据 | 对应 BUS-01 | Migration 执行前 | `BLOCKED-DATA` |
| `MIG-02` | 目标 version 范围 | 对应 BUS-04、REQ-05 | Staging 数据冻结前 | `OPEN-BUSINESS` |
| `MIG-03` | 若基本信息版本化，历史字段如何 Backfill | 不允许默认复制当前 Master 值到所有历史版本 | 新 Version DDL/DML 前 | `OPEN-BUSINESS` |
| `MIG-04` | Migration Log 独立事务由哪个发布工具/脚本执行 | 表和 SQL 模板已设计；实际执行器待部署环境确认 | Release Plan 前 | `OPEN-CODE` |

SQL 当前门禁见 [SQL Index](sql/README.md)。任何 `Partially Updated` 或 `Blocked` 文件不得进入部署包。

## 7. 文档冲突与依赖关系

| ID | 冲突/依赖 | 当前处理 | 状态 |
|---|---|---|---|
| `DOC-01` | 当前 V3 规定 `email_name/description/is_campaign` 属于 Master；REQ-01/02 可能要求版本化 | 在需求确认前，V3 仍代表当前基线，但不得据此关闭站会问题 | OPEN |
| `DOC-02` | 当前 V3/API 不展示 Expired Metadata；REQ-03/04 可能要求 History 展示 | 等待 History 范围确认后统一更新 V3、API、ER 和图 | OPEN |
| `DOC-04` | REQ-06 若确认“历史不迁移”，History 查询仍需解析软删除 taxonomy | 不能复用有效树查询；依赖 REQ-03 | OPEN |

## 8. 已确认且不应误列为开放项

以下事项已经确认，除非出现新的 PRD/BA 变更，不应重新作为待确认问题：

- `email_code` 由后端 Snowflake 生成并作为逻辑 Template Identity。
- Category/Subcategory/Tag 当前 To-Be 设计均按 `email_code + version` 保存。
- Save Draft 不因未来 `effective_from` 自动生成 Schedule；只有 Publish Future 进入 Schedule。
- Discard 未保存编辑是前端行为；已保存 Working Copy 复用 Version Delete。
- 附件可选、最大 10 MB、前端校验；Preview 不展示附件；Discard 不清理 S3。
- Active/Deactivate 复用现有逻辑，不重新 Publish。
- 现有 v1 成功包络为 `requestId/responseCode/responseMessage/data`，成功业务码为 `00000000`。
- Active/Published version 删除拒绝返回业务码 `10000121`；该错误不等同于 Version Conflict。
- Tag 每组可多选，4 个 Mandatory Group、2 个 Optional Group。
- Category/Subcategory 软删除后允许同名重建，只检查有效节点。
- Template taxonomy 使用新增专用表 `iic_msg_email_category`。
- 运行时没有新增 Audit Log；Migration Log 只记录一次性数据迁移。

## 9. 关闭记录

关闭任何条目前，在下表追加记录，并同步修改对应章节中的状态：

| ID | 最终结论 | 确认人/来源 | 日期 | 已同步文档 |
|---|---|---|---|---|
| `ARCH-01` | 新增 Template 专用 Category 表 `iic_msg_email_category` | 用户确认 | 2026-07-16 | V3、评审稿、ER/SVG、SQL Index 与全部 Category SQL |
| `APP-01` | Mobile App 当前与 Web 使用同一套 Template API；现有 v1 Contract 是共享兼容边界 | 用户确认 | 2026-07-16 | 本登记册 5.1 节 |
| `API-01` | Schedule 时间格式为 `yyyy-MM-dd HH:mm:ss`，统一按南非业务时区 `Africa/Johannesburg`（UTC+02:00）解释 | 用户确认 | 2026-07-17 | API Contract、V3、As-Is、测试材料 |
| `API-05` | `EX-01` 至 `EX-15` 的现有请求与响应字段均已通过 QA 实测确认 | 用户确认 | 2026-07-17 | API Contract、v1 As-Is、测试材料 |
| `BUS-05` | Category Reorder 提交同一 Parent 下全部有效同级节点的完整顺序，不接受局部变化 | TL 设计冻结 | 2026-07-17 | API Contract、V3、Mock、HTTP 示例 |
| `API-04` | `NEW-01` 至 `NEW-09` 的 Method、Path 和 DTO 按 API Contract 当前定义冻结为开发基线 | 用户授权按现有 API 风格先给出 Contract | 2026-07-17 | API Contract、联调包、Review/V3 |
| `API-06` | List Filter 字段冻结为 `isCampaign/categoryId/subcategoryIds/tagGroups` 和现有 keyword；默认 `updatedDate/false` | 用户授权设计冻结 | 2026-07-17 | API Contract、HTTP/Fetch/Mock |
| `API-07` | Request 使用 `categoryId/subcategoryIds/tagGroups`；Response 使用 `category/subcategories/tagGroups`，均绑定明确 version | 用户授权设计冻结 | 2026-07-17 | API Contract、V3 |
| `API-08` | Metadata Update 使用全量替换；`tagGroups` 必须包含完整 6 组，字段或任一 Group 缺失均失败 | 用户授权设计冻结 | 2026-07-17 | API Contract、Mock |
| `API-09` | Category 接口响应字段及稳定业务错误键按 API Contract 第 5、7 章冻结 | 用户授权设计冻结 | 2026-07-17 | API Contract、Mock |
| `API-10` | Category 创建信息字段冻结为 `createdBy/createdDate`；`description` 为 nullable optional | 用户授权设计冻结 | 2026-07-17 | API Contract、DDL/DTO |
| `BUS-06` | LEAD-93 新增和增强功能仅由 Web v2 提供；Mobile App 继续使用现有 v1；五个完全不变接口继续复用 v1 | 用户确认 | 2026-07-17 | V1 基线、V2 Contract、Review、V3、联调包 |
| `C22` | v1 响应结构和必填规则保持不变，v2 新字段不返回给 App；无需依赖 App 是否宽松反序列化来保证接口兼容 | v1/v2 隔离方案 | 2026-07-17 | V1 基线、V2 Contract、本登记册 5.1 节 |
|  |  |  |  |  |
