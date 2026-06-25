# Story - LEAD-301: Assign a  Category

## 📋 Jira Metadata
| Field | Value |
| :--- | :--- |
| **Jira Key** | `LEAD-301` |
| **Type** | `故事` |
| **Status** | `待办` |
| **Story Points** | `1` |
| **Parent Feature/Epic** | `LEAD-93` |
| **Labels** | `none` |
| **Components** | `none` |

## 📖 Original Description
As a Content Manager
I want to assign a category & sub category  to a template
So that templates are correctly organised and discoverable in the Templates Library.

Templates are organised using a two‑level classification structure:
* * Category (Level 1)
Subcategory (Level 2)
Each template must be assigned to exactly one Category and one Subcategory.
Subcategories are dependent on the selected Category.


## 🎯 Acceptance Criteria (验收标准)
AC1: Category & Subcategory Selection UI
Given the Content Manager is creating or editing a template
Then:
* * * A Category dropdown is displayed
A Subcategory dropdown is displayed
The Subcategory dropdown is disabled until a Category is selected
AC2: Category–Subcategory Dependency
Given the Content Manager selects a Category
Then:
* * The Subcategory dropdown is enabled
Only Subcategories belonging to the selected Category are available
When the Category is changed
Then:
* * Any previously selected Subcategory is cleared
The user must select a new Subcategory
AC3: Save Draft Behaviour
Given the Content Manager clicks Save Draft
Then:
* * * * Category is optional
Subcategory is optional
The template can be saved without either being selected
The template status remains Draft
AC4: Submit for Review Validation
Given the Content Manager clicks Publish
When either Category or Subcategory is missing
Then:
* * Submission is blocked
Inline validation messages are displayed:
* * “Please select a category”
“Please select a subcategory”
And when both Category and Subcategory are selected
Then:
* Submission proceeds successfully
AC5: Persistence & Library Placement
Given a Category and Subcategory are selected
Then:
* * Both values are stored against the template record
The template appears in the Templates Library under:
* * The selected Category
The selected Subcategory
AC6: Editing Category or Subcategory on Draft Templates
Given a template is in Draft status
When the Content Manager changes the Category or Subcategory
Then:
* * The changes are saved immediately
The template’s library placement updates accordingly
AC7: Editing Category or Subcategory on Approved Templates
Given a template is in Published status
When the Content Manager changes either the Category or Subcategory
Then:
* The template status changes to In Review
AC8: Permissions & Visibility
* * Only Content Managers can assign or change Category and Subcategory
Advisers:
* * Can view Category and Subcategory
Cannot edit them
AC9: Error Handling
* If categories or subcategories fail to load:
* * * An error message is displayed
Save Draft remains available
Submit for Review is disabled



## 📋 Definition of Ready (DOR) Checklist
*未明确配置 DOR Checklist*

💬 **[View Comments & Discussions (查看评审与讨论历史)](LEAD-301_Assign_a_Category_comments.md)**

