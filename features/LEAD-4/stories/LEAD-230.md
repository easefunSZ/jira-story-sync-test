# Story - LEAD-230:  PSI Validation & storage  for New Customers

## 📋 Jira Metadata
| Field | Value |
| :--- | :--- |
| **Jira Key** | `LEAD-230` |
| **Type** | `故事` |
| **Status** | `Analysis` |
| **Story Points** | `3` |
| **Parent Feature/Epic** | `LEAD-4` |
| **Labels** | `none` |
| **Components** | `none` |

## 📖 Original Description
As a business user
I want PSI information supplied on a lead for a new customer to be validated and stored
So that valid PSI information is retained and invalid PSI information is prevented from entering InteGreat.

This story closes the gap where a lead contains a PSI but no matching customer exists, ensuring PSI validation is applied consistently across both new and existing customer leads.


## 🎯 Acceptance Criteria (验收标准)
AC1
Given a new customer lead is received and no matching customer exists in InteGreat, when a PSI code is provided on the lead, then the system must persist the PSI value on the lead record.
AC2
Given a new customer lead contains a PSI code, when validation is executed, then the system must validate whether the PSI exists in the intermediary master source (EDR/API).
AC3
Given a PSI code is found, when intermediary validation is completed, then the system must determine whether the intermediary is Active or Inactive and persist the result on the lead.
AC4
Given a *PSI code is invalid  (not 6-digit numeric)*or cannot be found, when validation is completed, then the system must record a PSI Validation Failed outcome and persist the reason.
AC5
Given a new customer lead contains no PSI code, when validation is executed, then *no PSI enrichmen*t attempt shall be performed because no customer record exists from which to derive PSI.
AC6
Given PSI validation is completed, when the lead record is updated, then the validation outcome must be available for audit and external reporting.
AC7
Given PSI validation fails, when processing continues, then the failure outcome must be recorded regardless of whether the lead progresses further in the workflow.
AC8
Given multiple validation rules execute on the lead, when PSI validation completes, then the result must be retained independently of other validation outcomes.


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

💬 *暂无评审与讨论历史评论*

