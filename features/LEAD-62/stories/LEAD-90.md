# Story - LEAD-90: Lead Deduplication & Cross-Campaign Management

## 📋 Jira Metadata
| Field | Value |
| :--- | :--- |
| **Jira Key** | `LEAD-90` |
| **Type** | `故事` |
| **Status** | `正在进行` |
| **Story Points** | `2` |
| **Parent Feature/Epic** | `LEAD-62` |
| **Labels** | `oc_internal_review` |
| **Components** | `none` |

## 📖 Original Description
As the Leads Processing System
I want to identify when an incoming lead already exists in InteGreat
So that duplicate leads are managed according to campaign and recency business rules, preventing duplicate allocation and ensuring a consistent customer experience.

Context:
The Lead Deduplication check is performed to prevent the same Lead from being repeatedly created and distributed as new leads in InteGreat.
The checks support objectives:
* * * Avoid duplicate allocation to advisers
Prevent customers from being contacted multiple times unnecessarily
Maintain a single customer engagement history


## 🎯 Acceptance Criteria (验收标准)
Scenario 1 –  Same Campaign- duplicate lead
Description
When a new lead is received, the system must validate whether the customer already exists as an active lead within the same campaign in InteGreat.
Acceptance Criteria
AC1.1
Given a lead is uploaded or received
When the system matches the customer to an existing lead in the same campaign
Then the system must identify the lead as a Same Campaign Duplicate.
AC1.2
The system must prevent creation of a new lead record for the same campaign.
AC1.3
The existing lead record must remain the primary active record.
AC1.4
The duplicate event must create an exception reason “  Same Campaign duplicate lead”
Clarification: No duplicate Lead ID , no duplicate Customer ID (GCS ID-existing)-If you provide me with a lead tracker Payload , I can have a look and determine what the unique identifier is.
Scenario 2 –  Cross Campaign- Duplicate
Description
The incoming lead already exists in InteGreat, but under a different campaign.
Acceptance Criteria
AC2.1
Given a lead is uploaded or received
When the customer already exists as a lead in a different campaign
Then the system must identify the lead as a Cross-Campaign Duplicate.
AC2.2
The system must  still create a lead for the new campaign
* AC2.3
The system must retain a relationship between the existing lead and the new campaign lead for tracking and reporting.
AC2.4
The system must record the duplicate match details, including:
* * * Existing campaign
New campaign
Match timestamp
AC2.5
The system must create a exception reason “Cross-Campaign Duplicate”
Clarification: Lead ID, Client ID



## 📋 Definition of Ready (DOR) Checklist
# Default checklist
---DOR_US
* [done] FA: INVEST user story with AC
* [open] FA/QE: test data as needed
* [skipped] Data: business rules
* [skipped] Data data source established
* [skipped] Data: documentation pipelines and data flows
* [skipped] API: tech discovery done
* [skipped] API: documentation and payload provisioning
* [skipped] API: test data provisioned
* [done] OC: documentation and payload provisioning
* [skipped] OC: contract if no API exists
* [skipped] OC: table readiness for data integration
* [done] OC: UI design

💬 **[View Comments & Discussions (查看评审与讨论历史)](LEAD-90_comments.md)**

