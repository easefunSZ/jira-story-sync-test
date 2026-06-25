# Story - LEAD-175: Maturity Lead Visibility in My Leads ( after acceptance)

## 📋 Jira Metadata
| Field | Value |
| :--- | :--- |
| **Jira Key** | `LEAD-175` |
| **Type** | `故事` |
| **Status** | `Analysis` |
| **Parent Feature/Epic** | `LEAD-25` |
| **Labels** | `none` |
| **Components** | `none` |

## 📖 Original Description
As an adviser,
I want full maturity details after accepting a lead
So that I can prepare for meaningful customer conversations.

Rules
* * * Rule: Visibility = POST_ACCEPTANCE_ONLY
Rule: Ownership check (lead must be assigned to adviser)
Rule: Data must be retrieved from enriched dataset (not raw source)
Data Elements
* * * * * Policy Type
Maturity Date
Maturity Value
Assigned Adviser ID
Lead Status = ACCEPTED


## 🎯 Acceptance Criteria (验收标准)
AC3.1 – Display After Acceptance
Given an adviser accepts a maturity campaign lead
When the lead moves to My Leads
Then maturity information must become visible to the assigned adviser.
AC3.2 – Maturity Fields Displayed
Given maturity information exists for the accepted lead
When the adviser views the lead in My Leads
Then the following fields must be displayed:
* * * product type
Maturity Date
Maturity Value
AC3.3 – Conditional Display
Given a maturity field contains no value
When the adviser views the lead
Then that field must not be displayed.
AC3.4 – Non-Maturity Leads
Given the lead does not belong to a maturity campaign
When the adviser views the lead in My Leads
Then maturity-specific fields must not be displayed.
AC3.5 – Adviser Access Control
Given a maturity lead has been allocated to an adviser
When another adviser attempts to view the lead details
Then maturity-specific information must not be visible unless they have authorised access.

Stage
What Adviser Sees
After Acceptance (My Leads)
Maturity information
Product type: Endownment
Maturity date: 01/06/2026
Maturity value:  R 500 000


## 📋 Definition of Ready (DOR) Checklist
*未明确配置 DOR Checklist*

💬 *暂无评审与讨论历史评论*

