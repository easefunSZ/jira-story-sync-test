-- Tag relation group mismatch or missing Tag Value; expected 0 rows.
SELECT r.email_code, r.version, r.group_code, r.tag_code
FROM iic_msg_template_tag_rel r
LEFT JOIN iic_msg_email_config_version ev
  ON ev.email_code = r.email_code
 AND ev.version = r.version
 AND ev.status = 0
LEFT JOIN iic_msg_tag_value v
  ON v.tag_code = r.tag_code
 AND v.status = 0
WHERE r.status = 0
  AND (ev.id IS NULL OR v.id IS NULL OR v.group_code <> r.group_code);

-- Duplicate active relation for the same Tag Value; expected 0 rows. Multiple
-- different tag_code values in one Group are valid.
SELECT email_code, version, group_code, tag_code, COUNT(*) AS duplicate_count
FROM iic_msg_template_tag_rel
WHERE status = 0
GROUP BY email_code, version, group_code, tag_code
HAVING COUNT(*) > 1;
