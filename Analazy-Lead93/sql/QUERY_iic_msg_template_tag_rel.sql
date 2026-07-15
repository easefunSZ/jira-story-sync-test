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

-- More than one active Tag Value in one group for one Template Version;
-- expected 0 rows. The unique key prevents this after deployment.
SELECT email_code, version, group_code, COUNT(*) AS tag_count
FROM iic_msg_template_tag_rel
WHERE status = 0
GROUP BY email_code, version, group_code
HAVING COUNT(*) > 1;
