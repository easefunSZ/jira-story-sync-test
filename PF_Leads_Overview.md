# DAE PF Leads 需求同步与架构分析总览

该文档包含了 Jira 上与 **"DAE PF Leads"** Epic 关联的所有 Epic 和 Feature 级详细需求的同步、梳理及总结，包含其下属的所有 Story 故事级别文档及评审讨论记录。

---

## 🏗️ 功能模块分类与索引

### 📁 Ingestion (数据摄入与标准化)

- **[LEAD-6](features/LEAD-6/LEAD-6.md)**: Enhance ingestion of  lead data *(状态: Ready for Deployment)*
  - └─ **故事: [LEAD-70](features/LEAD-6/stories/LEAD-70.md)**: Verify sourcetype = "Everlytic" & "want2Talk2PSI: False" in One Connect DAE Platform  *(状态: Ready for Deployment | 点数: 3)* | **[💬 查看讨论](features/LEAD-6/stories/LEAD-70_comments.md)**
  - └─ **故事: [LEAD-69](features/LEAD-6/stories/LEAD-69.md)**:  Define File Failure Handling, Retry, and Escalation Rules for Lead Ingestion *(状态: Ready for Deployment | 点数: 2)* | **[💬 查看讨论](features/LEAD-6/stories/LEAD-69_comments.md)**
  - └─ **故事: [LEAD-68](features/LEAD-6/stories/LEAD-68.md)**: Record Level:  Failure Visibility ( business) *(状态: Ready for Deployment | 点数: 2)* | **[💬 查看讨论](features/LEAD-6/stories/LEAD-68_comments.md)**
  - └─ **故事: [LEAD-49](features/LEAD-6/stories/LEAD-49.md)**: File level: Failure reasons  & Notification (IT) *(状态: Ready for Deployment | 点数: 2)* | **[💬 查看讨论](features/LEAD-6/stories/LEAD-49_comments.md)**
  - └─ **故事: [LEAD-48](features/LEAD-6/stories/LEAD-48.md)**: Unified Lead Ingestion (All Lead Types) *(状态: Ready for Deployment | 点数: 2)* | **[💬 查看讨论](features/LEAD-6/stories/LEAD-48_comments.md)**
  - └─ **故事: [LEAD-47](features/LEAD-6/stories/LEAD-47.md)**: Unified Lead routing *(状态: Ready for Deployment | 点数: 2)* | **[💬 查看讨论](features/LEAD-6/stories/LEAD-47_comments.md)**
- **[LEAD-5](features/LEAD-5/LEAD-5.md)**: Batch Lead Ingestion-Segment Agnostic *(状态: Ready for Deployment)*
  - └─ **故事: [LEAD-149](features/LEAD-5/stories/LEAD-149.md)**: Create Demo Scenario's for showcase *(状态: 已完成 | 点数: 3)*
  - └─ **故事: [LEAD-87](features/LEAD-5/stories/LEAD-87.md)**: Batch campaign upload in IG — one error won't stop whole batch *(状态: Ready for Deployment | 点数: 5)* | **[💬 查看讨论](features/LEAD-5/stories/LEAD-87_comments.md)**
  - └─ **故事: [LEAD-67](features/LEAD-5/stories/LEAD-67.md)**: Email Notification  for File Failures *(状态: Ready for Deployment | 点数: 3)* | **[💬 查看讨论](features/LEAD-5/stories/LEAD-67_comments.md)**
  - └─ **故事: [LEAD-54](features/LEAD-5/stories/LEAD-54.md)**: Success/failure data for reporting *(状态: Ready for Deployment | 点数: 3)* | **[💬 查看讨论](features/LEAD-5/stories/LEAD-54_comments.md)**
  - └─ **故事: [LEAD-53](features/LEAD-5/stories/LEAD-53.md)**: Near real time processing *(状态: Ready for Deployment | 点数: 5)* | **[💬 查看讨论](features/LEAD-5/stories/LEAD-53_comments.md)**
  - └─ **故事: [LEAD-52](features/LEAD-5/stories/LEAD-52.md)**: Support large files *(状态: Ready for Deployment | 点数: 3)* | **[💬 查看讨论](features/LEAD-5/stories/LEAD-52_comments.md)**
  - └─ **故事: [LEAD-51](features/LEAD-5/stories/LEAD-51.md)**: Automated ingestion of manual files *(状态: Ready for Deployment | 点数: 5)* | **[💬 查看讨论](features/LEAD-5/stories/LEAD-51_comments.md)**
  - └─ **故事: [LEAD-50](features/LEAD-5/stories/LEAD-50.md)**: Use existing validation & processing rules *(状态: Ready for Deployment | 点数: 3)* | **[💬 查看讨论](features/LEAD-5/stories/LEAD-50_comments.md)**
