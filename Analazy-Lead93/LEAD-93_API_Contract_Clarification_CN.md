# LEAD-93 / LEAD-405 / LEAD-406 Web v2 API Contract

> 状态：最终开发基线
> 日期：2026-07-23
> 需求基线：PRD v2.0（`DAE_PRD_LEAD-93 Template Management_v2.0 - updated July 21st.docx`）、Jira Feature 拆分及 2026-07-21 LEAD-278 Jira/OM Copy and Create 澄清
> 交叉需求参考：`PRD_LEAD-308 Advisor-Template Management_v1.3 -updated July 20th.docx`
> 范围：25 个 Web v2 Endpoint

## 1. 契约总览

本文是 Web 前端、后端和接口测试共同遵循的 API 基线。正文只定义最终对外契约，不记录现状分析、实现差异、内部类名或评审过程。Web 端只调用本文列出的 `/v2` Endpoint；环境网关路由不属于 Endpoint。

### 1.1 配套文件

| 文件                                                                              | 用途                                |
| --------------------------------------------------------------------------------- | ----------------------------------- |
| [HTTP 请求示例](api-contract/examples/lead93-api.http)                             | 接口请求样例（需同步为 25 个 Endpoint） |
| [Postman Collection](postman/LEAD-93-v2-contract-all-apis.postman_collection.json) | 调用场景及断言（需同步为 25 个 Endpoint） |
| [本地 Mock](api-contract/mock/lead93-mock-server.mjs)                              | 前后端并行开发和固定响应调试        |
| [Mock 调试报告](postman/reports/v2-contract-mock-2026-07-21_162015.debug.html)     | URL、Request、Response 和断言样例   |

本契约已合并为 25 个 Endpoint；HTTP 示例、Postman Collection 和本地 Mock 需按本次接口冻结结果同步更新。

### 1.2 公共约定

| 项目         | 契约                                                                                                                                                                                                                |
| ------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Base Path    | `/iic-dae-msg/web/msg/template/email/v2`                                                                                                                                                                          |
| 响应包络     | requestId/responseCode/responseMessage/data；普通业务失败时 data=null，仅字段定位接口返回 data.fieldErrors                                                                                                          |
| HTTP Status  | 业务成功和业务失败均返回 HTTP 200；网关、协议或服务不可用等非业务异常不在本契约内                                                                                                                                   |
| 成功判断     | `responseCode="00000000"`；其他值为业务失败，实际失败码和 `responseMessage` 以 QA 实测为准                                                                                                                      |
| 分页         | 请求使用`pageNum/pageSize`；响应使用 `pageNo/pageSize/totalCount/totalPage/dataList`                                                                                                                            |
| 时间         | `yyyy-MM-dd HH:mm:ss`，按 `Africa/Johannesburg`（UTC+02:00）解释                                                                                                                                                |
| 标识类型     | `emailCode`、Category ID 等 64 位标识均使用 String                                                                                                                                                                |
| 空值         | 可空字段使用`null`；不使用空字符串代替无值，字段另有说明时除外                                                                                                                                                    |
| 写请求       | 成功返回前完成该命令的全部校验和写入；失败不得产生部分业务结果                                                                                                                                                      |
| 业务失败数据 | 普通失败仅返回 responseCode/responseMessage/data=null；EX-05、EX-06、EX-16、NEW-08、NEW-11 返回 data.fieldErrors/invalidFieldCount；NEW-12 在需迁移时返回 data.reassignRequired 与 data.affectedTemplateCount |
| Metadata     | Category、Subcategory 和 Tag 归属于`emailCode` 对应的当前 Template，不属于内容 Version                                                                                                                            |
| 生命周期     | `versionStatus`：`0=Schedule, 1=Active, 2=Expired, 3=Draft`                                                                                                                                                     |

**公共请求头**

| Header             | 必填 | 说明                   |
| ------------------ | ---: | ---------------------- |
| `authorization`  |   是 | Bearer 登录态          |
| `x-apigw-api-id` |   是 | 环境配置提供           |
| `content-type`   |   是 | `application/json`   |
| `language`       |   是 | `en-US`              |
| `requestid`      |   是 | 每次请求使用新的唯一值 |

**角色权限**

| 能力                                                  | 允许角色                         | 约束                                                                                        |
| ----------------------------------------------------- | -------------------------------- | ------------------------------------------------------------------------------------------- |
| Template、Category/Subcategory 和 Metadata 管理写操作 | `Content Manager`              | 方案中的“管理员”与`Content Manager` 是同一角色，不新增独立 Admin 角色                   |
| Published Template 与 Tag Taxonomy 查询               | `Content Manager`、`Adviser` | Adviser 只能读取 Enabled + Active Published Template，不允许通过请求参数读取 Draft/Schedule |
| Draft/Admin List、管理端 Detail 和 Version 管理       | `Content Manager`              | 复用现有鉴权机制                                                                            |
| Tag Seed 与一次性 Migration                           | 非运行时 API                     | 由受控数据库脚本和发布流程执行                                                              |

### 1.3 Endpoint 清单

| ID         | Method + Complete Endpoint                                                   | 主要场景                                           |
| ---------- | ---------------------------------------------------------------------------- | -------------------------------------------------- |
| `EX-01`  | `POST /iic-dae-msg/web/msg/template/email/v2/queryList`                    | Published 列表、搜索和筛选                         |
| `EX-02`  | `POST /iic-dae-msg/web/msg/template/email/v2/templateList`                 | Draft/Admin 列表、搜索和筛选                       |
| `EX-03`  | `POST /iic-dae-msg/web/msg/template/email/v2/detail`                       | 管理端 Template Detail                             |
| `EX-04`  | `POST /iic-dae-msg/web/msg/template/email/v2/published/detail`             | Adviser Published Detail                           |
| `EX-15`  | `POST /iic-dae-msg/web/msg/template/email/v2/channelList`                  | Channel 选项                                       |
| `EX-05`  | `POST /iic-dae-msg/web/msg/template/email/v2/add`                          | 首次创建并 Save Draft、Save Draft、Cancel Schedule |
| `EX-16`  | `POST /iic-dae-msg/web/msg/template/email/v2/publish`                      | Publish Now、Schedule Publish、直接发布新 Template |
| `EX-06`  | `POST /iic-dae-msg/web/msg/template/email/v2/update`                       | 更新 Template 主信息与当前 Metadata                 |
| `EX-07`  | `POST /iic-dae-msg/web/msg/template/email/v2/changeStatus`                 | Deactivate、Reactivate                             |
| `EX-08`  | `POST /iic-dae-msg/web/msg/template/email/v2/delete`                       | 删除 Template                                      |
| `NEW-10` | `POST /iic-dae-msg/web/msg/template/email/v2/copy`                         | Copy and Create 首次保存                           |
| `EX-09`  | `POST /iic-dae-msg/web/msg/template/email/v2/version/add`                  | 增加内容版本                                       |
| `EX-10`  | `POST /iic-dae-msg/web/msg/template/email/v2/version/update`               | 更新 Draft 内容版本                                |
| `EX-11`  | `POST /iic-dae-msg/web/msg/template/email/v2/version/delete`               | Cancel 已保存 Draft、删除 Schedule                 |
| `EX-12`  | `GET /iic-dae-msg/web/msg/template/email/v2/version/getMaxVersion`         | 查询最大版本号                                     |
| `EX-13`  | `POST /iic-dae-msg/web/msg/template/email/v2/version/detail`               | 查询内容版本详情                                   |
| `EX-14`  | `POST /iic-dae-msg/web/msg/template/email/v2/version/list/history`         | Version History                                    |
| `NEW-01` | `GET /iic-dae-msg/web/msg/template/email/v2/category/tree`                 | Category Tree                                      |
| `NEW-02` | `POST /iic-dae-msg/web/msg/template/email/v2/category`                     | 创建 Category                                      |
| `NEW-03` | `PUT /iic-dae-msg/web/msg/template/email/v2/category/{id}`                 | 更新 Category/Subcategory                          |
| `NEW-12` | `POST /iic-dae-msg/web/msg/template/email/v2/category/delete`              | 删除 Category/Subcategory；必要时迁移有效引用      |
| `NEW-05` | `PUT /iic-dae-msg/web/msg/template/email/v2/category/reorder`              | 保存同级排序                                       |
| `NEW-08` | `POST /iic-dae-msg/web/msg/template/email/v2/category/batch-subcategories` | 批量创建 Subcategory                               |
| `NEW-06` | `GET /iic-dae-msg/web/msg/template/email/v2/category/taxonomy`             | Tag Taxonomy                                       |
| `NEW-11` | `POST /iic-dae-msg/web/msg/template/email/v2/reassign`                     | 批量 Template Reassignment                         |

## 2. 模板查询与详情

### EX-01 Published List

**接口与场景**

| 项目     | 内容                                                                                       |
| -------- | ------------------------------------------------------------------------------------------ |
| Endpoint | `POST /iic-dae-msg/web/msg/template/email/v2/queryList`                                  |
| 页面     | `UI-A-01` Template Library Published/Search/Filter                                       |
| 场景     | 打开 Published 页签；搜索/筛选已发布模板；Adviser 查询可用模板；Adviser 搜索的固定排序场景 |

**请求参数**

| 字段                      | 类型     | 必填 | 说明                                                                                    |
| ------------------------- | -------- | ---: | --------------------------------------------------------------------------------------- |
| `emailName`             | String   |   否 | 保留 v1 字段名，作为全局关键字；匹配模板名称、当前 Active Email Subject、描述、标签名称 |
| `querySort`             | Integer  |   否 | 保留 v1 Adviser 排序字段，默认`0`；仅接受下表枚举值                                   |
| `isCampaign`            | Integer  |   是 | 保留 v1 必传字段；本期只允许传`0`，即 Email-only                                      |
| `categoryId`            | String   |   否 | 主分类，单选                                                                            |
| `subCategoryIds`        | String[] |   否 | 子分类，多选，同一维度 OR                                                               |
| `tagGroups`             | Object[] |   否 | 标签筛选组；同组 OR、跨组 AND                                                           |
| `tagGroups[].groupCode` | String   | 条件 | 提交`tagGroups` 时必填                                                                |
| `tagGroups[].tagCodes`  | String[] | 条件 | 提交`tagGroups` 时必填                                                                |
| `pageNum`               | Integer  |   否 | 当前页码，默认`1`                                                                     |
| `pageSize`              | Integer  |   否 | 每页数量，默认`20`                                                                    |

**请求 Mock**

```json
{
  "emailName": "retirement",
  "querySort": 0,
  "isCampaign": 0,
  "categoryId": "1001",
  "subCategoryIds": ["1101"],
  "tagGroups": [{"groupCode": "CONTENT_TYPE", "tagCodes": ["CONTENT_TYPE_EMAIL"]}],
  "pageNum": 1,
  "pageSize": 20
}
```

**`querySort` 枚举**

|    值 | Adviser 显示名称   | 排序语义            |
| ----: | ------------------ | ------------------- |
| `0` | Most Relevant      | 相关度降序；默认值  |
| `1` | Newest First       | Published Date 降序 |
| `2` | Oldest First       | Published Date 升序 |
| `3` | Alphabetical (A-Z) | Template Name 升序  |
| `4` | Alphabetical (Z-A) | Template Name 降序  |

排序作用于完整的当前筛选结果集，再分页；前端切换 `querySort` 时必须传 `pageNum=1`。

**响应字段**

| 字段                                 | 类型        | 说明                                                                     |
| ------------------------------------ | ----------- | ------------------------------------------------------------------------ |
| `data.pageNo`                      | Integer     | 当前页码                                                                 |
| `data.pageSize`                    | Integer     | 每页数量                                                                 |
| `data.totalCount`                  | Long        | 总记录数                                                                 |
| `data.totalPage`                   | Integer     | 总页数                                                                   |
| `data.dataList[].emailCode`        | String      | 模板唯一业务标识                                                         |
| `data.dataList[].emailName`        | String      | 模板名称                                                                 |
| `data.dataList[].title`            | String/null | 当前 Active version 的 Email Subject                                     |
| `data.dataList[].description`      | String/null | 描述                                                                     |
| `data.dataList[].version`          | String      | 当前 Active version                                                      |
| `data.dataList[].emailStatus`      | String      | `1=Active`                                                             |
| `data.dataList[].versionStatus`    | Integer     | 固定为`1=Active`                                                       |
| `data.dataList[].categoryId`       | String/null | 当前 Template 主分类 ID                                                  |
| `data.dataList[].categoryName`     | String/null | 当前 Template 主分类名称                                                 |
| `data.dataList[].subCategoryIds`   | String[]    | 当前 Template 子分类 ID                                                  |
| `data.dataList[].subCategoryNames` | String[]    | 当前 Template 子分类名称                                                 |
| `data.dataList[].tagMap`           | Object      | `{groupCode: [tagCode]}`；当前 Template 标签，不随 Active version 切换 |
| `data.dataList[].modifiedTime`     | DateTime    | 修改时间                                                                 |

**成功响应 Mock**

```json
{
  "requestId": "mock-request-id",
  "responseCode": "00000000",
  "responseMessage": "Succeed",
  "data": {
    "pageNo": 1,
    "pageSize": 20,
    "totalCount": 1,
    "totalPage": 1,
    "dataList": [{
      "emailCode": "815645091883520000",
      "emailName": "Retirement review invitation",
      "title": "Your retirement review",
      "description": "Invitation for the annual retirement review",
      "version": "V1",
      "emailStatus": "1",
      "versionStatus": 1,
      "categoryId": "1001",
      "categoryName": "Client Engagement",
      "subCategoryIds": ["1101"],
      "subCategoryNames": ["Advice Review"],
      "tagMap": {"CONTENT_TYPE": ["CONTENT_TYPE_EMAIL"]},
      "modifiedTime": "2026-07-16 09:00:00"
    }]
  }
}
```

**失败响应 JSON 示例**

```json
{
  "requestId": "mock-request-id",
  "responseCode": "QA_TESTED_ERROR_CODE",
  "responseMessage": "Invalid querySort.",
  "data": null
}
```

**错误码与提示**

| 业务语义码                | 实际 responseCode（后续填写） | responseMessage    |
| ------------------------- | ----------------------------- | ------------------ |
| REQUEST_VALIDATION_FAILED | 待开发/QA 填写                | 请求参数不合法。   |
| PERMISSION_DENIED         | 待开发/QA 填写                | 无权限执行此操作。 |

**前端处理与错误**

- Published 页签不显示或提交 Status Filter。
- `emailName` 沿用 v1 字段名，但由后端同时匹配 `config.email_name`、当前 Active `version.title`、`config.description` 和当前 Template Tag Name；Category/Subcategory Name 不在本期关键词范围。
- `isCampaign` 是 v1 兼容字段且必须传 `0`；后端拒绝其他值，保证本期仍为 Email-only。
- 空结果显示现有 Empty State；分页继续沿用现有页面行为。
- Adviser 的可选排序属于本 `EX-01` 搜索/列表场景：前端提交 `querySort`，后端按白名单对完整筛选结果集排序后分页；不建立 LEAD-308 专属接口。

