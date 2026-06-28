# Feature - LEAD-3: UI Changes

## 📋 Jira Metadata
| Field | Value |
| :--- | :--- |
| **Jira Key** | `LEAD-3` |
| **Type** | `Feature` |
| **Status** | `打开` |
| **Parent Epic** | `LEAD-36` |
| **Labels** | `DOR_FEAT` |
| **Components** | `User Experience Audit` |

## 📖 Original Description
Tracey a A few to add here…
 1. Allocation outcome   - Campaign Team cannot see outcome of Intermediated lead assigned to allocation group. Need Name of allocation group to appear on allocation screen.
 Lead vs Campaign confusion - Add Campaign Classification ( Aquisition or Existing  Customer and Lead Category ( prospect  or existing customer)
Lack of filters - adviser want to fielter a lead on Priority; Lead Category


---

### 💡 AI 深度技术分析与卡点评估

#### 1. 核心功能目标 (Business Goal)
优化线索展示界面：对 Intermediated lead 在分配屏幕上显示 allocation group 物理名称，增加 Acquisition/Existing 标识。

#### 2. 业务边界与核心场景 (Scope & Boundaries)
- **业务范围**：防止顾问对派单去向产生理解偏差，优化 display 控制。
- **输入数据**：依赖前置校验合格后流入的 Standard Payload 数据结构。
- **输出流向**：记录结果审计入库、下发 SQS 或进行页面渲染。

#### 3. 技术方案设计与难点评估 (Technical Design & Complexity)
- **技术实现**：前端 React 表格组件通过关联查询补齐 `allocation_group_name`，增强表单的可读性与视觉区分。
- **复杂度评估**：**中 (Medium)**。主要考量高并发去重加锁、大文件批处理时的 JVM 内存分配，以及多系统对接时的时延控制。
