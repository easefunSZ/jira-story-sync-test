# Feature - LEAD-145: Hard Code investigation

## 📋 Jira Metadata
| Field | Value |
| :--- | :--- |
| **Jira Key** | `LEAD-145` |
| **Type** | `Feature` |
| **Status** | `正在进行` |
| **Parent Epic** | `LEAD-34` |
| **Labels** | `DOR_FEAT` |
| **Components** | `Leads Additions` |

## 📖 Original Description
The below was listed as a stories. The intent of the story was to revisit the original technical design, where validation and rules were hard coded and not configurable. The team wanted to build a config table to manage all business validations and rules for flexibility and ease of change.
Based on feedback from the engineers, this would be extremely large and the other option was to implement a second solution, that is to build a config table for all new validations and business rules going forward , as well as keeping the existing rules hard-coded .
There is not enough known to understand what the impact of having both solutions in place, will be. this feature speaks to understanding the impacts of running both solutions as well as understanding what the time, effort and scale of removing hard coded rules would be.
We should not be spending more than 2 days, we will add another feature if more time is required.
Investigation outcome required: Documented 
What was hard-coded (Business rules, validation, field rules, etc)
What is required ito of effort, (size), in order to fix , test and implement, configurable values.

Previous user stories , was linked to lead 5 and lead 6
As a Product OwnerI want all validation rules, data attributes, and reporting outputs to be configurableSo that future changes can be made without code changes or redeployment.
Scope (Cross‑Cutting)Rule configurationRule sequencingData entities and indicatorsReporting outputs (external to IG)Key OutcomesRules and conditions are metadata‑drivenNew indicators and attributes can be added via configurationAll rule outcomes are available for reporting and auditRule execution is traceable (rule name, outcome, timestamp)e

Lead 61 deleted from Feature 4 also deals with Configuration requirements
“
As a Product OwnerI want all validation rules, data attributes, and reporting outputs to be configurableSo that future changes can be made without code changes or redeployment.
Scope (Cross‑Cutting)Rule configurationRule sequencingData entities and indicatorsReporting outputs (external to IG)Key OutcomesRules and conditions are metadata‑drivenNew indicators and attributes can be added via configurationAll rule outcomes are available for reporting and auditRule execution is traceable (rule name, outcome, timestamp)


## 📖 Linked Stories (关联的故事需求)
- **[LEAD-233](stories/LEAD-233_Performance_Analysis_for_Lead_Dispatch_Process_in_IG.md)**: Performance Analysis for Lead Dispatch Process in IG *(状态: 正在进行 | 故事点数: 5)*
- **[LEAD-228](stories/LEAD-228_Hardcoded_Rules_Investigation_Configurability_Assessment_Report.md)**: Hardcoded Rules Investigation & Configurability Assessment Report *(状态: 正在进行 | 故事点数: 5)*

---

### 💡 AI 深度技术分析与卡点评估

#### 1. 核心功能目标 (Business Goal)
评估并将 DAE 存量的硬编码业务校验规则转化为完全元数据驱动/动态配置化的可视化编排方案。

#### 2. 业务边界与核心场景 (Scope & Boundaries)
- **业务范围**：线索数据校验的可配置化，新老规则双轨制并行的影响评估，以及外部报表（PFMi）的追溯性实现。
- **输入数据**：依赖前置校验合格后流入的 Standard Payload 数据结构。
- **输出流向**：记录结果审计入库、下发 SQS 或进行页面渲染。

#### 3. 技术方案设计与难点评估 (Technical Design & Complexity)
- **技术实现**：物理表设计 `leads_validation_rule` 存储 SpEL 或 URule 决策路径，用 AOP 自动拦截记录修改版本快照，微前端使用 qiankun 接入统一的规则编排面板。
- **复杂度评估**：**高 (High)**。主要考量高并发去重加锁、大文件批处理时的 JVM 内存分配，以及多系统对接时的时延控制。
