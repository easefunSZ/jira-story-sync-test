-- Soft-delete the complete current Tag set for every Template in the mapping.
UPDATE iic_msg_template_tag_rel r
JOIN (SELECT DISTINCT email_code FROM tmp_lead93_tag_mapping) target ON target.email_code = r.email_code
SET r.status = -1, r.updated_by = @migration_user, r.updated_date = CURRENT_TIMESTAMP
WHERE r.status = 0;

INSERT INTO iic_msg_template_tag_rel (email_code, group_code, tag_code, status, created_by, updated_by)
SELECT m.email_code, v.group_code, v.tag_code, 0, @migration_user, @migration_user
FROM tmp_lead93_tag_mapping m
JOIN iic_msg_email_config e ON e.email_code = m.email_code AND e.status = 0
JOIN iic_msg_tag_value v ON v.tag_code = m.tag_code AND v.group_code = m.group_code AND v.status = 0
JOIN iic_msg_tag_group g ON g.group_code = v.group_code AND g.status = 0
ON DUPLICATE KEY UPDATE group_code = VALUES(group_code), status = 0, updated_by = VALUES(updated_by), updated_date = CURRENT_TIMESTAMP;
