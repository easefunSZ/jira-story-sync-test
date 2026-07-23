# LEAD-93 内网 AI 分阶段修改提示词

> 变更集合：`CHG-20260721-01`、`CHG-20260721-02`、`CHG-20260722-01`、`CHG-20260722-02`、`CHG-20260723-02`、`CHG-20260723-03`。  
> 使用规则：一次只发送一个阶段。内网 AI 完成该阶段并返回证据后，再发送下一阶段。不得让它根据全部 PRD 一次性改完。

## 0. 发送前准备

随提示词一并提供当前中文基线：

1. `LEAD-93_CHANGELOG_CN.md`
2. `LEAD-93_Template_Management_Solution_Design_CN_v3.md`
3. `LEAD-93_API_Contract_Clarification_CN.md`
4. `LEAD-93_Open_Questions_Register_CN.md`

**接口字段唯一基线：** Endpoint、请求字段、响应字段和错误语义必须以 `LEAD-93_API_Contract_Clarification_CN.md` 为准。NEW-12 首次影响评估返回 `data.reassignRequired` 与 `data.affectedTemplateCount`；不得输出旧的 `data.impact` 或 Active/Draft/Schedule 分项。

所有业务失败保持 HTTP 200 与现有 `IICResponseModel` 公共包络。不要编造 `responseCode` 数值；必须复用项目既有 `IICException`、全局异常处理和实际错误码机制。

---

## 阶段 0：只调查并冻结实现切分

```text
你是 DAE 后端代码分析工程师。请只调查，不修改文件，不执行数据库写操作。

变更集合：CHG-20260721-01、CHG-20260721-02、CHG-20260722-01、CHG-20260722-02、CHG-20260723-02、CHG-20260723-03。

请阅读随附的变更日志、详细方案、API Contract 和开放项登记册。以变更日志中的 CONFIRMED 规则确定业务范围，以 API Contract 确定 Endpoint 与字段；不得把 OPEN、PROVISIONAL 或历史草稿当作要求。

调查目标：
1. 找到 v1/v2 Email Controller、DTO、Service、Mapper/XML、Entity、全局异常处理、鉴权和测试入口。
2. 定位以下接口及其所有调用方：
   - EX-01/EX-02 List
   - EX-05 /v2/add
   - EX-06 /v2/update
   - EX-16 /v2/publish
   - NEW-10 /v2/copy
   - 现有 /v2/category/metadata
   - 所有 Category Delete、Impact、Reassign-and-Delete 入口
3. 定位 config、version、Category、Subcategory/Tag relation、Template Change History、Category Change History、Delete Audit 的真实表、Mapper 和事务边界。
4. 说明 v1 的必填参数、响应包络和 v2 当前复用点，确认 v1 不会被修改。
5. 找出 `responseCode`、`responseMessage`、fieldErrors 的实际生成链路。
6. 对照文档，列出每项“代码事实 / 已确认目标 / 差异 / 推荐实施阶段”。
7. 专门核对 NEW-12：说明真实代码当前返回哪些字段；将其与 `reassignRequired + affectedTemplateCount` 契约对比，并列出需要修改的位置。

返回格式：
一、代码证据（文件路径、类、方法、Mapper SQL、调用方）
二、当前真实行为（含事务、状态、异常和权限）
三、按阶段的修改清单
四、必须停止等待 TL 决策的冲突
五、建议的测试清单

完成后停止，不要修改代码。
```

**继续条件：** TL 核对阶段 0 的代码证据，并把实际文件/方法名贴入后续提示词中的“阶段 0 结论”。

---

## 阶段 1：数据访问与共用校验基础

```text
你是 DAE 后端开发工程师。请只完成本阶段，完成后停止。

已确认变更：CHG-20260721-01、CHG-20260722-01、CHG-20260722-02。
阶段 0 结论：
<粘贴已确认的 Controller/Service/Mapper/表名和现状证据>

本阶段目标：建立 LEAD-93 v2 所需的数据访问和共用校验基础，不改写 Version 生命周期。

必须实现：
1. 使用现有已批准的 DDL/实体结构，接入 Template 专用 Category、Subcategory/Tag 当前关系、Template Change History、Category Change History 和 Delete Audit。
2. Template 当前 Metadata 必须按 emailCode 保存，不绑定 version；主 Category 使用 config.category_id，Subcategory/Tag 使用当前 relation 表。
3. Category 根节点使用 parent_id=0；软删除统一为 -1；查询只读取有效节点。
4. Web v2 新建和查询固定 is_campaign=0；不得为 Campaign 新增页面/API 逻辑。
5. 提供共用校验：有效 Category、父子归属、有效 Tag/Group、Trigger 最多 5、Template Title 非空/最长120/字符规则/同主 Category 唯一。
6. 所有 v1 DTO、Mapper、必填参数和响应保持不变。

明确不做：EX-05/EX-06 聚合写入、Publish 状态修改、Copy、Category 删除迁移、Mock/Postman 重建。

测试至少覆盖：有效节点过滤、软删除 -1、Title 冲突、父子分类不匹配、Tag 无效、Trigger 超限、v1 List 冒烟。

返回：修改文件、SQL/Mapper 变化、校验入口、测试结果、未完成项。完成后停止。
```

