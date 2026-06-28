# Story - LEAD-206: Validation Rule Registry — Centralized Rule Definition & Management

## 📋 Jira Metadata
| Field | Value |
| :--- | :--- |
| **Jira Key** | `LEAD-206` |
| **Type** | `故事` |
| **Status** | `Analysis` |
| **Story Points** | `3` |
| **Parent Feature/Epic** | `LEAD-4` |
| **Labels** | `none` |
| **Components** | `none` |

## 📖 Original Description
Description
As a business analyst
I want a centralized rule registry that defines all validation rules, their properties, dependencies, and scope
So that the development team has a single source of truth for implementing the validation pipeline, and future rule changes can be managed without modifying the execution logic
Background
Validation rules are currently defined across two Features with each Story describing individual rule logic independently. There is no unified rule registry or execution orchestration definition. Without an explicit execution order:
* * * Development teams may implement rules in inconsistent sequences
The execution_order field in the LEAD-124 audit table lacks an authoritative source
The Phase 2 configurable framework has no Phase 1 rule metadata foundation
1. Rule Registry
validation_rule_registry table structure:
Field
Type
Description
rule_code
VARCHAR (PK)
Unique rule identifier
rule_name
VARCHAR
Rule name
execution_order
INT
Execution sequence (globally unique)
is_hard_stop
BOOLEAN
Whether failure halts subsequent rules
is_enabled
BOOLEAN
Whether rule is active (Phase 2)
dependency_rule_code
VARCHAR (nullable)
Prerequisite rule
dependency_condition
VARCHAR (nullable)
Dependency condition
2. Execution Order
#
Rule Code
Rule Name
Story
Hard Stop
Dependency
Scope
1
CAMPAIGN_VALIDATION
Campaign Existence & Status Check
LEAD-60
Yes
None
All Leads
2
NAME_VALIDATION
Name Data Quality Check
LEAD-40
No
Step 1 = PASS
All Leads
3
EXISTING_CUSTOMER
Existing Customer Identification
Existing Logic
No
Step 1 = PASS
All Leads
4
CUSTOMER_DECEASED
Deceased Customer Check
LEAD-58
Yes
Step 3 = Y
Existing Customers Only
5
PSI_ENRICHMENT
PSI Auto-Enrichment & Mismatch Handling
LEAD-84
No
Step 3 = Y AND (Lead has no PSI OR Lead PSI ≠ Customer PSI)
Existing Customers Only
6
PSI_DETECTION
PSI Detection, Format Validation & Storage
LEAD-57 / LEAD-230
No
After Step 5 completes (existing customers) OR after Step 3 = N (new customers)
All Leads (incl. New Customers)
7
PSI_ACTIVE_CHECK
PSI Active Status Check
LEAD-55 / LEAD-230
No
Step 6 = Y (PSI exists)
All Leads (where PSI present)
8
DEDUP_SAME_CAMPAIGN
Same-Campaign Deduplication
LEAD-90
Yes
Step 1 = PASS
All Leads
9
DEDUP_CROSS_CAMPAIGN
Cross-Campaign Duplicate Lead Detection
LEAD-90
No
Step 8 = PASS
All Leads
10
AUDIT_PERSIST
Validation Result Persistence & Reporting
LEAD-124
N/A
Always Executes
All Leads
Note: The business logic sequence below represents the recommended order based on rule dependencies. The development team may optimize the physical execution order for performance, provided all dependency constraints and business outcomes are preserved.


## 🎯 Acceptance Criteria (验收标准)
#
Acceptance Criteria
AC1
Each rule in the registry must include the following attributes: Rule ID, Rule Name, Associated Story, Hard Stop (Y/N), Dependency Conditions, and Applicable Scope
AC2
The rule registry must cover all validation categories: Campaign (CAM), Channel (CHA), Name (NAM), Deceased (DEC), and PSI
AC3
Each rule must clearly define its dependency relationships (e.g., "requires EXISTING_CUSTOMER result before execution"), but must not dictate the physical execution order
AC4
The rule registry must support independent updates (add / modify / deactivate rules) without impacting the existing pipeline logic


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
* [done] OC: documentation and payload provisioning
* [skipped] OC: contract if no API exists
* [skipped] OC: table readiness for data integration
* [skipped] OC: UI design

💬 **[View Comments & Discussions (查看评审与讨论历史)](LEAD-206_comments.md)**

