-- Insert exactly one immutable audit row after Metadata reassignment and node
-- soft-delete have passed all checks, but before the same transaction commits.
-- If this INSERT fails, the complete reassign-and-delete transaction rolls back.
INSERT INTO iic_msg_email_category_delete_audit (operation_id, source_category_id, source_category_name, source_parent_id, target_category_id, affected_template_count, deleted_node_count, deleted_nodes_snapshot, deleted_by, deleted_date)
VALUES (:operation_id, :source_category_id, :source_category_name, :source_parent_id, :target_category_id, :affected_template_count, :deleted_node_count, CAST(:deleted_nodes_snapshot AS JSON), :operator, CURRENT_TIMESTAMP);