- **[LEAD-227](features/LEAD-227_madm/LEAD-227_madm.md)**: Leads-Payload standardisation -MADM Files *(状态: Refinement)*

### 📁 Validation (数据校验与去重)

- **[LEAD-62](features/LEAD-62/LEAD-62.md)**: Leads-Data Validation-2 ( Lead & Campaigns) *(状态: 正在进行)*
  - └─ **故事: [LEAD-291](features/LEAD-62/stories/LEAD-291.md)**: Investgation for name & surname impacted scenarions *(状态: 正在进行 | 点数: 3)*
  - └─ **故事: [LEAD-253](features/LEAD-62/stories/LEAD-253.md)**: Validation Pipeline Framework Refactoring (DAE manual Creation) *(状态: Functional Testing | 点数: 3)* | **[💬 查看讨论](features/LEAD-62/stories/LEAD-253_comments.md)**
  - └─ **故事: [LEAD-245](features/LEAD-62/stories/LEAD-245.md)**: Validation Pipeline Framework Refactoring (SQS Message consumption) *(状态: Functional Testing | 点数: 8)* | **[💬 查看讨论](features/LEAD-62/stories/LEAD-245_comments.md)**
  - └─ **故事: [LEAD-209](features/LEAD-62/stories/LEAD-209.md)**: Validation Pipeline Framework Refactoring (DAE batch upload) *(状态: Ready for Development | 点数: 5)*
  - └─ **故事: [LEAD-170](features/LEAD-62/stories/LEAD-170.md)**: Create demo showcase *(状态: 已完成 | 点数: 3)*
  - └─ **故事: [LEAD-143](features/LEAD-62/stories/LEAD-143.md)**: Cross Campaign - Duplicate Decision Rules *(状态: 正在进行 | 点数: 2)*
  - └─ **故事: [LEAD-142](features/LEAD-62/stories/LEAD-142.md)**: Duplicate Rule Precedence / Processing Order  *(状态: 正在进行 | 点数: 3)* | **[💬 查看讨论](features/LEAD-62/stories/LEAD-142_comments.md)**
  - └─ **故事: [LEAD-125](features/LEAD-62/stories/LEAD-125.md)**: Lead Validation -Expose Validation Outcomes/Exception table ( to PFMI) *(状态: Ready for Development | 点数: 2)*
  - └─ **故事: [LEAD-124](features/LEAD-62/stories/LEAD-124.md)**: Lead Validation Audit Trail – Persist All Validation Outcomes per Lead *(状态: 正在进行 | 点数: 8)* | **[💬 查看讨论](features/LEAD-62/stories/LEAD-124_comments.md)**
  - └─ **故事: [LEAD-90](features/LEAD-62/stories/LEAD-90.md)**: Lead Deduplication & Cross-Campaign Management *(状态: 正在进行 | 点数: 2)* | **[💬 查看讨论](features/LEAD-62/stories/LEAD-90_comments.md)**
  - └─ **故事: [LEAD-60](features/LEAD-62/stories/LEAD-60.md)**: Campaign Existence & Status Validation *(状态: 正在进行 | 点数: 8)* | **[💬 查看讨论](features/LEAD-62/stories/LEAD-60_comments.md)**
  - └─ **故事: [LEAD-40](features/LEAD-62/stories/LEAD-40.md)**: Lead Name Validation – First Name or Surname Required *(状态: 正在进行 | 点数: 3)* | **[💬 查看讨论](features/LEAD-62/stories/LEAD-40_comments.md)**
