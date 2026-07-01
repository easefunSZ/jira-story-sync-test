# Story - LEAD-279: Manage Draft & Publish Workflow 

## 📋 Jira Metadata
| Field | Value |
| :--- | :--- |
| **Jira Key** | `LEAD-279` |
| **Type** | `故事` |
| **Status** | `Analysis` |
| **Story Points** | `none` |
| **Parent Feature/Epic** | `LEAD-93` |
| **Labels** | `none` |
| **Components** | `none` |

## 📖 Original Description
As a Content Manager, I want to manage templates through a controlled lifecycle workflow: Create → Preview → Save Draft → Publish, so that I can ensure content quality and accuracy before it becomes visible to advisers.
Background:
The publish mechanism is critical to ensuring that advisers always access the most current and approved version of a template. Without a controlled workflow, edits could be immediately visible to advisers before review, leading to inconsistent or incorrect customer communications. This story defines the complete template lifecycle state machine and the rules governing each state transition — it does not cover the act of editing content (LEAD-278), saving a draft (LEAD-302), or preview validation (LEAD-326).
Business Value:
A controlled Draft to Published workflow ensures that advisers always access the most current and approved version of a template, preventing unreviewed or incomplete content from reaching customers, thereby protecting communication quality, brand consistency, and regulatory compliance.
Workflow Status:
Status
Description (EN)
Advisers Visible
Editable
Draft
Template is being created or edited. Available actions: Edit, Preview, Save Draft, Submit for Review, Discard.
No
Yes
Preview
Submitted for preview. Reviewer can view the template, approve (→ Published) or reject (→ back to Draft with feedback).
No
No
Published
Live and visible to advisers. Current approved version. Editing creates a new Draft version.
Yes
No


## 🎯 Acceptance Criteria (验收标准)
#
AC
1
A newly created template defaults to Draft status and is not visible to advisers until published.
2
Draft templates are only visible to Content Managers; advisers cannot see or access drafts under any circumstances.
3
Content Manager can preview the draft exactly as advisers would see it (WYSIWYG) before submitting for review. 
4
Content Manager can save a draft at any point without triggering review or publish. 
5
Publishing requires a confirmation dialog: "Are you sure you want to publish this template? This will replace the current version visible to advisers."
6
If the publish action fails, the system displays an error message and retains the template in Review status without data loss. The Content Manager can retry or return to Draft.
7
Content Manager can discard a draft to revert to the current published version; discarding requires confirmation.
8
Each template displays a clear status badge: Published (live) or Draft (work in progress).
9
When a draft is published, the previously published version is automatically archived as a historical version. 


## 📋 Definition of Ready (DOR) Checklist
*未明确配置 DOR Checklist*

💬 **[View Comments & Discussions (查看评审与讨论历史)](LEAD-279_Manage_Draft_Publish_Workflow_comments.md)**

