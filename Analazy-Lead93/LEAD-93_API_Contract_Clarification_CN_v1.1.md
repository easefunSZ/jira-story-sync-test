# LEAD-93 / LEAD-405 / LEAD-406 Web v2 API Contract

> 状态：最终开发基线
> 日期：2026-07-27
> 需求基线：PRD v2.0（`DAE_PRD_LEAD-93 Template Management_v2.0 - updated July 21st.docx`）、Jira Feature 拆分及 2026-07-21 LEAD-278 Jira/OM Copy and Create 澄清
> 交叉需求参考：`PRD_LEAD-308 Advisor-Template Management_v1.3 -updated July 20th.docx`
> 范围：24 个 Web v2 Endpoint

## 1. 契约总览

本文是 Web 前端、后端和接口测试共同遵循的 API 基线。正文只定义最终对外契约，不记录现状分析、实现差异、内部类名或评审过程。Web 端只调用本文列出的 `/v2` Endpoint；环境网关路由不属于 Endpoint。

### 1.1 公共约定

| 项目          | 契约                                                                                                                                                                                                                 |
| ------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Base Path     | `/iic-dae-msg/web/msg/template/email/v2`                                                                                                                                                                           |
| 响应包络      | requestId/responseCode/responseMessage/data；普通业务失败时 data=null，仅字段定位接口返回 data.fieldErrors                                                                                                           |
| HTTP Status   | 业务成功和业务失败均返回 HTTP 200；网关、协议或服务不可用等非业务异常不在本契约内                                                                                                                                    |
| 成功判断      | `responseCode="00000000"` 为成功；其他值为业务失败。各 Endpoint 的失败码与提示以本文对应错误码表为准                                                                                                               |
| 分页          | 请求使用`pageNum/pageSize`；响应使用 `pageNo/pageSize/totalCount/totalPage/dataList`                                                                                                                             |
| 时间          | `yyyy-MM-dd HH:mm:ss`，按 `Africa/Johannesburg`（UTC+02:00）解释                                                                                                                                                 |
| 标识类型      | `emailCode`、Category ID、Subcategory ID 在所有 JSON 请求与响应中统一使用 String                                                                                                                                   |
| 空值          | 可空字段使用`null`；不使用空字符串代替无值，字段另有说明时除外                                                                                                                                                     |
| 写请求        | 成功返回前完成该命令的全部校验和写入；失败不得产生部分业务结果                                                                                                                                                       |
| 业务失败数据  | 普通失败仅返回 responseCode/responseMessage/data=null；EX-05、EX-06、EX-09、EX-10、NEW-08、NEW-10、NEW-11 返回 data.fieldErrors/invalidFieldCount；NEW-12 在需迁移时返回 data.reassignRequired 与 data.affectedTemplateCount |
| Metadata      | Category、Subcategory 和 Tag 归属于`emailCode` 对应的当前 Template，不属于内容 Version                                                                                                                             |
| Metadata 去重 | EX-01、EX-02、EX-03、EX-04、EX-13 返回的 Subcategory 和 Tag 按业务键唯一：同一`subcategoryId` 或同一 `groupCode + tagCode` 不得重复出现                                                                          |
| 生命周期      | `versionStatus`：`0=Schedule, 1=Active, 2=Expired, 3=Draft`                                                                                                                                                      |

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

### 1.2 Endpoint 清单

#### 1. 邮件模板管理接口 (Template APIs)

| ID         | Method + Complete Endpoint                                       | 主要场景                                        |
| ---------- | ---------------------------------------------------------------- | ----------------------------------------------- |
| `EX-01`  | `POST /iic-dae-msg/web/msg/template/email/v2/queryList`        | Published 列表、搜索和筛选                      |
| `EX-02`  | `POST /iic-dae-msg/web/msg/template/email/v2/templateList`     | Draft/Admin 列表、搜索和筛选                    |
| `EX-03`  | `POST /iic-dae-msg/web/msg/template/email/v2/detail`           | 管理端 Template Detail (含当前 Metadata)        |
| `EX-04`  | `POST /iic-dae-msg/web/msg/template/email/v2/published/detail` | Adviser Published Detail (含当前 Metadata)      |
| `EX-05`  | `POST /iic-dae-msg/web/msg/template/email/v2/add`              | 首次创建 Template：原子创建 config + V1 Version |
| `EX-06`  | `POST /iic-dae-msg/web/msg/template/email/v2/update`           | 更新 Template 主信息与当前 Metadata             |
| `EX-07`  | `POST /iic-dae-msg/web/msg/template/email/v2/changeStatus`     | Deactivate、Reactivate 模板                     |
| `EX-08`  | `POST /iic-dae-msg/web/msg/template/email/v2/delete`           | 删除 Template (4 表同步软删除)                  |
| `EX-15`  | `POST /iic-dae-msg/web/msg/template/email/v2/channelList`      | Channel 渠道选项列表                            |
| `NEW-10` | `POST /iic-dae-msg/web/msg/template/email/v2/copy`             | Copy and Create 复制创建独立 Template           |
| `NEW-11` | `POST /iic-dae-msg/web/msg/template/email/v2/reassign`         | 模板级批量跨分类重分配 (Template Reassignment)  |

#### 2. 版本管理接口 (Version APIs)

| ID        | Method + Complete Endpoint                                           | 主要场景                                                                        |
| --------- | -------------------------------------------------------------------- | ------------------------------------------------------------------------------- |
| `EX-09` | `POST /iic-dae-msg/web/msg/template/email/v2/version/add`          | 新增 V(N>1)：Draft、Active 或 Schedule                                          |
| `EX-10` | `POST /iic-dae-msg/web/msg/template/email/v2/version/update`       | 修改已有 V(N) 内容；受控执行 Draft -> Active/Schedule、Schedule -> Draft/Active |
| `EX-11` | `POST /iic-dae-msg/web/msg/template/email/v2/version/delete`       | 删除特定 Version、Cancel 已保存 Draft / Schedule                                |
| `EX-12` | `GET /iic-dae-msg/web/msg/template/email/v2/version/getMaxVersion` | 查询模板最大版本号                                                              |
| `EX-13` | `POST /iic-dae-msg/web/msg/template/email/v2/version/detail`       | 查询内容版本详情；需要 Metadata 时另取 Template 当前值                          |
| `EX-14` | `POST /iic-dae-msg/web/msg/template/email/v2/version/list/history` | Version History 版本历史列表                                                    |

#### 3. 分类目录与标签 Taxonomy 接口 (Category & Tag Taxonomy APIs)

| ID         | Method + Complete Endpoint                                                   | 主要场景                                   |
| ---------- | ---------------------------------------------------------------------------- | ------------------------------------------ |
| `NEW-01` | `GET /iic-dae-msg/web/msg/template/email/v2/category/tree`                 | Category Tree 分类树查询                   |
| `NEW-02` | `POST /iic-dae-msg/web/msg/template/email/v2/category`                     | 创建 Category 一级/二级分类                |
| `NEW-03` | `POST /iic-dae-msg/web/msg/template/email/v2/category/update`              | 更新 Category 名称/描述/渠道限制           |
| `NEW-12` | `POST /iic-dae-msg/web/msg/template/email/v2/category/delete`              | 删除 Category/Subcategory (两阶段解耦删除) |
| `NEW-05` | `POST /iic-dae-msg/web/msg/template/email/v2/category/reorder`             | 保存 Category 同级拖拽排序                 |
| `NEW-08` | `POST /iic-dae-msg/web/msg/template/email/v2/category/batch-subcategories` | 批量创建 Subcategory (1-5条)               |
| `NEW-06` | `GET /iic-dae-msg/web/msg/template/email/v2/category/taxonomy`             | Tag Taxonomy 标签元数据与可用值列表        |

## 2. 模板查询与详情

### EX-01 Published List

**接口与场景**

| 项目     | 内容                                                                                       |
| -------- | ------------------------------------------------------------------------------------------ |
| Endpoint | `POST /iic-dae-msg/web/msg/template/email/v2/queryList`                                  |
| 页面     | `UI-A-01` Template Library Published/Search/Filter                                       |
| 场景     | 打开 Published 页签；搜索/筛选已发布模板；Adviser 查询可用模板；Adviser 搜索的固定排序场景 |

**请求参数**

| 字段                      | 类型     | 必填 | 说明                                                                   |
| ------------------------- | -------- | ---: | ---------------------------------------------------------------------- |
| `keyWords`              | String   |   否 | v2 全局关键字；匹配模板名称、当前 Active Email Subject、描述、标签名称 |
| `querySort`             | Integer  |   否 | 保留 v1 Adviser 排序字段，默认`0`；仅接受下表枚举值                  |
| `isCampaign`            | Integer  |   是 | 保留 v1 必传字段；本期只允许传`0`，即 Email-only                     |
| `categoryId`            | String   |   否 | 主分类，单选                                                           |
| `subCategoryIds`        | String[] |   否 | 子分类，多选，同一维度 OR                                              |
| `tagGroups`             | Object[] |   否 | 标签筛选组；同组 OR、跨组 AND                                          |
| `tagGroups[].groupCode` | String   | 条件 | 提交`tagGroups` 时必填                                               |
| `tagGroups[].tagCodes`  | String[] | 条件 | 提交`tagGroups` 时必填                                               |
| `pageNum`               | Integer  |   否 | 当前页码，默认`1`                                                    |
| `pageSize`              | Integer  |   否 | 每页数量，默认`20`                                                   |

> **v1 参数迁移：** v1 `emailName` 的模板名称搜索由 v2 `keyWords` 统一替代。v2 不接收 `emailName` 作为兼容别名；`keyWords` 承担模板名称、Email Subject、描述和 Tag 名称的全局搜索。

**请求示例**

