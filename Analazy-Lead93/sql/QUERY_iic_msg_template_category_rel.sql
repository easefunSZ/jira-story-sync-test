-- Invalid current Subcategory or parent mismatch; expected 0 rows.
SELECT relation.email_code, relation.subcategory_id, subcategory.parent_id, template.category_id
FROM iic_msg_template_category_rel relation
LEFT JOIN iic_msg_email_config template ON template.email_code = relation.email_code AND template.status = 0
LEFT JOIN iic_msg_email_category subcategory ON subcategory.id = relation.subcategory_id AND subcategory.parent_id IS NOT NULL AND subcategory.is_deleted = 0
WHERE relation.status = 0
  AND (template.id IS NULL OR subcategory.id IS NULL OR template.category_id IS NULL OR subcategory.parent_id <> template.category_id);
