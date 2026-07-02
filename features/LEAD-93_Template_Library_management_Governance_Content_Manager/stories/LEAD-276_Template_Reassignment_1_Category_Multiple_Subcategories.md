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
I want to reassign an existing template to a different Category and/or Subcategories via the Edit Form
So that templates remain correctly organised when content structure changes, while enforcing the rule that a template belongs to only one Category.
Business Value
Maintaining an accurate and well-organised template library is critical for Adviser productivity. As business needs evolve, templates may need to be reclassified
Business rules
* * * * A template belongs to exactly one Category, but may belong to multiple Subcategories within that Category.
Template reassignment is performed via the Edit Form only. Drag-and-drop is reserved for directory sorting.
Changing the Category clears all previously selected Subcategories — the user must reselect.
Reassigning Category/Subcategory is a metadata change and does NOT trigger a status change (Published templates remain Published).
User Journey
* * * * * Content Manager navigates to the Templates Library.
Selects an existing template and opens the Edit Form.
Changes the Category dropdown — Subcategory selections are cleared automatically.
Selects one or more Subcategories from the new Category.
Clicks Save — the template is reassigned and the library placement is updated.


## 🎯 Acceptance Criteria (验收标准)
AC1: Reassign Category via Edit Form
Given a template exists and is assigned to Category A with one or more Subcategories
When the Content Manager opens the Edit Form and changes the Category to Category B
Then:
* * * * * The template is assigned to Category B
The assignment to Category A is removed (move, not copy)
All previously selected Subcategories (from Category A) are cleared
The Subcategory list updates to show only Subcategories belonging to Category B
The Content Manager must select at least one Subcategory from Category B before saving
AC2: Reassign Subcategories Within Same Category
Given a template is assigned to Category A with Subcategory X
When the Content Manager opens the Edit Form and changes the Subcategory selection to Subcategory Y and Subcategory Z (without changing the Category)
Then:
* * * * The template remains in Category A
The template is now assigned to Subcategory Y and Subcategory Z
Subcategory X is removed
The template appears under Subcategory Y and Subcategory Z in the library tree
AC3: Category Constraint — Single Category Only
Given a template exists
When viewing or editing the template
Then:
* * * The template must have exactly one Category assigned
The Category field is a single-select dropdown (not multi-select)
The system prevents assignment to multiple Categories
AC4: Subcategory Multi-Select Within Category
Given a template is assigned to a Category
When the Content Manager selects Subcategories
Then:
* * * The Content Manager can select one or more Subcategories
All selected Subcategories must belong to the same Category
The Subcategory list only shows options belonging to the currently selected Category
AC5: No Status Change on Reassignment
Given a template is in Published status
When the Content Manager changes the Category or Subcategories via the Edit Form
Then:
* * * The template status remains Published
The template remains visible to Advisers with the updated Category/Subcategory placement
No re-publish action is required
Rationale: Category/Subcategory reassignment is a metadata change, not a content change. Triggering a status change would cause unnecessary disruption to Adviser access.
AC6: Library Placement Update
Given a template has been reassigned to a new Category and/or Subcategories
When the changes are saved
Then:
* * * * The template appears in the Templates Library under the new Category
The template appears under each selected Subcategory within that Category
The template no longer appears under the old Category or its Subcategories
The template is not duplicated as a separate record — it is a single template displayed in multiple Subcategory views
AC7: Save Validation
Given the Content Manager is editing a template's Category/Subcategory assignment
When the Content Manager clicks Save
Then:
* * If a Category is selected but no Subcategory is selected → Save is blocked, inline validation message: "Please select at least one subcategory."
If both Category and at least one Subcategory are selected → Save proceeds successfully


## 📋 Definition of Ready (DOR) Checklist
*未明确配置 DOR Checklist*

💬 *暂无评审与讨论历史评论*

