# Story - LEAD-84: Auto-Correct Missing Lead PSI

## 📋 Jira Metadata
| Field | Value |
| :--- | :--- |
| **Jira Key** | `LEAD-84` |
| **Type** | `故事` |
| **Status** | `Analysis` |
| **Story Points** | `3` |
| **Parent Feature/Epic** | `LEAD-4` |
| **Labels** | `none` |
| **Components** | `none` |

## 📖 Original Description
As the Leads Processing System
I want to detect when PSI information is missing from an uploaded lead but already exists in InteGreat
So that the existing PSI data can automatically be applied to the lead and processing can continue consistently without manual intervention.


## 🎯 Acceptance Criteria (验收标准)
Success Acceptance Criteria
Scenario 1: Populate missing PSI from existing customer record before PSI validation
Given a lead file is uploaded without PSI information (File Contains a customer identifier; File does not  Does not contain PSI / Sales Code)
When the system identifies that the customer already exists in InteGreat (IG) and valid PSI information already exists for that customer
Then the system must automatically copy and apply the existing PSI information to the new lead.
Scenario 2: Continue PSI processing using the populated PSI
* * Given existing PSI information is successfully applied to the uploaded lead
When lead validation completes
Then the lead must continue processing via the PSI-Y route.
Given PSI information is auto-populated from an existing IG customer record
When the lead is processed
Then the system must retain a validation result - PSI Auto-populated ,indicating that PSI was sourced from an existing customer profile.
Audit & Traceability
* System records:
* * PSI source = Copied from existing customer
Validation result = PSI Auto‑Populated
Failure / Exception Acceptance Criteria
* * * * Given a lead file is uploaded without PSI information
When no matching customer record exists in IG
Then the system must not apply PSI data and the lead must follow the standard non-PSI processing or exception route.
Given a lead file is uploaded without PSI information
When a matching customer exists in IG but no PSI information exists for that customer
Then the system must not populate PSI and must flag the lead accordingly for downstream processing.
Given a matching customer record is found in IG
When the PSI data is incomplete or invalid,.
Then the system must not apply the PSI information and must generate an appropriate validation exception.
Given multiple possible customer matches are found in IG
When the system cannot confidently determine the correct customer record
Then the system must not auto-apply PSI information and must raise a duplicate customer reason , to write to exception table


## 📋 Definition of Ready (DOR) Checklist
# Default checklist
---DOR_US
* [done] FA: INVEST user story with AC
* [open] FA/QE: test data as needed
* [done] Data: business rules
* [done] Data data source established
* [done] Data: documentation pipelines and data flows
* [skipped] API: tech discovery done
* [skipped] API: documentation and payload provisioning
* [skipped] API: test data provisioned
* [skipped] OC: documentation and payload provisioning
* [skipped] OC: contract if no API exists
* [skipped] OC: table readiness for data integration
* [skipped] OC: UI design

💬 **[View Comments & Discussions (查看评审与讨论历史)](LEAD-84_comments.md)**

