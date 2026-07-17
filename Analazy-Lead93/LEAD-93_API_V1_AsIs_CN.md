# LEAD-93 现有 v1 API As-Is 接口约定

> 状态：现有 Web 与 Mobile App 兼容基线  
> 更新日期：2026-07-17  
> Controller 前缀：`/web/msg/template/email/v1`  
> 接口总数：17（LEAD-93 Contract 15、辅助查询 2）  
> 原则：本文只描述已存在的 v1 行为；LEAD-93 增强和新增能力使用 v2，不反向改变本文契约。

## 1. 阅读说明

本文按 Endpoint 组织现有 v1 接口。每个 Endpoint 只出现一次，并在同一节中说明：

1. 完整 Method + Endpoint；
2. 当前页面和业务场景；
3. 请求参数；
4. 脱敏请求示例；
5. 响应字段；
6. 脱敏响应示例；
7. 已验证行为、限制和错误处理。

### 1.1 证据标记

| 标记 | 含义 |
|---|---|
| `QA 实测` | 2026-07-16 已在 QA 发起真实请求并验证 HTTP、业务码或业务结果 |
| `代码确认` | 内网 Controller、DTO/BO/VO 或 Service 分析已确认 |

QA 顺序回归覆盖 22 个调用场景，共 110 个断言，HTTP 全部为 200。21 个场景返回 `00000000`；删除 Active version 按预期返回业务失败码 `10000121`。Send Email 和 Usage Report 不属于 LEAD-93 改造及本轮回归范围。

### 1.2 公共约定

| 项目 | v1 As-Is 约定 |
|---|---|
| 服务前缀 | `/iic-dae-msg`；环境外层路由由网关自动维护，不进入接口契约 |
| Controller 前缀 | `/web/msg/template/email/v1` |
| 响应包络 | `IICResponseModel<T>`：`requestId/responseCode/responseMessage/data` |
| 成功业务码 | `responseCode="00000000"`、`responseMessage="Succeed"` |
| HTTP 与业务成功 | 不能只判断 HTTP 200，必须同时判断 `responseCode` |
| 分页请求 | `pageNum/pageSize` |
| 分页响应 | `pageNo/pageSize/totalCount/totalPage/dataList` |
| 时间格式 | `yyyy-MM-dd HH:mm:ss` |
| 时间语义 | 服务器、业务和用户统一使用南非业务时区 `Africa/Johannesburg`（UTC+02:00） |
| 64 位标识 | `emailCode` 在 JavaScript 中按 String 处理 |
| 附件 | `fileKeys` 为逗号分隔的 S3 File Key；附件可选 |
| 正文 | `emailContent` 为加密正文；`emailContentKey` 为对应 Key |

QA 已确认的应用请求头：

| Header | 必填 | 说明 |
|---|---:|---|
| `authorization` | 是 | 当前登录态的完整 `Bearer ...` 值 |
| `x-apigw-api-id` | 是 | 当前环境的 API Gateway ID |
| `content-type` | 是 | `application/json` |
| `language` | 是 | QA 已确认使用 `en-US`；使用 `en` 曾触发通用 HTTP 500 |
| `requestid` | 是 | 每次调用使用新的短唯一值 |

不要把浏览器 `sec-ch-*` 请求头手工复制到 Postman/Newman；非 Chrome TLS 客户端携带这些 Header 可能触发 WAF。

### 1.3 状态值

| 字段 | 值 | 含义 |
|---|---:|---|
| `versionStatus` | `0` | Schedule |
| `versionStatus` | `1` | Active |
| `versionStatus` | `2` | Expired |
| `versionStatus` | `3` | Draft |
| `emailStatus` | `0` | Inactive |
| `emailStatus` | `1` | Active |
| `status` | `0` | 有效记录 |
| `status` | `-1` | 软删除记录 |
| `isDraft` | `"1"` | Save Draft |
| `isDraft` | `"2"` | Publish |
| `effectiveWay` | `0` | 立即生效 |
| `effectiveWay` | `1` | 预约生效 |

### 1.4 Endpoint 目录

