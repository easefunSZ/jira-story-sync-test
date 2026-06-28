# Story - LEAD-105: Expose campaign metadata and metadata success 

## 📋 Jira Metadata
| Field | Value |
| :--- | :--- |
| **Jira Key** | `LEAD-105` |
| **Type** | `故事` |
| **Status** | `Analysis` |
| **Story Points** | `3` |
| **Parent Feature/Epic** | `LEAD-9` |
| **Labels** | `DOR_US` |
| **Components** | `none` |

## 📖 Original Description
As a Reporting Analyst
I want campaign metadata and successful campaign load indicators
So that I can report on campaigns and confirm campaigns were loaded successfully


## 🎯 Acceptance Criteria (验收标准)
1.  Campaign details
* * * Feed includes campaign ID, name, and category ( Acquisition ; Existing customer campaign)
Campaign status is included
Each lead record is linked to a valid campaign
* Campaign Load
* *  Feed includes Lead volumes in Campaign ( Total lead count  per Campaign)
Feed includes Lead count  rejected at Campaign load.
3. Data freshness / timeliness
* Campaign and lead load data reflects the latest successful ingestion run Each dataset includes a “last updated timestamp” indicating when the feed was generated.
4. Load success indicator
* * Each campaign load includes a load status indicator (e.g., Success /  Failed).
Failed or partial loads include a high-level reason 
5. Traceability of load runs
* * Each campaign load is linked to a unique batch ID / ingestion ID.
Users can identify which leads were part of the same upload batch.
6. Data quality breakdown
* * Rejected lead counts are segmented by rejection reason (e.g., missing fields, invalid format, duplicate lead, invalid campaign reference).
Total rejected leads per campaign = sum of all rejection reason counts.
7. Reconciliation logic
* * * Total leads per campaign =  sucessfully ingested + rejected leads.
No campaign appears with missing or negative lead counts.
Reconciliation rules are clearly defined and consistent across feeds.
8. Campaign validity enforcement
* * Only active and valid campaigns are included in the feed.
Leads linked to invalid or unknown campaigns are flagged and excluded or routed to exception table.
9. Error visibility / exception reporting
* * Any campaign load failures or data issues are surfaced in an exception section of the feed.
Exceptions are clearly distinguishable from successful campaign data.



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

💬 **[View Comments & Discussions (查看评审与讨论历史)](LEAD-105_comments.md)**

