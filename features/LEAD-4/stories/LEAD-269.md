# Story - LEAD-269: Unified Exception Handling for Validation & Allocation

## 📋 Jira Metadata
| Field | Value |
| :--- | :--- |
| **Jira Key** | `LEAD-269` |
| **Type** | `故事` |
| **Status** | `Analysis` |
| **Story Points** | `5` |
| **Parent Feature/Epic** | `LEAD-4` |
| **Labels** | `none` |
| **Components** | `none` |

## 📖 Original Description
As a PF business user and operations analyst
I want a unified exception handling mechanism that captures all validation failures and allocation failures during lead processing, and writes them to the Exception Report with standardised exception reasons
So that all exception leads are traceable, reportable, and actionable — whether caused by business rule failures or allocation-level issues.
Background & Problem Statement
* * * * The current Exception Report only captures 5 exception reasons (sales code not valid, adviser status is inactive, adviser not provisioned on IG, campaign code/name not registered in IG, custoemr is deceased, inactive campaign)
With LEAD-4 (PSI & Customer Validation) and LEAD-62 (Lead & Campaign Validation) introducing new validation rules, multiple new exception scenarios have been identified but are not yet mapped to the Exception Report
There is no single place that defines the complete list of exception reasons and their triggering conditions
Some exceptions are generated during validation (pre-allocation), while others occur during allocation (post-validation). Both need to be captured consistently
In Scope
* * * Define and maintain the complete Exception Reason catalogue for all validation and allocation stages
Ensure every exception scenario writes a record to the Exception Report with a standardised exception_reason
Cover exceptions from both pre-allocation validation (LEAD-4, LEAD-62 rules) and allocation-stage failures
Complete Exception Reason Catalogue
A. Campaign Validation Exceptions
#
Exception Reason
Source Story
Hard Stop
Trigger Condition
1
Campaign not found — Campaign code/name not registered in IG
LEAD-60
Yes
Campaign ID/name does not exist in IG
2
Inactive campaign
LEAD-60
Yes
Campaign status = Inactive
3
Campaign expired — outside start/end dates
LEAD-60
Yes
Current date is outside campaign valid date range
B. Name Validation Exceptions
#
Exception Reason
Source Story
Hard Stop
Trigger Condition
4
Name Validation Failed — Both First Name and Surname are empty
LEAD-40
No
First Name = null AND Surname = null
C. Customer Validation Exceptions
#
Exception Reason
Source Story
Hard Stop
Trigger Condition
5
Customer Deceased
LEAD-58
Yes
Deceased Indicator = Y
6
Multiple Matching Customers Identified
LEAD-232
No
Surname + Cellphone matches multiple customer records
D. PSI Validation Exceptions
#
Exception Reason
Source Story
Hard Stop
Trigger Condition
7
PSI Sales Code Invalid — Length ≠ 6 or non-numeric
LEAD-231
Yes
PSI format validation fails
8
Invalid PSI Channel — PSI does not belong to PF SA channel
LEAD-55
No
PSI channel ≠ PF SA
9
Inactive PSI — PSI belongs to PF channel but is Inactive
LEAD-55
No
PSI channel = PF but status = Inactive
10
PSI Incomplete/Invalid — Customer exists but PSI is invalid
LEAD-84
No
PSI auto-populate finds invalid/incomplete PSI on customer record
11
Duplicate Customer Match during PSI Auto-Population
LEAD-84
No
PSI auto-populate matches multiple customer records
12
PSI Mismatch — Lead PSI ≠ Customer PSI
LEAD-84
No

E. SelectedAdvisor Validation Exceptions
#
Exception Reason
Source Story
Hard Stop
Trigger Condition
13
SelectedAdvisor salesCode not found in IG
LEAD-234
No
want2Talk2PSI = false AND selectedAdvisor.salesCode not in intermediary list
14
SelectedAdvisor Inactive
LEAD-234
No
selectedAdvisor exists but status = Inactive
15
Customer Declined PSI Contact
LEAD-234
No

F. Deduplication Exceptions
#
Exception Reason
Source Story
Hard Stop
Trigger Condition
16
Same-Campaign Duplicate Lead
LEAD-90
Yes
Duplicate lead detected within the same campaign
17
Cross-Campaign Duplicate Lead
LEAD-90
No
Duplicate lead detected across different campaigns
iic_crm_leads_exception_report is supposed to add two more column: exception_category,is_hard_stop
Exception category and Reason Mapping
exception_category
reason
is_hard_stop
CAMPAIGN
Campaign not found
1
CAMPAIGN
Inactive campaign
1
CAMPAIGN
Campaign expired
1
NAME
Name Validation Failed — Both First Name and Surname are empty
1
CUSTOMER
Customer Deceased
1
CUSTOMER
Multiple Matching Customers Identified
0
PSI
PSI Sales Code Invalid
1
PSI
Invalid PSI Channel
0
PSI
Inactive PSI
0
PSI
PSI Incomplete/Invalid
0
PSI
Duplicate Customer Match during PSI Auto-Population
0
PSI
PSI Mismatch — Lead PSI ≠ Customer PSI
0
SELECTED_ADVISOR
SelectedAdvisor salesCode not found
0
SELECTED_ADVISOR
SelectedAdvisor Inactive
0
SELECTED_ADVISOR
Customer Declined PSI Contact
0
DEDUP
Same-Campaign Duplicate Lead
1
DEDUP
Cross-Campaign Duplicate Lead
0
These are existing leads dispatch failure reason without category in exception table
Sales code not valid
1
Adviser status is inactive
1
Adviser not provisioned on IG
1
Campaign code/name not registered in IG
1
Custoemr is deceased, inactive campaign
1
is_hard_stop=1 -> excpetion report, is_hard_stop=0 -> audit report


## 🎯 Acceptance Criteria (验收标准)
AC
Description
AC1
All exception reasons listed in the catalogue above must be supported and written to the iic_crm_leads_exception_report table when triggered
AC2
Each exception record must include: leads_id, segment, source, SOURCE_NAME, reason (standardised exception reason from catalogue)
AC3
When a Hard Stop exception is triggered, the lead must be marked as "Validation Failed" and no subsequent validation rules are executed
AC4
When a non-Hard Stop exception is triggered, the exception is recorded but the lead continues processing through remaining validation rules


## 📋 Definition of Ready (DOR) Checklist
*未明确配置 DOR Checklist*

💬 *暂无评审与讨论历史评论*

