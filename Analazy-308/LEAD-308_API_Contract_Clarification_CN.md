# LEAD-308 Adviser Template Library Web API Contract

> 状态：自包含开发与评审基线  
> 更新日期：2026-07-17  
> 需求基线：`PRD_LEAD-308 Advisor-Template Management_v1.1 -updated July 14th.docx`  
> 共享接口来源：LEAD-93 Web v2 Contract  
> 未确认项：[LEAD-308 未确认项登记册](LEAD-308_Open_Questions_Register_CN.md)

## 1. 先看结论：308 到底用了什么、改了什么

LEAD-308 不再使用第二套 `A308-*` 编号，直接沿用 LEAD-93 的接口编号。开发和测试只需要阅读本文，不需要为了理解 308 的调用方式来回切换 93 文档。

### 1.1 接口总览

| LEAD-93 接口 | Endpoint | 308 用在哪里 | 308 是否修改接口 | 结论 |
|---|---|---|---|---|
| `EX-01` Published List | `POST /iic-dae-msg/web/msg/template/email/v2/queryList` | Card List、Search、Category/Tag Filter、Sort、Pagination | **基础查询不改；部分 PRD 能力待扩展** | 直接复用 Metadata Search/Filter；Thumbnail、Published Date、Most Relevant、Facet、混合 Email/Campaign 尚未满足 |
| `EX-04` Adviser Published Detail | `POST /iic-dae-msg/web/msg/template/email/v2/published/detail` | Detail、Preview、Use Template 前重校验 | **接口不改，只增加 308 调用场景** | 同一个 `{emailCode}` 请求用于三个入口；Preview 忽略附件字段 |
| `NEW-01` Category Tree | `GET /iic-dae-msg/web/msg/template/email/v2/category/tree` | 左侧 Category/Subcategory Navigation | **树查询不改；Count 待扩展** | 树和顺序可直接复用；Published Template Count 不是现有字段 |
| `NEW-06` Tag Taxonomy | `GET /iic-dae-msg/web/msg/template/email/v2/tag/taxonomy` | Filter Panel | **Taxonomy 不改；可用值/Count 待扩展** | 308 前端只展示 4 个 Mandatory Group；“只显示已使用值”不是现有能力 |
| 无 | 无独立 Preview API | Preview | **不新增** | `EX-04` + 现有 Renderer；正文和 Metadata，不显示附件 |
| 无 | 无独立 Use API | Use Template | **当前不新增** | `EX-04` 重读 Active 后由前端进入 Email/Campaign 下游；下游 Contract 待确认 |

### 1.2 修改类型定义

| 类型 | 含义 | 本项目接口 |
|---|---|---|
| `完全复用` | Method、Path、Request、Response 和后端行为均不因 308 改变 | `EX-04` 基础 Detail、`NEW-01` 基础 Tree、`NEW-06` 基础 Taxonomy |
| `调用方式变化` | 接口不改，但 308 页面在新的时机或用途调用 | `EX-04` 用于 Preview 和 Use 前重校验 |
| `需要扩展` | 308 PRD 要求超出 93 当前 Contract；必须先冻结字段/口径 | `EX-01` Card/Sort/Facet；`NEW-01` Count；Tag 可用值 |
| `不新增接口` | 需求通过既有接口和前端编排完成 | Preview、Use Template 当前方案 |

**因此，308 当前不是“新增 4 个 API”。它使用 4 个 LEAD-93 v2 API：其中基础能力可复用，只有明确列出的 PRD Gap 需要修改。**

## 2. 页面实际怎么调用

### 2.1 首次进入 Template Library

| 顺序 | 前端动作 | 调用接口 | 返回用途 | 是否等待其他接口 |
|---:|---|---|---|---|
| 1 | 加载 Category Tree | `NEW-01` | 左侧两级 Category/Subcategory | 可与步骤 2、3 并行 |
| 2 | 加载 Tag Taxonomy | `NEW-06` | Filter Panel；前端只保留 4 个 Mandatory Group | 可与步骤 1、3 并行 |
| 3 | 加载 Published Cards | `EX-01` | Card List、分页 | 页面核心请求 |

