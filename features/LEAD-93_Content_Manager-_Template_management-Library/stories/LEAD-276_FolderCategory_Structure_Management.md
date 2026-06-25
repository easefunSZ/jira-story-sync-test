# Story - LEAD-276: Folder/Category  Structure Management

## 📋 Jira Metadata
| Field | Value |
| :--- | :--- |
| **Jira Key** | `LEAD-276` |
| **Type** | `故事` |
| **Status** | `待办` |
| **Parent Feature/Epic** | `LEAD-93` |
| **Labels** | `none` |
| **Components** | `none` |

## 📖 Original Description
As a Content Manager, I want to create, rename, reorder, and delete folder categories in the template library, 
so that templates are organised by business meaning (e.g. Rewards, Missed Premiums, Retirement, Retrenchment) rather than relying on inconsistent naming conventions.
Background:
Templates are currently managed through poorly structured naming conventions, making it difficult for advisers to understand the purpose of a template or locate the correct content. A structured categorisation model is needed to organise templates by business context, enabling intuitive navigation and accurate template selection. This story establishes the foundational folder structure upon which all other template library capabilities depend.


## 🎯 Acceptance Criteria (验收标准)
* * * * * * * * Content Manager can create a new folder category with a unique name
Content Manager can rename an existing folder
Content Manager can reorder folders via drag-and-drop or manual sort order
Content Manager can delete an empty folder; system prevents deletion of folders that still contain templates with a warning message
Folder hierarchy supports at least two levels (e.g. Category > Sub-category)
Folder names must be unique within the same hierarchy level; system displays a validation error if a duplicate name is entered
Changes to folder structure take effect immediately and are reflected in the adviser-facing template library
The folder structure is designed to be scalable, supporting future content formats such as video and audio templates


## 📋 Definition of Ready (DOR) Checklist
*未明确配置 DOR Checklist*

💬 *暂无评审与讨论历史评论*