### EX-02 Draft/Admin List

**接口与场景**

| 项目     | 内容                                                          |
| -------- | ------------------------------------------------------------- |
| Endpoint | `POST /iic-dae-msg/web/msg/template/email/v2/templateList`  |
| 页面     | `UI-A-02` Draft/Admin Template List                         |
| 场景     | 打开 Draft/Admin 页签；搜索/筛选 Draft、Schedule 或管理态模板 |

> **实现归属备注：** 本接口是 Content Manager 获取权限模板列表的链路，权限模板范围由 UMS 服务提供。`templateList` 的 v2 参数扩展、权限范围及对应查询实现必须在 **UMS 代码库**同步修改；消息中心不得另行实现一套绕过 UMS 权限范围的列表逻辑。本文仅定义 Web 端最终请求/响应契约。

**请求参数**

| 字段                      | 类型     | 必填 | 说明                                                                                 |
| ------------------------- | -------- | ---: | ------------------------------------------------------------------------------------ |
| `keyWords`              | String   |   否 | 保留 v1 字段名，作为全局关键字；匹配模板名称、结果版本 Email Subject、描述、标签名称 |
| `templateStatus`        | String   |   否 | 保留 UMS 现有管理态筛选语义和值；不新增`tab` 枚举替代它                            |
| `channelList`           | String[] |   否 | 保留 UMS 现有 Channel 筛选                                                           |
| `emailStatusList`       | String[] |   否 | 保留 UMS 现有启用/停用筛选                                                           |
| `sortField`             | String   |   否 | 保留 UMS 现有排序字段；由 UMS 服务白名单校验，不接受客户端 SQL 片段                  |
| `isAsc`                 | Boolean  |   否 | 保留 UMS 现有升降序语义                                                              |
| `categoryId`            | String   |   否 | 主分类                                                                               |
| `subCategoryIds`        | String[] |   否 | 子分类多选，同一维度 OR                                                              |
| `tagGroups`             | Object[] |   否 | 标签筛选组；同组 OR、跨组 AND                                                        |
| `tagGroups[].groupCode` | String   | 条件 | 提交`tagGroups` 时必填                                                             |
| `tagGroups[].tagCodes`  | String[] | 条件 | 提交`tagGroups` 时必填                                                             |
| `pageNum`               | Integer  |   否 | 当前页码，默认`1`                                                                  |
| `pageSize`              | Integer  |   否 | 每页数量，默认`20`                                                                 |

**请求 Mock**

```json
{
  "keyWords": "retirement",
  "templateStatus": "1",
  "channelList": ["EMAIL"],
  "emailStatusList": ["1"],
  "sortField": "updatedDate",
  "isAsc": false,
  "categoryId": "1001",
  "subCategoryIds": ["1101"],
  "tagGroups": [{"groupCode": "LIFECYCLE_STAGE", "tagCodes": ["LIFECYCLE_STAGE_EXISTING_CLIENT"]}],
  "pageNum": 1,
  "pageSize": 20
}
```

**响应字段**

返回分页 `TemplateSummary`，现有分页层级为 `data.pageNo/pageSize/totalCount/totalPage/dataList`；同一 `emailCode` 只返回最大数字版本 V(N)，不会按字符串字典序选版。Category/Subcategory/Tag 始终来自该 `emailCode` 的当前 Template Metadata，不从结果 Version 读取。

**成功响应 Mock**

```json
{
  "requestId": "mock-request-id",
  "responseCode": "00000000",
  "responseMessage": "Succeed",
  "data": {
    "pageNo": 1,
    "pageSize": 20,
    "totalCount": 1,
    "totalPage": 1,
    "dataList": [{
      "emailCode": "815645091883520000",
      "emailName": "Retirement review invitation - working copy",
      "title": "Your retirement review",
      "description": "",
      "version": "V2",
      "emailStatus": "1",
      "versionStatus": 3,
      "categoryId": null,
      "categoryName": null,
      "subCategoryIds": [],
      "subCategoryNames": [],
      "tagMap": {},
      "modifiedTime": "2026-07-16 09:30:00"
    }]
  }
}
```

**失败响应 JSON 示例**

```json
{
  "requestId": "mock-request-id",
  "responseCode": "QA_TESTED_ERROR_CODE",
  "responseMessage": "No permission to view the template list.",
  "data": null
}
```

**错误码与提示**

| 业务语义码                | 实际 responseCode（后续填写） | responseMessage    |
| ------------------------- | ----------------------------- | ------------------ |
| REQUEST_VALIDATION_FAILED | 待开发/QA 填写                | 请求参数不合法。   |
| PERMISSION_DENIED         | 待开发/QA 填写                | 无权限执行此操作。 |

**前端处理与错误**

- 保持 UMS 现有 `templateStatus` 管理态筛选和 Draft 三分支语义，不由前端拼接状态条件；不接收 `tab`。
- Email Subject 作用于后端已选择的结果 Version；Category/Subcategory/Tag Filter 作用于当前 Template Metadata。
- `keyWords` 中的 Email Subject 来自 `result_version`；Tag Name 来自当前 Template Tag relation。
- 本期 Web Template Library 固定为 Email-only；页面不提供 Email/Campaign 类型切换。

### EX-03 Admin Template Detail

**接口与场景**

| 项目     | 内容                                                                 |
| -------- | -------------------------------------------------------------------- |
| Endpoint | `POST /iic-dae-msg/web/msg/template/email/v2/detail`               |
| 页面     | `UI-A-03` Template Detail/Preview、`UI-A-04` Template 创建与编辑 |
| 场景     | 打开管理端模板详情；编辑 Draft/Schedule；Preview 前加载已保存内容    |

**请求参数**

| 字段          | 类型   |     必填 | 说明                                              |
| ------------- | ------ | -------: | ------------------------------------------------- |
| `emailCode` | String |       是 | 模板业务标识                                      |
| `version`   | String | 条件必填 | 编辑明确 version 时必须传；不传时沿用现有选版规则 |

**请求 Mock**

```json
{"emailCode": "926734518203400192", "version": "V1"}
```

**响应字段**

| 字段                          | 类型          | 说明                                                                                  |
| ----------------------------- | ------------- | ------------------------------------------------------------------------------------- |
| `data.emailCode`            | String        | 模板标识                                                                              |
| `data.emailName`            | String        | Template Title                                                                        |
| `data.description`          | String/null   | Template Description                                                                  |
| `data.version`              | String        | 返回内容所属版本                                                                      |
| `data.versionStatus`        | Integer       | Version 状态                                                                          |
| `data.emailStatus`          | String        | Template 启用状态                                                                     |
| `data.copyFromEmailCode`    | String/null   | Copy and Create 来源 Template 的`emailCode`；仅供管理端发布前提醒，不在普通页面展示 |
| `data.title`                | String/null   | Email Subject                                                                         |
| `data.emailContent`         | String        | 加密正文                                                                              |
| `data.emailContentKey`      | String/null   | 正文解密 Key                                                                          |
| `data.textContent`          | String/null   | 纯文本正文                                                                            |
| `data.fileKeys`             | String/null   | 附件 Key，逗号分隔                                                                    |
| `data.fileInfos`            | Object[]      | 附件信息                                                                              |
| `data.fileInfos[].fileKey`  | String        | 附件 Key                                                                              |
| `data.fileInfos[].fileName` | String        | 附件名称                                                                              |
| `data.fileInfos[].fileType` | String        | 附件类型                                                                              |
| `data.fileInfos[].size`     | Long          | 附件大小，单位 Byte                                                                   |
| `data.fileInfos[].viewUrl`  | String/null   | 现有附件访问地址                                                                      |
| `data.isCustomBranding`     | String        | `0=No, 1=Yes`                                                                       |
| `data.effectiveFrom`        | DateTime/null | 生效时间                                                                              |
| `data.effectiveUntil`       | DateTime/null | 失效时间                                                                              |
| `data.categoryId`           | String/null   | 当前 Template 主 Category ID                                                          |
| `data.categoryName`         | String/null   | 当前 Template 主 Category 名称                                                        |
| `data.subCategoryIds`       | String[]      | 当前 Template Subcategory ID                                                          |
| `data.subCategoryNames`     | String[]      | 当前 Template Subcategory 名称                                                        |
| `data.tagMap`               | Object        | `{groupCode: [tagCode]}`；请求不同 version 时值相同                                 |

**成功响应 Mock**

```json
{
  "requestId": "mock-request-id",
  "responseCode": "00000000",
  "responseMessage": "Succeed",
  "data": {
    "emailCode": "926734518203400192",
    "emailName": "Retirement review invitation (Copy)",
    "description": "",
    "version": "V1",
    "versionStatus": 3,
    "emailStatus": "0",
    "copyFromEmailCode": "815645091883520000",
    "title": "Your retirement review",
    "emailContent": "MOCK_AES_CONTENT",
    "emailContentKey": "MOCK_AES_KEY",
    "textContent": "Your retirement review",
    "fileKeys": "",
    "fileInfos": [],
    "isCustomBranding": "0",
    "effectiveFrom": "2026-08-01 09:00:00",
    "effectiveUntil": null,
    "categoryId": "1001",
    "categoryName": "Client Engagement",
    "subCategoryIds": ["1101"],
    "subCategoryNames": ["Advice Review"],
    "tagMap": {"CONTENT_TYPE": ["CONTENT_TYPE_EMAIL"]}
  }
}
```

**失败响应 JSON 示例**

```json
{
  "requestId": "mock-request-id",
  "responseCode": "QA_TESTED_ERROR_CODE",
  "responseMessage": "The requested version does not exist.",
  "data": null
}
```

**错误码与提示**

| 业务语义码         | 实际 responseCode（后续填写） | responseMessage             |
| ------------------ | ----------------------------- | --------------------------- |
| TEMPLATE_NOT_FOUND | 待开发/QA 填写                | Template 不存在或已不可用。 |
| VERSION_NOT_FOUND  | 待开发/QA 填写                | 指定 Version 不存在。       |
| PERMISSION_DENIED  | 待开发/QA 填写                | 无权限执行此操作。          |

**前端处理与错误**

- 编辑 Draft/Schedule/指定历史版本时必须显式传 `version`，不能依赖自动选版。
- 目标 version 不存在或已软删除时提示刷新，不尝试改查其他 version。
- Preview 只展示正文和 Metadata，不展示附件，也不新增 Preview API。
- `copyFromEmailCode` 只用于 Copy 模板发布前提醒，不在 Detail 页面形成来源关系展示，也不得据此限制 A/B 的查询、编辑、发布或停用。

### EX-04 Adviser Published Detail

**接口与场景**

| 项目     | 内容                                                             |
| -------- | ---------------------------------------------------------------- |
| Endpoint | `POST /iic-dae-msg/web/msg/template/email/v2/published/detail` |
| 页面     | `UI-A-03` Adviser Published Detail                             |
| 场景     | Adviser 打开可用模板详情                                         |

**请求参数与 Mock**

| 字段          | 类型   | 必填 | 说明         |
| ------------- | ------ | ---: | ------------ |
| `emailCode` | String |   是 | 模板业务标识 |

```json
{"emailCode": "815645091883520000"}
```

**响应字段**

内容字段与 `EX-03` 相同，但后端强制返回 Adviser 可访问的当前 Active version，不允许前端指定 Draft/Schedule；不返回内部字段 `copyFromEmailCode`。

**成功响应 Mock**

```json
{
  "requestId": "mock-request-id",
  "responseCode": "00000000",
  "responseMessage": "Succeed",
  "data": {
    "emailCode": "815645091883520000",
    "emailName": "Retirement review invitation",
    "description": "Invitation for the annual retirement review",
    "version": "V1",
    "versionStatus": 1,
    "emailStatus": "1",
    "title": "Your retirement review",
    "emailContent": "MOCK_AES_CONTENT",
    "fileKeys": "",
    "fileInfos": [],
    "categoryId": "1001",
    "categoryName": "Client Engagement",
    "subCategoryIds": ["1101"],
    "subCategoryNames": ["Advice Review"],
    "tagMap": {"CONTENT_TYPE": ["CONTENT_TYPE_EMAIL"]}
  }
}
```

**失败响应 JSON 示例**

```json
{
  "requestId": "mock-request-id",
  "responseCode": "QA_TESTED_ERROR_CODE",
  "responseMessage": "The published template is unavailable.",
  "data": null
}
```

**错误码与提示**

| 业务语义码         | 实际 responseCode（后续填写） | responseMessage             |
| ------------------ | ----------------------------- | --------------------------- |
| TEMPLATE_NOT_FOUND | 待开发/QA 填写                | Template 不存在或已不可用。 |
| PERMISSION_DENIED  | 待开发/QA 填写                | 无权限执行此操作。          |

**前端处理与错误**

- 无权限、Inactive、已删除或没有 Active version 时不展示内容。
- 前端不得通过修改请求参数绕过 Published-only 规则。

### EX-15 Channel List

**接口与场景**

| 项目     | 内容                                                        |
| -------- | ----------------------------------------------------------- |
| Endpoint | `POST /iic-dae-msg/web/msg/template/email/v2/channelList` |
| 页面     | `UI-A-04` Template 创建与编辑                             |
| 场景     | 加载 Channel 下拉选项                                       |

**请求参数与 Mock**

无业务参数。

```json
{}
```

**响应字段与 Mock**

| 字段                   | 类型   | 说明         |
| ---------------------- | ------ | ------------ |
| `data[].channelCode` | String | Channel 编码 |
| `data[].channelName` | String | 显示名称     |

```json
{
  "requestId": "mock-request-id",
  "responseCode": "00000000",
  "responseMessage": "Succeed",
  "data": [
    {"channelCode": "EMAIL", "channelName": "Email"},
    {"channelCode": "CAMPAIGN", "channelName": "Campaign"}
  ]
}
```

**失败响应 JSON 示例**

```json
{
  "requestId": "mock-request-id",
  "responseCode": "QA_TESTED_ERROR_CODE",
  "responseMessage": "No permission to load channels.",
  "data": null
}
```

**错误码与提示**

| 业务语义码        | 实际 responseCode（后续填写） | responseMessage        |
| ----------------- | ----------------------------- | ---------------------- |
| PERMISSION_DENIED | 待开发/QA 填写                | 无权限执行此操作。     |
| OPERATION_FAILED  | 待开发/QA 填写                | 操作失败，请稍后重试。 |

**前端处理与错误**

- 沿用现有缓存、空状态和错误提示，不为 LEAD-93 新增特殊处理。

## 3. 模板保存与生命周期

### EX-05 Save Draft / Create Template

**接口与场景**

| 项目 | 内容 |
| --- | --- |
| Endpoint | `POST /iic-dae-msg/web/msg/template/email/v2/add` |
| 页面 | `UI-A-04` Template 创建与编辑 |
| 场景 | 首次创建并保存 V1 Draft；更新已有 Draft；从 Active/Expired 创建 V(N+1) Draft；通过 Save Draft 取消预约 |

