# LEAD-93 / LEAD-405 后端 AC 追溯矩阵

本文件是 [后端 AC 回归包说明](LEAD-93-405-backend-ac-README_CN.md) 的逐条追溯附件。需求来源为当前 Jira Story；所有 API 编号对应 Postman Collection 中的请求编号，所有 DB 编号对应自动化只读 SQL 断言。

## 判定口径

- `FULL`：已有 API 和/或数据库断言，运行报告可计算 PASS/FAIL。
- `PARTIAL`：需求的一部分是后端可测，剩余边界或 UI 行为没有在当前集合覆盖。
- `CONDITIONAL`：需要额外登录态，例如 Adviser 权限负例。
- `UI`：纯前端交互，不属于本后端回归集合。
- `GAP`：后端可测但当前没有足够确定的接口断言，必须补充后才能宣称 AC 全覆盖。

## LEAD-277

| AC | 后端验收要求 | Postman 用例 | 数据库断言 | 覆盖度 | 说明 |
| --- | --- | --- | --- | --- | --- |
| AC1 | 模板核心字段可被创建、读取和持久化 | API-21, API-22 | DB-01, DB-04, DB-05 | FULL | - |
| AC2 | 字段约束：模板名称、分类单选、子分类多选且归属正确 | API-17, API-20, API-28, API-29 | DB-04, DB-06 | PARTIAL | 已覆盖必填、单分类和归属；名称/描述最大长度须另补专用边界用例。 |
| AC3 | Save Draft 允许 Metadata 未完成，状态为 Draft | API-18, API-19 | DB-01 | FULL | - |
| AC4 | 草稿未选必填 Tag Group 时填充默认值 | API-18 | - | GAP | 当前基线仅确认草稿允许空 Tag；默认值的具体持久化形态未冻结。 |
| AC5 | Publish 校验标题、分类、子分类、四组 Tag 和正文 | API-20, API-21 | DB-03, DB-05 | FULL | - |
| AC6 | 发布失败被阻止并返回可定位字段错误 | API-20 | DB-03 | FULL | - |
| AC7 | 校验只在用户点击 Publish 时触发 | - | - | UI | 触发时机属于页面交互；后端只验证 Publish 请求。 |
| AC8 | 模板名称必填且不超过 120 字符 | API-17 | - | PARTIAL | 已覆盖必填；120 字符边界须另补。 |
| AC9 | Publish 必须选择 Category | API-20 | DB-03 | FULL | - |
| AC10 | Publish 必须选择至少一个 Subcategory | API-20 | DB-03 | FULL | - |
| AC11 | Publish 每个必填 Tag Group 至少一个值 | API-1, API-20 | DB-05 | FULL | - |
| AC12 | Publish 正文不能为空 | API-20 | DB-03 | FULL | - |
| AC13 | Draft 发布为 Published；Published Copy 为独立 Draft | API-18, API-21, API-32, API-41, API-45 | DB-01, DB-08, DB-10, DB-11 | FULL | - |
| AC14 | 所有发布入口复用一致的发布校验 | API-20, API-45 | - | PARTIAL | 已覆盖首次发布和 Version 发布；Preview 页面入口属于前端专属。 |

## LEAD-301

| AC | 后端验收要求 | Postman 用例 | 数据库断言 | 覆盖度 | 说明 |
| --- | --- | --- | --- | --- | --- |
| AC1 | 页面展示 Category 下拉和禁用态 Subcategory 多选 | - | - | UI | - |
| AC2 | 仅可选当前 Category 下 Subcategory，切换 Category 清空选择 | API-29 | DB-06 | PARTIAL | 后端覆盖跨分类子分类拒绝；页面清空行为属于前端。 |
| AC3 | Draft 可不选 Category/Subcategory，状态保持 Draft | API-18, API-19 | DB-01 | FULL | - |
| AC4 | Category 与同父 Subcategory 可排序，不能跨父移动 | API-15 | - | PARTIAL | 已覆盖完整同级排序写入；拖拽禁用与跨父交互属于前端。 |
| AC5 | Category/Subcategory 持久化，并可在列表、搜索和导航定位 | API-22, API-23, API-26, API-31 | DB-04, DB-06 | FULL | - |
| AC6 | Draft 修改分类后立即保存并更新位置 | - | - | GAP | 当前集合仅验证 Draft 初次创建，未覆盖已有 Draft 的 Metadata 更新。 |
| AC7 | Published 修改分类为 Metadata 变更且仍为 Published | API-24, API-25, API-26 | DB-04 | FULL | - |
| AC8 | Category/Subcategory 名称必填且最长 100 字符 | API-5, API-10, API-11 | - | PARTIAL | 已覆盖空名称；100 字符边界须另补。 |
| AC9 | Category/Subcategory 重名被拒绝且不落部分数据 | API-9, API-11 | DB-07 | PARTIAL | 已覆盖 Category 重名和批量原子性；Subcategory 重名的正式唯一性范围仍有文档冲突。 |

