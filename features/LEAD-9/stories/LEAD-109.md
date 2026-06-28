# Story - LEAD-109: Expose Lead allocation data

## 📋 Jira Metadata
| Field | Value |
| :--- | :--- |
| **Jira Key** | `LEAD-109` |
| **Type** | `故事` |
| **Status** | `待办` |
| **Story Points** | `3` |
| **Parent Feature/Epic** | `LEAD-9` |
| **Labels** | `DOR_US` |
| **Components** | `none` |

## 📖 Original Description
As a reporting analyst
I want lead allocation data showing where leads were allocated across channels and FA
So that I can track distribution and identify allocation bottlenecks or uneven workload.


## 🎯 Acceptance Criteria (验收标准)
1. Allocation Data Availability
* * Each lead record includes allocation details indicating where the lead is assigned.
Allocation data is available for all leads associated with a campaign.

* * * Allocation Hierarchy Coverage
* Dataset includes the following allocation levels:
* Business Channel, Region. Area. Team. Financial adviser
 Campaign Linkage
* Lead allocation data is linked to Campaign ID, enabling:
* * Reporting of allocations within each campaign
Aggregation of leads by campaign → channel → FA
Aggregation Support
* * Dataset supports reliable aggregation of:
* * * Leads allocated per campaign
Leads allocated per business channel
Leads allocated per FA
Aggregations produce consistent totals across all hierarchy levels.
AC5. Current vs Historical Allocation
* * * Dataset includes current allocation (latest assigned channel/FA).
Where available, historical allocation changes are captured, including:
* * * Previous allocation
New allocation
Timestamp of change
Data Completeness Rules
* * Mandatory fields (Lead ID, Campaign ID, Channel or FA) must not be null
Any missing allocation is:
* Explicitly flagged  in exception table


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

💬 **[View Comments & Discussions (查看评审与讨论历史)](LEAD-109_comments.md)**

