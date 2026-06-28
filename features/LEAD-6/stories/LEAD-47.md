# Story - LEAD-47: Unified Lead routing

## 📋 Jira Metadata
| Field | Value |
| :--- | :--- |
| **Jira Key** | `LEAD-47` |
| **Type** | `故事` |
| **Status** | `Ready for Deployment` |
| **Story Points** | `2` |
| **Parent Feature/Epic** | `LEAD-6` |
| **Labels** | `DOR_US` |
| **Components** | `Leads Fix` |

## 📖 Original Description
As a Marketing Ops user,
I want all Everlytic leads, including both intermediated and un‑intermediated leads, to be ingested into the IG pipeline,
so that all leads are visible, actionable, and not lost.


 Rule Sumary ( Ingestion- Unintermediated leads)


## 🎯 Acceptance Criteria (验收标准)
* * * * * * * If Everlytic does pass the PSI = Null value,  the lead must be ingested via API  into IG.
 Expectation:
Lead ingested
✅ Passes validation
✅ Identified as Unintermediated
✅ Routed to default allocation group
✅ Assigned to a user


## 📋 Definition of Ready (DOR) Checklist
​# DOR_US
​* [skipped] S/Arch: enabler work identified and systems integration designed
​* [skipped] S/Arch: solution design
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

💬 **[View Comments & Discussions (查看评审与讨论历史)](LEAD-47_comments.md)**

