# Feature - LEAD-92: Leads-Data enrichment

## 📋 Jira Metadata
| Field | Value |
| :--- | :--- |
| **Jira Key** | `LEAD-92` |
| **Type** | `Feature` |
| **Status** | `打开` |
| **Parent Epic** | `LEAD-34` |
| **Labels** | `DOR_FEAT` |
| **Components** | `Leads Additions` |

## 📖 Original Description
Comment
Advisers requested  a view of  Intent; Contact History; Income group .  
On payload :
“leadIntension":  "Hi I'm not happy. I'm about to cancel all my policies with your company 
“Income Band : -<30k per Month"
API
Last contact date:





Feature Goal
Ensure that all identified incoming lead records from all sources are enriched using business rules prior to adviser allocation, so that each lead contains validated and up-to-date customer contact details, clear lead purpose and intent, relevant customer interaction history, and auditable enrichment outcomes that support allocation decisioning and reporting.
Context
All identified lead records from all sources must be enriched using business‑defined rules before they can be allocated to advisers.This enrichment is required to:
Ensure validated and up-to-date customer contact details are availableClearly define lead intent and purpose using campaign data, data source name, and campaign typeProvide customer interaction history context prior to adviser engagementSupport allocation decisioning, which explicitly depends on enriched dataPersist enrichment activities and outcomes to support future reporting and analyticsEnrichment is therefore not optional or informational — it is foundational to allocation, adviser effectiveness, and reporting trust.
In ScopeAll identified incoming lead records from all sourcesRule-driven enrichment before allocation rules executeEnrichment of:Validated email addressMobile contact numberLead purpose and intent (derived from campaign, data source name, and campaign type)Customer interaction history (depth driven by rules)Persistence of:Enriched values (Income group, Allocation group, occupation)Enrichment activity typesRule outcomesUse of existing lead source name data (no standardisation in this feature) Out of Scope
Standardisation of lead source names (handled in a separate feature)Changes to allocation rules themselvesCreation of new interaction history data (existing history only)


---

### 💡 AI 深度技术分析与卡点评估

#### 1. 核心功能目标 (Business Goal)
在线索分配给顾问前，通过富化销售意图、历史联系记录和收入段来提升顾问展业深度。

#### 2. 业务边界与核心场景 (Scope & Boundaries)
- **业务范围**：在 Payload 解析中引入 `leadIntension` 与 `Income Band`，并自动呈现给分配端。
- **输入数据**：依赖前置校验合格后流入的 Standard Payload 数据结构。
- **输出流向**：记录结果审计入库、下发 SQS 或进行页面渲染。

#### 3. 技术方案设计与难点评估 (Technical Design & Complexity)
- **技术实现**：后端调用第三方 API 进行数据富化，设计 CompletableFuture 异步并行请求，设定 200ms 强超时熔断，防范由于外部系统延迟导致派单阻塞。
- **复杂度评估**：**中 (Medium)**。主要考量高并发去重加锁、大文件批处理时的 JVM 内存分配，以及多系统对接时的时延控制。
