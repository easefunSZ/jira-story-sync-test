# Story - LEAD-124: Lead Validation Audit Trail – Persist All Validation Outcomes per Lead

## 📋 Jira Metadata
| Field | Value |
| :--- | :--- |
| **Jira Key** | `LEAD-124` |
| **Type** | `故事` |
| **Status** | `正在进行` |
| **Story Points** | `8` |
| **Parent Feature/Epic** | `LEAD-62` |
| **Labels** | `oc_internal_review` |
| **Components** | `none` |

## 📖 Original Description
As a Product Owner / Operations Analyst
I want every validation step executed on each lead to be recorded with its outcome, timestamp, and failure reason
So that the full validation journey of every lead is traceable, auditable, and queryable within DAE/IG.
Background & Problem Statement
Currently in DAE, leads pass through multiple validation steps (PSI detection, PSI active/inactive check, customer deceased check, existing customer identification, name validation, deduplication, etc.), but none of these validation outcomes are persisted to a structured record. This means:
* * * * * It is impossible to determine whether a specific validation was executed for a given lead
It is impossible to know when a validation was executed
It is impossible to trace why a lead was rejected, passed, or flagged
Audit and compliance requirements cannot be met
The PFMi Reports team has no data source for validation reporting
Scope – Validation Rules Covered
This audit table must cover all validation rules from both Features:
Rule Code
Rule Name
Source Story
CAMPAIGN_VALIDATION
Campaign Existence & Status Validation
LEAD-60
LEAD_DEDUP_SAME_CAMPAIGN
Same-Campaign Duplicate Check
LEAD-90
LEAD_DEDUP_CROSS_CAMPAIGN
Cross-Campaign Duplicate Check
LEAD-90
NAME_VALIDATION
First Name / Surname Quality Check
LEAD-40
PSI_DETECTION
PSI Intermediary Detection
LEAD-57
PSI_ACTIVE_CHECK
PSI Active Status Check
LEAD-55/86
CUSTOMER_DECEASED
Deceased Customer Check
LEAD-58
EXISTING_CUSTOMER
Existing Customer Match
LEAD-59
Additional rules may be added as LEAD-65 (Configurable Rule Framework) evolves. The audit table must support extensibility without code changes.
Proposed Data Model:lead_validation_audit
Column
Type
Description
Example
id
BIGINT (PK, auto-increment)
Primary Key
1
lead_id
VARCHAR / BIGINT (FK)
Unique Identifier, link with lead master table
LD-20260518-001
lead_source
VARCHAR
lead source
Everlytic, MADM_Upload, MFC_OMIX
campaign_id
VARCHAR
campaign ID
20240423002
validation_rule_code
VARCHAR
validation rule code
CAMPAIGN_EXIST, CAMPAIGN_ACTIVE, PSI_DETECT, PSI_ACTIVE, CUSTOMER_DECEASED, EXISTING_CUSTOMER, NAME_VALIDATION, LEAD_DEDUP_SAME_CAMPAIGN, LEAD_DEDUP_CROSS_CAMPAIGN
validation_rule_name
VARCHAR
validation rule name
Campaign Existence & Status Validation
execution_order
INT
The execution order of this rule in the validation chain.
1, 2, 3...
validation_result
VARCHAR
validation result
PASS, FAIL, UNKNOWN, SKIPPED
is_hard_stop
BOOLEAN
is hard stop（Do not execute subsequent rules after a failure）
TRUE / FALSE
failure_reason
VARCHAR (nullable)
failure reason description
Campaign not found, Campaign inactive, Customer Deceased Indicator = Y, PSI Inactive
input_value
VARCHAR (nullable)
validation input value（for audit）
Campaign ID, PSI Code, ID No. e
output_value
VARCHAR (nullable)
validation response value
Active, Inactive, Y, N, Unknown
executed_at
TIMESTAMP
validation rule executed time
2026-05-18 10:23:45.123
executed_by
VARCHAR
executor（sys/user）
SYSTEM, BATCH_JOB_001
created_at
TIMESTAMP
record created time
2026-05-18 10:23:45.123
related_lead_id 
VARCHAR / BIGINT 
LEAD-90 AC2.3 It is required to record the existing leads matched during deduplication.

related_campaign_id 
VARCHAR / BIGINT 
LEAD-90 AC2.4/AC3.4 It is required to record the existing campaign ID that is matched.

match_criteria 
VARCHAR
LEAD-90 AC2.4 It is required to record the matching criteria.（like ID Number / Phone Number）

validation_result add ERROR value
VARCHAR
Distinguish between 'business validation failure (FAIL)' and 'system execution exception (ERROR)', such as API timeout.



## 🎯 Acceptance Criteria (验收标准)
AC
Description
AC-1
Each validation step for every lead must generate a record in the lead_validation_audit table.
AC-2
The record must contain: rule code, rule name, execution sequence, result (PASS/FAIL/UNKNOWN/SKIPPED), and execution timestamp.
AC-3
In Hard Stop scenarios, subsequent unexecuted rules must be merged into a single SKIPPED record (e.g., "Rules 4–10 skipped due to Hard Stop at Rule 3"), with the triggering rule code and failure reason documented.
AC-4
Validation rule codes and names must come from configurable rule definitions.
AC-5
Audit records must be immutable (append-only), supporting historical traceability.
AC-6
Support querying the complete validation chain by lead_id
AC-7
Cover all validation rules under lead4 (PSI Detection, PSI Liveness, Deceased Client, Existing Client) and lead62 (Campaign Validation, Name Validation, Deduplication).
AC-8
Audit write failure handling: If writing to the lead_validation_audit table fails (e.g., database connection error), the lead's main processing/allocation flow must continue (audit failure does not block business). The system must log the technical failure reason for troubleshooting.
AC-9
Duplicate lead audit: The first occurrence of a lead must be fully audited with all validation records. Subsequent duplicate leads must be marked with result = DUPLICATE and no further validation is required — duplicates are still system events that need traceability.
AC-10
Data retention policy: Audit data must remain online queryable for 12 months. After 12 months, data must be archived (moved to cold storage / data lake). Data must never be deleted (physical deletion is not permitted).


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
* [done] OC: contract if no API exists
* [done] OC: table readiness for data integration
* [skipped] OC: UI design

💬 **[View Comments & Discussions (查看评审与讨论历史)](LEAD-124_comments.md)**

