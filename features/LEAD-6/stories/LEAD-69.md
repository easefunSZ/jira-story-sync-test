# Story - LEAD-69:  Define File Failure Handling, Retry, and Escalation Rules for Lead Ingestion

## 📋 Jira Metadata
| Field | Value |
| :--- | :--- |
| **Jira Key** | `LEAD-69` |
| **Type** | `故事` |
| **Status** | `Ready for Deployment` |
| **Story Points** | `2` |
| **Parent Feature/Epic** | `LEAD-6` |
| **Labels** | `none` |
| **Components** | `Leads Fix` |

## 📖 Original Description
As a Campaign Team / Data team
I want clearly defined rules for how lead file and record failures are handled, including retry limits and escalation thresholds
So that we can distinguish between expected data failures and true system incidents, ensure consistent processing behaviour, and avoid unnecessary manual investigation or missed critical issues


## 🎯 Acceptance Criteria (验收标准)
Meeting with Preya/Kashief
* * Files are configured to automatically retry ingestion on an hourly schedule. Business stakeholders will not be included in these notifications, as the process is managed operationally within the technical team until successful ingestion is achieved.
File ingestion failure ( Notification)  - OC
In the event of a file ingestion failure (Matillion process), an automated notification must be sent to the Data Engineering team for investigation. The team will be responsible for diagnosing the issue and coordinating with the source system to ensure the lead file is corrected and resubmitted.
* * Record failures:
Record failures/exceptions Business – (table
* * No real-time notifications will be sent for individual record-level failures or exceptions.( result in alert fatigue) Instead, all such failures are already stored in the existing Exception table.
This data must be made available to the PFMI team, who will be responsible for producing a consolidated Power BI report for the Campaign team. The report should provide a single, end-to-end view of all business validation failures across the lead processing pipeline, enabling the Campaign team to investigate and rectify issues at a record level.
* 
* *Dependency  * Failure Report*
@Emil Schnabel – Alignment is required with the PFMI team to design and deliver the Power BI report using data from the existing Exception table or . Or for now, a manual extract by OC to provide table data ( of all exceptions- weekly provided to Campaign team)


## 📋 Definition of Ready (DOR) Checklist
*未明确配置 DOR Checklist*

💬 **[View Comments & Discussions (查看评审与讨论历史)](LEAD-69_comments.md)**

