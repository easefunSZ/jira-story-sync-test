-- Replace the complete current Subcategory set for one Template. The Service
-- validates every node against iic_msg_email_config.category_id, captures the
-- before snapshot, and performs this work in one transaction.
DELETE FROM iic_msg_template_category_rel WHERE email_code = :email_code;

INSERT INTO iic_msg_template_category_rel (email_code, subcategory_id)
SELECT :email_code, node.id
FROM iic_msg_email_category node
JOIN iic_msg_email_config template ON template.email_code = :email_code AND template.status = 0
WHERE node.id = :subcategory_id AND node.parent_id = template.category_id AND node.is_deleted = 0
ON DUPLICATE KEY UPDATE subcategory_id = VALUES(subcategory_id);

-- Copy and Create uses the same validated Insert once per submitted Subcategory,
-- with :email_code bound to B's new email_code. Do not copy invalid/deleted nodes
-- directly from the source Template.

-- Template soft-delete keeps its current Metadata rows for modification-history
-- readability. Physical cleanup is not part of the runtime delete transaction.