- **[LEAD-4](features/LEAD-4/LEAD-4.md)**: Leads-Data Validation 1 ( Customer and Intermediary) *(状态: 正在进行)*
  - └─ **故事: [LEAD-269](features/LEAD-4/stories/LEAD-269.md)**: Unified Exception Handling for Validation & Allocation *(状态: Analysis | 点数: 5)*
  - └─ **故事: [LEAD-234](features/LEAD-4/stories/LEAD-234.md)**: Validation for SelectedAdvisor When ‘want2Talk2PSI=false’ *(状态: Analysis | 点数: 3)* | **[💬 查看讨论](features/LEAD-4/stories/LEAD-234_comments.md)**
  - └─ **故事: [LEAD-231](features/LEAD-4/stories/LEAD-231.md)**: Validate PSI sales code format *(状态: Analysis | 点数: 3)*
  - └─ **故事: [LEAD-230](features/LEAD-4/stories/LEAD-230.md)**:  PSI Validation & storage  for New Customers *(状态: Analysis | 点数: 3)*
  - └─ **故事: [LEAD-206](features/LEAD-4/stories/LEAD-206.md)**: Validation Rule Registry — Centralized Rule Definition & Management *(状态: Analysis | 点数: 3)* | **[💬 查看讨论](features/LEAD-4/stories/LEAD-206_comments.md)**
  - └─ **故事: [LEAD-197](features/LEAD-4/stories/LEAD-197.md)**: Allow processing when PSI missing on Lead and Customer *(状态: Analysis | 点数: 3)* | **[💬 查看讨论](features/LEAD-4/stories/LEAD-197_comments.md)**
  - └─ **故事: [LEAD-84](features/LEAD-4/stories/LEAD-84.md)**: Auto-Correct Missing Lead PSI *(状态: Analysis | 点数: 3)* | **[💬 查看讨论](features/LEAD-4/stories/LEAD-84_comments.md)**
- **[LEAD-145](features/LEAD-145/LEAD-145.md)**: Hard Code investigation *(状态: 正在进行)*
  - └─ **故事: [LEAD-233](features/LEAD-145/stories/LEAD-233.md)**: Performance Analysis for Lead Dispatch Process in IG *(状态: 正在进行 | 点数: 5)*
  - └─ **故事: [LEAD-228](features/LEAD-145/stories/LEAD-228.md)**: Hardcoded Rules Investigation & Configurability Assessment Report *(状态: 正在进行 | 点数: 5)* | **[💬 查看讨论](features/LEAD-145/stories/LEAD-228_comments.md)**
- **[LEAD-305](features/LEAD-305/LEAD-305.md)**: Leads-Data Validation 3  *(状态: 正在进行)*
  - └─ **故事: [LEAD-232](features/LEAD-305/stories/LEAD-232.md)**: Lead to Customer Match *(状态: Analysis | 点数: 3)* | **[💬 查看讨论](features/LEAD-305/stories/LEAD-232_comments.md)**
  - └─ **故事: [LEAD-58](features/LEAD-305/stories/LEAD-58.md)**: Prevent Processing for Deceased Customers *(状态: Analysis | 点数: 3)* | **[💬 查看讨论](features/LEAD-305/stories/LEAD-58_comments.md)**
  - └─ **故事: [LEAD-57](features/LEAD-305/stories/LEAD-57.md)**:  PSI Detection and Storage *(状态: Analysis | 点数: 3)* | **[💬 查看讨论](features/LEAD-305/stories/LEAD-57_comments.md)**
  - └─ **故事: [LEAD-55](features/LEAD-305/stories/LEAD-55.md)**:  Validate Matching PSI between Lead and customer *(状态: Analysis | 点数: 3)* | **[💬 查看讨论](features/LEAD-305/stories/LEAD-55_comments.md)**

### 📁 Allocation (分配路由与规则)

- **[LEAD-35](features/LEAD-35/LEAD-35.md)**: Leads Allocation *(状态: 正在进行)*
  - └─ **故事: [LEAD-8](features/LEAD-35/stories/LEAD-8_opt.md)**: Opt in and out of campaigns *(状态: 打开 | 点数: 3)*
  - └─ **故事: [LEAD-7](features/LEAD-35/stories/LEAD-7_rules.md)**: Lead Allocation : Rules  *(状态: 打开 | 点数: 5)* | **[💬 查看讨论](features/LEAD-35/stories/LEAD-7_rules_comments.md)**
  - └─ **故事: [LEAD-6](features/LEAD-35/stories/LEAD-6.md)**: Enhance ingestion of  lead data *(状态: Ready for Deployment | 点数: 3)* | **[💬 查看讨论](features/LEAD-35/stories/LEAD-6_comments.md)**
