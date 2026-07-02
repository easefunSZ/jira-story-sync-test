# Story - LEAD-278: Edit a Published template 

## 📋 Jira Metadata
| Field | Value |
| :--- | :--- |
| **Jira Key** | `LEAD-278` |
| **Type** | `故事` |
| **Status** | `Analysis` |
| **Story Points** | `none` |
| **Parent Feature/Epic** | `LEAD-93` |
| **Labels** | `none` |
| **Components** | `none` |

## 📖 Original Description
As a Content Manager
I want to edit a published template and make changes to its content without disrupting Adviser access
So that I can keep published templates accurate, up-to-date, and compliant while Advisers continue using the current version until my changes are reviewed and re-published.
Business Value:
Published templates are live assets actively used by Advisers in client-facing interactions. When content becomes outdated, contains errors, or requires regulatory updates, Content Managers need to make corrections without taking the template offline. This story enables safe editing of published templates by creating a working draft copy, preserving the live version for Advisers until the updated content is validated and re-published — eliminating the current delete-and-recreate workaround that causes downtime, version history loss, and compliance risk.
Scope Definition:
This story only covers editing templates that are currently in Published status. It focuses on the content body (rich text, uploaded files) of published templates.
Status Flow:
This story covers one specific path in the template lifecycle:
Step
Status
Description
Adviser Visibility
1
Published (Current Live Version)
Template is live and in use by Advisers. CM clicks "Edit" to start modifications.
Visible — Advisers see this version
2
Draft (Working Copy)
System creates a working copy of the published template. CM edits the content body in this copy. The original published version remains untouched.
Original published version remains visible
3a
Save Draft
CM saves progress. Can close and return later to continue editing.
Original published version remains visible
3b
Re-Publish
CM clicks Publish. System runs pre-publish validation (LEAD-326). If passed, the working copy replaces the live version. Old version moves to version history.
New version now visible to Advisers
3c
Discard Changes
CM discards the working copy. The original published version remains unchanged. No version history entry is created.
Original published version unchanged
Rule: At no point during the editing process should the published template become unavailable to Advisers. The original published version is always the "live" version until a new version is explicitly re-published.
Function List:
Function
Description
Priority
Create Working Copy
When CM clicks "Edit" on a published template, the system creates a draft working copy. The original published version remains live and unchanged.
Must Have
WYSIWYG Content Editor
Rich text editor for editing the template content body. Supports: headings, bold/italic/underline, bullet & numbered lists, hyperlinks, inline images, tables. 
Must Have
Replace Uploaded File
If the published template contains an uploaded file (PDF/DOCX/TXT), CM can replace it with a new file. Same file type and size constraints as LEAD-303.
Must Have
Manual Save (Draft)
CM clicks "Save Draft" to persist changes. System saves the working copy. No auto-save — consistent with DAE platform behaviour.
Must Have
Unsaved Changes Warning
If CM navigates away or closes the editor with unsaved changes, system displays a confirmation dialog: "You have unsaved changes. Save as Draft / Discard / Cancel".
Must Have
Manual Preview
CM clicks "Preview" button to open a read-only preview of the working copy in a separate view (simulating the Adviser's view). CM can close the preview and return to the editor. 
Must Have
Re-Publish with Validation
CM clicks "Publish" on the working copy. System runs pre-publish validation (per LEAD-326). If passed, the working copy replaces the published version. Old version moves to version history (per LEAD-280).
Must Have
Discard Working Copy
CM can discard the working copy entirely. System deletes the draft; the original published version remains unchanged. No version history entry is created for discarded drafts.
Must Have
Concurrent Edit Lock
Only one CM can edit a published template's content at a time. If another CM attempts to edit, system displays: "[User Name] is currently editing this template. Please try again later." Lock applies to content body only — metadata editing (LEAD-299) is not blocked.
Must Have
Lock Release Mechanism
Lock is released when: (a) CM saves and exits the editor, (b) CM discards the working copy, (c) CM session times out (per DAE platform timeout setting), (d) CM explicitly clicks "Release Lock" button.
Must Have
Edit History Indicator
In the template library view, templates with an active working copy show a visual indicator (e.g., "Draft in progress" badge) so other CMs know an edit is underway.
Should Have


## 🎯 Acceptance Criteria (验收标准)
AC1: Initiate Edit on Published Template
Given a template with status = Published
When the Content Manager clicks "Edit"
Then:
* * * * * The system creates a draft working copy of the published template
The WYSIWYG editor opens with the current published content pre-loaded
The original published version remains live and visible to Advisers
The template shows a "Draft in progress" indicator in the library view
A concurrent edit lock is placed on this template's content
AC2: WYSIWYG Rich Text Editor
Given the Content Manager is editing a working copy
When the editor is loaded
Then the editor supports the following formatting options:
* * * * * * * Headings (H1, H2, H3)
Bold, Italic, Underline, Strikethrough
Bullet lists and numbered lists
Hyperlinks (insert, edit, remove)
Inline images (upload or paste)
Tables (insert, add/remove rows and columns)
Undo / Redo
AC3: Manual Save
Given the Content Manager has made changes in the editor
When the Content Manager clicks "Save Draft"
Then:
* * * * * The working copy is saved with the latest changes
A success message is displayed: "Draft saved successfully"
The template status remains Draft (working copy)
The original published version is NOT affected
No version history entry is created for draft saves
Note: There is no auto-save mechanism. This is consistent with DAE platform behaviour. CM must explicitly click "Save Draft" to persist changes.
AC4: Unsaved Changes Warning
Given the Content Manager has unsaved changes in the editor
When the Content Manager attempts to navigate away, close the browser tab, or click any link outside the editor
Then:
* * The system displays a confirmation dialog: "You have unsaved changes"
Options: "Save Draft" (saves and navigates) / "Discard" (discards working copy and navigates) / "Cancel" (returns to editor)
AC5: Manual Preview
Given the Content Manager is editing a working copy
When the Content Manager clicks "Preview"
Then:
* * * * A read-only preview opens in a separate view, showing the template as Advisers will see it
The preview reflects the current editor content (including unsaved changes visible in the editor)
The CM can close the preview and return to the editor to continue editing
This is a manual preview triggered by button click — NOT a real-time split-screen preview
AC6: Re-Publish Edited Template
Given the Content Manager has finished editing a working copy
When the Content Manager clicks "Publish"
Then:
* * * The system runs pre-publish validation (per LEAD-326)
If validation passes: The working copy replaces the live published version → template status = Published → the previous published version is saved to version history (per LEAD-280) → success message: "Template [Title] has been re-published successfully" → concurrent edit lock is released
If validation fails: Error summary displayed with inline field-level errors → template remains as Draft working copy → CM can fix issues and retry
AC7: Discard Working Copy
Given the Content Manager is editing a working copy (with or without unsaved changes)
When the Content Manager clicks "Discard Changes"
Then:
* * * A confirmation dialog appears: "Are you sure you want to discard all changes? The published version will remain unchanged."
If confirmed: the working copy is permanently deleted → the original published version remains unchanged → no version history entry is created → concurrent edit lock is released → CM returns to template library
If cancelled: CM returns to editor, working copy is preserved
AC8: Replace Uploaded File
Given the published template contains an uploaded file 
When the Content Manager clicks "Upload" in the working copy
Then:
* * * The file upload dialog opens (same constraints as LEAD-303: accepted formats, max file size)
The new file replaces the existing file in the working copy only
The original published template's file is NOT affected until re-publish
AC9: Concurrent Edit Lock
Given Content Manager A is editing a published template (working copy exists)
When Content Manager B attempts to click "Edit" on the same template
Then:
* * * * The system displays: "[CM A's Name] is currently editing this template. Please try again later."
The "Edit" button is disabled for CM B
CM B can still view the current published version (read-only)
Note: The lock applies to content body editing only. Metadata editing (LEAD-299: tags, category, description) is NOT blocked by this lock.
AC10: Lock Release
Given a concurrent edit lock exists on a template
Then the lock is released in any of the following scenarios:
* * * * (a) CM saves and exits the editor
(b) CM discards the working copy
(c) CM successfully re-publishes the template
(d) CM's session times out (per DAE platform timeout setting)


## 📋 Definition of Ready (DOR) Checklist
*未明确配置 DOR Checklist*

💬 **[View Comments & Discussions (查看评审与讨论历史)](LEAD-278_Edit_a_Published_template_comments.md)**

