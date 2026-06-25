# Comments - LEAD-124: Lead Validation Audit Trail – Persist All Validation Outcomes per Lead

此文件记录了 Jira Story [LEAD-124] 评审与设计过程中的讨论历史。

---

### 💬 评论人：Jiangtao Zhou (jiangtao.zhou@oldmutual.com)
📅 **时间**：2026-05-19T16:20:06.708+0200

 the following 4 questions need clarification from the business side：

Question 1: Business handling strategy when audit table write fails
If writing to the lead_validation_audit table fails (e.g., database connection error), should the lead's main allocation/processing flow continue or terminate?
* * Option A: Continue processing the lead (audit failure does not block business)
Option B: Terminate lead processing with an error (strong dependency on audit completeness)
Question 2: Audit record scope for duplicate leads
Each lead will generate audit records. For duplicate leads (e.g., same user, same campaign, repeated upload within a short period):
* * Should each duplicate lead generate a complete, independent set of audit records?
Or should only the first occurrence be fully audited, with subsequent duplicates marked as DUPLICATE and skip detailed validation?
Question 3: SKIPPED record granularity in Hard Stop scenarios
When a Hard Stop occurs (e.g., step 3 fails, and the next 7 steps are not executed), should the audit table generate one SKIPPED record per skipped rule (i.e., 7 separate records), or can they be merged into a single record (e.g., "Rules 4-10 skipped due to previous failure")?
Question 4: Audit data retention and archiving policy
How long should data in the lead_validation_audit table remain online queryable? (e.g., 3 months, 6 months, 1 year)
After the retention period expires, are the following allowed:
* * Deletion (physical delete)
Archiving to cold storage / data lake


---

### 💬 评论人：Cisca Van Zyl (cvanzyl6@oldmutual.com)
📅 **时间**：2026-05-19T16:47:31.312+0200

 My proposals - 1. Option A - Continue processing the lead even if audit write fails, but write reason for technical failure.. 2. Duplicates are still system events that need traceability first -occurrence be fully audited, with subsequent duplicates marked as DUPLICATe. Then no further validation required.  3.merged into a single record 4. 12 months - then archive ( never delete)


---

### 💬 评论人：Cisca Van Zyl (cvanzyl6@oldmutual.com)
📅 **时间**：2026-06-03T07:45:09.742+0200

Hi  , AC7 - add Channel Validation (PF vs Non‑PF)


---