## LEAD-306

| AC | 后端验收要求 | Postman 用例 | 数据库断言 | 覆盖度 | 说明 |
| --- | --- | --- | --- | --- | --- |
| AC1 | Create New 路由、首次保存后 URL、离页确认 | - | - | UI | - |
| AC2 | 创建页可提交 Category、Subcategory 与 Tags | API-21, API-22 | DB-04, DB-05 | FULL | - |
| AC3 | 首次 Save Draft 创建唯一 Template ID，状态为 Draft | API-18, API-19 | DB-01 | FULL | - |
| AC4 | Publish 严格校验、Draft 转 Published、Adviser 可见、Copy 复用规则 | API-20, API-21, API-23, API-32, API-45 | DB-03, DB-10 | PARTIAL | 后端状态和可见性查询已覆盖；页面消息和 Adviser UI 不在本套范围。 |
| AC5 | 仅 Content Manager 可创建 Template | API-56 | - | CONDITIONAL | 需配置 adviserAuthorization 并将 runPermissionTests=true。 |

## LEAD-307

| AC | 后端验收要求 | Postman 用例 | 数据库断言 | 覆盖度 | 说明 |
| --- | --- | --- | --- | --- | --- |
| AC1 | 删除 Category 前显示确认对话框 | - | - | UI | - |
| AC2 | 确认对话框展示不可逆、级联和引用影响说明 | - | - | UI | - |
| AC3 | 有引用时阻止直接删除并提供迁移选择 | API-50, API-51 | DB-12, DB-13 | PARTIAL | 当前 Contract 采用两阶段影响评估和迁移删除，不是仅人工迁移后重试。 |
| AC4 | 无引用 Category 级联软删除子节点并从树隐藏 | API-16, API-51, API-53 | DB-12 | PARTIAL | 软删除和树隐藏已覆盖；删除留痕未纳入当前后端测试基线。 |
| AC5 | 无引用 Subcategory 单独软删除且不影响父 Category | API-48, API-49 | - | PARTIAL | 叶节点删除和父节点保留已覆盖；有引用 Subcategory 的单独迁移分支未单测。 |

## LEAD-276

| AC | 后端验收要求 | Postman 用例 | 数据库断言 | 覆盖度 | 说明 |
| --- | --- | --- | --- | --- | --- |
| AC1 | 编辑页回显已选 Category/Subcategory | API-22, API-26, API-28 | DB-04 | PARTIAL | 后端 Detail 回显已覆盖；选中态渲染属于前端。 |
| AC2 | 改 Category 清空旧 Subcategory 并刷新候选项 | API-29 | DB-06 | PARTIAL | 后端拒绝跨分类关系；页面自动清空与刷新属于前端。 |
| AC3 | 只修改 Subcategory 时 Category 保持不变 | API-27, API-28 | DB-04 | FULL | - |
| AC4 | 一个 Template 仅一个 Category，可多个同父 Subcategory | API-21, API-27, API-29 | DB-04, DB-06 | FULL | - |
| AC5 | Template 重新分类仅通过编辑表单，不通过拖拽 | - | - | UI | - |
| AC6 | Published Metadata 修改不改变发布状态 | API-24, API-25 | DB-04 | FULL | - |
| AC7 | Draft 修改分类后立即保存 | - | - | GAP | 当前集合未覆盖已有 Draft 的 EX-06 更新。 |
| AC8 | 重新分类后搜索、筛选和位置同步更新 | API-23, API-31, API-47, API-52 | DB-13 | FULL | - |
| AC9 | Publish 必填分类，Draft 可为空 | API-18, API-20 | DB-01, DB-03 | FULL | - |
| AC10 | 仅 Content Manager 可修改分类 | API-57 | - | CONDITIONAL | 需配置 adviserAuthorization 并将 runPermissionTests=true。 |

## LEAD-278