### 2.2 搜索、筛选和排序

所有条件都重新调用 `EX-01`，不调用另一套 Adviser List API：

```text
Search / Category / Subcategory / Tag / Sort / Page changed
                         │
                         ▼
               POST v2/queryList (EX-01)
                         │
                         ▼
              Replace Card List + Pagination
```

前端使用 300ms debounce；每次条件改变把 `pageNum` 重置为 1。旧请求晚于新请求返回时不得覆盖当前页面状态。

### 2.3 打开 Detail 或 Preview

| 用户动作 | 调用 | 308 使用方式 |
|---|---|---|
| 点击 Card/Detail | `EX-04 {emailCode}` | 显示当前 Active 的正文和 Metadata |
| 点击 Preview | `EX-04 {emailCode}` | 使用返回正文调用现有 Renderer；忽略附件 |
| Preview Close/Back | 不调用 Template 写接口 | 恢复 Search、Filter、Sort、Page 和 Scroll Position |

### 2.4 点击 Use Template

```text
Click Use Template
       │
       ▼
EX-04 {emailCode} 重新解析当前 Active
       │
       ├── 不可见 / 已停用 / 已删除 / 无 Active ──> 保留 Library，提示刷新
       │
       └── 可用
             ├── isCampaign = 0 ──> Email Composer
             └── isCampaign = 1 ──> Campaign Creation
```

这里复用 `EX-04` 是为了避免使用列表缓存中的旧 version。进入 Email/Campaign 之后如何初始化属于下游 Contract，尚未冻结。

## 3. 公共 Contract

| 项目 | 约定 |
|---|---|
| 网关前缀 | `/iic-dae-msg` |
| v2 Controller 前缀 | `/web/msg/template/email/v2` |
| 响应包络 | `IICResponseModel<T>`：`requestId/responseCode/responseMessage/data` |
| 成功业务码 | `responseCode="00000000"`、`responseMessage="Succeed"` |
| 分页 | 请求 `pageNum/pageSize`；响应 `pageNo/pageSize/totalCount/totalPage/dataList` |
| 时间 | `yyyy-MM-dd HH:mm:ss`；`Africa/Johannesburg`（UTC+02:00） |
| 64 位 ID | `emailCode`、Category ID 在 JavaScript 中按 String |
| 身份范围 | 后端从登录态解析 Adviser、tenant 和 country，不接受客户端伪造 |
| Adviser 状态参数 | 不接受 `status/versionStatus/version/includeDraft` |

请求头沿用现有基线：`authorization`、`x-apigw-api-id`、`content-type: application/json`、`language: en-US`、每次唯一 `requestid`。

## 4. EX-01 Published List

### 4.1 这个接口在 93 和 308 中有什么不同

| 对比项 | LEAD-93 Contract | LEAD-308 使用/变化 | 是否需要改代码 |
|---|---|---|---|
| Endpoint | v2 `queryList` | 完全相同 | 否 |
| Published-only | 返回有效、启用的 Active version | Adviser 强制使用，前端不能传 Status | 基础逻辑复用 |
| Email/Campaign | `isCampaign` 必传，只查一种格式 | PRD 页面可能希望混合展示两种格式 | **待确认后修改** |
| Search | Title、Description、Tag Name | 完全相同；前端增加 2 字符和 debounce | 后端不改，前端改 |
| Category/Subcategory | 已支持 `categoryId/subcategoryIds` | Adviser 导航和 Filter 直接使用 | 否 |
| Tag Filter | 已支持 `tagGroups`，同组 OR、跨组 AND | 308 只让用户选择 4 个 Mandatory Group | 后端不改，前端限制 |
| Status Filter | Published 不提供 Status | 308 同样不展示/不提交 | 否 |
| Sort | `sortField/isAsc` | PRD 增加 Most Relevant、Published Date Sort | **需要扩展，尚未冻结** |
| Card | 返回基本信息与 Metadata | PRD 还要 Thumbnail、明确 Published Date | **需要扩展，尚未冻结** |
| Facet | 没有 Count/可用值 | PRD 要 Category Count 和仅显示可用 Tag | **需要扩展，尚未冻结** |

