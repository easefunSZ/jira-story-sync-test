# Story - LEAD-279: Manage Draft & Publish Workflow 

## 📋 Jira Metadata
| Field | Value |
| :--- | :--- |
| **Jira Key** | `LEAD-279` |
| **Type** | `故事` |
| **Status** | `待办` |
| **Story Points** | `8` |
| **Parent Feature/Epic** | `LEAD-93` |
| **Labels** | `none` |
| **Components** | `none` |

## 📖 Original Description
As a Content Manager, I want to save template changes as a draft and publish them when ready, so that I can review and refine edits before they become visible to advisers, ensuring consistency and accuracy in customer communication.
Background:
The publish mechanism is critical to ensuring that advisers always access the most current and approved version of a template. Without a controlled publish workflow, edits could be immediately visible to advisers before they are reviewed, leading to inconsistent or incorrect customer communications.


## 🎯 Acceptance Criteria (验收标准)
* * * * * * * * * All template edits (from Story 3) are saved in draft status by default and are never automatically published
Draft templates are only visible to Content Managers; advisers cannot see or access drafts under any circumstances
Content Manager can preview the draft exactly as it would appear to an adviser (WYSIWYG preview)
Content Manager can publish a draft, which immediately replaces the current published version
The publish action requires a confirmation dialog: "Are you sure you want to publish this template? This will replace the current version visible to advisers."
Content Manager can discard a draft to revert to the current published version; discarding requires confirmation
Each template displays a clear status badge:
* * * Published – live and visible to advisers
Draft – new template, never published

A newly created template starts in draft status and is not visible to advisers until first published
When a draft is published, the previously published version is automatically archived as a historical version (feeds into Story 5)
Dependencies: Story 3 (Edit Template Content)


## 📋 Definition of Ready (DOR) Checklist
*未明确配置 DOR Checklist*

💬 **[View Comments & Discussions (查看评审与讨论历史)](LEAD-279_Manage_Draft_Publish_Workflow_comments.md)**

