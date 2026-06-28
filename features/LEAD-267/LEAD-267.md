# Feature - LEAD-267: Leads-Workflow reconfig

## 📋 Jira Metadata
| Field | Value |
| :--- | :--- |
| **Jira Key** | `LEAD-267` |
| **Type** | `Feature` |
| **Status** | `打开` |
| **Parent Epic** | `LEAD-34` |
| **Labels** | `DOR_FEAT` |
| **Components** | `Leads Additions` |

## 📖 Original Description
Reduce  and simplify no of clicks to select and action leads. Remaing lables to slaes opp vs no of leads


---

### 💡 AI 深度技术分析与卡点评估

#### 1. 核心功能目标 (Business Goal)
精简和优化理财顾问在 DAE 系统上处理线索的交互工作流，极大降低点击次数。

#### 2. 业务边界与核心场景 (Scope & Boundaries)
- **业务范围**：重命名线索状态为 "Sales Opp"，合并冗余的点击动作。
- **输入数据**：依赖前置校验合格后流入的 Standard Payload 数据结构。
- **输出流向**：记录结果审计入库、下发 SQS 或进行页面渲染。

#### 3. 技术方案设计与难点评估 (Technical Design & Complexity)
- **技术实现**：重写前端线索跟进 State Machine，将原本繁杂的 5 次点击收敛至“一键置为机会”并优化前端数据缓存。
- **复杂度评估**：**中 (Medium)**。主要考量高并发去重加锁、大文件批处理时的 JVM 内存分配，以及多系统对接时的时延控制。
