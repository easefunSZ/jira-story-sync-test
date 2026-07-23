-- Soft-replace the complete current Subcategory set for one Template. The Service
-- validates every node against iic_msg_email_config.category_id, captures the
-- before snapshot, and performs this work in one transaction.
UPDATE iic_msg_template_category_rel
SET status = -1, updated_by = :operator, updated_date = CURRENT_TIMESTAMP
WHERE email_code = :email_code AND status = 0;

INSERT INTO iic_msg_template_category_rel (email_code, subcategory_id, status, created_by, updated_by)
SELECT :email_code, node.id, 0, :operator, :operator
FROM iic_msg_email_category node
JOIN iic_msg_email_config template ON template.email_code = :email_code AND template.status = 0
WHERE node.id = :subcategory_id AND node.parent_id = template.category_id AND node.is_deleted = 0
ON DUPLICATE KEY UPDATE status = 0, updated_by = VALUES(updated_by), updated_date = CURRENT_TIMESTAMP;

-- Copy and Create uses the same validated Insert once per submitted Subcategory,
-- with :email_code bound to B's new email_code. Do not copy invalid/deleted nodes
-- directly from the source Template.

-- Template soft-delete also soft-deletes current relation rows. Historical
-- display values remain available from the immutable change-history snapshots.
