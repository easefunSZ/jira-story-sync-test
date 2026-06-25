# Comments - LEAD-50: Use existing validation & processing rules

此文件记录了 Jira Story [LEAD-50] 评审与设计过程中的讨论历史。

---

### 💬 评论人：Tracey Lee Craig (tcraig@oldmutual.com)
📅 **时间**：2026-05-11T09:15:12.954+0200

@Kaashief  can we supply the source file and required data documentation in order to get this story to done, please.


---

### 💬 评论人：Tracey Lee Craig (tcraig@oldmutual.com)
📅 **时间**：2026-05-11T09:16:58.017+0200

Validation may prove whether or not existing Api can be used.


---

### 💬 评论人：Tracey Lee Craig (tcraig@oldmutual.com)
📅 **时间**：2026-05-11T09:28:21.829+0200

We may require new solution archicture


---

### 💬 评论人：Chan Ke (chan.ke@oldmutual.com)
📅 **时间**：2026-05-29T11:29:39.739+0200

Test Screenshot：
1.I access to the shared folder and then I upload five files to the shared folder
2.Within 1 minute, the files are detected one after another and then go into the corresponding logic.
3.and then I can check the snowflake report ，it will record the file processing status
4.if the file is processed failed，the presented admin can get the email like  the screenshot
5.Summary alert email sent every 30 minutes.Currently, the QA environment uses a 30-minute interval. This interval is configurable. There will be changes when we deploy Blue/Green releases later. Please compile the requirements and send them to the dev team ，the dev team should focus on this if it should be released th blue or green env.
6.if it is successfully processed,I can find in DAE system 

I use the file that yudan apply ,and i dont know the file format and content description ,so I only confirm that the lead is routo to DAE, I can create a file content that can match present adviser that I want .btw:This logic was implemented previously. Only the frequency is adjusted this time, changed from 1-2 hours to 1-2 minutes.so I think it is tested successfully  cc  


---

### 💬 评论人：Chan Ke (chan.ke@oldmutual.com)
📅 **时间**：2026-06-02T08:54:57.998+0200

1 minute edit to five  minutes  


---

### 💬 评论人：Embrenchia Snyman (embrenchia.snyman@oldmutual.com)
📅 **时间**：2026-06-10T09:23:52.976+0200

Work has been deployed to Blue ON through CHG36324860. 
Please liaise with your PO to acquire Business Sign Off in order for work to proceed to Green ON.


---

