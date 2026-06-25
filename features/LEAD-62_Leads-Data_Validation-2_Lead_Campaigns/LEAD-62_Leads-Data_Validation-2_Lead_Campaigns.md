# Feature - LEAD-62: Leads-Data Validation-2 ( Lead & Campaigns)

## 📋 Jira Metadata
| Field | Value |
| :--- | :--- |
| **Jira Key** | `LEAD-62` |
| **Type** | `Feature` |
| **Status** | `正在进行` |
| **Parent Epic** | `LEAD-34` |
| **Labels** | `DOR_FEAT` |
| **Components** | `none` |

## 📖 Original Description
Lead & Campaign Validation
Feature Goal
Ensure that all lead data records are validated against campaign and lead‑level data quality rules using configurable validation logic, so that only valid, complete, and non‑duplicate leads are processed, with outcomes persisted and reportable.

In‑Scope 

Validate whether the lead is associated with an active campaign
Check whether the customer already exists as an existing lead (duplicate detection)
Validate all records against an active campaign
Perform First Name and Surname validation to ensure basic identity data quality
Persist all validation outcomes on the lead record
Expose all validation results for downstream reporting and analytics
Ensure all validation rules are configurable (no-code / low-code changes), including rule definitions and conditions


## 📖 Linked Stories (关联的故事需求)
- **[LEAD-291](stories/LEAD-291_Investgation_for_name_surname_impacted_scenarions.md)**: Investgation for name & surname impacted scenarions *(状态: 正在进行 | 故事点数: 3)*
- **[LEAD-253](stories/LEAD-253_Validation_Pipeline_Framework_Refactoring_DAE_manual_Creation.md)**: Validation Pipeline Framework Refactoring (DAE manual Creation) *(状态: Functional Testing | 故事点数: 3)*
- **[LEAD-245](stories/LEAD-245_Validation_Pipeline_Framework_Refactoring_SQS_Message_consumption.md)**: Validation Pipeline Framework Refactoring (SQS Message consumption) *(状态: Functional Testing | 故事点数: 8)*
- **[LEAD-209](stories/LEAD-209_Validation_Pipeline_Framework_Refactoring_DAE_batch_upload.md)**: Validation Pipeline Framework Refactoring (DAE batch upload) *(状态: Ready for Development | 故事点数: 5)*
- **[LEAD-170](stories/LEAD-170_Create_demo_showcase.md)**: Create demo showcase *(状态: 已完成 | 故事点数: 3)*
- **[LEAD-143](stories/LEAD-143_Cross_Campaign_-_Duplicate_Decision_Rules.md)**: Cross Campaign - Duplicate Decision Rules *(状态: 正在进行 | 故事点数: 2)*
- **[LEAD-142](stories/LEAD-142_Duplicate_Rule_Precedence_Processing_Order.md)**: Duplicate Rule Precedence / Processing Order  *(状态: 正在进行 | 故事点数: 3)*
- **[LEAD-125](stories/LEAD-125_Lead_Validation_-Expose_Validation_OutcomesException_table_to_PFMI.md)**: Lead Validation -Expose Validation Outcomes/Exception table ( to PFMI) *(状态: Ready for Development | 故事点数: 2)*
- **[LEAD-124](stories/LEAD-124_Lead_Validation_Audit_Trail_Persist_All_Validation_Outcomes_per_Lead.md)**: Lead Validation Audit Trail – Persist All Validation Outcomes per Lead *(状态: 正在进行 | 故事点数: 8)*
- **[LEAD-90](stories/LEAD-90_Lead_Deduplication_Cross-Campaign_Management.md)**: Lead Deduplication & Cross-Campaign Management *(状态: 正在进行 | 故事点数: 2)*
- **[LEAD-60](stories/LEAD-60_Campaign_Existence_Status_Validation.md)**: Campaign Existence & Status Validation *(状态: 正在进行 | 故事点数: 8)*
- **[LEAD-40](stories/LEAD-40_Lead_Name_Validation_First_Name_or_Surname_Required.md)**: Lead Name Validation – First Name or Surname Required *(状态: 正在进行 | 故事点数: 3)*

---

### 💡 AI 深度技术分析与卡点评估

#### 1. 核心功能目标 (Business Goal)
针对 Campaign 有效性及线索去重进行活动级和线索级合法性验证，确保数据质量合规。

#### 2. 业务边界与核心场景 (Scope & Boundaries)
- **业务范围**：活动存在性校验、活动有效期校验、同一/跨活动重复检测以及姓名质量验证。校验结果须持久化归档。
- **输入数据**：依赖前置校验合格后流入的 Standard Payload 数据结构。
- **输出流向**：记录结果审计入库、下发 SQS 或进行页面渲染。

#### 3. 技术方案设计与难点评估 (Technical Design & Complexity)
- **技术实现**：在验证链中开发 `CampaignValidityChecker` 与 `DeduplicationChecker`。高并发去重需要借助 Redis 分布式锁控制锁竞争；同时在高并发下对 URule/SpEL 启用 JVM KnowledgePackage 本地缓存。
- **复杂度评估**：**高 (High)**。主要考量高并发去重加锁、大文件批处理时的 JVM 内存分配，以及多系统对接时的时延控制。