```json
{
  "keyWords": "retirement",
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
| `data.dataList[].categoryName`     | String/null | 当前 Template 主分类名称                                                 |
| `data.dataList[].subCategoryIds`   | String[]    | 当前 Template 子分类 ID                                                  |
| `data.dataList[].subCategoryNames` | String[]    | 当前 Template 子分类名称                                                 |
| `data.dataList[].tagMap`           | Object      | `{groupCode: [tagCode]}`；当前 Template 标签，不随 Active version 切换 |
| `data.dataList[].modifiedTime`     | DateTime    | 修改时间                                                                 |

**成功响应示例**

```json
{
  "requestId": "example-request-id",
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
      "categoryName": "Client Engagement",
      "subCategoryIds": ["1101"],
      "subCategoryNames": ["Advice Review"],
      "tagMap": {"CONTENT_TYPE": ["CONTENT_TYPE_EMAIL"]},
      "modifiedTime": "2026-07-16 09:00:00"
    }]
  }
}
```

> [!NOTE]
> `queryList/templateList` 的列表项**不返回** `categoryId`；前端以 `categoryName` 展示，不得依赖该字段做筛选或跳转。需要主分类 ID 时调用 `EX-03` 管理端详情。

**失败响应 JSON 示例（发布前字段校验失败）**

```json
{
  "requestId": "example-request-id",
  "responseCode": "00000006",
  "responseMessage": "Invalid querySort.",
  "data": null
}
```

**错误码与提示**

| 业务语义码                | responseCode                                    | responseMessage    |
| ------------------------- | ----------------------------------------------- | ------------------ |
| REQUEST_VALIDATION_FAILED | `00000006` (`IICResEnum.PARAM_ERROR`)       | 请求参数不合法。   |
| PERMISSION_DENIED         | `10000007` (`IICResEnum.PERMISSION_DENIED`) | 无权限执行此操作。 |

**前端处理与错误**

- Published 页签不显示或提交 Status Filter。
- `keyWords` 由后端同时匹配 `config.email_name`、当前 Active `version.title`、`config.description` 和当前 Template Tag Name；Category/Subcategory Name 不在本期关键词范围。
- `isCampaign` 是 v1 兼容字段且必须传 `0`；后端拒绝其他值，保证本期仍为 Email-only。
- 空结果显示现有 Empty State；分页继续沿用现有页面行为。
- Adviser 的可选排序属于本 `EX-01` 搜索/列表场景：前端提交 `querySort`，后端按白名单对完整筛选结果集排序后分页；不建立 LEAD-308 专属接口。

### EX-02 Draft/Admin List

**接口与场景**

| 项目     | 内容                                                                       |
| -------- | -------------------------------------------------------------------------- |
| Endpoint | `POST /iic-dae-msg/web/msg/template/email/v2/templateList`               |
| 页面     | `UI-A-02` Draft/Admin Template List                                      |
| 场景     | 打开 Content Manager Published 或 Draft 页签；搜索和筛选对应状态分组的模板 |

> **实现归属备注：** 本接口是 Content Manager 获取权限模板列表的链路，权限模板范围由 UMS 服务提供。`templateList` 的 v2 参数扩展、权限范围及对应查询实现必须在 **UMS 代码库**同步修改；消息中心不得另行实现一套绕过 UMS 权限范围的列表逻辑。本文仅定义 Web 端最终请求/响应契约。

**请求参数**

| 字段                      | 类型     | 必填 | 说明                                                                                                                             |
| ------------------------- | -------- | ---: | -------------------------------------------------------------------------------------------------------------------------------- |
| `keyWords`              | String   |   否 | v2 全局关键字；匹配模板名称、结果版本 Email Subject、描述、标签名称                                                              |
| `templateStatus`        | Integer  |   是 | `1=Published`，匹配 `versionStatus in (0,1)`；`0=Draft`，匹配 `versionStatus=3`；不得传原始 `versionStatus` 或 `tab` |
| `channelList`           | String[] |   否 | 保留 UMS 现有 Channel 筛选                                                                                                       |
| `emailStatusList`       | String[] |   否 | 保留 UMS 现有启用/停用筛选                                                                                                       |
| `sortField`             | String   |   否 | 保留 UMS 现有排序字段；由 UMS 服务白名单校验，不接受客户端 SQL 片段                                                              |
| `isAsc`                 | Boolean  |   否 | 保留 UMS 现有升降序语义                                                                                                          |
| `categoryId`            | String   |   否 | 主分类                                                                                                                           |
| `subCategoryIds`        | String[] |   否 | 子分类多选，同一维度 OR                                                                                                          |
| `tagGroups`             | Object[] |   否 | 标签筛选组；同组 OR、跨组 AND                                                                                                    |
| `tagGroups[].groupCode` | String   | 条件 | 提交`tagGroups` 时必填                                                                                                         |
| `tagGroups[].tagCodes`  | String[] | 条件 | 提交`tagGroups` 时必填                                                                                                         |
| `pageNum`               | Integer  |   否 | 当前页码，默认`1`                                                                                                              |
| `pageSize`              | Integer  |   否 | 每页数量，默认`20`                                                                                                             |

**请求示例**

```json
{
  "keyWords": "retirement",
  "templateStatus": 0,
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

**成功响应示例**

```json
{
  "requestId": "example-request-id",
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
  "requestId": "example-request-id",
  "responseCode": "10000007",
  "responseMessage": "No permission to view the template list.",
  "data": null
}
```

**错误码与提示**

| 业务语义码                | responseCode                                    | responseMessage    |
| ------------------------- | ----------------------------------------------- | ------------------ |
| REQUEST_VALIDATION_FAILED | `00000006` (`IICResEnum.PARAM_ERROR`)       | 请求参数不合法。   |
| PERMISSION_DENIED         | `10000007` (`IICResEnum.PERMISSION_DENIED`) | 无权限执行此操作。 |

**前端处理与错误**

- `templateStatus` 是必传数字分组字段：`1` 查询 Schedule/Active（`versionStatus in (0,1)`），`0` 只查询 Draft（`versionStatus=3`）；不接收 `tab` 或原始 Version Status 值。
- `emailStatusList` 继续独立筛选 Template 启停状态，不改变 `templateStatus` 的 Version 状态分组语义。
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

**请求示例**

```json
{"emailCode": "926734518203400192", "version": "V1"}
```

**响应字段**

| 字段                          | 类型          | 说明                                                                                                 |
| ----------------------------- | ------------- | ---------------------------------------------------------------------------------------------------- |
| `data.emailCode`            | String        | 模板标识                                                                                             |
| `data.emailName`            | String        | Template Title                                                                                       |
| `data.description`          | String/null   | Template Description                                                                                 |
| `data.version`              | String        | 返回内容所属版本                                                                                     |
| `data.versionStatus`        | Integer       | Version 状态                                                                                         |
| `data.emailStatus`          | String        | Template 启用状态                                                                                    |
| `data.title`                | String/null   | Email Subject                                                                                        |
| `data.emailContent`         | String        | 加密正文                                                                                             |
| `data.emailContentKey`      | String/null   | 正文解密 Key                                                                                         |
| `data.textContent`          | String/null   | 纯文本正文                                                                                           |
| `data.fileKeys`             | String/null   | 附件 Key，逗号分隔                                                                                   |
| `data.fileInfos`            | Object[]      | 附件信息                                                                                             |
| `data.fileInfos[].fileKey`  | String        | 附件 Key                                                                                             |
| `data.fileInfos[].fileName` | String        | 附件名称                                                                                             |
| `data.fileInfos[].fileType` | String        | 附件类型                                                                                             |
| `data.fileInfos[].size`     | Long          | 附件大小，单位 Byte                                                                                  |
| `data.fileInfos[].viewUrl`  | String/null   | 现有附件访问地址                                                                                     |
| `data.isCustomBranding`     | String        | `0=No, 1=Yes`                                                                                      |
| `data.effectiveFrom`        | DateTime/null | 生效时间                                                                                             |
| `data.effectiveUntil`       | DateTime/null | 失效时间                                                                                             |
| `data.categoryId`           | String/null   | 当前 Template 主 Category ID                                                                         |
| `data.categoryName`         | String/null   | 当前 Template 主 Category 名称                                                                       |
| `data.subCategoryIds`       | String[]      | 当前 Template Subcategory ID                                                                         |
| `data.subCategoryNames`     | String[]      | 当前 Template Subcategory 名称                                                                       |
| `data.tagMap`               | Object        | `{groupCode: [tagCode]}`；请求不同 version 时值相同                                                |
| `data.copyFromEmailCode`    | String/null   | 仅 Content Manager 管理端返回；Copy Template B 时为来源 A 的`emailCode`，普通 Template 为 `null` |

**成功响应示例**

```json
{
  "requestId": "example-request-id",
  "responseCode": "00000000",
  "responseMessage": "Succeed",
  "data": {
    "emailCode": "926734518203400192",
    "emailName": "Retirement review invitation (Copy)",
    "description": "",
    "version": "V1",
    "versionStatus": 3,
    "emailStatus": "0",
    "title": "Your retirement review",
    "emailContent": "EXAMPLE_AES_CONTENT",
    "emailContentKey": "EXAMPLE_AES_KEY",
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
    "tagMap": {"CONTENT_TYPE": ["CONTENT_TYPE_EMAIL"]},
    "copyFromEmailCode": "815645091883520000"
  }
}
```

**失败响应 JSON 示例**

```json
{
  "requestId": "example-request-id",
  "responseCode": "10000110",
  "responseMessage": "The requested version does not exist.",
  "data": null
}
```

**错误码与提示**

| 业务语义码         | responseCode                                             | responseMessage             |
| ------------------ | -------------------------------------------------------- | --------------------------- |
| TEMPLATE_NOT_FOUND | `10000108` (`MsgResEnum.MSG_CODE_DOES_NOT_EXIST`)    | Template 不存在或已不可用。 |
| VERSION_NOT_FOUND  | `10000110` (`MsgResEnum.MSG_VERSION_DOES_NOT_EXIST`) | 指定 Version 不存在。       |
| PERMISSION_DENIED  | `10000007` (`IICResEnum.PERMISSION_DENIED`)          | 无权限执行此操作。          |

**前端处理与错误**

- 编辑 Draft/Schedule/指定历史版本时必须显式传 `version`，不能依赖自动选版。
- 目标 version 不存在或已软删除时提示刷新，不尝试改查其他 version。
- Preview 只展示正文和 Metadata，不展示附件，也不新增 Preview API。
- Copy Template B 重新进入编辑页时，前端读取 `copyFromEmailCode`，在 Publish 前展示“Template B 发布不会自动停用来源 Template A”的非阻断提醒；普通 Template 该字段为 `null`，不展示提醒。

### EX-04 Adviser Published Detail

**接口与场景**

| 项目     | 内容                                                             |
| -------- | ---------------------------------------------------------------- |
| Endpoint | `POST /iic-dae-msg/web/msg/template/email/v2/published/detail` |
| 页面     | `UI-A-03` Adviser Published Detail                             |
| 场景     | Adviser 打开可用模板详情                                         |

**请求参数与示例**

| 字段          | 类型   | 必填 | 说明         |
| ------------- | ------ | ---: | ------------ |
| `emailCode` | String |   是 | 模板业务标识 |

```json
{"emailCode": "815645091883520000"}
```

**响应字段**

内容字段与 `EX-03` 相同，但后端强制返回 Adviser 可访问的当前 Active version，不允许前端指定 Draft/Schedule；不返回内部字段 `copyFromEmailCode`。

**成功响应示例**

```json
{
  "requestId": "example-request-id",
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
    "emailContent": "EXAMPLE_AES_CONTENT",
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
  "requestId": "example-request-id",
  "responseCode": "10000108",
  "responseMessage": "The published template is unavailable.",
  "data": null
}
```

**错误码与提示**

| 业务语义码         | responseCode                                          | responseMessage             |
| ------------------ | ----------------------------------------------------- | --------------------------- |
| TEMPLATE_NOT_FOUND | `10000108` (`MsgResEnum.MSG_CODE_DOES_NOT_EXIST`) | Template 不存在或已不可用。 |
| PERMISSION_DENIED  | `10000007` (`IICResEnum.PERMISSION_DENIED`)       | 无权限执行此操作。          |

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

**请求参数与示例**

无业务参数。

```json
{}
```

**响应字段与示例**

| 字段                   | 类型   | 说明         |
| ---------------------- | ------ | ------------ |
| `data[].channelCode` | String | Channel 编码 |
| `data[].channelName` | String | 显示名称     |

```json
{
  "requestId": "example-request-id",
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
  "requestId": "example-request-id",
  "responseCode": "00000001",
  "responseMessage": "No permission to load channels.",
  "data": null
}
```

**错误码与提示**

| 业务语义码        | responseCode                                    | responseMessage        |
| ----------------- | ----------------------------------------------- | ---------------------- |
| PERMISSION_DENIED | `10000007` (`IICResEnum.PERMISSION_DENIED`) | 无权限执行此操作。     |
| OPERATION_FAILED  | `00000001` (`IICResEnum.FAILED`)            | 操作失败，请稍后重试。 |

**前端处理与错误**

- 沿用现有缓存、空状态和错误提示，不为 LEAD-93 新增特殊处理。

## 3. 模板保存与生命周期

### EX-05 Create Template and V1 Version

**接口与场景**

| 项目     | 内容                                                                                                              |
| -------- | ----------------------------------------------------------------------------------------------------------------- |
| Endpoint | `POST /iic-dae-msg/web/msg/template/email/v2/add`                                                               |
| 页面     | `UI-A-04` Template 创建与编辑                                                                                   |
| 场景     | 首次创建 Template；原子写 config、V1 Version 与当前 Metadata。`isDraft` 决定 V1 保存为 Draft 或进入首次发布路径 |

**聚合边界**

`/v2/add` 是首次创建的外观聚合入口：当 `emailCode` 为空时，一个请求同时提交 Template 主信息、V1 Version 内容及当前 Category/Subcategory/Tag 快照。后端在一个 `@Transactional` 事务中生成业务标识、写入 config 和 V1 Version、写入 Metadata 关系与 `CREATE` 修改历史。`isDraft` 决定 V1 以 Draft 保存还是走首次发布路径；任一步校验或写入失败均回滚，不得留下只创建 config/version、但未处理本次 Metadata 的孤儿记录。

> [!NOTE]
> **关键路由分工（与 v1 生命周期逻辑一致）**：
>
> - `EX-05` (`POST /v2/add`)：仅用于 **首次创建 Template（emailCode 为空）**，原子创建 config 与 V1 Version。
> - `EX-09` (`POST /v2/version/add`)：用于按 v1 规则新增目标 Version。最大 Version 为 Active 或 Expired 时，`isDraft="1"` 新增 V(N+1) Draft；`isDraft="2"` 新增下一个 Version 并发布或预约。最大 Version 为 Draft/Schedule 时，常规新增请求被拒绝。已废弃的 `/v2/publish` 不再使用。
> - `EX-10` (`POST /v2/version/update`)：修改指定已有 Draft/Schedule V(N) 的内容或状态。`isDraft="1"` 保存 Draft 或取消预约；`isDraft="2"` 按 `effectiveWay` 立即发布或预约发布。不创建 Version，也不修改 Template 当前 Metadata；`versionStatus` 不是操作指令。**Active 不能经本接口原地转为 Draft；需保留 Active，并通过 EX-09 新建 V(N+1) Draft。**

**场景参数**

| 场景                | 关键参数                                                                       | 结果                                                                    |
| ------------------- | ------------------------------------------------------------------------------ | ----------------------------------------------------------------------- |
| 首次创建为 Draft    | `emailCode` 不传，`isDraft="1"`，提交完整 Metadata 快照                    | 单事务生成`emailCode`，Insert config、V1 Draft、关系和 CREATE History |
| 首次创建并发布/预约 | `emailCode` 不传，`isDraft="2"`，按 `effectiveWay` 传时间和完整 Metadata | 单事务生成 config/V1；V1 进入 Active 或 Schedule                        |

**请求参数**

| 字段                      | 类型          | 必填 | 说明                                                                                  |
| ------------------------- | ------------- | ---: | ------------------------------------------------------------------------------------- |
| `emailCode`             | String        |   否 | 首次创建不得传；后端生成并返回                                                        |
| `version`               | String        |   否 | 前端不传；首次创建固定为 V1                                                           |
| `emailName`             | String        |   是 | Template Title；非空、最长 120 字符并执行字符白名单校验                               |
| `description`           | String/null   |   否 | Template Description                                                                  |
| `title`                 | String/null   |   否 | Email Subject；Draft 可为空                                                           |
| `emailContent`          | String        |   是 | AES 加密正文                                                                          |
| `emailContentKey`       | String/null   |   否 | AES Key                                                                               |
| `textContent`           | String/null   |   否 | 纯文本正文                                                                            |
| `fileKeys`              | String/null   |   否 | 附件 Key，逗号分隔                                                                    |
| `isDraft`               | String        |   是 | 与 v1 一致：`"1"` 创建 V1 Draft；`"2"` 创建 V1 后进入发布路径                     |
| `effectiveWay`          | Integer/null  | 条件 | `isDraft="2"` 时必填：`0=立即发布, 1=预约发布`；Draft 可暂存时间但不自动 Schedule |
| `effectiveFrom`         | DateTime/null | 条件 | `isDraft="2" && effectiveWay=1` 时必填；按南非业务时区解释                          |
| `effectiveUntil`        | DateTime/null |   否 | Draft 可暂存；立即 Active 时由现有实现写当前时间                                      |
| `moduleCode`            | String/null   |   否 | 模块编码                                                                              |
| `moduleCodeName`        | String/null   |   否 | 模块名称                                                                              |
| `scenarioCode`          | String/null   |   否 | 场景编码                                                                              |
| `editMode`              | String/null   |   否 | 编辑器模式                                                                            |
| `thumbnailKey`          | String/null   |   否 | 缩略图 Key                                                                            |
| `channelMap`            | Object/null   |   否 | Channel Code 与名称映射                                                               |
| `isCustomBranding`      | String        |   是 | `0/1`                                                                               |
| `categoryId`            | String/null   | 条件 | **仅首次创建时必传字段**；当前主 Category，`null` 表示 Draft 暂未选择         |
| `subCategoryIds`        | String[]      | 条件 | **仅首次创建时必传字段**；完整快照，空数组表示暂未选择                          |
| `tagGroups`             | Object[]      | 条件 | **仅首次创建时必传字段**；完整 4 组快照，组内空数组表示暂未选择                 |
| `tagGroups[].groupCode` | String        | 条件 | 提交`tagGroups` 时必填                                                              |
| `tagGroups[].tagCodes`  | String[]      | 条件 | 提交`tagGroups` 时必填；Trigger 去重后最多 5 个                                     |

当 `emailCode` 已存在时，本接口必须拒绝请求；已有 Template 新增 V(N>1) 走 EX-09，主信息/Metadata 更新走 EX-06，已有 Version 内容或受控状态更新走 EX-10。

**请求示例：首次创建并 Save Draft**

```json
{
  "moduleCode": "COMMUNICATION",
  "moduleCodeName": "Communications",
  "scenarioCode": "TEMPLATE_LIBRARY",
  "emailName": "Retirement review invitation",
  "description": "",
  "title": "Your retirement review",
  "editMode": "HTML",
  "emailContent": "EXAMPLE_AES_CONTENT",
  "emailContentKey": "EXAMPLE_AES_KEY",
  "textContent": "Your retirement review",
  "fileKeys": "",
  "isDraft": "1",
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

**响应字段**

| 字段                       | 类型        | 说明                                                                    |
| -------------------------- | ----------- | ----------------------------------------------------------------------- |
| `data.emailCode`         | String      | 首次保存时返回新生成的业务 ID                                           |
| `data.version`           | String      | 实际保存的 version                                                      |
| `data.copyFromEmailCode` | String/null | 发布命令统一返回的 Copy 来源；EX-05 仅创建普通 Template，固定为`null` |

**成功响应示例**

```json
{
  "requestId": "example-request-id",
  "responseCode": "00000000",
  "responseMessage": "Succeed",
  "data": {"emailCode": "815645091883520000", "version": "V1", "copyFromEmailCode": null}
}
```

**首次创建校验与字段错误**

EX-05 在生成 `emailCode` 之前完成请求结构、名称、Version 内容、Metadata、附件和首次发布条件校验。所有可同时定位的问题必须一次返回；不得先创建 config/V1 再以普通错误要求前端补录。

| 校验字段/范围                               | `isDraft="1"` 首次 Draft                           | `isDraft="2"` 首次发布/预约                                                         | `fieldErrors[].field` 示例                        |
| ------------------------------------------- | ---------------------------------------------------- | ------------------------------------------------------------------------------------- | --------------------------------------------------- |
| `emailName`                               | 非空、最长 120、字符白名单、名称冲突                 | 同左                                                                                  | `emailName`                                       |
| `emailContent`、加密 Key、附件            | 校验请求结构、附件格式/大小及引用有效性              | 同左                                                                                  | `emailContent`、`emailContentKey`、`fileKeys` |
| `title`、`description`                  | 可暂不完整                                           | 按 Publish 完整性规则必填                                                             | `title`、`description`                          |
| `isDraft`、`effectiveWay/effectiveFrom` | `isDraft` 必须为 `"1"`；时间可暂存但不改变状态   | `isDraft` 必须为 `"2"`；`effectiveWay` 必填；预约必须提供未来 `effectiveFrom` | `isDraft`、`effectiveWay`、`effectiveFrom`    |
| Category / Subcategory                      | 可为空；提供时必须有效、层级正确且归属匹配           | 主 Category、至少一个 Subcategory 必填且归属匹配                                      | `categoryId`、`subCategoryIds[0]`               |
| Tag Groups                                  | 可为空；提供时 Tag Value 必须有效；Trigger 最多 5 个 | 4 个 Group 各至少一个有效值；Trigger 最多 5 个                                        | `tagGroups[TRIGGER].tagCodes`                     |

**失败响应 JSON 示例**

```json
{
  "requestId": "example-request-id",
  "responseCode": "00000006",
  "responseMessage": "Template creation validation failed.",
  "data": {
    "fieldErrors": [
      {"field": "emailName", "code": "DUPLICATE", "message": "当前 Category 下 Template Title 已存在。"},
      {"field": "effectiveFrom", "code": "FUTURE_TIME_REQUIRED", "message": "预约发布必须选择晚于当前时间的生效时间。"},
      {"field": "subCategoryIds[0]", "code": "INVALID_SUBCATEGORY_BELONGING", "message": "Subcategory 必须属于当前 Category。"},
      {"field": "tagGroups[TRIGGER].tagCodes", "code": "MAX_SIZE", "message": "Trigger 最多选择 5 个。"}
    ],
    "invalidFieldCount": 4
  }
}
```

**错误码与提示**

| 业务语义码                 | responseCode                                                      | responseMessage                                             |
| -------------------------- | ----------------------------------------------------------------- | ----------------------------------------------------------- |
| REQUEST_VALIDATION_FAILED  | `00000006` (`IICResEnum.PARAM_ERROR`)                         | 请求参数不合法。                                            |
| TEMPLATE_NAME_DUPLICATE    | `10000107` (`MsgResEnum.MSG_NAME_ALREADY_EXISTS`)             | 当前 Category 下 Template Title 已存在。                    |
| CATEGORY_NOT_FOUND         | `90000021` (`ExceptionCodeEnum.CATEGORY_NOT_AVAILABLE`)       | Category/Subcategory 不存在或已删除。                       |
| CATEGORY_LEVEL_INVALID     | `00000006` (`IICResEnum.PARAM_ERROR`)                         | Category 层级或父节点不合法。                               |
| TAG_VALUE_INVALID          | `00000006`；`fieldErrors[].code=TAG_VALUE_INVALID`            | Tag 选择无效、已软删除或不属于提交 Group。                  |
| METADATA_VALIDATION_FAILED | `00000006`；详见 `fieldErrors[]`                              | Template Metadata 校验失败。                                |
| PUBLISH_VALIDATION_FAILED  | `00000006` (`IICResEnum.PARAM_ERROR`)                         | 发布前必须填写 X 个字段；详细字段见`data.fieldErrors[]`。 |
| ATTACHMENT_INVALID         | 按具体规则：`90000009/10/11` (`ExceptionCodeEnum`)            | 附件不存在、格式不支持或超过大小限制。                      |
| VERSION_STATE_INVALID      | `00000006` (`IICResEnum.PARAM_ERROR`)                         | 当前 Version 状态不允许此操作。                             |
| VERSION_CONFLICT           | `10000120` (`MsgResEnum.EMAIL_VERSION_EXIST_OPERATION_ERROR`) | Template Version 已变更，请刷新后重试。                     |
| OPERATION_FAILED           | `00000001` (`IICResEnum.FAILED`)                              | 操作失败，请稍后重试。                                      |

**前端处理与错误**

- 首次创建必须在同一个 EX-05 请求中提交 Metadata 完整快照；前端不得先调用 EX-05 再调用独立 Metadata 接口。
- 后端按 `@Transactional` 执行：生成 `emailCode` -> Insert config -> Insert V1 -> 写 `category_id`、Subcategory/Tag relations -> 写 `CREATE` Change History。`isDraft="1"` 时 V1 为 Draft；`isDraft="2"` 时按 `effectiveWay` 进入首次 Active 或 Schedule。任何字段校验、唯一性、taxonomy 归属、relation 或 history 写入失败都整体回滚。
- 所有可同时发现的创建校验错误通过 `data.fieldErrors[]` 返回；`invalidFieldCount` 等于数组长度。`isDraft="2"` 的首次发布失败同样返回全部 Publish 错误。失败时前端保留编辑内容，不将 `emailCode` 写入本地状态，后端不生成任何 config、V1、Metadata relation 或日志记录。
- 本接口不接受已有 `emailCode` 的更新、发布、预约或 Cancel Schedule。首次创建后，已有 Template 新增 V(N+1) 使用 EX-09；已有 V(N) 的内容编辑、发布、预约和 Cancel Schedule 使用 EX-10。
- `isDraft="2"` 的首次发布/预约成功也返回 `copyFromEmailCode`。EX-05 不承担 Copy 创建，因此该字段固定为 `null`；前端不得据此推断或建立 A/B 关系。
- 已有 Draft 或 Schedule 时，前端不得创建另一 Draft；版本生命周期命令必须提交目标版本的真实 `version`。
- 附件可选；单个最大 10 MB；前端沿用现有格式校验并排除多媒体、音频和视频。

### EX-06 Update Template Master Fields and Metadata

**接口与场景**

| 项目     | 内容                                                                                            |
| -------- | ----------------------------------------------------------------------------------------------- |
| Endpoint | `POST /iic-dae-msg/web/msg/template/email/v2/update`                                          |
| 页面     | `UI-A-04` Template 编辑；`UI-A-11` 单个 Template 当前属性编辑                               |
| 场景     | 一次性保存已有 Template 的名称、描述、当前 Category/Subcategory/Tag；单个 Template Reassignment |

**聚合边界**

EX-06 是已有 Template 的主信息与 Metadata 外观聚合接口，不再暴露独立 Metadata Endpoint。它只更新 Template 主表和当前关系表，并写一条 Template Change History 快照；不创建或更新内容 Version，不改变 `versionStatus/effectiveFrom/effectiveUntil`，也不触发发布、预约或版本状态机切换。

**请求参数**

| 字段                      | 类型        | 必填 | 说明                                                                |
| ------------------------- | ----------- | ---: | ------------------------------------------------------------------- |
| `emailCode`             | String      |   是 | Template 标识                                                       |
| `emailName`             | String      |   是 | 当前 Template Name                                                  |
| `description`           | String/null |   否 | 当前 Description                                                    |
| `channelMap`            | Object/null |   否 | 沿用 v1 `TemplateEmailUpdateBO` 的渠道 Map；键为 Channel Code，值为 Channel Name |
| `categoryId`            | String/null |   是 | 当前主 Category；`null` 表示 Draft 暂未选择                       |
| `subCategoryIds`        | String[]    |   是 | 当前 Subcategory 完整快照；空数组表示清空                           |
| `tagGroups`             | Object[]    |   是 | 当前 4 个 Tag Group 完整快照；每组都必须出现                        |
| `tagGroups[].groupCode` | String      |   是 | 固定 Group 编码                                                     |
| `tagGroups[].tagCodes`  | String[]    |   是 | Group 内完整 Tag Code 列表；空数组表示清空；Trigger 去重后最多 5 个 |

**请求示例**

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

**响应字段与示例**

成功时返回命令型响应，`data=null`。前端以已提交的完整快照更新页面本地状态；需要重新读取服务端规范值时调用 EX-03 Detail，不依赖 EX-06 响应体。

```json
{
  "requestId": "example-request-id",
  "responseCode": "00000000",
  "responseMessage": "Succeed",
  "data": null
}
```

**失败响应 JSON 示例**

```json
{
  "requestId": "example-request-id",
  "responseCode": "00000006",
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

| 业务语义码                    | responseCode                                                       | responseMessage                            |
| ----------------------------- | ------------------------------------------------------------------ | ------------------------------------------ |
| REQUEST_VALIDATION_FAILED     | `00000006` (`IICResEnum.PARAM_ERROR`)                          | 请求参数不合法。                           |
| TEMPLATE_NAME_DUPLICATE       | `10000107` (`MsgResEnum.MSG_NAME_ALREADY_EXISTS`)              | 当前 Category 下 Template Title 已存在。   |
| TEMPLATE_NOT_FOUND            | `10000108` (`MsgResEnum.MSG_CODE_DOES_NOT_EXIST`)              | Template 不存在或已不可用。                |
| CATEGORY_NOT_FOUND            | `90000021` (`ExceptionCodeEnum.CATEGORY_NOT_AVAILABLE`)        | Category/Subcategory 不存在或已删除。      |
| INVALID_SUBCATEGORY_BELONGING | `90000029` (`ExceptionCodeEnum.INVALID_SUBCATEGORY_BELONGING`) | 选定的 Subcategory 不属于当前主 Category。 |
| CATEGORY_LEVEL_INVALID        | `00000006` (`IICResEnum.PARAM_ERROR`)                          | Category 层级或父节点不合法。              |
| TAG_VALUE_INVALID             | `00000006`；`fieldErrors[].code=TAG_VALUE_INVALID`             | Tag 选择无效、已软删除或不属于提交 Group。 |
| METADATA_VALIDATION_FAILED    | `00000006`；详见 `fieldErrors[]`                               | Template Metadata 校验失败。               |
| OPERATION_FAILED              | `00000001` (`IICResEnum.FAILED`)                               | 操作失败，请稍后重试。                     |

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

**请求参数与示例**

| 字段            | 类型    | 必填 | 说明                     |
| --------------- | ------- | ---: | ------------------------ |
| `emailCode`   | String  |   是 | 模板标识                 |
| `emailStatus` | Integer |   是 | `0=Inactive, 1=Active` |

```json
{"emailCode": "815645091883520000", "emailStatus": 0}
```

**响应字段与示例**

```json
{"requestId": "example-request-id", "responseCode": "00000000", "responseMessage": "Succeed", "data": null}
```

**失败响应 JSON 示例**

```json
{
  "requestId": "example-request-id",
  "responseCode": "10000108",
  "responseMessage": "The template does not exist.",
  "data": null
}
```

**错误码与提示**

| 业务语义码                | responseCode                                          | responseMessage             |
| ------------------------- | ----------------------------------------------------- | --------------------------- |
| REQUEST_VALIDATION_FAILED | `00000006` (`IICResEnum.PARAM_ERROR`)             | 请求参数不合法。            |
| TEMPLATE_NOT_FOUND        | `10000108` (`MsgResEnum.MSG_CODE_DOES_NOT_EXIST`) | Template 不存在或已不可用。 |
| OPERATION_FAILED          | `00000001` (`IICResEnum.FAILED`)                  | 操作失败，请稍后重试。      |

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

**请求参数与示例**

| 字段          | 类型   | 必填 | 说明     |
| ------------- | ------ | ---: | -------- |
| `emailCode` | String |   是 | 模板标识 |

```json
{"emailCode": "815645091883520000"}
```

**响应字段与示例**

```json
{"requestId": "example-request-id", "responseCode": "00000000", "responseMessage": "Succeed", "data": null}
```

**失败响应 JSON 示例**

```json
{
  "requestId": "example-request-id",
  "responseCode": "10000108",
  "responseMessage": "The template does not exist.",
  "data": null
}
```

**错误码与提示**

| 业务语义码         | responseCode                                          | responseMessage             |
| ------------------ | ----------------------------------------------------- | --------------------------- |
| TEMPLATE_NOT_FOUND | `10000108` (`MsgResEnum.MSG_CODE_DOES_NOT_EXIST`) | Template 不存在或已不可用。 |
| OPERATION_FAILED   | `00000001` (`IICResEnum.FAILED`)                  | 操作失败，请稍后重试。      |

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
4. 成功后使用返回的 `emailCode` 和 `version="V1"` 进入普通 Draft 编辑流程；后续保存统一使用 `EX-10`。
5. B 后续点击 Publish 时显示来源 Template 停用提醒。该提醒仅使用 Copy 后当前编辑会话保留的来源 Template A 标识；确认继续后仍调用普通 Version 写接口。

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

**请求示例**

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
  "emailContent": "EXAMPLE_AES_CONTENT",
  "emailContentKey": "EXAMPLE_AES_KEY",
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

**响应字段与示例**

| 响应条件 | 字段                         | 类型     | 说明                                                   |
| -------- | ---------------------------- | -------- | ------------------------------------------------------ |
| 成功     | `data.emailCode`             | String   | 后端为 B 生成的新业务标识                              |
| 成功     | `data.version`               | String   | 固定返回`V1`                                           |
| 成功     | `data.versionStatus`         | Integer  | 固定返回`3=Draft`                                      |
| 成功     | `data.emailStatus`           | String   | B 的当前启停状态，按新建 Draft 现有默认值返回          |
| 字段校验失败 | `data.invalidFieldCount`   | Integer  | 本次可定位校验失败的字段数量，等于 `fieldErrors` 长度 |
| 字段校验失败 | `data.fieldErrors`         | Object[] | 全部可同时发现的可定位输入错误                         |
| 字段校验失败 | `data.fieldErrors[].field` | String   | 请求 JSON 路径，例如 `emailName`、`subCategoryIds[0]` |
| 字段校验失败 | `data.fieldErrors[].code`  | String   | 字段级原因，例如 `REQUIRED`、`DUPLICATE`、`INVALID`   |
| 字段校验失败 | `data.fieldErrors[].message` | String | 供前端显示的具体错误提示                               |
| 单项业务失败 | `data`                     | null     | 例如来源版本不再是当前 Active、来源不可用或系统失败    |

```json
{
  "requestId": "example-request-id",
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
  "requestId": "example-request-id",
  "responseCode": "10000120",
  "responseMessage": "The source template is no longer the current Active template.",
  "data": null
}
```

**字段校验失败 JSON 示例**

```json
{
  "requestId": "example-request-id",
  "responseCode": "00000006",
  "responseMessage": "Copy template validation failed.",
  "data": {
    "fieldErrors": [
      {"field": "emailName", "code": "DUPLICATE", "message": "当前 Category 下 Template Title 已存在。"},
      {"field": "subCategoryIds[0]", "code": "INVALID_SUBCATEGORY_BELONGING", "message": "Subcategory 必须属于当前 Category。"}
    ],
    "invalidFieldCount": 2
  }
}
```

**错误码与提示**

| 业务语义码                 | responseCode                                                      | responseMessage                            |
| -------------------------- | ----------------------------------------------------------------- | ------------------------------------------ |
| COPY_SOURCE_NOT_ACTIVE     | `10000120` (`MsgResEnum.EMAIL_VERSION_EXIST_OPERATION_ERROR`) | 来源 Template 已不是当前 Active Template。 |
| TEMPLATE_NAME_DUPLICATE    | `10000107` (`MsgResEnum.MSG_NAME_ALREADY_EXISTS`)             | 当前 Category 下 Template Title 已存在。   |
| REQUEST_VALIDATION_FAILED  | `00000006` (`IICResEnum.PARAM_ERROR`)                         | 请求参数不合法。                           |
| METADATA_VALIDATION_FAILED | `00000006` (`IICResEnum.PARAM_ERROR`)                         | Template Metadata 校验失败。               |
| TAG_VALUE_INVALID          | `00000006`；`fieldErrors[].code=TAG_VALUE_INVALID`            | Tag 选择无效、已软删除或不属于提交 Group。 |
| OPERATION_FAILED           | `00000001` (`IICResEnum.FAILED`)                              | 操作失败，请稍后重试。                     |

**前端处理与错误**

- 来源校验失败：来源不存在、已停用/删除，或 `sourceVersion` 已不再是当前最新 Active；前端保留页面内容并提示刷新来源后重试。
- `sourceEmailCode/sourceVersion` 的来源并发校验失败是单项业务失败，返回 `data=null` 并提示刷新来源后重试；不作为输入框字段错误。
- `emailName`、Version 内容、附件和 Metadata 的可定位输入校验使用 `data.fieldErrors[]` 一次返回全部问题；默认 `(Copy)` 名称冲突时，前端按 `field="emailName"` 定位名称输入框。Category/Subcategory/Tag 已失效或归属不合法时同样返回字段级错误。Draft 不执行 Publish 的四个 Mandatory Tag Group 完整性校验。
- Template B、V1 Draft 和 Metadata 必须原子创建；任一步失败均不得返回成功或留下半成品。
- 创建 B 时在 `iic_msg_email_config.copy_from_email_code` 保存 A 的 `emailCode`，作为不可变的内部来源追踪值；普通新建 Template 保存 `NULL`。
- 来源 Template A 全程只读，不更新其状态、内容、Metadata 或附件引用。除上述内部来源字段和发布前 Popup 外，A/B 不建立可导航或可操作的业务关系；后续均 Published 时，Content Manager 和 Adviser 都按两个普通 Template 展示。
- B 的 Save Draft、Publish、Schedule、Deactivate、Delete 和 Version History 完全复用普通 Template 规则；不得因 `copy_from_email_code` 改写 A 或 B 的内容级 Version 生命周期。

## 4. 版本管理

### EX-09 Add Version

**接口与场景**

| 项目     | 内容                                                        |
| -------- | ----------------------------------------------------------- |
| Endpoint | `POST /iic-dae-msg/web/msg/template/email/v2/version/add` |
| 页面     | `UI-A-06` Version History / 增加版本流程                  |
| 场景     | 已有 Template 新增 V(N>1)：创建 Draft、立即发布或预约发布   |

> [!NOTE]
> **新增版本专用入口（EX-09）**：
> `emailCode` 已存在时，本接口按 v1 最大 Version 规则处理：最大 Version 为 Active 或 Expired 时，`isDraft="1"` 新增目标 `V(N+1)` Draft；最大 Version 为 Draft/Schedule 时，常规新增请求被拒绝。`isDraft="2"` 新增 `V(N+1)`，再按 `effectiveWay` 进入 Active 或 Schedule。已有 Draft 的发布/预约和已有 Schedule 的取消预约统一走 EX-10。不得调用已废弃的 `/v2/publish`。

**请求参数与示例**

| 字段                 | 类型          | 必填 | 说明                                                                                 |
| -------------------- | ------------- | ---: | ------------------------------------------------------------------------------------ |
| `emailCode`        | String        |   是 | 模板标识                                                                             |
| `version`          | String/null   |   否 | 可显式传目标版本；省略时后端按最大 Version 自动计算新增目标`V(N+1)`                |
| `moduleCode`       | String/null   |   否 | 模块编码                                                                             |
| `scenarioCode`     | String/null   |   否 | 场景编码                                                                             |
| `editMode`         | String        |   是 | 编辑器模式                                                                           |
| `title`            | String/null   | 条件 | Email Subject；`isDraft="1"` 时允许为空，`isDraft="2"` 发布或预约发布时按 Publish 校验必填 |
| `emailContent`     | String        |   是 | AES 加密正文                                                                         |
| `emailContentKey`  | String/null   | 条件 | 加密正文需要解密 Key 时必填                                                          |
| `textContent`      | String/null   |   否 | 纯文本正文                                                                           |
| `effectiveWay`     | Integer/null  | 条件 | `isDraft="2"` 时必填：`0=立即生效, 1=预约生效`；`isDraft="1"` 时不触发状态切换 |
| `effectiveFrom`    | DateTime/null | 条件 | `isDraft="2" && effectiveWay=1` 时必填；新增 Draft 可按现状保存时间但不转 Schedule |
| `effectiveUntil`   | DateTime/null |   否 | 沿用现有 Version 字段语义                                                            |
| `fileKeys`         | String/null   |   否 | 附件 Key，逗号分隔                                                                   |
| `isDraft`          | String        |   是 | 与 v1 一致：`"1"` 保存 Draft；`"2"` 新增并发布/预约目标 Version                  |
| `thumbnailKey`     | String/null   |   否 | 缩略图 Key                                                                           |
| `isCustomBranding` | String        |   是 | `0=No, 1=Yes`                                                                      |

```json
{
  "emailCode": "815645091883520000",
  "version": "V2",
  "moduleCode": "COMMUNICATION",
  "scenarioCode": "TEMPLATE_LIBRARY",
  "title": "LEAD-93 V2 API test",
  "isDraft": "2",
  "effectiveWay": 0,
  "effectiveFrom": null,
  "effectiveUntil": null,
  "editMode": "HTML",
  "emailContent": "EXAMPLE_AES_CONTENT",
  "textContent": "LEAD-93 V2 API test",
  "fileKeys": "",
  "emailContentKey": "EXAMPLE_AES_KEY",
  "thumbnailKey": null,
  "isCustomBranding": "0"
}
```

**响应字段与示例**

| 字段                       | 类型        | 说明                                                                  |
| -------------------------- | ----------- | --------------------------------------------------------------------- |
| `requestId`              | String      | 请求追踪标识                                                          |
| `responseCode`           | String      | 成功时为`00000000`                                                  |
| `responseMessage`        | String      | 成功时为`Succeed`                                                   |
| `data.emailCode`         | String      | 模板标识                                                              |
| `data.version`           | String      | 新增的目标版本号                                                      |
| `data.versionStatus`     | Integer     | 最终状态：`3=Draft`、`1=Active`、`0=Schedule`                   |
| `data.copyFromEmailCode` | String/null | Copy Template B 时为来源 A 的`emailCode`；普通 Template 为 `null` |

```json
{
  "requestId": "example-request-id",
  "responseCode": "00000000",
  "responseMessage": "Succeed",
  "data": {"emailCode": "815645091883520000", "version": "V2", "versionStatus": 1, "copyFromEmailCode": "815645091883520000"}
}
```

发布成功后，V2 为 Active (`1`)，V1 转为 Expired (`2`)。

**失败响应 JSON 示例**

```json
{
  "requestId": "example-request-id",
  "responseCode": "00000006",
  "responseMessage": "2 fields must be completed before publishing.",
  "data": {
    "invalidFieldCount": 2,
    "fieldErrors": [
      {"field": "title", "code": "REQUIRED", "message": "Title is required."},
      {"field": "tagGroups[TRIGGER]", "code": "REQUIRED", "message": "At least one Trigger tag is required."}
    ]
  }
}
```

**错误码与提示**

| 业务语义码                | responseCode                                          | responseMessage                                                    |
| ------------------------- | ----------------------------------------------------- | ------------------------------------------------------------------ |
| REQUEST_VALIDATION_FAILED | `00000006` (`IICResEnum.PARAM_ERROR`)             | 请求参数不合法。                                                   |
| TEMPLATE_NOT_FOUND        | `10000108` (`MsgResEnum.MSG_CODE_DOES_NOT_EXIST`) | Template 不存在或已不可用。                                        |
| VERSION_STATE_INVALID     | `00000006` (`IICResEnum.PARAM_ERROR`)             | 当前 Version 状态不允许此操作。                                    |
| PUBLISH_VALIDATION_FAILED | `00000006` (`IICResEnum.PARAM_ERROR`)             | 发布前必须填写 X 个字段；`data.fieldErrors[]` 返回全部失败字段。 |
| OPERATION_FAILED          | `00000001` (`IICResEnum.FAILED`)                  | 操作失败，请稍后重试。                                             |

**前端处理与错误**

- `isDraft="1"` 时，最大 Version 为 Active 或 Expired 均新增目标 `V(N+1)` Draft；不触发发布校验，`title` 可为空。`version` 可省略，由后端计算新增版本号；前端不应自行依赖版本号计算。`isDraft="2"` 时，后端新增目标 `V(N+1)`：`effectiveWay=0` 进入 Active、旧 Active 变 Expired；`effectiveWay=1` 进入 Schedule、旧 Active 保持，由现有 Scheduler 到点完成 `Schedule -> Active` 与旧 Active 过期。发布前任一字段不通过时，必须在一次失败响应的 `data.fieldErrors[]` 返回全部错误，且不写入本次 Version/状态变化。
- 创建 Draft、发布或预约发布均不承担 Copy and Create；独立模板复制使用 `NEW-10`。成功执行 `isDraft="2"` 的发布或预约命令时，响应返回目标 Template 当前的 `copyFromEmailCode`，供前端保持 Copy 发布提醒上下文；普通 Template 返回 `null`。版本内容写入、适用的 Publish Validation 与状态切换必须处于同一事务；当前 Template Metadata 不随 Version 复制。

### EX-10 Update Version

**接口与场景**

| 项目     | 内容                                                                                |
| -------- | ----------------------------------------------------------------------------------- |
| Endpoint | `POST /iic-dae-msg/web/msg/template/email/v2/version/update`                      |
| 页面     | `UI-A-04` Template 创建与编辑                                                     |
| 场景     | 修改指定已有 V(N) 的内容；可受控执行 Draft 发布/预约，或 Cancel Schedule 恢复 Draft |

**请求参数**

| 字段                 | 类型          | 必填 | 说明                                                                                                              |
| -------------------- | ------------- | ---: | ----------------------------------------------------------------------------------------------------------------- |
| `emailCode`        | String        |   是 | 模板标识                                                                                                          |
| `version`          | String        |   是 | 目标 version                                                                                                      |
| `moduleCode`       | String/null   |   否 | 模块编码                                                                                                          |
| `scenarioCode`     | String/null   |   否 | 场景编码                                                                                                          |
| `editMode`         | String/null   |   否 | 编辑器模式                                                                                                        |
| `title`            | String/null   |   否 | Email Subject；Draft 允许为空                                                                                     |
| `emailContent`     | String/null   |   否 | AES 加密正文；Draft 允许为空                                                                                      |
| `emailContentKey`  | String/null   | 条件 | 加密正文需要解密 Key 时传入                                                                                       |
| `textContent`      | String/null   |   否 | 纯文本正文                                                                                                        |
| `isDraft`          | String        |   是 | v1 兼容命令：`"1"` 保存 Draft/取消预约；`"2"` 发布或预约发布                                                  |
| `effectiveWay`     | Integer/null  | 条件 | `isDraft="2"` 时必填：`0=立即生效, 1=预约生效`；`isDraft="1"` 时不驱动状态切换                              |
| `effectiveFrom`    | DateTime/null | 条件 | `isDraft="2" && effectiveWay=1` 时必填且必须晚于当前时间；立即发布由后端写当前时间；Save Draft 不传时保留已存值 |
| `effectiveUntil`   | DateTime/null |   否 | 立即 Active 时由现有实现写当前时间；Save Draft 不传时保留已存值                                                   |
| `fileKeys`         | String/null   |   否 | 附件 Key，逗号分隔                                                                                                |
| `thumbnailKey`     | String/null   |   否 | 缩略图 Key                                                                                                        |
| `isCustomBranding` | String/null   |   否 | `0=No, 1=Yes`                                                                                                   |

**请求示例**

```json
{
  "emailCode": "815645091883520000",
  "version": "V2",
  "moduleCode": "COMMUNICATION",
  "scenarioCode": "TEMPLATE_LIBRARY",
  "title": "Your updated retirement review",
  "editMode": "HTML",
  "emailContent": "EXAMPLE_AES_CONTENT",
  "emailContentKey": "EXAMPLE_AES_KEY",
  "textContent": "Your updated retirement review",
  "fileKeys": "",
  "isDraft": "1",
  "thumbnailKey": null,
  "isCustomBranding": "0"
}
```

**状态迁移请求示例（Cancel Schedule）**

```json
{
  "emailCode": "815645091883520000",
  "version": "V2",
  "isDraft": "1"
}
```

**响应字段与示例**

| 字段                       | 类型        | 说明                                                                  |
| -------------------------- | ----------- | --------------------------------------------------------------------- |
| `data.emailCode`         | String      | 模板标识                                                              |
| `data.version`           | String      | 目标 version                                                          |
| `data.versionStatus`     | Integer     | 命令完成后的 Version 状态                                             |
| `data.copyFromEmailCode` | String/null | Copy Template B 时为来源 A 的`emailCode`；普通 Template 为 `null` |

```json
{
  "requestId": "example-request-id",
  "responseCode": "00000000",
  "responseMessage": "Succeed",
  "data": {"emailCode": "815645091883520000", "version": "V2", "versionStatus": 3, "copyFromEmailCode": "815645091883520000"}
}
```

**失败响应 JSON 示例**

```json
{
  "requestId": "example-request-id",
  "responseCode": "10000110",
  "responseMessage": "The requested version does not exist.",
  "data": null
}
```

**发布校验失败 JSON 示例（`isDraft="2"`）**

```json
{
  "requestId": "example-request-id",
  "responseCode": "00000006",
  "responseMessage": "2 fields must be completed before publishing.",
  "data": {
    "invalidFieldCount": 2,
    "fieldErrors": [
      {"field": "title", "code": "REQUIRED", "message": "Title is required."},
      {"field": "tagGroups[TRIGGER]", "code": "REQUIRED", "message": "At least one Trigger tag is required."}
    ]
  }
}
```

**错误码与提示**

| 业务语义码                | responseCode                                                      | responseMessage                                                    |
| ------------------------- | ----------------------------------------------------------------- | ------------------------------------------------------------------ |
| REQUEST_VALIDATION_FAILED | `00000006` (`IICResEnum.PARAM_ERROR`)                         | 请求参数不合法。                                                   |
| TEMPLATE_NOT_FOUND        | `10000108` (`MsgResEnum.MSG_CODE_DOES_NOT_EXIST`)             | Template 不存在或已不可用。                                        |
| VERSION_NOT_FOUND         | `10000110` (`MsgResEnum.MSG_VERSION_DOES_NOT_EXIST`)          | 指定 Version 不存在。                                              |
| VERSION_STATE_INVALID     | `00000006` (`IICResEnum.PARAM_ERROR`)                         | 当前 Version 状态不允许此操作。                                    |
| VERSION_CONFLICT          | `10000120` (`MsgResEnum.EMAIL_VERSION_EXIST_OPERATION_ERROR`) | Template Version 已变更，请刷新后重试。                            |
| PUBLISH_VALIDATION_FAILED | `00000006` (`IICResEnum.PARAM_ERROR`)                         | 发布前必须填写 X 个字段；`data.fieldErrors[]` 返回全部失败字段。 |
| OPERATION_FAILED          | `00000001` (`IICResEnum.FAILED`)                              | 操作失败，请稍后重试。                                             |

**受控状态迁移与前端处理**

| 当前状态         | 命令字段                        | 后端处理                                   | 校验与结果                                                                            |
| ---------------- | ------------------------------- | ------------------------------------------ | ------------------------------------------------------------------------------------- |
| Draft (`3`)    | `isDraft="2", effectiveWay=0` | 更新目标 Draft；旧 Active 变 Expired       | 执行完整 Publish 校验；后端写`effectiveFrom/effectiveUntil=now`；同事务提交         |
| Draft (`3`)    | `isDraft="2", effectiveWay=1` | 更新目标 Draft 为 Schedule                 | 执行完整 Publish 校验；未来`effectiveFrom` 必填；旧 Active 保持                     |
| Schedule (`0`) | `isDraft="1"`                 | 取消预约，恢复同一 Version 为 Draft        | 不执行 Publish 校验；省略时间字段，保留已存`effectiveFrom/effectiveUntil`           |
| Schedule (`0`) | `isDraft="2", effectiveWay=0` | 立即生效同一 Version；旧 Active 变 Expired | 执行完整 Publish 校验；后端写`effectiveFrom/effectiveUntil=now`；同事务提交         |
| Draft (`3`)    | `isDraft="1"`                 | 保存同一 Draft 内容                        | 不改变`versionStatus`；不传时间时保留已存生效时间                                   |
| Active (`1`)   | 任意                            | 拒绝直接改为 Draft 或其他状态              | 返回`VERSION_STATE_INVALID`；如需草稿，保留 Active 并由 EX-09 新建 `V(N+1)` Draft |
| 其他组合         | 任意                            | 拒绝                                       | 返回`VERSION_STATE_INVALID`；不写库                                                 |

- EX-10 不创建 Version、不修改 Template 当前 Metadata。新增 V(N+1) 始终使用 EX-09。
- Draft -> Active/Schedule 的发布校验失败必须以 `data.fieldErrors[]` 一次返回全部可定位错误，且不写入本次内容或状态变化。
- 成功执行 `isDraft="2"` 的立即发布或预约发布时，响应返回目标 Template 当前的 `copyFromEmailCode`；普通 Template 返回 `null`。Save Draft 或 Cancel Schedule 不依赖该字段，但响应结构保持兼容。
- `Schedule -> Active` 可由前端通过本接口立即触发，也可由现有 Scheduler 在 `effectiveFrom` 到点后自动执行；两条路径遵循相同的发布校验和旧 Active 过期规则。
- 后端 Update 影响 0 行时返回失败；前端提示刷新，不显示保存成功。前端只暴露上表四条状态操作；后端仍必须拒绝其他状态组合。

### EX-11 Delete Version

**接口与场景**

| 项目     | 内容                                                                                                                         |
| -------- | ---------------------------------------------------------------------------------------------------------------------------- |
| Endpoint | `POST /iic-dae-msg/web/msg/template/email/v2/version/delete`                                                               |
| 页面     | `UI-A-04` Template 创建与编辑、`UI-A-06` Version History                                                                 |
| 场景     | Cancel 已保存 Working Copy；删除 Draft/Schedule version。删除预约版本与 EX-10 的 Cancel Schedule（恢复 Draft）是两条不同路径 |

**请求参数与示例**

| 字段          | 类型   | 必填 | 说明                        |
| ------------- | ------ | ---: | --------------------------- |
| `emailCode` | String |   是 | 模板标识                    |
| `version`   | String |   是 | 目标 Draft/Schedule version |

```json
{"emailCode": "815645091883520000", "version": "V2"}
```

**响应字段与示例**

```json
{"requestId": "example-request-id", "responseCode": "00000000", "responseMessage": "Succeed", "data": null}
```

**失败响应 JSON 示例**

```json
{
  "requestId": "example-request-id",
  "responseCode": "10000121",
  "responseMessage": "Operation failed. The version has been published.",
  "data": null
}
```

**错误码与提示**

| 业务语义码            | responseCode                                                          | responseMessage                                   |
| --------------------- | --------------------------------------------------------------------- | ------------------------------------------------- |
| TEMPLATE_NOT_FOUND    | `10000108` (`MsgResEnum.MSG_CODE_DOES_NOT_EXIST`)                 | Template 不存在或已不可用。                       |
| VERSION_NOT_FOUND     | `10000110` (`MsgResEnum.MSG_VERSION_DOES_NOT_EXIST`)              | 指定 Version 不存在。                             |
| VERSION_PUBLISHED     | `10000121` (`MsgResEnum.EMAIL_VERSION_PUBLISHED_OPERATION_ERROR`) | Operation failed. The version has been published. |
| VERSION_STATE_INVALID | `00000006` (`IICResEnum.PARAM_ERROR`)                             | 当前 Version 状态不允许此操作。                   |
| OPERATION_FAILED      | `00000001` (`IICResEnum.FAILED`)                                  | 操作失败，请稍后重试。                            |

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

**请求示例**

```text
GET /iic-dae-msg/web/msg/template/email/v2/version/getMaxVersion?emailCode=815645091883520000
```

**响应字段**

| 字段                   | 类型    | 说明               |
| ---------------------- | ------- | ------------------ |
| `data.emailCode`     | String  | Template 标识      |
| `data.version`       | String  | 最大数字版本       |
| `data.versionStatus` | Integer | 该最大版本当前状态 |

**成功响应示例**

```json
{
  "requestId": "example-request-id",
  "responseCode": "00000000",
  "responseMessage": "Succeed",
  "data": {"emailCode": "815645091883520000", "version": "V2", "versionStatus": 3}
}
```

**失败响应 JSON 示例**

```json
{
  "requestId": "example-request-id",
  "responseCode": "10000108",
  "responseMessage": "The template does not exist.",
  "data": null
}
```

**错误码与提示**

| 业务语义码         | responseCode                                          | responseMessage             |
| ------------------ | ----------------------------------------------------- | --------------------------- |
| TEMPLATE_NOT_FOUND | `10000108` (`MsgResEnum.MSG_CODE_DOES_NOT_EXIST`) | Template 不存在或已不可用。 |
| OPERATION_FAILED   | `00000001` (`IICResEnum.FAILED`)                  | 操作失败，请稍后重试。      |

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

**请求参数与示例**

| 字段          | 类型   | 必填 | 说明                       |
| ------------- | ------ | ---: | -------------------------- |
| `emailCode` | String |   是 | 模板标识                   |
| `version`   | String |   是 | 目标 version；不得自动改选 |

```json
{"emailCode": "815645091883520000", "version": "V1"}
```

**响应字段**

返回指定 version 的现有 Version Detail 字段。Version Editor 打开历史 Version 时，并行调用 EX-13 读取所选 Version 内容、调用 EX-03 读取当前 Category/Subcategory/Tag。EX-13 的 `categoryId` 不作为当前主分类数据来源，且 EX-13 不是 Metadata 历史快照接口。

**成功响应示例**

```json
{
  "requestId": "example-request-id",
  "responseCode": "00000000",
  "responseMessage": "Succeed",
  "data": {
    "emailCode": "815645091883520000",
    "version": "V1",
    "versionStatus": 1,
    "title": "Your retirement review",
    "emailContent": "EXAMPLE_AES_CONTENT",
    "fileKeys": ""
  }
}
```

**失败响应 JSON 示例**

```json
{
  "requestId": "example-request-id",
  "responseCode": "10000110",
  "responseMessage": "The requested version does not exist.",
  "data": null
}
```

**错误码与提示**

| 业务语义码         | responseCode                                             | responseMessage             |
| ------------------ | -------------------------------------------------------- | --------------------------- |
| TEMPLATE_NOT_FOUND | `10000108` (`MsgResEnum.MSG_CODE_DOES_NOT_EXIST`)    | Template 不存在或已不可用。 |
| VERSION_NOT_FOUND  | `10000110` (`MsgResEnum.MSG_VERSION_DOES_NOT_EXIST`) | 指定 Version 不存在。       |
| PERMISSION_DENIED  | `10000007` (`IICResEnum.PERMISSION_DENIED`)          | 无权限执行此操作。          |

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

**请求参数与示例**

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

**响应字段与示例**

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
  "requestId": "example-request-id",
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
  "requestId": "example-request-id",
  "responseCode": "10000108",
  "responseMessage": "The template does not exist.",
  "data": null
}
```

**错误码与提示**

| 业务语义码                | responseCode                                          | responseMessage             |
| ------------------------- | ----------------------------------------------------- | --------------------------- |
| REQUEST_VALIDATION_FAILED | `00000006` (`IICResEnum.PARAM_ERROR`)             | 请求参数不合法。            |
| TEMPLATE_NOT_FOUND        | `10000108` (`MsgResEnum.MSG_CODE_DOES_NOT_EXIST`) | Template 不存在或已不可用。 |
| PERMISSION_DENIED         | `10000007` (`IICResEnum.PERMISSION_DENIED`)       | 无权限执行此操作。          |

**前端处理与错误**

- 首次发布不额外创建 V2：同一 V1 从 Draft 变为 Active，并作为 V1 历史记录显示。
- Version History 只展示内容版本历史，不混入 Template 基本信息和 Category/Tag 修改记录。

## 5. 分类管理

### NEW-01 Category Tree

**接口与场景**

| 项目     | 内容                                                                     |
| -------- | ------------------------------------------------------------------------ |
| Endpoint | `GET /iic-dae-msg/web/msg/template/email/v2/category/tree`             |
| 页面     | UI-A-07 Category 管理列表                                                |
| 场景     | 加载管理树；加载筛选项；加载模板分类选择；加载迁移目标；Adviser 分类导航 |

**请求参数与示例**

本接口不接收业务筛选参数，始终读取完整有效的两级分类树。Adviser 的关键词、Category/Subcategory 和 Tag 筛选仅提交给 `EX-01`；分类树不随当前列表条件变化。

```text
GET /iic-dae-msg/web/msg/template/email/v2/category/tree
```

**响应字段**

| 字段                              | 类型        | 说明                                                                                                             |
| --------------------------------- | ----------- | ---------------------------------------------------------------------------------------------------------------- |
| `data[].id`                     | String      | 节点 ID；后端 Long 在 JSON 边界序列化为 String                                                                   |
| `data[].categoryName`           | String      | 显示名                                                                                                           |
| `data[].description`            | String/null | 节点描述；可为空                                                                                                 |
| `data[].parentId`               | String      | 一级固定为`"0"`，二级为父 Category ID                                                                          |
| `data[].sortOrder`              | Integer     | 同级排序                                                                                                         |
| `data[].publishedTemplateCount` | Integer     | 该节点包含的全部 Published Template 数量；按唯一 `emailCode` 去重，最小为 `0` |
| `data[].children`               | Object[]    | 二级节点；无节点返回`[]`                                                                                       |
| `data[].leaf`                   | Boolean     | 是否叶子节点                                                                                                     |

**成功响应示例**

```json
{
  "requestId": "example-request-id",
  "responseCode": "00000000",
  "responseMessage": "Succeed",
  "data": [{
      "id": "1001",
      "categoryName": "Client Engagement",
      "description": "Client communication templates",
      "parentId": "0",
      "sortOrder": 1,
      "publishedTemplateCount": 12,
      "leaf": false,
      "children": [{
        "id": "1101",
        "categoryName": "Advice Review",
        "description": null,
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
  "requestId": "example-request-id",
  "responseCode": "10000007",
  "responseMessage": "No permission to view categories.",
  "data": null
}
```

**错误码与提示**

| 业务语义码        | responseCode                                    | responseMessage        |
| ----------------- | ----------------------------------------------- | ---------------------- |
| PERMISSION_DENIED | `10000007` (`IICResEnum.PERMISSION_DENIED`) | 无权限执行此操作。     |
| OPERATION_FAILED  | `00000001` (`IICResEnum.FAILED`)            | 操作失败，请稍后重试。 |

**前端处理与错误**

- 只返回有效节点；软删除节点不用于新建、编辑、筛选或迁移目标。
- Category 与 Subcategory 都返回 `publishedTemplateCount`。只统计 `config.status=0`、`config.email_status=1`、`config.is_campaign=0` 且存在有效 Active Version 的 Template；Draft、Schedule、Expired 不计入。
- 数量按唯一 `emailCode` 去重。即使关系表异常重复，同一 Template 在同一节点内也只能计数一次。
- 没有匹配 Published Template 的有效节点仍须返回，`publishedTemplateCount=0`，前端显示 `(0)`。
- Adviser 修改 Search、Category/Subcategory 或 Tag Filter 后，只重新调用 `EX-01` 更新列表；不重新调用本接口。
- 固定两级；前端不推导或展示第三级。
- Category 层级由后端根据 `parentId` 推导，前端不提交持久化层级字段。
- `id` 是 Category/Subcategory 唯一标识；Contract 不提供或接收 `categoryCode`。

### NEW-02 Create Category

**接口与场景**

| 项目     | 内容                                                     |
| -------- | -------------------------------------------------------- |
| Endpoint | `POST /iic-dae-msg/web/msg/template/email/v2/category` |
| 页面     | `UI-A-08` Create Category/Subcategory                  |
| 场景     | 创建一级 Category                                        |

**请求参数与示例**

| 字段             | 类型        | 必填 | 说明                                                                  |
| ---------------- | ----------- | ---: | --------------------------------------------------------------------- |
| `categoryName` | String      |   是 | 有效节点全局唯一                                                      |
| `description`  | String/null |   否 | 节点描述；可为空                                                      |
| `parentId`     | String      |   是 | 创建一级 Category 固定传`"0"`；批量创建 Subcategory 使用 `NEW-08` |

```json
{
  "categoryName": "Client Engagement",
  "description": "Client communication templates",
  "parentId": "0"
}
```

**响应字段与示例**

返回创建后的完整 Category Node。

```json
{
  "requestId": "example-request-id",
  "responseCode": "00000000",
  "responseMessage": "Succeed",
  "data": {
    "id": "3001",
    "categoryName": "Client Engagement",
    "description": "Client communication templates",
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
  "requestId": "example-request-id",
  "responseCode": "90000015",
  "responseMessage": "An active category with this name already exists.",
  "data": null
}
```

**错误码与提示**

| 业务语义码                | responseCode                                                     | responseMessage                        |
| ------------------------- | ---------------------------------------------------------------- | -------------------------------------- |
| REQUEST_VALIDATION_FAILED | `00000006` (`IICResEnum.PARAM_ERROR`)                        | 请求参数不合法。                       |
| CATEGORY_NAME_DUPLICATE   | `90000015` (`ExceptionCodeEnum.DUPLICATE_CATEGORY_NAME`)     | 有效 Category/Subcategory 名称已存在。 |
| CATEGORY_LEVEL_INVALID    | `90000013` (`ExceptionCodeEnum.CATEGORY_MAX_DEPTH_EXCEEDED`) | Category 层级或父节点不合法。          |
| OPERATION_FAILED          | `00000001` (`IICResEnum.FAILED`)                             | 操作失败，请稍后重试。                 |

**前端处理与错误**

- 名称为空时返回 `REQUEST_VALIDATION_FAILED`；与任一有效 Category/Subcategory 重复时返回 `CATEGORY_NAME_DUPLICATE`。页面在名称输入框显示内联提示，不关闭创建弹窗。
- 软删除后允许重新创建同名节点。
- `categoryId` 由数据库生成，前端创建时不传；后续编辑、排序和删除使用返回的 `categoryId`。

### NEW-03 Update Category/Subcategory

**接口与场景**

| 项目     | 内容                                                            |
| -------- | --------------------------------------------------------------- |
| Endpoint | `POST /iic-dae-msg/web/msg/template/email/v2/category/update` |
| 页面     | `UI-A-09` Edit Category/Subcategory                           |
| 场景     | 编辑 Category 或 Subcategory 的 Name                            |

**请求参数与示例**

| 字段             | 类型        | 必填 | 说明             |
| ---------------- | ----------- | ---: | ---------------- |
| `categoryId`   | String      |   是 | 目标节点         |
| `categoryName` | String      |   是 | 新名称           |
| `description`  | String/null |   否 | 节点描述；可为空 |

```json
{"categoryId": "3001", "categoryName": "Client Engagement", "description": "Client communication templates"}
```

**响应字段与示例**

更新成功返回 `data=null`。前端随后重新加载 Category Tree。

```json
{"requestId":"example-request-id","responseCode":"00000000","responseMessage":"Succeed","data":null}
```

**失败响应 JSON 示例**

```json
{
  "requestId": "example-request-id",
  "responseCode": "90000016",
  "responseMessage": "An active category with this name already exists.",
  "data": null
}
```

**错误码与提示**

| 业务语义码                | responseCode                                                 | responseMessage                        |
| ------------------------- | ------------------------------------------------------------ | -------------------------------------- |
| REQUEST_VALIDATION_FAILED | `00000006` (`IICResEnum.PARAM_ERROR`)                    | 请求参数不合法。                       |
| CATEGORY_NOT_FOUND        | `90000016` (`ExceptionCodeEnum.CATEGORY_NOT_FOUND`)      | Category/Subcategory 不存在或已删除。  |
| CATEGORY_NAME_DUPLICATE   | `90000015` (`ExceptionCodeEnum.DUPLICATE_CATEGORY_NAME`) | 有效 Category/Subcategory 名称已存在。 |
| OPERATION_FAILED          | `00000001` (`IICResEnum.FAILED`)                         | 操作失败，请稍后重试。                 |

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

**请求示例：首次删除尝试**

```json
{
  "sourceCategoryId": "1001"
}
```

**请求示例：确认迁移并删除**

```json
{
  "sourceCategoryId": "1001",
  "targetCategoryId": "2001",
  "targetSubcategoryIds": ["2101"]
}
```

**响应 JSON 示例**

1. 无引用直接软删除成功：

```json
{
  "requestId": "example-request-id",
  "responseCode": "00000000",
  "responseMessage": "Succeed",
  "data": {
    "success": true,
    "reassignRequired": false,
    "affectedTemplateCount": 0
  }
}
```

2. 存在有效引用阻断（需要选择迁移目标）：

```json
{
  "requestId": "example-request-id",
  "responseCode": "90000030",
  "responseMessage": "Category is in use. Select a target Category before deleting.",
  "data": {
    "success": false,
    "reassignRequired": true,
    "affectedTemplateCount": 2
  }
}
```

3. 提交有效目标完成迁移并软删除成功：

```json
{
  "requestId": "example-request-id",
  "responseCode": "00000000",
  "responseMessage": "Succeed",
  "data": {
    "success": true,
    "reassignRequired": true,
    "affectedTemplateCount": 2
  }
}
```

4. 迁移目标合法性校验失败（如选择自身或下属子分类）：

```json
{
  "requestId": "example-request-id",
  "responseCode": "90000031",
  "responseMessage": "迁移目标不能为当前被删除节点或其子分类。",
  "data": {
    "success": false,
    "reassignRequired": true,
    "affectedTemplateCount": 2
  }
}
```

前端接收到 `reassignRequired=true` 且 `success=false` 时，直接读取 `data.affectedTemplateCount` 弹出提示：“该分类下有 X 个模板，请选择迁移目标。”，并展示目标分类选择下拉框。

**错误码与提示**

| 业务语义码                       | responseCode                                                  | responseMessage                                     |
| -------------------------------- | ------------------------------------------------------------- | --------------------------------------------------- |
| REQUEST_VALIDATION_FAILED        | `00000006` (`IICResEnum.PARAM_ERROR`)                     | 请求参数不合法。                                    |
| CATEGORY_NOT_FOUND               | `90000033` (`ExceptionCodeEnum.CATEGORY_ALREADY_DELETED`) | Category/Subcategory 不存在或已删除。               |
| CATEGORY_IN_USE                  | `90000030` (`ExceptionCodeEnum.CATEGORY_IN_USE`)          | Category 已被 Active/Draft/Schedule Template 引用。 |
| CATEGORY_TARGET_INVALID          | `90000031` (`ExceptionCodeEnum.INVALID_MIGRATION_TARGET`) | 目标 Category/Subcategory 不可用。                  |
| INVALID_MIGRATION_TARGET         | `90000031` (`ExceptionCodeEnum.INVALID_MIGRATION_TARGET`) | 迁移目标不能为当前被删除节点或其子分类。            |
| CATEGORY_CONCURRENT_MODIFICATION | `90000032` (`ExceptionCodeEnum.CONCURRENT_MODIFICATION`)  | Category 引用已变化，请刷新后重试。                 |
| PERMISSION_DENIED                | `10000007` (`IICResEnum.PERMISSION_DENIED`)               | 无权限执行此操作。                                  |
| OPERATION_FAILED                 | `00000001` (`IICResEnum.FAILED`)                          | 操作失败，请稍后重试。                              |

**前端处理与错误**

- 前端删除操作只调用本接口。首次请求不传 targetCategoryId；后端在事务内检查 Active/Draft/Schedule 引用。
- 无上述引用时，后端直接软删除 Category/Subcategory，Expired-only Template 不阻止删除，也不迁移其历史 Metadata。
- 有引用时，后端不删除，返回 CATEGORY_IN_USE 和 data.reassignRequired=true，以及影响统计；前端据此展示迁移目标选择。
- 用户确认目标后，前端调用同一接口并提交 targetCategoryId 和 targetSubcategoryIds。后端必须重新检查真实引用，并原子完成当前 Metadata 迁移、Category 软删除、Category Change History 和受影响 Template Config Log 写入。
- targetCategoryId 不存在、已删除或层级不匹配时返回 CATEGORY_TARGET_INVALID；目标等于源节点或位于待删除子树时返回 INVALID_MIGRATION_TARGET。两次调用之间引用或节点变化时返回 CATEGORY_CONCURRENT_MODIFICATION，前端重新发起首次删除尝试。
- 只要迁移、软删除或任一 History/Audit 写入失败，整笔事务回滚；前端不得循环调用单 Template Metadata API 代替本接口。

### NEW-05 Reorder Category

**接口与场景**

| 项目     | 内容                                                             |
| -------- | ---------------------------------------------------------------- |
| Endpoint | `POST /iic-dae-msg/web/msg/template/email/v2/category/reorder` |
| 页面     | `UI-A-07` Category 管理列表                                    |
| 场景     | 保存 Category 或同一父 Category 下 Subcategory 的前端排序        |

**请求参数与示例**

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

**响应字段与示例**

```json
{
  "requestId": "example-request-id",
  "responseCode": "00000000",
  "responseMessage": "Succeed",
  "data": null
}
```

**失败响应 JSON 示例**

```json
{
  "requestId": "example-request-id",
  "responseCode": "90000032",
  "responseMessage": "The category order has changed. Refresh and try again.",
  "data": null
}
```

**错误码与提示**

| 业务语义码                | responseCode                                                     | responseMessage                       |
| ------------------------- | ---------------------------------------------------------------- | ------------------------------------- |
| REQUEST_VALIDATION_FAILED | `00000006` (`IICResEnum.PARAM_ERROR`)                        | 请求参数不合法。                      |
| CATEGORY_NOT_FOUND        | `90000033` (`ExceptionCodeEnum.CATEGORY_ALREADY_DELETED`)    | Category/Subcategory 不存在或已删除。 |
| CATEGORY_LEVEL_INVALID    | `90000013` (`ExceptionCodeEnum.CATEGORY_MAX_DEPTH_EXCEEDED`) | Category 层级或父节点不合法。         |
| CATEGORY_ORDER_STALE      | `90000032` (`ExceptionCodeEnum.CONCURRENT_MODIFICATION`)     | Category 排序已变化，请刷新后重试。   |
| OPERATION_FAILED          | `00000001` (`IICResEnum.FAILED`)                             | 操作失败，请稍后重试。                |

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

**请求参数与示例**

| 位置 | 字段              | 类型        | 必填 | 说明                                                      |
| ---- | ----------------- | ----------- | ---: | --------------------------------------------------------- |
| Body | `parentId`      | String      |   是 | 必须存在、`status=0` 且 `parent_id=0` 的一级 Category |
| Body | `subcategories` | Object[]    |   是 | 1-5 项                                                    |
| Item | `name`          | String      |   是 | 全局有效名称唯一                                          |
| Item | `description`   | String/null |   否 | 节点描述；可为空                                          |

```json
{
  "parentId": "1001",
  "subcategories": [
    {"name": "Advice Review", "description": "Advice review templates"},
    {"name": "Annual Check-in", "description": null}
  ]
}
```

**响应字段与示例**

`data[]` 按请求顺序返回创建后的 Category Tree Node。

```json
{
  "requestId": "example-request-id",
  "responseCode": "00000000",
  "responseMessage": "Succeed",
  "data": [
    {"id": "5000", "categoryName": "Advice Review", "description": "Advice review templates", "parentId": "1001", "sortOrder": 1, "leaf": true, "children": []},
    {"id": "5001", "categoryName": "Annual Check-in", "description": null, "parentId": "1001", "sortOrder": 2, "leaf": true, "children": []}
  ]
}
```

**失败响应 JSON 示例**

```json
{
  "requestId": "example-request-id",
  "responseCode": "00000006",
  "responseMessage": "2 个子目录校验失败。",
  "data": {
    "fieldErrors": [
      {
        "itemIndex": null,
        "itemName": null,
        "businessCode": "CATEGORY_NOT_FOUND",
        "field": "parentId",
        "code": "INVALID",
        "message": "Parent Category 不存在或已删除。"
      },
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
    "invalidFieldCount": 3
  }
}
```

**错误码与提示**

| 业务语义码                | responseCode                                   | responseMessage                        |
| ------------------------- | ---------------------------------------------- | -------------------------------------- |
| REQUEST_VALIDATION_FAILED | `00000006` (`IICResEnum.PARAM_ERROR`)      | 请求参数不合法。                       |
| CATEGORY_NOT_FOUND        | `00000006`；`fieldErrors[].field=parentId` | Parent Category 不存在或已删除。       |
| CATEGORY_LEVEL_INVALID    | `00000006`；`fieldErrors[].field=parentId` | Parent 必须为一级 Category。           |
| CATEGORY_NAME_DUPLICATE   | `00000006`；`fieldErrors[].code=DUPLICATE` | 有效 Category/Subcategory 名称已存在。 |
| OPERATION_FAILED          | `00000001` (`IICResEnum.FAILED`)           | 操作失败，请稍后重试。                 |

**前端处理与错误**

- 后端先校验完整请求，再决定是否写入：Parent 必须存在、有效且为一级 Category；数组为空、超过 5 条、名称为空、批内重名和与有效节点重名均需在同一次响应中返回。每个失败子目录在 data.fieldErrors[] 中占一项，包含 itemIndex、itemName、businessCode、field、code 和 message；itemIndex 从 0 开始，对应原请求数组位置。
- 同名的两个请求项都必须分别返回失败项；多个不同子目录同时失败时也必须全部返回。invalidFieldCount 等于失败子目录数量；Parent 自身非法时使用 field=parentId、itemIndex=null 返回该项。
- 本接口是原子操作：只要 data.fieldErrors[] 非空，本批任何 Subcategory 都不得创建。前端按 itemIndex 标红，修正后必须整批重新提交，不能拆成逐条重试。

### NEW-11 Batch Template Reassignment（暂时保留先不删）

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

**请求示例**

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

**响应字段与示例**

成功时返回 `data=null`。

```json
{"requestId":"example-request-id","responseCode":"00000000","responseMessage":"Succeed","data":null}
```

**失败响应 JSON 示例**

```json
{
  "requestId": "example-request-id",
  "responseCode": "10000108",
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

| 业务语义码                 | responseCode                                                | responseMessage                            |
| -------------------------- | ----------------------------------------------------------- | ------------------------------------------ |
| REQUEST_VALIDATION_FAILED  | `00000006` (`IICResEnum.PARAM_ERROR`)                   | 请求参数不合法。                           |
| TEMPLATE_NOT_FOUND         | `10000108` (`MsgResEnum.MSG_CODE_DOES_NOT_EXIST`)       | Template 不存在或已不可用。                |
| CATEGORY_NOT_FOUND         | `90000021` (`ExceptionCodeEnum.CATEGORY_NOT_AVAILABLE`) | Category/Subcategory 不存在或已删除。      |
| CATEGORY_LEVEL_INVALID     | `00000006` (`IICResEnum.PARAM_ERROR`)                   | Category 层级或父节点不合法。              |
| TAG_VALUE_INVALID          | `00000006`；`fieldErrors[].code=TAG_VALUE_INVALID`      | Tag 选择无效、已软删除或不属于提交 Group。 |
| METADATA_VALIDATION_FAILED | `00000006`；详见 `fieldErrors[]`                        | Template Metadata 校验失败。               |
| OPERATION_FAILED           | `00000001` (`IICResEnum.FAILED`)                        | 操作失败，请稍后重试。                     |

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

**请求参数与示例**

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

**成功响应示例**

```json
{
  "requestId": "example-request-id",
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
  "requestId": "example-request-id",
  "responseCode": "10000007",
  "responseMessage": "No permission to view tag taxonomy.",
  "data": null
}
```

**错误码与提示**

| 业务语义码        | responseCode                                    | responseMessage        |
| ----------------- | ----------------------------------------------- | ---------------------- |
| PERMISSION_DENIED | `10000007` (`IICResEnum.PERMISSION_DENIED`) | 无权限执行此操作。     |
| OPERATION_FAILED  | `00000001` (`IICResEnum.FAILED`)            | 操作失败，请稍后重试。 |

**前端处理与错误**

- Taxonomy 由固定 DB seed 维护，前端不提供 Tag 管理 CRUD。
- 每个 Group 均可多选；同组筛选 OR，不同组筛选 AND。
- 前端按 `maxSelections` 限制选择数量；Trigger 为 5，`null` 表示当前不限制。
- 4 个 Mandatory Group；前端不把 `isMandatory` 写死在页面代码中。
- 示例只展示代表性 Tag Value；前端必须按接口返回的完整数组动态展示选项。
- Template 当前 Tag 可以暂时不完整，不自动生成 `Unclassified`；Publish 时再根据 `isMandatory=1` 阻止缺失项。Metadata 修改只依赖已存在的 `emailCode`，不属于任何 Version 状态。

## 7. 业务失败响应约定

业务成功和业务失败均返回 HTTP 200。前端先判断 responseCode：00000000 为成功，其他值为业务失败。普通失败只显示 responseMessage；不得向页面返回 SQL、堆栈或内部类名。

responseCode 已在本文按业务语义冻结。前端不得依赖 responseMessage 的固定文本做业务分支；后续实现必须遵循本文定义，不得为已定义业务语义重新分配数字码。

### 7.1 普通业务失败

除 7.2 列出的结构化错误接口外，所有失败响应都使用以下最小结构：

```json
{
  "requestId": "example-request-id",
  "responseCode": "00000001",
  "responseMessage": "The requested operation cannot be completed.",
  "data": null
}
```

页面显示 responseMessage，并按当前页面已有交互保留输入、刷新列表或关闭弹窗；不解析额外错误对象。

### 7.2 需要字段级错误信息的接口

下列接口需要结构化 `data.fieldErrors`，用于定位输入框或批量项。每个 Endpoint 的业务语义码与文案仍以其自身“错误码与提示”表为准。

| Endpoint                                                  | 为什么需要结构化错误信息                                 | data 返回字段                                                                       |
| --------------------------------------------------------- | -------------------------------------------------------- | ----------------------------------------------------------------------------------- |
| EX-05 Create Template and V1 Version                      | 首次创建需同时校验主信息、V1 内容和 Metadata             | fieldErrors、invalidFieldCount                                                      |
| EX-06 Update Template Master Fields and Metadata          | 一次性校验名称、Category/Subcategory 和 Tag 关系         | fieldErrors、invalidFieldCount                                                      |
| EX-09 新增 Active / Schedule、EX-10 Draft 发布 / Schedule | 发布前需要逐字段标红并显示顶部汇总                       | fieldErrors、invalidFieldCount                                                      |
| NEW-08 Batch Create Subcategories                         | 需定位批量数组中全部重复或非法的子目录                   | fieldErrors[].itemIndex/itemName/businessCode/field/code/message、invalidFieldCount |
| NEW-10 Copy and Create                                    | 首次保存独立模板 B 时需定位名称、内容、附件和 Metadata   | fieldErrors、invalidFieldCount                                                      |
| NEW-11 Batch Template Reassignment                        | 需定位批量 Template 中失败的具体项目和字段               | fieldErrors、invalidFieldCount                                                      |
| NEW-12 Delete Category/Subcategory                        | 首次删除发现有效引用时，前端需显示影响范围并选择迁移目标 | reassignRequired、impact                                                            |

EX-05、EX-06、EX-09、EX-10 与 NEW-10 的 `data.fieldErrors[]` 使用同一包络；预写校验应一次返回全部可同时发现的错误：

```json
{
  "fieldErrors": [
    {"field": "emailName", "code": "DUPLICATE", "message": "当前 Category 下 Template Title 已存在。"}
  ],
  "invalidFieldCount": 1
}
```

`field` 使用请求 JSON 路径或 `null`；`code` 表示字段级校验（如 `REQUIRED`、`DUPLICATE`、`INVALID`）。EX-05、EX-06、EX-09、EX-10、NEW-08、NEW-10、NEW-11 的任何可定位输入校验失败，外层统一返回 `responseCode="00000006"`（`IICResEnum.PARAM_ERROR`）和 `data.fieldErrors[]`；前端只按字段路径和 `code/message` 渲染，不按 `900000xx` 分支。`fieldErrors` 非空时不得写库。校验通过后发生的 Version Conflict、状态不允许、对象不存在、权限、事务或系统失败，返回对应单项业务失败和 `data=null`。NEW-08 使用 `fieldErrors[]` 返回本批全部失败子目录；NEW-10 使用 `fieldErrors[]` 返回 Copy Draft 的全部可定位输入问题；NEW-11 使用 `fieldErrors[]` 定位 Metadata 或批量项；NEW-12 在 `CATEGORY_IN_USE` 时返回 `reassignRequired` 和 `impact`；其他接口不返回结构化错误 data。

### 7.3 业务语义码与实际 responseCode

每个 Endpoint 的“错误码与提示”表已列出其全部业务失败场景：

- 业务语义码用于需求、开发和测试对齐，例如 CATEGORY_IN_USE、VERSION_CONFLICT；它不是本期响应 data 的字段。
- 实际 responseCode 已由 Message Center 本服务枚举定义并回填；不得在 Service 中直接写数字码，也不得修改 common 代码库。
- 既有 Template/Version 语义复用 `MsgResEnum`；LEAD-93 的 Category、Tag、Metadata、批量重分配语义使用 `ExceptionCodeEnum`。聚合字段校验的外层统一使用 `00000006`，细粒度原因由 `fieldErrors[].code` 表示；目录管理等非聚合接口仍返回其对应 `ExceptionCodeEnum` 码。
- 前端以 responseCode != 00000000 判断失败并展示 responseMessage；EX-05、EX-06、EX-09、EX-10、NEW-08、NEW-10、NEW-11 仅在 `data.fieldErrors` 存在时逐项定位控件。

---

## 附录：更新日志（2026-07-27 ~ 2026-07-28）

### Endpoint 路由变更（7/27）

- NEW-03：`PUT /category/{id}` → `POST /category/update`，id 从 URL Path 移入 Body 字段 `categoryId`
- NEW-05：`PUT /category/reorder` → `POST /category/reorder`

### 响应字段新增（7/27）

- EX-05、EX-09、EX-10 发布/预约成功时 `data` 统一返回 `copyFromEmailCode`

### 请求参数调整（7/28）

- EX-01：`emailName` → `keyWords`（替换，不再接收 `emailName` 别名）
- EX-09 Draft：`title` 改为可空，仅 Publish/预约时校验必填
- NEW-01：移除 `keyWords`、`tagGroups` 筛选参数，只返回静态 Published 计数
- NEW-10 Copy Draft 的 Save Draft 校验统一返回 `fieldErrors[]`
