-- Insert one immutable Category/Subcategory history row after the current-tree
-- write succeeds and before its transaction commits. operation_id is shared by
-- all nodes changed in a batch create, reorder, or delete operation.
INSERT INTO iic_msg_email_category_change_history (operation_id, category_id, change_type, changed_fields, before_snapshot, after_snapshot, changed_by, changed_date)
VALUES (:operation_id, :category_id, :change_type, CAST(:changed_fields AS JSON), CAST(:before_snapshot AS JSON), CAST(:after_snapshot AS JSON), :operator, CURRENT_TIMESTAMP);

-- Snapshot conventions:
-- CREATE:  before_snapshot = NULL; after_snapshot = {id,parentId,categoryName,sortOrder,isDeleted}.
-- UPDATE:  before_snapshot and after_snapshot are complete node snapshots.
-- REORDER: one row per changed node; changed_fields contains sortOrder only.
-- DELETE:  one row per soft-deleted node; after_snapshot has isDeleted=-1,
--          deletedBy and deletedDate. It shares operation_id with the optional
--          iic_msg_email_category_delete_audit operation summary.
