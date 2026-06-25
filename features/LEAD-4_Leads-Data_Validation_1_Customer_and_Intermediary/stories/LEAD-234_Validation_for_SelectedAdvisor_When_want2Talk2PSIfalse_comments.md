# Comments - LEAD-234: Validation for SelectedAdvisor When ‘want2Talk2PSI=false’

此文件记录了 Jira Story [LEAD-234] 评审与设计过程中的讨论历史。

---

### 💬 评论人：Dan Yu (dan.yu@oldmutual.com)
📅 **时间**：2026-06-08T13:13:41.010+0200

 @ please check the story description and AC for selectedAdvisor validation:
When want2Talk2PSI = false and a selectedAdvisor with salesCode is provided, we propose applying the same validation rules as customerInfo.psi.salesCode, including:
* * * Sales code existence check
Intermediary active status check
Customer deceased status check
If any check fails, the lead will not proceed to dispatch.


---

### 💬 评论人：Tracey Lee Craig (tcraig@oldmutual.com)
📅 **时间**：2026-06-08T13:34:22.315+0200

   So Logic is,for Want to talk to PSI” is False, and “No PSI” code present, then apply the “ sales code existence check”, Apply the acive/Inactive check and check for deceased, apply the outcomes to the lead record, but  This lead should not be presented as the customer does not want to talk to an advisor. Please confirm. If so, why would we want the other checks performed, for auditing purposes?


---

### 💬 评论人：Cisca Van Zyl (cvanzyl6@oldmutual.com)
📅 **时间**：2026-06-08T14:26:32.377+0200

 Yes, correct —
when want2Talk2PSI = false, the lead must not be allocated the  PSI advisor, because the customer has explicitly opted out of advisor interaction.
The lead however must route to a General Pool / DFA (based on feedback from Rozana)  and we can add a exception “ Non‑PSI routing applied per customer intent”


---

### 💬 评论人：Cisca Van Zyl (cvanzyl6@oldmutual.com)
📅 **时间**：2026-06-08T14:31:45.372+0200

 The sales code existence, active/inactive, and deceased checks can still be  performed  as validation controls, not for allocation.


---

### 💬 评论人：Tracey Lee Craig (tcraig@oldmutual.com)
📅 **时间**：2026-06-08T14:32:10.131+0200

  
Ok makes sense, then Dany Yu, yes your logic is correct


---

