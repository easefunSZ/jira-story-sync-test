# Comments - LEAD-52: Support large files

此文件记录了 Jira Story [LEAD-52] 评审与设计过程中的讨论历史。

---

### 💬 评论人：Tracey Lee Craig (tcraig@oldmutual.com)
📅 **时间**：2026-05-11T09:33:22.802+0200

This requires a task to analyse the Lambda and matillion  file limitations


---

### 💬 评论人：Jiangtao Zhou (jiangtao.zhou@oldmutual.com)
📅 **时间**：2026-05-12T12:55:22.439+0200

 please tell us the prod server performance, and support how many Matillion pipeline concurrence.


---

### 💬 评论人：Chan Ke (chan.ke@oldmutual.com)
📅 **时间**：2026-06-01T03:38:32.872+0200

Test screenshot:

1.I use some files that more than 52000 records and check ,it is uploaded and supported successfully
we can see the table

the sql like：
SELECT FILE_ID, FILE_NAME, FILE_SIZE_BYTES, TOTAL_ROWS, UPLOAD_TIME, STATUS,COMPLETION_TIME, ORIGINAL_PATH, PENDING_PATH, ARCHIVE_PATH, S3_PATH, CREATED_AT, UPDATED_AT
FROM DEV_AUDIT.FILE_PROCESSING.FILE_MASTER;the status and the total_rows ,we can see the files size and the process,it can support more than 52000 records


---

### 💬 评论人：Tao Qian (tao.qian@oldmutual.com)
📅 **时间**：2026-06-02T10:00:17.337+0200

The current system design temporarily sets the maximum limit for a single file to 60,000 records to prevent Lambda timeouts. This threshold ensures system stability under peak loads. 


---

### 💬 评论人：Embrenchia Snyman (embrenchia.snyman@oldmutual.com)
📅 **时间**：2026-06-10T09:23:52.787+0200

Work has been deployed to Blue ON through CHG36324860. 
Please liaise with your PO to acquire Business Sign Off in order for work to proceed to Green ON.


---

