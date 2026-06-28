# Comments - LEAD-90: Lead Deduplication & Cross-Campaign Management

此文件记录了 Jira Story [LEAD-90] 评审与设计过程中的讨论历史。

---

### 💬 评论人：Dan Yu (dan.yu@oldmutual.com)
📅 **时间**：2026-05-18T03:29:26.325+0200

 The initial idea is to query customers by phone number. May I ask: for the customer data collected by the campaign, will phone numbers be duplicated? A customer can have multiple phone numbers? Also, when filling in the phone number during campaign management, is there any validation? Or does the Everlytic system perform validity checks on customer phone numbers? If the source system has already done the validation, does DAE still need to do it as well?


---

### 💬 评论人：Tracey Lee Craig (tcraig@oldmutual.com)
📅 **时间**：2026-05-18T08:54:31.998+0200

 
Hi there, makes sense to want to use the contact number, i would suggest maybe using that in conjunction with name and or surname. 
* * * * Please remember Everlytic is not our only data source . Ito of Validation on the contact number done by the that team, I will confirm.
Where lead data comes from the lead tracker source, basic number validation/formatting validation is done, they will also run a check for basic duplication, but do not run it against any other source. Please check and see that we run this against IG customer list.
 Where Lead data sources are received via MADM Files, these contact numbers are validated. Please again, check that we run a validation to IG customer list as ell.
Where lead sources are received by manual upload directly into IG, Im not sure what, if any validation is done.


---

### 💬 评论人：Tracey Lee Craig (tcraig@oldmutual.com)
📅 **时间**：2026-05-18T10:02:41.675+0200

 I received confirmation from Everlytic, that they run a Google number validation. Please let me know if anything else is required.


---

### 💬 评论人：Dan Yu (dan.yu@oldmutual.com)
📅 **时间**：2026-05-19T04:07:51.244+0200

@Tracey Lee Craig To deduplicate leads, we need a reliable method to identify unique customers. The options are either phone number or ID/passport. Since ID/passport does not appear to be a mandatory field during lead generation, we propose using mobile number as the unique identifier. Could you please confirm two scenarios in the South African context:
* * Is it possible for one customer to have multiple mobile numbers registered?
Conversely, is it possible for one mobile number to belong to multiple different customers?
Alternatively, do you have any other recommendations for ensuring customer uniqueness?


---

### 💬 评论人：Tracey Lee Craig (tcraig@oldmutual.com)
📅 **时间**：2026-05-20T10:15:53.389+0200

  , We are waiting on Business sign-off , our stakeholder is off sick and we will only be able to sogn-off on this story next week.  This should stop getting the feature into DOR, please confirm. Then please use the api registry link provided; DAE Api Registry - Digital Adviser Enablement - Confluence. Can we confirm the following, Madm files provide the customer gcs id, Everyltic provides the customer GCS id, I think the leads tracker file also contains this or customer ID, if so , then we can check for Duplication, please have a look. @ Cisca we will need to ensure that we update this story to all potential outcomes, based on Dan Yu, finds. 


---

### 💬 评论人：Dan Yu (dan.yu@oldmutual.com)
📅 **时间**：2026-06-15T08:27:28.826+0200

 
Please double confirm our alignment on the deduplication logic for leads within the same campaign and cross campaign:
* * Existing customers (with GCS ID): Deduplicate by Customer ID (GCS ID)- only one lead per customer ID is allowed within the same campaign.
New customers (without GCS ID): Deduplicate by name/surname + mobile number as the unique identifier per customer within the same campaign. 
Please confirm if this aligns with your understanding.


---

### 💬 评论人：Tracey Lee Craig (tcraig@oldmutual.com)
📅 **时间**：2026-06-15T08:48:06.309+0200

 Correct and it must be a perfect match


---

