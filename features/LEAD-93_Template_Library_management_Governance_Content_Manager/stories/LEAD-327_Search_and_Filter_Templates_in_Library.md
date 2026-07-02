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
Scope Note: This story focuses on the search and filter functionality added to the existing Template Library list view. Sorting, pagination, and list rendering are already implemented and out of scope for this story.


## 🎯 Acceptance Criteria (验收标准)

AC1
Search Bar
A search bar is displayed at the top of the Template Library main page. The search bar includes:
* * * Placeholder text: "Search templates by title, description, or tags..."
A clear (✕) button to reset the search input
Search is triggered when the user presses Enter or clicks a search icon
AC2
Keyword Search Scope
The search must match keywords against the following template fields:
* * * Title — partial match supported
Description — partial match supported
Tags — matches against all tag groups: Content Type, Trigger Event, Lifecycle Stage, Financial Need, Proposition / Source
Search is case-insensitive.
AC3
Filter Dimensions
The following filter dimensions are available alongside the search bar: （Table1）
AC4
Filter Combination Logic
* * Filters across different dimensions are combined with AND (intersection)
Filters within the same dimension are combined with OR (union)
Example: Lifecycle Stage = "Prospect" AND Financial Need = "Protect" → returns templates tagged with both. Lifecycle Stage = "Prospect" OR "New Client" → returns templates tagged with either.
AC5
Search + Filter Combination
Search keywords and filter selections can be used together. When combined:
* * Results must match both the keyword search AND all active filters
Filters narrow down the search results, not replace them
AC6
Active Filter Display
* * * * Each active filter is displayed as a chip / badge near the search bar
Each chip shows the dimension name and selected value (e.g., Lifecycle Stage: Prospect)
Each chip has a ✕ button to remove that individual filter
A "Clear All Filters" button is available to reset all filters and search input at once
AC7
Empty State
When no templates match the current search + filter combination:
* * * Display message: "No templates found. Try adjusting your search terms or filters."
The "Clear All Filters" button remains visible
The template list area shows no rows (no broken layout)
Table 1：
Filter
Type
Values
Category / Subcategory
Multi-select, hierarchical
All active categories and subcategories (from LEAD-293). Selecting a parent category automatically includes all its subcategories.
Content Type
Multi-select
Phase 1: Email, Campaign (per LEAD-300 taxonomy)
Trigger Event
Multi-select
All values from Tag_Taxonomy.xlsx, grouped by parent category (Customer Event, Adviser Activity, Seasonal Event, Product Event, Business Event)
Lifecycle Stage
Multi-select
All values from Tag_Taxonomy.xlsx (e.g., Prospect, New Client, Existing Client, At-Risk Client, Lapsed Client)
Financial Need
Multi-select
All values from Tag_Taxonomy.xlsx (e.g., Protect, Grow Wealth, Save, Plan Retirement, Engagement, Awareness, Financial Education)
Proposition / Source
Multi-select (optional)
All values from Tag_Taxonomy.xlsx (e.g., OM Bank, Rewards, Vault22)
Status
Multi-select
Draft, Published


## 📋 Definition of Ready (DOR) Checklist
*未明确配置 DOR Checklist*

💬 **[View Comments & Discussions (查看评审与讨论历史)](LEAD-327_Search_and_Filter_Templates_in_Library_comments.md)**