**聚合边界**

`/v2/add` 是首次创建的外观聚合入口：当 `emailCode` 为空时，一个请求同时提交 Template 主信息、V1 Draft 内容及当前 Category/Subcategory/Tag 快照。后端在一个 `@Transactional` 事务中生成业务标识、写入 config 和 V1 Draft、写入 Metadata 关系与 `CREATE` 修改历史。任一步校验或写入失败均回滚，不得留下只创建 config/version、但未处理本次 Metadata 的孤儿草稿。

Draft 的 Metadata 可暂时不完整：`categoryId` 可为 `null`，数组可为空；这不等同于分步调用产生的半成品。后续 Publish 仍执行 Category、Subcategory 和 Mandatory Tag 的完整校验。已有 `emailCode` 的 Save Draft 只处理主信息与 Version，不接收 Metadata；现有 Template 的主信息和 Metadata 统一使用 EX-06 更新。

**场景参数**

| 场景 | 关键参数 | 结果 |
| --- | --- | --- |
| 首次创建并 Save Draft | `emailCode` 不传，`isDraft=1`，提交完整 Metadata 快照 | 单事务生成 `emailCode`，Insert config、V1 Draft、关系和 CREATE History |
| Save Draft | `emailCode` 已存在，`isDraft=1` | 始终保存为 Draft；未来时间不会生成 Schedule |
| Cancel Schedule | Schedule version 调用 `isDraft=1` | 同一版本 `0 -> 3`，保留已保存时间 |

**请求参数**

| 字段 | 类型 | 必填 | 说明 |
| --- | --- | ---: | --- |
| `emailCode` | String | 条件 | 首次创建不传；编辑现有 Template 时传 |
| `version` | String | 条件 | 更新 Draft/取消 Schedule 时传真实版本；从 Active/Expired 首次创建 Working Copy 时可不传，由后端生成 V(N+1) |
| `emailName` | String | 是 | Template Title；非空、最长 120 字符并执行字符白名单校验 |
| `description` | String/null | 否 | Template Description |
| `title` | String/null | 否 | Email Subject；Draft 可为空 |
| `emailContent` | String | 是 | AES 加密正文 |
| `emailContentKey` | String/null | 否 | AES Key |
| `textContent` | String/null | 否 | 纯文本正文 |
| `fileKeys` | String/null | 否 | 附件 Key，逗号分隔 |
| `isDraft` | Integer | 是 | 固定传 `1`；`0` 不再作为前端提交/发布入口 |
| `effectiveWay` | Integer/null | 否 | Draft 可暂存现有值；不触发 Schedule |
| `effectiveFrom` | DateTime/null | 否 | Draft 可暂存，按南非业务时区解释 |
| `effectiveUntil` | DateTime/null | 否 | Draft 可暂存，按南非业务时区解释 |
| `moduleCode` | String/null | 否 | 模块编码 |
| `moduleCodeName` | String/null | 否 | 模块名称 |
| `scenarioCode` | String/null | 否 | 场景编码 |
| `editMode` | String/null | 否 | 编辑器模式 |
| `thumbnailKey` | String/null | 否 | 缩略图 Key |
| `channelMap` | Object/null | 否 | Channel Code 与名称映射 |
| `isCustomBranding` | String | 是 | `0/1` |
| `categoryId` | String/null | 条件 | **仅首次创建时必传字段**；当前主 Category，`null` 表示 Draft 暂未选择 |
| `subCategoryIds` | String[] | 条件 | **仅首次创建时必传字段**；完整快照，空数组表示暂未选择 |
| `tagGroups` | Object[] | 条件 | **仅首次创建时必传字段**；完整 4 组快照，组内空数组表示暂未选择 |
| `tagGroups[].groupCode` | String | 条件 | 提交 `tagGroups` 时必填 |
| `tagGroups[].tagCodes` | String[] | 条件 | 提交 `tagGroups` 时必填；Trigger 去重后最多 5 个 |

当 `emailCode` 已存在时，`categoryId`、`subCategoryIds`、`tagGroups` 不得提交；后端拒绝混合写入，避免 EX-05 与 EX-06 产生两套 Metadata 更新语义。

**请求 Mock：首次创建并 Save Draft**

```json
{
  "moduleCode": "COMMUNICATION",
  "moduleCodeName": "Communications",
  "scenarioCode": "TEMPLATE_LIBRARY",
  "emailName": "Retirement review invitation",
  "description": "",
  "title": "Your retirement review",
  "editMode": "HTML",
  "emailContent": "MOCK_AES_CONTENT",
  "emailContentKey": "MOCK_AES_KEY",
  "textContent": "Your retirement review",
  "fileKeys": "",
  "isDraft": 1,
  "effectiveWay": 1,
  "effectiveFrom": "2026-08-01 09:00:00",
  "effectiveUntil": null,
  "thumbnailKey": null,
  "channelMap": {},
  "isCustomBranding": "0",
  "categoryId": "1001",
  "subCategoryIds": ["1101"],
  "tagGroups": [
    {"groupCode": "CONTENT_TYPE", "tagCodes": ["CONTENT_TYPE_EMAIL"]},
    {"groupCode": "TRIGGER", "tagCodes": ["TRIGGER_ANNUAL_REVIEW"]},
    {"groupCode": "LIFECYCLE_STAGE", "tagCodes": ["LIFECYCLE_STAGE_EXISTING_CLIENT"]},
    {"groupCode": "FINANCIAL_NEED", "tagCodes": ["FINANCIAL_NEED_PLAN_RETIREMENT"]}
  ]
}
```

**请求 Mock：保存已有 Draft**

```json
{
  "emailCode": "815645091883520000",
  "version": "V2",
  "emailName": "Retirement review invitation",
  "description": "",
  "title": "Your retirement review",
  "editMode": "HTML",
  "emailContent": "MOCK_AES_CONTENT",
  "emailContentKey": "MOCK_AES_KEY",
  "textContent": "Your retirement review",
  "fileKeys": "",
  "isDraft": 1,
  "effectiveWay": 1,
  "effectiveFrom": "2026-08-01 09:00:00",
  "effectiveUntil": null,
  "thumbnailKey": null,
  "channelMap": {},
  "isCustomBranding": "0"
}
```

**响应字段**

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| `data.emailCode` | String | 首次保存时返回新生成的业务 ID |
| `data.version` | String | 实际保存的 version |

**成功响应 Mock**

```json
{
  "requestId": "mock-request-id",
  "responseCode": "00000000",
  "responseMessage": "Succeed",
  "data": {"emailCode": "815645091883520000", "version": "V1"}
}
```

**失败响应 JSON 示例**

```json
{
  "requestId": "mock-request-id",
  "responseCode": "QA_TESTED_ERROR_CODE",
  "responseMessage": "Template creation validation failed.",
  "data": {
    "fieldErrors": [
      {"field": "categoryId", "code": "INVALID", "message": "Category 不存在或已删除。"},
      {"field": "tagGroups[1].tagCodes", "code": "MAX_SIZE", "message": "Trigger 最多选择 5 个。"}
    ],
    "invalidFieldCount": 2
  }
}
```

**错误码与提示**

| 业务语义码 | 实际 responseCode（后续填写） | responseMessage |
| --- | --- | --- |
| REQUEST_VALIDATION_FAILED | 待开发/QA 填写 | 请求参数不合法。 |
| TEMPLATE_NAME_DUPLICATE | 待开发/QA 填写 | 当前 Category 下 Template Title 已存在。 |
| CATEGORY_NOT_FOUND | 待开发/QA 填写 | Category/Subcategory 不存在或已删除。 |
| CATEGORY_LEVEL_INVALID | 待开发/QA 填写 | Category 层级或父节点不合法。 |
| TAG_VALUE_INVALID | 待开发/QA 填写 | Tag 选择无效或已失效。 |
| METADATA_VALIDATION_FAILED | 待开发/QA 填写 | Template Metadata 校验失败。 |
| VERSION_STATE_INVALID | 待开发/QA 填写 | 当前 Version 状态不允许此操作。 |
| VERSION_CONFLICT | 待开发/QA 填写 | Template Version 已变更，请刷新后重试。 |
| OPERATION_FAILED | 待开发/QA 填写 | 操作失败，请稍后重试。 |

**前端处理与错误**

- 首次创建必须在同一个 EX-05 请求中提交 Metadata 完整快照；前端不得先调用 EX-05 再调用独立 Metadata 接口。
- 后端按 `@Transactional` 执行：生成 `emailCode` -> Insert config -> Insert V1 Draft -> 写 `category_id`、Subcategory/Tag relations -> 写 `CREATE` Change History。任何字段校验、唯一性、taxonomy 归属、relation 或 history 写入失败都整体回滚。
- 所有可同时发现的创建校验错误通过 `data.fieldErrors[]` 返回；`invalidFieldCount` 等于数组长度。失败时前端保留编辑内容，不将 `emailCode` 写入本地状态。
- Save Draft 的版本分支保持现状：新建 V1 Insert；已有 Draft Update；Active 无 Draft时 Insert V(N+1)；仅 Expired 且无 Draft时保留 Expired V(N) 并 Insert V(N+1) Draft；Schedule 时 Update 同一 V(N) 为 Draft。
- 已有 Draft 或 Schedule 时，前端不得创建另一 Draft；编辑或取消预约必须提交目标版本的真实 `version`。
- 附件可选；单个最大 10 MB；前端沿用现有格式校验并排除多媒体、音频和视频。

### EX-16 Publish / Schedule

**接口与场景**

| 项目     | 内容                                                                           |
| -------- | ------------------------------------------------------------------------------ |
| Endpoint | `POST /iic-dae-msg/web/msg/template/email/v2/publish`                        |
| 页面     | `UI-A-04` Template 创建与编辑                                                |
| 场景     | 以页面最新内容发布已有 Draft；或者不先 Save Draft，直接创建并发布全新 Template |

**请求参数**

| 字段                      | 类型          | 必填 | 说明                                                                           |
| ------------------------- | ------------- | ---: | ------------------------------------------------------------------------------ |
| `emailCode`             | String        | 条件 | 发布已有 Draft 时必填；全新未落库 Template 直接 Publish 时不传                 |
| `targetVersion`         | String        | 条件 | 发布已有 Draft 时必填且必须是当前 Draft；全新 Template 不传，成功时固定创建 V1 |
| `emailName`             | String        |   是 | 页面当前 Template Title；参与完整 Publish Validation                           |
| `description`           | String/null   |   是 | 页面当前 Description；按 Publish 规则校验                                      |
| `title`                 | String        |   是 | 页面当前 Email Subject                                                         |
| `emailContent`          | String        |   是 | 页面当前 AES 加密正文                                                          |
| `emailContentKey`       | String/null   | 条件 | 正文解密 Key                                                                   |
| `textContent`           | String/null   |   否 | 页面当前纯文本正文                                                             |
| `fileKeys`              | String/null   |   否 | 页面当前附件 Key，逗号分隔                                                     |
| `moduleCode`            | String/null   |   否 | 页面当前模块编码                                                               |
| `moduleCodeName`        | String/null   |   否 | 页面当前模块名称                                                               |
| `scenarioCode`          | String/null   |   否 | 页面当前场景编码                                                               |
| `editMode`              | String/null   |   否 | 页面当前编辑器模式                                                             |
| `thumbnailKey`          | String/null   |   否 | 页面当前缩略图 Key                                                             |
| `channelMap`            | Object/null   |   否 | 页面当前 Channel Code 与名称映射                                               |
| `isCustomBranding`      | String        |   是 | 页面当前 Branding，`0/1`                                                     |
| `categoryId`            | String/null   | 条件 | 全新 Template 直接 Publish 时必填；已有 Draft 不传并从数据库读取当前值         |
| `subCategoryIds`        | String[]      | 条件 | 全新 Template 直接 Publish 时提交完整当前快照；已有 Draft 不传                 |
| `tagGroups`             | Object[]      | 条件 | 全新 Template 直接 Publish 时提交完整 4 组当前快照；已有 Draft 不传            |
| `tagGroups[].groupCode` | String        | 条件 | 全新 Template 直接 Publish 时必填                                              |
| `tagGroups[].tagCodes`  | String[]      | 条件 | 全新 Template 直接 Publish 时必填；空数组表示该组未选择                        |
| `effectiveWay`          | Integer       |   是 | `0=立即发布, 1=预约发布`                                                     |
| `effectiveFrom`         | DateTime/null | 条件 | `effectiveWay=1`时必填且必须晚于当前南非业务时间；立即发布传 null            |

```json
{
  "emailCode": "815645091883520000",
  "targetVersion": "V2",
  "moduleCode": "COMMUNICATION",
  "moduleCodeName": "Communications",
  "scenarioCode": "TEMPLATE_LIBRARY",
  "emailName": "Retirement review invitation",
  "description": "Invitation for the annual retirement review",
  "title": "Your retirement review",
  "editMode": "HTML",
  "emailContent": "MOCK_AES_CONTENT",
  "emailContentKey": "MOCK_AES_KEY",
  "textContent": "Your retirement review",
  "fileKeys": "",
  "thumbnailKey": null,
  "channelMap": {},
  "isCustomBranding": "0",
  "effectiveWay": 1,
  "effectiveFrom": "2026-08-01 09:00:00"
}
```

**请求 Mock：全新 Template 直接 Publish**

```json
{
  "moduleCode": "COMMUNICATION",
  "moduleCodeName": "Communications",
  "scenarioCode": "TEMPLATE_LIBRARY",
  "emailName": "New retirement review invitation",
  "description": "Invitation for the annual retirement review",
  "title": "Your retirement review",
  "editMode": "HTML",
  "emailContent": "MOCK_AES_CONTENT",
  "emailContentKey": "MOCK_AES_KEY",
  "textContent": "Your retirement review",
  "fileKeys": "",
  "thumbnailKey": null,
  "channelMap": {},
  "isCustomBranding": "0",
  "categoryId": "1001",
  "subCategoryIds": ["1101"],
  "tagGroups": [
    {"groupCode": "CONTENT_TYPE", "tagCodes": ["CONTENT_TYPE_EMAIL"]},
    {"groupCode": "TRIGGER", "tagCodes": ["TRIGGER_ANNUAL_REVIEW"]},
    {"groupCode": "LIFECYCLE_STAGE", "tagCodes": ["LIFECYCLE_STAGE_EXISTING_CLIENT"]},
    {"groupCode": "FINANCIAL_NEED", "tagCodes": ["FINANCIAL_NEED_PLAN_RETIREMENT"]}
  ],
  "effectiveWay": 0,
  "effectiveFrom": null
}
```

**响应字段与 Mock**

命令成功时返回 `data=null`。前端关闭编辑页并重新加载对应列表，不依赖响应推导最终状态。

```json
{
  "requestId": "mock-request-id",
  "responseCode": "00000000",
  "responseMessage": "Succeed",
  "data": null
}
```

