# Feature - LEAD-93: Content Manager- Template management-Library-Content Manager Role

## 📋 Jira Metadata
| Field | Value |
| :--- | :--- |
| **Jira Key** | `LEAD-93` |
| **Type** | `Feature` |
| **Status** | `Design Review` |
| **Parent Epic** | `LEAD-11` |
| **Labels** | `DOR_FEAT` |
| **Components** | `none` |

## 📖 Original Description
Background and Opportunity
English
Mandarin (简体中文)
The current template layout is just a simple list. Advisers have to rely on template names and their memory to find the right one. It does not provide a clear structure that helps them easily find and use the correct template.
Templates are currently managed through poorly structured naming conventions, making it difficult for advisers to understand the purpose of a template or locate the correct content. 
Template names are often inconsistent and do not clearly reflect the business context (e.g. rewards, missed premiums, retirement, retrenchment). As a result, advisers are required to rely on guesswork when selecting templates, leading to inefficiency, incorrect usage, and reduced confidence in the template library.
 A structured categorisation model is required to organise templates by business meaning rather than naming, enabling intuitive navigation and accurate template selection. 
当前模板主要通过不规范的命名进行管理，导致顾问难以理解模板的用途，也难以快速找到合适的内容。模板名称往往不一致，且无法清楚反映业务场景（例如：奖励、欠费、退休、裁员等）。因此，顾问在选择模板时需要依赖猜测，降低工作效率，也容易使用错误模板，影响对系统的信任。为了解决这个问题，需要建立基于业务分类的结构，将模板按实际业务意义进行组织，而不是依赖名称，从而提升查找体验和使用准确性。
Feature Goal
English
Mandarin (简体中文)
Create a business -structured template library that makes it easy for advisers to find the right template, use the latest  content, avoid selecting the wrong template, and allows the business to manage templates in a consistent and scalable way.
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
This feature will cover the  Content Manager  Scope only ;
1.Template Creation & Upload
Create new templates
Upload template files ( pdf; .txt; .mp4; .mp3; .html, .htm)
Failed upload
Save drafts
2. Template Metadata, Tagging & Categorisation
Create categories/subcategories
Edit or delete category
Assign categories/subcategories
Apply tags (Persona, Life Stage, Trigger, Format)
Maintain structured taxonomy
3. Template Editing & Lifecycle Management
Create/ Edit templates
Duplicate templates
Re-assign template to a new category
Delete/archive templates
Manage versioning 
4. Template Review & Approval Workflow
Create, edit, save Draft - Publish
Manage status 
5. Template Preview & Validation
Preview templates before publishing
Validate formatting and content quality
6. Template Administration & Actions
Use action menu (edit, duplicate, -reassign, delete)
Field rules & validations
Template Title; Template description; Template type
Metadata & tagging
Workflow and status
Versioning
Editing rules
Duplication rules
Delete/archive rules
Action menu rules 
8.Migration of existing templates


## 📖 Linked Stories (关联的故事需求)
- **[LEAD-307](stories/LEAD-307_Archive_a_categorysubcategory.md)**: Archive a category/subcategory *(状态: 待办 | 故事点数: 5)*
- **[LEAD-306](stories/LEAD-306_Create_a_new_template.md)**: Create a new template *(状态: 待办 | 故事点数: 3)*
- **[LEAD-303](stories/LEAD-303_Upload_a_template_file.md)**: Upload a template file *(状态: 待办 | 故事点数: 5)*
- **[LEAD-302](stories/LEAD-302_Safe_a_draft_view_template.md)**: Safe a draft view template *(状态: 待办 | 故事点数: 1)*
- **[LEAD-301](stories/LEAD-301_Assign_a_Category.md)**: Assign a  Category *(状态: 待办 | 故事点数: 1)*
- **[LEAD-300](stories/LEAD-300_Assign_Tags.md)**: Assign Tags *(状态: 待办 | 故事点数: 1)*
- **[LEAD-299](stories/LEAD-299_Edit_Tags_and_Metadata.md)**: Edit Tags and Metadata *(状态: 待办 | 故事点数: 2)*
- **[LEAD-298](stories/LEAD-298_Edit_a_Template.md)**: Edit a Template *(状态: 待办 | 故事点数: 3)*
- **[LEAD-297](stories/LEAD-297_Duplicate_a_template.md)**: Duplicate a template *(状态: 待办 | 故事点数: 2)*
- **[LEAD-296](stories/LEAD-296_Delete_Archive_a_template.md)**: Delete & Archive a template *(状态: 待办 | 故事点数: 5)*
- **[LEAD-295](stories/LEAD-295_Access_to_template_actions.md)**: Access to template actions *(状态: 待办 | 故事点数: 1)*
- **[LEAD-294](stories/LEAD-294_Edit_Category.md)**: Edit Category *(状态: 待办 | 故事点数: 3)*
- **[LEAD-293](stories/LEAD-293_Create_a_category.md)**: Create a category *(状态: 待办 | 故事点数: 3)*
- **[LEAD-280](stories/LEAD-280_Template_versioning.md)**: Template versioning *(状态: 待办 | 故事点数: 8)*
- **[LEAD-279](stories/LEAD-279_Manage_Draft_Publish_Workflow.md)**: Manage Draft & Publish Workflow  *(状态: 待办 | 故事点数: 8)*
- **[LEAD-278](stories/LEAD-278_Manage_Template_Content.md)**: Manage Template Content  *(状态: 待办 | 故事点数: 3)*
- **[LEAD-277](stories/LEAD-277_Field_level_validation_rules.md)**: Field level validation rules *(状态: 待办 | 故事点数: 3)*
- **[LEAD-276](stories/LEAD-276_Reassign_Template_to_a_Different_Category.md)**: Reassign Template to a Different Category  *(状态: 待办 | 故事点数: 3)*

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
