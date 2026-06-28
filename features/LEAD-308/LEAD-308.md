# Feature - LEAD-308: Content Manager-Template Management-Library-Adviser Role

## 📋 Jira Metadata
| Field | Value |
| :--- | :--- |
| **Jira Key** | `LEAD-308` |
| **Type** | `Feature` |
| **Status** | `Design Review` |
| **Parent Epic** | `LEAD-11` |
| **Labels** | `DOR_FEAT` |
| **Components** | `Leads Additions` |

## 📖 Original Description
Please note this feature is no 2, for the content manager -Library, Feature 10 2, is leads 93

Business Problem
English 
Mandarin (简体中文) 
Advisers currently struggle to find the correct templates because template names do not clearly indicate their business purpose. 
This forces advisers to rely on guesswork, resulting in inefficiencies and incorrect template usage.
 Without structured categories, advisers cannot easily navigate or locate relevant templates. 
由于模板名称无法反映实际业务用途，顾问难以快速找到正确的模板。这导致顾问需要依赖猜测进行选择，降低效率并增加错误使用的风险。在没有分类结构的情况下，顾问无法高效浏览和定位相关模板。 
Feature Goal
English 
Mandarin (简体中文) 
Enable advisers to reliably discover and use templates through a structured, consistent, and accurate library populated with correctly migrated and categorised templates. 
使顾问能够通过结构化、一致且准确的模板库轻松查找和使用模板，确保所有模板已正确迁移和分类。 
Scope
Adviser View Only
English 
Mandarin (简体中文) 
Feature scope applies to Country: South Africa, Business Segment: PF 
适用于国家：南非，业务板块：PF 
Template Discovery & Browsing
在顾问界面显示分类结构 
Display folder/category structure
Browse templates by category
按分类浏览模板 
Search, Filter & Sorting
仅显示已发布模板 
Search templates
Filter by published status
Filter by latest version
仅显示最新版本 
Template Evaluation
搜索模板 
Preview templates
View template details

Template Usage & Activation

Select template
Activate/use template

VALIDATION & BUSINESS RULES (Adviser-Specific)
Adviser can only:
View Published templates
Preview templates
Use templates
Adviser cannot:
Edit
Tag
Approve
Delete templates

Key Concepts
English 
Mandarin (简体中文) 
Template 
模板 
Folder / Category 
分类 / 文件夹 
Adviser 
顾问 
Published Template 
已发布模板 
Latest Template 
最新模板 
Migration
English 
Mandarin (简体中文) 
Adviser view must only surface templates that have been successfully migrated, validated, categorised, and published. 
 
 Templates that fail migration or classification quality checks must not be visible. 
 The library must ensure clean data, consistent categorisation, and no duplicate or ambiguous templates. 
顾问端只能显示已成功迁移、分类和发布的模板。未通过迁移或分类校验的模板不得展示。模板库必须保证数据干净、分类一致，并且不存在重复或不明确的模板。 
Key concepts involved
English 
Mandarin (简体中文) 
Template 
模板 
Folder / Category 
分类 / 文件夹 
Adviser 
顾问 
Published Template 
已发布模板 
Latest Template 
最新模板 


## 📖 Linked Stories (关联的故事需求)
- **[LEAD-323](stories/LEAD-323.md)**: View Template Pagination *(状态: 待办 | 故事点数: 3)*
- **[LEAD-322](stories/LEAD-322.md)**: Restrict Usage of DRAFT Templates *(状态: 待办 | 故事点数: 1)*
- **[LEAD-321](stories/LEAD-321.md)**: Template Usage & Activation *(状态: 待办 | 故事点数: 1)*
- **[LEAD-320](stories/LEAD-320.md)**: View Template Context Information *(状态: 待办 | 故事点数: 1)*
- **[LEAD-319](stories/LEAD-319.md)**: Preview Template *(状态: 待办 | 故事点数: 2)*
- **[LEAD-318](stories/LEAD-318.md)**: Sort Templates *(状态: 待办 | 故事点数: 1)*
- **[LEAD-317](stories/LEAD-317.md)**: Clear filters *(状态: 待办 | 故事点数: 1)*
- **[LEAD-316](stories/LEAD-316.md)**: View active filters *(状态: 待办 | 故事点数: 1)*
- **[LEAD-315](stories/LEAD-315.md)**: Apply Template Filters *(状态: 待办 | 故事点数: 3)*
- **[LEAD-314](stories/LEAD-314.md)**: Search a template *(状态: 待办 | 故事点数: 2)*
- **[LEAD-313](stories/LEAD-313.md)**: Navigate Template Categories *(状态: 待办 | 故事点数: 3)*
- **[LEAD-312](stories/LEAD-312.md)**: View Template Library *(状态: 待办 | 故事点数: 2)*

---

### 💡 AI 深度技术分析与卡点评估

#### 1. 核心功能目标 (Business Goal)
为理财顾问提供营销模板库的只读浏览和快速使用交互。

#### 2. 业务边界与核心场景 (Scope & Boundaries)
- **业务范围**：仅面向 ROLE_ADVISER 角色，不提供新建、编辑、重命名、删除或发布模板的权限。
- **输入数据**：依赖前置校验合格后流入的 Standard Payload 数据结构。
- **输出流向**：记录结果审计入库、下发 SQS 或进行页面渲染。

#### 3. 技术方案设计与难点评估 (Technical Design & Complexity)
- **技术实现**：在 React 前端组件中利用角色过滤实现只读模式，仅渲染 Live 状态下的模板文件夹及卡片信息。
- **复杂度评估**：**中 (Medium)**。主要考量高并发去重加锁、大文件批处理时的 JVM 内存分配，以及多系统对接时的时延控制。
