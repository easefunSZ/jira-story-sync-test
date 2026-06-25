# Feature - LEAD-8: Additional Allocation Rules

## 📋 Jira Metadata
| Field | Value |
| :--- | :--- |
| **Jira Key** | `LEAD-8` |
| **Type** | `Feature` |
| **Status** | `打开` |
| **Parent Epic** | `LEAD-35` |
| **Labels** | `DOR_FEAT` |
| **Components** | `Leads Fix` |

## 📖 Original Description
Description
Ensure all allocation rules are in place including High Leads rules
Enhance PF leads rule allocation  functionality.Providing PF with the ability to configure (amend ) and manage (track) (existing)) lead business allocation  rules for specified users.
Context
Currently when changes to lead allocation allocation rules are required, business has to raise a backlog request, this results in business unable to manage leads effectively based on changing priorities
This change requires and interface that allows users within a specified role, the ability to change allocation rules as required within all PF distribution channels, with the ability to track these changes, within the PF context
Must take into account adviser availability when allocating. 

Rules are grouped by:With/without advisorsAllocation group/No allocation groupsWith postal code/without postal codeIncome bands
Considerations-Minimize no of screen and consider dynamic display-Minimize capturing-Consider dynamic field display-Rule for config-Impact to campaigns
-Field, user error messages
-Impact on running PSI check within IG
NFR considerations
-Real time updates vs batch updates-time to reflect changes made -When rule changes are being made rule must not accessible for changes and user attempting must be made aware.
-Locking for change, when a user has opened a field for change, or a rule change has been submitted but not reflected yet
Requires a solution designRequires OC inputRequires a UI design
Impacts:
E.G. Currently when advisers are in an unavailable status, they are not excluded from the leads allocation logic
Value Add/Benefit
Improved accuracy of  leads provision to correct groups.Improved turn around of lead allocation to groupsImproved management of rule effectiveness.To BusinessBusiness users do not have to log a build request and follow the build process, which will improve turn around time for rule amendments


## 📖 Linked Stories (关联的故事需求)
- **[LEAD-123](stories/LEAD-123_Test_Rule_Management_Capability_Functional_and_NFR.md)**: Test Rule Management Capability (Functional and NFR) *(状态: 待办)*
- **[LEAD-122](stories/LEAD-122_Gather_and_Document_OC_Input_for_Rule_Management.md)**: Gather and Document OC Input for Rule Management *(状态: 待办)*
- **[LEAD-121](stories/LEAD-121_Assess_and_Mitigate_Impact_on_Campaigns_and_PSI_Checks.md)**: Assess and Mitigate Impact on Campaigns and PSI Checks *(状态: 待办)*
- **[LEAD-119](stories/LEAD-119_Integrate_Rule_Management_with_Lead_Allocation_Engine.md)**: Integrate Rule Management with Lead Allocation Engine *(状态: 待办)*
- **[LEAD-117](stories/LEAD-117_Design_User_Interface_for_Rule_Configuration_and_Tracking.md)**: Design User Interface for Rule Configuration and Tracking *(状态: 待办)*
- **[LEAD-115](stories/LEAD-115_Implement_Audit_Trail_for_Rule_Changes.md)**: Implement Audit Trail for Rule Changes *(状态: 待办)*
- **[LEAD-114](stories/LEAD-114_Implement_Role-Based_Access_Control_for_Rule_Management_UI.md)**: Implement Role-Based Access Control for Rule Management UI *(状态: 待办)*
- **[LEAD-111](stories/LEAD-111_Develop_Rule_Configuration_and_Amendment_Functionality.md)**: Develop Rule Configuration and Amendment Functionality *(状态: 待办)*
- **[LEAD-110](stories/LEAD-110_Design_Rule_Management_Solution_Architecture.md)**: Design Rule Management Solution Architecture *(状态: 待办)*

---

### 💡 AI 深度技术分析与卡点评估

#### 1. 核心功能目标 (Business Goal)
实现 PF Leads 复杂分配规则的可配置和管理（如邮编、理财顾问组、收入段等）。

#### 2. 业务边界与核心场景 (Scope & Boundaries)
- **业务范围**：允许 PF Channel Head 直接在界面调整各组别分配权重，免去提 Backlog 开发流程。
- **输入数据**：依赖前置校验合格后流入的 Standard Payload 数据结构。
- **输出流向**：记录结果审计入库、下发 SQS 或进行页面渲染。

#### 3. 技术方案设计与难点评估 (Technical Design & Complexity)
- **技术实现**：基于 URule 决策表，在 UI 端配置条件转换 JSON，动态提交到 URule 引擎中进行解析应用，并记录 AOP 操作历史实现Diff对比与版本回滚。
- **复杂度评估**：**中 (Medium)**。主要考量高并发去重加锁、大文件批处理时的 JVM 内存分配，以及多系统对接时的时延控制。
