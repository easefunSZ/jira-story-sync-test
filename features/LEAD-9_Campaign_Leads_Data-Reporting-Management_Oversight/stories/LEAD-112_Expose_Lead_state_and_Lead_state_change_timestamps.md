# Story - LEAD-112: Expose  Lead state and Lead state change timestamps

## 📋 Jira Metadata
| Field | Value |
| :--- | :--- |
| **Jira Key** | `LEAD-112` |
| **Type** | `故事` |
| **Status** | `待办` |
| **Story Points** | `3` |
| **Parent Feature/Epic** | `LEAD-9` |
| **Labels** | `DOR_US` |
| **Components** | `none` |

## 📖 Original Description
As a reporting analyst
I want lead status/state and state change timestamps
So that I can report on where leads are in the process and identify delays


## 🎯 Acceptance Criteria (验收标准)
AC1. Lead Status Availability
* * Each lead record includes a current status/state (e.g., New, Assigned, Contacted, Qualified, Closed).
AC2. State Change Timestamps
* The dataset includes timestamps for key state transitions, at minimum:
* * * * Lead creation date/time
First assignment date/time
First contact date/time (if applicable)
Closure date/time (if applicable)
AC3. Historical State Tracking
* * The dataset provides historical state changes per lead, either:
* * As multiple timestamp columns, or
As a separate state change/event table with one record per state transition
Each state change record includes:
* * * * Lead ID
Previous state (optional but preferred)
New state
Timestamp of change
AC4. Traceability & Sequencing
* * State transitions can be ordered chronologically per lead using timestamps
No duplicate or conflicting state transitions exist for the same timestamp
AC5. Campaign-Level Analysis Support
* Lead state and state changes are linked to campaign ID, enabling:
* * Reporting of lead progression within a campaign
Aggregation of leads by state per campaign
AC6. Time-in-State Analysis
* Dataset supports calculation of time spent in each state, either:
* * Directly (derived fields), or
Indirectly via available timestamps
AC7. Data Completeness Rules
* * Mandatory timestamps (e.g., creation date) must not be null
Missing timestamps for specific states are:
* * Allowed only where the state has not been reached, and
Clearly distinguishable from data quality issues
AC8. Data Quality & Consistency
* * * Each lead has a unique identifier
No orphan state records exist without a corresponding lead
Status transitions follow valid business rules (e.g., no skipping from New → Closed unless allowed)


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

💬 **[View Comments & Discussions (查看评审与讨论历史)](LEAD-112_Expose_Lead_state_and_Lead_state_change_timestamps_comments.md)**