**失败响应 JSON 示例**

```json
{
  "requestId": "mock-request-id",
  "responseCode": "QA_TESTED_ERROR_CODE",
  "responseMessage": "发布前必须填写 10 个字段。",
  "data": {
    "fieldErrors": [
      {
        "field": "emailName",
        "code": "REQUIRED",
        "message": "需要 Template Title。"
      },
      {
        "field": "description",
        "code": "REQUIRED",
        "message": "需要 Description。"
      },
      {
        "field": "title",
        "code": "REQUIRED",
        "message": "需要 Email Subject。"
      },
      {
        "field": "emailContent",
        "code": "REQUIRED",
        "message": "需要邮件正文。"
      },
      {
        "field": "categoryId",
        "code": "REQUIRED",
        "message": "必须分配 Category。"
      },
      {
        "field": "subCategoryIds",
        "code": "REQUIRED",
        "message": "必须分配至少一个 Subcategory。"
      },
      {
        "field": "tagGroups[0].tagCodes",
        "code": "REQUIRED",
        "message": "必须选择 Content Type。"
      },
      {
        "field": "tagGroups[1].tagCodes",
        "code": "REQUIRED",
        "message": "必须选择至少一个 Trigger。"
      },
      {
        "field": "tagGroups[2].tagCodes",
        "code": "REQUIRED",
        "message": "必须选择 Lifecycle Stage。"
      },
      {
        "field": "tagGroups[3].tagCodes",
        "code": "REQUIRED",
        "message": "必须选择 Financial Need。"
      }
    ],
    "invalidFieldCount": 10
  }
}
```

**错误码与提示**

| 业务语义码                 | 实际 responseCode（后续填写） | responseMessage                          |
| -------------------------- | ----------------------------- | ---------------------------------------- |
| PUBLISH_VALIDATION_FAILED  | 待开发/QA 填写                | 发布前必须填写 X 个字段。                |
| TEMPLATE_NAME_DUPLICATE    | 待开发/QA 填写                | 当前 Category 下 Template Title 已存在。 |
| METADATA_VALIDATION_FAILED | 待开发/QA 填写                | Template Metadata 校验失败。             |
| TAG_VALUE_INVALID          | 待开发/QA 填写                | Tag 选择无效或已失效。                   |
| VERSION_CONFLICT           | 待开发/QA 填写                | Template Version 已变更，请刷新后重试。  |
| VERSION_STATE_INVALID      | 待开发/QA 填写                | 当前 Version 状态不允许此操作。          |
| OPERATION_FAILED           | 待开发/QA 填写                | 操作失败，请稍后重试。                   |

**前端处理与错误**

- 当管理端 Detail 的 `copyFromEmailCode` 非空时，前端必须在真正调用本接口前显示非阻断确认框：说明发布 B 不会自动停用来源 Template A，若 A 不应继续使用，CM 需通过现有 Deactivate 操作单独停用 A。用户可取消返回编辑器，也可确认后继续发布。
- Popup 只负责提醒，不调用新的后端接口、不把来源状态作为 Publish 前置条件，也不向 Publish 请求增加确认字段；即使 A 仍为 Active，B 仍可正常发布。
- 发布已有 Draft：后端使用请求中的页面快照校验 Template/Version 字段，并读取该 `emailCode` 的当前 Category/Subcategory/Tag；请求不得覆盖已保存 Metadata。
- 全新 Template 直接 Publish：请求不传 `emailCode/targetVersion`，同时提交首次 Category/Subcategory/Tag 当前快照。Metadata 仍归属于新生成的 `emailCode`，不是 V1 的版本级数据。
- 所有字段校验必须在写入前完成；若现有 Version Conflict 检测命中，也必须在写入前失败。失败时不保存页面内容、不更新原 Draft、不创建新 Version；返回 `invalidFieldCount + fieldErrors[]`。其精确命中条件待专项核实。
- `emailName` 与当前主 Category 内其他有效 Template 重复时返回 `TEMPLATE_NAME_DUPLICATE`，字段为 `emailName`、`code="DUPLICATE"`；前端保留输入并显示内联提示。缺少 Title、Description、Category、Subcategory、Mandatory Tag、Subject 或正文时返回 `PUBLISH_VALIDATION_FAILED`。
- 发布命令必须原子完成页面快照保存和状态切换，任一步失败均不得产生部分结果。
- 全新 Template 校验成功后生成新 `emailCode` 和 V1；V1 直接进入 Active 或 Schedule，不先产生 Draft。
- 立即发布：旧 Active 变 Expired，目标 Draft 以请求快照更新后变 Active，`effectiveFrom=now`、`effectiveUntil=null`。
- 预约发布：目标 Draft 以请求快照更新后变 Schedule，保存未来 `effectiveFrom`；到时由现有 Scheduler 切换状态。
- Version Conflict 沿用现有失败路径；目标 Draft 不存在或状态已变化时整体失败。Active 基线的精确比较规则仍待专项核实，不在本契约虚构字段或错误码。
- 历史 Template 重新 Publish 时同样执行全部必填校验。

### EX-06 Update Template Master Fields and Metadata

**接口与场景**

| 项目 | 内容 |
| --- | --- |
| Endpoint | `POST /iic-dae-msg/web/msg/template/email/v2/update` |
| 页面 | `UI-A-04` Template 编辑；`UI-A-11` 单个 Template 当前属性编辑 |
| 场景 | 一次性保存已有 Template 的名称、描述、当前 Category/Subcategory/Tag；单个 Template Reassignment |

**聚合边界**

EX-06 是已有 Template 的主信息与 Metadata 外观聚合接口，不再暴露独立 Metadata Endpoint。它只更新 Template 主表和当前关系表，并写一条 Template Change History 快照；不创建或更新内容 Version，不改变 `versionStatus/effectiveFrom/effectiveUntil`，也不触发发布、预约或版本状态机切换。

**请求参数**

| 字段 | 类型 | 必填 | 说明 |
| --- | --- | ---: | --- |
| `emailCode` | String | 是 | Template 标识 |
| `emailName` | String | 是 | 当前 Template Name |
| `description` | String/null | 否 | 当前 Description |
| `channelMap` | Object/null | 否 | 渠道 Map；键为 Channel Code，值为 Channel Name |
| `categoryId` | String/null | 是 | 当前主 Category；`null` 表示 Draft 暂未选择 |
| `subCategoryIds` | String[] | 是 | 当前 Subcategory 完整快照；空数组表示清空 |
| `tagGroups` | Object[] | 是 | 当前 4 个 Tag Group 完整快照；每组都必须出现 |
| `tagGroups[].groupCode` | String | 是 | 固定 Group 编码 |
| `tagGroups[].tagCodes` | String[] | 是 | Group 内完整 Tag Code 列表；空数组表示清空；Trigger 去重后最多 5 个 |

**请求 Mock**

```json
{
  "emailCode": "815645091883520000",
  "emailName": "Retirement review invitation",
  "description": "Invitation for the annual retirement review",
  "channelMap": {"EMAIL": "Email"},
  "categoryId": "1001",
  "subCategoryIds": ["1101"],
  "tagGroups": [
    {"groupCode": "CONTENT_TYPE", "tagCodes": ["CONTENT_TYPE_EMAIL"]},
    {"groupCode": "TRIGGER", "tagCodes": ["TRIGGER_ANNUAL_REVIEW"]},
    {"groupCode": "LIFECYCLE_STAGE", "tagCodes": ["LIFECYCLE_STAGE_EXISTING_CLIENT"]},
    {"groupCode": "FINANCIAL_NEED", "tagCodes": ["FINANCIAL_NEED_PLAN_RETIREMENT"]}
  ]
}
```

**响应字段与 Mock**

成功时返回已保存的当前 Metadata 摘要，供前端同步本地状态。

```json
{
  "requestId": "mock-request-id",
  "responseCode": "00000000",
  "responseMessage": "Succeed",
  "data": {
    "emailCode": "815645091883520000",
    "categoryId": "1001",
    "subCategoryIds": ["1101"],
    "tagGroupCount": 4,
    "tagRelationCount": 4
  }
}
```

**失败响应 JSON 示例**

```json
{
  "requestId": "mock-request-id",
  "responseCode": "QA_TESTED_ERROR_CODE",
  "responseMessage": "Template update validation failed.",
  "data": {
    "fieldErrors": [
      {"field": "emailName", "code": "DUPLICATE", "message": "当前 Category 下 Template Title 已存在。"},
      {"field": "subCategoryIds[0]", "code": "INVALID", "message": "Subcategory 不属于当前 Category。"}
    ],
    "invalidFieldCount": 2
  }
}
```

**错误码与提示**

| 业务语义码 | 实际 responseCode（后续填写） | responseMessage |
| --- | --- | --- |
| REQUEST_VALIDATION_FAILED | 待开发/QA 填写 | 请求参数不合法。 |
| TEMPLATE_NAME_DUPLICATE | 待开发/QA 填写 | 当前 Category 下 Template Title 已存在。 |
| TEMPLATE_NOT_FOUND | 待开发/QA 填写 | Template 不存在或已不可用。 |
| CATEGORY_NOT_FOUND | 待开发/QA 填写 | Category/Subcategory 不存在或已删除。 |
| INVALID_SUBCATEGORY_BELONGING | 待开发/QA 填写 | 选定的 Subcategory 不属于当前主 Category。 |
| CATEGORY_LEVEL_INVALID | 待开发/QA 填写 | Category 层级或父节点不合法。 |
| TAG_VALUE_INVALID | 待开发/QA 填写 | Tag 选择无效或已失效。 |
| METADATA_VALIDATION_FAILED | 待开发/QA 填写 | Template Metadata 校验失败。 |
| OPERATION_FAILED | 待开发/QA 填写 | 操作失败，请稍后重试。 |

**前端处理与错误**

- 一次请求提交 `emailName`、`description`、`categoryId`、`subCategoryIds` 和完整 `tagGroups` 快照；字段缺失不解释为“保持原值”。
- 后端在单一 `@Transactional` 事务内校验名称、taxonomy 和 Tag 上限，更新 config 主字段及 `category_id`，全量替换 Subcategory/Tag relations，并写一条包含前后快照的 Template Change History。任一步失败全部回滚。
- 所有可同时发现的输入错误都通过 `data.fieldErrors[]` 返回；`invalidFieldCount` 等于数组长度。通常的对象不存在、事务失败等非字段定位失败仍可返回 `data=null`。
- 该接口不接收 `version`，不修改 Subject、正文、附件或生效时间；已 Published 的 Template 成功修改 Category/Subcategory 后仍保持 Published，不创建 Draft 或新 Version。
- 批量 Template Reassignment 使用 NEW-11；其业务含义是批量处理，不应通过循环调用 EX-06 替代。

### EX-07 Change Status

**接口与场景**

| 项目     | 内容                                                         |
| -------- | ------------------------------------------------------------ |
| Endpoint | `POST /iic-dae-msg/web/msg/template/email/v2/changeStatus` |
| 页面     | `UI-A-01` Template Library                                 |
| 场景     | Deactivate；Active/Reactivate                                |

**请求参数与 Mock**

| 字段            | 类型    | 必填 | 说明                     |
| --------------- | ------- | ---: | ------------------------ |
| `emailCode`   | String  |   是 | 模板标识                 |
| `emailStatus` | Integer |   是 | `0=Inactive, 1=Active` |

```json
{"emailCode": "815645091883520000", "emailStatus": 0}
```

**响应字段与 Mock**

```json
{"requestId": "mock-request-id", "responseCode": "00000000", "responseMessage": "Succeed", "data": null}
```

**失败响应 JSON 示例**

```json
{
  "requestId": "mock-request-id",
  "responseCode": "QA_TESTED_ERROR_CODE",
  "responseMessage": "The template does not exist.",
  "data": null
}
```

**错误码与提示**

| 业务语义码                | 实际 responseCode（后续填写） | responseMessage             |
| ------------------------- | ----------------------------- | --------------------------- |
| REQUEST_VALIDATION_FAILED | 待开发/QA 填写                | 请求参数不合法。            |
| TEMPLATE_NOT_FOUND        | 待开发/QA 填写                | Template 不存在或已不可用。 |
| OPERATION_FAILED          | 待开发/QA 填写                | 操作失败，请稍后重试。      |

**前端处理与错误**

- Deactivate 只修改 `config.email_status`，不修改 config.status 或任何 `versionStatus`。
- Reactivate 恢复原 Active 内容，不重新执行 Publish。
- 重复提交相同状态不得改变 Version 或重新执行 Publish。

### EX-08 Delete Template

**接口与场景**

| 项目     | 内容                                                   |
| -------- | ------------------------------------------------------ |
| Endpoint | `POST /iic-dae-msg/web/msg/template/email/v2/delete` |
| 页面     | `UI-A-05` Template Delete                            |
| 场景     | 删除 Draft Template                                    |

**请求参数与 Mock**

| 字段          | 类型   | 必填 | 说明     |
| ------------- | ------ | ---: | -------- |
| `emailCode` | String |   是 | 模板标识 |

```json
{"emailCode": "815645091883520000"}
```

**响应字段与 Mock**

```json
{"requestId": "mock-request-id", "responseCode": "00000000", "responseMessage": "Succeed", "data": null}
```

**失败响应 JSON 示例**

```json
{
  "requestId": "mock-request-id",
  "responseCode": "QA_TESTED_ERROR_CODE",
  "responseMessage": "The template does not exist.",
  "data": null
}
```

**错误码与提示**

| 业务语义码         | 实际 responseCode（后续填写） | responseMessage             |
| ------------------ | ----------------------------- | --------------------------- |
| TEMPLATE_NOT_FOUND | 待开发/QA 填写                | Template 不存在或已不可用。 |
| OPERATION_FAILED   | 待开发/QA 填写                | 操作失败，请稍后重试。      |

**前端处理与错误**

- Delete 继续软删除 config 和所有 version；Category/Subcategory/Tag 当前关系不按 version 清理。
- 不修改任何 version 的 `versionStatus`。
- 成功后从列表移除，详情页返回列表；不清理 S3 附件。

### NEW-10 Copy and Create

**接口与场景**

| 项目     | 内容                                                                                    |
| -------- | --------------------------------------------------------------------------------------- |
| Endpoint | `POST /iic-dae-msg/web/msg/template/email/v2/copy`                                    |
| 页面     | `UI-A-06` Version History / Copy and Create 后的模板编辑页                            |
| 场景     | 从当前最新 Published/Active Version 预填独立模板；首次点击 Save Draft 时创建 Template B |

**前端调用时点**

1. 点击 Copy and Create：前端通过现有 Detail 数据预填页面，不调用 `NEW-10`。
2. 用户可编辑预填字段；默认 `emailName` 为原名称加 `(Copy)`。
3. 首次点击 Save Draft：前端提交完整编辑后快照，调用 `NEW-10`。
4. 成功后使用返回的 `emailCode` 和 `version="V1"` 进入普通 Draft 编辑流程；后续保存使用 `EX-05/EX-10`。
5. B 后续点击 Publish 时，根据 Detail 返回的 `copyFromEmailCode` 显示来源 Template 停用提醒；确认继续后仍调用普通 `EX-16`。

