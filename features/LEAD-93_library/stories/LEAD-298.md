# Story - LEAD-298: Validation and rules for folders

## 📋 Jira Metadata
| Field | Value |
| :--- | :--- |
| **Jira Key** | `LEAD-298` |
| **Type** | `故事` |
| **Status** | `待办` |
| **Parent Feature/Epic** | `LEAD-93` |
| **Labels** | `none` |
| **Components** | `none` |

## 📖 Original Description
As a System
I want to enforce validation and rules across folders and templates
so that data integrity, usability, and governance are maintained.


## 🎯 Acceptance Criteria (验收标准)
* Folder names must be unique within the same hierarchy level
* System prevents saving folders with duplicate names and displays a clear validation message
* Templates must have required fields (e.g. title, content, assigned folder) before saving or publishing
* * * * System prevents saving or publishing templates with missing required fields
Missing fields are clearly highlighted with actionable validation messages
Templates must be assigned to a folder before publishing
Templates can be moved between folders without data loss
* * * System enforces valid template lifecycle states (draft → published)
Draft templates are not visible to advisers
Only authorised users can publish templates
* * Only the latest published version of a template is visible to advisers
Older versions are hidden from adviser view but retained for history


## 📋 Definition of Ready (DOR) Checklist
*未明确配置 DOR Checklist*

💬 *暂无评审与讨论历史评论*

