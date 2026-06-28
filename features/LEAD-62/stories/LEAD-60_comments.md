# Comments - LEAD-60: Campaign Existence & Status Validation

此文件记录了 Jira Story [LEAD-60] 评审与设计过程中的讨论历史。

---

### 💬 评论人：Embrenchia Snyman (embrenchia.snyman@oldmutual.com)
📅 **时间**：2026-04-14T09:29:33.807+0200

Please indicate planned quarter (Quarter Prioritized) @{{reporter}}


---

### 💬 评论人：Tracey Lee Craig (tcraig@oldmutual.com)
📅 **时间**：2026-05-13T13:07:51.941+0200

  We will require test data, with Active  campaigns and inactive.
This should match the definition of  an active campaign stated in story.
The same campaign data could be used, if the the campaign is set to Inactive to test the rest of the scenario’s


---

### 💬 评论人：Chan Ke (chan.ke@oldmutual.com)
📅 **时间**：2026-06-15T04:28:59.603+0200

  thanks ,In QA env，I can create different status campaign，it is done~


---

### 💬 评论人：Chan Ke (chan.ke@oldmutual.com)
📅 **时间**：2026-06-16T04:58:35.331+0200

Confirmed with the BA and Dev team on June 15th:
* * Regarding SQS scenarios, as well as the scenario where an adviser creates a campaign and selects a customer to convert into a lead, these will be completed in SP6.3. The remaining items will be continuously delivered in subsequent iterations.
Regarding the AC mentioning the flow when there is no campaign: We confirmed a shared understanding that during mandatory validation, the system will validate normally; however, in scenarios where a campaign is not required, this validation logic will not block the process and will allow it to pass through normally.


---

### 💬 评论人：Dan Yu (dan.yu@oldmutual.com)
📅 **时间**：2026-06-17T12:29:36.183+0200

Hi  
The current rule requires Campaign Status = Active AND current date is between start/end dates. However, we found that adviser-created campaigns do not have mandatory start/end dates (unlike Campaign Manager-created campaigns which require them).
For adviser campaigns with NULL start/end dates that default to Active status:
* * Option A: Accept as valid — only check Status = Active, skip date validation when dates are NULL. Advisers can create leads under these campaigns.
Option B: Update business rule — set campaigns with NULL dates to "Pending" status, requiring dates before activation.
Please confirm which approach should we follow?


---

### 💬 评论人：Tracey Lee Craig (tcraig@oldmutual.com)
📅 **时间**：2026-06-17T14:05:18.840+0200

 Happy with Option A


---

### 💬 评论人：Automation for Jira (undefined)
📅 **时间**：2026-06-18T08:51:31.747+0200

Technical Sign-Off
I, Jiazhi Li, hereby attest that:
• Development has been completed
• Code review has been completed and approved
• Unit testing has been completed successfully
• No known critical defects prevent progression
• The acceptance criteria have been met
• The work item is considered ready for testing
This attestation serves as Technical Sign-Off.
Date/Time: 18 Jun 2026 06:51


---

### 💬 评论人：Emil Schnabel (emil.schnabel@oldmutual.com)
📅 **时间**：2026-06-22T08:39:44.164+0200

Defect found. More details to be added later


---

