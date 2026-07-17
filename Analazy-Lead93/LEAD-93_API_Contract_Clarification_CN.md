# LEAD-93 Web v2 前端接口约定

> 状态：前端与测试交付基线（存在明确冻结项）
> 日期：2026-07-17
> 需求基线：PRD v1.1（updated July 14th）
> 接口总数：24（复用 v1 不变接口 5、v2 增强接口 10、v2 新增接口 9）

## 1. 阅读说明

本文是前端开发和接口测试的主交付文档，按 Endpoint 组织。每个 Endpoint 只出现一次，并在同一节内包含：

1. 完整 Method + Endpoint；
2. 使用页面和业务场景；
3. 请求参数；
4. 请求 Mock；
5. 响应字段；
6. 成功响应 Mock；
7. 前端处理和主要错误。

| 辅助材料 | 用途 |
|---|---|
| [可执行 HTTP 请求](api-contract/examples/lead93-api.http) | 在 IDE 中直接调用 24 个接口 |
| [本地模拟服务](api-contract/mock/lead93-mock-server.mjs) | 页面并行开发和固定测试数据 |
| [现有 v1 As-Is API 基线](LEAD-93_API_V1_AsIs_CN.md) | Mobile App 与现有 Web 的不可破坏兼容契约 |
| [未确认项登记册](LEAD-93_Open_Questions_Register_CN.md) | 查看待 BA/PO、前后端或真实代码确认的事项 |

### 1.1 状态标记

| 状态 | 前端含义 |
|---|---|
| `可复用` | 继续使用现有接口和现有字段 |
| `可按 Mock 开发` | 业务行为已确定，可先对接 Mock；正式联调时替换待冻结字段 |
| `开发基线` | Method、Path、DTO 和本文定义的行为已冻结，前后端按此实现 |
| `待接口冻结` | Method、Path、字段名或错误码仍是候选，不能生成正式 Client |
| `业务阻塞` | 业务边界未确认，相关页面行为不能定稿 |

### 1.2 公共约定

| 项目 | 约定 |
|---|---|
| 网关前缀 | `/iic-dae-msg` |
| v1 Controller 前缀 | `/web/msg/template/email/v1`；只用于 5 个保持不变接口和现有 App/Web 兼容 |
| v2 Controller 前缀 | `/web/msg/template/email/v2`；承载全部 LEAD-93 增强和新增能力 |
| 响应包络 | 继续使用现有 `IICResponseModel<T>`：`requestId/responseCode/responseMessage/data` |
| 成功业务码 | `responseCode="00000000"`，`responseMessage="Succeed"` |
| 分页 | 请求使用 `pageNum/pageSize`；现有列表响应使用 `pageNo/pageSize/totalCount/totalPage/dataList` |
| 时间格式 | `yyyy-MM-dd HH:mm:ss`；统一按南非业务时区 `Africa/Johannesburg`（UTC+02:00）解释 |
| 64 位 ID | `emailCode`、Category ID 等在前端统一使用 String |
| 权限 | 沿用现有登录态；后端强制 Content Manager 写权限和 Adviser 数据范围 |
| Mock 包络 | Mock 与真实 v1 使用同一包络字段；新增接口使用第 7 章稳定错误键，现有 Version Conflict/HTTP Status 仍待 `API-02/API-03` |

现有 QA 调用已确认需要以下应用请求头。环境级路由前缀由网关自动维护，不进入本接口契约。

| Header | 要求 | 说明 |
|---|---|---|
| `authorization` | 必传 | 沿用现有 Bearer 登录态 |
| `x-apigw-api-id` | 必传 | 由环境配置提供 |
| `content-type` | 必传 | `application/json` |
| `language` | 必传 | 当前 QA 确认为 `en-US` |
| `requestid` | 必传 | 每次请求使用新的短唯一值 |

2026-07-16 QA 回归已验证全部 15 个现有 Contract Endpoint 的可达性、v1 包络、请求与响应字段和所覆盖业务结果，并额外验证了 2 个辅助查询接口。`data` 内新增 Category/Subcategory/Tag Metadata 仍属于 To-Be Contract，不应被解释为现网 v1 已经包含这些字段。

### 1.3 API 版本路由

| 类型 | Endpoint ID | 版本策略 |
|---|---|---|
| 保持不变 | `EX-06`、`EX-07`、`EX-12`、`EX-14`、`EX-15` | 继续调用 v1，不复制到 v2 |
| 增强现有能力 | `EX-01`—`EX-05`、`EX-08`—`EX-11`、`EX-13` | 使用 v2；v1 保持原请求与响应行为 |
| 新增能力 | `NEW-01`—`NEW-09` | 仅提供 v2 |

Web 新页面可以混合调用 v1 和 v2；Mobile App 继续使用现有 v1。v1/v2 共享底层 Template/Version 数据，因此 Publish、Deactivate 和数据迁移造成的业务数据变化仍会跨端可见。

当前 24 个接口不包含范围尚未确认的 Copy and Create。当前方向是复制选中版本的基本信息和版本内容并创建新的 Template；若最终确认需要后端承载，则新增 v2 API。`COPY-01` 关闭前不冻结 Endpoint/DTO，也不把它与 `/version/add` 或同一 Template 的 Working Copy 流程关联。

### 1.4 Endpoint 目录

