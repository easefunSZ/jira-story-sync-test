# Story - LEAD-306: Create a new template

## 📋 Jira Metadata
| Field | Value |
| :--- | :--- |
| **Jira Key** | `LEAD-306` |
| **Type** | `故事` |
| **Status** | `待办` |
| **Story Points** | `3` |
| **Parent Feature/Epic** | `LEAD-93` |
| **Labels** | `none` |
| **Components** | `none` |

## 📖 Original Description
As a Content Manager
I want to create a new template from scratch via a dedicated creation screen
So that I can produce structured, governed content for advisers.

The Content Manager initiates template creation from the Templates Library using the “+ New Template” action.
The system must support draft creation, full-page editing, and submission into a Publshed state
Flow - Create → Save Draft → Complete fields → Submit → Status = Published


## 🎯 Acceptance Criteria (验收标准)
AC1: Open Creation Screen
Given the Content Manager is on the Templates Library page
When the Content Manager clicks “+ New Template”
Then the system navigates to a full-page “Create Template” screen
And the screen has its own URL (deep-linkable)
And if the user attempts to leave the screen with unsaved changes, a confirmation dialog is displayed
AC2: Capture Template Details
Given the Create Template screen is open
When the Content Manager enters the following fields:
* * * Title (plain text, max 120 characters)
Description (plain text, max 500 characters)
Format (one of: Emailer, Campaign, Toolkit, Infographic)
Then the system captures and retains the inputs
And format selection dynamically controls which content fields are displayed
And changing the format clears incompatible content with user confirmation
AC3: Save Draft Template
Given the Content Manager has entered partial or complete information
When the Content Manager clicks Save Draft
Then the system creates the template record in the database
And assigns a unique template ID
And the draft template becomes visible in the Templates Library to Content Managers
AC5: Required Field Rules
* Save Draft
* * Allows partial completion
Bypasses mandatory field validation
AC6: Visibility & Permissions
* * * Draft and In Review templates:
* Visible to Content Managers only
published templates:
* Visible to Advisers
Only users with Content Manager permissions can access the Create Template screen

Default behaviour on creation:
* * * First Save → Template created
Status = Draft
Visible to Content Managers only


## 📋 Definition of Ready (DOR) Checklist
*未明确配置 DOR Checklist*

💬 *暂无评审与讨论历史评论*

