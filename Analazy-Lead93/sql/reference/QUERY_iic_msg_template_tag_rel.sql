-- Active Tag relation with a missing Template, Tag Value, or mismatched redundant
-- group_code; expected 0 rows.
SELECT relation.email_code, relation.group_code, relation.tag_code
FROM iic_msg_template_tag_rel relation
LEFT JOIN iic_msg_email_config template ON template.email_code = relation.email_code AND template.status = 0
LEFT JOIN iic_msg_tag_value value_node ON value_node.tag_code = relation.tag_code AND value_node.status = 0
LEFT JOIN iic_msg_tag_group group_node ON group_node.group_code = relation.group_code AND group_node.status = 0
WHERE relation.status = 0
  AND (template.id IS NULL OR value_node.tag_code IS NULL OR group_node.group_code IS NULL OR value_node.group_code <> relation.group_code);

-- Duplicate business relations are prevented by uk_template_tag.
SELECT email_code, tag_code, COUNT(*) AS duplicate_count
FROM iic_msg_template_tag_rel
WHERE status = 0
GROUP BY email_code, tag_code
HAVING COUNT(*) > 1;