| 分类 | Endpoint ID |
|---|---|
| 模板查询与详情 | [EX-01](#ex-01-published-list)、[EX-02](#ex-02-draftadmin-list)、[EX-03](#ex-03-admin-template-detail)、[EX-04](#ex-04-adviser-published-detail)、[EX-15](#ex-15-channel-list) |
| 模板保存与生命周期 | [EX-05](#ex-05-save-draft--publish--schedule)、[EX-06](#ex-06-update-template-master-fields)、[EX-07](#ex-07-change-status)、[EX-08](#ex-08-delete-template) |
| 版本管理 | [EX-09](#ex-09-add-version)、[EX-10](#ex-10-update-version)、[EX-11](#ex-11-delete-version)、[EX-12](#ex-12-get-max-version)、[EX-13](#ex-13-version-detail)、[EX-14](#ex-14-version-history) |
| 分类管理 | [NEW-01](#new-01-category-tree)、[NEW-02](#new-02-create-category)、[NEW-03](#new-03-update-categorysubcategory)、[NEW-04](#new-04-reassign-and-delete)、[NEW-05](#new-05-reorder-category)、[NEW-08](#new-08-batch-create-subcategories)、[NEW-09](#new-09-category-delete-impact) |
| 标签与版本元数据 | [NEW-06](#new-06-tag-taxonomy)、[NEW-07](#new-07-update-version-metadata) |

## 2. 模板查询与详情

### EX-01 Published List

**接口与场景**

| 项目 | 内容 |
|---|---|
| Endpoint | `POST /iic-dae-msg/web/msg/template/email/v2/queryList` |
| 页面 | `UI-03` Template Library、`UI-07` Adviser 列表 |
| 场景 | 打开 Published 页签；搜索/筛选已发布模板；Adviser 查询可用模板 |
| 本期变化 | 增加 Email/Campaign、Category、Subcategory、Tag Filter；不再硬编码排除 Campaign |
| 状态 | `开发基线`；现有请求与响应字段已经 QA 实测确认 |

**页面参考**

[查看 UI-A-01 Template Library 页面与接口地图](#ui-a-01)

**请求参数**

| 字段 | 类型 | 必填 | 说明 |
|---|---|---:|---|
| `isCampaign` | Integer | 是 | `0=Email, 1=Campaign` |
| `emailName` | String | 否 | 关键字；匹配模板名称、描述、标签名称 |
| `categoryId` | String | 否 | 主分类，单选 |
| `subcategoryIds` | String[] | 否 | 子分类，多选 |
| `tagGroups` | Object[] | 否 | `{groupCode, tagCodes[]}`；同组 OR、跨组 AND |
| `channelList` | String[] | 否 | 沿用现有 Channel Filter |
| `pageNum` | Integer | 是 | 默认 1 |
| `pageSize` | Integer | 是 | 当前 Web 请求使用 20；后端未传默认值仍按现有实现 |
| `sortField` | String | 否 | 默认 `updatedDate` |
| `isAsc` | Boolean | 否 | 默认 `false` |

**请求 Mock**

```json
{
  "isCampaign": 0,
  "emailName": "retirement",
  "categoryId": "1001",
  "subcategoryIds": ["1101"],
  "tagGroups": [{"groupCode": "CONTENT_TYPE", "tagCodes": ["EMAIL"]}],
  "channelList": [],
  "pageNum": 1,
  "pageSize": 20,
  "sortField": "updatedDate",
  "isAsc": false
}
```

**响应字段**

| 字段 | 类型 | 说明 |
|---|---|---|
| `data.pageNo/pageSize/totalCount/totalPage` | Integer | 现有分页信息 |
| `data.dataList[].emailCode` | String | 模板唯一业务标识 |
| `data.dataList[].emailName` | String | 模板名称 |
| `data.dataList[].description` | String/null | 描述 |
| `data.dataList[].version` | String | 当前 Active version |
| `data.dataList[].emailStatus` | String | `1=Active` |
| `data.dataList[].versionStatus` | Integer | 固定为 `1=Active` |
| `data.dataList[].isCampaign` | Integer | Email/Campaign 类型 |
| `data.dataList[].category` | Object/null | 当前 Active 主分类 |
| `data.dataList[].subcategories` | Object[] | 当前 Active 子分类 |
| `data.dataList[].tagGroups` | Object[] | 当前 Active 标签 |
| `data.dataList[].modifiedTime` | DateTime | 修改时间 |

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
      "description": "Invitation for the annual retirement review",
      "version": "V1",
      "emailStatus": "1",
      "versionStatus": 1,
      "isCampaign": 0,
      "category": {"categoryId": "1001", "categoryName": "Client Engagement"},
      "subcategories": [{"categoryId": "1101", "categoryName": "Advice Review"}],
      "tagGroups": [{"groupCode": "CONTENT_TYPE", "tagCodes": ["EMAIL"]}],
      "modifiedTime": "2026-07-16 09:00:00"
    }]
  }
}
```

**前端处理与错误**

- Published 页签不显示或提交 Status Filter。
- `isCampaign` 缺失/非法时不执行无类型全量查询。
- 空结果显示现有 Empty State；分页和排序继续沿用现有页面行为。

### EX-02 Draft/Admin List

**接口与场景**

| 项目 | 内容 |
|---|---|
| Endpoint | `POST /iic-dae-msg/web/msg/template/email/v2/templateList` |
| 页面 | `UI-03` Template Library Draft/Admin 页签 |
| 场景 | 打开 Draft/Admin 页签；搜索/筛选 Draft、Schedule 或管理态模板 |
| 本期变化 | 增加 Email/Campaign、Category、Subcategory、Tag、Keyword Filter |
| 状态 | `开发基线`；现有请求与响应字段已经 QA 实测确认 |

**页面参考**

[查看 UI-A-02 Draft/Admin Template 列表](#ui-a-02)

**请求参数**

| 字段 | 类型 | 必填 | 说明 |
|---|---|---:|---|
| `isCampaign` | Integer | 是 | `0=Email, 1=Campaign` |
| `keyWords` | String | 否 | 匹配模板名称、描述、标签名称 |
| `templateStatus` | String | 否 | 沿用现有状态编码；已验证 Web 请求值为 `"1"`，完整映射由现有前端常量维护 |
| `categoryId` | String | 否 | 主分类 |
| `subcategoryIds` | String[] | 否 | 子分类，多选 |
| `tagGroups` | Object[] | 否 | 标签筛选 |
| `channelList` | String[] | 否 | 沿用现有 Channel Filter |
| `emailStatusList` | String[] | 否 | 沿用现有启停状态 Filter |
| `pageNum/pageSize` | Integer | 是 | 当前 Web 请求使用 `1/20` |
| `sortField/isAsc` | String/Boolean | 否 | 默认 `updatedDate/false` |

**请求 Mock**

```json
{
  "isCampaign": 0,
  "keyWords": "retirement",
  "templateStatus": "1",
  "categoryId": "1001",
  "subcategoryIds": ["1101"],
  "tagGroups": [{"groupCode": "LIFECYCLE_STAGE", "tagCodes": ["RETIREMENT"]}],
  "pageNum": 1,
  "pageSize": 20,
  "channelList": [],
  "emailStatusList": [],
  "sortField": "updatedDate",
  "isAsc": false
}
```

**响应字段**

返回分页 `TemplateSummary`，现有分页层级为 `data.pageNo/pageSize/totalCount/totalPage/dataList`；同一 `emailCode` 只返回最大数字版本 V(N)，不会按字符串字典序选版。To-Be 在 `dataList[]` 元素中增加目标版本 Metadata。

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
      "description": "",
      "version": "V2",
      "emailStatus": "1",
      "versionStatus": 3,
      "isCampaign": 0,
      "category": null,
      "subcategories": [],
      "tagGroups": [],
      "modifiedTime": "2026-07-16 09:30:00"
    }]
  }
}
```

**前端处理与错误**

- 保持现有 Draft 三分支语义，不由前端拼接状态条件。
- Search/Filter 应作用于后端已选择的结果版本。
- 若页面允许 Email/Campaign 切换，切换后重新查询，不合并两种类型的数据。

### EX-03 Admin Template Detail

**接口与场景**

| 项目 | 内容 |
|---|---|
| Endpoint | `POST /iic-dae-msg/web/msg/template/email/v2/detail` |
| 页面 | `UI-04` 创建与编辑、`UI-05` Detail/Preview |
| 场景 | 打开管理端模板详情；编辑 Draft/Schedule；Preview 前加载已保存内容 |
| 本期变化 | 返回所选 version 的 Category、Subcategory、Tag |
| 状态 | `开发基线`；现有 `EmailDetailDTO` 请求与响应已经 QA 实测确认 |

**页面参考**

[查看 UI-A-03 Template Detail/Preview](#ui-a-03)

**请求参数**

| 字段 | 类型 | 必填 | 说明 |
|---|---|---:|---|
| `emailCode` | String | 是 | 模板业务标识 |
| `version` | String | 条件必填 | 编辑明确 version 时必须传；不传时沿用现有选版规则 |

**请求 Mock**

```json
{"emailCode": "815645091883520000", "version": "V2"}
```

**响应字段**

| 字段 | 类型 | 说明 |
|---|---|---|
| `emailCode/emailName/description` | String | 模板标识和基本信息 |
| `version/versionStatus/emailStatus` | String/Integer | 版本和状态 |
| `title` | String/null | Email Subject |
| `emailContent/emailContentKey` | String | 加密正文和 Key |
| `textContent` | String/null | 纯文本正文 |
| `fileKeys/fileInfos` | String/Array | 附件 |
| `isCampaign/isCustomBranding` | Integer/String | 类型和 Branding |
| `effectiveFrom/effectiveUntil` | DateTime/null | 生效时间 |
| `category/subcategories/tagGroups` | Object/Array | 目标 version Metadata |

**成功响应 Mock**

```json
{
  "requestId": "mock-request-id",
  "responseCode": "00000000",
  "responseMessage": "Succeed",
  "data": {
    "emailCode": "815645091883520000",
    "emailName": "Retirement review invitation - working copy",
    "description": "",
    "version": "V2",
    "versionStatus": 3,
    "emailStatus": "1",
    "title": "Your retirement review",
    "emailContent": "MOCK_AES_CONTENT",
    "emailContentKey": "MOCK_AES_KEY",
    "textContent": "Your retirement review",
    "fileKeys": "",
    "fileInfos": [],
    "isCampaign": 0,
    "isCustomBranding": "0",
    "effectiveFrom": "2026-08-01 09:00:00",
    "effectiveUntil": null,
    "category": null,
    "subcategories": [],
    "tagGroups": []
  }
}
```

**前端处理与错误**

- 编辑 Draft/Schedule/指定历史版本时必须显式传 `version`，不能依赖自动选版。
- 目标 version 不存在或已软删除时提示刷新，不尝试改查其他 version。
- Preview 只展示正文和 Metadata，不展示附件，也不新增 Preview API。

### EX-04 Adviser Published Detail

**接口与场景**

| 项目 | 内容 |
|---|---|
| Endpoint | `POST /iic-dae-msg/web/msg/template/email/v2/published/detail` |
| 页面 | `UI-07` Adviser Published Template |
| 场景 | Adviser 打开可用模板详情 |
| 本期变化 | 返回当前 Active version 的 Category、Subcategory、Tag |
| 状态 | `可按 Mock 开发`；PRD v1.1 未提供新的 Adviser 页面原型 |

**请求参数与 Mock**

| 字段 | 类型 | 必填 | 说明 |
|---|---|---:|---|
| `emailCode` | String | 是 | 模板业务标识 |

```json
{"emailCode": "815645091883520000"}
```

**响应字段**

与 `EX-03` 相同，但后端强制返回 Adviser 可访问的当前 Active version，不允许前端指定 Draft/Schedule。

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
    "isCampaign": 0,
    "category": {"categoryId": "1001", "categoryName": "Client Engagement"},
    "subcategories": [{"categoryId": "1101", "categoryName": "Advice Review"}],
    "tagGroups": [{"groupCode": "CONTENT_TYPE", "tagCodes": ["EMAIL"]}]
  }
}
```

**前端处理与错误**

- 无权限、Inactive、已删除或没有 Active version 时不展示内容。
- 前端不得通过修改请求参数绕过 Published-only 规则。

### EX-15 Channel List

**接口与场景**

| 项目 | 内容 |
|---|---|
| Endpoint | `POST /iic-dae-msg/web/msg/template/email/v1/channelList` |
| 页面 | `UI-04` 模板创建/编辑、`UI-07` Adviser 页面 |
| 场景 | 加载 Channel 下拉选项 |
| 本期变化 | 无 |
| 状态 | `可复用` |

**请求参数与 Mock**

无业务参数。

```json
{}
```

**响应字段与 Mock**

| 字段 | 类型 | 说明 |
|---|---|---|
| `data[].channel` | String | Channel 编码 |
| `data[].channelName` | String | 显示名称 |

```json
{
  "requestId": "mock-request-id",
  "responseCode": "00000000",
  "responseMessage": "Succeed",
  "data": [
    {"channel": "EMAIL", "channelName": "Email"},
    {"channel": "CAMPAIGN", "channelName": "Campaign"}
  ]
}
```

**前端处理与错误**

- 沿用现有缓存、空状态和错误提示，不为 LEAD-93 新增特殊处理。

## 3. 模板保存与生命周期

### EX-05 Save Draft / Publish / Schedule

**接口与场景**

| 项目 | 内容 |
|---|---|
| Endpoint | `POST /iic-dae-msg/web/msg/template/email/v2/add` |
| 页面 | `UI-04` 模板创建与编辑 |
| 场景 | 首次/再次保存草稿；立即发布；预约发布；通过 Save Draft 取消预约 |
| 本期变化 | 同一请求保存目标 version 的 Category/Subcategory/Tag；Publish 增加完整校验 |
| 状态 | `可按 Mock 开发`；现有 DTO 已确认，基本信息版本归属仍待 `REQ-01/02` |

**页面参考**

[查看 UI-A-04 Template 创建与编辑](#ui-a-04)

**场景参数**

| 场景 | 关键参数 | 结果 |
|---|---|---|
| Save Draft | `isDraft="1"` | 始终保存为 Draft；未来时间不会生成 Schedule |
| Publish Now | `isDraft="2", effectiveWay=0` | 目标 Draft 变 Active；旧 Active 变 Expired |
| Schedule Publish | `isDraft="2", effectiveWay=1, effectiveFrom>now` | 目标 Draft 变 Schedule |
| Cancel Schedule | Schedule version 调用 `isDraft="1"` | 同一版本 `0 -> 3`，保留已保存时间 |

**请求参数**

| 字段 | 类型 | Draft | Publish | 说明 |
|---|---|---:|---:|---|
| `emailCode` | String | 条件 | 条件 | 首次 Save Draft 不传；后端 Snowflake 生成 |
| `version` | String | 条件 | 是 | 编辑已有 version 时传 |
| `emailName` | String | 是 | 是 | Template Title；最终版本归属待 `REQ-01/02` |
| `description` | String/null | 否 | 是 | 描述 |
| `isCampaign` | Integer | 是 | 是 | `0=Email, 1=Campaign` |
| `title` | String/null | 否 | 是 | Email Subject |
| `emailContent` | String | 是 | 是 | AES 加密正文 |
| `emailContentKey` | String/null | 否 | 条件 | AES Key |
| `textContent` | String/null | 否 | 否 | 纯文本正文 |
| `fileKeys` | String/null | 否 | 否 | 附件 Key，逗号分隔 |
| `isDraft` | String | 是 | 是 | `"1"=Draft, "2"=Publish` |
| `effectiveWay` | Integer | 否 | 是 | `0=Now, 1=Schedule` |
| `effectiveFrom` | DateTime/null | 否 | Schedule 必填 | Draft 可暂存；按 `Africa/Johannesburg`（UTC+02:00）解释 |
| `effectiveUntil` | DateTime/null | 否 | 否 | Draft 可暂存 |
| `categoryId` | String/null | 否 | 是 | 主分类 |
| `subcategoryIds` | String[] | 否 | 是 | Publish 至少一项 |
| `tagGroups` | Object[] | 否 | 是 | 完整 6 个 Tag Group 快照 |
| `moduleCode/moduleCodeName/scenarioCode` | String | 沿用现状 | 沿用现状 | 现有字段 |
| `editMode/thumbnailKey/channelMap` | Mixed | 沿用现状 | 沿用现状 | 现有字段 |
| `isCustomBranding` | String | 是 | 是 | `0/1` |

**请求 Mock：Save Draft**

```json
{
  "emailCode": "815645091883520000",
  "version": "V2",
  "moduleCode": "COMMUNICATION",
  "moduleCodeName": "Communications",
  "scenarioCode": "TEMPLATE_LIBRARY",
  "emailName": "Retirement review invitation",
  "description": "",
  "isCampaign": 0,
  "title": "Your retirement review",
  "editMode": "HTML",
  "emailContent": "MOCK_AES_CONTENT",
  "emailContentKey": "MOCK_AES_KEY",
  "textContent": "Your retirement review",
  "fileKeys": "",
  "isDraft": "1",
  "effectiveWay": 1,
  "effectiveFrom": "2026-08-01 09:00:00",
  "effectiveUntil": null,
  "thumbnailKey": null,
  "channelMap": {},
  "isCustomBranding": "0",
  "categoryId": null,
  "subcategoryIds": [],
  "tagGroups": []
}
```

**请求 Mock：Publish Now**

```json
{
  "emailCode": "815645091883520000",
  "version": "V2",
  "moduleCode": "COMMUNICATION",
  "moduleCodeName": "Communications",
  "scenarioCode": "TEMPLATE_LIBRARY",
  "emailName": "Retirement review invitation",
  "description": "Invitation for the annual retirement review",
  "isCampaign": 0,
  "title": "Your retirement review",
  "editMode": "HTML",
  "emailContent": "MOCK_AES_CONTENT",
  "emailContentKey": "MOCK_AES_KEY",
  "textContent": "Your retirement review",
  "fileKeys": "",
  "isDraft": "2",
  "effectiveWay": 0,
  "effectiveFrom": null,
  "effectiveUntil": null,
  "thumbnailKey": null,
  "channelMap": {},
  "isCustomBranding": "0",
  "categoryId": "1001",
  "subcategoryIds": ["1101"],
  "tagGroups": [
    {"groupCode": "CONTENT_TYPE", "tagCodes": ["EMAIL"]},
    {"groupCode": "TRIGGER", "tagCodes": ["MANUAL"]},
    {"groupCode": "LIFECYCLE_STAGE", "tagCodes": ["RETIREMENT"]},
    {"groupCode": "FINANCIAL_NEED", "tagCodes": ["RETIREMENT_PLANNING"]},
    {"groupCode": "PROPOSITION", "tagCodes": []},
    {"groupCode": "SOURCE", "tagCodes": []}
  ]
}
```

**请求 Mock：Schedule Publish**

```json
{
  "emailCode": "815645091883520000",
  "version": "V2",
  "moduleCode": "COMMUNICATION",
  "moduleCodeName": "Communications",
  "scenarioCode": "TEMPLATE_LIBRARY",
  "emailName": "Retirement review invitation",
  "description": "Invitation for the annual retirement review",
  "isCampaign": 0,
  "title": "Your retirement review",
  "editMode": "HTML",
  "emailContent": "MOCK_AES_CONTENT",
  "emailContentKey": "MOCK_AES_KEY",
  "textContent": "Your retirement review",
  "fileKeys": "",
  "isDraft": "2",
  "effectiveWay": 1,
  "effectiveFrom": "2026-08-01 09:00:00",
  "effectiveUntil": null,
  "thumbnailKey": null,
  "channelMap": {},
  "isCustomBranding": "0",
  "categoryId": "1001",
  "subcategoryIds": ["1101"],
  "tagGroups": [
    {"groupCode": "CONTENT_TYPE", "tagCodes": ["EMAIL"]},
    {"groupCode": "TRIGGER", "tagCodes": ["MANUAL"]},
    {"groupCode": "LIFECYCLE_STAGE", "tagCodes": ["RETIREMENT"]},
    {"groupCode": "FINANCIAL_NEED", "tagCodes": ["RETIREMENT_PLANNING"]},
    {"groupCode": "PROPOSITION", "tagCodes": []},
    {"groupCode": "SOURCE", "tagCodes": []}
  ]
}
```

**响应字段**

| 字段 | 类型 | 说明 |
|---|---|---|
| `data.emailCode` | String | 首次保存时返回新生成的业务 ID |
| `data.version` | String | 实际保存的 version |
| `data.versionStatus` | Integer | `0=Schedule, 1=Active, 3=Draft` |
| `data.emailStatus` | String | Template 启停状态 |
| `data.effectiveFrom/effectiveUntil` | DateTime/null | 实际保存时间 |

**成功响应 Mock：Save Draft**

```json
{
  "requestId": "mock-request-id",
  "responseCode": "00000000",
  "responseMessage": "Succeed",
  "data": {
    "emailCode": "815645091883520000",
    "version": "V2",
    "versionStatus": 3,
    "emailStatus": "1",
    "effectiveFrom": "2026-08-01 09:00:00",
    "effectiveUntil": null
  }
}
```

**成功响应 Mock：Publish Now**

```json
{
  "requestId": "mock-request-id",
  "responseCode": "00000000",
  "responseMessage": "Succeed",
  "data": {
    "emailCode": "815645091883520000",
    "version": "V2",
    "versionStatus": 1,
    "emailStatus": "1",
    "effectiveFrom": "2026-07-16 10:00:00",
    "effectiveUntil": null
  }
}
```

**成功响应 Mock：Schedule Publish**

```json
{
  "requestId": "mock-request-id",
  "responseCode": "00000000",
  "responseMessage": "Succeed",
  "data": {
    "emailCode": "815645091883520000",
    "version": "V2",
    "versionStatus": 0,
    "emailStatus": "1",
    "effectiveFrom": "2026-08-01 09:00:00",
    "effectiveUntil": null
  }
}
```

**前端处理与错误**

- Published Validation 失败时保留 Draft 和旧 Active，并显示字段级错误。
- 历史 Template 重新 Publish 时也执行全部必填校验。
- Save Draft 的版本分支：新建 V1 Insert；已有 Draft Update；Active 无 Draft 时 Insert V(N+1)；仅 Expired 时 Update V(N)；Schedule 时 Update 同一 V(N) 为 Draft。
- 附件可选；单个最大 10 MB；前端沿用现有格式校验并排除多媒体、音频和视频。

### EX-06 Update Template Master Fields

**接口与场景**

| 项目 | 内容 |
|---|---|
| Endpoint | `POST /iic-dae-msg/web/msg/template/email/v1/update` |
| 页面 | `UI-04` Basic Information |
| 场景 | 保存模板主记录基本信息 |
| 本期变化 | 当前方案保持现状；站会提出基本信息进入版本层 |
| 状态 | `业务阻塞`：依赖 `REQ-01/REQ-02` |

**请求参数**

| 字段 | 类型 | 必填 | 说明 |
|---|---|---:|---|
| `emailCode` | String | 是 | 模板标识 |
| `emailName` | String | 是 | 当前 Template Name |
| `description` | String/null | 否 | 当前 Description |
| `isCampaign` | Integer | 是 | 当前 Email/Campaign 类型 |

**请求 Mock**

```json
{
  "emailCode": "815645091883520000",
  "emailName": "Retirement review invitation",
  "description": "Invitation for the annual retirement review",
  "isCampaign": 0
}
```

**响应字段与 Mock**

成功时 `data=null`。

```json
{"requestId": "mock-request-id", "responseCode": "00000000", "responseMessage": "Succeed", "data": null}
```

**前端处理与错误**

- `REQ-01/REQ-02` 未关闭前，不定稿本接口与 `EX-05/EX-10` 的字段分工。
- 当前可以继续复用现有页面调用，但新增字段不得默认写入主表。

### EX-07 Change Status

**接口与场景**

| 项目 | 内容 |
|---|---|
| Endpoint | `POST /iic-dae-msg/web/msg/template/email/v1/changeStatus` |
| 页面 | `UI-03` Template Library |
| 场景 | Deactivate；Active/Reactivate |
| 本期变化 | 无 |
| 状态 | `可复用` |

**请求参数与 Mock**

| 字段 | 类型 | 必填 | 说明 |
|---|---|---:|---|
| `emailCode` | String | 是 | 模板标识 |
| `emailStatus` | String | 是 | `0=Inactive, 1=Active` |
| 其他现有字段 | Mixed | 按现状 | 保持 `TemplateStatusChangeBO` |

```json
{"emailCode": "815645091883520000", "emailStatus": "0"}
```

**响应字段与 Mock**

```json
{"requestId": "mock-request-id", "responseCode": "00000000", "responseMessage": "Succeed", "data": null}
```

**前端处理与错误**

- Deactivate 只修改 `config.email_status`，不修改 config.status 或任何 `versionStatus`。
- Reactivate 恢复原 Active 内容，不重新执行 Publish。
- 重复点击的幂等表现沿用现有接口。

### EX-08 Delete Template

**接口与场景**

| 项目 | 内容 |
|---|---|
| Endpoint | `POST /iic-dae-msg/web/msg/template/email/v2/delete` |
| 页面 | `UI-03` Draft Delete |
| 场景 | 删除 Draft Template |
| 本期变化 | 同步软删除所有 version 的 Subcategory/Tag relations |
| 状态 | `开发基线`；现有删除请求与响应已经 QA 实测确认 |

**页面参考**

[查看 UI-A-05 Template Delete](#ui-a-05)

**请求参数与 Mock**

| 字段 | 类型 | 必填 | 说明 |
|---|---|---:|---|
| `emailCode` | String | 是 | 模板标识 |

```json
{"emailCode": "815645091883520000"}
```

**响应字段与 Mock**

```json
{"requestId": "mock-request-id", "responseCode": "00000000", "responseMessage": "Succeed", "data": null}
```

**前端处理与错误**

- Delete 是级联软删除：更新 config.status、所有 version.status 及其 Metadata relations。
- 不修改任何 version 的 `versionStatus`。
- 成功后从列表移除，详情页返回列表；不清理 S3 附件。

## 4. 版本管理

### EX-09 Add Version

**接口与场景**

| 项目 | 内容 |
|---|---|
| Endpoint | `POST /iic-dae-msg/web/msg/template/email/v2/version/add` |
| 页面 | 现有增加版本流程 |
| As-Is 实测 | 在 v1 `/version/add` 提交目标 `version="V2"` 的完整 payload 后，V2 成为 Active、V1 变为 Expired |
| 本期变化 | 增加版本时同时保存目标版本 Category/Subcategory/Tag，并执行 Published Validation |
| 状态 | `开发基线`；现有请求、响应和状态结果已经 QA 实测确认 |

**页面参考**

[查看 UI-A-06 Version History](#ui-a-06)

**请求参数与 Mock**

| 字段 | 类型 | 必填 | 说明 |
|---|---|---:|---|
| `emailCode` | String | 是 | 模板标识 |
| `version` | String | 是 | 实测新增目标版本传 `V2`，不是源 Active version `V1` |
| 版本正文和时间字段 | Mixed | 是/条件 | 实测成功请求包含完整 Version payload |

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
  "isCustomBranding": "0",
  "categoryId": "1001",
  "subcategoryIds": ["1101"],
  "tagGroups": [
    {"groupCode": "CONTENT_TYPE", "tagCodes": ["EMAIL"]},
    {"groupCode": "TRIGGER", "tagCodes": ["MANUAL"]},
    {"groupCode": "LIFECYCLE_STAGE", "tagCodes": ["RETIREMENT"]},
    {"groupCode": "FINANCIAL_NEED", "tagCodes": ["RETIREMENT_PLANNING"]},
    {"groupCode": "PROPOSITION", "tagCodes": []},
    {"groupCode": "SOURCE", "tagCodes": []}
  ]
}
```

**响应字段与 Mock**

| 字段 | 类型 | 说明 |
|---|---|---|
| `requestId/responseCode/responseMessage` | String | 包络和成功码已确认 |
| `data.emailCode/version/versionStatus` | String/String/Integer | 新增版本的标识、版本号和最终状态 |

```json
{
  "requestId": "mock-request-id",
  "responseCode": "00000000",
  "responseMessage": "Succeed",
  "data": {"emailCode": "815645091883520000", "version": "V2", "versionStatus": 1}
}
```

后续通过 `getMaxVersion`、Version Detail 和 Version History 验证到的业务结果是：V2 为 Active (`1`)，V1 为 Expired (`2`)。

**前端处理与错误**

- 本接口只表达“增加版本并切换 Active”的现有语义，不承担范围尚未确认的 Copy and Create。
- 新版本正文、Metadata、Published Validation 和状态切换必须在同一事务中完成。

### EX-10 Update Version

**接口与场景**

| 项目 | 内容 |
|---|---|
| Endpoint | `POST /iic-dae-msg/web/msg/template/email/v2/version/update` |
| 页面 | `UI-04` 模板编辑 |
| 场景 | 更新已有 Draft/Schedule version 内容和 Metadata |
| 本期变化 | 增加 version Metadata 原子保存和 Publish Validation |
| 状态 | `开发基线`；现有请求与响应字段已经 QA 实测确认 |

**请求参数**

| 字段 | 类型 | 必填 | 说明 |
|---|---|---:|---|
| `emailCode` | String | 是 | 模板标识 |
| `version` | String | 是 | 目标 version |
| `title/emailContent/emailContentKey` | String | 条件 | 版本正文相关字段 |
| `effectiveFrom/effectiveUntil` | DateTime/null | 否 | Draft/Schedule 已保存时间 |
| `categoryId` | String/null | 否 | 主分类 |
| `subcategoryIds` | String[] | 是 | 完整快照，可空数组 |
| `tagGroups` | Object[] | 是 | 必须提交完整 6 组快照；字段缺失或缺少任一 Group 均为非法请求 |
| 其他 Version Add 字段 | Mixed | 按现状 | 现有字段透传 |

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
  "isCustomBranding": "0",
  "categoryId": "1001",
  "subcategoryIds": ["1101"],
  "tagGroups": [
    {"groupCode": "CONTENT_TYPE", "tagCodes": ["EMAIL"]},
    {"groupCode": "TRIGGER", "tagCodes": ["MANUAL"]},
    {"groupCode": "LIFECYCLE_STAGE", "tagCodes": ["RETIREMENT"]},
    {"groupCode": "FINANCIAL_NEED", "tagCodes": ["RETIREMENT_PLANNING"]},
    {"groupCode": "PROPOSITION", "tagCodes": []},
    {"groupCode": "SOURCE", "tagCodes": []}
  ]
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

**前端处理与错误**

- version 内容、`categoryId`、Subcategory relations 和 Tag relations 必须同成同败。
- 后端 Update 影响 0 行时返回失败；前端提示刷新，不显示保存成功。
- Schedule 期间保存草稿会把同一 version 更新为 Draft；不创建新 version。

### EX-11 Delete Version

**接口与场景**

| 项目 | 内容 |
|---|---|
| Endpoint | `POST /iic-dae-msg/web/msg/template/email/v2/version/delete` |
| 页面 | `UI-04` 编辑页 |
| 场景 | Discard 已保存 Working Copy；删除 Draft/Schedule version；Cancel Schedule by Delete |
| 本期变化 | 同步软删除目标 version 的 Metadata relations |
| 状态 | `开发基线`；Draft/Schedule 删除成功与 Active 删除拒绝均已 QA 实测确认 |

**请求参数与 Mock**

| 字段 | 类型 | 必填 | 说明 |
|---|---|---:|---|
| `emailCode` | String | 是 | 模板标识 |
| `version` | String | 是 | 目标 Draft/Schedule version |

```json
{"emailCode": "815645091883520000", "version": "V2"}
```

**响应字段与 Mock**

```json
{"requestId": "mock-request-id", "responseCode": "00000000", "responseMessage": "Succeed", "data": null}
```

**前端处理与错误**

- 未保存的编辑离开页面时不调用本接口。
- 已保存 Working Copy 的 Discard 调用本接口并软删除 Draft。
- 删除 Active/Published version 时，As-Is 返回 HTTP 200、`responseCode="10000121"`、`responseMessage="Operation failed. The version has been published."`；前端必须按业务码判定失败。
- 成功后回到列表；附件仍保留在 S3，不执行清理。

### EX-12 Get Max Version

**接口与场景**

| 项目 | 内容 |
|---|---|
| Endpoint | `GET /iic-dae-msg/web/msg/template/email/v1/version/getMaxVersion?emailCode={emailCode}` |
| 页面 | `UI-04` 编辑、`UI-06` Version History |
| 场景 | 获取模板的最大数字版本 |
| 本期变化 | 无 |
| 状态 | `可复用` |

**请求参数**

| 位置 | 字段 | 类型 | 必填 |
|---|---|---|---:|
| Query | `emailCode` | String | 是 |

请求示例：

```text
GET /iic-dae-msg/web/msg/template/email/v1/version/getMaxVersion?emailCode=815645091883520000
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

**前端处理与错误**

- 后端必须按版本数字比较，不能按 `V10 < V2` 的字符串顺序。
- 不存在 version 时沿用现有空响应/错误行为。

### EX-13 Version Detail

**接口与场景**

| 项目 | 内容 |
|---|---|
| Endpoint | `POST /iic-dae-msg/web/msg/template/email/v2/version/detail` |
| 页面 | `UI-04` 编辑、`UI-06` Version History |
| 场景 | 加载明确指定的版本内容 |
| 本期变化 | 返回指定 version 的 Category/Subcategory/Tag |
| 状态 | `可按 Mock 开发`；历史字段范围依赖 `REQ-03/04` |

**请求参数与 Mock**

| 字段 | 类型 | 必填 | 说明 |
|---|---|---:|---|
| `emailCode` | String | 是 | 模板标识 |
| `version` | String | 是 | 目标 version；不得自动改选 |

```json
{"emailCode": "815645091883520000", "version": "V1"}
```

**响应字段**

返回指定 version 的现有 Version Detail 全字段，并增加：

| 字段 | 类型 | 说明 |
|---|---|---|
| `data.category` | Object/null | 主分类 |
| `data.subcategories` | Object[] | 子分类 |
| `data.tagGroups` | Object[] | 标签 |

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
    "fileKeys": "",
    "category": {"categoryId": "1001", "categoryName": "Client Engagement"},
    "subcategories": [{"categoryId": "1101", "categoryName": "Advice Review"}],
    "tagGroups": [{"groupCode": "CONTENT_TYPE", "tagCodes": ["EMAIL"]}]
  }
}
```

**前端处理与错误**

- version 不存在或已软删除时提示刷新，不回退查询其他 version。
- 当前基线不要求通过本接口展示所有 Expired Metadata；最终范围依赖 `REQ-03/04`。

### EX-14 Version History

**接口与场景**

| 项目 | 内容 |
|---|---|
| Endpoint | `POST /iic-dae-msg/web/msg/template/email/v1/version/list/history` |
| 页面 | `UI-06` Version History |
| 场景 | 加载版本历史分页列表 |
| 本期变化 | 当前基线保持现状 |
| 状态 | `业务阻塞`：是否展示历史基本信息/Metadata 依赖 `REQ-03/04` |

**页面参考**

[查看 UI-A-06 Version History](#ui-a-06)

**请求参数与 Mock**

| 字段 | 类型 | 必填 | 说明 |
|---|---|---:|---|
| `emailCode` | String | 是 | 模板标识 |
| `pageNum/pageSize` | Integer | 是 | 分页 |
| `sortField/isAsc` | String/Boolean | 否 | 沿用现有排序 |

```json
{
  "emailCode": "815645091883520000",
  "pageNum": 1,
  "pageSize": 20,
  "sortField": "version",
  "isAsc": false
}
```

**响应字段与 Mock**

| 字段 | 类型 | 说明 |
|---|---|---|
| `data.pageNo/pageSize/totalCount/totalPage` | Integer | 现有 `PageResult` 分页结构；本接口完整脱敏响应仍待回填 |
| `data.dataList[].emailCode/version/versionStatus` | Mixed | 版本标识和状态 |
| `data.dataList[].modifiedBy/modifiedTime` | String/DateTime | 修改信息 |

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
      {"emailCode": "815645091883520000", "version": "V2", "versionStatus": 1, "modifiedBy": "content.manager", "modifiedTime": "2026-07-16 10:00:00"},
      {"emailCode": "815645091883520000", "version": "V1", "versionStatus": 2, "modifiedBy": "content.manager", "modifiedTime": "2026-06-01 09:00:00"}
    ]
  }
}
```

**前端处理与错误**

- 在 `REQ-03/04` 关闭前，不新增历史基本信息和 Expired Metadata 列。

## 5. 分类管理

> `NEW-01` 至 `NEW-05`、`NEW-08`、`NEW-09` 的 Method、Path、DTO 和本章错误语义已冻结为开发基线。后续实现如需调整，必须同步修改 Contract、Mock 和前端 Client。

### NEW-01 Category Tree

**接口与场景**

| 项目 | 内容 |
|---|---|
| Endpoint | `GET /iic-dae-msg/web/msg/template/email/v2/category/tree` |
| 页面 | `UI-01` Category 管理、`UI-02` 删除迁移、`UI-03/UI-04` Filter/Form |
| 场景 | 加载管理树；加载筛选项；加载模板分类选择；加载迁移目标 |
| 状态 | `开发基线` |

**页面参考**

[查看 UI-A-07 Category 管理列表](#ui-a-07)

**请求参数与 Mock**

无业务参数。

```text
GET /iic-dae-msg/web/msg/template/email/v2/category/tree
```

**响应字段**

| 字段 | 类型 | 说明 |
|---|---|---|
| `data.categories[].categoryId` | String | 节点 ID |
| `categoryName` | String | 显示名 |
| `description` | String/null | 可选描述，最终 UX 依赖 `REQ-08` |
| `level` | Integer | `1=Category, 2=Subcategory` |
| `parentCategoryId` | String/null | 一级为 null |
| `sortOrder` | Integer | 同级排序 |
| `createdBy/createdDate` | String/DateTime | 创建信息 |
| `children` | Object[] | 二级节点；无节点返回 `[]` |

**成功响应 Mock**

```json
{
  "requestId": "mock-request-id",
  "responseCode": "00000000",
  "responseMessage": "Succeed",
  "data": {
    "categories": [{
      "categoryId": "1001",
      "categoryName": "Client Engagement",
      "description": "Templates used during client engagement",
      "level": 1,
      "parentCategoryId": null,
      "sortOrder": 1,
      "createdBy": "content.manager",
      "createdDate": "2026-07-16 09:00:00",
      "children": [{
        "categoryId": "1101",
        "categoryName": "Advice Review",
        "description": null,
        "level": 2,
        "parentCategoryId": "1001",
        "sortOrder": 1,
        "createdBy": "content.manager",
        "createdDate": "2026-07-16 09:01:00",
        "children": []
      }]
    }]
  }
}
```

**前端处理与错误**

- 只返回有效节点；软删除节点不用于新建、编辑、筛选或迁移目标。
- 固定两级；前端不推导或展示第三级。
- 内部 `categoryCode` 对前端不可见。

### NEW-02 Create Category

**接口与场景**

| 项目 | 内容 |
|---|---|
| Endpoint | `POST /iic-dae-msg/web/msg/template/email/v2/category` |
| 页面 | `UI-01` Create Category |
| 场景 | 创建一级 Category |
| 状态 | `开发基线`；`description` 固定为 nullable optional，UX 可暂不展示 |

**页面参考**

[查看 UI-A-08 Create Category/Subcategory](#ui-a-08)

**请求参数与 Mock**

| 字段 | 类型 | 必填 | 说明 |
|---|---|---:|---|
| `categoryName` | String | 是 | 有效节点全局唯一 |
| `description` | String/null | 否 | 可选描述 |

```json
{
  "categoryName": "Client Engagement",
  "description": "Templates used during client engagement"
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
    "categoryId": "3001",
    "categoryName": "Client Engagement",
    "description": "Templates used during client engagement",
    "level": 1,
    "parentCategoryId": null,
    "sortOrder": 3,
    "createdBy": "content.manager",
    "createdDate": "2026-07-16 10:00:00",
    "children": []
  }
}
```

**前端处理与错误**

- 名称为空或与任一有效 Category/Subcategory 重复时显示字段错误。
- 软删除后允许重新创建同名节点。
- `categoryId/categoryCode` 均由后端生成，前端不传。

### NEW-03 Update Category/Subcategory

**接口与场景**

| 项目 | 内容 |
|---|---|
| Endpoint | `PUT /iic-dae-msg/web/msg/template/email/v2/category/{id}` |
| 页面 | `UI-01` Rename/Edit |
| 场景 | 编辑 Category 或 Subcategory 的 Name/Description |
| 状态 | `开发基线` |

**页面参考**

[查看 UI-A-09 Edit Category/Subcategory](#ui-a-09)

**请求参数与 Mock**

| 位置 | 字段 | 类型 | 必填 | 说明 |
|---|---|---|---:|---|
| Path | `id` | String | 是 | 目标节点 |
| Body | `categoryName` | String | 是 | 新名称 |
| Body | `description` | String/null | 否 | 新描述 |

```json
{"categoryName": "Client Engagement", "description": "Updated description"}
```

**响应字段与 Mock**

```json
{
  "requestId": "mock-request-id",
  "responseCode": "00000000",
  "responseMessage": "Succeed",
  "data": {
    "categoryId": "1001",
    "categoryName": "Client Engagement",
    "description": "Updated description",
    "level": 1,
    "parentCategoryId": null,
    "sortOrder": 1,
    "createdBy": "content.manager",
    "createdDate": "2026-07-16 09:00:00",
    "children": []
  }
}
```

**前端处理与错误**

- 本期不支持把已有 Subcategory 移到另一 Category。
- 目标不存在、已删除或名称与有效节点重复时失败，页面保留原值。

### NEW-04 Reassign and Delete

**接口与场景**

| 项目 | 内容 |
|---|---|
| Endpoint | `POST /iic-dae-msg/web/msg/template/email/v2/category/{id}/delete-and-reassign` |
| 页面 | `UI-02` Category 删除与迁移 |
| 场景 | 有引用时迁移 Active/Draft/Schedule Metadata 后删除节点；无引用时直接软删除 |
| 状态 | `开发基线` |

**页面参考**

[查看 UI-A-10 Category 删除与迁移](#ui-a-10)

**请求参数与 Mock**

| 位置 | 字段 | 类型 | 必填 | 说明 |
|---|---|---|---:|---|
| Path | `id` | String | 是 | 待删除 Category/Subcategory |
| Body | `targetCategoryId` | String/null | 条件 | 有有效引用时必传 |
| Body | `targetSubcategoryIds` | String[] | 是 | 目标子分类；无引用可空数组 |

```json
{
  "targetCategoryId": "2001",
  "targetSubcategoryIds": ["2101"]
}
```

**响应字段与 Mock**

| 字段 | 类型 | 说明 |
|---|---|---|
| `data.sourceCategoryId` | String | 已删除源节点 |
| `data.migratedVersionCount` | Integer | 实际迁移版本数 |
| `data.deletedNodeCount` | Integer | 实际软删除节点数 |

```json
{
  "requestId": "mock-request-id",
  "responseCode": "00000000",
  "responseMessage": "Succeed",
  "data": {"sourceCategoryId": "1001", "migratedVersionCount": 3, "deletedNodeCount": 2}
}
```

**前端处理与错误**

- 不允许前端循环调用 `NEW-07` 迁移单个 Template。
- Active、Draft、Schedule 必须迁移；Expired 和已软删除 version 不迁移。
- 目标失效、位于待删除子树、层级不匹配、Update 0 行或并发数量变化时整体失败；刷新影响范围后重试。

### NEW-05 Reorder Category

**接口与场景**

| 项目 | 内容 |
|---|---|
| Endpoint | `PUT /iic-dae-msg/web/msg/template/email/v2/category/reorder` |
| 页面 | `UI-01` Category 管理 |
| 场景 | 保存 Category 或同一父 Category 下 Subcategory 的前端排序 |
| 状态 | `开发基线`；请求必须提交同一 Parent 下全部有效同级节点的完整顺序 |

**请求参数与 Mock**

| 字段 | 类型 | 必填 | 说明 |
|---|---|---:|---|
| `parentCategoryId` | String/null | 是 | 一级排序传 null；二级传父 ID |
| `orderedCategoryIds` | String[] | 是 | 提交同一 Parent 下全部有效同级节点的完整顺序，不接受局部变化 |

```json
{
  "parentCategoryId": null,
  "orderedCategoryIds": ["1001", "2001", "3001"]
}
```

**响应字段与 Mock**

```json
{
  "requestId": "mock-request-id",
  "responseCode": "00000000",
  "responseMessage": "Succeed",
  "data": {"parentCategoryId": null, "orderedCategoryIds": ["1001", "2001", "3001"]}
}
```

**前端处理与错误**

- 只提交同一级、同一 Parent 的有效节点。
- 保存失败时恢复原顺序或重新加载树，不在前端假设部分成功。

### NEW-08 Batch Create Subcategories

**接口与场景**

| 项目 | 内容 |
|---|---|
| Endpoint | `POST /iic-dae-msg/web/msg/template/email/v2/category/{parentId}/subcategories/batch` |
| 页面 | `UI-01` Category 管理、`UI-04` 模板表单 |
| 场景 | 在有效 Category 下一次创建 1-5 个 Subcategory |
| 状态 | `开发基线` |

**页面参考**

[查看 UI-A-08 Create Category/Subcategory](#ui-a-08)

**请求参数与 Mock**

| 位置 | 字段 | 类型 | 必填 | 说明 |
|---|---|---|---:|---|
| Path | `parentId` | String | 是 | 有效一级 Category |
| Body | `subcategories` | Object[] | 是 | 1-5 项 |
| Item | `categoryName` | String | 是 | 全局有效名称唯一 |
| Item | `description` | String/null | 否 | 可选描述 |

```json
{
  "subcategories": [
    {"categoryName": "Advice Review", "description": "Review-related templates"},
    {"categoryName": "Annual Check-in", "description": null}
  ]
}
```

**响应字段与 Mock**

`data.subcategories[]` 按请求顺序返回完整 Category Node。

```json
{
  "requestId": "mock-request-id",
  "responseCode": "00000000",
  "responseMessage": "Succeed",
  "data": {
    "subcategories": [
      {"categoryId": "5000", "categoryName": "Advice Review", "description": "Review-related templates", "level": 2, "parentCategoryId": "1001", "sortOrder": 1, "createdBy": "content.manager", "createdDate": "2026-07-16 10:00:00", "children": []},
      {"categoryId": "5001", "categoryName": "Annual Check-in", "description": null, "level": 2, "parentCategoryId": "1001", "sortOrder": 2, "createdBy": "content.manager", "createdDate": "2026-07-16 10:00:00", "children": []}
    ]
  }
}
```

**前端处理与错误**

- 数组为空、超过 5 条、批内重名、与有效节点重名或 Parent 非法时整批失败。
- 前端不能把失败请求拆成逐条重试，以免破坏原子语义。

### NEW-09 Category Delete Impact

**接口与场景**

| 项目 | 内容 |
|---|---|
| Endpoint | `GET /iic-dae-msg/web/msg/template/email/v2/category/{id}/delete-impact` |
| 页面 | `UI-02` Delete Confirmation |
| 场景 | 点击 Delete 后展示子节点、Template 和各状态 version 的影响数量 |
| 状态 | `开发基线` |

**页面参考**

[查看 UI-A-10 Category 删除与迁移](#ui-a-10)

**请求参数**

| 位置 | 字段 | 类型 | 必填 |
|---|---|---|---:|
| Path | `id` | String | 是 |

请求示例：

```text
GET /iic-dae-msg/web/msg/template/email/v2/category/1001/delete-impact
```

**响应字段与 Mock**

| 字段 | 类型 | 说明 |
|---|---|---|
| `sourceCategoryId/sourceLevel` | String/Integer | 源节点 |
| `childCount/templateCount/versionCount` | Integer | 总体影响 |
| `activeVersionCount` | Integer | 需迁移 Active 数 |
| `draftVersionCount` | Integer | 需迁移 Draft 数 |
| `scheduleVersionCount` | Integer | 需迁移 Schedule 数 |
| `expiredVersionCount` | Integer | 只展示、不迁移的 Expired 数 |

```json
{
  "requestId": "mock-request-id",
  "responseCode": "00000000",
  "responseMessage": "Succeed",
  "data": {
    "sourceCategoryId": "1001",
    "sourceLevel": 1,
    "childCount": 1,
    "templateCount": 2,
    "versionCount": 4,
    "activeVersionCount": 2,
    "draftVersionCount": 1,
    "scheduleVersionCount": 0,
    "expiredVersionCount": 1
  }
}
```

**前端处理与错误**

- Impact 结果只用于确认框，不保证提交时数量不变。
- `NEW-04` 执行时后端会重新查询并锁定真实影响范围。
- 目标不存在或已删除时关闭确认框并刷新 Category Tree。

## 6. 标签与版本元数据

### NEW-06 Tag Taxonomy

**接口与场景**

| 项目 | 内容 |
|---|---|
| Endpoint | `GET /iic-dae-msg/web/msg/template/email/v2/tag/taxonomy` |
| 页面 | `UI-04` Tag Assignment、`UI-03` Tag Filter |
| 场景 | 加载模板标签选择；加载列表标签筛选项 |
| 状态 | `开发基线` |

**页面参考**

[查看 UI-A-11 Tag Assignment 与版本元数据](#ui-a-11)

**请求参数与 Mock**

无业务参数。

```text
GET /iic-dae-msg/web/msg/template/email/v2/tag/taxonomy
```

**响应字段**

| 字段 | 类型 | 说明 |
|---|---|---|
| `data.tagGroups[].groupCode` | String | 固定 Group 编码 |
| `groupName` | String | Group 显示名 |
| `mandatory` | Boolean | Publish 时是否必填 |
| `sortOrder` | Integer | Group 排序 |
| `values[].tagCode` | String | 固定 Tag Value 编码 |
| `values[].tagName` | String | 显示名 |
| `values[].sortOrder` | Integer | Value 排序 |

**成功响应 Mock**

```json
{
  "requestId": "mock-request-id",
  "responseCode": "00000000",
  "responseMessage": "Succeed",
  "data": {
    "tagGroups": [
      {"groupCode": "CONTENT_TYPE", "groupName": "Content Type", "mandatory": true, "sortOrder": 1, "values": [{"tagCode": "EMAIL", "tagName": "Email", "sortOrder": 1}, {"tagCode": "UNCLASSIFIED", "tagName": "Unclassified", "sortOrder": 99}]},
      {"groupCode": "TRIGGER", "groupName": "Trigger", "mandatory": true, "sortOrder": 2, "values": [{"tagCode": "MANUAL", "tagName": "Manual", "sortOrder": 1}]},
      {"groupCode": "LIFECYCLE_STAGE", "groupName": "Life-cycle Stage", "mandatory": true, "sortOrder": 3, "values": [{"tagCode": "RETIREMENT", "tagName": "Retirement", "sortOrder": 1}]},
      {"groupCode": "FINANCIAL_NEED", "groupName": "Financial Need", "mandatory": true, "sortOrder": 4, "values": [{"tagCode": "RETIREMENT_PLANNING", "tagName": "Retirement Planning", "sortOrder": 1}]},
      {"groupCode": "PROPOSITION", "groupName": "Proposition", "mandatory": false, "sortOrder": 5, "values": []},
      {"groupCode": "SOURCE", "groupName": "Source", "mandatory": false, "sortOrder": 6, "values": []}
    ]
  }
}
```

**前端处理与错误**

- Taxonomy 由固定 DB seed 维护，前端不提供 Tag 管理 CRUD。
- 每个 Group 均可多选；同组筛选 OR，不同组筛选 AND。
- 4 个 Mandatory Group、2 个 Optional Group；前端不把 `mandatory` 写死在页面代码中。

### NEW-07 Update Version Metadata

**接口与场景**

| 项目 | 内容 |
|---|---|
| Endpoint | `PUT /iic-dae-msg/web/msg/template/email/v2/template/{emailCode}/version/{version}/metadata` |
| 页面 | `UI-04` 模板编辑 |
| 场景 | 单独保存 Draft/Active version Metadata；单 Template Reassignment |
| 状态 | `开发基线`；使用全量替换语义 |

**页面参考**

[查看 UI-A-11 Tag Assignment 与版本元数据](#ui-a-11)

**请求参数**

| 位置 | 字段 | 类型 | 必填 | 说明 |
|---|---|---|---:|---|
| Path | `emailCode` | String | 是 | 模板标识 |
| Path | `version` | String | 是 | 明确目标 version |
| Body | `categoryId` | String/null | 是 | Draft 可 null；Active 必填 |
| Body | `subcategoryIds` | String[] | 是 | 完整快照；空数组表示清空 |
| Body | `tagGroups` | Object[] | 是 | 必须包含完整 6 组快照；字段或任一 Group 缺失均失败 |
| Item | `groupCode` | String | 是 | Group 编码 |
| Item | `tagCodes` | String[] | 是 | 空数组表示清空该组 |

**请求 Mock**

```json
{
  "categoryId": "1001",
  "subcategoryIds": ["1101"],
  "tagGroups": [
    {"groupCode": "CONTENT_TYPE", "tagCodes": ["EMAIL"]},
    {"groupCode": "TRIGGER", "tagCodes": ["MANUAL"]},
    {"groupCode": "LIFECYCLE_STAGE", "tagCodes": ["RETIREMENT"]},
    {"groupCode": "FINANCIAL_NEED", "tagCodes": ["RETIREMENT_PLANNING"]},
    {"groupCode": "PROPOSITION", "tagCodes": []},
    {"groupCode": "SOURCE", "tagCodes": []}
  ]
}
```

**响应字段与 Mock**

返回 `emailCode + version` 和更新后的完整 Metadata Snapshot。

```json
{
  "requestId": "mock-request-id",
  "responseCode": "00000000",
  "responseMessage": "Succeed",
  "data": {
    "emailCode": "815645091883520000",
    "version": "V2",
    "categoryId": "1001",
    "subcategoryIds": ["1101"],
    "tagGroups": [
      {"groupCode": "CONTENT_TYPE", "tagCodes": ["EMAIL"]},
      {"groupCode": "TRIGGER", "tagCodes": ["MANUAL"]},
      {"groupCode": "LIFECYCLE_STAGE", "tagCodes": ["RETIREMENT"]},
      {"groupCode": "FINANCIAL_NEED", "tagCodes": ["RETIREMENT_PLANNING"]},
      {"groupCode": "PROPOSITION", "tagCodes": []},
      {"groupCode": "SOURCE", "tagCodes": []}
    ]
  }
}
```

**前端处理与错误**

- 请求必须明确指定 `emailCode + version`，后端不得自动选择 Active/Draft/最大版本。
- Draft 允许不完整；Active 更新后立即生效，并对现有 Title、Description、Format、Subject、Body 和新 Metadata 执行完整 Published Validation。
- Mandatory Group 空数组：Draft 使用 `Unclassified`；Active 拒绝。Optional Group 空数组表示清空。
- Tag 重复、失效、Group 不匹配、Subcategory 层级错误或目标 version 不存在时整体失败，原 Metadata 不变。
- 本接口不创建新版本，也不改变 `versionStatus`。

## 7. 通用错误 Mock

以下结构沿用已确认的 v1 包络字段。新增 Category/Tag/Metadata 接口使用下列稳定业务错误键；现有 Version Conflict 和统一字段校验的最终 HTTP Status/兼容映射仍待 `API-02/API-03` 冻结。

| `responseCode` | 使用场景 |
|---|---|
| `VALIDATION_FAILED` | 通用字段校验或 Publish 完整性校验失败 |
| `VERSION_CONFLICT` | 版本状态已变化、已有 Draft/Schedule 或并发冲突 |
| `CATEGORY_NOT_FOUND` | Category/Subcategory 不存在或已软删除 |
| `CATEGORY_NAME_DUPLICATE` | 与任一有效 Category/Subcategory 名称重复 |
| `CATEGORY_LEVEL_INVALID` | Parent、层级或跨 Parent 操作非法 |
| `CATEGORY_IN_USE` | 节点存在有效引用但未提供迁移目标 |
| `CATEGORY_TARGET_INVALID` | 迁移目标失效、位于待删除子树或层级不匹配 |
| `CATEGORY_CONCURRENT_MODIFICATION` | 影响数量或节点状态在提交前发生变化 |
| `TAG_VALUE_INVALID` | Tag/Group 不存在、失效或归属错误 |
| `METADATA_VALIDATION_FAILED` | Metadata 快照缺字段、缺 Group 或 Published 必填项不完整 |

**字段校验失败**

```json
{
  "requestId": "mock-request-id",
  "responseCode": "VALIDATION_FAILED",
  "responseMessage": "Published validation failed",
  "data": {
    "fieldErrors": [
      {"field": "categoryId", "code": "REQUIRED", "message": "Category is required"}
    ]
  }
}
```

**版本冲突**

```json
{"requestId":"mock-request-id","responseCode":"VERSION_CONFLICT","responseMessage":"Template version has changed; refresh and retry","data":null}
```

**无权限**

```json
{"requestId":"mock-request-id","responseCode":"PERMISSION_DENIED","responseMessage":"You do not have permission to perform this action","data":null}
```

## 8. 尚未冻结但会影响前端的事项

| 登记册 ID | 问题 | 影响接口 |
|---|---|---|
| `REQ-01/REQ-02` | 哪些模板基本信息进入版本层，主表继续保存什么 | `EX-05/06/09/10/13`、List |
| `REQ-03/REQ-04` | Version History 是否展示历史基本信息和 Metadata | `EX-13/14` |
| `API-02/API-03` | 字段错误和 Version Conflict 正式响应 | 所有写接口 |
| `COPY-01` | Copy and Create 的业务对象、复制范围和持久化时点；若由后端承载则新增 v2 API | 接口总数、Template 创建、Version Detail |

状态、Owner 和关闭记录只在[未确认项登记册](LEAD-93_Open_Questions_Register_CN.md)维护。

## 9. 页面与接口地图

本附录是 Word 版本的页面导航入口。正文 Endpoint 不再重复放置缩略图，而是通过内部链接跳转到本附录。每个页面原型只出现一次；截图用于定位页面和控件，接口字段仍以对应 Endpoint 章节为准。

| 页面编号 | 页面/操作 | 关联 Endpoint |
|---|---|---|
| [UI-A-01](#ui-a-01) | Template Library Published/Search/Filter | [EX-01](#ex-01) |
| [UI-A-02](#ui-a-02) | Draft/Admin Template List | [EX-02](#ex-02) |
| [UI-A-03](#ui-a-03) | Template Detail/Preview | [EX-03](#ex-03)、[EX-04](#ex-04) |
| [UI-A-04](#ui-a-04) | Template 创建、编辑、Save Draft/Publish | [EX-05](#ex-05)、[EX-06](#ex-06)、[EX-10](#ex-10)、[NEW-07](#new-07) |
| [UI-A-05](#ui-a-05) | Template Delete | [EX-08](#ex-08) |
| [UI-A-06](#ui-a-06) | Version History | [EX-09](#ex-09)、[EX-11](#ex-11)、[EX-12](#ex-12)、[EX-13](#ex-13)、[EX-14](#ex-14) |
| [UI-A-07](#ui-a-07) | Category 管理列表 | [NEW-01](#new-01)、[NEW-05](#new-05) |
| [UI-A-08](#ui-a-08) | Create Category/Subcategory | [NEW-02](#new-02)、[NEW-08](#new-08) |
| [UI-A-09](#ui-a-09) | Edit Category/Subcategory | [NEW-03](#new-03) |
| [UI-A-10](#ui-a-10) | Category 删除、影响检查与迁移 | [NEW-04](#new-04)、[NEW-09](#new-09) |
| [UI-A-11](#ui-a-11) | Tag Assignment 与版本元数据 | [NEW-06](#new-06)、[NEW-07](#new-07) |

### UI-A-01 Template Library

返回接口：[EX-01 Published List](#ex-01)

| 页面区域 | 接口关系 |
|---|---|
| Published Tab、搜索和 Filter | `EX-01` 请求条件 |
| Template 列表、分页和排序 | `EX-01` 响应与页面状态 |
| Create New Template | 进入 `UI-A-04`；创建/首次保存使用 `EX-05` |

![UI-A-01a Template Library 默认页面](api-contract/assets/prd/image19.png)

![UI-A-01b Template Library 搜索筛选](api-contract/assets/prd/image20.png)

<!-- pagebreak -->

### UI-A-02 Draft/Admin Template List

返回接口：[EX-02 Draft/Admin List](#ex-02)

| 页面区域 | 接口关系 |
|---|---|
| Draft/Admin Tab 和筛选 | `EX-02` 请求条件 |
| Draft/Schedule 行 | `EX-02` 返回的目标 version 和派生状态 |
| Edit/Delete 操作 | `EX-03`、`EX-05`、`EX-08` 或 `EX-11`，取决于对象层级 |

![UI-A-02 Draft/Admin Template List](api-contract/assets/prd/image15.png)

<!-- pagebreak -->

### UI-A-03 Template Detail/Preview

返回接口：[EX-03 Admin Detail](#ex-03)、[EX-04 Adviser Detail](#ex-04)

| 页面区域 | 接口关系 |
|---|---|
| 管理端 Detail/Preview | `EX-03` |
| Adviser Published Detail | `EX-04` |
| 正文和版本元数据 | 由显式选择的 version 返回；Preview 不展示附件 |

![UI-A-03 Template Detail Preview](api-contract/assets/prd/image18.png)

<!-- pagebreak -->

### UI-A-04 Template 创建与编辑

返回接口：[EX-05 Save/Publish](#ex-05)、[EX-06 Master Fields](#ex-06)、[EX-10 Update Version](#ex-10)、[NEW-07 Metadata](#new-07)

| 页面区域 | 接口关系 |
|---|---|
| Basic Information | `EX-05` 创建/首次保存；主表独立修改使用 `EX-06` |
| Save Draft/Publish/Schedule | `EX-05` |
| 编辑现有版本 | `EX-10` |
| Category/Subcategory/Tag | 随目标 version 提交；独立 Metadata 修改使用 `NEW-07` |

![UI-A-04 Template 创建与编辑](api-contract/assets/prd/image13.png)

<!-- pagebreak -->

### UI-A-05 Template Delete

返回接口：[EX-08 Delete Template](#ex-08)、[EX-11 Delete Version](#ex-11)

| 页面区域 | 接口关系 |
|---|---|
| Delete Confirmation | `EX-08` Template 级联软删除 |
| 未保存编辑离开 | 前端行为，不调用删除接口 |
| 已持久化 Working Copy | 使用 `EX-11` 删除目标 Draft version |

![UI-A-05 Delete Template](api-contract/assets/prd/image21.png)

<!-- pagebreak -->

### UI-A-06 Version History

返回接口：[EX-09 Add](#ex-09)、[EX-10 Update](#ex-10)、[EX-11 Delete](#ex-11)、[EX-12 Max](#ex-12)、[EX-13 Detail](#ex-13)、[EX-14 History](#ex-14)

| 页面区域 | 接口关系 |
|---|---|
| History List | `EX-14` |
| Version Detail/Edit | `EX-13`、`EX-10` |
| Add/Delete/Max Version | `EX-09`、`EX-11`、`EX-12` |
| Copy and Create | 范围由 `COPY-01` 确认，当前不与 `EX-09` 等同 |

![UI-A-06 Version History](api-contract/assets/prd/image14.png)

<!-- pagebreak -->

### UI-A-07 Category 管理列表

返回接口：[NEW-01 Category Tree](#new-01)、[NEW-05 Reorder](#new-05)

| 页面区域 | 接口关系 |
|---|---|
| Category/Subcategory Tree | `NEW-01` |
| 排序 | `NEW-05` |
| Create/Edit/Delete 入口 | `NEW-02`、`NEW-03`、`NEW-04` |

![UI-A-07 Category 管理列表](api-contract/assets/prd/image1.png)

<!-- pagebreak -->

### UI-A-08 Create Category/Subcategory

返回接口：[NEW-02 Create Category](#new-02)、[NEW-08 Batch Subcategories](#new-08)

| 页面区域 | 接口关系 |
|---|---|
| Create Category | `NEW-02` |
| Create Multiple Subcategories | `NEW-08` |
| Name/Parent/Description 校验 | 对应接口字段级 Validation |

![UI-A-08 Create Category Subcategory](api-contract/assets/prd/image2.png)

<!-- pagebreak -->

### UI-A-09 Edit Category/Subcategory

返回接口：[NEW-03 Update Category](#new-03)

| 页面区域 | 接口关系 |
|---|---|
| Rename/Edit | `NEW-03` |
| 有效节点和同名校验 | `NEW-03` 字段校验与业务错误 |

![UI-A-09 Edit Category Subcategory](api-contract/assets/prd/image8.png)

<!-- pagebreak -->

### UI-A-10 Category 删除与迁移

返回接口：[NEW-04 Reassign/Delete](#new-04)、[NEW-09 Delete Impact](#new-09)

| 页面区域 | 接口关系 |
|---|---|
| 打开 Delete Confirmation | `NEW-09` 查询删除影响 |
| 选择迁移目标并确认 | `NEW-04` 原子迁移当前有效引用并软删除 |
| 历史版本 | 不迁移，最终展示规则仍由登记册控制 |

![UI-A-10 Category 删除与迁移](api-contract/assets/prd/image12.png)

<!-- pagebreak -->

### UI-A-11 Tag Assignment 与版本元数据

返回接口：[NEW-06 Tag Taxonomy](#new-06)、[NEW-07 Version Metadata](#new-07)

| 页面区域 | 接口关系 |
|---|---|
| Tag Group/Value 选项 | `NEW-06` |
| Category/Subcategory/Tag Assignment | `NEW-07` 或随 `EX-05/09/10` 保存目标 version |
| Mandatory Group | Draft 允许不完整；Publish 时后端强制校验 |

![UI-A-11 Tag Assignment 与版本元数据](api-contract/assets/prd/image17.png)