- **[LEAD-8](features/LEAD-8_opt/LEAD-8_opt.md)**: Opt in and out of campaigns *(状态: 打开)*
  - └─ **故事: [LEAD-123](features/LEAD-8_opt/stories/LEAD-123.md)**: Test Rule Management Capability (Functional and NFR) *(状态: 待办 | 点数: 3)*
  - └─ **故事: [LEAD-122](features/LEAD-8_opt/stories/LEAD-122.md)**: Gather and Document OC Input for Rule Management *(状态: 待办 | 点数: 3)* | **[💬 查看讨论](features/LEAD-8_opt/stories/LEAD-122_comments.md)**
  - └─ **故事: [LEAD-121](features/LEAD-8_opt/stories/LEAD-121.md)**: Assess and Mitigate Impact on Campaigns and PSI Checks *(状态: 待办 | 点数: 3)* | **[💬 查看讨论](features/LEAD-8_opt/stories/LEAD-121_comments.md)**
  - └─ **故事: [LEAD-119](features/LEAD-8_opt/stories/LEAD-119.md)**: Integrate Rule Management with Lead Allocation Engine *(状态: 待办 | 点数: 3)*
  - └─ **故事: [LEAD-117](features/LEAD-8_opt/stories/LEAD-117.md)**: Design User Interface for Rule Configuration and Tracking *(状态: 待办 | 点数: 3)*
  - └─ **故事: [LEAD-115](features/LEAD-8_opt/stories/LEAD-115.md)**: Implement Audit Trail for Rule Changes *(状态: 待办 | 点数: 3)*
  - └─ **故事: [LEAD-114](features/LEAD-8_opt/stories/LEAD-114.md)**: Implement Role-Based Access Control for Rule Management UI *(状态: 待办 | 点数: 3)*
  - └─ **故事: [LEAD-111](features/LEAD-8_opt/stories/LEAD-111.md)**: Develop Rule Configuration and Amendment Functionality *(状态: 待办 | 点数: 3)*
  - └─ **故事: [LEAD-110](features/LEAD-8_opt/stories/LEAD-110.md)**: Design Rule Management Solution Architecture *(状态: 待办 | 点数: 3)*
- **[LEAD-7](features/LEAD-7_rules/LEAD-7_rules.md)**: Lead Allocation : Rules  *(状态: 打开)*
  - └─ **故事: [LEAD-99](features/LEAD-7_rules/stories/LEAD-99.md)**: Allocate leads only to eligible advisers *(状态: 待办 | 点数: 3)*

### 📁 Enrichment (线索数据富化)

- **[LEAD-92](features/LEAD-92/LEAD-92.md)**: Leads-Data enrichment *(状态: 打开)*
- **[LEAD-28](features/LEAD-28/LEAD-28.md)**:  Execute lead enrichment *(状态: 打开)*
- **[LEAD-25](features/LEAD-25_intermediated/LEAD-25_intermediated.md)**: Maturity Lead Enrichment -Intermediated customers *(状态: Refinement)*
  - └─ **故事: [LEAD-266](features/LEAD-25_intermediated/stories/LEAD-266.md)**: Demo Requirements *(状态: 待办 | 点数: 3)*
  - └─ **故事: [LEAD-208](features/LEAD-25_intermediated/stories/LEAD-208.md)**: Master rule matrix *(状态: 正在进行 | 点数: 3)*
  - └─ **故事: [LEAD-176](features/LEAD-25_intermediated/stories/LEAD-176.md)**: Controlled Display of Campaign Information in Leads Pool *(状态: Analysis | 点数: 3)*
  - └─ **故事: [LEAD-175](features/LEAD-25_intermediated/stories/LEAD-175.md)**: Maturity Lead Visibility in My Leads ( after acceptance) *(状态: Analysis | 点数: 3)*
  - └─ **故事: [LEAD-66](features/LEAD-25_intermediated/stories/LEAD-66.md)**: Conditional Display of Maturity Features *(状态: Analysis | 点数: 3)*
  - └─ **故事: [LEAD-32](features/LEAD-25_intermediated/stories/LEAD-32.md)**: Audit & Reporting of Enrichment Outcomes *(状态: Analysis | 点数: 3)*
  - └─ **故事: [LEAD-29](features/LEAD-25_intermediated/stories/LEAD-29.md)**: Enrich Maturity Leads Prior to Allocation *(状态: Analysis | 点数: 3)*
