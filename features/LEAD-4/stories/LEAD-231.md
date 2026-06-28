# Story - LEAD-231: Validate PSI sales code format

## 📋 Jira Metadata
| Field | Value |
| :--- | :--- |
| **Jira Key** | `LEAD-231` |
| **Type** | `故事` |
| **Status** | `Analysis` |
| **Story Points** | `3` |
| **Parent Feature/Epic** | `LEAD-4` |
| **Labels** | `none` |
| **Components** | `none` |

## 📖 Original Description
As the lead processing system,
I want to validate the format of any PSI sales code received on an inbound lead,
so that only correctly formatted sales codes are processed and submitted for further PSI validation.


## 🎯 Acceptance Criteria (验收标准)
AC – Validate PSI Sales Code Format
Given a PSI sales code is present on the lead
When the system validates the sales code format
Then the PSI sales code must:
* * Contain exactly 6 digits
Contain numeric characters only (0–9)
And if the sales code does not meet the required format, the system must:
* * * Fail PSI validation
Generate a PSI Sales code invalid Exception
Not perform any further PSI validation checks (existence or active status)
AC2 – Validate Length
Given a PSI sales code is present
When the system validates the code
Then the sales code must contain exactly 6 digits.
AC3 – Validate Numeric Content
Given a PSI sales code is present
When the system validates the code
Then the sales code must contain numeric characters only (0–9).

AC4 – Continue Processing for Valid Format
Given a PSI sales code passes format validation
When validation completes successfully
Then the system must proceed with subsequent PSI validation checks.
AC5 – Audit Validation Result
Given PSI format validation has been performed
When processing completes
Then the system must record:
* * * * Lead identifier
Validation date/time
Validation result (Pass/Fail)
Failure reason (if applicable)


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
---DOR_US
* [open] FA: INVEST user story with AC
* [open] FA/QE: test data as needed
* [open] Data: business rules
* [open] Data data source established
* [open] Data: documentation pipelines and data flows
* [open] API: tech discovery done
* [open] API: documentation and payload provisioning
* [open] API: test data provisioned
* [open] OC: documentation and payload provisioning
* [open] OC: contract if no API exists
* [open] OC: table readiness for data integration
* [open] OC: UI design

💬 *暂无评审与讨论历史评论*