**请求参数**

| 字段                      | 类型        | 必填 | 说明                                                                                                                      |
| ------------------------- | ----------- | ---: | ------------------------------------------------------------------------------------------------------------------------- |
| `sourceEmailCode`       | String      |   是 | 来源 Template A；只允许当前 Enabled 且未软删除的 Published Template                                                       |
| `sourceVersion`         | String      |   是 | 前端预填时加载的当前最新 Active Version；保存时后端重新校验仍为当前 Active                                                |
| `emailName`             | String      |   是 | B 的 Template Title；默认追加` (Copy)`，该固定结尾是字符白名单的唯一括号例外；重名返回字段错误，不自动生成 `(Copy 2)` |
| `description`           | String/null |   否 | 预填 A 的 Description，允许保存前修改                                                                                     |
| `moduleCode`            | String/null |   否 | 预填 A 的模块编码                                                                                                         |
| `moduleCodeName`        | String/null |   否 | 预填 A 的模块名称                                                                                                         |
| `scenarioCode`          | String/null |   否 | 预填 A 的场景编码                                                                                                         |
| `channelMap`            | Object/null |   否 | 预填 A 的 Channel 信息                                                                                                    |
| `isCustomBranding`      | String      |   是 | 预填 A 的 Custom Branding；`0/1`                                                                                        |
| `title`                 | String/null |   否 | B V1 Draft 的 Email Subject                                                                                               |
| `editMode`              | String/null |   否 | B V1 Draft 的编辑器模式                                                                                                   |
| `emailContent`          | String/null |   否 | B V1 Draft 的加密正文                                                                                                     |
| `emailContentKey`       | String/null | 条件 | B V1 Draft 提交加密正文时传入解密 Key                                                                                     |
| `textContent`           | String/null |   否 | B V1 Draft 的纯文本正文                                                                                                   |
| `fileKeys`              | String/null |   否 | 复用 A Active Version 的附件 Key；不复制 S3 对象或上传记录                                                                |
| `thumbnailKey`          | String/null |   否 | 预填的缩略图 Key                                                                                                          |
| `categoryId`            | String/null |   否 | B 的当前主 Category；保存时必须仍为有效一级节点                                                                           |
| `subCategoryIds`        | String[]    |   否 | B 的全部当前 Subcategory；必须属于`categoryId`                                                                          |
| `tagGroups`             | Object[]    |   否 | B 的全部当前 Tag；Draft 可为空，Trigger 最多 5 个                                                                         |
| `tagGroups[].groupCode` | String      | 条件 | 提交`tagGroups` 时必填                                                                                                  |
| `tagGroups[].tagCodes`  | String[]    | 条件 | 提交`tagGroups` 时必填；空数组表示该组未选择                                                                            |

`NEW-10` 固定创建 `V1 Draft`，不接收 `emailCode/version/isDraft/effectiveWay/effectiveFrom/effectiveUntil/versionStatus` 等目标生命周期字段。

**请求 Mock**

```json
{
  "sourceEmailCode": "815645091883520000",
  "sourceVersion": "V3",
  "moduleCode": "COMMUNICATION",
  "moduleCodeName": "Communications",
  "scenarioCode": "TEMPLATE_LIBRARY",
  "emailName": "Retirement review invitation (Copy)",
  "description": "Invitation for the annual retirement review",
  "channelMap": {},
  "isCustomBranding": "0",
  "title": "Your retirement review",
  "editMode": "HTML",
  "emailContent": "MOCK_AES_CONTENT",
  "emailContentKey": "MOCK_AES_KEY",
  "textContent": "Your retirement review",
  "fileKeys": "s3-file-key-01,s3-file-key-02",
  "thumbnailKey": null,
  "categoryId": "1001",
  "subCategoryIds": ["1101", "1102"],
  "tagGroups": [
    {"groupCode": "CONTENT_TYPE", "tagCodes": ["CONTENT_TYPE_EMAIL"]},
    {"groupCode": "TRIGGER", "tagCodes": ["TRIGGER_REVIEW"]}
  ]
}
```

**响应字段与 Mock**

| 字段                   | 类型    | 说明                                          |
| ---------------------- | ------- | --------------------------------------------- |
| `data.emailCode`     | String  | 后端为 B 生成的新业务标识                     |
| `data.version`       | String  | 固定返回`V1`                                |
| `data.versionStatus` | Integer | 固定返回`3=Draft`                           |
| `data.emailStatus`   | String  | B 的当前启停状态，按新建 Draft 现有默认值返回 |

```json
{
  "requestId": "mock-request-id",
  "responseCode": "00000000",
  "responseMessage": "Succeed",
  "data": {
    "emailCode": "926734518203400192",
    "version": "V1",
    "versionStatus": 3,
    "emailStatus": "0"
  }
}
```

**失败响应 JSON 示例**

```json
{
  "requestId": "mock-request-id",
  "responseCode": "QA_TESTED_ERROR_CODE",
  "responseMessage": "The source template is no longer the current Active template.",
  "data": null
}
```

**错误码与提示**

| 业务语义码                 | 实际 responseCode（后续填写） | responseMessage                            |
| -------------------------- | ----------------------------- | ------------------------------------------ |
| COPY_SOURCE_NOT_ACTIVE     | 待开发/QA 填写                | 来源 Template 已不是当前 Active Template。 |
| TEMPLATE_NAME_DUPLICATE    | 待开发/QA 填写                | 当前 Category 下 Template Title 已存在。   |
| REQUEST_VALIDATION_FAILED  | 待开发/QA 填写                | 请求参数不合法。                           |
| METADATA_VALIDATION_FAILED | 待开发/QA 填写                | Template Metadata 校验失败。               |
| TAG_VALUE_INVALID          | 待开发/QA 填写                | Tag 选择无效或已失效。                     |
| OPERATION_FAILED           | 待开发/QA 填写                | 操作失败，请稍后重试。                     |

**前端处理与错误**

- 来源校验失败：来源不存在、已停用/删除，或 `sourceVersion` 已不再是当前最新 Active；前端保留页面内容并提示刷新来源后重试。
- 字段校验失败且 `fieldErrors[].field="emailName"`：默认 `(Copy)` 名称冲突；前端定位名称输入框，由用户修改后重试。
- Category/Subcategory/Tag 已失效或归属不合法时返回字段级错误；Draft 不执行 Publish 的四个 Mandatory Tag Group 完整性校验。
- Template B、V1 Draft 和 Metadata 必须原子创建；任一步失败均不得返回成功或留下半成品。
- 创建 B 时在 `iic_msg_email_config.copy_from_email_code` 保存 A 的 `emailCode`，作为不可变的内部来源追踪值；普通新建 Template 保存 `NULL`。
- 来源 Template A 全程只读，不更新其状态、内容、Metadata 或附件引用。除上述内部来源字段和发布前 Popup 外，A/B 不建立可导航或可操作的业务关系；后续均 Published 时，Content Manager 和 Adviser 都按两个普通 Template 展示。
- B 的 Save Draft、Publish、Schedule、Deactivate、Delete 和 Version History 完全复用普通 Template 规则；不得因 `copy_from_email_code` 改写 A 或 B 的内容级 Version 生命周期。

## 4. 版本管理

### EX-09 Add Version

**接口与场景**

| 项目     | 内容                                                                                     |
| -------- | ---------------------------------------------------------------------------------------- |
| Endpoint | `POST /iic-dae-msg/web/msg/template/email/v2/version/add`                              |
| 页面     | `UI-A-06` Version History / 增加版本流程                                               |
| 场景     | 在同一 Template 下增加目标内容 Version：立即生效时进入 Active；预约生效时先进入 Schedule |

**请求参数与 Mock**

| 字段                 | 类型          | 必填 | 说明                                                   |
| -------------------- | ------------- | ---: | ------------------------------------------------------ |
| `emailCode`        | String        |   是 | 模板标识                                               |
| `version`          | String        |   是 | 实测新增目标版本传`V2`，不是源 Active version `V1` |
| `moduleCode`       | String/null   |   否 | 模块编码                                               |
| `scenarioCode`     | String/null   |   否 | 场景编码                                               |
| `editMode`         | String        |   是 | 编辑器模式                                             |
| `title`            | String        |   是 | Email Subject；新增并发布版本时参与发布校验            |
| `emailContent`     | String        |   是 | AES 加密正文                                           |
| `emailContentKey`  | String/null   | 条件 | 加密正文需要解密 Key 时必填                            |
| `textContent`      | String/null   |   否 | 纯文本正文                                             |
| `effectiveWay`     | Integer       |   是 | `0=立即生效, 1=预约生效`                             |
| `effectiveFrom`    | DateTime/null | 条件 | `effectiveWay=1` 时必填                              |
| `effectiveUntil`   | DateTime/null |   否 | 沿用现有版本字段                                       |
| `fileKeys`         | String/null   |   否 | 附件 Key，逗号分隔                                     |
| `thumbnailKey`     | String/null   |   否 | 缩略图 Key                                             |
| `isCustomBranding` | String        |   是 | `0=No, 1=Yes`                                        |

```json
{
  "emailCode": "815645091883520000",
  "version": "V2",
  "moduleCode": "COMMUNICATION",
  "scenarioCode": "TEMPLATE_LIBRARY",
  "title": "LEAD-93 V2 API test",
  "effectiveWay": 0,
  "effectiveFrom": null,
  "effectiveUntil": null,
  "editMode": "HTML",
  "emailContent": "MOCK_AES_CONTENT",
  "textContent": "LEAD-93 V2 API test",
  "fileKeys": "",
  "emailContentKey": "MOCK_AES_KEY",
  "thumbnailKey": null,
  "isCustomBranding": "0"
}
```

**响应字段与 Mock**

| 字段                   | 类型    | 说明                 |
| ---------------------- | ------- | -------------------- |
| `requestId`          | String  | 请求追踪标识         |
| `responseCode`       | String  | 成功时为`00000000` |
| `responseMessage`    | String  | 成功时为`Succeed`  |
| `data.emailCode`     | String  | 模板标识             |
| `data.version`       | String  | 新增的目标版本号     |
| `data.versionStatus` | Integer | 新版本最终状态       |

```json
{
  "requestId": "mock-request-id",
  "responseCode": "00000000",
  "responseMessage": "Succeed",
  "data": {"emailCode": "815645091883520000", "version": "V2", "versionStatus": 1}
}
```

后续通过 `getMaxVersion`、Version Detail 和 Version History 验证到的业务结果是：V2 为 Active (`1`)，V1 为 Expired (`2`)。

**失败响应 JSON 示例**

```json
{
  "requestId": "mock-request-id",
  "responseCode": "QA_TESTED_ERROR_CODE",
  "responseMessage": "The target version cannot be added in its current state.",
  "data": null
}
```

**错误码与提示**

| 业务语义码                | 实际 responseCode（后续填写） | responseMessage                 |
| ------------------------- | ----------------------------- | ------------------------------- |
| REQUEST_VALIDATION_FAILED | 待开发/QA 填写                | 请求参数不合法。                |
| TEMPLATE_NOT_FOUND        | 待开发/QA 填写                | Template 不存在或已不可用。     |
| VERSION_STATE_INVALID     | 待开发/QA 填写                | 当前 Version 状态不允许此操作。 |
| PUBLISH_VALIDATION_FAILED | 待开发/QA 填写                | 发布前必须填写 X 个字段。       |
| OPERATION_FAILED          | 待开发/QA 填写                | 操作失败，请稍后重试。          |

**前端处理与错误**

- 本接口只表达同一 `emailCode` 下增加目标内容 Version：`effectiveWay=0` 时目标 Version 立即进入 Active、旧 Active 变 Expired；`effectiveWay=1` 时目标 Version 先进入 Schedule、旧 Active 保持，由现有 Scheduler 到点完成切换。不承担 Copy and Create；独立模板复制使用 `NEW-10`。
- 新版本正文、Published Validation 和状态切换必须在同一事务中完成；当前 Template Metadata 不随版本复制。

### EX-10 Update Version

**接口与场景**

| 项目     | 内容                                                           |
| -------- | -------------------------------------------------------------- |
| Endpoint | `POST /iic-dae-msg/web/msg/template/email/v2/version/update` |
| 页面     | `UI-A-04` Template 创建与编辑                                |
| 场景     | 更新已有 Draft/Schedule version 内容                           |

**请求参数**

| 字段                 | 类型          | 必填 | 说明                            |
| -------------------- | ------------- | ---: | ------------------------------- |
| `emailCode`        | String        |   是 | 模板标识                        |
| `version`          | String        |   是 | 目标 version                    |
| `moduleCode`       | String/null   |   否 | 模块编码                        |
| `scenarioCode`     | String/null   |   否 | 场景编码                        |
| `editMode`         | String/null   |   否 | 编辑器模式                      |
| `title`            | String/null   |   否 | Email Subject；Draft 允许为空   |
| `emailContent`     | String/null   |   否 | AES 加密正文；Draft 允许为空    |
| `emailContentKey`  | String/null   | 条件 | 加密正文需要解密 Key 时传入     |
| `textContent`      | String/null   |   否 | 纯文本正文                      |
| `effectiveWay`     | Integer/null  |   否 | Draft/Schedule 已保存的生效方式 |
| `effectiveFrom`    | DateTime/null |   否 | Draft/Schedule 已保存的生效时间 |
| `effectiveUntil`   | DateTime/null |   否 | Draft/Schedule 已保存的失效时间 |
| `fileKeys`         | String/null   |   否 | 附件 Key，逗号分隔              |
| `thumbnailKey`     | String/null   |   否 | 缩略图 Key                      |
| `isCustomBranding` | String/null   |   否 | `0=No, 1=Yes`                 |

**请求 Mock**

```json
{
  "emailCode": "815645091883520000",
  "version": "V2",
  "moduleCode": "COMMUNICATION",
  "scenarioCode": "TEMPLATE_LIBRARY",
  "title": "Your updated retirement review",
  "effectiveWay": 0,
  "effectiveFrom": null,
  "effectiveUntil": null,
  "editMode": "HTML",
  "emailContent": "MOCK_AES_CONTENT",
  "emailContentKey": "MOCK_AES_KEY",
  "textContent": "Your updated retirement review",
  "fileKeys": "",
  "thumbnailKey": null,
  "isCustomBranding": "0"
}
```

**响应字段与 Mock**

```json
{
  "requestId": "mock-request-id",
  "responseCode": "00000000",
  "responseMessage": "Succeed",
  "data": {"emailCode": "815645091883520000", "version": "V2", "versionStatus": 3}
}
```

**失败响应 JSON 示例**

```json
{
  "requestId": "mock-request-id",
  "responseCode": "QA_TESTED_ERROR_CODE",
  "responseMessage": "The requested version does not exist.",
  "data": null
}
```

**错误码与提示**

