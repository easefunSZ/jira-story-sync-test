# Comments - LEAD-307: Delete a  category/subcategory 

此文件记录了 Jira Story [LEAD-307] 评审与设计过程中的讨论历史。

---

### 💬 评论人：Tao Qian (tao.qian@oldmutual.com)
📅 **时间**：2026-07-01T02:53:02.409+0200

* LEAD-293 (Create Category) and LEAD-277 (Validation Framework) state: If archived, the user must have a selection to archive all templates or move/reassign them to another category.

So do we implement a strict block (forcing the user to manually reassign templates beforehand), or do we display a resolution modal during archiving that allows bulk-reassignment or bulk-archiving of templates?


---

### 💬 评论人：Cisca Van Zyl (cvanzyl6@oldmutual.com)
📅 **时间**：2026-07-01T09:47:15.335+0200

 I have updated this story from archive to pure delete. Deletion is strictly blocked if templates are assigned. The intended behavior is a strict delete block. If the category or any of its subcategories has templates assigned, the delete action must not proceed. The user must first manually reassign or delete those templates before attempting to delete the category. There is no bulk reassignment, delete flow as part of this story.


---

### 💬 评论人：Dan Yu (dan.yu@oldmutual.com)
📅 **时间**：2026-07-01T10:24:55.977+0200

Hi Please check following:
* * * AC3 vs AC4 
AC3 states that deleting a parent category will automatically delete all its subcategories. But AC4 requires the category to have no subcategories before it can be deleted. Could you confirm which is the intended behaviour? We assume AC3 (cascade delete) is correct and AC4's "no subcategories" condition is unintended.
Delete Flow — Block or Guide? AC3 says if templates still exist under a category, the system blocks deletion and the CM must manually reassign templates first. But LEAD-293 AC9 and LEAD-277 describe a different approach — a dialog that lets the CM choose to either move templates to another category or archive/delete them in one step. Which approach should we follow? The guided dialog (consistent with LEAD-293/LEAD-277) would be a much better user experience. I also checked UX is the first manual approach.
Data Retention & Recoverability. Since delete is a permanent, irreversible action (unlike archive), please confirm:
* * * Is this a hard delete (removed from database) or soft delete (marked as deleted, data retained)?
Should the system keep an audit record of who deleted what and when?
Is there any undo/recovery mechanism needed in case of accidental deletion?
* Subcategory Independent Deletion. All ACs describe deleting a parent category (with cascade). Can a CM delete a single subcategory without deleting the parent category? If yes, does the same template-check logic as category delete apply?


---

### 💬 评论人：Cisca Van Zyl (cvanzyl6@oldmutual.com)
📅 **时间**：2026-07-01T11:32:36.339+0200

 
* * * * AC3 vs AC4: The intended behaviour is cascade delete. A parent category can be deleted even if it has subcategories, provided there are no templates assigned to the parent category or any of its subcategories. If the validation passes, the parent category and all of its child subcategories are deleted (soft delete).
Delete Flow: Please follow the manual approach as per the approved UX. If templates are assigned, deletion is blocked and the Content Manager must manually reassign, , or delete the templates before attempting deletion again. 
Data Retention: This is a soft delete. Deleted categories remain in the database for audit purposes but are hidden from users. An audit record should be kept (who deleted it and when). There is no undo/recovery functionality.
Subcategory Deletion: Yes, a Content Manager can delete an individual subcategory. The same validation applies—if the subcategory has assigned templates, deletion is blocked. If there are no templates, only the selected subcategory is deleted and the parent category remains.
I've updated the story and acceptance criteria to reflect these changes.


---

