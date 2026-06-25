# Comments - LEAD-55:  Validate Matching PSI between Lead and customer

此文件记录了 Jira Story [LEAD-55] 评审与设计过程中的讨论历史。

---

### 💬 评论人：Embrenchia Snyman (embrenchia.snyman@oldmutual.com)
📅 **时间**：2026-04-14T09:29:33.565+0200

Please indicate planned quarter (Quarter Prioritized) @{{reporter}}


---

### 💬 评论人：Dan Yu (dan.yu@oldmutual.com)
📅 **时间**：2026-06-10T04:58:28.378+0200

Hi  
I'd like to clarify our proposed approach for Channel  Validation in the PSI validation flow. There are two layers of logic:
Approach 1 — Payload-First (Recommended Priority)
If the inbound payload contains segmentCode and country fields with valid values, we use these fields directly to determine the channel. This is the most straightforward and reliable method.
Approach 2 — DAE As-Is Code Logic (Fallback)
If segmentCode and/or country are empty/null in the payload, the system falls back to the current DAE code-based logic to determine the segment. The existing logic works as follows (see attached flow diagram):
* * * Parse the lead and check whether lead.source exists.
* * YES → Query Campaign
NO → Campaign = null
Check if lead.source equals "NAM":
* * YES (Namibia path): Campaign exists → Segment = Campaign.Segment; no Campaign → Segment = NAM_PF
NO (Non-Namibia path): Matches rewardNaCampaignIds → NAM_PF; otherwise → NA_PF; then Campaign exists → Override with Campaign.Segment
End & Return
Recommendation:
The current as-is code logic (Approach 2) involves multiple conditional branches and is not straightforward enough. We recommend enforcing segmentCode and country as mandatory fields at lead creation time across all data sources (Everlytic, batch files, API). This way:
* * * Channel determination becomes direct and unambiguous
We reduce dependency on indirect logic (lead.source, campaign config, rewardNaCampaignIds)
It simplifies maintenance and future rule changes
Action Required: Could you please confirm whether it is feasible from a business perspective to make segmentCode and country mandatory for all lead sources? If so, we will implement Approach 1 as the primary logic and retain Approach 2 only as a backward-compatible fallback during the transition period.
Looking forward to your feedback.


---

### 💬 评论人：Tracey Lee Craig (tcraig@oldmutual.com)
📅 **时间**：2026-06-10T07:58:04.488+0200

  Approach 1, sound the most logical. However if we do it this way , we would need this field to be mandatory as your pointed out. At this point I cannot determine that tis field is mandatory across all paylod-lead sources. I have another feature that I am still building which deals with payload standardisation. If these fields are not mandatory now, I suggest we go with existing logic, as I do not want to delay this feature. As a leads team we will have to look across all data suppliers of lead records and determine required field/mandatory fields, and this will require work by all leads data suppliers.


---

### 💬 评论人：Dan Yu (dan.yu@oldmutual.com)
📅 **时间**：2026-06-10T08:19:07.382+0200

 This will not impact the current sprint delivery. It is solely to align on the solution with you, enabling you to decide which approach is the most feasible.


---