| 业务语义码                | 实际 responseCode（后续填写） | responseMessage                         |
| ------------------------- | ----------------------------- | --------------------------------------- |
| REQUEST_VALIDATION_FAILED | 待开发/QA 填写                | 请求参数不合法。                        |
| TEMPLATE_NOT_FOUND        | 待开发/QA 填写                | Template 不存在或已不可用。             |
| VERSION_NOT_FOUND         | 待开发/QA 填写                | 指定 Version 不存在。                   |
| VERSION_STATE_INVALID     | 待开发/QA 填写                | 当前 Version 状态不允许此操作。         |
| VERSION_CONFLICT          | 待开发/QA 填写                | Template Version 已变更，请刷新后重试。 |
| OPERATION_FAILED          | 待开发/QA 填写                | 操作失败，请稍后重试。                  |

**前端处理与错误**

- Version Update 只处理版本内容和时间字段，不修改 Template 当前 Metadata。
- 后端 Update 影响 0 行时返回失败；前端提示刷新，不显示保存成功。
- Schedule 期间保存草稿会把同一 version 更新为 Draft；不创建新 version。

### EX-11 Delete Version

**接口与场景**

| 项目     | 内容                                                                               |
| -------- | ---------------------------------------------------------------------------------- |
| Endpoint | `POST /iic-dae-msg/web/msg/template/email/v2/version/delete`                     |
| 页面     | `UI-A-04` Template 创建与编辑、`UI-A-06` Version History                       |
| 场景     | Cancel 已保存 Working Copy；删除 Draft/Schedule version；Cancel Schedule by Delete |

**请求参数与 Mock**

| 字段          | 类型   | 必填 | 说明                        |
| ------------- | ------ | ---: | --------------------------- |
| `emailCode` | String |   是 | 模板标识                    |
| `version`   | String |   是 | 目标 Draft/Schedule version |

```json
{"emailCode": "815645091883520000", "version": "V2"}
```

**响应字段与 Mock**

```json
{"requestId": "mock-request-id", "responseCode": "00000000", "responseMessage": "Succeed", "data": null}
```

**失败响应 JSON 示例**

```json
{
  "requestId": "mock-request-id",
  "responseCode": "10000121",
  "responseMessage": "Operation failed. The version has been published.",
  "data": null
}
```

**错误码与提示**

| 业务语义码            | 实际 responseCode（后续填写） | responseMessage                                   |
| --------------------- | ----------------------------- | ------------------------------------------------- |
| TEMPLATE_NOT_FOUND    | 待开发/QA 填写                | Template 不存在或已不可用。                       |
| VERSION_NOT_FOUND     | 待开发/QA 填写                | 指定 Version 不存在。                             |
| VERSION_PUBLISHED     | 10000121（已实测）            | Operation failed. The version has been published. |
| VERSION_STATE_INVALID | 待开发/QA 填写                | 当前 Version 状态不允许此操作。                   |
| OPERATION_FAILED      | 待开发/QA 填写                | 操作失败，请稍后重试。                            |

**前端处理与错误**

- 未保存的编辑离开页面时不调用本接口。
- 已保存 Working Copy 的 Cancel 调用本接口并软删除 Draft；未保存编辑的 Cancel 仅由前端丢弃页面状态，不调用后端。
- 删除 Active/Published version 时返回 `responseCode="10000121"`、`responseMessage="Operation failed. The version has been published."`；前端必须按业务码判定失败。
- 成功后回到列表；附件仍保留在 S3，不执行清理。

### EX-12 Get Max Version

**接口与场景**

| 项目     | 内容                                                                                       |
| -------- | ------------------------------------------------------------------------------------------ |
| Endpoint | `GET /iic-dae-msg/web/msg/template/email/v2/version/getMaxVersion?emailCode={emailCode}` |
| 页面     | `UI-A-04` Template 创建与编辑、`UI-A-06` Version History                               |
| 场景     | 获取模板的最大数字版本                                                                     |

**请求参数**

| 位置  | 字段          | 类型   | 必填 |
| ----- | ------------- | ------ | ---: |
| Query | `emailCode` | String |   是 |

**请求 Mock**

```text
GET /iic-dae-msg/web/msg/template/email/v2/version/getMaxVersion?emailCode=815645091883520000
```

**响应字段**

| 字段                   | 类型    | 说明               |
| ---------------------- | ------- | ------------------ |
| `data.emailCode`     | String  | Template 标识      |
| `data.version`       | String  | 最大数字版本       |
| `data.versionStatus` | Integer | 该最大版本当前状态 |

**成功响应 Mock**

```json
{
  "requestId": "mock-request-id",
  "responseCode": "00000000",
  "responseMessage": "Succeed",
  "data": {"emailCode": "815645091883520000", "version": "V2", "versionStatus": 3}
}
```

**失败响应 JSON 示例**

```json
{
  "requestId": "mock-request-id",
  "responseCode": "QA_TESTED_ERROR_CODE",
  "responseMessage": "The template does not exist.",
  "data": null
}
```

**错误码与提示**

| 业务语义码         | 实际 responseCode（后续填写） | responseMessage             |
| ------------------ | ----------------------------- | --------------------------- |
| TEMPLATE_NOT_FOUND | 待开发/QA 填写                | Template 不存在或已不可用。 |
| OPERATION_FAILED   | 待开发/QA 填写                | 操作失败，请稍后重试。      |

**前端处理与错误**

- 后端必须按版本数字比较，不能按 `V10 < V2` 的字符串顺序。
- 不存在 version 时沿用现有空响应/错误行为。

### EX-13 Version Detail

**接口与场景**

| 项目     | 内容                                                           |
| -------- | -------------------------------------------------------------- |
| Endpoint | `POST /iic-dae-msg/web/msg/template/email/v2/version/detail` |
| 页面     | `UI-A-04` Template 创建与编辑、`UI-A-06` Version History   |
| 场景     | 加载明确指定的版本内容                                         |

**请求参数与 Mock**

| 字段          | 类型   | 必填 | 说明                       |
| ------------- | ------ | ---: | -------------------------- |
| `emailCode` | String |   是 | 模板标识                   |
| `version`   | String |   是 | 目标 version；不得自动改选 |

```json
{"emailCode": "815645091883520000", "version": "V1"}
```

**响应字段**

返回指定 version 的现有 Version Detail 字段。Category/Subcategory/Tag 是 Template 当前属性，如页面需要同时展示，应使用模板详情中的当前值，不得标记为该历史 Version 的快照。

**成功响应 Mock**

```json
{
  "requestId": "mock-request-id",
  "responseCode": "00000000",
  "responseMessage": "Succeed",
  "data": {
    "emailCode": "815645091883520000",
    "version": "V1",
    "versionStatus": 1,
    "title": "Your retirement review",
    "emailContent": "MOCK_AES_CONTENT",
    "fileKeys": ""
  }
}
```

**失败响应 JSON 示例**

```json
{
  "requestId": "mock-request-id",
  "responseCode": "QA_TESTED_ERROR_CODE",
  "responseMessage": "The requested version does not exist.",
  "data": null
}
```

**错误码与提示**

| 业务语义码         | 实际 responseCode（后续填写） | responseMessage             |
| ------------------ | ----------------------------- | --------------------------- |
| TEMPLATE_NOT_FOUND | 待开发/QA 填写                | Template 不存在或已不可用。 |
| VERSION_NOT_FOUND  | 待开发/QA 填写                | 指定 Version 不存在。       |
| PERMISSION_DENIED  | 待开发/QA 填写                | 无权限执行此操作。          |

**前端处理与错误**

- version 不存在或已软删除时提示刷新，不回退查询其他 version。
- 本接口只返回指定内容 Version，不返回历史 Template 属性快照。

### EX-14 Version History

**接口与场景**

| 项目     | 内容                                                                 |
| -------- | -------------------------------------------------------------------- |
| Endpoint | `POST /iic-dae-msg/web/msg/template/email/v2/version/list/history` |
| 页面     | `UI-A-06` Version History                                          |
| 场景     | 加载版本历史分页列表                                                 |

**请求参数与 Mock**

| 字段          | 类型    | 必填 | 说明                      |
| ------------- | ------- | ---: | ------------------------- |
| `emailCode` | String  |   是 | 模板标识                  |
| `pageNum`   | Integer |   否 | 当前页码，默认`1`       |
| `pageSize`  | Integer |   否 | 每页数量，默认`20`      |
| `isAsc`     | Boolean |   否 | `true=升序, false=降序` |

```json
{
  "emailCode": "815645091883520000",
  "pageNum": 1,
  "pageSize": 20,
  "isAsc": false
}
```

**响应字段与 Mock**

| 字段                              | 类型     | 说明     |
| --------------------------------- | -------- | -------- |
| `data.pageNo`                   | Integer  | 当前页码 |
| `data.pageSize`                 | Integer  | 每页数量 |
| `data.totalCount`               | Long     | 总记录数 |
| `data.totalPage`                | Integer  | 总页数   |
| `data.dataList[].emailCode`     | String   | 模板标识 |
| `data.dataList[].version`       | String   | 版本号   |
| `data.dataList[].versionStatus` | Integer  | 版本状态 |
| `data.dataList[].updatedBy`     | String   | 更新人   |
| `data.dataList[].updatedDate`   | DateTime | 更新时间 |

```json
{
  "requestId": "mock-request-id",
  "responseCode": "00000000",
  "responseMessage": "Succeed",
  "data": {
    "pageNo": 1,
    "pageSize": 20,
    "totalCount": 2,
    "totalPage": 1,
    "dataList": [
      {"emailCode": "815645091883520000", "version": "V2", "versionStatus": 1, "updatedBy": "content.manager", "updatedDate": "2026-07-16 10:00:00"},
      {"emailCode": "815645091883520000", "version": "V1", "versionStatus": 2, "updatedBy": "content.manager", "updatedDate": "2026-06-01 09:00:00"}
    ]
  }
}
```

**失败响应 JSON 示例**

```json
{
  "requestId": "mock-request-id",
  "responseCode": "QA_TESTED_ERROR_CODE",
  "responseMessage": "The template does not exist.",
  "data": null
}
```

**错误码与提示**

| 业务语义码                | 实际 responseCode（后续填写） | responseMessage             |
| ------------------------- | ----------------------------- | --------------------------- |
| REQUEST_VALIDATION_FAILED | 待开发/QA 填写                | 请求参数不合法。            |
| TEMPLATE_NOT_FOUND        | 待开发/QA 填写                | Template 不存在或已不可用。 |
| PERMISSION_DENIED         | 待开发/QA 填写                | 无权限执行此操作。          |

**前端处理与错误**

- 首次发布不额外创建 V2：同一 V1 从 Draft 变为 Active，并作为 V1 历史记录显示。
- Version History 只展示内容版本历史，不混入 Template 基本信息和 Category/Tag 修改记录。

## 5. 分类管理

### NEW-01 Category Tree

**接口与场景**

| 项目     | 内容                                                                                   |
| -------- | -------------------------------------------------------------------------------------- |
| Endpoint | `GET /iic-dae-msg/web/msg/template/email/v2/category/tree`                           |
| 页面     | UI-A-07 Category 管理列表                                                              |
| 场景     | 加载管理树；加载筛选项；加载模板分类选择；加载迁移目标；Adviser 分类导航与动态模板数量 |

**请求参数与 Mock**

管理端调用无业务参数。Template Library / Adviser 分类导航可传入当前搜索条件；数量只受 `emailName` 和 `tagGroups` 影响，不受 `categoryId` / `subCategoryIds` 选择影响。

```text
GET /iic-dae-msg/web/msg/template/email/v2/category/tree
GET /iic-dae-msg/web/msg/template/email/v2/category/tree?emailName=retirement&tagGroups=...
```

`tagGroups` 的业务结构与 `EX-01` 相同；GET 参数序列化沿用项目现有 Web 约定。

**响应字段**

| 字段                              | 类型     | 说明                                                                                                                         |
| --------------------------------- | -------- | ---------------------------------------------------------------------------------------------------------------------------- |
| `data[].id`                     | String   | 节点 ID；后端 Long 在 JSON 边界序列化为 String                                                                               |
| `data[].categoryName`           | String   | 显示名                                                                                                                       |
| `data[].parentId`               | String   | 一级固定为`"0"`，二级为父 Category ID                                                                                      |
| `data[].sortOrder`              | Integer  | 同级排序                                                                                                                     |
| `data[].publishedTemplateCount` | Integer  | 当前`emailName` 和 `tagGroups` 条件下的 Published Email Template 数量；Category/Subcategory 均按唯一 `email_code` 计数 |
| `data[].children`               | Object[] | 二级节点；无节点返回`[]`                                                                                                   |
| `data[].leaf`                   | Boolean  | 是否叶子节点                                                                                                                 |

**成功响应 Mock**

```json
{
  "requestId": "mock-request-id",
  "responseCode": "00000000",
  "responseMessage": "Succeed",
  "data": [{
      "id": "1001",
      "categoryName": "Client Engagement",
      "parentId": "0",
      "sortOrder": 1,
      "publishedTemplateCount": 12,
      "leaf": false,
      "children": [{
        "id": "1101",
        "categoryName": "Advice Review",
        "parentId": "1001",
        "sortOrder": 1,
        "publishedTemplateCount": 4,
        "leaf": true,
        "children": []
      }]
    }]
}
```

**失败响应 JSON 示例**

```json
{
  "requestId": "mock-request-id",
  "responseCode": "QA_TESTED_ERROR_CODE",
  "responseMessage": "No permission to view categories.",
  "data": null
}
```

**错误码与提示**

| 业务语义码        | 实际 responseCode（后续填写） | responseMessage        |
| ----------------- | ----------------------------- | ---------------------- |
| PERMISSION_DENIED | 待开发/QA 填写                | 无权限执行此操作。     |
| OPERATION_FAILED  | 待开发/QA 填写                | 操作失败，请稍后重试。 |

**前端处理与错误**

- 只返回有效节点；软删除节点不用于新建、编辑、筛选或迁移目标。
- 固定两级；前端不推导或展示第三级。
- Category 层级由后端根据 `parentId` 推导，前端不提交持久化层级字段。
- `id` 是 Category/Subcategory 唯一标识；Contract 不提供或接收 `categoryCode`。
- 数量仅统计当前 Adviser 可见的 Published Email Template；一个 Template 关联多个 Subcategory 时，在同一节点仅计一次。

### NEW-02 Create Category

**接口与场景**

| 项目     | 内容                                                     |
| -------- | -------------------------------------------------------- |
| Endpoint | `POST /iic-dae-msg/web/msg/template/email/v2/category` |
| 页面     | `UI-A-08` Create Category/Subcategory                  |
| 场景     | 创建一级 Category                                        |

**请求参数与 Mock**

| 字段                 | 类型   | 必填 | 说明                                                                  |
| -------------------- | ------ | ---: | --------------------------------------------------------------------- |
| `categoryName`     | String |   是 | 有效节点全局唯一                                                      |
| `parentCategoryId` | String |   是 | 创建一级 Category 固定传`"0"`；批量创建 Subcategory 使用 `NEW-08` |

