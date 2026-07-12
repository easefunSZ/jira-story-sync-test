-- Invalid Subcategory or parent mismatch; expected 0 rows.
SELECT r.email_code, r.subcategory_id, s.parent_id, m.category_id
FROM iic_msg_template_category_rel r
LEFT JOIN iic_msg_category_config s
  ON s.id = r.subcategory_id
 AND s.flag = :template_category_flag
 AND s.category_level = 2
 AND s.is_deleted = 0
LEFT JOIN iic_msg_template_metadata m
  ON m.email_code = r.email_code
 AND m.status = 0
WHERE r.status = 0
  AND (s.id IS NULL OR m.id IS NULL OR s.parent_id <> m.category_id);

