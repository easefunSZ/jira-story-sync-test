# Story - LEAD-40: Lead Name Validation – First Name or Surname Required

## 📋 Jira Metadata
| Field | Value |
| :--- | :--- |
| **Jira Key** | `LEAD-40` |
| **Type** | `故事` |
| **Status** | `正在进行` |
| **Story Points** | `3` |
| **Parent Feature/Epic** | `LEAD-62` |
| **Labels** | `oc_internal_review` |
| **Components** | `Leads Fix` |

## 📖 Original Description
As a business stakeholder
I want leads to be allowed through processing when at least one customer name field (First Name or Surname) is provided, regardless of whether a PSI exists
So that valid leads are not rejected or blocked due to missing non‑critical name information.


## 🎯 Acceptance Criteria (验收标准)
* * * The rule applies to all incoming leads, regardless of:
* * PSI = Yes
PSI = No
A lead is considered valid for processing if at least one of the following name fields is populated:
* * First Name
Surname
It is not mandatory for both fields to be populated.
1: First Name present, Surname missing
Given an incoming lead is received
And the lead has a First Name populated
And the Surname is missing or blank
When name validation is performed
Then:
* * * * The lead passes name validation
The lead continues through normal processing
The lead is eligible for allocation
No rejection is triggered due to missing Surname
2: Surname present, First Name missing
Given an incoming lead is received
And the lead has a Surname populated
And the First Name is missing or blank
When name validation is performed
Then:
* * * * The lead passes name validation
The lead continues through normal processing
The lead is eligible for allocation
No rejection is triggered due to missing First Name
3: Both First Name and Surname are present
Given an incoming lead is received
And both First Name and Surname are populated
When name validation is performed
Then:
* * The lead passes name validation
The lead proceeds through normal processing and allocation
4: Both First Name and Surname are missing
Given an incoming lead is received
And both First Name and Surname are missing or blank
When name validation is performed
Then:
* * * The lead fails name validation
The lead is handled according to standard invalid‑data rules
The validation outcome is recorded with description 
Additional Acceptance Conditions
* * * This rule applies to both:
* * PSI = Yes
PSI = No
This rule is not a hard stop when at least one name field is present.
Validation outcomes must be available for audit and reporting.



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

💬 **[View Comments & Discussions (查看评审与讨论历史)](LEAD-40_Lead_Name_Validation_First_Name_or_Surname_Required_comments.md)**