---

## 阶段 2：Template 新建与主信息/Metadata 聚合写入

```text
你是 DAE 后端开发工程师。请只完成本阶段，完成后停止。

已确认变更：CHG-20260721-02、CHG-20260722-01、CHG-20260722-02、CHG-20260723-02、CHG-20260723-03。
阶段 0/1 结论：
<粘贴实际实现路径和测试结果>

实现 EX-05：POST /iic-dae-msg/web/msg/template/email/v2/add
1. 仅当 emailCode 为空时，它是新建的一站式外观聚合入口。
2. Request 新增 categoryId、subCategoryIds、tagGroups。可以提交 categoryId=null 和空数组作为 Draft 的未完整 Metadata，但必须作为同一请求快照处理。
3. 单个 @Transactional 内按顺序完成：生成 emailCode -> Insert config -> Insert V1 Draft -> 写 category_id/Subcategory/Tag relations -> 写 CREATE Template Change History。
4. 任何校验或写入失败都整体回滚，不得留下孤儿 config 或 Draft。
5. 可同时发现的输入错误通过 data.fieldErrors[]/invalidFieldCount 一次返回；失败时不写库。
6. emailCode 已存在时严格保留现有 Save Draft 的 Version 选择与状态逻辑；不得接收或修改 categoryId、subCategoryIds、tagGroups。

实现 EX-06：POST /iic-dae-msg/web/msg/template/email/v2/update
1. 一次接收 emailCode、emailName、description、channelMap、categoryId、subCategoryIds、tagGroups。
2. 单个 @Transactional 内：获取 before 快照 -> 完整校验 -> 更新 config 主字段与 category_id -> 全量替换 Subcategory/Tag 当前关系 -> 写 before/after Template Change History。
3. 不接收 version；绝不修改 Subject、正文、附件、versionStatus、effectiveFrom 或 effectiveUntil。
4. Published Template 更新 Metadata 后仍保持 Published，不创建 Draft/New Version。
5. 子分类不属于主分类时，以 field="subCategoryIds" 返回字段错误，业务语义为 INVALID_SUBCATEGORY_BELONGING。

兼容要求：
- 不修改 v1。
- 不修改 Scheduler、Version Conflict、/v2/version/add 或 NEW-10 Copy 行为。
- 独立 /v2/category/metadata 不再作为前端接口。先核对调用方；若仍有外部调用，只报告，不能擅自删除或改语义。

测试至少覆盖：
- EX-05 成功创建；任一 Metadata 校验失败整体回滚；已有 emailCode 混入 Metadata 被拒绝。
- EX-06 成功全量替换；多个字段错误一起返回；更新后 Version 行数、状态和时间完全不变。
- Published 更新分类后仍 Published。

返回：实际文件和方法、事务边界、失败回滚证据、测试结果、旧 Metadata 入口的调用方结论。完成后停止。
```

---

## 阶段 3：Publish、Copy 与查询兼容回归

```text
你是 DAE 后端开发工程师。请只完成本阶段，完成后停止。

已确认变更：CHG-20260721-02、CHG-20260722-01、CHG-20260722-02、CHG-20260723-03。
前序阶段结论：
<粘贴阶段 0-2 的结果>

本阶段目标：使写入聚合后的当前 Metadata 正确接入已有 Publish、Copy 和 List/Detail 查询边界；不重写 Version 状态机。

必须实现：
1. EX-16 Publish 保留既有 Version 状态切换；发布前读取当前 Template Metadata，校验 Category、Subcategory 和四个 Mandatory Tag Group。失败时不保存本次 Draft、不写 Version/History，使用 data.fieldErrors[] 一次返回所有可同时发现的错误。
2. NEW-10 Copy 继续创建独立 Template B；首次保存原子写 B config、B.V1 Draft、当前 Metadata、CREATE History 和 copy_from_email_code。不得调用 /version/add 修改 A。
3. EX-01/EX-02 保留 v1 现有必填参数和响应兼容，并只在 v2 追加 Metadata Filter；Web v2 查询和新建固定 is_campaign=0。
4. Detail/List 读取当前 Metadata，不把它标记为历史 Version Snapshot；v1 不新增 Metadata 依赖或必填参数。

必须保持不变：Version Scheduler、Version Conflict、Active/Deactivate 现有语义、附件和 Preview。

测试至少覆盖：发布 Metadata 缺失、发布多字段错误、Copy A/B 独立、v1 List/Detail 回归、v2 List Filter 回归。

返回：修改文件、保留的 Version 路径、v1/v2 回归证据、测试结果。完成后停止。
```

