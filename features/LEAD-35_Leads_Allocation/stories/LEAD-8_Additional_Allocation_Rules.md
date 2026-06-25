# Story - LEAD-8: Additional Allocation Rules

## 📋 Jira Metadata
| Field | Value |
| :--- | :--- |
| **Jira Key** | `LEAD-8` |
| **Type** | `Feature` |
| **Status** | `打开` |
| **Parent Feature/Epic** | `LEAD-35` |
| **Labels** | `DOR_FEAT` |
| **Components** | `Leads Fix` |

## 📖 Original Description
Description
Ensure all allocation rules are in place including High Leads rules
Enhance PF leads rule allocation  functionality.
Providing PF with the ability to configure (amend ) and manage (track) (existing)) lead business allocation  rules for specified users.
Context
Currently when changes to lead allocation allocation rules are required, business has to raise a backlog request, this results in business unable to manage leads effectively based on changing priorities
This change requires and interface that allows users within a specified role, the ability to change allocation rules as required within all PF distribution channels, with the ability to track these changes, within the PF context
Must take into account adviser availability when allocating. 

Rules are grouped by:
With/without advisors
Allocation group/No allocation groups
With postal code/without postal code
Income bands
Considerations
-Minimize no of screen and consider dynamic display
-Minimize capturing
-Consider dynamic field display
-Rule for config
-Impact to campaigns
-Field, user error messages
-Impact on running PSI check within IG
NFR considerations
-Real time updates vs batch updates-time to reflect changes made -When rule changes are being made rule must not accessible for changes and user attempting must be made aware.
-Locking for change, when a user has opened a field for change, or a rule change has been submitted but not reflected yet
Requires a solution design
Requires OC input
Requires a UI design
Impacts:
E.G. Currently when advisers are in an unavailable status, they are not excluded from the leads allocation logic
Value Add/Benefit
Improved accuracy of  leads provision to correct groups.
Improved turn around of lead allocation to groups
Improved management of rule effectiveness.
To Business
Business users do not have to log a build request and follow the build process, which will improve turn around time for rule amendments


## 🎯 Acceptance Criteria (验收标准)
AC1) Provision of access to users within a specified role to Rule config UI.
AC2) Required fields for specified users to make changes to required rules.
AC3) Rule changes applied and amended/new rules visible to all PF roles who both view rules and have to apply rules or who to execute within rules
*AC4)*An audit trail of changes made to rules, including but not limited, previous rule, New rule, Date and Time stamp of change, role and person who made change, via IG, visible to specified users who can make changes.


## 📋 Definition of Ready (DOR) Checklist
​# Default checklist
​--- DOR_FEAT
​* [open] Feature goal
​* [open] 5 - 7 stories
​* [open] Acceptance criteria
​* [open] OC input
​* [open] Arch Solution design
​* [open] UX journey map

💬 *暂无评审与讨论历史评论*

