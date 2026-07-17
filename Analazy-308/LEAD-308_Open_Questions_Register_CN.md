# LEAD-308 未确认项与关闭登记册

> 更新日期：2026-07-17  
> 规则：所有不确定项只在本登记册关闭。会议口头结论必须补充 Owner、日期和证据，并同步详细方案与 API Contract。

## 1. 状态定义

| 状态 | 含义 |
|---|---|
| `OPEN` | 未确认；不能作为开发假设 |
| `CODE-CHECK` | 业务方向已知，等待内网代码/环境核对 |
| `RESOLVED-DESIGN` | 技术实现已冻结，但外部文档可能仍需修正 |
| `CLOSED` | 已确认并同步全部受影响文档 |

## 2. 开发前或对应功能前必须关闭

| ID | 问题 | 当前事实/处理 | Owner | 冻结点 | 状态 |
|---|---|---|---|---|---|
| `SCOPE-01` | 308 是否交付 Mobile 新功能 | PRD 写 Mobile + Web；LEAD-93 冻结为新增/增强仅 Web v2，Mobile 保持 v1 | BA/PO | Mobile 开发排期前 | OPEN |
| `LIST-01` | Adviser Library 是否同屏混合 Email/Campaign | `EX-01 isCampaign` 当前必传单值；不得改为无类型全量查询 | BA/UX/API | List Contract 冻结前 | OPEN |
| `FACET-01` | Category/Tag Count 口径和 API | 未确认全局或上下文 Count；未确认零值隐藏/禁用；`NEW-01/06` 当前无 Count | BA/UX/API | Facet 开发前 | OPEN |
| `SORT-01` | Most Relevant 评分规则 | PRD 只有名称，无字段权重、精确/部分匹配、Tag 命中、同分规则 | BA/PO | 排序 Mapper 前 | OPEN |
| `SORT-02` | Published Date 的正式来源 | `modifiedTime` 与 `effective_from` 都不能未经确认直接等同 Published Date | BA/Backend | Newest/Oldest 开发前 | OPEN |
| `CARD-01` | Thumbnail 字段和 URL | 已知 `version.thumbnail_key`；访问 URL、默认图、失效处理需代码核对 | Backend/Frontend | Card 实图联调前 | CODE-CHECK |
| `USE-01` | Email Composer 激活 Contract | 需真实路由、Method/Path、DTO、正文/附件传递和失败码 | Email Team/Backend | Email Use E2E 前 | OPEN |
| `USE-02` | Campaign 激活 Contract | Campaign 管理入口及初始化 Contract 尚未确认 | Campaign Team/BA | Campaign Use E2E 前 | OPEN |
| `META-01` | Detail/Preview 是否显示 Optional Proposition/Source | Filter 只显示四组已确认；“全部 Metadata”展示范围未明确 | BA/UX | Detail UI 冻结前 | OPEN |

## 3. 已形成设计结论但需外部同步

| ID | 事项 | 结论 | 待办 | 状态 |
|---|---|---|---|---|
| `PRD-01` | LEAD-319 描述 PDF/TXT/媒体 Preview | 实现按 LEAD-93 基线：正文 + Metadata；不支持附件 | BA/PO 修正 308 PRD 和 AC，QA 更新用例 | RESOLVED-DESIGN |
| `DATA-01` | 308 是否新增表 | 不新增；复用 LEAD-93 数据模型，只提供 QUERY | 无 | CLOSED |
| `STATE-01` | Adviser 是否看 Working Copy | Active + Draft 共存时只看 Active，不显示 Draft 提示 | 无 | CLOSED |
| `PREVIEW-01` | Preview 是否新增 API | 不新增；调用 `EX-04` 后复用现有 Renderer | 无 | CLOSED |
| `USE-00` | Use 前是否重读 Active | 是，只提交 `emailCode` 并重新解析 | 无 | CLOSED |
| `AUDIT-01` | 是否新增审计 | Data Tracking 为 Nice to Have；本期无审计表/事件 | 无 | CLOSED |

## 4. 内网代码核对项

| ID | 核对内容 | 期望证据 | 影响 |
|---|---|---|---|
| `CODE-01` | Adviser 权限、tenant/country 注入点 | Security/Context 类、Controller 注解或 Filter | List/Detail 可见性 |
| `CODE-02` | `EX-01` v2 Controller/DTO/Mapper 落点 | Method、DTO、Mapper SQL | 实际改造清单 |
| `CODE-03` | `EX-04` 正文解密和返回链路 | Service/VO/测试请求 | Preview/Use |
| `CODE-04` | Thumbnail 解析 | `thumbnail_key` 使用位置、文件服务调用 | Card |
| `CODE-05` | 现有 Renderer | 入口、Input/Output、净化、错误码，确认不加载附件 | Preview |
| `CODE-06` | Email Composer 初始化 | 路由、Store/Context、API 与附件处理 | `USE-01` |
| `CODE-07` | Campaign 创建初始化 | 路由、Store/Context、API 与附件处理 | `USE-02` |
| `CODE-08` | Category/Tag 缓存 | Cache key、刷新时机、是否可承载动态 Count | Facet |

## 5. 关闭记录

| 日期 | ID | 决策 | 证据 | 同步文档 |
|---|---|---|---|---|
| 2026-07-17 | `DATA-01` | 308 无 DDL/DML | LEAD-93 V3 数据模型 | 详细方案、评审稿、SQL |
| 2026-07-17 | `STATE-01` | Adviser 只看 Active | 用户确认与 LEAD-93 Contract | 详细方案、API |
| 2026-07-17 | `PREVIEW-01` | Preview 无独立 API、无附件 | 用户确认与 LEAD-93 V3 | 全部 308 文档 |
| 2026-07-17 | `USE-00` | Use 前调用 `EX-04` 重读 Active | LEAD-93 `EX-04` | 详细方案、API |

## 6. 关闭模板

```text
ID:
Decision:
Owner:
Decision Date:
Evidence / code link:
Affected API / UI / SQL:
Documents updated:
Test cases updated:
```
