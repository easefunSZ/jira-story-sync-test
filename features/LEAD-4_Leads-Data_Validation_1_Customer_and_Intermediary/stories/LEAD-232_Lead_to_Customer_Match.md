# Story - LEAD-232: Lead to Customer Match

## 📋 Jira Metadata
| Field | Value |
| :--- | :--- |
| **Jira Key** | `LEAD-232` |
| **Type** | `故事` |
| **Status** | `Analysis` |
| **Parent Feature/Epic** | `LEAD-4` |
| **Labels** | `none` |
| **Components** | `none` |

## 📖 Original Description
As a Lead Management System
I want to match inbound leads against existing customer records
So that leads are correctly linked to existing customers and duplicate customer records are not created.


## 🎯 Acceptance Criteria (验收标准)
AC1: Match Using GCS Customer ID
Given a GCS Customer ID is present on the inbound lead
When the GCS Customer ID matches an existing customer record
Then the lead must be linked to the matching customer record
And the Existing Customer Indicator must be set to "Yes"
And no further customer matching rules must be executed.
AC2: Fallback Match Using Surname and Cellphone Number
Given a GCS Customer ID is not provided or no matching customer record is found using the GCS Customer ID
When the lead's “Surname” and “Cellphone Number” match an existing customer record
Then the lead must be linked to the matching customer record
And the Existing Customer Indicator must be set to "Yes".
AC3: No Customer Match Found
Given no customer record can be matched using:
* * GCS Customer ID; or
Surname and Cellphone Number
When the matching process completes
Then the lead must be treated as a New Customer lead
And the Existing Customer Indicator must be set to "No".
AC5: Multiple Customer Matches Found
Given more than one customer record matches the Surname and Cellphone Number criteria
When the matching process completes
Then the lead must be flagged 
And no customer record must be automatically linked
And an exception must be raised  ( exception reason) - “ Multiple Matching Customers Identified”
AC6: Missing Matching Data
Given the lead does not contain a GCS Customer ID
And either the Surname or Cellphone Number is missing
When customer matching is attempted
Then the system must treat the lead as a New Customer lead
And record the reason as "Insufficient customer matching data".
AC7: Audit Logging
Given customer matching is performed
When the matching process completes
Then the system must record:
* * * * * Lead ID
Match method used (GCS Customer ID or Surname + Cellphone Number)
Match outcome
Matched Customer ID (if found)
Date and time of the decision.


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

💬 **[View Comments & Discussions (查看评审与讨论历史)](LEAD-232_Lead_to_Customer_Match_comments.md)**

