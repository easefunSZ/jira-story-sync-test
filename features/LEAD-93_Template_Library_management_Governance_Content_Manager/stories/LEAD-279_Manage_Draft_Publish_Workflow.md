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
The publish mechanism ensures that advisers always access the most current and approved version of a template. Without a controlled workflow, edits could be immediately visible before review, leading to inconsistent or incorrect customer communications.
Scope of this story: Defines the template lifecycle state machine and the rules governing each state transition.
Out of scope: Content editing (LEAD-278), Save Draft details (LEAD-302), Preview rendering (LEAD-326).
Business Value:
A controlled Draft → Published workflow prevents unreviewed or incomplete content from reaching customers, protecting communication quality, brand consistency, and regulatory compliance.
Workflow Status:
Draft → Publish → Published -> Edit → Draft(new version)
Status
Description (EN)
Advisers Visible
Editable by CM
Available Actions
Draft
Template is being created or edited. Available actions: Edit, Preview, Save Draft, Publish, Discard.
No
Yes
Edit, Preview, Save Draft, Publish, Discard
Published
Live and visible to advisers. This is the current approved version. Cannot be edited directly — clicking "Edit" creates a new Draft version.
Yes
No
View, Edit (→ new Draft)


## 🎯 Acceptance Criteria (验收标准)
* Draft Behaviour
#
AC
AC1
A newly created template defaults to Draft status.
AC2
Draft templates are only visible to Content Managers. Advisers cannot see or access drafts under any circumstances.
AC3
Content Manager can save a draft at any point without triggering publish. Saving a draft does not require all mandatory fields to be completed.
AC4
Each template displays a clear status badge:
* * Draft — work in progress
Published — live version
* Publish
#
AC
AC5
Pre-publish validation: Before publishing, the system validates all mandatory fields are completed (LEAD-277 Section 10 for full validation rules). If validation fails, the system displays field-level error messages and blocks publish.
AC6
Publish confirmation dialog — two scenarios:
First-time publish (new template):
"Are you sure you want to publish this template? It will become visible to advisers."
Re-publish (updating existing published template):
"Are you sure you want to publish this template? This will replace the current version visible to advisers."
The dialog has two buttons: [Cancel] (returns to editor) and [Publish] (proceeds).
AC7
On successful publish:
* * * * Template status changes from Draft → Published
Template becomes immediately visible to advisers
System displays a success notification: "Template published successfully."
CM is redirected to the template detail view
* Versioning
#
AC
AC8
Editing a Published template: When a CM clicks "Edit" on a Published template, the system creates a new Draft version. The current Published version remains live and visible to advisers until the new Draft is published.
AC9
When a new Draft is published, the previously published version is automatically archived as a historical version. Advisers always see only the latest published version.
AC10
When validation passes (AC5) but the system fails to complete the publish operation (e.g., network error, version conflict, edit lock conflict):
* * * * The publish is treated as an atomic operation — on failure, the template remains in Draft status. If re-publishing, the current Published version stays live and unaffected.
All draft content is preserved (auto-save before returning error if needed). No user content is lost.
The CM stays on the editor page (no redirect). An error is shown at the top:
* * General failure: "Publishing failed. Your changes have been saved as a draft. Please try again." — with a [Retry Publish] button that re-triggers from the confirmation dialog (AC6).
Version conflict: "A newer version was published by [User] on [Date]. Please review the latest version before republishing." — with a [View Latest Version] button.
Publish failures are recorded in the audit log (template ID, user, timestamp, failure reason).
4.Discard Draft
AC11
Discard a draft of an existing published template: CM can discard the draft to revert to the current published version. The draft is deleted, and the published version remains unchanged.
AC12
Discard a brand-new template (never published): CM can discard the draft. Since there is no published version to revert to, the template is permanently deleted.
AC13
Discarding always requires a confirmation dialog:
Existing published template:
"Are you sure you want to discard this draft? The template will revert to the current published version."
New template (never published):
"Are you sure you want to discard this draft? This template has never been published and will be permanently deleted."
Buttons: [Cancel] and [Discard]


## 📋 Definition of Ready (DOR) Checklist
*未明确配置 DOR Checklist*

💬 **[View Comments & Discussions (查看评审与讨论历史)](LEAD-279_Manage_Draft_Publish_Workflow_comments.md)**