| AC | 后端验收要求 | Postman 用例 | 数据库断言 | 覆盖度 | 说明 |
| --- | --- | --- | --- | --- | --- |
| AC1 | 从 Published Copy 创建独立 Draft，原模板保持可用 | API-32, API-34 | DB-08, DB-09 | PARTIAL | 独立 Copy 与原模板状态已覆盖；WYSIWYG 预填渲染属于前端。 |
| AC2 | WYSIWYG 格式化能力 | - | - | UI | - |
| AC3 | 手动 Save Draft 保存 B，原模板不受影响 | API-33, API-34 | DB-08, DB-09 | PARTIAL | 保存和原模板不变已覆盖；页面成功消息与 Version History 文案属于前端。 |
| AC4 | 离开未保存编辑时确认 Save/Cancel/Back | - | - | UI | - |
| AC5 | 手动 Preview 显示未保存内容 | - | - | UI | - |
| AC6 | Copy B 发布为独立 Published，原模板仅显式停用时变化 | API-34, API-35, API-36, API-37, API-38, API-45 | DB-09, DB-10 | FULL | - |
| AC7 | Discard/Cancel 删除 B，原 Published 不变 | API-39, API-40 | DB-15, DB-16 | FULL | - |

## LEAD-293

| AC | 后端验收要求 | Postman 用例 | 数据库断言 | 覆盖度 | 说明 |
| --- | --- | --- | --- | --- | --- |
| AC1 | Content Manager 可进入创建分类功能 | - | - | UI | - |
| AC2 | 创建 Category/Subcategory 名称，最长 100 字符 | API-6, API-12, API-13 | - | PARTIAL | 创建已覆盖；100 字符边界须另补。 |
| AC3 | 空/重复名称失败，单次最多五个 Subcategory，无部分落库 | API-5, API-9, API-10, API-11 | DB-07 | PARTIAL | 已覆盖空名称、Category 重名、上限和原子性；Subcategory 重名范围待确认。 |
| AC4 | 创建后立即在下拉和导航可用 | API-2, API-6, API-12, API-13 | - | PARTIAL | Tree API 可见性已覆盖；页面下拉渲染属于前端。 |
| AC5 | 新分类默认有效并可立即被 Template 使用 | API-6, API-21 | DB-04 | FULL | - |
| AC6 | 创建失败无部分数据 | API-10, API-11 | DB-07 | FULL | - |
| AC7 | 仅 Content Manager 可创建/编辑 Category | API-55 | - | CONDITIONAL | 需配置 Adviser 登录态。 |
| AC8 | 创建人和创建时间被保存 | - | - | GAP | 数据库字段存在，但自动断言未覆盖创建人/创建时间。 |
| AC9 | 两层分类结构，Template 一主分类多子分类 | API-2, API-12, API-13, API-21, API-27 | DB-04 | FULL | - |

## LEAD-300

| AC | 后端验收要求 | Postman 用例 | 数据库断言 | 覆盖度 | 说明 |
| --- | --- | --- | --- | --- | --- |
| 1 | 返回 Tag Group 与 Required 标识 | API-1 | DB-05 | PARTIAL | 后端 Taxonomy 已覆盖；页面展示属于前端。 |
| 2 | Tag 仅可从预置多选 taxonomy 选择，不接受自由文本 | API-1, API-30 | DB-05 | FULL | - |
| 3 | Publish 缺少任一必填 Tag Group 时阻止发布 | API-1, API-20 | DB-03, DB-05 | FULL | - |
| 4 | Save Draft 不强制 Tag，未选值使用默认表示 | API-18 | DB-01 | PARTIAL | Draft 宽松已覆盖；默认值具体落库表示未冻结。 |
| 5 | 每个 Tag Group 支持多选 | API-1, API-24, API-26 | DB-05 | FULL | - |
| 6 | 可回显并增删已分配 Tag | API-24, API-26 | DB-05 | FULL | - |
| 7 | Tag 是 Metadata；修改 Published Tag 不改变状态且不受分类限制 | API-24, API-25 | DB-04, DB-05 | PARTIAL | 状态不变已覆盖；跨所有分类的 Tag 可用性由 taxonomy 数据决定，未做枚举组合测试。 |
| 8 | 仅 Content Manager 可编辑 Tag，Adviser 只读 | API-57 | - | CONDITIONAL | 需配置 adviserAuthorization 并将 runPermissionTests=true。 |
| 9 | 已分配 Tag 立即可用于列表筛选 | API-31 | DB-05 | FULL | - |
