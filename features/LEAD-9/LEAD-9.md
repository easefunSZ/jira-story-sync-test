# Feature - LEAD-9: Campaign & Leads Data-Reporting-Management Oversight

## 📋 Jira Metadata
| Field | Value |
| :--- | :--- |
| **Jira Key** | `LEAD-9` |
| **Type** | `Feature` |
| **Status** | `打开` |
| **Parent Epic** | `LEAD-34` |
| **Labels** | `DOR_FEAT` |
| **Components** | `Leads Fix` |

## 📖 Original Description
Campaign & Leads Data – Management Oversight delivers  consumable data feed that enables management oversight reporting on lead allocation and outcomes across campaigns
Currently, the sales management hierarchy lacks quick access to insight showing what happens to leads allocated to their teams, limiting their ability to identify issues and take corrective action.
Current ProblemSales management does not have near-real-time access to:how many leads were loaded vs allocated,where leads sit in the process (states),which teams/advisers are not accepting / progressing leads,SLA breaches by campaign and team.Insight is not available at the right granularity (business channel → FA → adviser), preventing targeted interventions.
This change provides a structured data feed for external consumption to build dashboards and reports that allow leadership to track:campaign loading success and campaign metadata,lead allocation to channels and hierarchy levels,lead state/status changes over time,SLA compliance (within vs outside SLA),lead types (Hot / Non-hot),volumes and trends from business channel down to adviser / FA level.
Opportunity / ValueProvide consistent, auditable reporting inputs so managers can:monitor throughput and outcomes by campaign,identify bottlenecks (e.g., non-acceptance, SLA expiry),drive performance actions with evidence,improve conversion and reduce lead leakagePrimary OutcomesVisibility: Managers can see lead volumes and outcomes by campaign and hierarchy level.Control: SLA breaches are measurable and actionable.Trust: A single, consistent feed prevents conflicting numbers across reports
Dependancies
Data mapping - need Data Team resource to assist PFMI


## 📖 Linked Stories (关联的故事需求)
- **[LEAD-193](stories/LEAD-193.md)**: Expose Exception data *(状态: 待办 | 故事点数: 1)*
- **[LEAD-189](stories/LEAD-189.md)**: Expose Lead closure reasons *(状态: 待办 | 故事点数: 1)*
- **[LEAD-188](stories/LEAD-188.md)**: Expose Lead priority and volumes *(状态: 待办 | 故事点数: 2)*
- **[LEAD-116](stories/LEAD-116.md)**: Expose SLA Indicators *(状态: 待办 | 故事点数: 3)*
- **[LEAD-112](stories/LEAD-112.md)**: Expose  Lead state and Lead state change timestamps *(状态: 待办 | 故事点数: 3)*
- **[LEAD-109](stories/LEAD-109.md)**: Expose Lead allocation data *(状态: 待办 | 故事点数: 3)*
- **[LEAD-107](stories/LEAD-107.md)**: Enhance Consumable Data Feed Access *(状态: 待办 | 故事点数: 3)*
- **[LEAD-105](stories/LEAD-105.md)**: Expose campaign metadata and metadata success  *(状态: Analysis | 故事点数: 3)*

---

### 💡 AI 深度技术分析与卡点评估

#### 1. 核心功能目标 (Business Goal)
生成跨活动全生命周期的线索数据 Consumable Data Feed 供 PFMi 报表分析，完成审计闭环。

#### 2. 业务边界与核心场景 (Scope & Boundaries)
- **业务范围**：将线索接收、校验结果、分配明细及状态变化导出为数据流。
- **输入数据**：依赖前置校验合格后流入的 Standard Payload 数据结构。
- **输出流向**：记录结果审计入库、下发 SQS 或进行页面渲染。

#### 3. 技术方案设计与难点评估 (Technical Design & Complexity)
- **技术实现**：使用 Debezium (CDC) 监听 `lead_validation_history` 和 `lead_record` 变更日志，将数据以 JSON 投递至 Kafka，确保 PFMi 团队能够进行实时报表拉取。
- **复杂度评估**：**中 (Medium)**。主要考量高并发去重加锁、大文件批处理时的 JVM 内存分配，以及多系统对接时的时延控制。
