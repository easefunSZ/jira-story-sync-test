# Comments - LEAD-206: Validation Rule Registry — Centralized Rule Definition & Management

此文件记录了 Jira Story [LEAD-206] 评审与设计过程中的讨论历史。

---

### 💬 评论人：Dan Yu (dan.yu@oldmutual.com)
📅 **时间**：2026-06-03T13:57:09.697+0200

 A question about the PSI validation scope for new customers.
Currently in LEAD-206, all PSI-related rules (Detection, Active Check, Enrichment) are scoped as "EXISTING_ONLY" — meaning they are skipped entirely for new customers. But what about the scenario: new customer + Lead has a PSI code? Should the system still validate whether that PSI is active and run PSI Detection to persist the PSI value?
Could you confirm


---

### 💬 评论人：Cisca Van Zyl (cvanzyl6@oldmutual.com)
📅 **时间**：2026-06-03T14:10:45.201+0200

 Yes, applicable to new customer also. If a PSI exists on the lead ( new customer)→ run PSI rules. 


---

### 💬 评论人：Dan Yu (dan.yu@oldmutual.com)
📅 **时间**：2026-06-03T14:52:40.615+0200

Hi as you create a new story 230 to include PSI validation for new customer with PSI, I updated the validation order accordingly to include new customer, please check the order in lead206 and let me know if you have any discrepancy on it, thank you.


---

### 💬 评论人：Cisca Van Zyl (cvanzyl6@oldmutual.com)
📅 **时间**：2026-06-04T03:18:21.383+0200

Hi Yu
What framework is used for your technical sequencing model? I am unsure whether the business validation sequence should drive the technical execution sequence, or whether the technical design should determine the optimal processing order.
My  additional input from a  business-driven sequencing model perspective:
Business wants:
Validate the lead
1.  CHANNEL_VALIDATION (Hard Stop)
2.  NAME_VALIDATION (Partial Hard Stop)
Ensure minimum information exists to process the lead.
Lead is only linked to PF channel
Identify the customer
1.  EXISTING_CUSTOMER check
Many downstream rules depend on this
Run compliance checks
1.  CUSTOMER_DECEASED
* * *   Right after existing check
  It's a hard stop
  Prevents further processing
Run business validations ( Campaign,PSI)
* * *   Campaign context first
  Dedup (filtering)
  PSI (more complex logic)
Campaign Validation
1.  CAMPAIGN_PRESENCE_CHECK
2.  CAMPAIGN_VALIDATION (Hard Stop if present)
Conditional validation. Skip if no campaign supplied.
Campaign Validation should not be the first validation because some valid leads will not have a campaign.
Deduplication
1.  DEDUP lead_SAME_CAMPAIGN (if campaign exists)
Dedup eliminates unnecessary processing
PSI validation
1.  PSI_DETECTION
2.  PSI_FORMAT_VALIDATION  (6digit code)(Hard Stop)
3.   PSI_ENRICHMENT (existing only + condition)
4.   PSI_ACTIVE_CHECK (Hard Stop)
Audit the outcome
Thanks
Cisca


---

### 💬 评论人：Dan Yu (dan.yu@oldmutual.com)
📅 **时间**：2026-06-04T04:38:34.637+0200

 
Thanks for the detailed proposal - really helpful to see it structured from a business logic perspective. Here's my feedback:
First, to answer your question — business-driven or tech-driven?
What we are defining in the PRD is the business logic sequence — the order that makes sense from a business rules perspective. The dev team will design their own physical execution order based on technical considerations (e.g., performance optimization, API call batching, parallel processing). These two may differ, and that's expected. Our job is to ensure the business rules and their dependencies are clearly defined — how the dev team implements them technically is their design decision, as long as the business outcomes are preserved.
Points I agree with:
* * * CHANNEL_VALIDATION as Step 1 — Makes sense as the first gate. I already have CHA-001 in the rule matrix but missed it in the execution sequence. Will add it.
DEDUP before PSI — Agree. No point running PSI validation (incl. external API calls) on duplicate leads. More efficient to dedup first.
PSI_FORMAT_VALIDATION as a separate step — Happy to split it out from PSI_DETECTION for clarity.
Points that need clarification:
* CAMPAIGN_VALIDATION position:
I understand your reasoning — from a business perspective, not all leads originate from campaigns. However, from a technical design perspective, every lead is assigned a campaign ID by the system (including non-campaign leads). Therefore:
* * If campaign ID is empty/null → this is a data anomaly and should go directly to the exception table — this check should happen early
If campaign ID is present but campaign is inactive/invalid → this is a business validation that can sit later in the sequence as you proposed
So I'd suggest we keep it as two steps, but position them differently:
* * Early (Step 2): CAMPAIGN_PRESENCE_CHECK — Is campaign ID populated? If null → exception table (data quality issue)
Later (Step 5/6): CAMPAIGN_STATUS_VALIDATION — Is the campaign active and valid? If inactive → hard stop
Does this work for you? It addresses both concerns — catching data anomalies early while not blocking valid non-campaign leads unnecessarily.
* PSI order — DETECTION → FORMAT → ENRICHMENT → ACTIVE:
In my current design, ENRICHMENT comes before DETECTION because for existing customers without PSI, we first try to enrich from the customer record, then detect/validate. If we flip the order, an existing customer with no PSI would fail at DETECTION before we get a chance to enrich it. Two options:
* * Option A: ENRICHMENT → DETECTION → FORMAT → ACTIVE (enrich first, then validate)
Option B: DETECTION → if missing & existing customer → ENRICHMENT → FORMAT → ACTIVE (your proposal — add a conditional branch)
I'm leaning towards Option A as it's simpler, but open to discussion.
Proposed next step:
Can we schedule a quick 30-min sync to finalize the sequence? I have a merged rule matrix (17 rules covering both existing and new customer PSI scenarios incl. LEAD-230) ready to share for your review beforehand.


---

### 💬 评论人：Cisca Van Zyl (cvanzyl6@oldmutual.com)
📅 **时间**：2026-06-04T05:17:43.155+0200

From: Dan Yu (Jira) <jira@oldmutualig.atlassian.net>
Sent: Thursday, 04 June 2026 04:39
To: Cisca Van Zyl <CVanZyl6@oldmutual.com>
Subject: [JIRA] Dan Yu mentioned you on 
This email originates from an external source. Stop and think before you click!
Dan Yu mentioned you on a work item


---

