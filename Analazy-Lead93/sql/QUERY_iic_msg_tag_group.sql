-- Runtime fixed Tag Group query. max_selections is derived by the Service:
-- TRIGGER returns 5; other Groups return NULL.
SELECT group_code, group_name, is_mandatory, sort_order
FROM iic_msg_tag_group
WHERE status = 0
ORDER BY sort_order, group_code;

-- Published Template missing a mandatory Tag Group; expected 0 rows.
SELECT DISTINCT c.email_code, g.group_code
FROM iic_msg_email_config c
JOIN iic_msg_email_config_version v ON v.email_code = c.email_code AND v.status = 0 AND v.version_status = 1
CROSS JOIN iic_msg_tag_group g
WHERE c.status = 0 AND c.email_status = 1 AND g.status = 0 AND g.is_mandatory = 1
  AND NOT EXISTS (
    SELECT 1
    FROM iic_msg_template_tag_rel r
    JOIN iic_msg_tag_value tv ON tv.tag_code = r.tag_code AND tv.group_code = r.group_code AND tv.status = 0
    WHERE r.email_code = c.email_code AND r.status = 0 AND r.group_code = g.group_code
  );
