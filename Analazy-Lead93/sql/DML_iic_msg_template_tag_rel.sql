-- Replace the complete current Tag set for every Template in the mapping.
DELETE r FROM iic_msg_template_tag_rel r
JOIN (SELECT DISTINCT email_code FROM tmp_lead93_tag_mapping) target ON target.email_code = r.email_code;

INSERT INTO iic_msg_template_tag_rel (email_code, tag_code)
SELECT m.email_code, v.tag_code
FROM tmp_lead93_tag_mapping m
JOIN iic_msg_email_config e ON e.email_code = m.email_code AND e.status = 0
JOIN iic_msg_tag_value v ON v.tag_code = m.tag_code AND v.group_code = m.group_code
ON DUPLICATE KEY UPDATE tag_code = VALUES(tag_code);
