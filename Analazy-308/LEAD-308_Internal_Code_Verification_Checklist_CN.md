# LEAD-308 内网代码核对清单

> 用途：在合规环境内由开发人员或内网 AI 填写。请提供结构、方法签名和脱敏结论，不复制客户数据、Token、密钥或敏感业务内容。

## 1. 输出要求

每项至少填写：

- 代码仓库/模块；
- 类、方法、DTO/VO/Mapper 名称；
- 当前行为；
- LEAD-308 是否需要修改；
- 脱敏证据位置；
- 影响的登记册 ID。

## 2. Published List 与选版

| 核对项 | 需要回答 | 填写结果 |
|---|---|---|
| `EX-01` Controller | v2 Method/Path、Request DTO、Response VO 是什么 | 待填写 |
| 可见性条件 | `status/email_status/version_status/is_campaign` 在哪层强制 | 待填写 |
| 权限范围 | Adviser、tenant、country 从哪个 Context/Filter 获取 | 待填写 |
| Active 唯一性 | 多个 Active 当前如何处理 | 待填写 |
| 分页与 Count | List/Count 是否复用完全相同条件 | 待填写 |
| Sort | 当前允许的 `sortField` 白名单和默认值 | 待填写 |
| Metadata 装配 | Category/Subcategory/Tag 是 Join、批量查询还是 N+1 | 待填写 |

请附脱敏的 Controller 方法签名、DTO 字段、Mapper ID 和关键条件，不需要完整源码。

## 3. Category 与 Tag

| 核对项 | 需要回答 | 填写结果 |
|---|---|---|
| `NEW-01` | Tree 的 Service/Mapper、缓存和返回字段 | 待填写 |
| `NEW-06` | Taxonomy 的 Service/Mapper、缓存和六组返回规则 | 待填写 |
| 动态 Count | 当前是否已有 Published Count/Facet 查询 | 待填写 |
| 失效节点 | `is_deleted=1` Category、失效 Tag 的读取行为 | 待填写 |
| 缓存刷新 | Category/Tag 变更后如何失效 | 待填写 |

## 4. Detail 与 Preview

| 核对项 | 需要回答 | 填写结果 |
|---|---|---|
| `EX-04` | Controller/Service/VO 和当前 Active 解析逻辑 | 待填写 |
| 正文 | `emailContent/emailContentKey` 如何解密/净化 | 待填写 |
| Renderer | 前端或后端入口、输入、输出、错误码 | 待填写 |
| 附件隔离 | Renderer 是否会读取 `fileKeys/fileInfos`；如何保证 Preview 不加载 | 待填写 |
| 页面状态 | Preview Close/Back 后 Query State 当前保存在哪里 | 待填写 |

## 5. Thumbnail

| 核对项 | 需要回答 | 填写结果 |
|---|---|---|
| 来源 | `thumbnail_key` 是否已在现有 List/Detail VO 中返回 | 待填写 |
| URL | 使用哪个文件服务、签名 URL 或 CDN 解析 | 待填写 |
| 缺省 | null、对象不存在、访问失败时现有 UI 如何处理 | 待填写 |
| 安全 | URL 有效期和权限边界 | 待填写 |

## 6. Use Template 下游

### 6.1 Email

| 核对项 | 需要回答 | 填写结果 |
|---|---|---|
| Route | Email Composer 的实际前端路由 | 待填写 |
| 初始化 | 通过 Router State、Store 还是后端 API 初始化 | 待填写 |
| Payload | Template 标识、正文、Subject、附件字段 | 待填写 |
| 失败 | 初始化失败的错误码和返回页面行为 | 待填写 |

### 6.2 Campaign

| 核对项 | 需要回答 | 填写结果 |
|---|---|---|
| Route | Campaign 创建/管理的实际入口 | 待填写 |
| 初始化 API | Method/Path/DTO | 待填写 |
| Payload | Template 内容、图片、附件、Metadata 如何使用 | 待填写 |
| 权限 | Adviser 是否具有创建 Campaign 权限 | 待填写 |

## 7. 前端范围与 Mobile

| 核对项 | 需要回答 | 填写结果 |
|---|---|---|
| Web Client | v1/v2 API Client 的模块和版本切换方式 | 待填写 |
| Mobile | 当前是否调用 v1 `queryList`，是否具备 Category/Tag UI | 待填写 |
| Shared UI | Web/Mobile 是否共享 Renderer、Card 和 Query State | 待填写 |
| Feature Flag | 308 是否有环境/角色/平台开关 | 待填写 |

## 8. 性能证据

请在 QA 脱敏环境执行并填写：

| 查询 | 数据规模 | 执行计划/耗时 | 结论 |
|---|---:|---|---|
| Published List 无 Filter | 待填写 | 待填写 | 待填写 |
| Keyword Search | 待填写 | 待填写 | 待填写 |
| 四组 Tag Filter | 待填写 | 待填写 | 待填写 |
| Category Count | 待填写 | 待填写 | 待填写 |
| Detail Active Resolve | 待填写 | 待填写 | 待填写 |

## 9. 回填结论

```text
Verified by:
Date:
Environment:
Confirmed unchanged components:
Components requiring change:
Resolved question IDs:
New findings/questions:
Sanitized evidence location:
```
