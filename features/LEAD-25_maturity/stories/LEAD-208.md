# Story - LEAD-208: Master rule matrix

## 📋 Jira Metadata
| Field | Value |
| :--- | :--- |
| **Jira Key** | `LEAD-208` |
| **Type** | `故事` |
| **Status** | `正在进行` |
| **Parent Feature/Epic** | `LEAD-25` |
| **Labels** | `none` |
| **Components** | `none` |

## 📖 Original Description
This rule matrix is used as a single source of truth to ensure all feature behaviour is consistently implemented, tested, governed, and traceable across requirements, development, QA, and compliance.
Legend
* * * * * * * US1 = Enrichment
US2 = Leads Pool Display
US3 = Post-Acceptance Visibility
US4 = Conditional Rendering
US5 = AI Conversation Guide
US6 = Security, Audit & Resilience
US7 = Audit & Reporting (Enrichment + AI)


## 🎯 Acceptance Criteria (验收标准)
Rule ID
Rule Name
Rule Description
Applies To (User Stories)
Key Data Elements
System Layer
R1
Campaign Classification Rule
System must identify whether a lead is MATURITY or NON-MATURITY at ingestion
US1, US2, US3, US4, US5, US6, US7
Campaign Type, Campaign ID
Ingestion Layer
R2
Pre-Allocation Enrichment Rule
All maturity leads must be enriched before allocation
US1
Policy Type, Maturity Date, Maturity Value, Retention Note
Enrichment Service
R3
Enrichment Failure Handling Rule
Enrichment failure must not block lead processing
US1, US6, US7
Error Code, Failure Reason
Processing Layer
R4
Leads Pool Data Minimisation Rule
Only Campaign Information is visible pre-acceptance
US2
Retention Note
UI Layer
R5
Post-Acceptance Data Reveal Rule
Full maturity data is only visible after lead acceptance
US3
 Maturity Date, Value
UI + Access Layer
R6
Conditional Feature Rendering Rule
Maturity features only apply to valid maturity leads with data
US4, US5
Campaign Type, Data Availability
UI Layer
R7
Channel Scope Rule
Feature only available for PFA, AFD, DFA channels
US4, US6
Channel Type
Platform Layer
R8
AI Trigger Eligibility Rule
AI only triggers when lead is accepted and data exists
US5
Lead Status, Campaign Type
AI Trigger Layer
R9
AI Data Restriction Rule
AI must use only approved dataset fields
US5, US7
Name, Maturity Date, Value
AI Input Layer
R10
AI Output Compliance Rule
AI must not provide advice or recommendations
US5
AI Response Content
AI Output Layer
R11
AI UI Behaviour Rule
AI must render as inline expandable panel only
US5
UI Component Type
UI Layer
R12
Mandatory Disclaimer Rule
AI disclaimer must always be displayed
US5
Disclaimer Text Version
UI Layer
R13
Role-Based Access Control Rule
Only authorised advisers can view maturity data and AI
US3, US5, US6
User Role, Ownership
Security Layer
R14
Audit Logging Rule (Enrichment)
All enrichment events must be logged
US1, US6, US7
Lead ID, Status, Timestamp
Audit Layer
R15
Audit Logging Rule (AI Usage)
All AI interactions must be logged end-to-end
US5, US6, US7
Adviser ID, Lead ID, Event Type
Audit Layer
R16
Traceability Rule
End-to-end correlation ID required across lifecycle
US1, US5, US6, US7
Correlation ID
Observability Layer
R17
Reporting Availability Rule
Enrichment + AI data must be reportable
US6, US7
Metrics, Status, Usage Stats
Reporting Layer
R18
Audit Immutability Rule
Audit records must be append-only and immutable
US6, US7
Audit Logs
Compliance Layer
R19
Regression Protection Rule
Non-maturity leads must remain unaffected
US2, US4, US6
Campaign Type
Platform Layer


## 📋 Definition of Ready (DOR) Checklist
*未明确配置 DOR Checklist*

💬 *暂无评审与讨论历史评论*

