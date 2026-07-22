# LEAD-93 / LEAD-405 / LEAD-406 Web v2 API Contract

> 状态：最终开发基线
> 日期：2026-07-21
> 需求基线：PRD v2.0（`DAE_PRD_LEAD-93 Template Management_v2.0 - updated July 21st.docx`）、Jira Feature 拆分及 2026-07-21 LEAD-278 Jira/OM Copy and Create 澄清
> 交叉需求参考：`PRD_LEAD-308 Advisor-Template Management_v1.3 -updated July 20th.docx`
> 范围：28 个 Web v2 Endpoint

## 1. 契约总览

本文是 Web 前端、后端和接口测试共同遵循的 API 基线。正文只定义最终对外契约，不记录现状分析、实现差异、内部类名或评审过程。Web 端只调用本文列出的 `/v2` Endpoint；环境网关路由不属于 Endpoint。

### 1.1 配套文件

| 文件 | 用途 |
|---|---|
| [HTTP 请求示例](api-contract/examples/lead93-api.http) | 28 个 Endpoint 的可执行请求样例 |
| [Postman Collection](postman/LEAD-93-v2-contract-all-apis.postman_collection.json) | 28 个 Endpoint、30 个调用场景及断言 |
| [本地 Mock](api-contract/mock/lead93-mock-server.mjs) | 前后端并行开发和固定响应调试 |
| [Mock 调试报告](postman/reports/v2-contract-mock-2026-07-21_162015.debug.html) | URL、Request、Response 和断言样例 |

HTTP 示例与 Postman 已按 `Method + Path` 比对：28/28，缺失 0，多余 0。

### 1.2 公共约定

| 项目 | 契约 |
|---|---|
| Base Path | `/iic-dae-msg/web/msg/template/email/v2` |
| 响应包络 | `requestId/responseCode/responseMessage/data` |
| HTTP Status | 业务成功和业务失败均返回 HTTP 200；网关、协议或服务不可用等非业务异常不在本契约内 |
| 成功判断 | `responseCode="00000000"`；其他值为业务失败，实际失败码和 `responseMessage` 以 QA 实测为准 |
| 分页 | 请求使用 `pageNum/pageSize`；响应使用 `pageNo/pageSize/totalCount/totalPage/dataList` |
| 时间 | `yyyy-MM-dd HH:mm:ss`，按 `Africa/Johannesburg`（UTC+02:00）解释 |
| 标识类型 | `emailCode`、Category ID 等 64 位标识均使用 String |
| 空值 | 可空字段使用 `null`；不使用空字符串代替无值，字段另有说明时除外 |
| 写请求 | 成功返回前完成该命令的全部校验和写入；失败不得产生部分业务结果 |
| Metadata | Category、Subcategory 和 Tag 归属于 `emailCode` 对应的当前 Template，不属于内容 Version |
| 生命周期 | `versionStatus`：`0=Schedule, 1=Active, 2=Expired, 3=Draft` |

**公共请求头**

| Header | 必填 | 说明 |
|---|---:|---|
| `authorization` | 是 | Bearer 登录态 |
| `x-apigw-api-id` | 是 | 环境配置提供 |
| `content-type` | 是 | `application/json` |
| `language` | 是 | `en-US` |
| `requestid` | 是 | 每次请求使用新的唯一值 |

**角色权限**

| 能力 | 允许角色 | 约束 |
|---|---|---|
| Template、Category/Subcategory 和 Metadata 管理写操作 | `Content Manager` | 方案中的“管理员”与 `Content Manager` 是同一角色，不新增独立 Admin 角色 |
| Published Template 与 Tag Taxonomy 查询 | `Content Manager`、`Adviser` | Adviser 只能读取 Enabled + Active Published Template，不允许通过请求参数读取 Draft/Schedule |
| Draft/Admin List、管理端 Detail 和 Version 管理 | `Content Manager` | 复用现有鉴权机制 |
| Tag Seed 与一次性 Migration | 非运行时 API | 由受控数据库脚本和发布流程执行 |

### 1.3 Endpoint 清单

| ID | Method + Complete Endpoint | 主要场景 |
|---|---|---|
| `EX-01` | `POST /iic-dae-msg/web/msg/template/email/v2/queryList` | Published 列表、搜索和筛选 |
| `EX-02` | `POST /iic-dae-msg/web/msg/template/email/v2/templateList` | Draft/Admin 列表、搜索和筛选 |
| `EX-03` | `POST /iic-dae-msg/web/msg/template/email/v2/detail` | 管理端 Template Detail |
| `EX-04` | `POST /iic-dae-msg/web/msg/template/email/v2/published/detail` | Adviser Published Detail |
| `EX-15` | `POST /iic-dae-msg/web/msg/template/email/v2/channelList` | Channel 选项 |
| `EX-05` | `POST /iic-dae-msg/web/msg/template/email/v2/add` | Save Draft、Cancel Schedule |
| `EX-16` | `POST /iic-dae-msg/web/msg/template/email/v2/publish` | Publish Now、Schedule Publish、直接发布新 Template |
| `EX-06` | `POST /iic-dae-msg/web/msg/template/email/v2/update` | 修改 Template 基本信息 |
| `EX-07` | `POST /iic-dae-msg/web/msg/template/email/v2/changeStatus` | Deactivate、Reactivate |
| `EX-08` | `POST /iic-dae-msg/web/msg/template/email/v2/delete` | 删除 Template |
| `NEW-10` | `POST /iic-dae-msg/web/msg/template/email/v2/copy` | Copy and Create 首次保存 |
| `EX-09` | `POST /iic-dae-msg/web/msg/template/email/v2/version/add` | 增加内容版本 |
| `EX-10` | `POST /iic-dae-msg/web/msg/template/email/v2/version/update` | 更新 Draft 内容版本 |
| `EX-11` | `POST /iic-dae-msg/web/msg/template/email/v2/version/delete` | Cancel 已保存 Draft、删除 Schedule |
| `EX-12` | `GET /iic-dae-msg/web/msg/template/email/v2/version/getMaxVersion` | 查询最大版本号 |
| `EX-13` | `POST /iic-dae-msg/web/msg/template/email/v2/version/detail` | 查询内容版本详情 |
| `EX-14` | `POST /iic-dae-msg/web/msg/template/email/v2/version/list/history` | Version History |
| `NEW-01` | `GET /iic-dae-msg/web/msg/template/email/v2/category/tree` | Category Tree |
| `NEW-02` | `POST /iic-dae-msg/web/msg/template/email/v2/category` | 创建 Category |
| `NEW-03` | `PUT /iic-dae-msg/web/msg/template/email/v2/category/{id}` | 更新 Category/Subcategory |
| `NEW-12` | `DELETE /iic-dae-msg/web/msg/template/email/v2/category/{categoryId}` | 删除无有效引用节点 |
| `NEW-04` | `POST /iic-dae-msg/web/msg/template/email/v2/category/reassign-and-delete` | 迁移引用并删除节点 |
| `NEW-05` | `PUT /iic-dae-msg/web/msg/template/email/v2/category/reorder` | 保存同级排序 |
| `NEW-08` | `POST /iic-dae-msg/web/msg/template/email/v2/category/batch-subcategories` | 批量创建 Subcategory |
| `NEW-09` | `POST /iic-dae-msg/web/msg/template/email/v2/category/delete-impact/{categoryId}` | 删除影响分析 |
| `NEW-06` | `GET /iic-dae-msg/web/msg/template/email/v2/category/taxonomy` | Tag Taxonomy |
| `NEW-07` | `POST /iic-dae-msg/web/msg/template/email/v2/category/metadata` | 更新单个 Template Metadata |
| `NEW-11` | `POST /iic-dae-msg/web/msg/template/email/v2/reassign` | 批量 Template Reassignment |

