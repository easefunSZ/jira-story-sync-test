# Story - LEAD-229: Audit & reporting of  AI Usage ( conversation guide)

## 📋 Jira Metadata
| Field | Value |
| :--- | :--- |
| **Jira Key** | `LEAD-229` |
| **Type** | `故事` |
| **Status** | `正在进行` |
| **Story Points** | `2` |
| **Parent Feature/Epic** | `LEAD-265` |
| **Labels** | `none` |
| **Components** | `none` |

## 📖 Original Description
As a compliance officer / platform owner,
I want all AI Conversation Guide usage to be audited and reportable,
So that I can ensure appropriate usage, monitor compliance with guidance-only rules, and track adoption and effectiveness of the AI feature.


## 🎯 Acceptance Criteria (验收标准)
C1 – AI Interaction Logging
Every time the AI Conversation Guide is accessed, the system must create an audit record capturing:
* * * * * Lead ID
Adviser ID
Timestamp
Campaign Type (must be MATURITY)
Trigger event (tooltip click / panel open)
AC2 – AI Request and Response Traceability
The system must log a traceable record of:
* * * * AI input dataset used (fields only, not sensitive raw values if restricted by policy)
Prompt version / template ID
AI response version/output ID
Correlation ID linking request → response → UI render
AC3 – Compliance Verification Logging
Each AI interaction must record compliance checks:
* * * Whether output passed compliance filter (Yes/No)
Whether any restricted content was detected (Yes/No)
If blocked or modified, reason code must be captured
AC4 – Usage Analytics Capture
The system must capture AI usage metrics including:
* * * Total AI interactions per adviser
Total AI interactions per campaign
Frequency of usage per lead
AC5 – Data Scope Compliance Audit
The audit log must confirm that only approved fields were used:
* * * Client Name
Maturity Date
Maturity Value
Any deviation from approved dataset must be logged as a compliance violation.
AC6 – UI Interaction Audit
Each AI usage event must log:
* * Tooltip click event
Panel open/close events
AC7 – Error and Failure Logging
If AI fails to generate or load:
* * * Error type (timeout, service failure, validation failure)
Fallback behaviour triggered
User-facing message shown
All failures must be included in reporting.
AC8 – Reporting Availability
AI usage data must be available via reporting layer or dashboard with filters for:
* * * * * Date range
Adviser
Campaign type
Channel (PFA, AFD, DFA)
Success vs failure interactions
AC9 – Regulatory Compliance Flagging
System must be able to flag and report:
* Any instance where AI attempted to provide advice or recommendations
AC10 – Role-Based Access Control
* * Only authorised users (compliance, platform ops, analytics) can access AI audit and reporting data
Advisers must not see system-level AI audit logs
AC11 – Audit Immutability
* * * AI audit records must be immutable once created
Updates or deletions are not permitted
Only append-only logging is allowed
AC12 – End-to-End Traceability
Each AI interaction must be traceable from:
* Lead creation → Lead acceptance → AI trigger → AI response → UI rendering → audit log
using a unique correlation ID.


## 📋 Definition of Ready (DOR) Checklist
*未明确配置 DOR Checklist*

💬 **[View Comments & Discussions (查看评审与讨论历史)](LEAD-229_comments.md)**

