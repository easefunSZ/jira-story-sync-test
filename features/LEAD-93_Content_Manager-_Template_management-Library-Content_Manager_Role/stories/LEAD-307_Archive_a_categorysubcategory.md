# Story - LEAD-307: Archive a category/subcategory

## 📋 Jira Metadata
| Field | Value |
| :--- | :--- |
| **Jira Key** | `LEAD-307` |
| **Type** | `故事` |
| **Status** | `待办` |
| **Story Points** | `5` |
| **Parent Feature/Epic** | `LEAD-93` |
| **Labels** | `none` |
| **Components** | `none` |

## 📖 Original Description
As a Content Manager
I want to archive a category
So that outdated or unused categories are no longer available for use.
When a Category is archived:
* * *  All Subcategories under that Category are automatically archived
 Archived Subcategories:
* * Are no longer selectable
Do not appear in navigation or filters
 The Category and Subcategories:
* * Remain in the system for audit/history
Cannot be edited once archived
* * Category cannot be archived if:
* Any template is still assigned to its subcategories
Content Manager must:
* * Reassign templates to another Category/Subcategory
OR delete/archive the templates


## 🎯 Acceptance Criteria (验收标准)
AC1: Access Archive Category
Given the Content Manager is in Manage Categories
When the Content Manager selects a category
And clicks Archive
Then the system displays a confirmation dialogAdd Acceptance Criteria
AC2: Archive Confirmation
Given the confirmation dialog is displayed
Then the dialog clearly states:
* * Archiving will remove the category from use
Existing templates must be reassigned first
AC3: Validation Before Archive
Given the Content Manager confirms archive
When the category:
*  has templates assigned
Then:
* * Archiving is blocked
An error message is displayed:
“This category cannot be archived while templates are still assigned.”
Archiving a Category automatically archives all its Subcategories
AC4: Successful Archive
Given the category has:
* * No subcategories
No templates assigned
When the Content Manager confirms archive
Then:
* * The category status is set to Archived
The category:
* * Is removed from navigation
Is no longer selectable during template creation
AC5: Historical Integrity
* Archived categories:
* * * Are retained for audit/history
Are not editable
Are not selectable


## 📋 Definition of Ready (DOR) Checklist
*未明确配置 DOR Checklist*

💬 *暂无评审与讨论历史评论*

