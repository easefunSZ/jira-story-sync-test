-- Support/QA lookup by backend operation ID.
SELECT id, operation_id, source_category_id, source_category_name, source_parent_id, target_category_id, affected_template_count, deleted_node_count, deleted_nodes_snapshot, deleted_by, deleted_date
FROM iic_msg_email_category_delete_audit
WHERE operation_id = :operation_id;

-- Associated Template audit details. The immutable before snapshot contains
-- emailCode, templateName and the source Category/Subcategory values captured
-- before reassignment; after_snapshot contains the replacement current values.
SELECT h.email_code,
       JSON_UNQUOTE(JSON_EXTRACT(h.before_snapshot, '$.templateName')) AS template_name,
       h.changed_fields,
       h.before_snapshot,
       h.after_snapshot,
       h.changed_by,
       h.changed_date
FROM iic_msg_email_template_change_history h
WHERE h.operation_id = :operation_id AND h.change_type = 'CATEGORY_REASSIGNMENT'
ORDER BY h.email_code;

-- Support lookup by deleted node and time range. Runtime Template queries do
-- not join this audit table.
SELECT id, operation_id, source_category_id, source_category_name, affected_template_count, deleted_node_count, deleted_by, deleted_date
FROM iic_msg_email_category_delete_audit
WHERE source_category_id = :source_category_id AND deleted_date >= :date_from AND deleted_date < :date_to
ORDER BY deleted_date DESC, id DESC;
