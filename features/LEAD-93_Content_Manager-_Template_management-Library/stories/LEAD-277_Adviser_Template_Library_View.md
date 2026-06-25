# Story - LEAD-277: Adviser Template Library View

## 📋 Jira Metadata
| Field | Value |
| :--- | :--- |
| **Jira Key** | `LEAD-277` |
| **Type** | `故事` |
| **Status** | `待办` |
| **Parent Feature/Epic** | `LEAD-93` |
| **Labels** | `none` |
| **Components** | `none` |

## 📖 Original Description
As an Adviser, I want to browse the template library using the folder/category structure and search for templates by name, so that I can quickly locate the relevant template for client communications (e.g. rewards, missed premiums) without relying on unclear or inconsistent template titles.
Background:
Advisers currently rely on guesswork when selecting templates due to inconsistent naming. This leads to inefficiency, incorrect template usage, and reduced confidence in the template library. A structured browse and search experience will enable advisers to navigate by business category and find the correct template quickly.


## 🎯 Acceptance Criteria (验收标准)
* * * * * * * * Adviser can navigate the template library using the folder/category hierarchy established in Story 1
Only published templates (latest version) are visible to advisers; draft or unpublished templates are completely hidden
Adviser can search templates by name with real-time filtering / type-ahead suggestions
Search results display: template name, folder path (breadcrumb), and last published date
When a folder contains no published templates, it is hidden from the adviser view
Adviser can preview template content in a read-only view before selecting it for use
The template list within each folder is sorted alphabetically by default, with the option to sort by last published date
The library view clearly reflects the business categorisation (e.g. Rewards, Missed Premiums) so advisers can intuitively understand the purpose of each section
Dependencies: Story 1 (Folder Structure Management)
Restricted actions for Advisers 
* * * * Cannot create or edit templates
Cannot publish or delete content
Cannot view drafts or unpublished versions
Cannot modify folder structure


## 📋 Definition of Ready (DOR) Checklist
*未明确配置 DOR Checklist*

💬 *暂无评审与讨论历史评论*

