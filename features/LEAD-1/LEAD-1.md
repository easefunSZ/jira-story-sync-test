# Feature - LEAD-1: Leads-Campaign Management-UI Changes to display information

## 📋 Jira Metadata
| Field | Value |
| :--- | :--- |
| **Jira Key** | `LEAD-1` |
| **Type** | `Feature` |
| **Status** | `打开` |
| **Parent Epic** | `None` |
| **Labels** | `DOR_FEAT` |
| **Components** | `Leads Fix` |

## 📖 Original Description
To be updated, the ability show  lead categories, such as source and campaign name and Customer type (prospect/existing as fields), that can be filtered on.Reconfig of display


---

### 💡 AI 深度技术分析与卡点评估

#### 1. 核心功能目标 (Business Goal)
线索界面卡片显示配置化重构，支持展示来源、活动名称和客户类型。

#### 2. 业务边界与核心场景 (Scope & Boundaries)
- **业务范围**：整体列表显示的自定义展示字段控制。
- **输入数据**：依赖前置校验合格后流入的 Standard Payload 数据结构。
- **输出流向**：记录结果审计入库、下发 SQS 或进行页面渲染。

#### 3. 技术方案设计与难点评估 (Technical Design & Complexity)
- **技术实现**：基于 React Table 的 column config 实现，顾问可自定义勾选需要展示的字段并保存在本地 `localStorage`。
- **复杂度评估**：**中 (Medium)**。主要考量高并发去重加锁、大文件批处理时的 JVM 内存分配，以及多系统对接时的时延控制。