## 2. 模板查询与详情

### EX-01 Published List

**接口与场景**

| 项目 | 内容 |
|---|---|
| Endpoint | `POST /iic-dae-msg/web/msg/template/email/v2/queryList` |
| 页面 | `UI-A-01` Template Library Published/Search/Filter |
| 场景 | 打开 Published 页签；搜索/筛选已发布模板；Adviser 查询可用模板 |

**请求参数**

| 字段 | 类型 | 必填 | 说明 |
|---|---|---:|---|
| `keyword` | String | 否 | 关键字；匹配模板名称、当前 Active Email Subject、描述、标签名称 |
| `categoryId` | String | 否 | 主分类，单选 |
| `subCategoryIds` | String[] | 否 | 子分类，多选，同一维度 OR |
| `tagGroups` | Object[] | 否 | 标签筛选组；同组 OR、跨组 AND |
| `tagGroups[].groupCode` | String | 条件 | 提交 `tagGroups` 时必填 |
| `tagGroups[].tagCodes` | String[] | 条件 | 提交 `tagGroups` 时必填 |
| `pageNum` | Integer | 否 | 当前页码，默认 `1` |
| `pageSize` | Integer | 否 | 每页数量，默认 `20` |

**请求 Mock**

```json
{
  "keyword": "retirement",
  "categoryId": "1001",
  "subCategoryIds": ["1101"],
  "tagGroups": [{"groupCode": "CONTENT_TYPE", "tagCodes": ["CONTENT_TYPE_EMAIL"]}],
  "pageNum": 1,
  "pageSize": 20
}
```

**响应字段**

| 字段 | 类型 | 说明 |
|---|---|---|
| `data.pageNo` | Integer | 当前页码 |
| `data.pageSize` | Integer | 每页数量 |
| `data.totalCount` | Long | 总记录数 |
| `data.totalPage` | Integer | 总页数 |
| `data.dataList[].emailCode` | String | 模板唯一业务标识 |
| `data.dataList[].emailName` | String | 模板名称 |
| `data.dataList[].title` | String/null | 当前 Active version 的 Email Subject |
| `data.dataList[].description` | String/null | 描述 |
| `data.dataList[].version` | String | 当前 Active version |
| `data.dataList[].emailStatus` | String | `1=Active` |
| `data.dataList[].versionStatus` | Integer | 固定为 `1=Active` |
| `data.dataList[].categoryId` | String/null | 当前 Template 主分类 ID |
| `data.dataList[].categoryName` | String/null | 当前 Template 主分类名称 |
| `data.dataList[].subCategoryIds` | String[] | 当前 Template 子分类 ID |
| `data.dataList[].subCategoryNames` | String[] | 当前 Template 子分类名称 |
| `data.dataList[].tagMap` | Object | `{groupCode: [tagCode]}`；当前 Template 标签，不随 Active version 切换 |
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

**前端处理与错误**

- Published 页签不显示或提交 Status Filter。
- Keyword 由后端同时匹配 `config.email_name`、当前 Active `version.title`、`config.description` 和当前 Template Tag Name；Category/Subcategory Name 不在本期关键词范围。
- 后端固定只查询 Email：`is_campaign = 0`；前端不传入、也不读取该内部字段。
- 空结果显示现有 Empty State；分页和排序继续沿用现有页面行为。

### EX-02 Draft/Admin List

**接口与场景**

| 项目 | 内容 |
|---|---|
| Endpoint | `POST /iic-dae-msg/web/msg/template/email/v2/templateList` |
| 页面 | `UI-A-02` Draft/Admin Template List |
| 场景 | 打开 Draft/Admin 页签；搜索/筛选 Draft、Schedule 或管理态模板 |

**请求参数**

| 字段 | 类型 | 必填 | 说明 |
|---|---|---:|---|
| `keyword` | String | 否 | 匹配模板名称、结果版本 Email Subject、描述、标签名称 |
| `tab` | String | 是 | `DRAFT/SCHEDULE/DISABLED`；Published 不调用本接口表达状态筛选 |
| `categoryId` | String | 否 | 主分类 |
| `subCategoryIds` | String[] | 否 | 子分类多选，同一维度 OR |
| `tagGroups` | Object[] | 否 | 标签筛选组；同组 OR、跨组 AND |
| `tagGroups[].groupCode` | String | 条件 | 提交 `tagGroups` 时必填 |
| `tagGroups[].tagCodes` | String[] | 条件 | 提交 `tagGroups` 时必填 |
| `pageNum` | Integer | 否 | 当前页码，默认 `1` |
| `pageSize` | Integer | 否 | 每页数量，默认 `20` |

**请求 Mock**

