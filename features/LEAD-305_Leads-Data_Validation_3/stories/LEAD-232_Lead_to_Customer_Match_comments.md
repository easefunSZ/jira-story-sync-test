# Comments - LEAD-232: Lead to Customer Match

此文件记录了 Jira Story [LEAD-232] 评审与设计过程中的讨论历史。

---

### 💬 评论人：Dan Yu (dan.yu@oldmutual.com)
📅 **时间**：2026-06-08T13:04:07.799+0200

 For AC2 please Update:
I checked that both the customer detail page and the associated lead detail page require Customer ID to render. Therefore, when a unique customer is matched via Firstname/Surname + Cellphone No., the matched Customer ID will be auto populated into the new lead record to ensure downstream pages function correctly.
Please confirm if we are aligned. If so, will take extra action to populate the matched customer ID in incoming lead records.


---

### 💬 评论人：Cisca Van Zyl (cvanzyl6@oldmutual.com)
📅 **时间**：2026-06-08T13:17:10.298+0200

 Yes, provided the Customer ID is only auto-populated when a single unique customer match is found.


---