| 分类 | Endpoint ID |
|---|---|
| 模板查询与详情 | [V1-01](#v1-01-published-list)、[V1-02](#v1-02-template-library-admin-list)、[V1-03](#v1-03-template-detail)、[V1-04](#v1-04-published-detail)、[V1-15](#v1-15-channel-list) |
| 模板保存与生命周期 | [V1-05](#v1-05-save-draft--publish--schedule)、[V1-06](#v1-06-update-template-master-fields)、[V1-07](#v1-07-change-status)、[V1-08](#v1-08-delete-template) |
| 版本管理 | [V1-09](#v1-09-add-version)、[V1-10](#v1-10-update-version)、[V1-11](#v1-11-delete-version)、[V1-12](#v1-12-get-max-version)、[V1-13](#v1-13-version-detail)、[V1-14](#v1-14-version-history) |
| 辅助查询 | [V1-S01](#v1-s01-query-object)、[V1-S02](#v1-s02-recipient-list) |

## 2. 模板查询与详情

### V1-01 Published List

**接口与场景**

| 项目 | 内容 |
|---|---|
| Endpoint | `POST /iic-dae-msg/web/msg/template/email/v1/queryList` |
| 当前页面 | Published/Adviser 模板列表 |
| 当前场景 | 查询可使用的 Published 模板；按模板名称搜索 |
| Request DTO | `EmailQueryDTO` |
| Response DTO | `PageResult<EmailDetailVO>` |
| 证据 | `QA 实测` + `代码确认` |

**As-Is 查询约束**

后端现有 Published 查询硬编码过滤：

- `version.status = 0`；
- `config.status = 0`；
- `config.email_status = 1`；
- `version.version_status = 1`；
- `is_campaign != 1`。

因此 v1 默认排除 Campaign。LEAD-93 不修改此 v1 查询，Email/Campaign 选择和 Metadata Filter 由 v2 提供。

**请求参数**

| 字段 | 类型 | 必填 | 说明 |
|---|---|---:|---|
| `isCampaign` | Integer | 否 | 现有 DTO 字段；As-Is 查询仍硬编码排除 Campaign |
| `emailName` | String | 否 | 模板名称关键字 |
| `pageNum` | Integer | 是 | 页码，QA 使用 1 |
| `pageSize` | Integer | 是 | 页大小，QA 使用 20 |
| `channelList` | String[] | 否 | Channel Filter；QA 使用空数组 |

**请求示例**

```json
{
  "isCampaign": 0,
  "emailName": "Retirement review",
  "pageNum": 1,
  "pageSize": 20,
  "channelList": []
}
```

**响应字段**

| 字段 | 类型 | 说明 |
|---|---|---|
| `data.pageNo/pageSize/totalCount/totalPage` | Integer | 分页信息 |
| `data.dataList` | `EmailDetailVO[]` | Published 模板列表 |
| `data.dataList[].emailCode` | String | 模板业务标识 |
| `data.dataList[].emailName` | String | 模板名称 |
| `data.dataList[].description` | String/null | 模板描述 |
| `data.dataList[].version` | String | 返回版本 |
| `data.dataList[].versionStatus` | Integer | Published 查询为 `1=Active` |
| `data.dataList[].emailStatus` | String | Published 查询为 `1=Active` |
| `data.dataList[].title` | String/null | Email Subject |
| `data.dataList[].modifiedBy/modifiedTime` | String/DateTime | 修改信息 |
| `data.dataList[].publishedTime` | DateTime/null | 发布时间 |
| `data.dataList[].isCampaign` | Integer | Email/Campaign 标识 |

**成功响应示例**

```json
{
  "requestId": "qa-request-id",
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
      "description": "Invitation for the annual retirement review",
      "version": "V1",
      "versionStatus": 1,
      "emailStatus": "1",
      "title": "Your retirement review",
      "isCampaign": 0,
      "modifiedBy": "content.manager",
      "modifiedTime": "2026-07-16 09:00:00",
      "publishedTime": "2026-07-16 09:00:00"
    }]
  }
}
```

**客户端处理与限制**

- 空结果使用现有 Empty State。
- v1 不支持 Category、Subcategory、Tag Filter。
- v1 不保证返回 LEAD-93 新增的 Metadata 字段。

### V1-02 Template Library Admin List

**接口与场景**

| 项目 | 内容 |
|---|---|
| Endpoint | `POST /iic-dae-msg/web/msg/template/email/v1/templateList` |
| 当前页面 | Template Library 管理列表 |
| 当前场景 | 按当前 Tab、状态、Channel、关键字和排序条件查询管理列表 |
| Request DTO | `TemplateEmailQueryBO` |
| Response DTO | Controller 声明为 `Object`；QA 已确认返回分页 `dataList` |
| 证据 | `QA 实测` + `代码确认`；本文列出前端依赖字段，完整响应已验证 |

**请求参数**

| 字段 | 类型 | 必填 | 说明 |
|---|---|---:|---|
| `pageNum` | Integer | 是 | 页码 |
| `pageSize` | Integer | 是 | 页大小 |
| `templateStatus` | String | 是 | 当前页面 Tab/模板状态编码；QA 调用值为 `"1"` |
| `keyWords` | String | 否 | 现有关键字 |
| `channelList` | String[] | 否 | Channel Filter |
| `emailStatusList` | String[] | 否 | 启停状态 Filter |
| `sortField` | String | 否 | QA 使用 `updatedDate` |
| `isAsc` | Boolean | 否 | QA 使用 `false` |

**请求示例**

```json
{
  "pageNum": 1,
  "pageSize": 20,
  "templateStatus": "1",
  "keyWords": "",
  "channelList": [],
  "emailStatusList": [],
  "sortField": "updatedDate",
  "isAsc": false
}
```

**响应字段**

| 字段 | 类型 | 说明 |
|---|---|---|
| `data.pageNo/pageSize/totalCount/totalPage` | Integer | 已确认分页层级 |
| `data.dataList` | Object[] | 当前 Tab 的模板记录 |
| `data.dataList[].emailCode` | String | 模板业务标识 |
| `data.dataList[].emailName` | String | 模板名称 |
| `data.dataList[].description` | String/null | 描述 |
| `data.dataList[].version` | String | 当前查询选择的版本 |
| `data.dataList[].versionStatus` | Integer | Schedule/Active/Expired/Draft |
| `data.dataList[].emailStatus` | String | Template 启停状态 |
| `data.dataList[].modifiedBy/modifiedTime` | String/DateTime | 修改信息 |

**成功响应示例**

以下示例只包含已确认可依赖字段，不表示现网条目只有这些字段。

```json
{
  "requestId": "qa-request-id",
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
      "description": "Invitation for the annual retirement review",
      "version": "V1",
      "versionStatus": 1,
      "emailStatus": "1",
      "modifiedBy": "content.manager",
      "modifiedTime": "2026-07-16 09:00:00"
    }]
  }
}
```

**客户端处理与限制**

- Tab 对应的状态组合由后端现有逻辑选择，前端不要自行合并不同查询结果。
- 同一 `emailCode` 的版本选择沿用现有最大数字版本逻辑。
- v1 不支持 Category、Subcategory 和 Tag Filter。

### V1-03 Template Detail

**接口与场景**

| 项目 | 内容 |
|---|---|
| Endpoint | `POST /iic-dae-msg/web/msg/template/email/v1/detail` |
| 当前页面 | 管理端 Template Detail、编辑页 |
| 当前场景 | 按 `emailCode` 和可选 `version` 加载模板详情 |
| Request DTO | `EmailDetailDTO` |
| Response DTO | `EmailDetailVO` |
| 证据 | `QA 实测` + `代码确认` |

**请求参数与示例**

| 字段 | 类型 | 必填 | 说明 |
|---|---|---:|---|
| `emailCode` | String | 是 | 模板业务标识 |
| `version` | String | 条件必填 | 查询指定版本时传；不传时沿用现有选版规则 |

```json
{
  "emailCode": "815645091883520000",
  "version": "V1"
}
```

**响应字段**

| 字段 | 类型 | 说明 |
|---|---|---|
| `data.emailName/emailCode/description` | String | 模板基本信息 |
| `data.version/versionStatus/emailStatus` | String/Integer | 版本与启停状态 |
| `data.emailContent/emailContentKey` | String | 加密正文及 Key |
| `data.title/textContent` | String/null | Subject 与纯文本正文 |
| `data.fileKeys/fileInfos` | String/List | 附件 Key 和附件信息 |
| `data.moduleCode` | String | 模块编码 |
| `data.channel/channelName` | String | Channel |
| `data.modifiedBy/modifiedTime/publishedTime` | Mixed | 修改、发布时间 |
| `data.messageType` | Integer | `0=Email, 1=SMS` |
| `data.thumbnailKey` | String/null | 缩略图 Key |
| `data.isCustomBranding` | String | `0/1` |
| `data.isCampaign` | Integer | Email/Campaign 标识 |

**成功响应示例**

```json
{
  "requestId": "qa-request-id",
  "responseCode": "00000000",
  "responseMessage": "Succeed",
  "data": {
    "emailName": "Retirement review invitation",
    "emailCode": "815645091883520000",
    "description": "Invitation for the annual retirement review",
    "version": "V1",
    "versionStatus": 1,
    "emailStatus": "1",
    "emailContent": "ENCRYPTED_CONTENT",
    "emailContentKey": "ENCRYPTED_KEY",
    "title": "Your retirement review",
    "textContent": "Your retirement review",
    "fileKeys": "",
    "fileInfos": [],
    "moduleCode": "COMMUNICATION",
    "channel": "EMAIL",
    "channelName": "Email",
    "modifiedBy": "content.manager",
    "modifiedTime": "2026-07-16 09:00:00",
    "publishedTime": "2026-07-16 09:00:00",
    "messageType": 0,
    "thumbnailKey": null,
    "isCustomBranding": "0",
    "isCampaign": 0
  }
}
```

**客户端处理与限制**

- 编辑明确版本时必须传 `version`，避免依赖自动选版。
- v1 响应没有 Category、Subcategory、Tag 等版本 Metadata 契约。
- 目标记录不存在时沿用现有业务错误或空数据处理。

### V1-04 Published Detail

**接口与场景**

| 项目 | 内容 |
|---|---|
| Endpoint | `POST /iic-dae-msg/web/msg/template/email/v1/published/detail` |
| 当前页面 | Adviser Published Template Detail |
| 当前场景 | 加载指定模板当前可用的 Published 内容 |
| Request DTO | `EmailDetailDTO` |
| Response DTO | `EmailDetailVO` |
| 证据 | `QA 实测` + `代码确认` |

**请求参数与示例**

| 字段 | 类型 | 必填 | 说明 |
|---|---|---:|---|
| `emailCode` | String | 是 | 模板业务标识 |

```json
{"emailCode": "815645091883520000"}
```

**响应字段与示例**

响应字段与 [V1-03 Template Detail](#v1-03-template-detail) 的 `EmailDetailVO` 相同，但当前接口按 Published 语义返回可使用的 Active version。

```json
{
  "requestId": "qa-request-id",
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
    "emailContent": "ENCRYPTED_CONTENT",
    "fileKeys": "",
    "fileInfos": [],
    "isCampaign": 0
  }
}
```

**客户端处理与限制**

- v1 不允许通过请求指定 Draft/Schedule version。
- Inactive、软删除或没有 Active version 时不得把其他版本当作 Published 内容展示。

### V1-15 Channel List

**接口与场景**

| 项目 | 内容 |
|---|---|
| Endpoint | `POST /iic-dae-msg/web/msg/template/email/v1/channelList` |
| 当前页面 | 模板创建、编辑及查询页面 |
| 当前场景 | 加载 Channel 选项 |
| Request DTO | 无 |
| Response DTO | `List<ChannelInfoVO>` |
| 证据 | `QA 实测` + `代码确认`；QA 返回 10 条 Channel |

**请求参数与示例**

无业务参数。

```json
{}
```

**响应字段与示例**

| 字段 | 类型 | 说明 |
|---|---|---|
| `data[].channel` | String | Channel 编码 |
| `data[].channelName` | String | Channel 显示名称 |

```json
{
  "requestId": "qa-request-id",
  "responseCode": "00000000",
  "responseMessage": "Succeed",
  "data": [
    {"channel": "EMAIL", "channelName": "Email"}
  ]
}
```

**客户端处理与限制**

- LEAD-93 保持本接口不变。
- 示例只展示一条，QA 实际返回 10 条；完整 Channel 常量由现有系统维护。

## 3. 模板保存与生命周期

### V1-05 Save Draft / Publish / Schedule

**接口与场景**

| 项目 | 内容 |
|---|---|
| Endpoint | `POST /iic-dae-msg/web/msg/template/email/v1/add` |
| 当前页面 | 模板创建和编辑 |
| 当前场景 | 新建/更新 Draft；Publish Now；Schedule Publish；通过 Save Draft 取消 Schedule |
| Request DTO | `EmailAddBO` |
| Response DTO | `EmailInfoVO` |
| 证据 | 新建 V1 Draft、同 V1 Publish 为 `QA 实测`；其他状态分支为 `代码确认`/已确认现状 |

**场景行为**

| 场景 | 关键输入 | As-Is 结果 |
|---|---|---|
| 首次 Save Draft | 无 `emailCode`、`version="V1"`、`isDraft="1"` | Insert V1 Draft，后端生成 `emailCode` |
| 更新已有 Draft | 已有 Draft 的 `emailCode/version`、`isDraft="1"` | Update 同一 Draft |
| Active 且无 Draft | Active 的 `emailCode`、新版本号、`isDraft="1"` | Insert V(N+1) Draft |
| 仅 Expired 且无 Draft | 目标最大版本、`isDraft="1"` | Update V(N) 为 Draft |
| Schedule 期间 Save Draft | Schedule 的 `emailCode/version`、`isDraft="1"` | Update 同一 V(N) 为 Draft；保留已保存时间 |
| Publish Now | `isDraft="2"`、`effectiveWay=0` | 目标版本 Active；旧 Active Expired |
| Schedule Publish | `isDraft="2"`、`effectiveWay=1`、未来 `effectiveFrom` | 目标版本 Schedule；定时任务生效 |

Save Draft 即使携带未来 `effectiveFrom` 也不会生成 Schedule；时间仍保存在 Draft row。Schedule 必须由 Publish 并选择未来时间产生。

**请求参数**

| 字段 | 类型 | 必填 | 说明 |
|---|---|---:|---|
| `moduleCode` | String | 否 | 模块编码 |
| `moduleCodeName` | String | 否 | 模块名称 |
| `scenarioCode` | String | 否 | 场景编码 |
| `emailCode` | String | 条件必填 | 新建不传；更新/Publish 已有模板时传 |
| `emailName` | String | 是 | Template Name |
| `description` | String/null | 否 | 描述 |
| `effectiveWay` | Integer | 否 | `0=Now, 1=Schedule` |
| `effectiveFrom` | DateTime/null | 条件必填 | Schedule Publish 必填；Draft 可保存 |
| `effectiveUntil` | DateTime/null | 否 | Draft 可保存；Active 生效后通常为 null |
| `title` | String/null | 否 | Email Subject |
| `editMode` | String | 否 | QA 使用 `HTML` |
| `emailContent` | String | 是 | 加密正文 |
| `textContent` | String/null | 否 | 纯文本正文 |
| `fileKeys` | String/null | 否 | 附件 Key，逗号分隔 |
| `emailContentKey` | String/null | 否 | 正文 Key |
| `isDraft` | String | 是 | `"1"=Save Draft, "2"=Publish` |
| `version` | String | 条件必填 | 新建为 V1；编辑时为目标版本 |
| `thumbnailKey` | String/null | 否 | 缩略图 Key |
| `channelMap` | Object | 否 | Channel 内容映射 |
| `isCustomBranding` | String | 是 | `0/1`，代码有 `@NotBlank` |
| `isCampaign` | Integer | 否 | Email/Campaign 标识 |

**请求示例：首次 Save Draft**

```json
{
  "moduleCode": "COMMUNICATION",
  "moduleCodeName": "Communications",
  "scenarioCode": "TEMPLATE_LIBRARY",
  "emailName": "LEAD93 API test",
  "description": "Temporary API test draft",
  "effectiveWay": 0,
  "effectiveFrom": null,
  "effectiveUntil": null,
  "title": "LEAD-93 API test",
  "editMode": "HTML",
  "emailContent": "ENCRYPTED_CONTENT",
  "textContent": "LEAD-93 API test",
  "fileKeys": "",
  "emailContentKey": "ENCRYPTED_KEY",
  "isDraft": "1",
  "version": "V1",
  "thumbnailKey": null,
  "channelMap": {},
  "isCustomBranding": "0",
  "isCampaign": 0
}
```

**请求示例：Publish Now**

```json
{
  "moduleCode": "COMMUNICATION",
  "moduleCodeName": "Communications",
  "scenarioCode": "TEMPLATE_LIBRARY",
  "emailCode": "815645091883520000",
  "emailName": "LEAD93 API test",
  "description": "Temporary API test draft",
  "effectiveWay": 0,
  "effectiveFrom": null,
  "effectiveUntil": null,
  "title": "LEAD-93 API test",
  "editMode": "HTML",
  "emailContent": "ENCRYPTED_CONTENT",
  "textContent": "LEAD-93 API test",
  "fileKeys": "",
  "emailContentKey": "ENCRYPTED_KEY",
  "isDraft": "2",
  "version": "V1",
  "thumbnailKey": null,
  "channelMap": {},
  "isCustomBranding": "0",
  "isCampaign": 0
}
```

**请求示例：Schedule Publish**

```json
{
  "emailCode": "815645091883520000",
  "emailName": "LEAD93 API test",
  "version": "V2",
  "isDraft": "2",
  "effectiveWay": 1,
  "effectiveFrom": "2026-08-01 09:00:00",
  "effectiveUntil": null,
  "title": "LEAD-93 API test",
  "emailContent": "ENCRYPTED_CONTENT",
  "emailContentKey": "ENCRYPTED_KEY",
  "isCustomBranding": "0",
  "isCampaign": 0
}
```

**响应字段**

| 字段 | 类型 | 说明 |
|---|---|---|
| `data.emailCode` | String | 首次保存返回后端生成的模板标识 |
| `data.version` | String | 实际保存版本 |
| 其他 `EmailInfoVO` 字段 | Mixed | 本次 QA 只断言并提取了 `emailCode/version`，其余字段不作为本文 v1 兼容依赖 |

**成功响应示例**

```json
{
  "requestId": "qa-request-id",
  "responseCode": "00000000",
  "responseMessage": "Succeed",
  "data": {
    "emailCode": "815645091883520000",
    "version": "V1"
  }
}
```

**客户端处理与限制**

- Published Validation、Category 和 Tag 必填属于 v2，不得反向增加为 v1 必填字段。
- 附件可选；现有前端负责 10 MB 和格式校验；Discard 不清理 S3 文件。

### V1-06 Update Template Master Fields

**接口与场景**

| 项目 | 内容 |
|---|---|
| Endpoint | `POST /iic-dae-msg/web/msg/template/email/v1/update` |
| 当前页面 | 模板基本信息编辑 |
| 当前场景 | 更新主表中的 Template Name、Description 等基本信息 |
| Request DTO | `TemplateEmailUpdateBO` |
| Response DTO | `Void` |
| 证据 | `QA 实测` + `代码确认` |

**请求参数与示例**

| 字段 | 类型 | 必填 | 说明 |
|---|---|---:|---|
| `emailCode` | String | 是 | 模板标识 |
| `emailName` | String | 是 | Template Name |
| `description` | String/null | 否 | 描述 |
| `isCampaign` | Integer | 否 | Email/Campaign 标识 |

```json
{
  "emailCode": "815645091883520000",
  "emailName": "Retirement review invitation updated",
  "description": "Updated description",
  "isCampaign": 0
}
```

**成功响应示例**

```json
{"requestId":"qa-request-id","responseCode":"00000000","responseMessage":"Succeed","data":null}
```

**客户端处理与限制**

- QA 已验证更新名称和描述后可通过 Detail 查询到新值。
- 这是主记录字段更新，不执行 Publish，不改变 `versionStatus`。

### V1-07 Change Status

**接口与场景**

| 项目 | 内容 |
|---|---|
| Endpoint | `POST /iic-dae-msg/web/msg/template/email/v1/changeStatus` |
| 当前页面 | Template Library |
| 当前场景 | Deactivate；Active/Reactivate |
| Request DTO | `TemplateStatusChangeBO` |
| Response DTO | `Void` |
| 证据 | Disable、Enable、再次 Disable 均为 `QA 实测` |

**请求参数与示例**

| 字段 | 类型 | 必填 | 说明 |
|---|---|---:|---|
| `emailCode` | String | 是 | 模板标识 |
| `emailStatus` | String | 是 | `0=Inactive, 1=Active` |

```json
{"emailCode":"815645091883520000","emailStatus":"0"}
```

**成功响应示例**

```json
{"requestId":"qa-request-id","responseCode":"00000000","responseMessage":"Succeed","data":null}
```

**客户端处理与限制**

- 只修改 `iic_msg_email_config.email_status`。
- 不修改 `config.status`，也不修改任何 version 的 `versionStatus`。
- Reactivate 恢复原 Active 内容，不重新执行 Publish。

### V1-08 Delete Template

**接口与场景**

| 项目 | 内容 |
|---|---|
| Endpoint | `POST /iic-dae-msg/web/msg/template/email/v1/delete` |
| 当前页面 | Template Library |
| 当前场景 | 删除 Template |
| Request DTO | `TemplateEmailDeleteBO` |
| Response DTO | `Void` |
| 证据 | 测试模板清理为 `QA 实测`；软删除行为为 `代码确认` |

**请求参数与示例**

| 字段 | 类型 | 必填 | 说明 |
|---|---|---:|---|
| `emailCode` | String | 是 | 模板标识 |

```json
{"emailCode":"815645091883520000"}
```

**成功响应示例**

```json
{"requestId":"qa-request-id","responseCode":"00000000","responseMessage":"Succeed","data":null}
```

**客户端处理与限制**

- 现有行为是级联软删除：更新 config 和所有 version 的 `status`。
- 不修改 version 的 `versionStatus`。
- 不清理 S3 附件。

## 4. 版本管理

### V1-09 Add Version

**接口与场景**

| 项目 | 内容 |
|---|---|
| Endpoint | `POST /iic-dae-msg/web/msg/template/email/v1/version/add` |
| 当前页面 | 现有 Add Version 流程 |
| 当前场景 | 使用完整 Version payload 新增目标版本 |
| Request DTO | `TemplateEmailVersionAddBO` |
| Response DTO | `TemplateEmailVersionVO` |
| 证据 | `QA 实测`：目标 `version="V2"` 的完整 payload 成功；最小 payload 失败 |

**请求参数**

| 字段 | 类型 | 必填 | 说明 |
|---|---|---:|---|
| `emailCode` | String | 是 | 模板标识 |
| `version` | String | 是 | 目标新增版本，例如 `V2` |
| `moduleCode` | String | 否 | 模块编码 |
| `scenarioCode` | String | 否 | 场景编码 |
| `title` | String/null | 否 | Subject |
| `effectiveWay` | Integer | 否 | 生效方式 |
| `effectiveFrom/effectiveUntil` | DateTime/null | 否 | 生效时间 |
| `editMode` | String | 否 | 编辑模式 |
| `emailContent/emailContentKey` | String | 条件 | 正文和 Key |
| `textContent` | String/null | 否 | 纯文本正文 |
| `fileKeys` | String/null | 否 | 附件 Key |
| `thumbnailKey` | String/null | 否 | 缩略图 |
| `isCustomBranding` | String | 是 | `0/1` |

**请求示例**

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
  "emailContent": "ENCRYPTED_CONTENT",
  "textContent": "LEAD-93 V2 API test",
  "fileKeys": "",
  "emailContentKey": "ENCRYPTED_KEY",
  "thumbnailKey": null,
  "isCustomBranding": "0"
}
```

**响应字段与示例**

```json
{
  "requestId": "qa-request-id",
  "responseCode": "00000000",
  "responseMessage": "Succeed",
  "data": {
    "emailCode": "815645091883520000",
    "version": "V2",
    "versionStatus": 1
  }
}
```

**已验证行为与限制**

- 最小请求 `{"emailCode":"...","version":"V1"}` 返回 `00000001`。
- 目标 `version="V2"` 的完整 payload 返回成功；后续查询确认 V2 Active、V1 Expired。
- 本接口表达现有“增加版本并切换 Active”语义；范围尚未确认的 Copy and Create 不在本文中推导。

### V1-10 Update Version

**接口与场景**

| 项目 | 内容 |
|---|---|
| Endpoint | `POST /iic-dae-msg/web/msg/template/email/v1/version/update` |
| 当前页面 | 模板版本编辑 |
| 当前场景 | 更新已有 Draft version 内容 |
| Request DTO | `TemplateEmailVersionAddBO` |
| Response DTO | `TemplateEmailVersionVO` |
| 证据 | `QA 实测` |

**请求参数**

请求字段与 [V1-09 Add Version](#v1-09-add-version) 相同；`emailCode` 和目标 `version` 必传。

**请求示例**

```json
{
  "emailCode": "815645091883520000",
  "version": "V1",
  "moduleCode": "COMMUNICATION",
  "scenarioCode": "TEMPLATE_LIBRARY",
  "title": "LEAD-93 V1 updated",
  "effectiveWay": 0,
  "effectiveFrom": null,
  "effectiveUntil": null,
  "editMode": "HTML",
  "emailContent": "ENCRYPTED_CONTENT",
  "textContent": "LEAD-93 V1 updated",
  "fileKeys": "",
  "emailContentKey": "ENCRYPTED_KEY",
  "thumbnailKey": null,
  "isCustomBranding": "0"
}
```

**响应字段与示例**

QA 已确认接口返回成功和 version 信息，但没有保存完整脱敏响应。最小安全示例为：

```json
{
  "requestId": "qa-request-id",
  "responseCode": "00000000",
  "responseMessage": "Succeed",
  "data": {
    "emailCode": "815645091883520000",
    "version": "V1"
  }
}
```

**客户端处理与限制**

- 只更新明确指定的目标 version。
- v1 不接收 Category、Subcategory 或 Tag Metadata。
- Update 失败时不得在客户端显示保存成功。

### V1-11 Delete Version

**接口与场景**

| 项目 | 内容 |
|---|---|
| Endpoint | `POST /iic-dae-msg/web/msg/template/email/v1/version/delete` |
| 当前页面 | 版本编辑/Version History |
| 当前场景 | 删除 Draft/Schedule；拒绝删除 Active |
| Request DTO | `TemplateEmailVersionDetailBO` |
| Response DTO | `Void` |
| 证据 | Draft/Schedule 删除成功与 Active 删除拒绝均为 `QA 实测` |

**请求参数与示例**

| 字段 | 类型 | 必填 | 说明 |
|---|---|---:|---|
| `emailCode` | String | 是 | 模板标识 |
| `version` | String | 是 | 目标版本 |

```json
{"emailCode":"815645091883520000","version":"V2"}
```

**成功响应结构**

```json
{"requestId":"qa-request-id","responseCode":"00000000","responseMessage":"Succeed","data":null}
```

**已验证失败响应：删除 Active**

HTTP Status 仍为 200，客户端必须读取业务码。

```json
{
  "requestId": "qa-request-id",
  "responseCode": "10000121",
  "responseMessage": "Operation failed. The version has been published.",
  "data": null
}
```

**客户端处理与限制**

- 未保存的页面编辑离开不调用本接口。
- 已持久化 Draft 的 Discard 调用本接口软删除目标 Draft。
- 删除 version 不清理 S3 附件。

### V1-12 Get Max Version

**接口与场景**

| 项目 | 内容 |
|---|---|
| Endpoint | `GET /iic-dae-msg/web/msg/template/email/v1/version/getMaxVersion?emailCode={emailCode}` |
| 当前页面 | 编辑和 Version History |
| 当前场景 | 获取指定模板最大数字版本 |
| Request DTO | Query Parameter `emailCode` |
| Response DTO | `TemplateEmailVersionVO` |
| 证据 | `QA 实测` + `代码确认` |

**请求参数与示例**

| 位置 | 字段 | 类型 | 必填 |
|---|---|---|---:|
| Query | `emailCode` | String | 是 |

```text
GET /iic-dae-msg/web/msg/template/email/v1/version/getMaxVersion?emailCode=815645091883520000
```

**响应字段与示例**

| 字段 | 类型 | 说明 |
|---|---|---|
| `data.emailCode` | String | 模板标识 |
| `data.version` | String | 最大数字版本 |
| `data.versionStatus` | Integer | 该版本当前状态 |

```json
{
  "requestId": "qa-request-id",
  "responseCode": "00000000",
  "responseMessage": "Succeed",
  "data": {
    "emailCode": "815645091883520000",
    "version": "V2",
    "versionStatus": 1
  }
}
```

**客户端处理与限制**

- 最大版本按数字比较，例如 V10 大于 V2，不按字符串字典序。
- 最大版本不等于 Draft；它可能是 Active、Schedule、Expired 或 Draft。

### V1-13 Version Detail

**接口与场景**

| 项目 | 内容 |
|---|---|
| Endpoint | `POST /iic-dae-msg/web/msg/template/email/v1/version/detail` |
| 当前页面 | 模板编辑、Version History |
| 当前场景 | 获取指定 `emailCode + version` 的版本内容 |
| Request DTO | `TemplateEmailVersionDetailBO` |
| Response DTO | `TemplateEmailVersionDetailVO` |
| 证据 | `QA 实测` + `代码确认` |

**请求参数与示例**

| 字段 | 类型 | 必填 | 说明 |
|---|---|---:|---|
| `emailCode` | String | 是 | 模板标识 |
| `version` | String | 是 | 指定版本 |

```json
{"emailCode":"815645091883520000","version":"V2"}
```

**响应字段**

| 字段 | 类型 | 说明 |
|---|---|---|
| `data.emailCode/version/versionStatus` | Mixed | 版本标识和状态 |
| `data.title` | String/null | Subject |
| `data.emailContent/emailContentKey` | String | 正文和 Key |
| `data.textContent` | String/null | 纯文本正文 |
| `data.fileKeys` | String/null | 附件 Key |
| `data.effectiveWay` | Integer | 生效方式 |
| `data.effectiveFrom/effectiveUntil` | DateTime/null | 生效时间 |
| `data.thumbnailKey/isCustomBranding` | Mixed | 缩略图和 Branding |

**成功响应示例**

```json
{
  "requestId": "qa-request-id",
  "responseCode": "00000000",
  "responseMessage": "Succeed",
  "data": {
    "emailCode": "815645091883520000",
    "version": "V2",
    "versionStatus": 1,
    "title": "LEAD-93 V2 API test",
    "emailContent": "ENCRYPTED_CONTENT",
    "emailContentKey": "ENCRYPTED_KEY",
    "textContent": "LEAD-93 V2 API test",
    "fileKeys": "",
    "effectiveWay": 0,
    "effectiveFrom": "2026-07-16 10:00:00",
    "effectiveUntil": null,
    "thumbnailKey": null,
    "isCustomBranding": "0"
  }
}
```

**客户端处理与限制**

- 必须按请求 version 返回，不得自动回退到其他版本。
- v1 不返回 LEAD-93 版本 Metadata 契约。

### V1-14 Version History

**接口与场景**

| 项目 | 内容 |
|---|---|
| Endpoint | `POST /iic-dae-msg/web/msg/template/email/v1/version/list/history` |
| 当前页面 | Version History |
| 当前场景 | 查询指定模板的版本历史 |
| Request DTO | `TemplateEmailVersionQueryBO` |
| Response DTO | `PageResult<TemplateEmailVersionListVO>` |
| 证据 | `QA 实测` + `代码确认`；本文列出前端依赖字段，完整响应已验证 |

**请求参数与示例**

| 字段 | 类型 | 必填 | 说明 |
|---|---|---:|---|
| `emailCode` | String | 是 | 模板标识 |
| `pageNum/pageSize` | Integer | 是 | 分页 |
| `sortField` | String | 否 | QA 使用 `version` |
| `isAsc` | Boolean | 否 | QA 使用 `false` |

```json
{
  "emailCode": "815645091883520000",
  "pageNum": 1,
  "pageSize": 20,
  "sortField": "version",
  "isAsc": false
}
```

**响应字段与示例**

| 字段 | 类型 | 说明 |
|---|---|---|
| `data.pageNo/pageSize/totalCount/totalPage` | Integer | 分页 |
| `data.dataList[].emailCode` | String | 模板标识 |
| `data.dataList[].version` | String | 版本号 |
| `data.dataList[].versionStatus` | Integer | 版本状态 |
| `data.dataList[].modifiedBy/modifiedTime` | String/DateTime | 修改信息 |

```json
{
  "requestId": "qa-request-id",
  "responseCode": "00000000",
  "responseMessage": "Succeed",
  "data": {
    "pageNo": 1,
    "pageSize": 20,
    "totalCount": 2,
    "totalPage": 1,
    "dataList": [
      {"emailCode":"815645091883520000","version":"V2","versionStatus":1,"modifiedBy":"content.manager","modifiedTime":"2026-07-16 10:00:00"},
      {"emailCode":"815645091883520000","version":"V1","versionStatus":2,"modifiedBy":"content.manager","modifiedTime":"2026-07-16 09:00:00"}
    ]
  }
}
```

**客户端处理与限制**

- QA 已通过本接口确认 `/version/add` 后 V2 Active、V1 Expired。
- v1 History 不提供 LEAD-93 新增 Metadata 的兼容承诺。

## 5. 辅助查询

### V1-S01 Query Object

**接口与场景**

| 项目 | 内容 |
|---|---|
| Endpoint | `POST /iic-dae-msg/web/msg/template/email/v1/queryObject` |
| 当前页面 | 现有模板收件对象相关页面 |
| 当前场景 | 查询可用对象类型/对象数据 |
| Request DTO | 无 |
| Response DTO | `QueryObjectVO` |
| 证据 | `QA 实测`；请求与完整响应已验证 |

**请求参数与示例**

```json
{}
```

**响应字段与最小安全示例**

| 字段 | 类型 | 说明 |
|---|---|---|
| `data.objectCode` | String | QA 已确认 |
| `data` 其他字段 | Mixed | 当前原始脱敏响应未保存，不定义为 LEAD-93 v1 依赖 |

```json
{
  "requestId": "qa-request-id",
  "responseCode": "00000000",
  "responseMessage": "Succeed",
  "data": {
    "objectCode": "EXISTING_OBJECT_CODE"
  }
}
```

**客户端处理与限制**

- 本接口不属于 LEAD-93 修改范围。
- 现有客户端继续按当前实现消费完整 `QueryObjectVO`。

### V1-S02 Recipient List

**接口与场景**

| 项目 | 内容 |
|---|---|
| Endpoint | `POST /iic-dae-msg/web/msg/template/email/v1/recipientList` |
| 当前页面 | 现有收件人选择页面 |
| 当前场景 | 分页查询 Recipient |
| Request DTO | `EmailRecipientDTO` |
| Response DTO | `PageResult<EmailRecipientVO>` |
| 证据 | `QA 实测`；请求、分页和完整响应已验证 |

**请求参数与示例**

| 字段 | 类型 | 必填 | 说明 |
|---|---|---:|---|
| `pageNum` | Integer | 是 | 页码 |
| `pageSize` | Integer | 是 | 页大小 |
| `keyWords` | String | 否 | 搜索关键字 |

```json
{"pageNum":1,"pageSize":20,"keyWords":""}
```

**响应字段与最小安全示例**

| 字段 | 类型 | 说明 |
|---|---|---|
| `data.pageNo/pageSize/totalCount/totalPage` | Integer | 分页 |
| `data.dataList` | `EmailRecipientVO[]` | Recipient 条目 |

```json
{
  "requestId": "qa-request-id",
  "responseCode": "00000000",
  "responseMessage": "Succeed",
  "data": {
    "pageNo": 1,
    "pageSize": 20,
    "totalCount": 0,
    "totalPage": 0,
    "dataList": []
  }
}
```

**客户端处理与限制**

- 本接口不属于 LEAD-93 修改范围。
- 空列表按现有页面行为处理。

## 6. 公共错误处理

### 6.1 成功判断

```javascript
function isV1Success(response) {
  return response.ok && response.body?.responseCode === "00000000";
}
```

HTTP 200 不代表业务成功。所有 v1 调用都必须同时检查 `responseCode`。

### 6.2 已验证业务错误

| 场景 | HTTP | `responseCode` | 处理 |
|---|---:|---|---|
| 删除 Active/Published version | 200 | `10000121` | 显示 Published version 不可删除，不刷新为成功状态 |
| `/version/add` 缺少完整 payload | 200 | `00000001` | 作为业务失败处理；不得进入成功页面 |

JSR-303 Validation 和其他错误由现有 ecommon 全局异常处理。当前 QA 材料没有保存所有正式错误码，因此本文不新增或推测 v1 错误码。

## 7. v1 兼容边界

1. 不给 v1 List、Detail、Save 或 Version 接口增加新的必填 Category、Subcategory、Tag、Metadata 参数。
2. 不把 v1 查询改成依赖新增 Metadata 关系的 INNER JOIN，避免旧模板因没有 Metadata 而消失。
3. 不改变 `IICResponseModel` 包络、现有分页层级和业务成功码。
4. 不改变 Draft、Schedule、Active、Expired 的状态值及现有选版结果。
5. 不要求 Mobile App 解析 v2 新增字段；增强查询、Metadata 和新管理能力仅由 v2 提供。
6. v1 与 v2 读取同一 Template/Version 数据，因此 Publish、Deactivate、Delete 和一次性迁移造成的业务数据变化仍会被两端看到。
7. v1 接口兼容不等于数据静止：App 可以看到名称、描述、启停状态和当前 Active 内容发生正常业务变化。

## 8. QA 回归结果

| 指标 | 结果 |
|---|---:|
| Contract Endpoint | 15/15 已调用 |
| 辅助查询 Endpoint | 2/2 已调用 |
| 顺序场景 | 22/22 完成 |
| HTTP 200 | 22/22 |
| 断言 | 110/110 通过 |
| `00000000` | 21 个场景 |
| 预期约束错误 | 删除 Active version 返回 `10000121` |
| 测试数据清理 | 临时 Template 已软删除 |
| Send Email | 未执行，明确排除 |
| Usage Report | 未执行，明确排除 |

## 9. 证据与可执行材料

- [v1 完整顺序回归 Collection](postman/LEAD-93-v1-full-run.postman_collection.json)
- [v1 全接口 Collection](postman/LEAD-93-v1-as-is-all-apis.postman_collection.json)
- [Postman 使用说明](postman/README.md)
- [Web v2 前端接口约定](LEAD-93_API_Contract_Clarification_CN.md)
