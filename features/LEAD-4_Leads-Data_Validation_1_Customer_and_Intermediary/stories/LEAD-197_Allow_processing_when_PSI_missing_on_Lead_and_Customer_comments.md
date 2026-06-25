# Comments - LEAD-197: Allow processing when PSI missing on Lead and Customer

此文件记录了 Jira Story [LEAD-197] 评审与设计过程中的讨论历史。

---

### 💬 评论人：Dan Yu (dan.yu@oldmutual.com)
📅 **时间**：2026-06-01T09:36:06.071+0200

 I've updated "Then" description as shown below – please let me know if you agree:
* Then:
* * * * The Lead continues processing without being blocked
The validation result is marked as "Pass – No PSI on both"
The system must log the following information in the validation audit table:
* * * * * * * * * Lead ID
Customer ID
Validation Rule ID (PSI-005)
Validation Type: PSI Validation
Validation Outcome: Pass
Failure Reason: N/A
Lead PSI Value: Null
Customer PSI Value: Null
Processing Timestamp
This record can be used for subsequent data quality reporting to identify customers with missing PSI
Note: For existing customers, a missing PSI is a data quality issue. Although it does not block the current lead processing, the audit trail should support future data cleansing and PSI backfill efforts.


---

### 💬 评论人：Cisca Van Zyl (cvanzyl6@oldmutual.com)
📅 **时间**：2026-06-01T09:49:28.528+0200

 Thanks. 100%.


---

