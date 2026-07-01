# Story - LEAD-307: Delete a  category/subcategory 

## 📋 Jira Metadata
| Field | Value |
| :--- | :--- |
| **Jira Key** | `LEAD-307` |
| **Type** | `故事` |
| **Status** | `Analysis` |
| **Story Points** | `none` |
| **Parent Feature/Epic** | `LEAD-93` |
| **Labels** | `none` |
| **Components** | `none` |

## 📖 Original Description
As a Content Manager
I want to delete a category/subategory
So that outdated or unused categories are no longer available for use.

Business Value 
Remove old or unused categories so the template library stays clean and easy to use.

User journey
Delete a Category
* * * * * * * * * The Content Manager navigates to Manage Categories.
The Content Manager selects a category.
The Content Manager clicks Delete.
The system displays a confirmation dialog.
The Content Manager confirms the deletion.
The system validates whether templates are assigned to:
* * the selected category, or
any of its subcategories.
If templates are assigned to the category or any of its subcategories:
* * * the delete action is blocked.
an error message is displayed.
the Content Manager must manually reassign, archive or delete the templates before attempting deletion again.
If no templates are assigned:
* * the selected category is marked as Deleted (soft delete).
all child subcategories are automatically marked as Deleted (cascade delete).
Deleted categories and subcategories:
* * * * * do not appear in navigation
do not appear in dropdown lists
do not appear in filters
cannot be selected
cannot be edited.
Delete a Subcategory only  ( but Category remain)
* * * * * * The Content Manager selects a subcategory.
The Content Manager clicks Delete.
The system displays a confirmation dialog.
The system validates whether templates are assigned to the selected subcategory.
If templates are assigned:
* deletion is blocked.
If no templates are assigned:
* * only the selected subcategory is marked as Deleted.
the parent category remains unchanged.
System Validation Before Deletion
Category
Before deleting a category, the system checks for templates assigned to:
* * the selected category
any of its child subcategories
If templates exist anywhere within the category hierarchy, deletion is blocked.
Subcategory
Before deleting a subcategory, the system checks for templates assigned to that subcategory.
If templates exist, deletion is blocked.
What Happens After Deletion
Category
When a category is successfully deleted:
* * * * * the category is marked as Deleted
all child subcategories are automatically marked as Deleted
deleted categories and subcategories are hidden throughout the application
they cannot be selected
they cannot be edited
Subcategory
When a subcategory is successfully deleted:
* * * only the selected subcategory is marked as Deleted
the parent category remains active
the deleted subcategory is hidden throughout the application
Data Retention
Deletion is implemented as a soft delete.
Deleted categories and subcategories remain in the database for audit purposes but are no longer available to users.
The system records:
* * * * Deleted By
Deleted Date and Time
Category/Subcategory ID
Category/Subcategory Name
There is no user-facing undo or recovery option.


## 🎯 Acceptance Criteria (验收标准)
AC1 – Delete Category
Given the Content Manager is on the Manage Categories page
When the Content Manager selects a category
And clicks Delete
Then the system displays a confirmation dialog. ( Category and all subactegories will be deleted, ARe you sure?  
AC2 – Delete Confirmation
Given the confirmation dialog is displayed
Then it clearly states that:
* * * * * deleting the category will remove it from use
all child subcategories will also be deleted
deletion cannot proceed while templates are assigned to the selected category or any of its subcategories
templates must first be manually reassignedor deleted
this action cannot be undone
AC3 – Validation Before Category Deletion
Given the Content Manager confirms deletion
When templates are assigned to:
* * the selected category, or
any of its subcategories
Then
* * * the delete action is blocked
the category and its subcategories remain unchanged
the following error message is displayed:
"This category cannot be deleted while templates are still assigned."
And
The Content Manager must manually reassign, archive or delete the templates before attempting deletion again.
AC4 – Successful Category Deletion
Given
* * the selected category has no templates assigned
none of its subcategories have templates assigned
When the Content Manager confirms deletion
Then
* * * * * * the selected category is marked as Deleted
all child subcategories are automatically marked as Deleted
the deleted category and subcategories no longer appear in:
* * * navigation
dropdown lists
filters
they cannot be selected
they cannot be edited
an audit record is created capturing:
* * the user who performed the deletion
the date and time of deletion
AC5 – Delete Subcategory
Given the Content Manager selects a subcategory
When the Content Manager clicks Delete
Then the system displays the confirmation dialog.
When the selected subcategory has one or more templates assigned
Then
* * * the delete action is blocked
the subcategory remains unchanged
the following error message is displayed:
"This subcategory cannot be deleted while templates are still assigned."
And
The Content Manager must manually reassign, archive or delete the templates before attempting deletion again.
When the selected subcategory has no templates assigned
Then
* * * * * * only the selected subcategory is marked as Deleted
the parent category remains unchanged
the deleted subcategory no longer appears in:
* * * navigation
dropdown lists
filters
it cannot be selected
it cannot be edited
an audit record is created capturing:
* * the user who performed the deletion
the date and time of deletion.



## 📋 Definition of Ready (DOR) Checklist
*未明确配置 DOR Checklist*

💬 **[View Comments & Discussions (查看评审与讨论历史)](LEAD-307_Delete_a_categorysubcategory_comments.md)**

