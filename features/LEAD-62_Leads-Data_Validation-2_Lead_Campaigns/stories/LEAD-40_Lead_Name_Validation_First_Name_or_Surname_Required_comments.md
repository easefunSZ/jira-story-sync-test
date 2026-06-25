# Comments - LEAD-40: Lead Name Validation – First Name or Surname Required

此文件记录了 Jira Story [LEAD-40] 评审与设计过程中的讨论历史。

---

### 💬 评论人：Dan Yu (dan.yu@oldmutual.com)
📅 **时间**：2026-05-29T09:41:54.810+0200

  Surname and First Name were originally mandatory fields. If we change them to optional, the DB schema would need adjustment, and the associated frontend pages and backend proxy logic would also need changes. Therefore, our proposed solution is that users only need to enter one of the two fields, and the system will default the other to a value of "-". This minimizes the overall impact. Would you agree with this approach?


---

### 💬 评论人：Tracey Lee Craig (tcraig@oldmutual.com)
📅 **时间**：2026-05-29T09:54:32.974+0200

 Hi Yes, if you a re referring to scenario 4, this should never happen, if it does it is definitely a fail, one of those must be present.


---

### 💬 评论人：Dan Yu (dan.yu@oldmutual.com)
📅 **时间**：2026-05-29T12:02:17.563+0200

 the default value is given to scenario 1 & 2, please check and confirm is it feasible on your side.
Scenario
First Name
Surname
Verification Result
1
Input value
— (system default value)
PASS
2
— (system default value)
Input value
PASS
3
Input value
Input value
PASS
4
Null
Null
FAIL


---

### 💬 评论人：Tracey Lee Craig (tcraig@oldmutual.com)
📅 **时间**：2026-06-01T08:00:21.577+0200

 Happy with that


---

### 💬 评论人：Dan Yu (dan.yu@oldmutual.com)
📅 **时间**：2026-06-11T05:37:42.954+0200

HI  
The frontend developer raised a question regarding LEAD-40 (Name Validation): Should the first name / last name validation rules apply to PF leads only, or to both PF and MFC leads?
Currently, the lead creation process does not differentiate between PF and MFC. If we apply the validation rules to PF only, it should not impact MFC logic.
Could you please confirm whether the name validation should be:
* * PF only — validation rules apply to PF leads only, MFC remains unchanged
Both PF and MFC — validation rules apply to all leads regardless of segment
Thanks!


---

