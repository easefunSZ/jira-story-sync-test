# Comments - LEAD-278: Edit a Published template 

此文件记录了 Jira Story [LEAD-278] 评审与设计过程中的讨论历史。

---

### 💬 评论人：Tao Qian (tao.qian@oldmutual.com)
📅 **时间**：2026-07-01T03:05:05.252+0200

* * * Does this lock also apply when a user is only editing metadata (LEAD-298)?
If A is editing the body content, can  B edit the title or tags at the same time? Or does the lock apply to the entire template entity?
How is the lock released if a user closes the tab or becomes inactive? 


---

### 💬 评论人：Cisca Van Zyl (cvanzyl6@oldmutual.com)
📅 **时间**：2026-07-01T11:55:56.856+0200

 I have  removed Lead 298, “Edit A Draft template.” as this is existing functionality.   As for locking rules on 278; ( this is my understanding ) - The same locking rules apply whether the  template is draft or published. The template status does not change how locking works.
The lock only applies when someone is editing the content body (WYSIWYG editor).
* * * Only one person can edit the content at a time.
Other users must wait until the lock is released.
Metadata editing (like title or tags) is not affected by this lock and works separately.
The lock starts when a user clicks “Edit Content” and is removed when:
* * * The user saves and exits
The user is inactive for a period of time
The session ends or times out


---

