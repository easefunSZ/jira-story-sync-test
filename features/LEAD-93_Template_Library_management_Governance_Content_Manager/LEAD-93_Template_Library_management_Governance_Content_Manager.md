# Feature - LEAD-93:  Template Library management & Governance ( Content Manager)

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
1.Template Creation /search
Create new  email templates
Save drafts; 
Edit Drafts or published templates
Search a termplate
2. Template Metadata, Tagging & Categorisation
Create categories/subcategories
Edit or delete/archive category
Assign categories/subcategories
Apply tags/labels
Maintain structured taxonomy
3. Template Editing & Lifecycle Management
Create/ Edit templates
Re-assign template to a new category
Delete/archive templates
Manage versioning 
4. Template   Workflow
Create, edit, save Draft - Publish
Manage status 
5. Template Preview 
Preview templates before publishing
6. Template Administration & Actions
Use action menu (edit, reassign, delete)
Field rules & validations
Template Title; Template description; Template type
Metadata & tagging
Workflow and status
Versioning
Editing rules
Duplication rules
Delete/archive rules
Action menu rules 
Pre-publish
8.Migration of existing templates and data cleanup
Move existing templates into the new structured model


## 📖 Linked Stories (关联的故事需求)
- **[LEAD-328](stories/LEAD-328_Data_alignmentTemplate_Migration_to_Structured_Model.md)**: Data alignment/Template Migration to Structured Model *(状态: Analysis)*
- **[LEAD-327](stories/LEAD-327_Search_and_Filter_Templates_in_Library.md)**: Search and Filter Templates in Library *(状态: Analysis)*
- **[LEAD-326](stories/LEAD-326_Template_Preview.md)**: Template Preview  *(状态: Analysis)*
- **[LEAD-307](stories/LEAD-307_Delete_a_categorysubcategory.md)**: Delete a  category/subcategory  *(状态: Analysis)*
- **[LEAD-306](stories/LEAD-306_Create_a_new_template.md)**: Create a new template *(状态: Analysis)*
- **[LEAD-301](stories/LEAD-301_Assign_Edit_Category_subcategory.md)**: Assign & Edit Category & subcategory *(状态: Analysis)*
- **[LEAD-300](stories/LEAD-300_Select_Assign_and_Edit_Tags.md)**: Select /Assign and Edit Tags *(状态: Analysis)*
- **[LEAD-296](stories/LEAD-296_Delete_a_template.md)**: Delete a template *(状态: Analysis)*
- **[LEAD-293](stories/LEAD-293_Create_a_category_subcategories.md)**: Create a category/ subcategories  *(状态: Analysis)*
- **[LEAD-280](stories/LEAD-280_Template_versioning.md)**: Template versioning *(状态: Analysis)*
- **[LEAD-279](stories/LEAD-279_Manage_Draft_Publish_Workflow.md)**: Manage Draft & Publish Workflow  *(状态: Analysis)*
- **[LEAD-278](stories/LEAD-278_Edit_a_Published_template.md)**: Edit a Published template  *(状态: Analysis)*
- **[LEAD-277](stories/LEAD-277_Template_data_model_and_validation_framework.md)**: Template data model and validation framework *(状态: Analysis)*
- **[LEAD-276](stories/LEAD-276_Template_Reassignment_1_Category_Multiple_Subcategories.md)**: Template Reassignment (1 Category, Multiple Subcategories) *(状态: Analysis)*

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
