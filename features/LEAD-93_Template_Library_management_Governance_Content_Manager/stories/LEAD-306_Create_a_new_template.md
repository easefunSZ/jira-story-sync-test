# Story - LEAD-306: Create a new template

## 📋 Jira Metadata
| Field | Value |
| :--- | :--- |
| **Jira Key** | `LEAD-306` |
| **Type** | `故事` |
| **Status** | `Analysis` |
| **Story Points** | `none` |
| **Parent Feature/Epic** | `LEAD-93` |
| **Labels** | `none` |
| **Components** | `none` |

## 📖 Original Description
As a Content Manager
I want to create a new template from scratch via a dedicated creation screen
So that I can produce structured, governed content for advisers.
Business value 
To make sure all templates are created  by the Content Manager in a consistent, structured way and go through a controlled process before being published for advisers.

User journey 
* * The Content Manager goes to the Templates Library
Clicks “+ New Template”
 Open Creation Screen
* * * The system opens the Create Template screen (full page)
The screen has its own URL
If the user tries to leave without saving, the system shows a warning message
 Enter Template Details
* The Content Manager enters:
* * * * * * Title
Description
Selects a Format (Emailer, Campaign)
Category
Subcategory
Adds Tags
* The system:
* * Saves the entered data
Shows fields based on selected format
Save Draft
* * The Content Manager clicks Save Draft
The system:
* * * Creates the template
Assigns a unique template ID
Saves it with Status = Draft
* The draft:
* * Appears in the Templates Library
Is visible only to Content Managers
Complete & Publish
* * * * The Content Manager continues editing the template
Completes all required fields
Submits the template
The system:
* * Validates required fields
Updates status to Published
Final Outcome
* The published template:
* * Becomes visible to Advisers
Can now be used

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
* * * * Title (plain text, max 120 characters)
Description (plain text, max 500 characters)
Format (select : Emailer, Campaign)
Tags (Content Type, Trigger; Financial Need, Lifecycle stage)
Then the system captures and retains the inputs
And format selection dynamically controls which content fields are displayed
And changing the format clears incompatible content with user confirmation
AC3: Save Draft Template
Given the Content Manager has entered partial or complete information
When the Content Manager clicks Save Draft
Then the system creates the template record in the database
And assigns a unique template ID
And the draft template becomes visible in the Templates Library to Content Managers
AC4: Publish Template with Validation
Given the Content Manager is editing a Draft template and all content is complete
When the Content Manager clicks "Publish"
Then the system performs a pre-publish validation check on the following required fields:
* * * * * * * Title (not empty, max 120 characters)
Description (not empty, max 500 characters)
Format (must be selected)
Category (must be assigned)
Subcategory (must be assigned)
At least one Tag assigned
Template content body is not empty
If all required fields pass validation
Then:
* * * * The system updates the template status from Draft → Published
The template becomes visible to Advisers
A new version entry is created in the version history
A success message is displayed: "Template [Title] has been published successfully"
If one or more required fields fail validation
Then:
* * * * * The system blocks the publish action
The system highlights each failed field with an inline error message (e.g., "Title is required", "Category must be assigned")
A summary banner is displayed at the top: "X field(s) must be completed before publishing"
The template remains in Draft status
No version entry is created
When the Content Manager clicks "Edit" on a Published template
Then:
* * * The system creates a working copy with status = Draft
The previously published version remains visible to Advisers until the new Draft is re-published
The Content Manager can modify content and re-publish following the same validation rules above
AC5: Required Field Rules
* Save Draft
* * Allows partial completion
Bypasses mandatory field validation
AC6: Visibility & Permissions
* * * Draft atemplates:
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

