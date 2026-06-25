# Story - LEAD-302: Safe a draft view template

## 📋 Jira Metadata
| Field | Value |
| :--- | :--- |
| **Jira Key** | `LEAD-302` |
| **Type** | `故事` |
| **Status** | `待办` |
| **Story Points** | `1` |
| **Parent Feature/Epic** | `LEAD-93` |
| **Labels** | `none` |
| **Components** | `none` |

## 📖 Original Description
As a Content Manager
I want to save a template as a draft at any point during creation or editing
So that I can return later to complete or refine it without losing work.


## 🎯 Acceptance Criteria (验收标准)
AC1: Save Draft Action
Given the Content Manager is creating or editing a template
When the Content Manager clicks “Save Draft”
Then the system saves the current state of the template
And the user remains on the Create/Edit Template screen
And a success confirmation message is displayed
AC2: Validation Rules for Save Draft
Given the Content Manager clicks Save Draft
Then the system applies basic technical validation only, including:
* * Field type validation
Maximum length constraints
And the system does not enforce:
* * * Mandatory business fields
Category selection
File upload requirements
And Save Draft is allowed even if required fields for submission are missing.
AC3: Draft Persistence & Status
Given Save Draft is successful
Then:
* * * * A template record is created (if it does not already exist)
A unique template ID is generated
The template status is set to Draft
Created date and last saved date are stored
AC4: Visibility of Draft Templates
* * Draft templates are visible to:
* * Content Managers
Draft templates are not visible to Advisers
Draft status is clearly indicated on the template card in the Templates Library
AC5: Resume Editing Draft Template
Given a template is in Draft status
When the Content Manager reopens the template from the Templates Library
Then the system restores all previously saved data, including:
* * * * * Template details (title, description)
Selected format
Metadata and tags
Uploaded file (if applicable)
Content entered in editors
And the template opens in editable mode.
AC6: Editing Behaviour for Drafts
* * Draft templates can be edited without restriction
Multiple saves overwrite the existing draft state
AC7: Error Handling
* * If Save Draft fails:
* * * An error message is displayed
The user remains on the current screen
No data loss occurs
If the user attempts to navigate away with unsaved changes:
* A confirmation dialog is displayed


## 📋 Definition of Ready (DOR) Checklist
*未明确配置 DOR Checklist*

💬 *暂无评审与讨论历史评论*

