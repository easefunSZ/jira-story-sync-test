-- Tag relation with a missing Template or Tag Value; expected 0 rows.
SELECT relation.email_code, relation.tag_code
FROM iic_msg_template_tag_rel relation
LEFT JOIN iic_msg_email_config template ON template.email_code = relation.email_code AND template.status = 0
LEFT JOIN iic_msg_tag_value value_node ON value_node.tag_code = relation.tag_code
WHERE template.id IS NULL OR value_node.tag_code IS NULL;

-- Duplicate relations are prevented by the composite primary key.
SELECT email_code, tag_code, COUNT(*) AS duplicate_count
FROM iic_msg_template_tag_rel
GROUP BY email_code, tag_code
HAVING COUNT(*) > 1;
