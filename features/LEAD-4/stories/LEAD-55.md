# Story - LEAD-55:  Validate Matching PSI between Lead and customer

## 📋 Jira Metadata
| Field | Value |
| :--- | :--- |
| **Jira Key** | `LEAD-55` |
| **Type** | `故事` |
| **Status** | `Analysis` |
| **Parent Feature/Epic** | `LEAD-4` |
| **Labels** | `DOR_US` |
| **Components** | `Leads Fix` |

## 📖 Original Description
As a Business User
As a system
I want to verify that the PSI on the lead matches the PSI in the same Channel on the customer record
So that valid leads can proceed without interruption




## 🎯 Acceptance Criteria (验收标准)
1.Rule only runs when PSI exists
* * * If a lead has gone through the PSI check
And PSI Indicator = "Y"
* Then the system must run the PSI Active Check
If PSI Indicator = "N"
* Then the system must not run the PSI Active Check
2. PSI must belong to the Personal Finance (PF) Channel
* * * If a lead has a PSI linked
* Then the system must check the channel of the PSI
If the PSI is in the Personal Finance (PF SA) channel
* Then continue with the PSI Active Check
If the PSI is not in the PF channel
* * Then:
* * * * * * * The lead must be flagged as “Invalid PSI Channel”
The lead must not continue normal processing
The lead must be sent to the exception table
The reason “PSI not in PF Channel” must be stored

3. PSI active status must be checked
If the PSI is in the PF channel
* Then the system must check if the PSI is Active using the defined rules
PSI is marked as Active
* If the PSI meets the rules for Active
* Then set PSI Active Indicator = "Y"
5. PSI is marked as Inactive
* If the PSI does not meet the rules for Active
* Then set PSI Active Indicator = "N"
6. PSI status must always be saved
* After the check is done
* * The result must be saved on the lead
It must not be removed or changed, even if later steps fail
7. Inactive PSI leads must be flagged
* If PSI Active Indicator = "N"
* Then:
* * The lead must be flagged as “Inactive PSI”
The flag must be visible to users and reporting
8. Handling of inactive PSI leads
* If PSI Active Indicator = "N"
* Then:
* * * The lead must not follow normal processing
The lead must go to the exception process
The reason “Inactive PSI” must be recorded
10. PSI status available for reporting
* After processing
* The PSI Active Indicator and Channel validation result must be available for:
* * * Processing
Exception handling
Reporting


## 📋 Definition of Ready (DOR) Checklist
# DOR_US
* [in progress] S/Arch: enabler work identified and systems integration designed
* [in progress] S/Arch: solution design
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
* [done] FA: INVEST user story with AC
* [open] FA/QE: test data as needed

💬 **[View Comments & Discussions (查看评审与讨论历史)](LEAD-55_comments.md)**

