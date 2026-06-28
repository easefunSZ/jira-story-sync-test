# Comments - LEAD-6: Enhance ingestion of  lead data

此文件记录了 Jira Story [LEAD-6] 评审与设计过程中的讨论历史。

---

### 💬 评论人：Dan Yu (dan.yu@oldmutual.com)
📅 **时间**：2026-04-20T22:44:44.143+0200

There is no new API identified as required for this feature. The intention is to work within the existing API structure and apply any necessary data validation for Everlytics import data there. This approach is dependent on the existing leads tracker design.


---

### 💬 评论人：Tao Qian (tao.qian@oldmutual.com)
📅 **时间**：2026-04-22T06:34:14.949+0200

Importing Everlytics leads doesn't require modifying the API code. I need either a configuration setup documentation or the code for parsing the lead tracker configuration.


---

### 💬 评论人：Emil Schnabel (emil.schnabel@oldmutual.com)
📅 **时间**：2026-04-22T14:32:12.070+0200

 Flag added 
 waiting on Leads tracker API architecture so that we can evaluate capability on all lead sources for Integreat


---

### 💬 评论人：Dan Yu (dan.yu@oldmutual.com)
📅 **时间**：2026-04-26T16:42:00.687+0200

  
Based on the current analysis, the Old Mutual DAE Enablement Platform already has an existing channel to handle Everlytic leads. It uses “want2Talk2PSI” to indicate intermediate and non-intermediate leads.
Therefore, OC’s scope is to verify whether leads with want2Talk2PSI = false are dispatched correctly and how they are dispatched. Meanwhile, the BA needs to clarify the dispatch rules for Everlytic non-intermediate leads.


---

### 💬 评论人：Kaashief Lodewyk (klodewyk2@oldmutual.com)
📅 **时间**：2026-05-06T13:37:20.670+0200

Solution Design for Leads
Digital Adviser Enablement - Confluence


---

### 💬 评论人：Kaashief Lodewyk (klodewyk2@oldmutual.com)
📅 **时间**：2026-05-06T13:38:19.220+0200

DAE API Enpoints Api Endpoints and Payloads - Digital Adviser Enablement - Confluence


---

### 💬 评论人：Embrenchia Snyman (embrenchia.snyman@oldmutual.com)
📅 **时间**：2026-06-02T18:15:30.322+0200

Release 13.2 (Blue) 28 May was cancelled due to scope changes and lack of readiness. All associated tickets are re-assigned to Release 13.2 (Blue 4 June 2026)


---

### 💬 评论人：Embrenchia Snyman (embrenchia.snyman@oldmutual.com)
📅 **时间**：2026-06-05T07:44:34.162+0200

BLUE deployment completed successfully.
Ownership has been assigned to the Scrum Master to coordinate business validation.
Before this item can be considered for GREEN:
* * * Business testing must be completed (or formally waived)
Product Owner approval obtained
Business Testing Sign Off updated to Signed Off
Once complete, the item may be included in a GREEN release.


---

### 💬 评论人：Automation for Jira (undefined)
📅 **时间**：2026-06-17T15:39:55.024+0200

I Tracey Lee Craig hereby attest on 17 Jun 2026 that I am waiving business sign off on this work and accept any associated risk. The work may progress to GREEN production state.


---

### 💬 评论人：Embrenchia Snyman (embrenchia.snyman@oldmutual.com)
📅 **时间**：2026-06-17T15:40:32.795+0200

Warning: Issue for deployment of Release 13.2 (BLUE) 4 June was changed by user Tracey Lee Craig after scope lock down. Review required. 
@Embrenchia Snyman 


---

