-- Tag relation group mismatch or missing Tag Value; expected 0 rows.
SELECT r.email_code, r.group_code, r.tag_code
FROM iic_msg_template_tag_rel r
LEFT JOIN iic_msg_tag_value v
  ON v.tag_code = r.tag_code
 AND v.status = 0
WHERE r.status = 0
  AND (v.id IS NULL OR v.group_code <> r.group_code);

