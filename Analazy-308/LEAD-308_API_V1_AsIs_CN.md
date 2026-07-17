# LEAD-308 相关现有 v1 API As-Is 基线

> 状态：兼容边界  
> 更新日期：2026-07-17  
> 证据来源：[LEAD-93 v1 As-Is API 基线](../Lead-93/LEAD-93_API_V1_AsIs_CN.md)  
> 原则：本文不复制全部 LEAD-93 v1 接口，只列 LEAD-308 直接依赖或必须保持兼容的现状。

## 1. 公共约定

| 项目 | As-Is |
|---|---|
| 服务前缀 | `/iic-dae-msg` |
| Controller 前缀 | `/web/msg/template/email/v1` |
| 响应包络 | `IICResponseModel<T>`：`requestId/responseCode/responseMessage/data` |
| 成功业务码 | `00000000`；HTTP 200 不等同于业务成功 |
| 分页 | 请求 `pageNum/pageSize`；响应 `pageNo/pageSize/totalCount/totalPage/dataList` |
| 时间 | `yyyy-MM-dd HH:mm:ss`，南非业务时区 `Africa/Johannesburg` |
| 64 位 ID | `emailCode` 在 JavaScript 中按 String 处理 |

## 2. V1-01 Published List

| 项目 | 内容 |
|---|---|
| Endpoint | `POST /iic-dae-msg/web/msg/template/email/v1/queryList` |
| Request DTO | `EmailQueryDTO` |
| Response | `PageResult<EmailDetailVO>` |
| 证据 | LEAD-93 QA 实测 + 内网代码确认 |

现有后端硬编码过滤：

```text
version.status = 0
config.status = 0
config.email_status = 1
version.version_status = 1
is_campaign != 1
```

现有请求可包含 `isCampaign/emailName/pageNum/pageSize/channelList`，但 As-Is 查询仍硬编码排除 Campaign。v1 不支持 Category、Subcategory 或 Tag Filter，也不保证返回 LEAD-93 新增 Metadata。

**对 LEAD-308 的约束：**

- 不修改 v1 来承载 308 新功能；
- 308 Web 使用 v2 `EX-01`；
- Mobile 如果继续使用 v1，将无法获得完整 308 Search/Filter/Metadata 能力；其交付范围需由 `SCOPE-01` 冻结。

## 3. V1-04 Published Detail

LEAD-93 已将 Adviser 新场景设计为 v2 `EX-04 /published/detail`。现有 v1 Detail 只能作为兼容基线，不得增加 308 Metadata 字段后要求旧客户端同步升级。

LEAD-308 的 Detail、Preview 和 Use 前重解析统一使用 v2 `EX-04`：只提交 `emailCode`，由服务端选择当前 Active，前端不能提交 Draft/Schedule version。

## 4. V1-15 Channel List

| 项目 | 内容 |
|---|---|
| Endpoint | `POST /iic-dae-msg/web/msg/template/email/v1/channelList` |
| 状态 | 保持不变/可复用 |

只有最终 UX 需要 Channel Filter 或 Format 选项时才调用该接口。308 PRD 当前以 Email/Campaign Format 为主要区分，不应擅自增加 Channel Filter。

## 5. 兼容性结论

- v1 请求、响应和硬编码 Published 行为保持不变。
- v2 与 v1 共享底层 Master/Version 数据，Publish、Deactivate、Delete 的结果会跨端可见。
- v2 新增 Metadata 不反向写入 v1 响应。
- 308 不能以“Mobile 也要支持”为理由直接改 v1；必须先关闭 `SCOPE-01` 并完成兼容设计。