### 4.2 当前可直接使用的 Request

| 字段 | 类型 | 必填 | 308 怎么使用 | 与 93 是否不同 |
|---|---|---:|---|---|
| `isCampaign` | Integer | 是 | 当前只能传 `0` 或 `1` | 不同点只在 308 UX 尚未决定是否混合 |
| `emailName` | String | 否 | Search Keyword；匹配 Title、Description、Tag Name | 相同 |
| `categoryId` | String | 否 | 当前主 Category，单选 | 相同 |
| `subcategoryIds` | String[] | 否 | 当前 Subcategory，多选 | 相同 |
| `tagGroups` | Object[] | 否 | 只提交 4 个 Mandatory Group 中的选择 | Contract 相同，UI 子集不同 |
| `channelList` | String[] | 否 | 308 PRD 未要求 Channel Filter，提交空数组 | 相同字段，308 不展示 UI |
| `pageNum` | Integer | 是 | 页码；条件改变后回到 1 | 相同 |
| `pageSize` | Integer | 是 | 当前 Web 基线 20 | 相同 |
| `sortField` | String | 否 | 当前只能使用 93 已支持值 | 308 新 Sort 尚未冻结 |
| `isAsc` | Boolean | 否 | 与 `sortField` 配套 | 相同 |

```json
{
  "isCampaign": 0,
  "emailName": "retirement",
  "categoryId": "1001",
  "subcategoryIds": ["1101"],
  "tagGroups": [
    {"groupCode": "TRIGGER", "tagCodes": ["CLIENT_EVENT", "SEASONAL"]},
    {"groupCode": "FINANCIAL_NEED", "tagCodes": ["RETIREMENT_PLANNING"]}
  ],
  "channelList": [],
  "pageNum": 1,
  "pageSize": 20,
  "sortField": "updatedDate",
  "isAsc": false
}
```

### 4.3 当前可直接使用的 Response

| 字段 | 308 Card 用途 | 已满足 PRD | 说明 |
|---|---|---:|---|
| `emailCode` | 后续 Detail/Preview/Use 标识 | 是 | 前端按 String |
| `emailName` | Template Title | 是 | 来自 Master |
| `description` | Card Description | 是 | 可为 null |
| `version` | 当前 Active version | 是 | 只用于展示/调试，不回传选择 version |
| `emailStatus` | 可见性结果 | 是 | Adviser 结果应为 Active |
| `versionStatus` | Published 状态 | 是 | 固定 `1=Active` |
| `isCampaign` | Email/Campaign Format | 是 | 下游分流依据 |
| `category` | Main Category | 是 | 当前 Active Metadata |
| `subcategories` | Subcategory | 是 | 当前 Active Metadata |
| `tagGroups` | Card Tags | 是 | 当前 Active Metadata |
| `modifiedTime` | 修改时间 | 否，不能直接当 Published Date | `SORT-02` 待确认 |
| Thumbnail | Card Image | **否** | 当前响应没有已冻结字段 |
| Facet/Count | Navigation/Filter Count | **否** | 当前响应没有 |

```json
{
  "requestId": "request-id",
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
      "description": "Invitation for the annual review",
      "version": "V2",
      "emailStatus": "1",
      "versionStatus": 1,
      "isCampaign": 0,
      "category": {"categoryId": "1001", "categoryName": "Client Engagement"},
      "subcategories": [{"categoryId": "1101", "categoryName": "Advice Review"}],
      "tagGroups": [
        {"groupCode": "TRIGGER", "tagCodes": ["CLIENT_EVENT", "SEASONAL"]},
        {"groupCode": "FINANCIAL_NEED", "tagCodes": ["RETIREMENT_PLANNING"]}
      ],
      "modifiedTime": "2026-07-17 09:00:00"
    }]
  }
}
```

