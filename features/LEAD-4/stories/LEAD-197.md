# Story - LEAD-197: Allow processing when PSI missing on Lead and Customer

## 📋 Jira Metadata
| Field | Value |
| :--- | :--- |
| **Jira Key** | `LEAD-197` |
| **Type** | `故事` |
| **Status** | `Analysis` |
| **Story Points** | `3` |
| **Parent Feature/Epic** | `LEAD-4` |
| **Labels** | `none` |
| **Components** | `none` |

## 📖 Original Description
As a system, I want to allow processing even if PSI is missing on both lead and customer to avoid unnecessary blocking.


## 🎯 Acceptance Criteria (验收标准)
* * * Given: The lead has no PSI, and the matched customer record also has no PSI
When: The system executes the PSI validation process
Then:
* * * * The Lead continues processing without being blocked
The validation result is marked as "Pass – No PSI on both"
The system must log the following information in the validation audit table:
* * * * * * * * * Lead ID
Customer ID
Validation Rule ID (PSI-005)
Validation Type: PSI Validation
Validation Outcome: Pass
Failure Reason: N/A
Lead PSI Value: Null
Customer PSI Value: Null
Processing Timestamp
This record can be used for subsequent data quality reporting to identify customers with missing PSI
Note: For existing customers, a missing PSI is a data quality issue. Although it does not block the current lead processing, the audit trail should support future data cleansing and PSI backfill efforts.


## 📋 Definition of Ready (DOR) Checklist
# Default checklist
---DOR_US
* [done] FA: INVEST user story with AC
* [open] FA/QE: test data as needed
* [done] Data: business rules
* [done] Data data source established
* [done] Data: documentation pipelines and data flows
* [skipped] API: tech discovery done
* [skipped] API: documentation and payload provisioning
* [skipped] API: test data provisioned
* [skipped] OC: documentation and payload provisioning
* [skipped] OC: contract if no API exists
* [open] OC: table readiness for data integration
* [skipped] OC: UI design

💬 **[View Comments & Discussions (查看评审与讨论历史)](LEAD-197_comments.md)**

