# Feature - LEAD-192: Content Manager-Adviser template request

## 📋 Jira Metadata
| Field | Value |
| :--- | :--- |
| **Jira Key** | `LEAD-192` |
| **Type** | `Feature` |
| **Status** | `打开` |
| **Parent Epic** | `LEAD-34` |
| **Labels** | `DOR_FEAT` |
| **Components** | `Leads Additions` |

## 📖 Original Description
Ability for an adviser to request new templates to content management team


---

### 💡 AI 深度技术分析与卡点评估

#### 1. 核心功能目标 (Business Goal)
为理财顾问提供新营销模板的申请、审批及自动分发工作流。

#### 2. 业务边界与核心场景 (Scope & Boundaries)
- **业务范围**：从顾问提报、内容团队审核、批准，到最终发布到库中可用的状态流控。
- **输入数据**：依赖前置校验合格后流入的 Standard Payload 数据结构。
- **输出流向**：记录结果审计入库、下发 SQS 或进行页面渲染。

#### 3. 技术方案设计与难点评估 (Technical Design & Complexity)
- **技术实现**：建立基于 Spring StateMachine 的模板状态流控制，并结合 WebSocket 进行实时审批通知推送。
- **复杂度评估**：**中 (Medium)**。主要考量高并发去重加锁、大文件批处理时的 JVM 内存分配，以及多系统对接时的时延控制。
