# Story - LEAD-57:  PSI Detection and Storage

## 📋 Jira Metadata
| Field | Value |
| :--- | :--- |
| **Jira Key** | `LEAD-57` |
| **Type** | `故事` |
| **Status** | `Analysis` |
| **Parent Feature/Epic** | `LEAD-4` |
| **Labels** | `DOR_US` |
| **Components** | `Leads Fix` |

## 📖 Original Description
As a Business Platform
I want to validate whether a PSI exists for each incoming lead and store the outcome
So that PSI‑based processing and reporting can be applied consistently across all lead sources.
Business Problem : In Integreat Leads, PSI (Preferred Sales Intermediary) is not validated or determined by Integreat itself. This leads to:
* * * Incorrect lead routing or allocation
Advisers actioning leads they should not be associated with
Inconsistent PSI‑based reporting across channels
Outcome
Each lead is tagged with a stored PSI existence result, enabling consistent PSI‑based processing and reporting across all lead sources.


## 🎯 Acceptance Criteria (验收标准)

1. PSI Determination
* * * * Given a lead is received by the system
When the lead is processed
Then the system must determine whether a Primary Servicing Intermediary (PSI) is attached to the lead
And classify the outcome as either:
* * PSI exists ( PSI = Y)
PSI does not exist (PSI = N)
2. Persistence of PSI Outcome
* * * * * * * * Given PSI determination has been performed for a lead
When processing is completed
Then the PSI outcome must be stored against the lead record
And the stored value must be available for downstream processes and 
Channel
PSI Exists (Y/N)
PSI Active (Y/N)
PSI Sales Code Active (Y/N)
And ensure these values are available for downstream processes and reporting
3. Data Consistency
* * * Given multiple lead sources (e.g. Everlytic, batch files, API feeds)
When PSI validation is applied
Then the PSI outcome must be determined using the same business rules across all sources
4. Downstream Availability
* * * Given a lead has been processed
When allocation, routing, or reporting is executed
Then the system must be able to access the stored PSI outcome without recalculating it



## 📋 Definition of Ready (DOR) Checklist
# DOR_US
* [in progress] S/Arch: enabler work identified and systems integration designed
* [in progress] S/Arch: solution design
* [done] Data: business rules
* [done] Data data source established
* [done] Data: documentation pipelines and data flows
* [skipped] API: tech discovery done
* [skipped] API: documentation and payload provisioning
* [skipped] API: test data provisioned
* [skipped] OC: documentation and payload provisioning
* [skipped] OC: contract if no API exists
* [skipped] OC: table readiness for data integration
* [skipped] OC: UI design
* [done] FA: INVEST user story with AC
* [open] FA/QE: test data as needed

💬 **[View Comments & Discussions (查看评审与讨论历史)](LEAD-57_PSI_Detection_and_Storage_comments.md)**

