# Feature - LEAD-227: Leads-Payload standardisation -MADM Files

## 📋 Jira Metadata
| Field | Value |
| :--- | :--- |
| **Jira Key** | `LEAD-227` |
| **Type** | `Feature` |
| **Status** | `Refinement` |
| **Parent Epic** | `LEAD-34` |
| **Labels** | `DOR_FEAT` |
| **Components** | `Leads Additions` |

## 📖 Original Description
Goal
Establish a standardised, governed file contract for all lead files received from CS Analytics, ensuring that:
Incoming files are fully aligned to IG data requirements
Data is structured, validated, and ingestion-ready at source
Downstream processing is efficient, predictable, and reliable
Data quality issues are identified early (at file ingestion) rather than downstream
Context
The current lead ingestion process within IG consumes lead files provisioned by the PF Customer Analytics team, which were originally designed for a legacy system and legacy processes. As a result, these files:
Do not align to IG data model requirements
Contain inconsistent field definitions, formats, and structures
Include fields that are:
Not required for IG processing
Missing but critical for IG workflows
Are ingested with minimal interrogation, leading to downstream inefficiencies
From the current pipeline design:
The ingestion process relies heavily on source file structure with limited validation or standardisation 
There is no consistent mechanism to define required vs optional fields
Duplicate handling and validation are inconsistent and often deferred downstream 
File processing focuses on automation (detection and ingestion) rather than input quality or structure governance
This results in:
Increased data quality risks
Failed or partially processed files
Additional downstream validation complexity
Reduced visibility and control for IG users
Increased reliance on BAU or technical teams to resolve issues
 Problem Statement
IG currently lacks a standardised file contract for incoming lead files from CS Analytics. This leads to:
Misalignment between incoming data structures and IG processing requirements
Inefficient ingestion due to rework, transformation, and exception handling
Inability to enforce consistent data governance and validation upfront
Increased operational overhead and processing delays
Scope
This feature introduces a formalised file ingestion standard (file contract) specifically for:
Batch lead files received from CS Analytics for PF Leads
Files must be in .txt format
Applies at file level (structure, fields, formats)
Excludes payload-level processing logic (addressed in a separate feature)
Definition of a standard IG Lead File Specification, including:
File format standard (TXT enforced)
Field-level definitions
Required vs optional fields
Standardised naming conventions
Data types and formats
Introduction of file-level validation rules (pre-ingestion)
Alignment of incoming files to IG downstream processing and validation framework


---

### 💡 AI 深度技术分析与卡点评估

#### 1. 核心功能目标 (Business Goal)
标准化入栈 Payload 结构，确保上游所有文件类型和接口报文完全对齐 OC（One Connect）系统展示与报表要求。

#### 2. 业务边界与核心场景 (Scope & Boundaries)
- **业务范围**：作为数据摄入的最前端校验关卡，强制规范字段（如 CampaignID, Channel, DOB, CustomerType 等）。
- **输入数据**：依赖前置校验合格后流入的 Standard Payload 数据结构。
- **输出流向**：记录结果审计入库、下发 SQS 或进行页面渲染。

#### 3. 技术方案设计与难点评估 (Technical Design & Complexity)
- **技术实现**：开发基于 JSON Schema 的强类型 `UnifiedLeadDTO` 校验器，前置拒绝对接不完整的残缺报文，并首先对 MADM 成熟度文件（Maturity files）进行规范收敛。
- **复杂度评估**：**中 (Medium)**。主要考量高并发去重加锁、大文件批处理时的 JVM 内存分配，以及多系统对接时的时延控制。
