-- Invalid Subcategory or parent mismatch; expected 0 rows.
SELECT r.email_code, r.version, r.subcategory_id, s.parent_id, v.category_id
FROM iic_msg_template_category_rel r
LEFT JOIN iic_msg_email_config_version v
  ON v.email_code = r.email_code
 AND v.version = r.version
 AND v.status = 0
LEFT JOIN iic_msg_email_category s
  ON s.id = r.subcategory_id
 AND s.category_level = 2
 AND s.is_deleted = 0
WHERE r.status = 0
  AND (
    v.id IS NULL
    OR s.id IS NULL
    OR v.category_id IS NULL
    OR s.parent_id <> v.category_id
  );
