# Story - LEAD-48: Unified Lead Ingestion (All Lead Types)

## 📋 Jira Metadata
| Field | Value |
| :--- | :--- |
| **Jira Key** | `LEAD-48` |
| **Type** | `故事` |
| **Status** | `Ready for Deployment` |
| **Story Points** | `2` |
| **Parent Feature/Epic** | `LEAD-6` |
| **Labels** | `DOR_US` |
| **Components** | `Leads Fix` |

## 📖 Original Description
As a Product owner
I want to ingest both intermediated and un-intermediated leads from all sources
So that all leads are processed through the Integreat pipeline and, once ingested, are routed according to PSI status (PSI = Y or PSI = N)
Success
Lead is intermediated 
When processed
Then it follows the existing intermediated routing to IG.

Lead is un-intermediated (PSI (N)
When processed
Then it follows the un-intermediated workflow path (e.g., default queue/assignment rule).
New lead data sources are implemented
When configuration is updated
Then no code change is required (configuration-driven routing).


## 🎯 Acceptance Criteria (验收标准)
System must accept lead feeds containing:
* * * * * Intermediated leads (PSI populated)
* Un-intermediated leads (PSI = null or empty)
PSI field must support:
* * Valid Sales Code (intermediated)
Null/empty values (un-intermediated)
Leads must enter the same ingestion pipeline regardless of type
No lead type should be excluded based on PSI presence
Once Ingested, the lead must follow the existing PSI -Y, or PSI - N routing.
 



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

💬 **[View Comments & Discussions (查看评审与讨论历史)](LEAD-48_Unified_Lead_Ingestion_All_Lead_Types_comments.md)**

