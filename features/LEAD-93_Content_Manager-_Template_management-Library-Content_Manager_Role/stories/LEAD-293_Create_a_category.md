# Story - LEAD-293: Create a category

## 📋 Jira Metadata
| Field | Value |
| :--- | :--- |
| **Jira Key** | `LEAD-293` |
| **Type** | `故事` |
| **Status** | `待办` |
| **Story Points** | `3` |
| **Parent Feature/Epic** | `LEAD-93` |
| **Labels** | `none` |
| **Components** | `none` |

## 📖 Original Description

As a Content Manager
I want to create a new Category
So that templates can be organised consistently within the Templates Library.

Categories represent the top‑level classification used to group templates in the library.
Each Category can contain one or more Subcategories.
Category creation is a governed administrative action and impacts:
* * * Template creation
Category navigation
Filtering and discovery


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
(Category names must be unique across the system.)
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



## 📋 Definition of Ready (DOR) Checklist
*未明确配置 DOR Checklist*

💬 *暂无评审与讨论历史评论*

