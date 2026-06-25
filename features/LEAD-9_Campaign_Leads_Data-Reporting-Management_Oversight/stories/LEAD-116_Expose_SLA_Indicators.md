# Story - LEAD-116: Expose SLA Indicators

## 📋 Jira Metadata
| Field | Value |
| :--- | :--- |
| **Jira Key** | `LEAD-116` |
| **Type** | `故事` |
| **Status** | `待办` |
| **Story Points** | `3` |
| **Parent Feature/Epic** | `LEAD-9` |
| **Labels** | `DOR_US` |
| **Components** | `none` |

## 📖 Original Description
As a reporting analyst
I want SLA  indicators for leads by campaign and team/adviser
So that I can report on SLA breaches 


## 🎯 Acceptance Criteria (验收标准)
AC1. SLA Data Availability
* * * * * Each lead record includes the timestamps required to calculate SLA, at minimum:
* * * Lead creation date/time
SLA start date/time (if different from creation)
First action/contact date/time
AC2. SLA Definition & Thresholds
* * SLA thresholds are defined and agreed (e.g., X hours or days).

AC3. SLA Status Indicator
* Each lead includes an SLA indicator/status, such as:
* * * Within SLA
Outside SLA
SLA Pending (for leads still within allowed time window)
AC4. Campaign-Level SLA Reporting
* SLA indicators are linked to Campaign ID, enabling:
* * Reporting of SLA compliance by campaign
Comparison of SLA performance across campaigns
AC6. SLA Breach Identification
* * * Dataset supports identification of:
* * Number of leads breaching SLA
Percentage of leads breaching SLA
SLA breaches are clearly distinguishable from leads still in progress.



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

💬 **[View Comments & Discussions (查看评审与讨论历史)](LEAD-116_Expose_SLA_Indicators_comments.md)**

