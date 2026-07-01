# Comments - LEAD-293: Create a category/ subcategories 

此文件记录了 Jira Story [LEAD-293] 评审与设计过程中的讨论历史。

---

### 💬 评论人：Tao Qian (tao.qian@oldmutual.com)
📅 **时间**：2026-07-01T02:54:39.197+0200

AC 9 states: "A template can belong to many categories or sub-categories."
LEAD-301 (Assign Category) and LEAD-276 (Reassign Category) assume a single parent-child category pair is assigned per template.


Can a template belong to multiple categories simultaneously? If yes:
* * How does drag-and-drop reassignment work? (Does dragging a template to another category copy it, move it, or prompt the user?)
How is this rendered in the folder navigation tree (does the same template appear in multiple folders)?


---

### 💬 评论人：Dan Yu (dan.yu@oldmutual.com)
📅 **时间**：2026-07-01T09:13:58.924+0200

 
We need clarification on the template-to-category relationship:
* * * One-to-many or many-to-many? AC9 says "a template can belong to many categories", but LEAD-301 and LEAD-276 assume single assignment. Which is the intended behavior?
Archived category handling — When a category is archived, what happens to its templates? Archive all, move to another category, or mark as "uncategorized"?
Automated mapping rules — The story mentions "automated mapping" for existing templates. Is there a mapping table or rule set we should follow?


---

### 💬 评论人：Cisca Van Zyl (cvanzyl6@oldmutual.com)
📅 **时间**：2026-07-01T10:13:42.735+0200

 Temaplates  can belong to 1 Category, but many subcategories. 2. I have updated archive to “delete”, as we do not want to complicate this. 3. Automated mapping - yes, bsuy with this, will add document soonest. to Lead 328


---

