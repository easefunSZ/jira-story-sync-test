# Feature - LEAD-272: Leads -Campaign Management

## 📋 Jira Metadata
| Field | Value |
| :--- | :--- |
| **Jira Key** | `LEAD-272` |
| **Type** | `Feature` |
| **Status** | `打开` |
| **Parent Epic** | `LEAD-36` |
| **Labels** | `DOR_FEAT` |
| **Components** | `Leads Additions` |

## 📖 Original Description
Bepsoke campaign , to look at if advisers want campaign to look like it is from them.
Enhance PF lea


---

### 💡 AI 深度技术分析与卡点评估

#### 1. 核心功能目标 (Business Goal)
为顾问提供专属的定制活动信息配置，支持顾问绑定自己特有的 Campaign display 面板。

#### 2. 业务边界与核心场景 (Scope & Boundaries)
- **业务范围**：活动定制化属性，仅面向理财顾问前端展示控制。
- **输入数据**：依赖前置校验合格后流入的 Standard Payload 数据结构。
- **输出流向**：记录结果审计入库、下发 SQS 或进行页面渲染。

#### 3. 技术方案设计与难点评估 (Technical Design & Complexity)
- **技术实现**：前端开发 `CampaignConfigurator` 组件绑定专属中介 sales code 属性，后端基于关系表存储配置。
- **复杂度评估**：**中 (Medium)**。主要考量高并发去重加锁、大文件批处理时的 JVM 内存分配，以及多系统对接时的时延控制。
