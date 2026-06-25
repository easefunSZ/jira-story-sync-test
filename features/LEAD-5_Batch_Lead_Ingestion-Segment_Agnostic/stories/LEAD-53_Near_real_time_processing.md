# Story - LEAD-53: Near real time processing

## 📋 Jira Metadata
| Field | Value |
| :--- | :--- |
| **Jira Key** | `LEAD-53` |
| **Type** | `故事` |
| **Status** | `Ready for Deployment` |
| **Story Points** | `5` |
| **Parent Feature/Epic** | `LEAD-5` |
| **Labels** | `DOR_US` |
| **Components** | `Leads Fix` |

## 📖 Original Description
As a Campaign Manager / Campaign Administrator
I want manual uploads to process in near real time after the file is available
So that campaigns and opportunities can be actioned quickly.


## 🎯 Acceptance Criteria (验收标准)
Success
* * * AC3.1 Once a file is detected, processing begins within an agreed near real-time window 
AC3.2 The pipeline processes files asynchronously (non-blocking) so ingestion does not stall other workloads.
AC3.3 The upload/job ID reflects timestamps for received, started, and completed states.


## 📋 Definition of Ready (DOR) Checklist
# DOR_US
* [skipped] S/Arch: enabler work identified and systems integration designed
* [done] S/Arch: solution design
* [done] Data: business rules
* [skipped] Data data source established
* [skipped] Data: documentation pipelines and data flows
* [skipped] API: tech discovery done
* [skipped] API: documentation and payload provisioning
* [skipped] API: test data provisioned
* [skipped] OC: documentation and payload provisioning
* [skipped] OC: contract if no API exists
* [skipped] OC: table readiness for data integration
* [skipped] OC: UI design
* [done] FA: INVEST user story with AC
* [done] FA/QE: test data as needed

💬 **[View Comments & Discussions (查看评审与讨论历史)](LEAD-53_Near_real_time_processing_comments.md)**

