# Story - LEAD-277: Template data model and validation framework

## 📋 Jira Metadata
| Field | Value |
| :--- | :--- |
| **Jira Key** | `LEAD-277` |
| **Type** | `故事` |
| **Status** | `Analysis` |
| **Story Points** | `none` |
| **Parent Feature/Epic** | `LEAD-93` |
| **Labels** | `none` |
| **Components** | `none` |

## 📖 Original Description
As a Content Manager,
I want to capture, manage, and validate template details and metadata,
So that templates are complete, accurate, and meet quality standards before publishing template 

Context:
This story defines the validation framework, ensuring consistency, quality, and governance across template creation and publishing.
This story covers:
* * * * Field & Data Capture
Validation Rules
Metadata & Tagging
Workflow & Status Rules





## 🎯 Acceptance Criteria (验收标准)
1.Template Data Capture (Template Details Section)
🔹 Field: Template Title
Rules
* * * * Mandatory: Yes
Data Type: String
Min Length: 5 characters
Max Length: 120 characters
Allowed Characters
* * Letters, numbers, spaces
Basic punctuation (- , . & ’)
Disallowed
* * * HTML tags
Special characters (@ # $ %)
Must be unique within the same category
Validation Logic
* Prevent duplicate titles within same category
Error Messages
* * * “Template title is required”
“Title must be between 5–120 characters”
“A template with this title already exists in the selected category”
🔹 Field: Description
Rules
* * * Mandatory:
* * Draft → No
Published → Yes
Data Type: Text Area
Max Length: 500 characters
Validation Logic
* * Soft validation (Draft)
Hard validation (Published)
Error Messages
* * “Description is required for published”
“Description cannot exceed 500 characters”
🟩 2. Template Type & Content Handling
🔹 Field: Template Type (Create vs Upload)
Rules
* * * Mandatory: Yes
Values:
* * Create Template
Upload Template
Default: Create Template
🔹 Field: Subject Line (Emailer only)
Rules
* * Mandatory: Yes (only for Emailer format)
Max Length: 120 characters
Validation Logic
* Only enforced when Format = Emailer
Error Messages
* “Subject line is required for email templates”
🔹 Field: Upload File
Rules
* Mandatory: Yes (if Upload selected)
Allowed Formats
* PDF, DOCX, HTML, TXT, Video, Audio
Constraints
* Max File Size: 10MB
Error Messages
* * * “Unsupported file format”
“File exceeds 10MB size limit”
“File upload failed. Please try again”
🟩 3. Metadata & Tagging (Classification Layer)
🔹 Field: Content Type
Rules
* Mandatory: Yes (on Submit)
Validation Logic
* Prevent parent-only selection
Error Messages
* “Please select a valid content type”
🔹 Field: Event / Trigger
Rules
* * * Mandatory: No
Multi-select: Yes
Max selections: 5
Validation Logic
* Prevent excessive tagging
Error Messages
* “You can select up to 4 triggers/events”
🔹 Field: Financial Need
Rules
* * Mandatory: No
Multi-select: Yes
🔹 Field: Lifecycle Stage
Rules
* * * Mandatory: No
Multi-select: Yes
Must align with predefined taxonomy
Validation Logic
* Only allow controlled values
🟩 4. Workflow & Status Management
🔹 Field: Status
System Controlled
Values
* * Draft
Published
Rules
* * Default = Draft
Allowed transition:
* Draft → Published
🟩 5. Editing & Versioning Rules
🔹 Editing Draft Templates
* * All fields editable
No strict validation until submit
🔹 Editing Published Templates
* Any change triggers:
* * New version creation
Audit log entry
🟩 6. Duplication Rules
🔹 Duplicate Template
Copies
* * * Title (append “(Copy)”)
Tags
Content
Resets
* Status → Draft
Validation
* New title must be unique
🟩 7. Delete & Archive Rules
🔹 Delete Template
Rules
* Soft delete or archive preferred
Restrictions
* Cannot delete templates in use (optional rule)
Error Message
* “This template cannot be deleted as it is currently in use”
🟩 8. Template Actions (Action Menu)
🔹 Action Visibility
Action
Draft
Published
Edit
✅
✅
Delete/Archive
✅
✅
🟩 9. Category Governance Rules (Critical)
🔹 Category Archive Rules
Rule 1: No Active Templates
* Cannot archive if templates exist
Rule 2: Mandatory Resolution
* Templates must be:
* * ✅ Reassigned/moved to different category
OR ✅ Archived
Rule 3: Reassignment Control
* * * Can only move to active categories
Cannot select archived categories
Status must remain unchanged
Rule 4: Template Archiving Behaviour
* * * Removed from active listings
Cannot be used
Retained for audit
🟩 10. Pre-Publish Validation (Quality Gate)
🔹 Mandatory Fields
Publishing must fail if missing:
* * * * * Template Title
Template Description
Template Type
Category (must be active)
Content must exist
🟩 11. Category Validation (Critical Rule)
✅ Required
* * * Category must exist
Category must be active
Category must not be archived
❌ Block if
* Template is linked to archived category
Error Example
* “Template cannot be published in an archived category. Reassign category.”


## 📋 Definition of Ready (DOR) Checklist
*未明确配置 DOR Checklist*

💬 *暂无评审与讨论历史评论*

