# Story - LEAD-49: File level: Failure reasons  & Notification (IT)

## 📋 Jira Metadata
| Field | Value |
| :--- | :--- |
| **Jira Key** | `LEAD-49` |
| **Type** | `故事` |
| **Status** | `Ready for Deployment` |
| **Story Points** | `2` |
| **Parent Feature/Epic** | `LEAD-6` |
| **Labels** | `DOR_US` |
| **Components** | `Leads Fix` |

## 📖 Original Description
As a Data Engineer, I need to receive an alert when a lead file fails ingestion so that I can investigate the root cause and coordinate with the source system to correct and resubmit the file.
The Matillion process needs to cater for this requirement.


## 🎯 Acceptance Criteria (验收标准)
1. Failure Detection
* * * Given a lead file ingestion process is executed
When the ingestion fails at any stage (e.g. file receipt) 
Then the failure must be detected and classified by the ingestion framework.
2. Alert Triggering
* * * Given a lead file ingestion failure is detected ( 3 times)
When the failure is confirmed
Then an alert must be automatically triggered without manual intervention.
( as there is an hourly retry to ingest the file - after each attempt:
* * Log failure reason; Keep file in “Pending Retry” state. Alert must only be triggered after  (final retry failed) 3rd time
Status: “Ingestion failed – manual intervention required
3. Alert Delivery Channel
* * Given the alert is triggered
Then it must be delivered through the configured notification channel(s), such as:
* Email
4. Alert Content
* * Given an alert is sent
Then it must include at minimum:
* * * * File name and unique file identifier
Source system name (Madam or Everlytic)
Error message and/or  error code 
Date and time of failure
5. Recovery Support
* * * Given the source system resubmits a corrected lead file
When ingestion succeeds
Then no failure alert is triggered, and the successful ingestion is logged.


## 📋 Definition of Ready (DOR) Checklist
​# DOR_US
​* [open] S/Arch: enabler work identified and systems integration designed
​* [open] S/Arch: solution design
​* [open] Data: business rules
​* [open] Data data source established
​* [open] Data: documentation pipelines and data flows
​* [open] API: tech discovery done
​* [open] API: documentation and payload provisioning
​* [open] API: test data provisioned
​* [open] OC: documentation and payload provisioning
​* [open] OC: contract if no API exists
​* [open] OC: table readiness for data integration
​* [open] OC: UI design
​* [open] FA: INVEST user story with AC
​* [open] FA/QE: test data as needed

💬 **[View Comments & Discussions (查看评审与讨论历史)](LEAD-49_File_level_Failure_reasons_Notification_IT_comments.md)**

