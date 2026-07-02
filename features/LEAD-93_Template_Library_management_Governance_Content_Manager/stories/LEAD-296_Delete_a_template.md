# Story - LEAD-296: Delete a template

## 📋 Jira Metadata
| Field | Value |
| :--- | :--- |
| **Jira Key** | `LEAD-296` |
| **Type** | `故事` |
| **Status** | `Analysis` |
| **Story Points** | `none` |
| **Parent Feature/Epic** | `LEAD-93` |
| **Labels** | `none` |
| **Components** | `none` |

## 📖 Original Description
As a Content Manager, I want to delete a template that is in Draft status, so that outdated or unnecessary content is permanently removed and not used by advisors.
Preconditions
* * * The user is logged in as a Content Manager with appropriate permissions.
The template to be deleted must be in Draft status.
Templates in Published status cannot be deleted directly — they must first be deactivated back to Draft status before deletion is allowed.
Business Rules
Rule
Description
Draft-only deletion
Only templates in Draft status can be deleted. The delete action must not be available or executable for templates in Published status.
Published → Draft before deletion
If a Content Manager wants to delete a Published template, they must first deactivate it (transition it back to Draft status), and then perform the delete operation.
Delete entry point
The delete action is accessible from the template detail page only. The user navigates from the Draft template listing into the detail page, where a Delete button is available.
All versions deleted
When a template is deleted, all versions of that template are permanently removed.
Confirmation required
A confirmation dialog must be displayed before the delete action is executed to prevent accidental deletion.
Out of Scope
* * * Bulk/Batch Deletion — The current system does not support selecting and deleting multiple templates at once. Deletion is a single-template operation from the detail page only.
Direct deletion of Published templates — Published templates must be deactivated to Draft first.
Soft delete / Recycle bin — Deletion is permanent. There is no undo or recovery mechanism in the current scope.


## 🎯 Acceptance Criteria (验收标准)
AC1: Delete Button Visibility — Draft Status Only
Given I am a Content Manager viewing the template listing page
And a template is in "Draft" status
When I click on the template to navigate to its detail page
Then I should see a "Delete" button on the detail page
AC2: Delete Confirmation Dialog
Given I am on the detail page of a "Draft" template
When I click the "Delete" button
Then a confirmation dialog is displayed with the message:”Are you sure you want to delete the template: test PFA DFA template? Please note all the versions will be deleted.”  And the dialog displays two action buttons: "Cancel" and "Delete"
AC3: Confirm Deletion — Template Removed
Given the delete confirmation dialog is displayed
When I click the "Delete" button on the dialog
Then the template and all its versions are permanently deleted
And I am redirected back to the template listing page
And the deleted template no longer appears in the listing
And a success notification is displayed (e.g., "Template deleted successfully")
AC4: Cancel Deletion
Given the delete confirmation dialog is displayed
When I click the "Cancel" button
Then the dialog is closed
And the template remains unchanged
And I stay on the template detail page


## 📋 Definition of Ready (DOR) Checklist
*未明确配置 DOR Checklist*

💬 **[View Comments & Discussions (查看评审与讨论历史)](LEAD-296_Delete_a_template_comments.md)**

