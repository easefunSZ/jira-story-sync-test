# Epic / 长篇故事 - LEAD-35: Leads Allocation

## 📋 Jira Metadata
| Field | Value |
| :--- | :--- |
| **Jira Key** | `LEAD-35` |
| **Type** | `Epic / 长篇故事` |
| **Status** | `正在进行` |
| **Parent Epic** | `None` |
| **Labels** | `none` |
| **Components** | `none` |

## 📖 Original Description
Empty


## 📖 Linked Stories (关联的故事需求)
- **[LEAD-8](stories/LEAD-8_opt.md)**: Opt in and out of campaigns *(状态: 打开 | 故事点数: 3)*
- **[LEAD-7](stories/LEAD-7_rules.md)**: Lead Allocation : Rules  *(状态: 打开 | 故事点数: 5)*
- **[LEAD-6](stories/LEAD-6.md)**: Enhance ingestion of  lead data *(状态: Ready for Deployment | 故事点数: 3)*

---

### 💡 AI 深度技术分析与卡点评估

#### 1. 核心功能目标 (Business Goal)
构建线索分配逻辑的大脑，统一协调 Reward Leads 与 PF General Leads 的分配路由决策分发。

#### 2. 业务边界与核心场景 (Scope & Boundaries)
- **业务范围**：只处理验证通过的线索，通过责任链与下游的 BPM、URule 进行集成。本期只负责物理链路解耦，不修改分配引擎核心逻辑以隔离风险。
- **输入数据**：依赖前置校验合格后流入的 Standard Payload 数据结构。
- **输出流向**：记录结果审计入库、下发 SQS 或进行页面渲染。

#### 3. 技术方案设计与难点评估 (Technical Design & Complexity)
- **技术实现**：在 `Orchestrator` 入口处建立状态机拦截，若线索校验中出现 Hard Stop，则拦截分配流并标记线索状态，仅校验无阻断异常的线索才能触发下游派单节点。
- **复杂度评估**：**中 (Medium)**。主要考量高并发去重加锁、大文件批处理时的 JVM 内存分配，以及多系统对接时的时延控制。