```json
{
  "keyword": "retirement",
  "tab": "DRAFT",
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

**前端处理与错误**

- 保持现有 Draft 三分支语义，不由前端拼接状态条件。
- Email Subject 作用于后端已选择的结果 Version；Category/Subcategory/Tag Filter 作用于当前 Template Metadata。
- Keyword 中的 Email Subject 来自 `result_version`；Tag Name 来自当前 Template Tag relation。
- 本期 Web Template Library 固定为 Email-only；页面不提供 Email/Campaign 类型切换。

### EX-03 Admin Template Detail

**接口与场景**

| 项目 | 内容 |
|---|---|
| Endpoint | `POST /iic-dae-msg/web/msg/template/email/v2/detail` |
| 页面 | `UI-A-03` Template Detail/Preview、`UI-A-04` Template 创建与编辑 |
| 场景 | 打开管理端模板详情；编辑 Draft/Schedule；Preview 前加载已保存内容 |

**请求参数**

| 字段 | 类型 | 必填 | 说明 |
|---|---|---:|---|
| `emailCode` | String | 是 | 模板业务标识 |
| `version` | String | 条件必填 | 编辑明确 version 时必须传；不传时沿用现有选版规则 |

**请求 Mock**

```json
{"emailCode": "926734518203400192", "version": "V1"}
```

**响应字段**

| 字段 | 类型 | 说明 |
|---|---|---|
| `data.emailCode` | String | 模板标识 |
| `data.emailName` | String | Template Title |
| `data.description` | String/null | Template Description |
| `data.version` | String | 返回内容所属版本 |
| `data.versionStatus` | Integer | Version 状态 |
| `data.emailStatus` | String | Template 启用状态 |
| `data.copyFromEmailCode` | String/null | Copy and Create 来源 Template 的 `emailCode`；仅供管理端发布前提醒，不在普通页面展示 |
| `data.title` | String/null | Email Subject |
| `data.emailContent` | String | 加密正文 |
| `data.emailContentKey` | String/null | 正文解密 Key |
| `data.textContent` | String/null | 纯文本正文 |
| `data.fileKeys` | String/null | 附件 Key，逗号分隔 |
| `data.fileInfos` | Object[] | 附件信息 |
| `data.fileInfos[].fileKey` | String | 附件 Key |
| `data.fileInfos[].fileName` | String | 附件名称 |
| `data.fileInfos[].fileType` | String | 附件类型 |
| `data.fileInfos[].size` | Long | 附件大小，单位 Byte |
| `data.fileInfos[].viewUrl` | String/null | 现有附件访问地址 |
| `data.isCustomBranding` | String | `0=No, 1=Yes` |
| `data.effectiveFrom` | DateTime/null | 生效时间 |
| `data.effectiveUntil` | DateTime/null | 失效时间 |
| `data.categoryId` | String/null | 当前 Template 主 Category ID |
| `data.categoryName` | String/null | 当前 Template 主 Category 名称 |
| `data.subCategoryIds` | String[] | 当前 Template Subcategory ID |
| `data.subCategoryNames` | String[] | 当前 Template Subcategory 名称 |
| `data.tagMap` | Object | `{groupCode: [tagCode]}`；请求不同 version 时值相同 |

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

**前端处理与错误**

- 编辑 Draft/Schedule/指定历史版本时必须显式传 `version`，不能依赖自动选版。
- 目标 version 不存在或已软删除时提示刷新，不尝试改查其他 version。
- Preview 只展示正文和 Metadata，不展示附件，也不新增 Preview API。
- `copyFromEmailCode` 只用于 Copy 模板发布前提醒，不在 Detail 页面形成来源关系展示，也不得据此限制 A/B 的查询、编辑、发布或停用。

### EX-04 Adviser Published Detail

**接口与场景**

| 项目 | 内容 |
|---|---|
| Endpoint | `POST /iic-dae-msg/web/msg/template/email/v2/published/detail` |
| 页面 | `UI-A-03` Adviser Published Detail |
| 场景 | Adviser 打开可用模板详情 |

**请求参数与 Mock**

| 字段 | 类型 | 必填 | 说明 |
|---|---|---:|---|
| `emailCode` | String | 是 | 模板业务标识 |

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

**前端处理与错误**

- 无权限、Inactive、已删除或没有 Active version 时不展示内容。
- 前端不得通过修改请求参数绕过 Published-only 规则。

### EX-15 Channel List

**接口与场景**

| 项目 | 内容 |
|---|---|
| Endpoint | `POST /iic-dae-msg/web/msg/template/email/v2/channelList` |
| 页面 | `UI-A-04` Template 创建与编辑 |
| 场景 | 加载 Channel 下拉选项 |

**请求参数与 Mock**

无业务参数。

```json
{}
```

**响应字段与 Mock**

| 字段 | 类型 | 说明 |
|---|---|---|
| `data[].channelCode` | String | Channel 编码 |
| `data[].channelName` | String | 显示名称 |

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

**前端处理与错误**

- 沿用现有缓存、空状态和错误提示，不为 LEAD-93 新增特殊处理。

## 3. 模板保存与生命周期

### EX-05 Save Draft

**接口与场景**

| 项目 | 内容 |
|---|---|
| Endpoint | `POST /iic-dae-msg/web/msg/template/email/v2/add` |
| 页面 | `UI-A-04` Template 创建与编辑 |
| 场景 | 首次保存 V1 Draft；更新已有 Draft；从 Active/Expired 创建 V(N+1) Draft；通过 Save Draft 取消预约 |

**场景参数**

| 场景 | 关键参数 | 结果 |
|---|---|---|
| Save Draft | `isDraft=1` | 始终保存为 Draft；未来时间不会生成 Schedule |
| Cancel Schedule | Schedule version 调用 `isDraft=1` | 同一版本 `0 -> 3`，保留已保存时间 |

**请求参数**

| 字段 | 类型 | 必填 | 说明 |
|---|---|---:|---|
| `emailCode` | String | 条件 | 首次 Save Draft 不传；编辑现有 Template 时传 |
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
|---|---|---|
| `data.emailCode` | String | 首次保存时返回新生成的业务 ID |
| `data.version` | String | 实际保存的 version |

**成功响应 Mock：Save Draft**

```json
{
  "requestId": "mock-request-id",
  "responseCode": "00000000",
  "responseMessage": "Succeed",
  "data": {
    "emailCode": "815645091883520000",
    "version": "V2"
  }
}
```

**前端处理与错误**

- `emailName` 不满足长度、字符白名单或同一主 Category 唯一性时返回字段级错误；前端不得只依赖后端，在输入和提交时执行相同校验。
- Save Draft 的版本分支：新建 V1 Insert；已有 Draft Update；Active 无 Draft时 Insert V(N+1)；仅 Expired 且无 Draft时保留 Expired V(N) 并 Insert V(N+1) Draft；Schedule 时 Update 同一 V(N) 为 Draft。
- Save Draft 不接收 Category/Subcategory/Tag；Template Metadata 通过 `NEW-07` 单独保存。
- 已有 Draft 或 Schedule 时，前端不得创建另一 Draft；编辑或取消预约必须提交目标版本的真实 `version`。
- 附件可选；单个最大 10 MB；前端沿用现有格式校验并排除多媒体、音频和视频。

### EX-16 Publish / Schedule

**接口与场景**

| 项目 | 内容 |
|---|---|
| Endpoint | `POST /iic-dae-msg/web/msg/template/email/v2/publish` |
| 页面 | `UI-A-04` Template 创建与编辑 |
| 场景 | 以页面最新内容发布已有 Draft；或者不先 Save Draft，直接创建并发布全新 Template |

**请求参数**

| 字段 | 类型 | 必填 | 说明 |
|---|---|---:|---|
| `emailCode` | String | 条件 | 发布已有 Draft 时必填；全新未落库 Template 直接 Publish 时不传 |
| `targetVersion` | String | 条件 | 发布已有 Draft 时必填且必须是当前 Draft；全新 Template 不传，成功时固定创建 V1 |
| `emailName` | String | 是 | 页面当前 Template Title；参与完整 Publish Validation |
| `description` | String/null | 是 | 页面当前 Description；按 Publish 规则校验 |
| `title` | String | 是 | 页面当前 Email Subject |
| `emailContent` | String | 是 | 页面当前 AES 加密正文 |
| `emailContentKey` | String/null | 条件 | 正文解密 Key |
| `textContent` | String/null | 否 | 页面当前纯文本正文 |
| `fileKeys` | String/null | 否 | 页面当前附件 Key，逗号分隔 |
| `moduleCode` | String/null | 否 | 页面当前模块编码 |
| `moduleCodeName` | String/null | 否 | 页面当前模块名称 |
| `scenarioCode` | String/null | 否 | 页面当前场景编码 |
| `editMode` | String/null | 否 | 页面当前编辑器模式 |
| `thumbnailKey` | String/null | 否 | 页面当前缩略图 Key |
| `channelMap` | Object/null | 否 | 页面当前 Channel Code 与名称映射 |
| `isCustomBranding` | String | 是 | 页面当前 Branding，`0/1` |
| `categoryId` | String/null | 条件 | 全新 Template 直接 Publish 时必填；已有 Draft 不传并从数据库读取当前值 |
| `subCategoryIds` | String[] | 条件 | 全新 Template 直接 Publish 时提交完整当前快照；已有 Draft 不传 |
| `tagGroups` | Object[] | 条件 | 全新 Template 直接 Publish 时提交完整 4 组当前快照；已有 Draft 不传 |
| `tagGroups[].groupCode` | String | 条件 | 全新 Template 直接 Publish 时必填 |
| `tagGroups[].tagCodes` | String[] | 条件 | 全新 Template 直接 Publish 时必填；空数组表示该组未选择 |
| `effectiveWay` | Integer | 是 | `0=立即发布, 1=预约发布` |
| `effectiveFrom` | DateTime/null | 条件 | `effectiveWay=1`时必填且必须晚于当前南非业务时间；立即发布传 null |

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

**前端处理与错误**

- 当管理端 Detail 的 `copyFromEmailCode` 非空时，前端必须在真正调用本接口前显示非阻断确认框：说明发布 B 不会自动停用来源 Template A，若 A 不应继续使用，CM 需通过现有 Deactivate 操作单独停用 A。用户可取消返回编辑器，也可确认后继续发布。
- Popup 只负责提醒，不调用新的后端接口、不把来源状态作为 Publish 前置条件，也不向 Publish 请求增加确认字段；即使 A 仍为 Active，B 仍可正常发布。
- 发布已有 Draft：后端使用请求中的页面快照校验 Template/Version 字段，并读取该 `emailCode` 的当前 Category/Subcategory/Tag；请求不得覆盖已保存 Metadata。
- 全新 Template 直接 Publish：请求不传 `emailCode/targetVersion`，同时提交首次 Category/Subcategory/Tag 当前快照。Metadata 仍归属于新生成的 `emailCode`，不是 V1 的版本级数据。
- 所有字段校验必须在写入前完成；若现有 Version Conflict 检测命中，也必须在写入前失败。失败时不保存页面内容、不更新原 Draft、不创建新 Version；返回 `invalidFieldCount + fieldErrors[]`。其精确命中条件待专项核实。
- 发布命令必须原子完成页面快照保存和状态切换，任一步失败均不得产生部分结果。
- 全新 Template 校验成功后生成新 `emailCode` 和 V1；V1 直接进入 Active 或 Schedule，不先产生 Draft。
- 立即发布：旧 Active 变 Expired，目标 Draft 以请求快照更新后变 Active，`effectiveFrom=now`、`effectiveUntil=null`。
- 预约发布：目标 Draft 以请求快照更新后变 Schedule，保存未来 `effectiveFrom`；到时由现有 Scheduler 切换状态。
- Version Conflict 沿用现有失败路径；目标 Draft 不存在或状态已变化时整体失败。Active 基线的精确比较规则仍待专项核实，不在本契约虚构字段或错误码。
- 历史 Template 重新 Publish 时同样执行全部必填校验。

### EX-06 Update Template Master Fields

**接口与场景**

| 项目 | 内容 |
|---|---|
| Endpoint | `POST /iic-dae-msg/web/msg/template/email/v2/update` |
| 页面 | `UI-A-04` Template 创建与编辑 |
| 场景 | 保存模板主记录基本信息 |

**请求参数**

| 字段 | 类型 | 必填 | 说明 |
|---|---|---:|---|
| `emailCode` | String | 是 | 模板标识 |
| `emailName` | String | 是 | 当前 Template Name |
| `description` | String/null | 否 | 当前 Description |
| `channelMap` | Object | 否 | 渠道 Map；键为 Channel Code，值为 Channel Name |

**请求 Mock**

```json
{
  "emailCode": "815645091883520000",
  "emailName": "Retirement review invitation",
  "description": "Invitation for the annual retirement review",
  "channelMap": {"EMAIL": "Email"}
}
```

**响应字段与 Mock**

成功时 `data=null`。

```json
{"requestId": "mock-request-id", "responseCode": "00000000", "responseMessage": "Succeed", "data": null}
```

**前端处理与错误**

- 本接口只接收 `emailCode/emailName/description/channelMap`；不得追加 `isCampaign`、`isCustomBranding` 等字段。
- 本接口不修改 Version Subject、正文、附件或生效时间。

### EX-07 Change Status

**接口与场景**

| 项目 | 内容 |
|---|---|
| Endpoint | `POST /iic-dae-msg/web/msg/template/email/v2/changeStatus` |
| 页面 | `UI-A-01` Template Library |
| 场景 | Deactivate；Active/Reactivate |

**请求参数与 Mock**

| 字段 | 类型 | 必填 | 说明 |
|---|---|---:|---|
| `emailCode` | String | 是 | 模板标识 |
| `emailStatus` | Integer | 是 | `0=Inactive, 1=Active` |

```json
{"emailCode": "815645091883520000", "emailStatus": 0}
```

**响应字段与 Mock**

```json
{"requestId": "mock-request-id", "responseCode": "00000000", "responseMessage": "Succeed", "data": null}
```

**前端处理与错误**

- Deactivate 只修改 `config.email_status`，不修改 config.status 或任何 `versionStatus`。
- Reactivate 恢复原 Active 内容，不重新执行 Publish。
- 重复提交相同状态不得改变 Version 或重新执行 Publish。

### EX-08 Delete Template

**接口与场景**

| 项目 | 内容 |
|---|---|
| Endpoint | `POST /iic-dae-msg/web/msg/template/email/v2/delete` |
| 页面 | `UI-A-05` Template Delete |
| 场景 | 删除 Draft Template |

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

- Delete 继续软删除 config 和所有 version；Category/Subcategory/Tag 当前关系不按 version 清理。
- 不修改任何 version 的 `versionStatus`。
- 成功后从列表移除，详情页返回列表；不清理 S3 附件。

### NEW-10 Copy and Create

**接口与场景**

| 项目 | 内容 |
|---|---|
| Endpoint | `POST /iic-dae-msg/web/msg/template/email/v2/copy` |
| 页面 | `UI-A-06` Version History / Copy and Create 后的模板编辑页 |
| 场景 | 从当前最新 Published/Active Version 预填独立模板；首次点击 Save Draft 时创建 Template B |

**前端调用时点**

1. 点击 Copy and Create：前端通过现有 Detail 数据预填页面，不调用 `NEW-10`。
2. 用户可编辑预填字段；默认 `emailName` 为原名称加 `(Copy)`。
3. 首次点击 Save Draft：前端提交完整编辑后快照，调用 `NEW-10`。
4. 成功后使用返回的 `emailCode` 和 `version="V1"` 进入普通 Draft 编辑流程；后续保存使用 `EX-05/EX-10`。
5. B 后续点击 Publish 时，根据 Detail 返回的 `copyFromEmailCode` 显示来源 Template 停用提醒；确认继续后仍调用普通 `EX-16`。

**请求参数**

| 字段 | 类型 | 必填 | 说明 |
|---|---|---:|---|
| `sourceEmailCode` | String | 是 | 来源 Template A；只允许当前 Enabled 且未软删除的 Published Template |
| `sourceVersion` | String | 是 | 前端预填时加载的当前最新 Active Version；保存时后端重新校验仍为当前 Active |
| `emailName` | String | 是 | B 的 Template Title；默认追加 ` (Copy)`，该固定结尾是字符白名单的唯一括号例外；重名返回字段错误，不自动生成 `(Copy 2)` |
| `description` | String/null | 否 | 预填 A 的 Description，允许保存前修改 |
| `moduleCode` | String/null | 否 | 预填 A 的模块编码 |
| `moduleCodeName` | String/null | 否 | 预填 A 的模块名称 |
| `scenarioCode` | String/null | 否 | 预填 A 的场景编码 |
| `channelMap` | Object/null | 否 | 预填 A 的 Channel 信息 |
| `isCustomBranding` | String | 是 | 预填 A 的 Custom Branding；`0/1` |
| `title` | String/null | 否 | B V1 Draft 的 Email Subject |
| `editMode` | String/null | 否 | B V1 Draft 的编辑器模式 |
| `emailContent` | String/null | 否 | B V1 Draft 的加密正文 |
| `emailContentKey` | String/null | 条件 | B V1 Draft 提交加密正文时传入解密 Key |
| `textContent` | String/null | 否 | B V1 Draft 的纯文本正文 |
| `fileKeys` | String/null | 否 | 复用 A Active Version 的附件 Key；不复制 S3 对象或上传记录 |
| `thumbnailKey` | String/null | 否 | 预填的缩略图 Key |
| `categoryId` | String/null | 否 | B 的当前主 Category；保存时必须仍为有效一级节点 |
| `subCategoryIds` | String[] | 否 | B 的全部当前 Subcategory；必须属于 `categoryId` |
| `tagGroups` | Object[] | 否 | B 的全部当前 Tag；Draft 可为空，Trigger 最多 5 个 |
| `tagGroups[].groupCode` | String | 条件 | 提交 `tagGroups` 时必填 |
| `tagGroups[].tagCodes` | String[] | 条件 | 提交 `tagGroups` 时必填；空数组表示该组未选择 |

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

| 字段 | 类型 | 说明 |
|---|---|---|
| `data.emailCode` | String | 后端为 B 生成的新业务标识 |
| `data.version` | String | 固定返回 `V1` |
| `data.versionStatus` | Integer | 固定返回 `3=Draft` |
| `data.emailStatus` | String | B 的当前启停状态，按新建 Draft 现有默认值返回 |

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

| 项目 | 内容 |
|---|---|
| Endpoint | `POST /iic-dae-msg/web/msg/template/email/v2/version/add` |
| 页面 | `UI-A-06` Version History / 增加版本流程 |
| 场景 | 增加目标内容版本，并按发布时间进入 Active 或 Schedule |

**请求参数与 Mock**

| 字段 | 类型 | 必填 | 说明 |
|---|---|---:|---|
| `emailCode` | String | 是 | 模板标识 |
| `version` | String | 是 | 实测新增目标版本传 `V2`，不是源 Active version `V1` |
| `moduleCode` | String/null | 否 | 模块编码 |
| `scenarioCode` | String/null | 否 | 场景编码 |
| `editMode` | String | 是 | 编辑器模式 |
| `title` | String | 是 | Email Subject；新增并发布版本时参与发布校验 |
| `emailContent` | String | 是 | AES 加密正文 |
| `emailContentKey` | String/null | 条件 | 加密正文需要解密 Key 时必填 |
| `textContent` | String/null | 否 | 纯文本正文 |
| `effectiveWay` | Integer | 是 | `0=立即生效, 1=预约生效` |
| `effectiveFrom` | DateTime/null | 条件 | `effectiveWay=1` 时必填 |
| `effectiveUntil` | DateTime/null | 否 | 沿用现有版本字段 |
| `fileKeys` | String/null | 否 | 附件 Key，逗号分隔 |
| `thumbnailKey` | String/null | 否 | 缩略图 Key |
| `isCustomBranding` | String | 是 | `0=No, 1=Yes` |

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

| 字段 | 类型 | 说明 |
|---|---|---|
| `requestId` | String | 请求追踪标识 |
| `responseCode` | String | 成功时为 `00000000` |
| `responseMessage` | String | 成功时为 `Succeed` |
| `data.emailCode` | String | 模板标识 |
| `data.version` | String | 新增的目标版本号 |
| `data.versionStatus` | Integer | 新版本最终状态 |

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

- 本接口只表达“同一 `emailCode` 增加版本并切换 Active”的现有语义，不承担 Copy and Create；独立模板复制使用 `NEW-10`。
- 新版本正文、Published Validation 和状态切换必须在同一事务中完成；当前 Template Metadata 不随版本复制。

### EX-10 Update Version

**接口与场景**

| 项目 | 内容 |
|---|---|
| Endpoint | `POST /iic-dae-msg/web/msg/template/email/v2/version/update` |
| 页面 | `UI-A-04` Template 创建与编辑 |
| 场景 | 更新已有 Draft/Schedule version 内容 |

**请求参数**

| 字段 | 类型 | 必填 | 说明 |
|---|---|---:|---|
| `emailCode` | String | 是 | 模板标识 |
| `version` | String | 是 | 目标 version |
| `moduleCode` | String/null | 否 | 模块编码 |
| `scenarioCode` | String/null | 否 | 场景编码 |
| `editMode` | String/null | 否 | 编辑器模式 |
| `title` | String/null | 否 | Email Subject；Draft 允许为空 |
| `emailContent` | String/null | 否 | AES 加密正文；Draft 允许为空 |
| `emailContentKey` | String/null | 条件 | 加密正文需要解密 Key 时传入 |
| `textContent` | String/null | 否 | 纯文本正文 |
| `effectiveWay` | Integer/null | 否 | Draft/Schedule 已保存的生效方式 |
| `effectiveFrom` | DateTime/null | 否 | Draft/Schedule 已保存的生效时间 |
| `effectiveUntil` | DateTime/null | 否 | Draft/Schedule 已保存的失效时间 |
| `fileKeys` | String/null | 否 | 附件 Key，逗号分隔 |
| `thumbnailKey` | String/null | 否 | 缩略图 Key |
| `isCustomBranding` | String/null | 否 | `0=No, 1=Yes` |

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

**前端处理与错误**

- Version Update 只处理版本内容和时间字段，不修改 Template 当前 Metadata。
- 后端 Update 影响 0 行时返回失败；前端提示刷新，不显示保存成功。
- Schedule 期间保存草稿会把同一 version 更新为 Draft；不创建新 version。

### EX-11 Delete Version

**接口与场景**

| 项目 | 内容 |
|---|---|
| Endpoint | `POST /iic-dae-msg/web/msg/template/email/v2/version/delete` |
| 页面 | `UI-A-04` Template 创建与编辑、`UI-A-06` Version History |
| 场景 | Cancel 已保存 Working Copy；删除 Draft/Schedule version；Cancel Schedule by Delete |

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
- 已保存 Working Copy 的 Cancel 调用本接口并软删除 Draft；未保存编辑的 Cancel 仅由前端丢弃页面状态，不调用后端。
- 删除 Active/Published version 时返回 `responseCode="10000121"`、`responseMessage="Operation failed. The version has been published."`；前端必须按业务码判定失败。
- 成功后回到列表；附件仍保留在 S3，不执行清理。

### EX-12 Get Max Version

**接口与场景**

| 项目 | 内容 |
|---|---|
| Endpoint | `GET /iic-dae-msg/web/msg/template/email/v2/version/getMaxVersion?emailCode={emailCode}` |
| 页面 | `UI-A-04` Template 创建与编辑、`UI-A-06` Version History |
| 场景 | 获取模板的最大数字版本 |

**请求参数**

| 位置 | 字段 | 类型 | 必填 |
|---|---|---|---:|
| Query | `emailCode` | String | 是 |

**请求 Mock**

```text
GET /iic-dae-msg/web/msg/template/email/v2/version/getMaxVersion?emailCode=815645091883520000
```

**响应字段**

| 字段 | 类型 | 说明 |
|---|---|---|
| `data.emailCode` | String | Template 标识 |
| `data.version` | String | 最大数字版本 |
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

**前端处理与错误**

- 后端必须按版本数字比较，不能按 `V10 < V2` 的字符串顺序。
- 不存在 version 时沿用现有空响应/错误行为。

### EX-13 Version Detail

**接口与场景**

| 项目 | 内容 |
|---|---|
| Endpoint | `POST /iic-dae-msg/web/msg/template/email/v2/version/detail` |
| 页面 | `UI-A-04` Template 创建与编辑、`UI-A-06` Version History |
| 场景 | 加载明确指定的版本内容 |

**请求参数与 Mock**

| 字段 | 类型 | 必填 | 说明 |
|---|---|---:|---|
| `emailCode` | String | 是 | 模板标识 |
| `version` | String | 是 | 目标 version；不得自动改选 |

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

**前端处理与错误**

- version 不存在或已软删除时提示刷新，不回退查询其他 version。
- 本接口只返回指定内容 Version，不返回历史 Template 属性快照。

### EX-14 Version History

**接口与场景**

| 项目 | 内容 |
|---|---|
| Endpoint | `POST /iic-dae-msg/web/msg/template/email/v2/version/list/history` |
| 页面 | `UI-A-06` Version History |
| 场景 | 加载版本历史分页列表 |

**请求参数与 Mock**

| 字段 | 类型 | 必填 | 说明 |
|---|---|---:|---|
| `emailCode` | String | 是 | 模板标识 |
| `pageNum` | Integer | 否 | 当前页码，默认 `1` |
| `pageSize` | Integer | 否 | 每页数量，默认 `20` |
| `isAsc` | Boolean | 否 | `true=升序, false=降序` |

```json
{
  "emailCode": "815645091883520000",
  "pageNum": 1,
  "pageSize": 20,
  "isAsc": false
}
```

**响应字段与 Mock**

| 字段 | 类型 | 说明 |
|---|---|---|
| `data.pageNo` | Integer | 当前页码 |
| `data.pageSize` | Integer | 每页数量 |
| `data.totalCount` | Long | 总记录数 |
| `data.totalPage` | Integer | 总页数 |
| `data.dataList[].emailCode` | String | 模板标识 |
| `data.dataList[].version` | String | 版本号 |
| `data.dataList[].versionStatus` | Integer | 版本状态 |
| `data.dataList[].updatedBy` | String | 更新人 |
| `data.dataList[].updatedDate` | DateTime | 更新时间 |

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

**前端处理与错误**

- 首次发布不额外创建 V2：同一 V1 从 Draft 变为 Active，并作为 V1 历史记录显示。
- Version History 只展示内容版本历史，不混入 Template 基本信息和 Category/Tag 修改记录。

## 5. 分类管理

### NEW-01 Category Tree

**接口与场景**

| 项目 | 内容 |
|---|---|
| Endpoint | `GET /iic-dae-msg/web/msg/template/email/v2/category/tree` |
| 页面 | `UI-A-07` Category 管理列表、`UI-A-10` Category 删除与迁移、`UI-A-01` Template Library、`UI-A-04` Template 创建与编辑 |
| 场景 | 加载管理树；加载筛选项；加载模板分类选择；加载迁移目标 |

**请求参数与 Mock**

无业务参数。

```text
GET /iic-dae-msg/web/msg/template/email/v2/category/tree
```

**响应字段**

| 字段 | 类型 | 说明 |
|---|---|---|
| `data[].id` | String | 节点 ID；后端 Long 在 JSON 边界序列化为 String |
| `data[].categoryName` | String | 显示名 |
| `data[].parentId` | String/null | 一级为 `0/null`，二级为父 Category ID |
| `data[].sortOrder` | Integer | 同级排序 |
| `data[].children` | Object[] | 二级节点；无节点返回 `[]` |
| `data[].templateCount` | Integer | 当前节点关联 Template 数量 |
| `data[].leaf` | Boolean | 是否叶子节点 |

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
      "templateCount": 8,
      "leaf": false,
      "children": [{
        "id": "1101",
        "categoryName": "Advice Review",
        "parentId": "1001",
        "sortOrder": 1,
        "templateCount": 3,
        "leaf": true,
        "children": []
      }]
    }]
}
```

