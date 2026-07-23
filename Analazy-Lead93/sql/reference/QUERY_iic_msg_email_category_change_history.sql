-- Support lookup for the lifecycle of one Category/Subcategory node.
SELECT id, operation_id, category_id, change_type, changed_fields, before_snapshot, after_snapshot, changed_by, changed_date
FROM iic_msg_email_category_change_history
WHERE category_id = :category_id
ORDER BY changed_date DESC, id DESC;

-- Support lookup for every node changed by a single batch operation.
SELECT id, operation_id, category_id, change_type, changed_fields, before_snapshot, after_snapshot, changed_by, changed_date
FROM iic_msg_email_category_change_history
WHERE operation_id = :operation_id
ORDER BY category_id, id;
