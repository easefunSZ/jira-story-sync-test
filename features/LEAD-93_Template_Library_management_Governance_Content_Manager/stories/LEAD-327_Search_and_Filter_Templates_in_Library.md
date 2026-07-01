# Story - LEAD-327: Search and Filter Templates in Library

## 📋 Jira Metadata
| Field | Value |
| :--- | :--- |
| **Jira Key** | `LEAD-327` |
| **Type** | `故事` |
| **Status** | `Analysis` |
| **Story Points** | `none` |
| **Parent Feature/Epic** | `LEAD-93` |
| **Labels** | `none` |
| **Components** | `none` |

## 📖 Original Description
As a Content Manager
I want to search and filter templates in the template library by keywords, categories, tags, and status
So that I can quickly locate specific templates without manually browsing through categories, especially as the template library grows.
Context:
The Content Manager manages a growing number of templates across multiple categories and subcategories. Relying solely on the category tree navigation becomes inefficient as the library scales. The system must provide a global search bar and multi-dimensional filter controls on the Templates Library main page.
Flow: Enter Search Keywords / Apply Filters → System Returns Matching Templates → CM Selects Template


## 🎯 Acceptance Criteria (验收标准)
* * * * * * * * * * A search bar must be available at the top of the Templates Library main page.
Search must support keyword matching against:
* * * Template title
Template description
Tags (Persona, Life Stage, Trigger, Format)
Search results must update in real-time (or on Enter) as the CM types.
The CM must be able to filter templates by:
* * * * Category / Subcategory (multi-select)
Tags — Persona, Life Stage, Trigger, Format (multi-select per dimension)
Status — Draft, In Review, Published, Archived
Date range — created date or last modified date
Filters must be combinable — the CM can apply multiple filters simultaneously (e.g., Status = Draft + Tag: Persona = "Young Professional").
Active filters must be displayed as filter chips/badges that can be individually removed.
A "Clear All Filters" action must be available to reset all filters at once.
When no results match, the system must display a "No templates found" message with a suggestion to adjust search terms or filters.
Search and filter results must respect the CM's permission scope — only templates the CM has access to should appear.
The result list must maintain the same Action Menu functionality as the standard library view (edit, duplicate, reassign, delete — based on template status).


## 📋 Definition of Ready (DOR) Checklist
*未明确配置 DOR Checklist*

💬 *暂无评审与讨论历史评论*

