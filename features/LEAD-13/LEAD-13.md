# Feature - LEAD-13: 630 - Enhance Everlytic Lead allocations (Avoid duplicate leads)

## 📋 Jira Metadata
| Field | Value |
| :--- | :--- |
| **Jira Key** | `LEAD-13` |
| **Type** | `Feature` |
| **Status** | `打开` |
| **Parent Epic** | `LEAD-33` |
| **Labels** | `DOR_FEAT` |
| **Components** | `Leads Fix` |

## 📖 Original Description
Where a hot lead is received for a customer who already has an active lead in DAE, a new lead must not be created.
Instead:
A hot lead indicator/notification must be displayed against the existing customer/lead.
The existing lead must be prioritised to the top of the leads list to ensure immediate attention.
Solution Design Needed - YES
A mechanism will be needed to identify a dupicate lead alreadin in DAE
ENABLER - YES
Everlytic Tech team - Fabio dos SantosMornay
OM Data Needed - MAYBE
OM Tech Work - YES
APi update for leads coming in from Everlytic
OCTech Work - YES
APi update for leads coming in from Everlytic
UI/UX Needed - YES
Some info from this api needs to map to areas on the UI


## 📖 Linked Stories (关联的故事需求)
- **[LEAD-46](stories/LEAD-46.md)**: Test duplicate lead prevention and hot lead indicator functionality *(状态: 待办)*
- **[LEAD-45](stories/LEAD-45.md)**: Map Everlytic lead data to UI components *(状态: 待办)*
- **[LEAD-44](stories/LEAD-44.md)**: Prioritise leads with hot lead indicator at the top of leads list *(状态: 待办)*
- **[LEAD-43](stories/LEAD-43.md)**: Implement hot lead indicator/notification on existing leads *(状态: 待办)*
- **[LEAD-42](stories/LEAD-42.md)**: Update API to prevent creation of duplicate leads from Everlytic *(状态: 待办)*
- **[LEAD-41](stories/LEAD-41.md)**: Design mechanism to identify duplicate active leads in DAE *(状态: 待办)*

---

### 💡 AI 深度技术分析与卡点评估

#### 1. 核心功能目标 (Business Goal)
针对 Everlytic 数据源，防止对已有活跃线索的客户生成重复线索。

#### 2. 业务边界与核心场景 (Scope & Boundaries)
- **业务范围**：当接收到 hot lead 时，不生成新线索，而是更新已有线索的 "Hot Lead" 标志，并将其优先级提至列表最前。
- **输入数据**：依赖前置校验合格后流入的 Standard Payload 数据结构。
- **输出流向**：记录结果审计入库、下发 SQS 或进行页面渲染。

#### 3. 技术方案设计与难点评估 (Technical Design & Complexity)
- **技术实现**：在线索去重匹配层实现“查重不丢弃、转为优先级提升”的控制逻辑。用 Redis 对客户 ID 加分布式排他锁，并发查询 `lead_record` 状态并执行 update 行为。
- **复杂度评估**：**中 (Medium)**。主要考量高并发去重加锁、大文件批处理时的 JVM 内存分配，以及多系统对接时的时延控制。
