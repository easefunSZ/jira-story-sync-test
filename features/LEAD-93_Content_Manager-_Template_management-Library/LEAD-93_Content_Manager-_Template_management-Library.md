# Feature - LEAD-93: Content Manager- Template management-Library

## 📋 Jira Metadata
| Field | Value |
| :--- | :--- |
| **Jira Key** | `LEAD-93` |
| **Type** | `Feature` |
| **Status** | `Refinement` |
| **Parent Epic** | `LEAD-11` |
| **Labels** | `DOR_FEAT` |
| **Components** | `none` |

## 📖 Original Description
Background and Opportunity
English
Mandarin (简体中文)
Templates are currently managed through poorly structured naming conventions, making it difficult for advisers to understand the purpose of a template or locate the correct content. Template names are often inconsistent and do not clearly reflect the business context (e.g. rewards, missed premiums, retirement, retrenchment). As a result, advisers are required to rely on guesswork when selecting templates, leading to inefficiency, incorrect usage, and reduced confidence in the template library. A structured categorisation model is required to organise templates by business meaning rather than naming, enabling intuitive navigation and accurate template selection.
当前模板主要通过不规范的命名进行管理，导致顾问难以理解模板的用途，也难以快速找到合适的内容。模板名称往往不一致，且无法清楚反映业务场景（例如：奖励、欠费、退休、裁员等）。因此，顾问在选择模板时需要依赖猜测，降低工作效率，也容易使用错误模板，影响对系统的信任。为了解决这个问题，需要建立基于业务分类的结构，将模板按实际业务意义进行组织，而不是依赖名称，从而提升查找体验和使用准确性。
Feature Goal
English
Mandarin (简体中文)
Create a structured template library that improves discoverability and ensures only latest template is visible
建立一个结构化的模板库，提高查找效率，并确保顾问只能看到最新
模板
Key Concepts
English
Mandarin (简体中文)
Template
模板
Folder / Category
分类 / 文件夹
Content Manager
内容管理员
Adviser
顾问
Publish
发布
Draft
草稿
Audit History
审计记录
Latest Template
最新模板
Feature Scope
English
Mandarin (简体中文)
Folder-based structure for templates
基于分类的模板结构
Edit template content
编辑模板内容
Edit template labels
编辑模板标签
Publish templates
发布模板
Audit history tracking
记录审计日志
Folder Management (Create, rename, delete)

Folder ordering (reorder/navigation control)

Template categorisation (assign/move templates between folders)

Adviser navigation (browse templates via folders)

Latest version enforcement

Scalability & extensibility (future content types)



## 📖 Linked Stories (关联的故事需求)
- **[LEAD-300](stories/LEAD-300_Bulk_upload_of_templates.md)**: Bulk upload of templates *(状态: 待办)*
- **[LEAD-299](stories/LEAD-299_Enforce_role-based_restriction.md)**: Enforce role-based restriction *(状态: 待办)*
- **[LEAD-298](stories/LEAD-298_Validation_and_rules_for_folders.md)**: Validation and rules for folders *(状态: 待办)*
- **[LEAD-297](stories/LEAD-297_Support_Mutiple_Content_Types.md)**: Support Mutiple Content Types *(状态: 待办)*
- **[LEAD-296](stories/LEAD-296_Search_Templates.md)**: Search Templates *(状态: 待办)*
- **[LEAD-295](stories/LEAD-295_Categorise_template.md)**: Categorise template *(状态: 待办)*
- **[LEAD-294](stories/LEAD-294_Re-order_folders.md)**: Re-order folders *(状态: 待办)*
- **[LEAD-293](stories/LEAD-293_Maintain_Folder_Hierarchy.md)**: Maintain Folder Hierarchy *(状态: 待办)*
- **[LEAD-280](stories/LEAD-280_Version_History.md)**: Version History *(状态: 待办)*
- **[LEAD-279](stories/LEAD-279_Draft_Publish_Workflow.md)**: Draft & Publish Workflow *(状态: 待办)*
- **[LEAD-278](stories/LEAD-278_Edit_Template_Content.md)**: Edit Template Content *(状态: 待办)*
- **[LEAD-277](stories/LEAD-277_Adviser_Template_Library_View.md)**: Adviser Template Library View *(状态: 待办)*
- **[LEAD-276](stories/LEAD-276_FolderCategory_Structure_Management.md)**: Folder/Category  Structure Management *(状态: 待办)*

---

### 💡 AI 深度技术分析与卡点评估

#### 1. 核心功能目标 (Business Goal)
构建统一规范的 Content Library（模板云盘），组织和共享 Email/SMS/视频模板。

#### 2. 业务边界与核心场景 (Scope & Boundaries)
- **业务范围**：支持对模板的分类打标、版本管理，并为顾问提供極速检索响应。
- **输入数据**：依赖前置校验合格后流入的 Standard Payload 数据结构。
- **输出流向**：记录结果审计入库、下发 SQS 或进行页面渲染。

#### 3. 技术方案设计与难点评估 (Technical Design & Complexity)
- **技术实现**：使用 Redis 缓存常用的模板卡片，采用 Elasticsearch 对模板 Summary 和标签进行倒排索引与模糊查询。
- **复杂度评估**：**中 (Medium)**。主要考量高并发去重加锁、大文件批处理时的 JVM 内存分配，以及多系统对接时的时延控制。
