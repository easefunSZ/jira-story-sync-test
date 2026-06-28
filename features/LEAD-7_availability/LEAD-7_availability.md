# Feature - LEAD-7: Lead allocation : Adviser Availability Management

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
When advisers are unavailable, due to leaving the business or makes themselves unavailable, leads should not be allocated to them.
Context:
The “unavailable adviser” status is currently not included in the lead allocation logic, which impacts both customer and adviser experience. (Feedback from previous architect)


## 📖 Linked Stories (关联的故事需求)
- **[LEAD-99](stories/LEAD-99.md)**: Allocate leads only to eligible advisers *(状态: 待办)*

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
