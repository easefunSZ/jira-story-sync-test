# Feature - LEAD-7: Lead Allocation : Rules 

## 📋 Jira Metadata
| Field | Value |
| :--- | :--- |
| **Jira Key** | `LEAD-7` |
| **Type** | `Feature` |
| **Status** | `打开` |
| **Parent Epic** | `LEAD-35` |
| **Labels** | `DOR_FEAT` |
| **Components** | `Leads Fix` |

## 📖 Original Description
Rule 1:Adviser Availability Management
When advisers are unavailable, due to leaving the business or makes themselves unavailable, leads should not be allocated to them.
Context:
The “unavailable adviser” status is currently not included in the lead allocation logic, which impacts both customer and adviser experience. (Feedback from previous architect)
Rule 2
Ensure all allocation rules are in place including High Leads rules
Rule 3
Ensuring that the sla for leads for  hot leads is correct, currently it expires prior to adviser actioning it.
P0tential Rule4, to be reviewed with business this was a feature MFC cloned onto our board which I removed.
“Where a hot lead is received for a customer who already has an active lead in DAE, a new lead must not be created.
Instead:
A hot lead indicator/notification must be displayed against the existing customer/lead.
The existing lead must be prioritised to the top of the leads list to ensure immediate attention.”
Lead Creation Rules
When a hot lead is received for a customer with an existing active lead, no new lead is created in DAE.
The system correctly identifies an active lead client before applying hot lead logic.
Hot leads for customers without an active lead continue to create a new lead as per existing rules.
Hot Lead Indicator
A clear hot lead indicator or notification is displayed on the existing lead/customer record.
The indicator is visually distinguishable from standard leads.
The indicator includes relevant context (e.g. source = Everlytic, date/time received).
Lead Prioritisation
Leads with an active hot lead indicator are automatically prioritised to the top of the leads list.
Re-prioritisation occurs in real time or within an acceptable processing window.
Sorting and filtering functionality continues to work without removing hot lead prioritisation.
Lead Creation Rules
When a hot lead is received for a customer with an existing active lead, no new lead is created in DAE.
The system correctly identifies an active lead client before applying hot lead logic.
Hot leads for customers without an active lead continue to create a new lead as per existing rules.
Hot Lead Indicator
A clear hot lead indicator or notification is displayed on the existing lead/customer record.
The indicator is visually distinguishable from standard leads.
The indicator includes relevant context (e.g. source = Everlytic, date/time received).
Lead Prioritisation
Leads with an active hot lead indicator are automatically prioritised to the top of the leads list.
Re-prioritisation occurs in real time or within an acceptable processing window.
Sorting and filtering functionality continues to work without removing hot lead prioritisation.
Lead Creation Rules
When a hot lead is received for a customer with an existing active lead, no new lead is created in DAE.
The system correctly identifies an active lead client before applying hot lead logic.
Hot leads for customers without an active lead continue to create a new lead as per existing rules.
Hot Lead Indicator
A clear hot lead indicator or notification is displayed on the existing lead/customer record.
The indicator is visually distinguishable from standard leads.
The indicator includes relevant context (e.g. source = Everlytic, date/time received).
Lead Prioritisation
Leads with an active hot lead indicator are automatically prioritised to the top of the leads list.
Re-prioritisation occurs in real time or within an acceptable processing window.
Sorting and filtering functionality continues to work without removing hot lead prioritisation.”


## 📖 Linked Stories (关联的故事需求)
- **[LEAD-99](stories/LEAD-99_Allocate_leads_only_to_eligible_advisers.md)**: Allocate leads only to eligible advisers *(状态: 待办 | 故事点数: 3)*

---

### 💡 AI 深度技术分析与卡点评估

#### 1. 核心功能目标 (Business Goal)
在线索分配逻辑中强集成顾问可用性状态（Availability Status）拦截，防止死单。

#### 2. 业务边界与核心场景 (Scope & Boundaries)
- **业务范围**：当顾问处于休假或离开状态时，派单路由自动将其从候选队列中剔除。
- **输入数据**：依赖前置校验合格后流入的 Standard Payload 数据结构。
- **输出流向**：记录结果审计入库、下发 SQS 或进行页面渲染。

#### 3. 技术方案设计与难点评估 (Technical Design & Complexity)
- **技术实现**：派单路由前置读取 DAE 数据库中理财顾问的 `availability_flag`。若状态不可用，路由逻辑重新进行权重分配，分流至备用顾问或回到等待池。
- **复杂度评估**：**中 (Medium)**。主要考量高并发去重加锁、大文件批处理时的 JVM 内存分配，以及多系统对接时的时延控制。
