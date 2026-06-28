# Story - LEAD-176: Controlled Display of Campaign Information in Leads Pool

## 📋 Jira Metadata
| Field | Value |
| :--- | :--- |
| **Jira Key** | `LEAD-176` |
| **Type** | `故事` |
| **Status** | `Analysis` |
| **Story Points** | `3` |
| **Parent Feature/Epic** | `LEAD-25` |
| **Labels** | `none` |
| **Components** | `none` |

## 📖 Original Description
As an adviser,
I want to see only relevant maturity campaign information in the Leads Pool
So that I can quickly understand campaign context without sensitive exposure.

Rules
* * Rule: Display = CAMPAIGN_Masked (pre-acceptance)
Rule: Hide maturity fields before lead acceptance
Data Elements
* * * * Campaign Information ( masked  values)
Campaign Name
Campaign Type
Lead ID


## 🎯 Acceptance Criteria (验收标准)
Acceptance Criteria
AC2.1 – Campaign Information Card
Given a maturity lead exists in the Leads Pool
When advisers view available leads
Then a "Campaign Information" card must be displayed.
AC2.2 – Masked Maturity  Display
Given a  maturity lead exist
When the adviser views the lead in the Leads Pool
Then the maksed vallues for Product type/Maturity date /Matuity value display
AC2.4 – Visibility Restriction
Given a lead has not yet been accepted
When the adviser views the lead in the Leads Pool
Then maturity value, policy type, maturity date  must not be displayed.
Stage
What Adviser Sees
Leads Pool
Maturity information
Product type: ******
Maturity date: */*/2026
Maturity value: *****
After Acceptance (My Leads)
Maturity information
Product type: Endownment
Maturity date: 01/06/2026
Maturity value:  R 500 000


## 📋 Definition of Ready (DOR) Checklist
*未明确配置 DOR Checklist*

💬 *暂无评审与讨论历史评论*

