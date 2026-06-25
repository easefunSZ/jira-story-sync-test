# Story - LEAD-7: Lead allocation : Adviser Availability Management

## 📋 Jira Metadata
| Field | Value |
| :--- | :--- |
| **Jira Key** | `LEAD-7` |
| **Type** | `Feature` |
| **Status** | `打开` |
| **Parent Feature/Epic** | `LEAD-35` |
| **Labels** | `DOR_FEAT` |
| **Components** | `Leads Fix` |

## 📖 Original Description
When advisers are unavailable, due to leaving the business or makes themselves unavailable, leads should not be allocated to them.
Context:
The “unavailable adviser” status is currently not included in the lead allocation logic, which impacts both customer and adviser experience. (Feedback from previous architect)


## 🎯 Acceptance Criteria (验收标准)
* * * * * * * * * The system must only allocate leads to advisers who are both Active and Available
Advisers marked as Inactive (e.g., left the business) must be automatically excluded from all lead allocation processes
Advisers marked as Unavailable (temporarily) must not receive new lead allocations during the unavailable period
The allocation engine must dynamically evaluate adviser status and availability at the time of assignment
The system must prevent manual allocation of leads to advisers who are inactive or unavailable (or require explicit override with audit tracking)
Any existing open leads assigned to advisers who become inactive or unavailable must be identifiable for reassignment
The system must ensure no lead remains unallocated due to adviser unavailability
Changes to adviser status or availability must take immediate effect in allocation rules
The system must provide visibility and traceability of allocation decisions, including exclusion reasons


## 📋 Definition of Ready (DOR) Checklist
​# Default checklist
​--- DOR_FEAT
​* [open] Feature goal
​* [open] 5 - 7 stories
​* [open] Acceptance criteria
​* [open] OC input
​* [open] Arch Solution design
​* [open] UX journey map

💬 **[View Comments & Discussions (查看评审与讨论历史)](LEAD-7_Lead_allocation_Adviser_Availability_Management_comments.md)**

