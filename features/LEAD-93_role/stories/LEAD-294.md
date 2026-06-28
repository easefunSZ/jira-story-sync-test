# Story - LEAD-294: Edit Category

## 📋 Jira Metadata
| Field | Value |
| :--- | :--- |
| **Jira Key** | `LEAD-294` |
| **Type** | `故事` |
| **Status** | `待办` |
| **Story Points** | `3` |
| **Parent Feature/Epic** | `LEAD-93` |
| **Labels** | `none` |
| **Components** | `none` |

## 📖 Original Description
As a Content Manager
I want to edit an existing category
So that category information remains accurate and aligned to the content strategy.


## 🎯 Acceptance Criteria (验收标准)

AC1: Access Edit Category
Given the Content Manager has permission to manage categories
When the Content Manager selects Manage Categories
And chooses an existing category
And clicks Edit
Then the system displays the Edit Category screen pre‑populated with current values
AC2: Editable Fields
Given the Edit Category screen is open
Then the Content Manager can edit:
* * Category Name
Description
Rules:
* * * Category Name is mandatory
Max length: 100 characters
Plain text only
AC3: Category Name Validation
Given the Content Manager attempts to save changes
When:
* * Category Name is empty
OR Category Name duplicates another existing category
Then:
* * Saving is blocked
Inline validation messages are displayed
AC4: Save Edited Category
Given all validation rules are met
When the Content Manager clicks Save
Then:
* * * The category is updated
Changes are immediately reflected:
* * In category navigation
In category dropdowns
Existing templates remain linked to the category
AC5: Impact on Existing Templates
* Editing a Category name:
* * Does not change template status
Templates automatically display the updated category name
AC6: Audit & Metadata
When a category is edited:
* * Last updated date is stored
Updated by user is stored
AC7: Permissions
* * Only Content Managers  can edit categories
Advisers can view categories but cannot edit them


## 📋 Definition of Ready (DOR) Checklist
*未明确配置 DOR Checklist*

💬 *暂无评审与讨论历史评论*

