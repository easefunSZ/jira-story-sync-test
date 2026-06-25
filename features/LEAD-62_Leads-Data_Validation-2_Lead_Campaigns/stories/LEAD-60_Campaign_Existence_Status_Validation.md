# Story - LEAD-60: Campaign Existence & Status Validation

## 📋 Jira Metadata
| Field | Value |
| :--- | :--- |
| **Jira Key** | `LEAD-60` |
| **Type** | `故事` |
| **Status** | `正在进行` |
| **Story Points** | `8` |
| **Parent Feature/Epic** | `LEAD-62` |
| **Labels** | `DOR_US, oc_internal_review` |
| **Components** | `Leads Fix` |

## 📖 Original Description
As a user
I want all incoming leads records to be validated against an active campaign
So that only valid campaign leads are processed and invalid leads are rejected early with reporting visibility 
Business Rules
1. Campaign Active Definition
A campaign is considered ACTIVE only when all conditions are true:
* * * Campaign Status = Active
Current Date ≥ Start Date
Current Date ≤ End Date
2. Mandatory Validation
* Campaign validation is mandatory for all incoming leads where Campaign ID is present (not NULL)
3. Exception Logging (Minimum Required Fields)
When validation fails, the following must be written to the Exception Table:
* * * * Lead ID
Campaign ID
Validation Result = FAILED
Failure Reason (one of):
* * * Campaign not found
Campaign inactive
Campaign expired (outside dates)
4. System of Record
* IntegReat is the system of record for Campaign Status and Campaign validity rules
5. Post-Processing / Historical Integrity
* If a campaign changes from Active → Inactive after a lead has already been processed:
* * * Existing leads retain their original validation outcome
No retrospective revalidation is performed
Audit records must retain campaign status as at time of validation
6. Lead Expiry Rule (Unaccepted Allocation)
* * * If a lead was allocated to an adviser while the campaign was active
But the lead is not accepted before campaign expiry
Then the lead will expire when the campaign end date is reached


## 🎯 Acceptance Criteria (验收标准)
1.Campaign Validation – Success Path
Given a lead references a Campaign ID
And the Campaign exists in IntegReat
And the Campaign is ACTIVE (based on status and valid dates)
When Business Validation is performed
Then
* * * The lead is allowed to proceed through the pipeline
Lead status remains valid
No exception is raised
2. Campaign Validation – Failure Path
Given a lead references a Campaign ID
And the Campaign does not exist OR is not active
When Business Validation is performed
Then
* * * * * * Stop lead processing during Business Validation
Set Lead Status = Validation Failed – Invalid / Inactive Campaign
Set Campaign Validation Result = FAILED
Record Campaign Failure Reason:
* * * Campaign not found
Campaign inactive
Campaign expired (outside Start/End dates)
Prevent routing and adviser allocation
Write record to Exception Table
3. Null Campaign Handling
Given a lead has Campaign ID = NULL
When Business Validation is performed
Then
* * Allow lead to proceed through the pipeline
No campaign validation is performed


## 📋 Definition of Ready (DOR) Checklist
# DOR_US
* [skipped] S/Arch: enabler work identified and systems integration designed
* [skipped] S/Arch: solution design
* [done] Data: business rules
* [done] Data data source established
* [skipped] Data: documentation pipelines and data flows
* [skipped] API: tech discovery done
* [skipped] API: documentation and payload provisioning
* [skipped] API: test data provisioned
* [done] OC: documentation and payload provisioning
* [skipped] OC: contract if no API exists
* [skipped] OC: table readiness for data integration
* [skipped] OC: UI design
* [done] FA: INVEST user story with AC
* [done] FA/QE: test data as needed

💬 **[View Comments & Discussions (查看评审与讨论历史)](LEAD-60_Campaign_Existence_Status_Validation_comments.md)**

