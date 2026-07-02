# Story - LEAD-301: Assign & Edit Category & subcategory

## 📋 Jira Metadata
| Field | Value |
| :--- | :--- |
| **Jira Key** | `LEAD-301` |
| **Type** | `故事` |
| **Status** | `Analysis` |
| **Story Points** | `none` |
| **Parent Feature/Epic** | `LEAD-93` |
| **Labels** | `none` |
| **Components** | `none` |

## 📖 Original Description
As a Content Manager
I want to assign a category and one or more subcategories to a template so that templates are correctly organised and discoverable in the Templates Library.

Business value
Make sure templates are correctly organised so they are easy to find and use.

User journey
The Content Manager goes to Templates Library.
Selects a new or existing template.
Opens the template for editing.
Selects:
* * A Category
One or more Subcategories belonging to the selected Category
Saves the template as a Draft or Publishes it.
The system links the template to the selected Category and all selected Subcategories.
The template appears in the correct place in:
* * * Category navigation
Each selected Subcategory
Search results


## 🎯 Acceptance Criteria (验收标准)
AC1: Category & Subcategory Selection UI
Given the Content Manager is creating or editing a template
Then:
* * * * A Category dropdown is displayed.
A Subcategory multi-select list is displayed.
The Subcategory list is disabled until a Category is selected.
The Content Manager can select one or more Subcategories belonging to the selected Category.
AC2: Category–Subcategory Dependency
Given the Content Manager selects a Category
Then:
* * * The Subcategory list is enabled.
Only Subcategories belonging to the selected Category are available.
The Content Manager can select one or more Subcategories.
When the Category is changed
Then:
* * Any previously selected Subcategories are cleared.
The user must select one or more Subcategories from the newly selected Category.
AC3: Save Draft Behaviour
Given the Content Manager clicks Save Draft
Then:
* * * * Category is optional.
Subcategory selection is optional.
The template can be saved without either being selected.
The template status remains Draft.
AC4: Drag-and-Drop Ordering for Categories and Subcategories
Given the Content Manager is on the Template Library management page,
When the user drags a Category or Subcategory to a new position,
Then:
* * * * * Categories can be reordered among other Categories via drag-and-drop
Subcategories can be reordered within the same parent Category via drag-and-drop
Subcategories cannot be dragged to a different Category
Templates cannot be dragged — only Categories and Subcategories support drag-and-drop
The new display order is saved immediately and reflected in the Template Library for all users (including Advisers)
AC5: Persistence & Library Placement
Given a Category and one or more Subcategories are selected
Then:
* * * The selected Category is stored against the template.
All selected Subcategories are stored against the template.
The template appears in the Templates Library under:
* * The selected Category.
Each selected Subcategory.
AC6: Editing Category or Subcategory on Draft Templates
Given a template is in Draft status
When the Content Manager changes the Category or selected Subcategories
Then:
* * The changes are saved immediately.
The template's placement in the Templates Library is updated accordingly.
AC7: Editing Category or Subcategory on Published Templates
Given a template is in Published status
When the Content Manager changes the Category or selected Subcategories
Then the template status changes to Draft


## 📋 Definition of Ready (DOR) Checklist
*未明确配置 DOR Checklist*

💬 **[View Comments & Discussions (查看评审与讨论历史)](LEAD-301_Assign_Edit_Category_subcategory_comments.md)**

