# Story - LEAD-278: Edit Template Content

## 📋 Jira Metadata
| Field | Value |
| :--- | :--- |
| **Jira Key** | `LEAD-278` |
| **Type** | `故事` |
| **Status** | `待办` |
| **Parent Feature/Epic** | `LEAD-93` |
| **Labels** | `none` |
| **Components** | `none` |

## 📖 Original Description
As a Content Manager, I want to edit the content of an existing template directly within the system, so that I can update templates without having to delete and re-upload them, reducing operational inefficiency and minimising errors.
Background:
Currently, updating a template requires deleting the existing version and re-uploading a new one. This process is error-prone, time-consuming, and creates gaps in template availability. Enabling direct inline editing allows Content Managers to make changes efficiently while maintaining continuity and version integrity.


## 🎯 Acceptance Criteria (验收标准)
* * * * * * * * Content Manager can open an existing template and edit its body content in a rich-text inline editor
Content Manager can edit the template name
Content Manager can reassign the template to a different folder category
All edits are automatically saved as a draft; the currently published version visible to advisers remains unchanged until a new publish action occurs
The system preserves the previously published version until a new version is explicitly published (no data loss on edit)
If the Content Manager navigates away with unsaved changes, the system displays a confirmation prompt: "You have unsaved changes. Save as draft or discard?"
Only one Content Manager can edit a template at a time; if another user attempts to edit, the system shows a lock indicator with the name of the current editor
The editor supports the current template content format, with the architecture designed to accommodate future formats (e.g. video, audio)
Dependencies: Story 1 (Folder Structure Management)


## 📋 Definition of Ready (DOR) Checklist
*未明确配置 DOR Checklist*

💬 *暂无评审与讨论历史评论*

