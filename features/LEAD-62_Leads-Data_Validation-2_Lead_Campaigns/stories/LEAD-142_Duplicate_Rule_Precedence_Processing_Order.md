# Story - LEAD-142: Duplicate Rule Precedence / Processing Order 

## 📋 Jira Metadata
| Field | Value |
| :--- | :--- |
| **Jira Key** | `LEAD-142` |
| **Type** | `故事` |
| **Status** | `正在进行` |
| **Story Points** | `3` |
| **Parent Feature/Epic** | `LEAD-62` |
| **Labels** | `oc_internal_review` |
| **Components** | `none` |

## 📖 Original Description
As the Leads Processing System
I want duplicate rules to be evaluated in a consistent order
So that only one final duplicate outcome is applied to a lead


## 🎯 Acceptance Criteria (验收标准)
Business Rules — Rule Precedence
Rule 1 – Existing Customer (Identity Match)
Rule Name
Existing Customer / Existing Lead Check
Incoming lead matches an existing customer using the highest‑priority identifier, e.g.:
* GCS ID (preferred)
Outcome
* Customer is confirmed as existing
Rule 2 – Same Campaign Duplicate 
Rule Name
Same Campaign – Existing Lead
Condition
* * * Existing customer found  ( GCS ID)
Existing lead found  ( Lead Id)
Same campaign ID as incoming lead ( campaign ID)
Outcome
BLOCK lead creation ( exception reason - Campaign duplicate Lead”
Rule 3 – Cross‑Campaign Duplicate 
Rule Name
Different Campaign – Existing Customer
Condition
* * * Existing customer found 
Existing lead found 
Different campaign ID 
Outcome
✅ ALLOW lead creation
System actions:
* * * * Create a new Lead ID for the new campaign
 Retain relationship to existing lead:
* * Origin Lead ID
New Lead ID
 Record:
* * * Existing campaign
New campaign
Match timestamp
Create exception reason:
“Cross‑Campaign Duplicate”


## 📋 Definition of Ready (DOR) Checklist
# Default checklist
---DOR_US
* [done] FA: INVEST user story with AC
* [open] FA/QE: test data as needed
* [skipped] Data: business rules
* [skipped] Data data source established
* [skipped] Data: documentation pipelines and data flows
* [skipped] API: tech discovery done
* [skipped] API: documentation and payload provisioning
* [skipped] API: test data provisioned
* [done] OC: documentation and payload provisioning
* [skipped] OC: contract if no API exists
* [skipped] OC: table readiness for data integration
* [skipped] OC: UI design

💬 **[View Comments & Discussions (查看评审与讨论历史)](LEAD-142_Duplicate_Rule_Precedence_Processing_Order_comments.md)**

