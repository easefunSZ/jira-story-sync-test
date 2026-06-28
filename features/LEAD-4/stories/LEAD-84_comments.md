# Comments - LEAD-84: Auto-Correct Missing Lead PSI

此文件记录了 Jira Story [LEAD-84] 评审与设计过程中的讨论历史。

---

### 💬 评论人：Tracey Lee Craig (tcraig@oldmutual.com)
📅 **时间**：2026-06-01T17:49:25.597+0200

 Hi Cisca, can we add an AC that says this rule must run after PSI detection, before we do the PSI check, I know you have a sequence table but we must also indicate on each story, please


---

### 💬 评论人：Cisca Van Zyl (cvanzyl6@oldmutual.com)
📅 **时间**：2026-06-02T07:45:10.755+0200

 Hi, I have updated the acceptance criteria.


---

### 💬 评论人：Dan Yu (dan.yu@oldmutual.com)
📅 **时间**：2026-06-03T12:45:16.367+0200

 please have a look at Failure/Exception AC 3. It states that 'PSI data is incomplete, invalid, or corrupted.' Could you please advise how to determine whether PSI data is corrupted? Also, do you have an example help to define it? Thank you


---

### 💬 评论人：Cisca Van Zyl (cvanzyl6@oldmutual.com)
📅 **时间**：2026-06-03T13:04:24.693+0200

 Hi,  PSI - corrupt. when the system is unable to correctly interpret the PSI data due to technical issues in the data itself. Not a field-level validation issue. I will remove the word “corrupted”


---

### 💬 评论人：Dan Yu (dan.yu@oldmutual.com)
📅 **时间**：2026-06-08T12:20:12.259+0200

 Regarding LEAD-84, need to double-check with you for below two points:
* PSI Auto-Population Precondition
When a lead has customer ID but no sales code, should we check wantToTalkToPSI before looking up PSI in IG?
* * * wantToTalkToPSI: true → proceed with PSI auto-population
wantToTalkToPSI: false → skip PSI auto-population
or no mater false or true, using customer id to find sales code and then do auto-population.
* Allocation Path When wantToTalkToPSI: false
Should the lead follow existing validation logic and be allocated to:
* * * selected advisor, or
defined allocation group, or
DFA by default?
Please confirm.


---

### 💬 评论人：Cisca Van Zyl (cvanzyl6@oldmutual.com)
📅 **时间**：2026-06-08T14:34:52.515+0200

From: Dan Yu (Jira) <jira@oldmutualig.atlassian.net>
Sent: Monday, 08 June 2026 12:20
To: Cisca Van Zyl <CVanZyl6@oldmutual.com>
Subject: [JIRA] Dan Yu mentioned you on 
This email originates from an external source. Stop and think before you click!
Dan Yu mentioned you on a work item


---

### 💬 评论人：Dan Yu (dan.yu@oldmutual.com)
📅 **时间**：2026-06-09T03:59:15.703+0200

Hi @Cisca Van Zyl, your reply came through empty，no message content was received.
To clarify my question: the original logic uses the customer ID to check the sales code and then auto-populates the PSI if a unique sales code is matched. Before starting the customer ID search, should we add wantToTalkToPSI = true as a validation condition to trigger the customer ID search action?
In other words, if wantToTalkToPSI = false, the system would skip the PSI auto-population step entirely and use the existing leads despatch logic instead.
Could you please confirm this?


---

### 💬 评论人：Cisca Van Zyl (cvanzyl6@oldmutual.com)
📅 **时间**：2026-06-09T07:08:28.025+0200

Hi Yu
No, the Customer ID lookup should still be performed regardless of wantToTalkToPSI. However, when wantToTalkToPSI = false, the lead must not be assigned to the PSI and should be routed via the standard lead dispatch process.
http://webrightagency.co.za/clients/OMMS/1047/LogoHR.png
Cisca van zyl
Lead Business ANalyst | Personal Finance: Execution
1st Floor, E Block, Mutualpark, Jan Smuts Drive, Pinelands, Cape Town, South Africa
cvanzyl6@oldmutual.com<cvanzyl6@oldmutual.com>
f. OldMutualSA<https://www.facebook.com/oldmutualnigeria/> t. @OldMutualSA<https://twitter.com/OldMutualZW> li. old-mutual-south-africa<nsurname@oldmutual.com>


---

### 💬 评论人：Cisca Van Zyl (cvanzyl6@oldmutual.com)
📅 **时间**：2026-06-09T07:20:02.744+0200

Hi
My view is that the customer's PSI should be identified and validated irrespective of the wantToTalkToPSI value. The wantToTalkToPSI flag should determine lead routing only.
I think we should also have an exception reason “PSI Contact Not Requested”, as the  the PSI  might query why this lead was not routed to him.
http://webrightagency.co.za/clients/OMMS/1047/LogoHR.png
Cisca van zyl
Lead Business ANalyst | Personal Finance: Execution
1st Floor, E Block, Mutualpark, Jan Smuts Drive, Pinelands, Cape Town, South Africa
cvanzyl6@oldmutual.com<cvanzyl6@oldmutual.com>
f. OldMutualSA<https://www.facebook.com/oldmutualnigeria/> t. @OldMutualSA<https://twitter.com/OldMutualZW> li. old-mutual-south-africa<nsurname@oldmutual.com>


---