### 4.4 EX-01 明确需要补充但尚未冻结的改造

| ID | PRD Gap | 当前缺什么 | 可能影响 | 现在能否开发 |
|---|---|---|---|---:|
| `LIST-01` | Email + Campaign 可能同屏 | `isCampaign` 只能传一个值 | Request、SQL、分页、Facet | 否 |
| `CARD-01` | Thumbnail | Response 无已冻结 Thumbnail URL/Key | Response DTO、文件服务、Card | 前端只做占位图 |
| `SORT-01` | Most Relevant | 无评分规则和 Sort 枚举 | Request、SQL、测试数据 | 否 |
| `SORT-02` | Newest/Oldest by Published Date | 发布时间字段未确认 | Response、Sort SQL | 否 |
| `FACET-01` | Category/Tag Count 与可用值 | 无 Facet Response | Response 或新 API、Count SQL、缓存 | 前端只做静态 UI |

在这些问题关闭前，不能把猜测字段加进 DTO/Mock。基础 List、Search、Category/Tag Filter 和分页可以先开发。

## 5. EX-04 Adviser Published Detail

### 5.1 这个接口在 93 和 308 中有什么不同

| 对比项 | LEAD-93 Contract | LEAD-308 使用/变化 | 是否修改接口 |
|---|---|---|---|
| Request | 只传 `emailCode` | 完全相同 | 否 |
| 选版 | 后端解析当前可见 Active | Detail、Preview、Use 都依赖同一规则 | 否 |
| Response | 正文、基本信息、附件引用、Category/Subcategory/Tag | Detail 使用全部 Context；Preview 主动忽略附件 | 否 |
| Preview | 93 已确定复用 Renderer、无独立 API | 308 直接复用 | 否 |
| Use Template | 93 只提供 Active Detail | 308 在进入下游前重新调用一次 | **调用时机变化，接口不改** |

### 5.2 Request 与 Response

```json
{"emailCode":"815645091883520000"}
```

```json
{
  "requestId": "request-id",
  "responseCode": "00000000",
  "responseMessage": "Succeed",
  "data": {
    "emailCode": "815645091883520000",
    "emailName": "Retirement review invitation",
    "description": "Invitation for the annual review",
    "version": "V2",
    "versionStatus": 1,
    "emailStatus": "1",
    "title": "Your retirement review",
    "emailContent": "ENCRYPTED_CONTENT",
    "fileKeys": "",
    "fileInfos": [],
    "isCampaign": 0,
    "category": {"categoryId": "1001", "categoryName": "Client Engagement"},
    "subcategories": [{"categoryId": "1101", "categoryName": "Advice Review"}],
    "tagGroups": [{"groupCode": "CONTENT_TYPE", "tagCodes": ["EMAIL"]}]
  }
}
```

### 5.3 308 的三种使用模式

| 模式 | 使用哪些字段 | 不使用哪些字段 | 后续动作 |
|---|---|---|---|
| Detail | 基本信息、正文、Category/Subcategory/Tag、Format | 无写字段 | 展示只读 Detail |
| Preview | 正文、基本信息、Metadata、Format | `fileKeys/fileInfos` | 交给现有 Renderer；不显示附件 |
| Use 前校验 | `emailCode/version/isCampaign`、正文和下游需要的现有字段 | 不修改 Template | 根据 `isCampaign` 进入下游 |

无权限、Inactive、已删除或没有 Active 时不返回 Template 内容。多个 Active 属于数据异常，服务端不得任意选择。

## 6. NEW-01 Category Tree

