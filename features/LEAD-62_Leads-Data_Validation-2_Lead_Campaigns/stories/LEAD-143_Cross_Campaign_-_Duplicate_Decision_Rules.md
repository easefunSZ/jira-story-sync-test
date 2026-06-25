# Story - LEAD-143: Cross Campaign - Duplicate Decision Rules

## 📋 Jira Metadata
| Field | Value |
| :--- | :--- |
| **Jira Key** | `LEAD-143` |
| **Type** | `故事` |
| **Status** | `正在进行` |
| **Story Points** | `2` |
| **Parent Feature/Epic** | `LEAD-62` |
| **Labels** | `oc_internal_review` |
| **Components** | `none` |

## 📖 Original Description
As the Leads Processing System
I want cross-campaign duplicates to be evaluated against configurable business rules
So that customers are not over-contacted while still allowing valid sales opportunities


## 🎯 Acceptance Criteria (验收标准)
Business Rules — Cross-Campaign Duplicate Handling
Rule 1 — Cross-Campaign Detection
IF a customer already exists in a different campaign
THEN the system must identify the lead as a Cross-Campaign Duplicate.
Lead must still be created.
Rule 2 — Relationship Tracking
Where a cross-campaign duplicate is allowed,
the system must store:
* * * * * Existing Lead ID
Existing Campaign ID
New Lead ID
New Campaign ID
Match Timestamp


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
* [open] OC: documentation and payload provisioning
* [skipped] OC: contract if no API exists
* [skipped] OC: table readiness for data integration
* [skipped] OC: UI design

💬 *暂无评审与讨论历史评论*

