# Comments - LEAD-53: Near real time processing

此文件记录了 Jira Story [LEAD-53] 评审与设计过程中的讨论历史。

---

### 💬 评论人：Tracey Lee Craig (tcraig@oldmutual.com)
📅 **时间**：2026-05-11T09:37:12.812+0200

As per the PRD, batch runs every hour on the hour, Investigation to understand if real time can be supported.


---

### 💬 评论人：Jiangtao Zhou (jiangtao.zhou@oldmutual.com)
📅 **时间**：2026-05-12T13:02:56.150+0200

 how many Matillion pipeline instance we can run in prod?


---

### 💬 评论人：Jiangtao Zhou (jiangtao.zhou@oldmutual.com)
📅 **时间**：2026-05-12T13:03:03.912+0200

 how many Matillion pipeline instance we can run in prod?


---

### 💬 评论人：Jiangtao Zhou (jiangtao.zhou@oldmutual.com)
📅 **时间**：2026-05-12T13:03:31.370+0200

 how many Matillion pipeline instance we can run in prod?


---

### 💬 评论人：Chan Ke (chan.ke@oldmutual.com)
📅 **时间**：2026-06-01T12:01:45.804+0200

Background:
After follow-up discussions, the current file scanning frequency has been adjusted to 5 minutes.
qiantao has confirmed with Dan that this setting meets the real-time requirements and strikes a good balance. It also imposes relatively lighter load on the server, satisfying business demands while accommodating the software’s performance limits
 I’m on board with this conclusion too.
Test screenshot:
1.I upload a file to the shared folder
2.after 5 minutes ,I can not see the file in the shared files ,and then I see the table
3.after the step 2,and then the data will sycn to DAE by eventbridge


---

### 💬 评论人：Tao Qian (tao.qian@oldmutual.com)
📅 **时间**：2026-06-02T09:03:46.712+0200

Initially, the job was designed to pick up files every minute. However, due to database connection pool limitations, concurrent execution of multiple jobs caused frequent startups, leading to prolonged database connection waits and ultimately crashing the entire application. After consulting with Data Engineer Mantsho Molepo, we adjusted the thread interval to 5 minutes to mitigate this issue.



---

### 💬 评论人：Chan Ke (chan.ke@oldmutual.com)
📅 **时间**：2026-06-02T09:53:46.150+0200



---

### 💬 评论人：Chan Ke (chan.ke@oldmutual.com)
📅 **时间**：2026-06-02T09:56:10.454+0200

  could you confirm the first column is the jobid


---

### 💬 评论人：Tracey Lee Craig (tcraig@oldmutual.com)
📅 **时间**：2026-06-02T10:16:00.116+0200

 Where am I looking first or 2nd screen shot? or am I matching the first screen shot to the 2nd screen shot, I am not sure what you want me to look for?


---

### 💬 评论人：Embrenchia Snyman (embrenchia.snyman@oldmutual.com)
📅 **时间**：2026-06-10T09:23:52.688+0200

Work has been deployed to Blue ON through CHG36324860. 
Please liaise with your PO to acquire Business Sign Off in order for work to proceed to Green ON.


---