- **[LEAD-309](features/LEAD-309/LEAD-309.md)**: Maturity Lead enrichment-Un-intermediated customers *(状态: Refinement)*

### 📁 Content Manager (模板与营销库)

- **[LEAD-268](features/LEAD-268/LEAD-268.md)**: Content Management- AI created template for Advisers *(状态: 打开)*
- **[LEAD-192](features/LEAD-192/LEAD-192.md)**: Content Manager-Adviser template request *(状态: 打开)*
- **[LEAD-190](features/LEAD-190/LEAD-190.md)**: Content Manager-Supporting video file uploads *(状态: 打开)*
- **[LEAD-93](features/LEAD-93_role/LEAD-93_role.md)**: Content Manager- Template management-Library-Content Manager Role *(状态: Design Review)*
  - └─ **故事: [LEAD-307](features/LEAD-93_role/stories/LEAD-307.md)**: Archive a category/subcategory *(状态: 待办 | 点数: 5)*
  - └─ **故事: [LEAD-306](features/LEAD-93_role/stories/LEAD-306.md)**: Create a new template *(状态: 待办 | 点数: 3)*
  - └─ **故事: [LEAD-303](features/LEAD-93_role/stories/LEAD-303.md)**: Upload a template file *(状态: 待办 | 点数: 5)* | **[💬 查看讨论](features/LEAD-93_role/stories/LEAD-303_comments.md)**
  - └─ **故事: [LEAD-302](features/LEAD-93_role/stories/LEAD-302.md)**: Safe a draft view template *(状态: 待办 | 点数: 1)*
  - └─ **故事: [LEAD-301](features/LEAD-93_role/stories/LEAD-301.md)**: Assign a  Category *(状态: 待办 | 点数: 1)* | **[💬 查看讨论](features/LEAD-93_role/stories/LEAD-301_comments.md)**
  - └─ **故事: [LEAD-300](features/LEAD-93_role/stories/LEAD-300.md)**: Assign Tags *(状态: 待办 | 点数: 1)* | **[💬 查看讨论](features/LEAD-93_role/stories/LEAD-300_comments.md)**
  - └─ **故事: [LEAD-299](features/LEAD-93_role/stories/LEAD-299.md)**: Edit Tags and Metadata *(状态: 待办 | 点数: 2)*
  - └─ **故事: [LEAD-298](features/LEAD-93_role/stories/LEAD-298.md)**: Edit a Template *(状态: 待办 | 点数: 3)*
  - └─ **故事: [LEAD-297](features/LEAD-93_role/stories/LEAD-297.md)**: Duplicate a template *(状态: 待办 | 点数: 2)*
  - └─ **故事: [LEAD-296](features/LEAD-93_role/stories/LEAD-296.md)**: Delete & Archive a template *(状态: 待办 | 点数: 5)*
  - └─ **故事: [LEAD-295](features/LEAD-93_role/stories/LEAD-295.md)**: Access to template actions *(状态: 待办 | 点数: 1)*
  - └─ **故事: [LEAD-294](features/LEAD-93_role/stories/LEAD-294.md)**: Edit Category *(状态: 待办 | 点数: 3)*
  - └─ **故事: [LEAD-293](features/LEAD-93_role/stories/LEAD-293.md)**: Create a category *(状态: 待办 | 点数: 3)*
  - └─ **故事: [LEAD-280](features/LEAD-93_role/stories/LEAD-280.md)**: Template versioning *(状态: 待办 | 点数: 8)*
  - └─ **故事: [LEAD-279](features/LEAD-93_role/stories/LEAD-279.md)**: Manage Draft & Publish Workflow  *(状态: 待办 | 点数: 8)* | **[💬 查看讨论](features/LEAD-93_role/stories/LEAD-279_comments.md)**
  - └─ **故事: [LEAD-278](features/LEAD-93_role/stories/LEAD-278.md)**: Manage Template Content  *(状态: 待办 | 点数: 3)*
  - └─ **故事: [LEAD-277](features/LEAD-93_role/stories/LEAD-277.md)**: Field level validation rules *(状态: 待办 | 点数: 3)*
  - └─ **故事: [LEAD-276](features/LEAD-93_role/stories/LEAD-276.md)**: Reassign Template to a Different Category  *(状态: 待办 | 点数: 3)*
