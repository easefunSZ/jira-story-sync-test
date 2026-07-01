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
As a Content Manager, 
I want to edit the content of an existing template directly within the system, 
so that I can update templates without having to delete them, reducing operational inefficiency and minimising errors.
Background:
Currently, updating a template requires deleting the existing version and re-uploading a new one. This process is error-prone, time-consuming, and creates gaps in template availability. Enabling direct inline editing allows Content Managers to make changes efficiently while maintaining continuity and version integrity.
Business Value:
Template content is the core asset that Advisers interact with daily. The ability to edit content directly within the system — rather than through a delete-and-reupload cycle — delivers measurable value across multiple dimensions: Operational Efficientcy, Content Continuity, Version Integrity, Error Reducing.
Distinction from LEAD-298 (Edit a Template)
Aspect
LEAD-278 — Manage Template Content
LEAD-298 — Edit a Template
Scope
Template body content — the actual content that Advisers read and use
Template metadata & properties — how the template is classified and managed
What is edited
Rich-text body, inline media, uploaded files, content formatting
Title, Description, Tags, Category, Subcategory, Status, Metadata fields
Editor type
WYSIWYG rich-text content editor (toolbar with formatting, media insertion)
Standard form fields (text inputs, dropdowns, tag selectors, category pickers)
Analogy
Writing and editing the "document body"
Filling in the "document properties panel"
Version impact
Content changes always create a new version
Metadata-only changes follow separate versioning rules defined in LEAD-298
Preview
Content preview available (Preview button to see Adviser view)
No preview needed — metadata changes are immediately visible in the form
Function List:
Function
Description
Priority
Open Content Editor
Content Manager clicks "Edit Content" on an existing template to open the WYSIWYG editor with current content loaded
Must Have
Rich-Text Editing (WYSIWYG)
Full rich-text editing capabilities: text input, formatting, paragraph structure, content organisation
Must Have
Formatting Toolbar
Toolbar with: Bold, Italic, Underline, Headings (H1-H3), Bullet List, Numbered List, Text Alignment, Link insertion, Undo/Redo
Must Have
Media & File Insertion
Insert images and files inline within the content body; supported formats aligned with LEAD-303 upload rules
Must Have
Table Support
Insert and edit tables within content (add/remove rows and columns, merge cells)
Should Have
Manual Save Draft
Content Manager explicitly clicks "Save Draft" button to save current edits as a draft version; published version remains unchanged until republished
Must Have
Content Preview
Content Manager clicks "Preview" button to view the template as Advisers will see it; preview opens in a separate view/modal (not real-time split-screen)
Must Have
Concurrent Editing Lock
Only one Content Manager can edit a template's content at a time; other users see a lock indicator with the current editor's name
Must Have
Version Creation on Save
Each "Save Draft" action creates a new version entry in the template's version history with user, timestamp, and change summary
Must Have
Content Format Extensibility
Architecture designed to accommodate future content formats (video, audio) without major refactoring; current scope is text, images, and files only
Nice to Have
Out of Scope:
Item
Reason
Covered By
Editing template metadata (title, tags, category, status)
Metadata editing is a separate concern
LEAD-298
Template creation from scratch
Creating new templates is a separate workflow
LEAD-306
Template file upload
Uploading files as template content is a separate function
LEAD-303
Video/audio content editing
Future format support; architecture readiness only in this story
Future backlog


## 🎯 Acceptance Criteria (验收标准)
* * * * * * Content Manager can open an existing template and edit its body content in a rich-text inline editor
Content Manager can edit the template name within content editor
The system preserves the previously published version until a new version is explicitly published (no data loss on edit)
If the Content Manager navigates away with unsaved changes, the system displays a confirmation prompt: "You have unsaved changes. Save as draft or discard?"
Only one Content Manager can edit a template at a time; if another user attempts to edit, the system shows a lock indicator with the name of the current editor
The editor supports the current template content format, with the architecture designed to accommodate future formats (e.g. video, audio)
Dependencies: Story: Folder Structure Management


## 📋 Definition of Ready (DOR) Checklist
*未明确配置 DOR Checklist*

💬 **[View Comments & Discussions (查看评审与讨论历史)](LEAD-278_Edit_a_Published_template_comments.md)**

