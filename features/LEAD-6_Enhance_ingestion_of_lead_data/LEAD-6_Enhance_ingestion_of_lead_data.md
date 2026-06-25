# Feature - LEAD-6: Enhance ingestion of  lead data

## 📋 Jira Metadata
| Field | Value |
| :--- | :--- |
| **Jira Key** | `LEAD-6` |
| **Type** | `Feature` |
| **Status** | `Ready for Deployment` |
| **Parent Epic** | `LEAD-35` |
| **Labels** | `DOR_FEAT, release-scope-breach` |
| **Components** | `Leads Fix` |

## 📖 Original Description
Statement
All lead sources (starting with Everlytic as the initial implementation) must support ingestion of both intermediated and un-intermediated leads into the Integreat pipeline, with full and transparent visibility of ingestion outcomes (success or failure).
Context
This enhancement ensures that all incoming lead data feeds, regardless of origin, are consistently processed through the Integreat ingestion pipeline and are capable of handling both:
Intermediated leads 
Un-intermediated leads 
Each inbound feed must provide explicit file-level ingestion status, indicating whether the upload and processing was successful or failed.
Current Behaviour (Everlytic)
Everlytic currently supports PSI structure in payloads
When PSI data is not present, it is passed as null or empty:
PSI.SalesCode = ""
PSI.digitalId = null
However, un-intermediated Everlytic leads are not currently being ingested into the Integreat lead pipeline, resulting in data loss and incomplete coverage.
Required Behaviour
The system must:
Accept both intermediated and un-intermediated leads from all sources
Ensure all valid leads are processed through the Integreat ingestion pipeline
Provide clear ingestion outcome visibility at file/feed level:
Successful ingestion
Full failure
Ensure PSI-null leads are still valid and processed where appropriate (based on routing rules)
Key Impacts
Everlytic un-intermediated leads are currently excluded and must be included in the pipeline
PSI = null must be treated as a valid state, not a rejection condition
Ingestion pipeline must not assume PSI presence is mandatory for processing
Future Considerations
Although initial implementation focuses on Everlytic, the solution must be designed as source-agnostic and extensible, supporting future onboarding of new source feeds.
All future sources must inherit the same capability to expose:
Ingestion success/failure status
Record-level processing outcomes (where applicable)
Standardised error reporting structure


## 📖 Linked Stories (关联的故事需求)
- **[LEAD-70](stories/LEAD-70_Verify_sourcetype_Everlytic_want2Talk2PSI_False_in_One_Connect_DAE_Platform.md)**: Verify sourcetype = "Everlytic" & "want2Talk2PSI: False" in One Connect DAE Platform  *(状态: Ready for Deployment | 故事点数: 3)*
- **[LEAD-69](stories/LEAD-69_Define_File_Failure_Handling_Retry_and_Escalation_Rules_for_Lead_Ingestion.md)**:  Define File Failure Handling, Retry, and Escalation Rules for Lead Ingestion *(状态: Ready for Deployment | 故事点数: 2)*
- **[LEAD-68](stories/LEAD-68_Record_Level_Failure_Visibility_business.md)**: Record Level:  Failure Visibility ( business) *(状态: Ready for Deployment | 故事点数: 2)*
- **[LEAD-49](stories/LEAD-49_File_level_Failure_reasons_Notification_IT.md)**: File level: Failure reasons  & Notification (IT) *(状态: Ready for Deployment | 故事点数: 2)*
- **[LEAD-48](stories/LEAD-48_Unified_Lead_Ingestion_All_Lead_Types.md)**: Unified Lead Ingestion (All Lead Types) *(状态: Ready for Deployment | 故事点数: 2)*
- **[LEAD-47](stories/LEAD-47_Unified_Lead_routing.md)**: Unified Lead routing *(状态: Ready for Deployment | 故事点数: 2)*

---

### 💡 AI 深度技术分析与卡点评估

#### 1. 核心功能目标 (Business Goal)
支持所有线索数据源（以 Everlytic 作为首期落地点）的自动化入栈，兼容中介（Intermediated）与非中介线索。

#### 2. 业务边界与核心场景 (Scope & Boundaries)
- **业务范围**：规范化 Everlytic 传入的 Payload，识别 `want2Talk2PSI` 布尔标签并映射为内部入参。
- **输入数据**：依赖前置校验合格后流入的 Standard Payload 数据结构。
- **输出流向**：记录结果审计入库、下发 SQS 或进行页面渲染。

#### 3. 技术方案设计与难点评估 (Technical Design & Complexity)
- **技术实现**：构建 `EverlyticIngestionController` 作为 Webhook 接收端，解析 Payload 并转换为统一的 `IngestionDTO`，写入 SQS 消息队列。
- **复杂度评估**：**中 (Medium)**。主要考量高并发去重加锁、大文件批处理时的 JVM 内存分配，以及多系统对接时的时延控制。
