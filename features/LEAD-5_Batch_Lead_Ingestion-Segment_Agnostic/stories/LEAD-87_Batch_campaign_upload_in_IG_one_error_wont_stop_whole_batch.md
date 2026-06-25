# Story - LEAD-87: Batch campaign upload in IG — one error won't stop whole batch

## 📋 Jira Metadata
| Field | Value |
| :--- | :--- |
| **Jira Key** | `LEAD-87` |
| **Type** | `故事` |
| **Status** | `Ready for Deployment` |
| **Story Points** | `5` |
| **Parent Feature/Epic** | `LEAD-5` |
| **Labels** | `none` |
| **Components** | `none` |

## 📖 Original Description
As a Campaign Manager,
I want to batch upload IG internal activity leads where individual row failures do not block the entire file upload,
So that valid leads are processed and written successfully, while failed rows are clearly reported with error details, improving operational responsiveness and reducing dependency on other teams.
Background & Business Context:
* * (Rozana) The batch upload functionality should remain available as an option for Campaign Managers and be extended to Channel Administrators. Channel Administrators frequently need to upload data from workshops and other ad hoc activities but are currently dependent on other teams for these uploads. Due to capacity constraints, support is not always provided timeously. Enabling them with this capability would significantly improve responsiveness and operational efficiency.
(Frans) IG internal activity leads must support batch upload. A single record failure must not block the entire file — e.g., if 10 leads are uploaded and 1 has a data error, the other 9 should be written successfully. OC to update error handling process to not block batch upload but process successful rows and throw exception report for failures.


## 🎯 Acceptance Criteria (验收标准)
AC 1: Partial Success Processing — Single Row Failure Does Not Block the Batch
Given a user uploads a batch file containing multiple lead records (e.g., 10 records),
When one or more records contain data errors (e.g., invalid format, PartyAPI decease check failure returning error 400),
Then:
* * * The system continues processing all remaining valid records without interrupting the entire batch upload;
All valid records (e.g., 9 out of 10) are successfully written to the system and corresponding leads are generated and allocated;
The UI does not display timeout errors caused by exception handling during processing.


## 📋 Definition of Ready (DOR) Checklist
# Default checklist
---DOR_US
* [done] FA: INVEST user story with AC
* [done] FA/QE: test data as needed
* [done] Data: business rules
* [open] Data data source established
* [skipped] Data: documentation pipelines and data flows
* [skipped] API: tech discovery done
* [skipped] API: documentation and payload provisioning
* [skipped] API: test data provisioned
* [skipped] OC: documentation and payload provisioning
* [skipped] OC: contract if no API exists
* [skipped] OC: table readiness for data integration
* [skipped] OC: UI design

💬 **[View Comments & Discussions (查看评审与讨论历史)](LEAD-87_Batch_campaign_upload_in_IG_one_error_wont_stop_whole_batch_comments.md)**

