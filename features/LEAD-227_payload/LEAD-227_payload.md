# Feature - LEAD-227: Leads-Payload standardisation

## 📋 Jira Metadata
| Field | Value |
| :--- | :--- |
| **Jira Key** | `LEAD-227` |
| **Type** | `Feature` |
| **Status** | `打开` |
| **Parent Epic** | `LEAD-34` |
| **Labels** | `DOR_FEAT` |
| **Components** | `Leads Additions` |

## 📖 Original Description
Standardise payloads at source must contain specific OC file requirements
May rationalise certain files
Must include all fields required for display or reporting
Starting with MADM files

Maturity Payload “deleted” story
As a system integratorI want incoming maturity lead payloads to conform to defined OC standard formatsSo that enrichment, processing, and downstream consumption are consistent, reliable, and scalable

Context:
The system must ensure that all incoming lead data—specifically for maturity campaigns—conforms to standardised payload structure and field requirements defined by OC before enrichment and allocation occur.


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
