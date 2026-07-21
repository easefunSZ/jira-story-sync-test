-- Replace the complete current Subcategory set for every Template in the mapping.
DELETE r FROM iic_msg_template_category_rel r
JOIN tmp_lead93_template_category_mapping target ON target.email_code = r.email_code;

INSERT INTO iic_msg_template_category_rel (email_code, subcategory_id)
SELECT m.email_code, c.id
FROM tmp_lead93_subcategory_mapping m
JOIN iic_msg_email_config e ON e.email_code = m.email_code AND e.status = 0
JOIN iic_msg_email_category c ON c.category_name = m.subcategory_name AND c.parent_id = e.category_id AND c.is_deleted = 0
ON DUPLICATE KEY UPDATE subcategory_id = VALUES(subcategory_id);
