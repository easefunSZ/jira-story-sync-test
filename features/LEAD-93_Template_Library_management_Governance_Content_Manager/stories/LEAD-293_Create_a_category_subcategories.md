# Story - LEAD-293: Create a category/ subcategories 

## 📋 Jira Metadata
| Field | Value |
| :--- | :--- |
| **Jira Key** | `LEAD-293` |
| **Type** | `故事` |
| **Status** | `Analysis` |
| **Story Points** | `none` |
| **Parent Feature/Epic** | `LEAD-93` |
| **Labels** | `none` |
| **Components** | `none` |

## 📖 Original Description

As a Content Manager,
I want to create categories and sub-categories,
So that templates are organised in a clear and structured way, making them easy to find and use.
*( see attached  list of Categories and subcategories )
Business Goal 
Create a clear category structure that helps Content Managers to group templates in a logical way, makes them easy to find, and allows the library to grow without becoming messy.
* * *  Move from a flat list → to a structured category system
 Make navigation simple and clear
 Reduce reliance on template names
User journey 
* * * * * * * The Content Manager goes to Manage Categories
Clicks Create Category
Enters:
* * Category name
Description (optional)
(Optional) selects a parent category to create a sub-category
Clicks Save
The system checks rules (name, duplicates)
If valid:
* * * Category is created
It appears in the category list
It can be used immediately
Category = Dropdown (single-select)
✅ Subcategory = Multi-select (NOT a simple dropdown — use multi-select or checkboxes)
See Catgeory and subactegory list attched,


## 🎯 Acceptance Criteria (验收标准)
AC1: Access Create Category Function
Given the Content Manager has appropriate permissions
When the Content Manager selects “Manage Categories”
And clicks “Create Category”
Then the system displays a Category creation form
AC2: Category Details Capture
Given the Create Category form is displayed
When the Content Manager enters:
* * Category Name (plain text)
Description (optional)
Then the system captures the inputs
Rules:
* * * Category Name is mandatory
Maximum length: 100 characters
Plain text only
AC3: Category Name Validation
Given the Content Manager attempts to save
When:
* * Category Name is empty
OR Category Name already exists
Then:
* * The system prevents saving
An inline validation message is displayed:
* * “Category name is required”
“A category with this name already exists”
Category names must be unique across the system - no duplicate names of categories
AC4: Save Category
Given all validation rules are met
When the Content Manager clicks Save
Then:
* * The Category is created and stored
It becomes immediately available:
* * In the Category dropdown
In Category navigation
AC5: Default Status & Visibility
* Newly created Categories:
* * * Are active by default
Are visible to all Content Managers
Are selectable for new templates immediately
AC6: Error Handling
* If category creation fails:
* * * An error message is displayed
The Content Manager remains on the Create Category screen
No partial data is saved
AC7: Permissions & Governance
* * Only users with Content Manager  permissions can create Categories
Advisers:
* * Can view Categories
Cannot create or edit Categories
AC8: Audit & Metadata
When a category is created:
* * Created date is stored
Created by user is stored

AC 9:  Hierachy/structure 
* * * * * Categories   represent the top‑level classification used to group templates in the library.
Each Category  can contain one or more Subcategories.
Sub -categories cannot have a child record
A template can belong to many categories or sub-categories
Categories (Name; Description;Parent category) can be edited/renamed and archived. If archived, then user must have selection to archive all or move templates to another category
Existing templates need to be assigned to Categories/subcategories (automated mapping)




## 📋 Definition of Ready (DOR) Checklist
*未明确配置 DOR Checklist*

💬 **[View Comments & Discussions (查看评审与讨论历史)](LEAD-293_Create_a_category_subcategories_comments.md)**

