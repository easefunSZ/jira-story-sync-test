# Comments - LEAD-49: File level: Failure reasons  & Notification (IT)

此文件记录了 Jira Story [LEAD-49] 评审与设计过程中的讨论历史。

---

### 💬 评论人：Embrenchia Snyman (embrenchia.snyman@oldmutual.com)
📅 **时间**：2026-04-14T09:29:33.027+0200

Please indicate planned quarter (Quarter Prioritized) @{{reporter}}


---

### 💬 评论人：Emil Schnabel (emil.schnabel@oldmutual.com)
📅 **时间**：2026-04-30T09:52:35.672+0200

* *  must confirm receiver email (inbox)
OC will analyze the Snowflake payload to check the current information
All will be done on 30/04/2026


---

### 💬 评论人：Cisca Van Zyl (cvanzyl6@oldmutual.com)
📅 **时间**：2026-05-04T17:37:19.501+0200

This cover File/API received successfully & Notification to IT. As for  Record count integrity check = 
* Yu Dan stated that the team is analyzing the gap between new requirements and the existing system, including the need to record additional data at each stage and update payloads with information such as total lead quantity/record count   and file name. Will this be covered now?
 


---

### 💬 评论人：Cisca Van Zyl (cvanzyl6@oldmutual.com)
📅 **时间**：2026-05-04T17:40:09.616+0200

No feedback received from Priya Dhanapune on required mailbox details 


---

### 💬 评论人：Dan Yu (dan.yu@oldmutual.com)
📅 **时间**：2026-05-06T16:31:27.615+0200

 
I have updated the verification result in LEAD-77 and summarise here as well. Based on the SQL query results, the current reasons captured in the DAE leads exception table include:
* * * * * * Sales code not valid
Adviser status is inactive
Adviser not provisioned on InteGreat
Campaign code/name not registered in InteGreat
Customer is deceased
Inactive campaign
These reasons are primarily related to data validation and business rule checks (adviser eligibility, campaign validity, customer status).
Allocation failures are not currently included in the exception table.
Therefore, total lead quantity/record count   and file name  are NOT included in this story – because this story is only for email notification based on the existing exception table. Capturing those counts would require additional development (e.g., modifying the ingestion pipeline to count records before validation failures occur). That is out of scope for this story.


---

### 💬 评论人：Cisca Van Zyl (cvanzyl6@oldmutual.com)
📅 **时间**：2026-05-06T19:20:24.386+0200

 
Thank you. 
Hi Yu, thank you.
* * Correct - This story only covers file-level ingestion failure detection and alerting after retries, not record-level processing or reconciliation metrics.
Upon reviewing the feature… I note The feature only defines file-level success/failure visibility and record-level outcome tracking, but it does not explicitly  state requirement for total lead counts or reconciliation metrics per file. Those would require additional ingestion metadata tracking not currently specified in scope.
 Implication
To support additional requirement, a new or enhanced solution would be needed to:
* * * Capture file-level metadata at ingestion stage (e.g. file name, source, total record count)
Persist total record counts before validation begins
Optionally extend logging to include ingestion failures (not just validation failures)
 And this will not happen in this Sprint.


---

### 💬 评论人：Cisca Van Zyl (cvanzyl6@oldmutual.com)
📅 **时间**：2026-05-13T15:38:34.712+0200

Hi  Progress update:  1x Outstanding items to complete Lead 49:
* OC to complete end-to end- testing.
* *  The test folder is not yet on the shared drive. 2. The dev environment cannot access the S3 bucket. 3. the dev environment hasn't been configured with the dev database environment. Therefore,  verification is not an end-to-end test process; it is a single-point verification with email notification.
Dependancy  & Blocker : Access to Pre-prod server. Kashief has followed up with Mischak MASHILOANE to expedite this request. 


---

### 💬 评论人：Embrenchia Snyman (embrenchia.snyman@oldmutual.com)
📅 **时间**：2026-06-02T18:15:32.369+0200

Release 13.2 (Blue) 28 May was cancelled due to scope changes and lack of readiness. All associated tickets are re-assigned to Release 13.2 (Blue 4 June 2026)


---

### 💬 评论人：Embrenchia Snyman (embrenchia.snyman@oldmutual.com)
📅 **时间**：2026-06-05T07:44:32.512+0200

BLUE deployment completed successfully.
Ownership has been assigned to the Scrum Master to coordinate business validation.
Before this item can be considered for GREEN:
* * * Business testing must be completed (or formally waived)
Product Owner approval obtained
Business Testing Sign Off updated to Signed Off
Once complete, the item may be included in a GREEN release.


---

