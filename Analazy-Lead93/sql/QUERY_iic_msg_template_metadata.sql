-- Metadata pointing to a missing/deleted Template; expected 0 rows.
SELECT m.email_code
FROM iic_msg_template_metadata m
LEFT JOIN iic_msg_email_config c
  ON c.email_code = m.email_code
 AND c.status = 0
WHERE m.status = 0
  AND c.id IS NULL;

-- Invalid main Category; expected 0 rows.
SELECT m.email_code, m.category_id
FROM iic_msg_template_metadata m
LEFT JOIN iic_msg_category_config c
  ON c.id = m.category_id
 AND c.flag = :template_category_flag
 AND c.category_level = 1
 AND c.is_deleted = 0
WHERE m.status = 0
  AND m.category_id IS NOT NULL
  AND c.id IS NULL;

