# Story - LEAD-326: Template Preview 

## 📋 Jira Metadata
| Field | Value |
| :--- | :--- |
| **Jira Key** | `LEAD-326` |
| **Type** | `故事` |
| **Status** | `Analysis` |
| **Story Points** | `none` |
| **Parent Feature/Epic** | `LEAD-93` |
| **Labels** | `none` |
| **Components** | `none` |

## 📖 Original Description
As a Content Manager
I want to preview a template's final appearance and validate its content before publishing
So that I can ensure the template meets quality standards and displays correctly to advisers before it goes live.

Buiness Value:
Ensure templates are correct, complete, and display properly before they are published, so advisers always receive high-quality and reliable content.
User journey
The Content Manager must be able to preview how a template will appear to advisers before transitioning it to Published status.
The system must perform pre-publish validation to ensure all required fields are completed and content meets formatting standards.
Flow: Select Template → Preview → System Validates → Show Validation Results → Confirm or Return to Edit

* * The Content Manager goes to the Templates Library
Selects a template with status Draft
 Open Preview
* * The Content Manager clicks Preview (from detail page or action menu)
The system opens the Preview screen
* * The preview is read-only
A “Back to Edit” button is available
 View Template
* The system shows the template exactly as advisers will see it:
* * * Layout and formatting
Images and videos
File content (PDF, text)
* The Content Manager checks:
* * * Content is correct
Layout looks right
Media displays properly
 Run Validation
* When the Content Manager prepares to publish, the system checks:
* * * * All required fields are completed
At least one tag is added
A valid template file is uploaded
A category is assigned
 If Validation Fails
* The system:
* * * Shows clear error messages
Highlights what is missing or incorrect
Blocks publishing
* The Content Manager:
* * Clicks Back to Edit
Fixes the issues
 If Validation Passes
* * The system confirms that everything is valid
The Content Manager can:
* * * Proceed to Publish
OR go back to edit if needed
 Final Outcome
* The template is:
* * * Verified for quality
Displayed correctly
Ready to be published for advisers


## 🎯 Acceptance Criteria (验收标准)
* * * * * * * * * * * The CM can preview any template in Draft  from the template detail page or the Action Menu.
The preview must render the template exactly as it will appear to advisers, including formatting,  and layout.
Supported file types must render correctly in preview:
* * * .pdf — embedded PDF viewer
.txt — formatted text display
Unsupported file types must not render and must display an appropriate error message.
Before publishing, the system must automatically validate:
* * * * All mandatory fields are completed (Title, Description, Type)
At least one tag per mandatory group (Content Type, Trigger Event, Lifecycle Stage, Financial Need)
Template file is uploaded and not corrupted
Template category is assigned
If validation fails, the system must display specific error messages indicating which fields or rules are not met, and block publishing until all errors are resolved.
Validation is triggered when the user initiates the Publish action from preview or edit mode.
If validation passes, the CM can proceed to publish or return to editing.
The preview must be read-only — no editing is allowed in preview mode.
A "Back to Edit" button must be available to return to the editing screen from preview.
Returning to edit must retain all previously entered data.
On successful publish, template status changes from Draft to Published


## 📋 Definition of Ready (DOR) Checklist
*未明确配置 DOR Checklist*

💬 *暂无评审与讨论历史评论*