- **[LEAD-308](features/LEAD-308/LEAD-308.md)**: Content Manager-Template Management-Library-Adviser Role *(状态: Design Review)*
  - └─ **故事: [LEAD-323](features/LEAD-308/stories/LEAD-323.md)**: View Template Pagination *(状态: 待办 | 点数: 3)*
  - └─ **故事: [LEAD-322](features/LEAD-308/stories/LEAD-322.md)**: Restrict Usage of DRAFT Templates *(状态: 待办 | 点数: 1)*
  - └─ **故事: [LEAD-321](features/LEAD-308/stories/LEAD-321.md)**: Template Usage & Activation *(状态: 待办 | 点数: 1)*
  - └─ **故事: [LEAD-320](features/LEAD-308/stories/LEAD-320.md)**: View Template Context Information *(状态: 待办 | 点数: 1)*
  - └─ **故事: [LEAD-319](features/LEAD-308/stories/LEAD-319.md)**: Preview Template *(状态: 待办 | 点数: 2)*
  - └─ **故事: [LEAD-318](features/LEAD-308/stories/LEAD-318.md)**: Sort Templates *(状态: 待办 | 点数: 1)*
  - └─ **故事: [LEAD-317](features/LEAD-308/stories/LEAD-317.md)**: Clear filters *(状态: 待办 | 点数: 1)*
  - └─ **故事: [LEAD-316](features/LEAD-308/stories/LEAD-316.md)**: View active filters *(状态: 待办 | 点数: 1)*
  - └─ **故事: [LEAD-315](features/LEAD-308/stories/LEAD-315.md)**: Apply Template Filters *(状态: 待办 | 点数: 3)*
  - └─ **故事: [LEAD-314](features/LEAD-308/stories/LEAD-314.md)**: Search a template *(状态: 待办 | 点数: 2)*
  - └─ **故事: [LEAD-313](features/LEAD-308/stories/LEAD-313.md)**: Navigate Template Categories *(状态: 待办 | 点数: 3)*
  - └─ **故事: [LEAD-312](features/LEAD-308/stories/LEAD-312.md)**: View Template Library *(状态: 待办 | 点数: 2)*

### 📁 UI & Reporting (界面展示与监督报表)

- **[LEAD-272](features/LEAD-272/LEAD-272.md)**: Leads -Campaign Management *(状态: 打开)*
- **[LEAD-267](features/LEAD-267/LEAD-267.md)**: Leads-Workflow reconfig *(状态: 打开)*
- **[LEAD-265](features/LEAD-265_intermediated/LEAD-265_intermediated.md)**: Maturity Leads_ AI conversation guide-Intermediated *(状态: Refinement)*
  - └─ **故事: [LEAD-229](features/LEAD-265_intermediated/stories/LEAD-229.md)**: Audit & reporting of  AI Usage ( conversation guide) *(状态: 正在进行 | 点数: 2)* | **[💬 查看讨论](features/LEAD-265_intermediated/stories/LEAD-229_comments.md)**
  - └─ **故事: [LEAD-207](features/LEAD-265_intermediated/stories/LEAD-207.md)**: Enforce AI Compliance & Disclaimer *(状态: 待办 | 点数: 1)*
  - └─ **故事: [LEAD-177](features/LEAD-265_intermediated/stories/LEAD-177.md)**: AI Conversation Guide (Expandable Panel) *(状态: 待办 | 点数: 3)*
