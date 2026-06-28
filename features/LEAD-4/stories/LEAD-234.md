# Story - LEAD-234: Validation for SelectedAdvisor When ‘want2Talk2PSI=false’

## 📋 Jira Metadata
| Field | Value |
| :--- | :--- |
| **Jira Key** | `LEAD-234` |
| **Type** | `故事` |
| **Status** | `Analysis` |
| **Story Points** | `3` |
| **Parent Feature/Epic** | `LEAD-4` |
| **Labels** | `none` |
| **Components** | `none` |

## 📖 Original Description
Currently, intermediary sales code validation is only performed on customerInfo.psi when want2Talk2PSI is true. When want2Talk2PSI is false and a selectedAdvisor with salesCode is provided in leadIntension, no validation is performed, posing a data quality and compliance risk.
The system should apply the same validation rules used for customerInfo.psi.salesCode to leadIntension.selectedAdvisor.salesCode when all trigger conditions are met.
Trigger Conditions
All conditions must be met simultaneously:
#
Condition
Field Path
Value
1
Customer does not want to talk to PSI
customerInfo.want2Talk2PSI
false
2
Selected Advisor is present
leadIntension.selectedAdvisor
Not null
3
Sales Code is provided
leadIntension.selectedAdvisor.salesCode
Not empty


## 🎯 Acceptance Criteria (验收标准)
AC1: Sales code does not exist in IG intermediary list
* * * Given trigger conditions are met
When selectedAdvisor.salesCode is validated against the IG intermediary list
Then if no match is found, record validation failure against the lead. Lead does not proceed to dispatch.
AC2: Intermediary is inactive
* * * Given salesCode matches an intermediary record
When the intermediary status is checked
Then if inactive, record validation failure against the lead. Lead does not proceed to dispatch.
AC3: Intermediary is deceased
* * * Given salesCode matches an intermediary record
When deceased check is performed
Then if deceased, record validation failure against the lead. Lead does not proceed to dispatch.
AC4: All validations pass
* * * Given salesCode exists, intermediary is active and not deceased
When all checks complete
Then lead proceeds to the dispatch process as normal.
AC5: Trigger conditions not met
* * Given want2Talk2PSI is false but selectedAdvisor is absent or salesCode is empty
Then this validation is not triggered. Lead follows existing logic.


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

💬 **[View Comments & Discussions (查看评审与讨论历史)](LEAD-234_comments.md)**