**前端处理与错误**

- 只返回有效节点；软删除节点不用于新建、编辑、筛选或迁移目标。
- 固定两级；前端不推导或展示第三级。
- Category 层级由后端根据 `parentId` 推导，前端不提交持久化层级字段。
- `id` 是 Category/Subcategory 唯一标识；Contract 不提供或接收 `categoryCode`。

### NEW-02 Create Category

**接口与场景**

| 项目 | 内容 |
|---|---|
| Endpoint | `POST /iic-dae-msg/web/msg/template/email/v2/category` |
| 页面 | `UI-A-08` Create Category/Subcategory |
| 场景 | 创建一级 Category |

**请求参数与 Mock**

| 字段 | 类型 | 必填 | 说明 |
|---|---|---:|---|
| `categoryName` | String | 是 | 有效节点全局唯一 |
| `parentCategoryId` | String | 是 | 创建一级 Category 固定传 `"0"`；批量创建 Subcategory 使用 `NEW-08` |

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
    "templateCount": 0,
    "leaf": true,
    "children": []
  }
}
```

**前端处理与错误**

- 名称为空或与任一有效 Category/Subcategory 重复时显示字段错误。
- 软删除后允许重新创建同名节点。
- `categoryId` 由数据库生成，前端创建时不传；后续编辑、排序和删除使用返回的 `categoryId`。

### NEW-03 Update Category/Subcategory

**接口与场景**

| 项目 | 内容 |
|---|---|
| Endpoint | `PUT /iic-dae-msg/web/msg/template/email/v2/category/{id}` |
| 页面 | `UI-A-09` Edit Category/Subcategory |
| 场景 | 编辑 Category 或 Subcategory 的 Name |

**请求参数与 Mock**

| 位置 | 字段 | 类型 | 必填 | 说明 |
|---|---|---|---:|---|
| Path | `id` | String | 是 | 目标节点 |
| Body | `categoryName` | String | 是 | 新名称 |

```json
{"categoryName": "Client Engagement"}
```

**响应字段与 Mock**

更新成功返回 `data=null`。前端随后重新加载 Category Tree。

```json
{"requestId":"mock-request-id","responseCode":"00000000","responseMessage":"Succeed","data":null}
```

**前端处理与错误**

- 本期不支持把已有 Subcategory 移到另一 Category。
- 目标不存在、已删除或名称与有效节点重复时失败，页面保留原值。

### NEW-12 Delete Unreferenced Category/Subcategory

**接口与场景**

| 项目 | 内容 |
|---|---|
| Endpoint | `DELETE /iic-dae-msg/web/msg/template/email/v2/category/{categoryId}` |
| 页面 | `UI-A-10` Category 删除与迁移 |
| 场景 | 删除没有 Active/Draft/Schedule Template 引用的 Category/Subcategory |

**请求参数与 Mock**

| 位置 | 字段 | 类型 | 必填 | 说明 |
|---|---|---|---:|---|
| Path | `categoryId` | String | 是 | 待软删除节点 |

```text
DELETE /iic-dae-msg/web/msg/template/email/v2/category/1001
```

**响应字段与 Mock**

```json
{"requestId":"mock-request-id","responseCode":"00000000","responseMessage":"Succeed","data":null}
```

**前端处理与错误**

- 前端先调用 `NEW-09`。不存在 Active/Draft/Schedule 引用时调用本接口；存在引用时必须调用 `NEW-04`。
- 仅有 Expired Version 的 Template 不阻止删除，历史内容和 Version 状态保持不变。
- 后端仍需在事务内重新检查引用，不能信任此前的 Impact 结果。
- 成功时软删除节点；节点不存在、已删除或出现并发引用时返回业务失败。

### NEW-04 Reassign and Delete

**接口与场景**

| 项目 | 内容 |
|---|---|
| Endpoint | `POST /iic-dae-msg/web/msg/template/email/v2/category/reassign-and-delete` |
| 页面 | `UI-A-10` Category 删除与迁移 |
| 场景 | 有引用时迁移“存在 Active/Draft/Schedule 的 Template”的当前 Metadata 后删除节点 |

**请求参数与 Mock**

| 位置 | 字段 | 类型 | 必填 | 说明 |
|---|---|---|---:|---|
| Body | `sourceCategoryId` | String | 是 | 待删除 Category/Subcategory |
| Body | `targetCategoryId` | String | 是 | 有效目标一级 Category |
| Body | `targetSubcategoryIds` | String[] | 否 | 目标子分类完整集合 |

```json
{
  "sourceCategoryId": "1001",
  "targetCategoryId": "2001",
  "targetSubcategoryIds": ["2101"]
}
```

**响应字段与 Mock**

成功时返回 `data=null`；前端重新加载 Category Tree 和 Template List。

```json
{
  "requestId": "mock-request-id",
  "responseCode": "00000000",
  "responseMessage": "Succeed",
  "data": null
}
```

**前端处理与错误**

- 不允许前端循环调用 `NEW-07` 迁移单个 Template。
- 只要 Template 存在 Active、Draft 或 Schedule version，就迁移其一套当前 Metadata；仅有 Expired version 的 Template 不迁移。
- Template Reassignment 与 Category 删除必须原子完成，任一步失败均不得产生部分迁移结果。
- 目标失效、位于待删除子树、层级不匹配、更新 0 行或并发数量变化时整体失败；前端刷新影响范围后重试。

### NEW-05 Reorder Category

**接口与场景**

| 项目 | 内容 |
|---|---|
| Endpoint | `PUT /iic-dae-msg/web/msg/template/email/v2/category/reorder` |
| 页面 | `UI-A-07` Category 管理列表 |
| 场景 | 保存 Category 或同一父 Category 下 Subcategory 的前端排序 |

**请求参数与 Mock**

| 字段 | 类型 | 必填 | 说明 |
|---|---|---:|---|
| `categoryId` | String | 是 | 同级节点 ID |
| `sortOrder` | Integer | 是 | 目标顺序，从 1 开始连续编号 |

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

**前端处理与错误**

- 只提交同一级、同一 Parent 的有效节点。
- 拖拽过程中不调用接口；完成一次 Drop 后提交该 Parent 下全部有效同级节点的完整顺序。
- 后端会锁定并比较完整同级 ID 集合，再把数组位置保存为连续 `sortOrder=1..N`；不接受局部 Patch。
- 若加载后发生新增、删除或并发排序，后端返回排序数据已过期的业务失败。前端必须重新加载 Category Tree，不自动重放旧顺序。
- 保存成功后重新加载 Category Tree；其他失败恢复原顺序或重新加载树，不在前端假设部分成功。

### NEW-08 Batch Create Subcategories

**接口与场景**

| 项目 | 内容 |
|---|---|
| Endpoint | `POST /iic-dae-msg/web/msg/template/email/v2/category/batch-subcategories` |
| 页面 | `UI-A-08` Create Category/Subcategory、`UI-A-04` Template 创建与编辑 |
| 场景 | 在有效 Category 下一次创建 1-5 个 Subcategory |

**请求参数与 Mock**

| 位置 | 字段 | 类型 | 必填 | 说明 |
|---|---|---|---:|---|
| Body | `parentId` | String | 是 | 有效一级 Category |
| Body | `subcategories` | Object[] | 是 | 1-5 项 |
| Item | `name` | String | 是 | 全局有效名称唯一 |

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
    {"id": "5000", "categoryName": "Advice Review", "parentId": "1001", "sortOrder": 1, "templateCount": 0, "leaf": true, "children": []},
    {"id": "5001", "categoryName": "Annual Check-in", "parentId": "1001", "sortOrder": 2, "templateCount": 0, "leaf": true, "children": []}
  ]
}
```

