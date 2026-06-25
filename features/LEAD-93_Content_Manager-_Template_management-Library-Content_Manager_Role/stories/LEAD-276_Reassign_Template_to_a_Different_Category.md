# Story - LEAD-276: Reassign Template to a Different Category 

## 📋 Jira Metadata
| Field | Value |
| :--- | :--- |
| **Jira Key** | `LEAD-276` |
| **Type** | `故事` |
| **Status** | `待办` |
| **Story Points** | `3` |
| **Parent Feature/Epic** | `LEAD-93` |
| **Labels** | `none` |
| **Components** | `none` |

## 📖 Original Description
As a Content Manager
I want to reassign an existing template to a different category and/or subcategory
So that templates remain correctly organised when content structure changes.


## 🎯 Acceptance Criteria (验收标准)
AC1: Access Reassign Category/Subcategory
Given the Content Manager has permission to manage templates
And the Content Manager opens an existing template (any status)
Then the Category and Subcategory fields are available for editing
AC2: Category and Subcategory Selection Rules
Given the Category field is edited
Then:
* * Subcategory options are filtered based on the selected Category
Only one Category and one Subcategory may be selected
When the Category is changed
Then:
* * The previously selected Subcategory is cleared
A new Subcategory must be selected
AC3: Save Draft Behaviour
Given the template is in Draft status
When the Content Manager reassigns the Category or Subcategory and clicks Save Draft
Then:
* * * The changes are saved
The template remains in Draft status
The template’s position in the library updates accordingly
AC4: Reassignment on Approved Templates
Given the template is in Published status
When the Content Manager changes the Category or Subcategory
Then:
* * The template status changes to Draft
The previously approved version remains visible to Advisers until republish new versioning applies)
AC5: Submit Reassigned Template for Review
Given the Content Manager has changed the Category or Subcategory
And all required fields are completed
When the Content Manager clicks Save
Then:
* * The reassigned Category and Subcategory are validated
The template enters Publsihed state
AC6: Validation Rules
* * Category and Subcategory:
* * Are optional for Save Draft
Are mandatory for save for Published
Subcategory must always belong to the selected Category
AC7: Visibility & Permissions
* * Only Content Managers  can reassign Category or Subcategory
Advisers:
* * Can view the assigned Category and Subcategory
Cannot modify them
AC8: Audit & History
When a template is reassigned:
* * Previous Category and Subcategory are stored for audit
Date and user who made the change are captured
AC9: Error Handling
* If categories or subcategories fail to load:
* Save Draft remains available


## 📋 Definition of Ready (DOR) Checklist
*未明确配置 DOR Checklist*

💬 *暂无评审与讨论历史评论*