---

## 阶段 4：统一分类删除与迁移

```text
你是 DAE 后端开发工程师。请只完成本阶段，完成后停止。

已确认变更：CHG-20260722-01、CHG-20260723-02、CHG-20260723-03。
前序阶段结论：
<粘贴阶段 0-3 的结果>

实现唯一删除入口：
POST /iic-dae-msg/web/msg/template/email/v2/category/delete

规则：
1. 首次请求仅传 sourceCategoryId。
2. 只要没有 Active/Draft/Schedule 引用，就直接软删除；仅 Expired 引用不阻止删除，也不迁移历史 Metadata。
3. 存在有效引用时，不写库，返回 CATEGORY_IN_USE、data.reassignRequired=true 和 data.affectedTemplateCount；不得返回旧的 data.impact 或 Active/Draft/Schedule 分项。
4. 用户带 targetCategoryId、targetSubcategoryIds 再次提交同一 Endpoint 后：重新查询和锁定源、目标、受影响 Template；同一事务完成当前 Metadata 迁移、Template Change History、Category Change History、Delete Audit 和源节点软删除。
5. targetCategoryId 不能等于 sourceCategoryId，也不能处于 sourceCategoryId 的子树中；违反时返回 INVALID_MIGRATION_TARGET。不得允许迁移到待删除节点或其后代。
6. 目标不存在、已删除、层级不匹配、两次请求间引用发生变化时，返回对应业务失败，不得部分写入。
7. 不物理删除；不让前端循环调用 EX-06 代替本操作。

旧入口处理：先检查所有 Impact、Direct Delete、Reassign-and-Delete Endpoint 的调用方。无调用方才能移除 Web v2 映射；有调用方时停止并报告兼容风险，不得擅自删除。

测试至少覆盖：
- 无有效引用直接删除；Expired-only 直接删除。
- 有引用首次返回 Impact 且零写入。
- 迁移到自己、迁移到子节点被拒绝。
- 成功迁移并删除；任一 relation/history/audit 写失败时整体回滚。
- 两次请求间数据变化时返回并发修改失败。

返回：锁定顺序、事务边界、历史/Audit 写入证据、旧入口调用方处理和测试结果。完成后停止。
```

---

## 阶段 5：接口回归、错误码登记与测试资产

```text
你是 DAE 后端开发与测试工程师。请只完成本阶段，完成后停止。

前序阶段结论：
<粘贴阶段 0-4 的结果>

本阶段目标：完成 LEAD-93 v2 回归和证据闭环。

必须完成：
1. 验证 Web v2 Contract 共 25 个 Endpoint；NEW-04、NEW-07、NEW-09 不再作为前端 Endpoint。
2. 输出每个实际业务失败场景的 responseCode、responseMessage、data 结构；不得用文档中的语义码伪造实际数值。
3. 验证普通失败 data=null；EX-05、EX-06、EX-16、NEW-08、NEW-11 只有字段定位场景才返回 fieldErrors/invalidFieldCount；NEW-12 仅在需迁移时返回 reassignRequired/impact。
4. 重新生成或更新 v2 Mock、Postman Collection、环境变量、断言和测试报告；不得继续使用 28 Endpoint 的历史资产作为通过证据。
5. 执行 v1 回归，证明 v1 请求参数、包络和 List/Detail 行为未被破坏。

返回：
- 25 Endpoint 清单及测试状态；
- 实际错误码映射表；
- 失败案例和数据库回滚证据；
- Mock/Postman 文件路径；
- 仍需 QA 或 TL 决策的项。

完成后停止，不做无关重构。
```

## 每阶段统一回传格式

```text
阶段：
结论：完成 / 停止待确认 / 无法实施

修改文件：
- 路径：
- 方法：
- 原因：

关键证据：
- 事务边界：
- SQL/Mapper：
- 响应/错误码：

测试：
- 用例：
- 结果：

阻塞项：
- 代码事实：
- 需要 TL/BA 决策：

下一阶段可否开始：是 / 否
```
