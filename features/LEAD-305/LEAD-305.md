# Feature - LEAD-305: Leads-Data Validation 3 

## 📋 Jira Metadata
| Field | Value |
| :--- | :--- |
| **Jira Key** | `LEAD-305` |
| **Type** | `Feature` |
| **Status** | `正在进行` |
| **Parent Epic** | `None` |
| **Labels** | `DOR_FEAT` |
| **Components** | `Leads Fix` |

## 📖 Original Description
Current State
PSI (Preferred  Sales Intermediary) validation is not executed within IG.
Currently the check run to identify if a sales code is present on the inbound lead record.
Then a check is run to identify if this sales code matches the sales code on the IG customer list.
 
A Deceased check is currently run, we need to ensure that the check that is run against all incoming data sources
Future State (Required Changes)
This feature recognises that a check to run and ensure that the PSI code on the lead record matches the PSI code on the IG customer list, across all data sources.
In addition,
We need to run a check when a lead record does not have a PSI, against the customer record, to check for a PSI code. If a PSI code exists the, lead record must be updated.
 We need to ensure that the Customer Deceased check is called on all records, if not, we need to implement the customer deceased check.
 Feature Goal
Ensure that the in scope validations are applied consistently across all data sources.
That these validations are configurable and not hard coded
That validation failures are written away, for auditing and reporting purposes.
 
In Scope for Feature
Run the PSI (intermediary) check
Interpret customer intent (want2Talk2PSI) to determine execution paths
Validate intermediary sales codes on non‑PSI leads for data integrity
Where an intermediary exists, check if the intermediary is active
Run a deceased customer check
Apply outcomes to the lead record
Provide outcomes for external reporting
Ensure all rules are configurable
 


## 📖 Linked Stories (关联的故事需求)
- **[LEAD-232](stories/LEAD-232.md)**: Lead to Customer Match *(状态: Analysis | 故事点数: 3)*
- **[LEAD-58](stories/LEAD-58.md)**: Prevent Processing for Deceased Customers *(状态: Analysis | 故事点数: 3)*
- **[LEAD-57](stories/LEAD-57.md)**:  PSI Detection and Storage *(状态: Analysis | 故事点数: 3)*
- **[LEAD-55](stories/LEAD-55.md)**:  Validate Matching PSI between Lead and customer *(状态: Analysis | 故事点数: 3)*

---

### 💡 AI 深度技术分析与卡点评估

#### 1. 核心功能目标 (Business Goal)
第三期数据校验，引入高阶产品规则与黑名单过滤条件，确保派单的绝对合规。

#### 2. 业务边界与核心场景 (Scope & Boundaries)
- **业务范围**：作为 Validation Pipeline 校验责任链的全新节点接入，对所有入库线索执行自动化质检。
- **输入数据**：依赖前置校验合格后流入的 Standard Payload 数据结构。
- **输出流向**：记录结果审计入库、下发 SQS 或进行页面渲染。

#### 3. 技术方案设计与难点评估 (Technical Design & Complexity)
- **技术实现**：在后台 Ingestion 验证链中集成高阶校验拦截类，生成带状态结果集并输出到 exceptions 审计日志表。
- **复杂度评估**：**中 (Medium)**。主要考量高并发去重加锁、大文件批处理时的 JVM 内存分配，以及多系统对接时的时延控制。