```json
{
  "categoryName": "Client Engagement",
  "parentCategoryId": "0"
}
```

**响应字段与 Mock**

返回创建后的完整 Category Node。

```json
{
  "requestId": "mock-request-id",
  "responseCode": "00000000",
  "responseMessage": "Succeed",
  "data": {
    "id": "3001",
    "categoryName": "Client Engagement",
    "parentId": "0",
    "sortOrder": 3,
    "leaf": true,
    "children": []
  }
}
```

**失败响应 JSON 示例**

```json
{
  "requestId": "mock-request-id",
  "responseCode": "QA_TESTED_ERROR_CODE",
  "responseMessage": "An active category with this name already exists.",
  "data": null
}
```

**错误码与提示**

| 业务语义码                | 实际 responseCode（后续填写） | responseMessage                        |
| ------------------------- | ----------------------------- | -------------------------------------- |
| REQUEST_VALIDATION_FAILED | 待开发/QA 填写                | 请求参数不合法。                       |
| CATEGORY_NAME_DUPLICATE   | 待开发/QA 填写                | 有效 Category/Subcategory 名称已存在。 |
| CATEGORY_LEVEL_INVALID    | 待开发/QA 填写                | Category 层级或父节点不合法。          |
| OPERATION_FAILED          | 待开发/QA 填写                | 操作失败，请稍后重试。                 |

**前端处理与错误**

- 名称为空时返回 `REQUEST_VALIDATION_FAILED`；与任一有效 Category/Subcategory 重复时返回 `CATEGORY_NAME_DUPLICATE`。页面在名称输入框显示内联提示，不关闭创建弹窗。
- 软删除后允许重新创建同名节点。
- `categoryId` 由数据库生成，前端创建时不传；后续编辑、排序和删除使用返回的 `categoryId`。

### NEW-03 Update Category/Subcategory

**接口与场景**

| 项目     | 内容                                                         |
| -------- | ------------------------------------------------------------ |
| Endpoint | `PUT /iic-dae-msg/web/msg/template/email/v2/category/{id}` |
| 页面     | `UI-A-09` Edit Category/Subcategory                        |
| 场景     | 编辑 Category 或 Subcategory 的 Name                         |

**请求参数与 Mock**

| 位置 | 字段             | 类型   | 必填 | 说明     |
| ---- | ---------------- | ------ | ---: | -------- |
| Path | `id`           | String |   是 | 目标节点 |
| Body | `categoryName` | String |   是 | 新名称   |

```json
{"categoryName": "Client Engagement"}
```

**响应字段与 Mock**

更新成功返回 `data=null`。前端随后重新加载 Category Tree。

```json
{"requestId":"mock-request-id","responseCode":"00000000","responseMessage":"Succeed","data":null}
```

**失败响应 JSON 示例**

```json
{
  "requestId": "mock-request-id",
  "responseCode": "QA_TESTED_ERROR_CODE",
  "responseMessage": "An active category with this name already exists.",
  "data": null
}
```

**错误码与提示**

| 业务语义码                | 实际 responseCode（后续填写） | responseMessage                        |
| ------------------------- | ----------------------------- | -------------------------------------- |
| REQUEST_VALIDATION_FAILED | 待开发/QA 填写                | 请求参数不合法。                       |
| CATEGORY_NOT_FOUND        | 待开发/QA 填写                | Category/Subcategory 不存在或已删除。  |
| CATEGORY_NAME_DUPLICATE   | 待开发/QA 填写                | 有效 Category/Subcategory 名称已存在。 |
| OPERATION_FAILED          | 待开发/QA 填写                | 操作失败，请稍后重试。                 |

**前端处理与错误**

- 本期不支持把已有 Subcategory 移到另一 Category。
- 目标不存在或已删除时返回 `CATEGORY_NOT_FOUND` 并刷新 Tree；名称与有效节点重复时返回 `CATEGORY_NAME_DUPLICATE`，页面保留用户输入。

### NEW-12 Delete Category/Subcategory

**接口与场景**

| 项目     | 内容                                                                                                                                                              |
| -------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Endpoint | POST /iic-dae-msg/web/msg/template/email/v2/category/delete                                                                                                       |
| 页面     | UI-A-10 Category 删除与迁移                                                                                                                                       |
| 场景     | 前端唯一的 Category/Subcategory 删除入口：无有效引用时直接软删除；有 Active/Draft/Schedule 引用时返回影响范围，用户选择迁移目标后再次调用同一接口完成迁移和删除。 |

**请求参数**

| 字段                 | 类型        | 必填 | 说明                                                                                   |
| -------------------- | ----------- | ---: | -------------------------------------------------------------------------------------- |
| sourceCategoryId     | String      |   是 | 待删除的 Category/Subcategory                                                          |
| targetCategoryId     | String/null |   否 | 仅当首次删除返回 reassignRequired=true 后，由用户选择并再次提交；有效目标一级 Category |
| targetSubcategoryIds | String[]    |   否 | 迁移后的完整目标 Subcategory 集合；空数组表示不分配目标 Subcategory                    |

**请求 Mock：首次删除尝试**

```json
{
  "sourceCategoryId": "1001"
}
```

**请求 Mock：确认迁移并删除**

```json
{
  "sourceCategoryId": "1001",
  "targetCategoryId": "2001",
  "targetSubcategoryIds": ["2101"]
}
```

**成功响应**

无有效引用时直接软删除；有引用且提交有效目标时原子迁移后软删除。两种成功场景均返回 data=null。

```json
{"requestId":"mock-request-id","responseCode":"00000000","responseMessage":"Succeed","data":null}
```

**失败响应 JSON 示例**

首次删除发现有效引用，需要选择迁移目标时：

```json
{
  "requestId": "mock-request-id",
  "responseCode": "QA_TESTED_ERROR_CODE",
  "responseMessage": "Category is in use. Select a target Category before deleting.",
  "data": {
    "reassignRequired": true,
    "affectedTemplateCount": 2
  }
}
```

前端接收到 `reassignRequired=true` 时，直接读取 `data.affectedTemplateCount` 弹出提示：“该分类下有 X 个模板，请选择迁移目标。”，并展示目标分类选择下拉框。

**错误码与提示**

| 业务语义码                       | 实际 responseCode（后续填写） | responseMessage                                     |
| -------------------------------- | ----------------------------- | --------------------------------------------------- |
| REQUEST_VALIDATION_FAILED        | 待开发/QA 填写                | 请求参数不合法。                                    |
| CATEGORY_NOT_FOUND               | 待开发/QA 填写                | Category/Subcategory 不存在或已删除。               |
| CATEGORY_IN_USE                  | 待开发/QA 填写                | Category 已被 Active/Draft/Schedule Template 引用。 |
| CATEGORY_TARGET_INVALID          | 待开发/QA 填写                | 目标 Category/Subcategory 不可用。                  |
| INVALID_MIGRATION_TARGET         | 待开发/QA 填写                | 迁移目标不能为当前被删除节点或其子分类。            |
| CATEGORY_CONCURRENT_MODIFICATION | 待开发/QA 填写                | Category 引用已变化，请刷新后重试。                 |
| PERMISSION_DENIED                | 待开发/QA 填写                | 无权限执行此操作。                                  |
| OPERATION_FAILED                 | 待开发/QA 填写                | 操作失败，请稍后重试。                              |

**前端处理与错误**

- 前端删除操作只调用本接口。首次请求不传 targetCategoryId；后端在事务内检查 Active/Draft/Schedule 引用。
- 无上述引用时，后端直接软删除 Category/Subcategory，Expired-only Template 不阻止删除，也不迁移其历史 Metadata。
- 有引用时，后端不删除，返回 CATEGORY_IN_USE 和 data.reassignRequired=true，以及影响统计；前端据此展示迁移目标选择。
- 用户确认目标后，前端调用同一接口并提交 targetCategoryId 和 targetSubcategoryIds。后端必须重新检查真实引用，并原子完成当前 Metadata 迁移、Category 软删除、Category Change History、Delete Audit 和受影响 Template Change History 写入。
- targetCategoryId 不存在、已删除或层级不匹配时返回 CATEGORY_TARGET_INVALID；目标等于源节点或位于待删除子树时返回 INVALID_MIGRATION_TARGET。两次调用之间引用或节点变化时返回 CATEGORY_CONCURRENT_MODIFICATION，前端重新发起首次删除尝试。
- 只要迁移、软删除或任一 History/Audit 写入失败，整笔事务回滚；前端不得循环调用单 Template Metadata API 代替本接口。

### NEW-05 Reorder Category

**接口与场景**

| 项目     | 内容                                                            |
| -------- | --------------------------------------------------------------- |
| Endpoint | `PUT /iic-dae-msg/web/msg/template/email/v2/category/reorder` |
| 页面     | `UI-A-07` Category 管理列表                                   |
| 场景     | 保存 Category 或同一父 Category 下 Subcategory 的前端排序       |

**请求参数与 Mock**

| 字段           | 类型    | 必填 | 说明                        |
| -------------- | ------- | ---: | --------------------------- |
| `categoryId` | String  |   是 | 同级节点 ID                 |
| `sortOrder`  | Integer |   是 | 目标顺序，从 1 开始连续编号 |

```json
[
  {"categoryId": "1001", "sortOrder": 1},
  {"categoryId": "2001", "sortOrder": 2},
  {"categoryId": "3001", "sortOrder": 3}
]
```

**响应字段与 Mock**

```json
{
  "requestId": "mock-request-id",
  "responseCode": "00000000",
  "responseMessage": "Succeed",
  "data": null
}
```

**失败响应 JSON 示例**

```json
{
  "requestId": "mock-request-id",
  "responseCode": "QA_TESTED_ERROR_CODE",
  "responseMessage": "The category order has changed. Refresh and try again.",
  "data": null
}
```

**错误码与提示**

| 业务语义码                | 实际 responseCode（后续填写） | responseMessage                       |
| ------------------------- | ----------------------------- | ------------------------------------- |
| REQUEST_VALIDATION_FAILED | 待开发/QA 填写                | 请求参数不合法。                      |
| CATEGORY_NOT_FOUND        | 待开发/QA 填写                | Category/Subcategory 不存在或已删除。 |
| CATEGORY_LEVEL_INVALID    | 待开发/QA 填写                | Category 层级或父节点不合法。         |
| CATEGORY_ORDER_STALE      | 待开发/QA 填写                | Category 排序已变化，请刷新后重试。   |
| OPERATION_FAILED          | 待开发/QA 填写                | 操作失败，请稍后重试。                |

**前端处理与错误**

- 只提交同一级、同一 Parent 的有效节点。
- 拖拽过程中不调用接口；完成一次 Drop 后提交该 Parent 下全部有效同级节点的完整顺序。
- 后端会锁定并比较完整同级 ID 集合，再把数组位置保存为连续 `sortOrder=1..N`；不接受局部 Patch。
- 若加载后发生新增、删除或并发排序，后端返回排序数据已过期的业务失败。前端必须重新加载 Category Tree，不自动重放旧顺序。
- 保存成功后重新加载 Category Tree；其他失败恢复原顺序或重新加载树，不在前端假设部分成功。

### NEW-08 Batch Create Subcategories

**接口与场景**

| 项目     | 内容                                                                         |
| -------- | ---------------------------------------------------------------------------- |
| Endpoint | `POST /iic-dae-msg/web/msg/template/email/v2/category/batch-subcategories` |
| 页面     | `UI-A-08` Create Category/Subcategory、`UI-A-04` Template 创建与编辑     |
| 场景     | 在有效 Category 下一次创建 1-5 个 Subcategory                                |

**请求参数与 Mock**

| 位置 | 字段              | 类型     | 必填 | 说明              |
| ---- | ----------------- | -------- | ---: | ----------------- |
| Body | `parentId`      | String   |   是 | 有效一级 Category |
| Body | `subcategories` | Object[] |   是 | 1-5 项            |
| Item | `name`          | String   |   是 | 全局有效名称唯一  |

```json
{
  "parentId": "1001",
  "subcategories": [
    {"name": "Advice Review"},
    {"name": "Annual Check-in"}
  ]
}
```

**响应字段与 Mock**

`data[]` 按请求顺序返回创建后的 Category Tree Node。

```json
{
  "requestId": "mock-request-id",
  "responseCode": "00000000",
  "responseMessage": "Succeed",
  "data": [
    {"id": "5000", "categoryName": "Advice Review", "parentId": "1001", "sortOrder": 1, "leaf": true, "children": []},
    {"id": "5001", "categoryName": "Annual Check-in", "parentId": "1001", "sortOrder": 2, "leaf": true, "children": []}
  ]
}
```

**失败响应 JSON 示例**

```json
{
  "requestId": "mock-request-id",
  "responseCode": "QA_TESTED_ERROR_CODE",
  "responseMessage": "2 个子目录校验失败。",
  "data": {
    "fieldErrors": [
      {
        "itemIndex": 1,
        "itemName": "Advice Review",
        "businessCode": "CATEGORY_NAME_DUPLICATE",
        "field": "subcategories[1].name",
        "code": "DUPLICATE",
        "message": "该 Subcategory 名称已存在。"
      },
      {
        "itemIndex": 3,
        "itemName": "",
        "businessCode": "REQUEST_VALIDATION_FAILED",
        "field": "subcategories[3].name",
        "code": "REQUIRED",
        "message": "需要 Subcategory 名称。"
      }
    ],
    "invalidFieldCount": 2
  }
}
```

**错误码与提示**

| 业务语义码                | 实际 responseCode（后续填写） | responseMessage                        |
| ------------------------- | ----------------------------- | -------------------------------------- |
| REQUEST_VALIDATION_FAILED | 待开发/QA 填写                | 请求参数不合法。                       |
| CATEGORY_NOT_FOUND        | 待开发/QA 填写                | Category/Subcategory 不存在或已删除。  |
| CATEGORY_NAME_DUPLICATE   | 待开发/QA 填写                | 有效 Category/Subcategory 名称已存在。 |
| OPERATION_FAILED          | 待开发/QA 填写                | 操作失败，请稍后重试。                 |

**前端处理与错误**

- 后端先校验完整请求，再决定是否写入：数组为空、超过 5 条、Parent 非法、名称为空、批内重名和与有效节点重名均需在同一次响应中返回。每个失败子目录在 data.fieldErrors[] 中占一项，包含 itemIndex、itemName、businessCode、field、code 和 message；itemIndex 从 0 开始，对应原请求数组位置。
- 同名的两个请求项都必须分别返回失败项；多个不同子目录同时失败时也必须全部返回。invalidFieldCount 等于失败子目录数量；Parent 自身非法时使用 field=parentId、itemIndex=null 返回该项。
- 本接口是原子操作：只要 data.fieldErrors[] 非空，本批任何 Subcategory 都不得创建。前端按 itemIndex 标红，修正后必须整批重新提交，不能拆成逐条重试。

### NEW-11 Batch Template Reassignment

