# Story - LEAD-300: Select /Assign and Edit Tags

## 📋 Jira Metadata
| Field | Value |
| :--- | :--- |
| **Jira Key** | `LEAD-300` |
| **Type** | `故事` |
| **Status** | `Analysis` |
| **Story Points** | `none` |
| **Parent Feature/Epic** | `LEAD-93` |
| **Labels** | `none` |
| **Components** | `none` |

## 📖 Original Description
As a Content Manager
I want to select and assign tags to a template when creating or editing it
So that the template can be easily filtered, searched, and correctly categorised by business intent across the library
Business Value
Consistent tagging ensures:
* * * Improved template discoverability
Accurate filtering across multiple dimensions
Scalable content management as the library grows


## 🎯 Acceptance Criteria (验收标准)
1. Tag Selection Availability
Given a user is creating or editing a template
When the template form is displayed
Then the system must allow the user to select tags
And tags must be grouped by:
* * * * * Content Type
Trigger Event
Lifecycle Stage
Financial Need
Proposition / Source
 2. Predefined Tag List Only
Given a user is assigning tags
When selecting a tag
Then only predefined tag values must be available
And the system must not allow free-text tag entry
 3. Mandatory Tag Assignment
Given a user is saving a template
When required tag groups are not completed
Then the system must prevent saving （suggest prevent publish, save draft skip validation）
And display a validation message
Required groups:
* * * * Content Type
Trigger Event
Lifecycle Stage
Financial Need
4. Single Tag per Required Group (Primary Rule)
Given a user is selecting tags
When selecting a tag within a required group
Then the user must select at least one tag
And only one primary tag should be selected per group (default behaviour)
mandatory groups allow multi-select, with a minimum of 1 tag required. The default behaviour is single-select (one tag pre-selected), but users can add more.
5. Multi-Select Support (Optional Groups)
Given a user is assigning tags
When selecting tags for more groups 
Then the system must allow multiple selections
6. Default Tag Assignment (Fallback)
Given a user has not manually selected tags
When the template is saved (if allowed by business rules)
Then the system must default to:
* * * * Content Type = Email
Trigger Event = Adviser Activity
Lifecycle Stage = Existing Client
Financial Need = Engagement
7. Tag Persistence
Given a template has tags assigned
When the template is edited
Then previously assigned tags must be retained
And only change if explicitly updated by the user
8. Independence from Category
Given a template has a Category and Subcategory assigned
When tags are applied
Then tags must not be restricted by Category
And must be assignable across all categories
9. Tag Visibilit
Given a template has tags assigned
When the template is viewed
Then assigned tags must be visible on:
* Template detail screen
 10. Tag Update on Edit
Given a template exists with tags
When a user edits the template
Then the user must be able to:
* * * Add tags
Remove tags
Replace tags
Show more lines
Validation Messages
Include these for clarity:
* * * * “Please select a Content Type”
“Please select a Trigger Event”
“Please select a Lifecycle Stage”
“Please select a Financial Need”
Definition of Done
A template is correctly tagged when:
* * * * ✅ It has at least one tag in each required group
✅ Tags are selected from predefined taxonomy
✅ Tags follow business rules
✅ Template can be filtered based on assigned tags


## 📋 Definition of Ready (DOR) Checklist
*未明确配置 DOR Checklist*

💬 **[View Comments & Discussions (查看评审与讨论历史)](LEAD-300_Select_Assign_and_Edit_Tags_comments.md)**