### 6.1 这个接口在 93 和 308 中有什么不同

| 对比项 | LEAD-93 Contract | LEAD-308 使用/变化 | 是否修改接口 |
|---|---|---|---|
| Tree | 返回有效两级 Category/Subcategory | 作为 Adviser Navigation | 否 |
| 顺序 | `sortOrder` | 按 Content Manager 配置顺序展示 | 否 |
| 管理字段 | 包含 description/created 信息 | Adviser 可忽略管理信息 | 否 |
| Published Count | 没有 | PRD 要每个节点显示 Count | **需要扩展，待确认** |

### 6.2 当前可直接使用的 Response

```json
{
  "requestId": "request-id",
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
      "children": [{
        "categoryId": "1101",
        "categoryName": "Advice Review",
        "description": null,
        "level": 2,
        "parentCategoryId": "1001",
        "sortOrder": 1,
        "children": []
      }]
    }]
  }
}
```

### 6.3 Count 为什么现在不能直接加

需要先确认 `FACET-01`：

- Count 是 Email/Campaign 分开还是合计；
- 是全局 Published Count，还是随当前 Search/Tag Filter 变化；
- 零数量节点是显示、禁用还是隐藏；
- Count 放在 `NEW-01`，还是由 `EX-01` 返回上下文 Facet。

## 7. NEW-06 Tag Taxonomy

### 7.1 这个接口在 93 和 308 中有什么不同

| 对比项 | LEAD-93 Contract | LEAD-308 使用/变化 | 是否修改接口 |
|---|---|---|---|
| Group | 返回 4 Mandatory + 2 Optional | Filter Panel 只展示 4 Mandatory | 接口不改，前端过滤 |
| Tag Value | 返回 taxonomy 中全部有效值 | PRD 希望只显示 Published Template 使用过的值 | **需要扩展，待确认** |
| Multi-select | 每个 Group 可多选 | 完全相同 | 否 |
| 组合逻辑 | 同组 OR、跨组 AND | 完全相同，由 `EX-01` 执行 | 否 |

### 7.2 当前可直接使用的 Response

```json
{
  "requestId": "request-id",
  "responseCode": "00000000",
  "responseMessage": "Succeed",
  "data": {
    "tagGroups": [{
      "groupCode": "CONTENT_TYPE",
      "groupName": "Content Type",
      "mandatory": true,
      "sortOrder": 1,
      "values": [
        {"tagCode": "EMAIL", "tagName": "Email", "sortOrder": 1},
        {"tagCode": "CAMPAIGN", "tagName": "Campaign", "sortOrder": 2}
      ]
    }]
  }
}
```

前端只保留 `CONTENT_TYPE/TRIGGER/LIFECYCLE_STAGE/FINANCIAL_NEED` 四组。`PROPOSITION/SOURCE` 不进入 Filter Panel。

### 7.3 “只显示可用值”缺口

`NEW-06` 是静态 taxonomy，没有 Template 使用情况。要满足 PRD，需要在 `FACET-01` 中选择一种方案：

1. `EX-01` 返回当前查询条件下的 Tag Facet；
2. `NEW-06` 增加 Published 使用状态/Count；
3. 新增专用 Facet API。

推荐优先由 `EX-01` 返回上下文 Facet，避免污染静态 taxonomy；该建议尚不是冻结 Contract。

## 8. Preview：没有 API 修改，使用方式不同

Preview 的完整实现是：

1. 调用 `EX-04 {emailCode}`；
2. 使用返回的当前 Active `emailContent` 和 Metadata；
3. 复用现有 Renderer；
4. 忽略 `fileKeys/fileInfos`，不请求附件下载；
5. 不持久化、不 Publish、不改变任何状态；
6. Close/Back 后恢复 Library Query State。

因此 Preview 不需要后端新增 `/preview`。308 PRD 中 PDF/TXT/媒体附件预览描述仍需 BA/PO 修正，技术实现以“正文 + Metadata、无附件”为准。

