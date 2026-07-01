# Story - LEAD-276: Template Reassignment (1 Category, Multiple Subcategories)

## 📋 Jira Metadata
| Field | Value |
| :--- | :--- |
| **Jira Key** | `LEAD-276` |
| **Type** | `故事` |
| **Status** | `Analysis` |
| **Story Points** | `none` |
| **Parent Feature/Epic** | `LEAD-93` |
| **Labels** | `none` |
| **Components** | `none` |

## 📖 Original Description
As a Content Manager
I want to reassign an existing template to a different category and/or one or more subcategories via drag-and-drop or manual selection
So that templates remain correctly organised when content structure changes while enforcing the rule that a template belongs to only one category.
Business Value
Maintaining an accurate and well-organised template library is critical for Adviser productivity. As business needs evolve, templates may need to be reclassified
Business rules
A template belongs to only one category, but may belong to multiple subcategories within that category.
Drag-and-drop should perform a move (not copy) operation and trigger a confirmation or subcategory selection step.
When a template is dragged to a different Category:
* * * *  The template is moved (not copied)
 Its previous Category is replaced
 All existing subcategories are cleared
 User must reselect subcategories for the new Category
A template should appear only once in the tree (under its Category), but can appear in multiple Subcategories within that Category.

Update UX -g iven a user drags a template to a new Category
When the drop is completed; Then the system prompts the user to select subcategories before finalising

b) drag & drop to another category


## 🎯 Acceptance Criteria (验收标准)
1. Reassign Template via Drag-and-Drop (Move Only)
Wven a template exists in Category A with one or more subcategories
When the user drags and drops the template into Category B
Then the template is moved to Category B
And it is removed from Category A
And all existing subcategories are cleared

* Subcategory Reselection Required After Category Change
Gven a template has been moved to a new Category
When the reassignment completes
Then the system requires the user to select one or more subcategories from the new Category
And only subcategories belonging to the selected Category are available

* Manual Reassignment via Edit Form
* * * * *  Given a template exists
When the user updates the Category via the edit form
Then the template is assigned to the selected Category
And all previously assigned subcategories are cleared
And the user can select multiple subcategories from the selected Category

* Category Constraint Enforcement
* * * * given a template exists
When viewing or editing the template
Then the template must have exactly one Category assigned
And the system prevents assignment to multiple Categories
* Multiple Ctageory assignamnet
* * * iven a template belongs to a Category
When the user selects subcategories
Then the user can select one or more subcategories
And all selected subcategories must belong to the same Category

* Status Change on Reassignment
* * * * Given ven a template is in Published status
When the Category or Subcategory is changed
Then the template status changes to Draft
And the previously published version remains visible to Advisers
*  Folder tree rendering
* * * * * Given a template is assigned to a single Category and multiple Subcategories
When the template library tree is displayed
Then the template appears under each assigned subcategory within that Category
And the template does not appear under any other Categories
And the template is not duplicated as separate records

* * 10.Version History Update``
iven a template is reassigned
When the change is saved
Then a new version entry is created
And the version history reflects the updated Category and Subcategories

* Audit logging
Given a template reassignment occurs
When the change is completed
Then the system logs:
* * * * * * previous Category
new Category
previous Subcategories
new Subcategories
user who made the change
timestamp




## 📋 Definition of Ready (DOR) Checklist
*未明确配置 DOR Checklist*

💬 *暂无评审与讨论历史评论*

