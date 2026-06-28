# Story - LEAD-189: Expose Lead closure reasons

## 📋 Jira Metadata
| Field | Value |
| :--- | :--- |
| **Jira Key** | `LEAD-189` |
| **Type** | `故事` |
| **Status** | `待办` |
| **Story Points** | `1` |
| **Parent Feature/Epic** | `LEAD-9` |
| **Labels** | `none` |
| **Components** | `none` |

## 📖 Original Description
As a reporting analyst
I want lead closure reasons to be exposed in the reporting dataset
So that I can understand why leads are closed and analyse patterns impacting conversion and performance


## 🎯 Acceptance Criteria (验收标准)
AC1. Closure Reason Availability
* * Each closed lead includes a closure reason field.
Closure reason is populated when a lead reaches a terminal/closed state.
AC2. Standardised Closure Reason Values
* Closure reasons are drawn from an agreed, standardised list (e.g., Not Interested, Unable to Contact, Converted, Duplicate, Invalid Lead).
C3. Closure Timestamp
* * Each closed lead includes a closure date/time, indicating when the lead was closed.
Closure timestamp aligns with the lead lifecycle/state tracking.
C4. Campaign & Allocation Linkage
* * Closure reasons are linked to:
* * * Campaign ID
Business channel / team
Financial adviser (FA)
Enables analysis of closure reasons by campaign and adviser/team.
AC5. Aggregation & Volume Reporting
* * Dataset supports aggregation of:
* * * Closed leads by closure reason
Closure reasons by campaign
Closure reasons by channel and FA
Closure reason counts reconcile to total closed lead counts.


## 📋 Definition of Ready (DOR) Checklist
*未明确配置 DOR Checklist*

💬 *暂无评审与讨论历史评论*