## 9. Use Template：当前只冻结到 EX-04

| 阶段 | 已冻结 | 未冻结 |
|---|---|---|
| 重校验 Template | 调用 `EX-04 {emailCode}`，获取最新可见 Active | 无 |
| 分流 | `isCampaign=0` Email；`isCampaign=1` Campaign | 无 |
| Email 初始化 | 进入现有 Email Composer | Route、API、DTO、附件和失败码 |
| Campaign 初始化 | 进入 Campaign Creation | 管理入口、Route、API、DTO 和失败码 |

当前不新增 `/use` API。若内网代码证明必须由后端完成跨模块初始化，再新增独立 Contract；不能把未确认下游字段塞进 `EX-04`。

## 10. 前后端到底改哪些地方

### 10.1 现在可以开发

| 能力 | 前端改造 | 后端改造 | 使用接口 |
|---|---|---|---|
| 基础 Card List | 新页面/Card/分页/状态管理 | 复用 93 v2 Query；接入 Adviser 权限 | `EX-01` |
| Search | 2 字符、300ms debounce、高亮、取消旧请求 | 复用已有 Search 字段和语义 | `EX-01` |
| Category Filter | Tree/选中态/Chip | 复用 `categoryId/subcategoryIds` Filter | `NEW-01` + `EX-01` |
| 四组 Tag Filter | 只展示 4 组、组内多选、Chip | 复用 `tagGroups` Filter | `NEW-06` + `EX-01` |
| Detail | 只读 Detail UI | 复用 Adviser Active Detail | `EX-04` |
| Preview | Renderer、Modal/Page、返回状态恢复、忽略附件 | 无新增 Preview API | `EX-04` |

### 10.2 还不能按最终 Contract 开发

| 能力 | 缺少决定 | 将修改什么 |
|---|---|---|
| Mixed Email/Campaign | `LIST-01` | `EX-01` Request/SQL 或前端双请求合并策略 |
| Thumbnail | `CARD-01` | `EX-01` Response、文件服务和 Card |
| Most Relevant | `SORT-01` | `EX-01` Sort 参数、评分 SQL、测试 |
| Published Date Sort | `SORT-02` | `EX-01` Response/Sort SQL |
| Category/Tag Facet | `FACET-01` | `EX-01` 或 taxonomy API Response、Count SQL、缓存 |
| Email Use E2E | `USE-01` | 下游 Route/API/DTO |
| Campaign Use E2E | `USE-02` | 下游 Route/API/DTO |

## 11. 错误与前端处理

| 场景 | 处理原则 |
|---|---|
| HTTP 200 + 非成功业务码 | 按失败处理，不能只判断 HTTP Status |
| 无 Adviser 权限 | 不返回 Template 数据 |
| Template 不可见 | Detail/Preview/Use 不泄露停用、删除或无 Active 的内部原因 |
| Category/Tag 非法 | 字段校验失败，不静默忽略 |
| Search/Filter 无结果 | 成功空分页 |
| 多个 Active | 服务端失败并记录数据异常，不任意返回一条 |
| Renderer 失败 | 保留 Library State，允许重试 |
| 下游初始化失败 | 不修改 Template，保留原页面 |

## 12. 接口冻结结论

| 接口 | 当前能否联调 | 还需修改的部分 |
|---|---:|---|
| `EX-01` 基础 List/Search/Filter/Page | 是 | Card 增量、复杂 Sort、Facet、混合 Format |
| `EX-04` Detail/Preview/Use 前重校验 | 是 | 不修改接口；只缺下游 Use Contract |
| `NEW-01` Tree | 是 | Count |
| `NEW-06` Taxonomy | 是 | Published 可用值/Count |

每个 Gap 关闭后，必须同步本文、后端 DTO/Mapper、前端 API Client、Mock 和自动化测试。LEAD-308 不再维护与 LEAD-93 重复的接口编号映射。
