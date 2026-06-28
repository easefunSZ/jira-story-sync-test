# Story - LEAD-7: Lead Allocation : Rules 

## 📋 Jira Metadata
| Field | Value |
| :--- | :--- |
| **Jira Key** | `LEAD-7` |
| **Type** | `Feature` |
| **Status** | `打开` |
| **Story Points** | `5` |
| **Parent Feature/Epic** | `LEAD-35` |
| **Labels** | `DOR_FEAT` |
| **Components** | `Leads Fix` |

## 📖 Original Description
Rule 1:Adviser Availability Management
When advisers are unavailable, due to leaving the business or makes themselves unavailable, leads should not be allocated to them.
Context:
The “unavailable adviser” status is currently not included in the lead allocation logic, which impacts both customer and adviser experience. (Feedback from previous architect)
Rule 2
Ensure all allocation rules are in place including High Leads rules
Rule 3
Ensuring that the sla for leads for  hot leads is correct, currently it expires prior to adviser actioning it.
P0tential Rule4, to be reviewed with business this was a feature MFC cloned onto our board which I removed.
“Where a hot lead is received for a customer who already has an active lead in DAE, a new lead must not be created.
Instead:
* * A hot lead indicator/notification must be displayed against the existing customer/lead.
The existing lead must be prioritised to the top of the leads list to ensure immediate attention.”
* Lead Creation Rules
* * * When a hot lead is received for a customer with an existing active lead, no new lead is created in DAE.
The system correctly identifies an active lead client before applying hot lead logic.
Hot leads for customers without an active lead continue to create a new lead as per existing rules.
Hot Lead Indicator
* * * A clear hot lead indicator or notification is displayed on the existing lead/customer record.
The indicator is visually distinguishable from standard leads.
The indicator includes relevant context (e.g. source = Everlytic, date/time received).
Lead Prioritisation
* * * Leads with an active hot lead indicator are automatically prioritised to the top of the leads list.
Re-prioritisation occurs in real time or within an acceptable processing window.
Sorting and filtering functionality continues to work without removing hot lead prioritisation.
Lead Creation Rules
* * * When a hot lead is received for a customer with an existing active lead, no new lead is created in DAE.
The system correctly identifies an active lead client before applying hot lead logic.
Hot leads for customers without an active lead continue to create a new lead as per existing rules.
Hot Lead Indicator
* * * A clear hot lead indicator or notification is displayed on the existing lead/customer record.
The indicator is visually distinguishable from standard leads.
The indicator includes relevant context (e.g. source = Everlytic, date/time received).
Lead Prioritisation
* * * Leads with an active hot lead indicator are automatically prioritised to the top of the leads list.
Re-prioritisation occurs in real time or within an acceptable processing window.
Sorting and filtering functionality continues to work without removing hot lead prioritisation.
Lead Creation Rules
* * * When a hot lead is received for a customer with an existing active lead, no new lead is created in DAE.
The system correctly identifies an active lead client before applying hot lead logic.
Hot leads for customers without an active lead continue to create a new lead as per existing rules.
Hot Lead Indicator
* * * A clear hot lead indicator or notification is displayed on the existing lead/customer record.
The indicator is visually distinguishable from standard leads.
The indicator includes relevant context (e.g. source = Everlytic, date/time received).
Lead Prioritisation
* * * Leads with an active hot lead indicator are automatically prioritised to the top of the leads list.
Re-prioritisation occurs in real time or within an acceptable processing window.
Sorting and filtering functionality continues to work without removing hot lead prioritisation.”


## 🎯 Acceptance Criteria (验收标准)
* * * * * * * * * The system must only allocate leads to advisers who are both Active and Available
Advisers marked as Inactive (e.g., left the business) must be automatically excluded from all lead allocation processes
Advisers marked as Unavailable (temporarily) must not receive new lead allocations during the unavailable period
The allocation engine must dynamically evaluate adviser status and availability at the time of assignment
The system must prevent manual allocation of leads to advisers who are inactive or unavailable (or require explicit override with audit tracking)
Any existing open leads assigned to advisers who become inactive or unavailable must be identifiable for reassignment
The system must ensure no lead remains unallocated due to adviser unavailability
Changes to adviser status or availability must take immediate effect in allocation rules
The system must provide visibility and traceability of allocation decisions, including exclusion reasons


## 📋 Definition of Ready (DOR) Checklist
​# Default checklist
​--- DOR_FEAT
​* [open] Feature goal
​* [open] 5 - 7 stories
​* [open] Acceptance criteria
​* [open] OC input
​* [open] Arch Solution design
​* [open] UX journey map

💬 **[View Comments & Discussions (查看评审与讨论历史)](LEAD-7_rules_comments.md)**