- **[LEAD-9](features/LEAD-9/LEAD-9.md)**: Campaign & Leads Data-Reporting-Management Oversight *(状态: 打开)*
  - └─ **故事: [LEAD-193](features/LEAD-9/stories/LEAD-193.md)**: Expose Exception data *(状态: 待办 | 点数: 1)*
  - └─ **故事: [LEAD-189](features/LEAD-9/stories/LEAD-189.md)**: Expose Lead closure reasons *(状态: 待办 | 点数: 1)*
  - └─ **故事: [LEAD-188](features/LEAD-9/stories/LEAD-188.md)**: Expose Lead priority and volumes *(状态: 待办 | 点数: 2)*
  - └─ **故事: [LEAD-116](features/LEAD-9/stories/LEAD-116.md)**: Expose SLA Indicators *(状态: 待办 | 点数: 3)* | **[💬 查看讨论](features/LEAD-9/stories/LEAD-116_comments.md)**
  - └─ **故事: [LEAD-112](features/LEAD-9/stories/LEAD-112.md)**: Expose  Lead state and Lead state change timestamps *(状态: 待办 | 点数: 3)* | **[💬 查看讨论](features/LEAD-9/stories/LEAD-112_comments.md)**
  - └─ **故事: [LEAD-109](features/LEAD-9/stories/LEAD-109.md)**: Expose Lead allocation data *(状态: 待办 | 点数: 3)* | **[💬 查看讨论](features/LEAD-9/stories/LEAD-109_comments.md)**
  - └─ **故事: [LEAD-107](features/LEAD-9/stories/LEAD-107.md)**: Enhance Consumable Data Feed Access *(状态: 待办 | 点数: 3)* | **[💬 查看讨论](features/LEAD-9/stories/LEAD-107_comments.md)**
  - └─ **故事: [LEAD-105](features/LEAD-9/stories/LEAD-105.md)**: Expose campaign metadata and metadata success  *(状态: Analysis | 点数: 3)* | **[💬 查看讨论](features/LEAD-9/stories/LEAD-105_comments.md)**
- **[LEAD-3](features/LEAD-3/LEAD-3.md)**: UI Changes *(状态: 打开)*
- **[LEAD-2](features/LEAD-2/LEAD-2.md)**: Birthday Filter *(状态: 打开)*
- **[LEAD-1](features/LEAD-1/LEAD-1.md)**: Leads-Campaign Management-UI Changes to display information *(状态: 打开)*
- **[LEAD-310](features/LEAD-310/LEAD-310.md)**: Maturity Leads_ AI conversation guide Un-intermediated *(状态: 打开)*

---

## 📈 功能路线图与架构总结

### 1. 校验与分配层彻底解耦 (Validation & Allocation Decoupling)
目前 DAE 重构的核心切入点是将“线索校验 (Validation)”与“线索分配 (Allocation)”在物理链路及逻辑控制器上完全解耦：
- **线索数据校验（Ingestion & Validation）**：由 [LEAD-4](features/LEAD-4/LEAD-4.md)、[LEAD-62](features/LEAD-62/LEAD-62.md) 校验链拦截，包括 PSI（中介代码）、Deceased（死亡库）和 Campaign Validity 有效性。
- **线索分配算法（Allocation & Rules）**：由 [LEAD-35](features/LEAD-35/LEAD-35.md)（BPM URule 决策流）处理分发，解耦能保障存量分配不受重构影响。

### 2. 线索富化与意图识别 (Enrichment)
在 [LEAD-25](features/LEAD-25_maturity/LEAD-25_maturity.md)、[LEAD-92](features/LEAD-92/LEAD-92.md) 中，增加了销售意图、联系历史和收入段的智能富化，并在前端以丰富卡片展示，帮助顾问制定针对性销售策略。

### 3. 内容与模板库智能化 (Content Manager)
在 [LEAD-93](features/LEAD-93_library/LEAD-93_library.md) 中，创建了统一的顾问营销模板库，未来结合 [LEAD-268](features/LEAD-268/LEAD-268.md) 引入 AI 自动生成电销/邮件文案，并在 [LEAD-190](features/LEAD-190/LEAD-190.md) 支持视频文件，极大强化了顾问的展业手段。