**接口与场景**

| 项目     | 内容                                                            |
| -------- | --------------------------------------------------------------- |
| Endpoint | `POST /iic-dae-msg/web/msg/template/email/v2/reassign`        |
| 页面     | `UI-A-11` Template Library 批量重新分类操作                   |
| 场景     | 一次全量替换一个或多个 Template 的当前 Category/Subcategory/Tag |

**请求参数**

| 字段                                  | 类型        | 必填 | 说明                                              |
| ------------------------------------- | ----------- | ---: | ------------------------------------------------- |
| `templates`                         | Object[]    |   是 | 至少一项；整批成功或整批失败                      |
| `templates[].emailCode`             | String      |   是 | Template 标识                                     |
| `templates[].categoryId`            | String/null |   是 | 当前主 Category；Draft 可为空，Published 必须有效 |
| `templates[].subCategoryIds`        | String[]    |   是 | 当前 Subcategory 完整快照                         |
| `templates[].tagGroups`             | Object[]    |   是 | 当前 4 个 Tag Group 完整快照                      |
| `templates[].tagGroups[].groupCode` | String      |   是 | Group 编码                                        |
| `templates[].tagGroups[].tagCodes`  | String[]    |   是 | Tag Code 完整列表；空数组表示清空该组             |

**请求 Mock**

```json
{
  "templates": [
    {
      "emailCode": "815645091883520000",
      "categoryId": "2001",
      "subCategoryIds": ["2101"],
      "tagGroups": [
        {"groupCode": "CONTENT_TYPE", "tagCodes": ["CONTENT_TYPE_EMAIL"]},
        {"groupCode": "TRIGGER", "tagCodes": ["TRIGGER_ANNUAL_REVIEW"]},
        {"groupCode": "LIFECYCLE_STAGE", "tagCodes": ["LIFECYCLE_STAGE_EXISTING_CLIENT"]},
        {"groupCode": "FINANCIAL_NEED", "tagCodes": ["FINANCIAL_NEED_PLAN_RETIREMENT"]}
      ]
    }
  ]
}
```

**响应字段与 Mock**

成功时返回 `data=null`。

```json
{"requestId":"mock-request-id","responseCode":"00000000","responseMessage":"Succeed","data":null}
```

**失败响应 JSON 示例**

```json
{
  "requestId": "mock-request-id",
  "responseCode": "QA_TESTED_ERROR_CODE",
  "responseMessage": "One or more templates do not exist.",
  "data": {
    "fieldErrors": [
      {
        "field": "templates[0].emailCode",
        "code": "NOT_FOUND",
        "message": "Template 不存在。"
      }
    ],
    "invalidFieldCount": 1
  }
}
```

**错误码与提示**

| 业务语义码                 | 实际 responseCode（后续填写） | responseMessage                       |
| -------------------------- | ----------------------------- | ------------------------------------- |
| REQUEST_VALIDATION_FAILED  | 待开发/QA 填写                | 请求参数不合法。                      |
| TEMPLATE_NOT_FOUND         | 待开发/QA 填写                | Template 不存在或已不可用。           |
| CATEGORY_NOT_FOUND         | 待开发/QA 填写                | Category/Subcategory 不存在或已删除。 |
| CATEGORY_LEVEL_INVALID     | 待开发/QA 填写                | Category 层级或父节点不合法。         |
| TAG_VALUE_INVALID          | 待开发/QA 填写                | Tag 选择无效或已失效。                |
| METADATA_VALIDATION_FAILED | 待开发/QA 填写                | Template Metadata 校验失败。          |
| OPERATION_FAILED           | 待开发/QA 填写                | 操作失败，请稍后重试。                |

**前端处理与错误**

- 任一 Template 校验或更新失败时整批回滚。
- 不创建或删除 Version，不改变 `versionStatus/effectiveFrom/effectiveUntil`，也不修改正文和附件。
- 本接口用于用户主动批量重分配，不能替代 NEW-12 的带目标目录迁移并删除分支。

## 6. Tag Taxonomy

### NEW-06 Tag Taxonomy

**接口与场景**

| 项目     | 内容                                                                |
| -------- | ------------------------------------------------------------------- |
| Endpoint | `GET /iic-dae-msg/web/msg/template/email/v2/category/taxonomy`    |
| 页面     | `UI-A-11` Tag Assignment、`UI-A-01` Template Library Tag Filter |
| 场景     | 加载模板标签选择；加载列表标签筛选项                                |

**请求参数与 Mock**

无业务参数。

```text
GET /iic-dae-msg/web/msg/template/email/v2/category/taxonomy
```

**响应字段**

| 字段                               | 类型         | 说明                                                     |
| ---------------------------------- | ------------ | -------------------------------------------------------- |
| `data[].groupCode`               | String       | 固定 Group 编码                                          |
| `data[].groupName`               | String       | Group 显示名                                             |
| `data[].isMandatory`             | Integer      | `1=Publish 必填, 0=可选`                               |
| `data[].maxSelections`           | Integer/null | 组内最大选择数；Trigger 为`5`，`null` 表示当前不限制 |
| `data[].sortOrder`               | Integer      | Group 排序                                               |
| `data[].tagValues[].tagCode`     | String       | 固定 Tag Value 编码                                      |
| `data[].tagValues[].tagName`     | String       | 显示名                                                   |
| `data[].tagValues[].description` | String/null  | Tag Taxonomy 中的可选说明                                |
| `data[].tagValues[].sortOrder`   | Integer      | Value 排序                                               |

**成功响应 Mock**

```json
{
  "requestId": "mock-request-id",
  "responseCode": "00000000",
  "responseMessage": "Succeed",
  "data": [
    {"groupCode": "CONTENT_TYPE", "groupName": "Content Type", "isMandatory": 1, "maxSelections": null, "sortOrder": 1, "tagValues": [{"tagCode": "CONTENT_TYPE_EMAIL", "tagName": "Email", "description": "Standard email communication", "sortOrder": 1}]},
    {"groupCode": "TRIGGER", "groupName": "Trigger Event", "isMandatory": 1, "maxSelections": 5, "sortOrder": 2, "tagValues": [{"tagCode": "TRIGGER_ANNUAL_REVIEW", "tagName": "Annual Review", "description": "Scheduled annual financial review", "sortOrder": 5}]},
    {"groupCode": "LIFECYCLE_STAGE", "groupName": "Lifecycle Stage", "isMandatory": 1, "maxSelections": null, "sortOrder": 3, "tagValues": [{"tagCode": "LIFECYCLE_STAGE_EXISTING_CLIENT", "tagName": "Existing Client", "description": "Current client", "sortOrder": 2}]},
    {"groupCode": "FINANCIAL_NEED", "groupName": "Financial Need", "isMandatory": 1, "maxSelections": null, "sortOrder": 4, "tagValues": [{"tagCode": "FINANCIAL_NEED_PROTECT", "tagName": "Protect", "description": "Insurance and risk protection needs", "sortOrder": 1}]}
  ]
}
```

**失败响应 JSON 示例**

```json
{
  "requestId": "mock-request-id",
  "responseCode": "QA_TESTED_ERROR_CODE",
  "responseMessage": "No permission to view tag taxonomy.",
  "data": null
}
```

**错误码与提示**

| 业务语义码        | 实际 responseCode（后续填写） | responseMessage        |
| ----------------- | ----------------------------- | ---------------------- |
| PERMISSION_DENIED | 待开发/QA 填写                | 无权限执行此操作。     |
| OPERATION_FAILED  | 待开发/QA 填写                | 操作失败，请稍后重试。 |

**前端处理与错误**

- Taxonomy 由固定 DB seed 维护，前端不提供 Tag 管理 CRUD。
- 每个 Group 均可多选；同组筛选 OR，不同组筛选 AND。
- 前端按 `maxSelections` 限制选择数量；Trigger 为 5，`null` 表示当前不限制。
- 4 个 Mandatory Group；前端不把 `isMandatory` 写死在页面代码中。
- 示例只展示代表性 Tag Value；前端必须按接口返回的完整数组动态展示选项。
- Template 当前 Tag 可以暂时不完整，不自动生成 `Unclassified`；Publish 时再根据 `isMandatory=1` 阻止缺失项。Metadata 修改只依赖已存在的 `emailCode`，不属于任何 Version 状态。

## 7. 业务失败响应约定

业务成功和业务失败均返回 HTTP 200。前端先判断 responseCode：00000000 为成功，其他值为业务失败。普通失败只显示 responseMessage；不得向页面返回 SQL、堆栈或内部类名。

现有 v1 已实测的 responseCode=10000121（删除 Active/Published Version）保持不变；其他真实业务码以 QA 环境实测登记为准。前端不得依赖 responseMessage 的固定文本做业务分支。

### 7.1 普通业务失败

除 7.2 列出的结构化错误接口外，所有失败响应都使用以下最小结构：

```json
{
  "requestId": "mock-request-id",
  "responseCode": "QA_TESTED_ERROR_CODE",
  "responseMessage": "The requested operation cannot be completed.",
  "data": null
}
```

页面显示 responseMessage，并按当前页面已有交互保留输入、刷新列表或关闭弹窗；不解析额外错误对象。

### 7.2 需要字段级错误信息的接口

下列接口需要结构化 `data.fieldErrors`，用于定位输入框或批量项。每个 Endpoint 的业务语义码与文案仍以其自身“错误码与提示”表为准。

| Endpoint | 为什么需要结构化错误信息 | data 返回字段 |
| --- | --- | --- |
| EX-05 Save Draft / Create Template | 首次创建需同时校验主信息、Version 内容和 Metadata | fieldErrors、invalidFieldCount |
| EX-06 Update Template Master Fields and Metadata | 一次性校验名称、Category/Subcategory 和 Tag 关系 | fieldErrors、invalidFieldCount |
| EX-16 Publish / Schedule | 发布前需要逐字段标红并显示顶部汇总 | fieldErrors、invalidFieldCount |
| NEW-08 Batch Create Subcategories | 需定位批量数组中全部重复或非法的子目录 | fieldErrors[].itemIndex/itemName/businessCode/field/code/message、invalidFieldCount |
| NEW-11 Batch Template Reassignment | 需定位批量 Template 中失败的具体项目和字段 | fieldErrors、invalidFieldCount |
| NEW-12 Delete Category/Subcategory | 首次删除发现有效引用时，前端需显示影响范围并选择迁移目标 | reassignRequired、impact |

EX-05、EX-06 与 EX-16 的 `data.fieldErrors[]` 使用同一包络；预写校验应一次返回全部可同时发现的错误：

```json
{
  "fieldErrors": [
    {"field": "emailName", "code": "DUPLICATE", "message": "当前 Category 下 Template Title 已存在。"}
  ],
  "invalidFieldCount": 1
}
```

`field` 使用请求 JSON 路径或 `null`；`code` 表示字段级校验（如 `REQUIRED`、`DUPLICATE`、`INVALID`）。`fieldErrors` 非空时不得写库。校验通过后如发生 Version Conflict、状态不允许、对象不存在或事务失败，可返回对应单项业务失败和 `data=null`。NEW-08 使用 `fieldErrors[]` 返回本批全部失败子目录；NEW-11 使用 `fieldErrors[]` 定位 Metadata 或批量项；NEW-12 在 `CATEGORY_IN_USE` 时返回 `reassignRequired` 和 `impact`；其他接口不返回结构化错误 data。

### 7.3 业务语义码与实际 responseCode

每个 Endpoint 的“错误码与提示”表已列出其全部业务失败场景：

- 业务语义码用于需求、开发和测试对齐，例如 CATEGORY_IN_USE、VERSION_CONFLICT；它不是本期响应 data 的字段。
- 实际 responseCode 必须由后端实现与 QA 实测后填入对应表格，不能由文档自行编造。
- 当前仅 VERSION_PUBLISHED 的 responseCode=10000121 已有实测证据；其他行均明确标为“待开发/QA 填写”。
- 前端以 responseCode != 00000000 判断失败并展示 responseMessage；EX-05、EX-06、EX-16、NEW-08、NEW-11 再读取 data.fieldErrors。

## 8. 页面与接口地图

截图只用于定位页面和操作入口，字段与行为以对应 Endpoint 章节为准。

| 页面编号    | 页面/操作                                      | 关联 Endpoint                                                     |
| ----------- | ---------------------------------------------- | ----------------------------------------------------------------- |
| `UI-A-01` | Template Library Published/Search/Filter       | `EX-01`                                                         |
| `UI-A-02` | Draft/Admin Template List                      | `EX-02`                                                         |
| `UI-A-03` | Template Detail/Preview                        | `EX-03`、`EX-04`                                              |
| `UI-A-04` | Template 创建、编辑、Save Draft/Publish        | `EX-05`、`EX-16`、`EX-06`、`EX-10`            |
| `UI-A-05` | Template Delete                                | `EX-08`                                                         |
| `UI-A-06` | Version History / Copy and Create              | `EX-09`、`EX-11`、`EX-12`、`EX-13`、`EX-14`、`NEW-10` |
| `UI-A-07` | Category 管理列表                              | `NEW-01`、`NEW-05`                                            |
| `UI-A-08` | Create Category/Subcategory                    | `NEW-02`、`NEW-08`                                            |
| `UI-A-09` | Edit Category/Subcategory                      | `NEW-03`                                                        |
| `UI-A-10` | Category 删除与迁移                            | `NEW-12`                                                        |
| `UI-A-11` | Tag Assignment、批量 Reassignment | `NEW-06`、`NEW-11`                                |

### UI-A-01 Template Library

![UI-A-01a Template Library 默认页面](api-contract/assets/prd/image19.png)

![UI-A-01b Template Library 搜索筛选](api-contract/assets/prd/image20.png)

### UI-A-02 Draft/Admin Template List

![UI-A-02 Draft/Admin Template List](api-contract/assets/prd/image15.png)

### UI-A-03 Template Detail/Preview

![UI-A-03 Template Detail Preview](api-contract/assets/prd/image18.png)

### UI-A-04 Template 创建与编辑

![UI-A-04 Template 创建与编辑](api-contract/assets/prd/image13.png)

### UI-A-05 Template Delete

![UI-A-05 Delete Template](api-contract/assets/prd/image21.png)

### UI-A-06 Version History

![UI-A-06 Version History](api-contract/assets/prd/image14.png)

### UI-A-07 Category 管理列表

![UI-A-07 Category 管理列表](api-contract/assets/prd/image1.png)

### UI-A-08 Create Category/Subcategory

![UI-A-08 Create Category Subcategory](api-contract/assets/prd/image2.png)

### UI-A-09 Edit Category/Subcategory

![UI-A-09 Edit Category Subcategory](api-contract/assets/prd/image8.png)

### UI-A-10 Category 删除与迁移

![UI-A-10 Category 删除与迁移](api-contract/assets/prd/image12.png)

### UI-A-11 Tag Assignment 与模板元数据

![UI-A-11 Tag Assignment 与模板元数据](api-contract/assets/prd/image17.png)
