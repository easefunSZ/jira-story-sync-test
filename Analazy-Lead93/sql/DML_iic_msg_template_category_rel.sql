-- Soft-delete the complete current Subcategory set for every Template in the mapping.
UPDATE iic_msg_template_category_rel r
JOIN tmp_lead93_template_category_mapping target ON target.email_code = r.email_code
SET r.status = -1, r.updated_by = @migration_user, r.updated_date = CURRENT_TIMESTAMP
WHERE r.status = 0;

INSERT INTO iic_msg_template_category_rel (email_code, subcategory_id, status, created_by, updated_by)
SELECT m.email_code, c.id, 0, @migration_user, @migration_user
FROM tmp_lead93_subcategory_mapping m
JOIN iic_msg_email_config e ON e.email_code = m.email_code AND e.status = 0
JOIN iic_msg_email_category c ON c.category_name = m.subcategory_name AND c.parent_id = e.category_id AND c.is_deleted = 0
ON DUPLICATE KEY UPDATE status = 0, updated_by = VALUES(updated_by), updated_date = CURRENT_TIMESTAMP;
