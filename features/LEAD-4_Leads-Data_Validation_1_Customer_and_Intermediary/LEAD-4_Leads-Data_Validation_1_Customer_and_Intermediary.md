# Feature - LEAD-4: Leads-Data Validation 1 ( Customer and Intermediary)

## 📋 Jira Metadata
| Field | Value |
| :--- | :--- |
| **Jira Key** | `LEAD-4` |
| **Type** | `Feature` |
| **Status** | `正在进行` |
| **Parent Epic** | `LEAD-34` |
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
- **[LEAD-269](stories/LEAD-269_Unified_Exception_Handling_for_Validation_Allocation.md)**: Unified Exception Handling for Validation & Allocation *(状态: Analysis | 故事点数: 5)*
- **[LEAD-234](stories/LEAD-234_Validation_for_SelectedAdvisor_When_want2Talk2PSIfalse.md)**: Validation for SelectedAdvisor When ‘want2Talk2PSI=false’ *(状态: Analysis | 故事点数: 3)*
- **[LEAD-231](stories/LEAD-231_Validate_PSI_sales_code_format.md)**: Validate PSI sales code format *(状态: Analysis | 故事点数: 3)*
- **[LEAD-230](stories/LEAD-230_PSI_Validation_storage_for_New_Customers.md)**:  PSI Validation & storage  for New Customers *(状态: Analysis | 故事点数: 3)*
- **[LEAD-206](stories/LEAD-206_Validation_Rule_Registry_Centralized_Rule_Definition_Management.md)**: Validation Rule Registry — Centralized Rule Definition & Management *(状态: Analysis | 故事点数: 3)*
- **[LEAD-197](stories/LEAD-197_Allow_processing_when_PSI_missing_on_Lead_and_Customer.md)**: Allow processing when PSI missing on Lead and Customer *(状态: Analysis | 故事点数: 3)*
- **[LEAD-84](stories/LEAD-84_Auto-Correct_Missing_Lead_PSI.md)**: Auto-Correct Missing Lead PSI *(状态: Analysis | 故事点数: 3)*

---

### 💡 AI 深度技术分析与卡点评估

#### 1. 核心功能目标 (Business Goal)
实施首选销售中介代码（PSI）及死亡人口状态校验，确保派单的客户具有可服务性。

#### 2. 业务边界与核心场景 (Scope & Boundaries)
- **业务范围**：当线索 Sales Code 缺失时自动反查客户列表补齐中介代码；对全部流入数据源强制进行 Deceased（死亡库）过滤。
- **输入数据**：依赖前置校验合格后流入的 Standard Payload 数据结构。
- **输出流向**：记录结果审计入库、下发 SQS 或进行页面渲染。

#### 3. 技术方案设计与难点评估 (Technical Design & Complexity)
- **技术实现**：开发 `PSIMatchingValidator`，利用 Caffeine Cache 缓存中介库，拦截无效 sales code 或 Deceased 客户。单次匹配控制在 5ms 内，保障高吞吐。
- **复杂度评估**：**中 (Medium)**。主要考量高并发去重加锁、大文件批处理时的 JVM 内存分配，以及多系统对接时的时延控制。
