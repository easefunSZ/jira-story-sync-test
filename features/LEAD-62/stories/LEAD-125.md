# Story - LEAD-125: Lead Validation -Expose Validation Outcomes/Exception table ( to PFMI)

## 📋 Jira Metadata
| Field | Value |
| :--- | :--- |
| **Jira Key** | `LEAD-125` |
| **Type** | `故事` |
| **Status** | `Ready for Development` |
| **Story Points** | `2` |
| **Parent Feature/Epic** | `LEAD-62` |
| **Labels** | `none` |
| **Components** | `none` |

## 📖 Original Description
As a PFMi Reporting Analyst
I want a structured data view/table that exposes lead validation outcomes/exceptions  along with lead and campaign metadata
So that I can build reports and dashboards to monitor lead validation pass/fail rates, and campaign integrity.
Background & Problem Statement
* * * LEAD-62 AC-7 requires: "All validation outcomes must be made available for reporting external to IG". The PFMI team needs the Exception table to be exposed, so that they can import this into their warehouse.
The current exception report only captures a subset of validation failure reasons:
* * * * * * Campaign code/name not registered in IG
Sales code not valid
Adviser not provisioned on IG
Inactive campaign
Customer is deceased
Adviser status is inactive
Other validation outcomes produced during the lead validation process are not recorded in the exception report. Additionally, the following data points identified by the reporting team are not currently available in any exception/reporting output:
Field
Description
Lead State
The validation outcome state, e.g. "Validation Failed"
Date Validated
The date/timestamp when validation was completed
Allocation Status
Whether the lead was allocated after validation (confirm if allocated)
Allocated Adviser ( Name/surname)
If allocated， which adviser was assigned
Adviser Channel
If allocated，which Channel the assigned adviser is linked to
Lead _ID

Campaign_ID/Name

Exception reason

Is allocated adviser the PSI (Y/N)

Scope
* * * * Identify and expose all lead validation exceptions — not limited to the six exception reasons currently captured. The lead_validatoin_audit table records the full set of validation rule results (e.g. CAMPAIGN_EXIST, PSI_DETECTION, PSI_ACTIVE_CHECK, CUSTOMER_DECEASED, EXISTING_CUSTOMER, DEDUP, NAME_VALIDATION, etc.) and should be used as the primary data source for deriving validation outcomes.
Expose the missing fields listed above (Lead State, Date Validated, Allocation Status, Allocated Adviser, Adviser Channel) so that they are available for PFMI reporting consumption.
Data sourcing approach:
* * * * Validation rule pass/fail results and failure reasons → derive from the lead_validation_audit table
Lead metadata (lead_id, lead_source, lead_priority, customer name, etc.) → existing lead master table
Campaign metadata (campaign_id, campaign_name, campaign_status, etc.) → existing campaign table and sync campaign data from om
Allocation details (adviser, team) → to be identified during design (may come from allocation/assignment records)
Out of scope for this story:
* * The decision on whether to extend the existing exception table or create a new reporting table/view — this will be determined during technical design.
UI or front-end changes.


## 🎯 Acceptance Criteria (验收标准)
AC1: All validation rule outcomes from the audit table are surfaced in the exception/reporting output (not just the six currently captured reasons).
AC2: The output includes: Lead State (validation failed / passed), Date Validated, Allocation Status, Allocated Adviser, and Adviser Team.
AC3: Existing exception data fields (Lead Source, Channel, Campaign ID/Name, Lead ID, Lead Name/Surname, Lead Priority, Exception Code, Exception Reason) continue to be available.
AC4: The data is accessible by the PFMI team for import into their data warehouse.


## 📋 Definition of Ready (DOR) Checklist
# Default checklist
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