**前端处理与错误**

- 数组为空、超过 5 条、批内重名、与有效节点重名或 Parent 非法时整批失败。
- 前端不能把失败请求拆成逐条重试，以免破坏原子语义。

### NEW-09 Category Delete Impact

**接口与场景**

| 项目 | 内容 |
|---|---|
| Endpoint | `POST /iic-dae-msg/web/msg/template/email/v2/category/delete-impact/{categoryId}` |
| 页面 | `UI-A-10` Category 删除与迁移 |
| 场景 | 点击 Delete 后展示子节点、Template 和当前生命周期影响数量 |

**请求参数**

| 位置 | 字段 | 类型 | 必填 |
|---|---|---|---:|
| Path | `categoryId` | String | 是 |

**请求 Mock**

```text
POST /iic-dae-msg/web/msg/template/email/v2/category/delete-impact/1001
```

**响应字段与 Mock**

| 字段 | 类型 | 说明 |
|---|---|---|
| `data.sourceCategoryId` | String | 源节点 ID |
| `data.sourceLevel` | Integer | 源节点层级 |
| `data.childCount` | Integer | 子节点数量 |
| `data.templateCount` | Integer | 受影响 Template 总数 |
| `data.activeTemplateCount` | Integer | 存在 Active version 的 Template 数 |
| `data.draftTemplateCount` | Integer | 存在 Draft version 的 Template 数 |
| `data.scheduleTemplateCount` | Integer | 存在 Schedule version 的 Template 数 |

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
    "activeTemplateCount": 2,
    "draftTemplateCount": 1,
    "scheduleTemplateCount": 0
  }
}
```

**前端处理与错误**

- Impact 结果只用于确认框，不保证提交时数量不变。
- `NEW-04` 执行时后端会重新查询并锁定真实影响范围。
- 目标不存在或已删除时关闭确认框并刷新 Category Tree。

## 6. 标签与模板元数据

### NEW-06 Tag Taxonomy

**接口与场景**

| 项目 | 内容 |
|---|---|
| Endpoint | `GET /iic-dae-msg/web/msg/template/email/v2/category/taxonomy` |
| 页面 | `UI-A-11` Tag Assignment、`UI-A-01` Template Library Tag Filter |
| 场景 | 加载模板标签选择；加载列表标签筛选项 |

**请求参数与 Mock**

无业务参数。

```text
GET /iic-dae-msg/web/msg/template/email/v2/category/taxonomy
```

**响应字段**

| 字段 | 类型 | 说明 |
|---|---|---|
| `data[].groupCode` | String | 固定 Group 编码 |
| `data[].groupName` | String | Group 显示名 |
| `data[].isMandatory` | Integer | `1=Publish 必填, 0=可选` |
| `data[].maxSelections` | Integer/null | 组内最大选择数；Trigger 为 `5`，`null` 表示当前不限制 |
| `data[].sortOrder` | Integer | Group 排序 |
| `data[].tagValues[].tagCode` | String | 固定 Tag Value 编码 |
| `data[].tagValues[].tagName` | String | 显示名 |
| `data[].tagValues[].description` | String/null | Tag Taxonomy 中的可选说明 |
| `data[].tagValues[].sortOrder` | Integer | Value 排序 |

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

**前端处理与错误**

- Taxonomy 由固定 DB seed 维护，前端不提供 Tag 管理 CRUD。
- 每个 Group 均可多选；同组筛选 OR，不同组筛选 AND。
- 前端按 `maxSelections` 限制选择数量；Trigger 为 5，`null` 表示当前不限制。
- 4 个 Mandatory Group；前端不把 `isMandatory` 写死在页面代码中。
- 示例只展示代表性 Tag Value；前端必须按接口返回的完整数组动态展示选项。
- Template 当前 Tag 可以暂时不完整，不自动生成 `Unclassified`；Publish 时再根据 `isMandatory=1` 阻止缺失项。Metadata 修改只依赖已存在的 `emailCode`，不属于任何 Version 状态。

### NEW-07 Update Template Metadata

**接口与场景**

| 项目 | 内容 |
|---|---|
| Endpoint | `POST /iic-dae-msg/web/msg/template/email/v2/category/metadata` |
| 页面 | `UI-A-04` Template 创建与编辑、`UI-A-11` Template 当前属性编辑 |
| 场景 | 更新 Template 当前 Category/Subcategory/Tag；单 Template Reassignment |

**请求参数**

| 位置 | 字段 | 类型 | 必填 | 说明 |
|---|---|---|---:|---|
| Body | `emailCode` | String | 是 | 模板标识 |
| Body | `categoryId` | String/null | 是 | Template 当前主 Category；Publish 前必填 |
| Body | `subCategoryIds` | String[] | 是 | 完整快照；空数组表示清空 |
| Body | `tagGroups` | Object[] | 是 | 必须包含完整 4 组快照；字段或任一 Group 缺失均失败 |
| Item | `groupCode` | String | 是 | Group 编码 |
| Item | `tagCodes` | String[] | 是 | 空数组表示清空该组；Trigger 去重后最多 5 个 |

**请求 Mock**

```json
{
  "emailCode": "815645091883520000",
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

返回更新结果及关系数量；前端以已提交快照更新本地状态，必要时重新加载 Detail。

```json
{
  "requestId": "mock-request-id",
  "responseCode": "00000000",
  "responseMessage": "Succeed",
  "data": {
    "emailCode": "815645091883520000",
    "categoryId": "1001",
    "subCategoryIds": ["1101"],
    "categoryRelationCount": 1,
    "tagGroupCount": 4,
    "tagRelationCount": 4,
    "status": "success"
  }
}
```

**前端处理与错误**

- 请求只以 `emailCode` 定位 Template 当前 Metadata，不得提交或使用 `version`。
- 任意 Group 空数组都表示清空该组。Publish/Schedule 再从数据库读取当前 Metadata 并校验 Mandatory Group。
- Trigger 去重后的 `tagCodes` 超过 5 个时整体失败；字段为 `tagGroups.TRIGGER`，错误文案为“Trigger 最多选择 5 个”。
- Tag 重复、Group 不匹配、Subcategory 层级错误或 Template 不存在时整体失败，原 Metadata 不变。
- 本接口不创建新版本，也不改变任何 `versionStatus`。
- 页面允许修改当前 Category/Subcategory/Tag 时调用本接口，保存成功后 Template Library 按新目录和 Tag 查询结果展示。Save Draft/Version API 仍不接收 Metadata；首次 Save Draft 取得 `emailCode` 前不能调用本接口。
- Metadata 不属于 Draft；本接口采用全量替换语义，每次请求必须提交完整 `categoryId`、`subCategoryIds` 和全部 `tagGroups`，不能把字段缺失解释为保持原值。

### NEW-11 Batch Template Reassignment

**接口与场景**

| 项目 | 内容 |
|---|---|
| Endpoint | `POST /iic-dae-msg/web/msg/template/email/v2/reassign` |
| 页面 | `UI-A-11` Template Library 批量重新分类操作 |
| 场景 | 一次全量替换一个或多个 Template 的当前 Category/Subcategory/Tag |

**请求参数**

| 字段 | 类型 | 必填 | 说明 |
|---|---|---:|---|
| `templates` | Object[] | 是 | 至少一项；整批成功或整批失败 |
| `templates[].emailCode` | String | 是 | Template 标识 |
| `templates[].categoryId` | String/null | 是 | 当前主 Category；Draft 可为空，Published 必须有效 |
| `templates[].subCategoryIds` | String[] | 是 | 当前 Subcategory 完整快照 |
| `templates[].tagGroups` | Object[] | 是 | 当前 4 个 Tag Group 完整快照 |
| `templates[].tagGroups[].groupCode` | String | 是 | Group 编码 |
| `templates[].tagGroups[].tagCodes` | String[] | 是 | Tag Code 完整列表；空数组表示清空该组 |

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

**前端处理与错误**

- 任一 Template 校验或更新失败时整批回滚。
- 不创建或删除 Version，不改变 `versionStatus/effectiveFrom/effectiveUntil`，也不修改正文和附件。
- 本接口用于用户主动批量重分配，不能替代 `NEW-04` 的 Category 迁移并删除事务。

## 7. 通用错误约定

失败响应使用公共包络，业务失败返回 HTTP 200。前端以 `responseCode="00000000"` 判断成功，其他值均按业务失败处理；Version Conflict 沿用现有失败响应。

下表名称仅用于标识错误场景，不是实际 `responseCode`。真实 `responseCode` 和 `responseMessage` 必须以 QA 环境实测结果为准；前端只有在实测值已登记后才能按具体错误码分支处理。

| 错误场景标识 | 使用场景 |
|---|---|
| `VALIDATION_FAILED` | 通用字段校验或 Publish 完整性校验失败 |
| `VERSION_CONFLICT` | 版本状态已变化、已有 Draft/Schedule 或并发冲突 |
| `COPY_SOURCE_NOT_ACTIVE` | Copy 来源不存在、已停用/删除，或提交的 `sourceVersion` 已不再是当前最新 Active |
| `CATEGORY_NOT_FOUND` | Category/Subcategory 不存在或已软删除 |
| `CATEGORY_NAME_DUPLICATE` | 与任一有效 Category/Subcategory 名称重复 |
| `CATEGORY_LEVEL_INVALID` | Parent、层级或跨 Parent 操作非法 |
| `CATEGORY_IN_USE` | 节点存在有效引用但未提供迁移目标 |
| `CATEGORY_TARGET_INVALID` | 迁移目标失效、位于待删除子树或层级不匹配 |
| `CATEGORY_CONCURRENT_MODIFICATION` | 影响数量或节点状态在提交前发生变化 |
| `CATEGORY_ORDER_STALE` | Reorder 请求的完整同级节点集合与数据库当前集合不一致 |
| `TAG_VALUE_INVALID` | Tag/Group 不存在、失效或归属错误 |
| `METADATA_VALIDATION_FAILED` | Metadata 快照缺字段、缺 Group 或 Published 必填项不完整 |
| `PERMISSION_DENIED` | 当前用户无权执行该查询或写操作 |

**字段校验失败**

```json
{
  "requestId": "mock-request-id",
  "responseCode": "QA_TESTED_ERROR_CODE",
  "responseMessage": "2 fields must be completed before publishing",
  "data": {
    "invalidFieldCount": 2,
    "fieldErrors": [
      {"field": "emailName", "code": "REQUIRED", "message": "Title is required"},
      {"field": "categoryId", "code": "REQUIRED", "message": "Category is required"}
    ]
  }
}
```

该响应只在 Publish/Publish Future 完整校验失败时返回。前端使用 `fieldErrors[].field` 定位表单控件，使用 `invalidFieldCount` 生成顶部摘要；Save Draft 不执行这组 Published 必填校验。失败请求不保存本次页面内容，原 Draft、旧 Active 和 Version History 均保持不变。

**Trigger 超过 5 个**

```json
{
  "requestId": "mock-request-id",
  "responseCode": "QA_TESTED_ERROR_CODE",
  "responseMessage": "Metadata validation failed",
  "data": {
    "fieldErrors": [
      {"field": "tagGroups.TRIGGER", "code": "MAX_SELECTIONS", "message": "Trigger supports up to 5 selections"}
    ]
  }
}
```

**版本冲突**

```json
{"requestId":"mock-request-id","responseCode":"QA_TESTED_ERROR_CODE","responseMessage":"Template version has changed; refresh and retry","data":null}
```

**无权限**

```json
{"requestId":"mock-request-id","responseCode":"QA_TESTED_ERROR_CODE","responseMessage":"You do not have permission to perform this action","data":null}
```

## 8. 页面与接口地图

截图只用于定位页面和操作入口，字段与行为以对应 Endpoint 章节为准。

| 页面编号 | 页面/操作 | 关联 Endpoint |
|---|---|---|
| `UI-A-01` | Template Library Published/Search/Filter | `EX-01` |
| `UI-A-02` | Draft/Admin Template List | `EX-02` |
| `UI-A-03` | Template Detail/Preview | `EX-03`、`EX-04` |
| `UI-A-04` | Template 创建、编辑、Save Draft/Publish | `EX-05`、`EX-16`、`EX-06`、`EX-10`、`NEW-07` |
| `UI-A-05` | Template Delete | `EX-08` |
| `UI-A-06` | Version History / Copy and Create | `EX-09`、`EX-11`、`EX-12`、`EX-13`、`EX-14`、`NEW-10` |
| `UI-A-07` | Category 管理列表 | `NEW-01`、`NEW-05` |
| `UI-A-08` | Create Category/Subcategory | `NEW-02`、`NEW-08` |
| `UI-A-09` | Edit Category/Subcategory | `NEW-03` |
| `UI-A-10` | Category 删除、影响检查与迁移 | `NEW-12`、`NEW-04`、`NEW-09` |
| `UI-A-11` | Tag Assignment、批量 Reassignment 与模板元数据 | `NEW-06`、`NEW-07`、`NEW-11` |

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
