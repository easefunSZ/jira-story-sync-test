# Comments - LEAD-70: Verify sourcetype = "Everlytic" & "want2Talk2PSI: False" in One Connect DAE Platform 

此文件记录了 Jira Story [LEAD-70] 评审与设计过程中的讨论历史。

---

### 💬 评论人：Tao Qian (tao.qian@oldmutual.com)
📅 **时间**：2026-04-27T15:59:50.500+0200


* * When want2Talk2PSI=False or salescode= "",  Will the lead be dispatched or not?
Yes，the lead will be dispatched.
If want2Talk2PSI=false or salesCode= "", and it is handled by URLE, where will it be routed?
      Here is the route map

3.Check the leadid  "leadId": "18998973" (data from prod)
This leadid is record as an exception leads because of  “inactive Campaign” .  
Here are the Everlytic leads with PSI.SalesCode = ““ and recorded as exceptions:
And these are  the Everlytic leads with PSI.SalesCode = ““ and properly routed:


---

### 💬 评论人：Tracey Lee Craig (tcraig@oldmutual.com)
📅 **时间**：2026-05-08T08:20:31.917+0200

Next Steps, Cisca will follow up with Michelle, to verify that the lead id without the PSI code 65731867, that was allocated to northern hub PFA, is correct. This was sent to Everlytic without a worksite code.


---

### 💬 评论人：Embrenchia Snyman (embrenchia.snyman@oldmutual.com)
📅 **时间**：2026-06-02T18:15:34.095+0200

Release 13.2 (Blue) 28 May was cancelled due to scope changes and lack of readiness. All associated tickets are re-assigned to Release 13.2 (Blue 4 June 2026)


---

### 💬 评论人：Embrenchia Snyman (embrenchia.snyman@oldmutual.com)
📅 **时间**：2026-06-05T07:44:30.649+0200

BLUE deployment completed successfully.
Ownership has been assigned to the Scrum Master to coordinate business validation.
Before this item can be considered for GREEN:
* * * Business testing must be completed (or formally waived)
Product Owner approval obtained
Business Testing Sign Off updated to Signed Off
Once complete, the item may be included in a GREEN release.


---

