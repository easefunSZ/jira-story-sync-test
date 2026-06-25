# Story - LEAD-277: Field level validation rules

## 📋 Jira Metadata
| Field | Value |
| :--- | :--- |
| **Jira Key** | `LEAD-277` |
| **Type** | `故事` |
| **Status** | `待办` |
| **Story Points** | `3` |
| **Parent Feature/Epic** | `LEAD-93` |
| **Labels** | `none` |
| **Components** | `none` |

## 📖 Original Description
1.TEMPLATE DETAILS SECTION
 Field: Template Title
Rules
* * * * * * * Mandatory:  Yes
Data Type: String
Min Length: 5 characters
Max Length: 120 characters
Allowed Characters:
* * Letters, numbers, spaces
Basic punctuation (- , . & ’)
Disallowed:
* * HTML tags
Special characters (@ # $ % etc., except allowed)
Must be unique within the same category
Validation Logic
* Prevent duplicate titles within same category
Error Messages
* * * “Template title is required”
“Title must be between 5–120 characters”
“A template with this title already exists in the selected category”
Field: Description
Rules
* * * * Mandatory: No (Draft), Yes (Published)
Data Type: Text Area
Max Length: 500 characters

Validation Logic
* * Soft validation (allowed empty in draft)
Hard validation on Published
Error Messages
* * “Description is required for published”
“Description cannot exceed 500 characters”

* TEMPLATE TYPE & CONTENT
Field: Template Type (Create vs Upload)
Rules
* * * Mandatory:  Yes
Values:
* * Create Template
Upload Template
Default: Create Template
Field: Subject Line (Emailer only)
Rules
* * Mandatory:  Yes (Emailer format only)
Max Length: 120 characters
Validation Logic
* Only enforced if Format = Emailer
Error Messages
* “Subject line is required for email templates”
Field: Upload File
Rules
* * * Mandatory:  Yes if Upload selected
Allowed Formats:
* * * * * * PDF
DOCX
HTML
TXT
Video file
Sound file
Max File Size: 10MB
Error Messages
* * * “Unsupported file format”
“File exceeds 10MB size limit”
“File upload failed. Please try again”

* METADATA & TAGGING (RIGHT PANEL)  - CATEGORIES to be confirmed with business
Field: Category
Rules
* * Mandatory: ✅ Yes (on Submit)
Must select leaf node (e.g., Income Protection, not just Financial Protection)
Validation Logic
* Prevent parent-only selection
Error Messages
* “Please select a valid category”
Field: Persona
Rules
* * * Mandatory: ❌ No
Multi-select: ✅ Yes
Max selections: 5
Validation Logic
* Prevent excessive tagging
Error Messages
* “You can select up to 5 personas”
 Field: Life Stage
Rules
* * Mandatory: ❌ No
Multi-select: ✅ Yes
 Field: Trigger/Event
Rules
* * * Mandatory: ❌ No
Multi-select: ✅ Yes
Must align with predefined taxonomy
Validation Logic
* Only allow controlled values
 Field: Format
Rules
* * * Mandatory: ✅ Yes
Values:
* * * Emailer
Toolkit
Campaign
Drives dynamic validation rules elsewhere
Validation Logic
* Locks dependent fields:
* * Emailer → subject required
Toolkit → file or sections required
4. Workflow & status
Field: Status
System Controlled
Values
* * * Draft
In Review
Published
Rules
* * Draft → default
Only transitions:
* * Draft → In Review
In Review → Published
5. EDITING RULES
Editing Draft Templates
* * All fields editable
No strict validation until submit
Editing Approved Templates
* * Any change triggers:
* Status → In Review
Audit log entry created
DUPLICATION RULES
Duplicate Template
Rules
* * Copies:
* * * Title (append “(Copy)”)
Tags
Content
Resets:
* Status → Draft
Validation
* Ensure new title is unique
 7. DELETE / ARCHIVE RULES
Delete Template
Rules
* * Soft delete (preferred) OR archive
Cannot delete:
* Templates currently in use (optional rule)
Error Messages
* “This template cannot be deleted as it is currently in use”
8. ACTION MENU RULES
Action Visibility
Action
Draft
Review
Published
Edit
✅
✅
✅
Duplicate
✅
✅
✅
Delete
✅
✅
✅






## 🎯 Acceptance Criteria (验收标准)
*未明确配置 Acceptance Criteria*

## 📋 Definition of Ready (DOR) Checklist
*未明确配置 DOR Checklist*

💬 *暂无评审与讨论历史评论*

