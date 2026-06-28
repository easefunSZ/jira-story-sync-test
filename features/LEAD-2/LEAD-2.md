# Feature - LEAD-2: Birthday Filter

## 📋 Jira Metadata
| Field | Value |
| :--- | :--- |
| **Jira Key** | `LEAD-2` |
| **Type** | `Feature` |
| **Status** | `打开` |
| **Parent Epic** | `UEJC-1084` |
| **Labels** | `DOR_FEAT` |
| **Components** | `Leads Fix` |

## 📖 Original Description
tbd


---

### 💡 AI 深度技术分析与卡点评估

#### 1. 核心功能目标 (Business Goal)
为顾问提供生日线索快捷筛选过滤组件。

#### 2. 业务边界与核心场景 (Scope & Boundaries)
- **业务范围**：顾问首页线索卡片的按 DOB 周期快速查看。
- **输入数据**：依赖前置校验合格后流入的 Standard Payload 数据结构。
- **输出流向**：记录结果审计入库、下发 SQS 或进行页面渲染。

#### 3. 技术方案设计与难点评估 (Technical Design & Complexity)
- **技术实现**：在 `lead_record` 的 `date_of_birth` 字段上添加数据库索引，前端设计 Slider 时间轮过滤组件。
- **复杂度评估**：**中 (Medium)**。主要考量高并发去重加锁、大文件批处理时的 JVM 内存分配，以及多系统对接时的时延控制。
