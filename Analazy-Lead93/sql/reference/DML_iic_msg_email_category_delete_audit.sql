-- Insert exactly one immutable audit row after direct soft-delete or Metadata
-- reassignment plus soft-delete has passed all checks, before the same transaction commits.
-- For direct delete, bind target_category_id = NULL and affected_template_count = 0.
-- If this INSERT fails, the complete category-delete transaction rolls back.
-- The per-node lifecycle records are written to
-- iic_msg_email_category_change_history with the same operation_id.
INSERT INTO iic_msg_email_category_delete_audit (operation_id, source_category_id, source_category_name, source_parent_id, target_category_id, affected_template_count, deleted_node_count, deleted_nodes_snapshot, deleted_by, deleted_date)
VALUES (:operation_id, :source_category_id, :source_category_name, COALESCE(:source_parent_id, 0), :target_category_id, :affected_template_count, :deleted_node_count, CAST(:deleted_nodes_snapshot AS JSON), :operator, CURRENT_TIMESTAMP);
