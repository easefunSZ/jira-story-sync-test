-- Fixed taxonomy read query.
SELECT
  g.group_code, g.group_name, g.is_mandatory, g.sort_order AS group_sort,
  v.tag_code, v.tag_name, v.is_default, v.sort_order AS tag_sort
FROM iic_msg_tag_group g
LEFT JOIN iic_msg_tag_value v
  ON v.group_code = g.group_code
 AND v.status = 0
WHERE g.status = 0
ORDER BY g.sort_order, v.sort_order, v.id;

-- Tag Value deactivation pre-check. Expected 0 rows before an approved
-- maintenance script sets the Tag Value status to -1.
SELECT v.tag_code, v.tag_name, g.group_code, g.group_name
FROM iic_msg_tag_value v
JOIN iic_msg_tag_group g ON g.group_code = v.group_code
WHERE v.tag_code = @tag_code_to_deactivate
  AND v.is_default = 1
  AND g.is_mandatory = 1;

SELECT DISTINCT r.email_code, r.version, ev.version_status, r.group_code, r.tag_code
FROM iic_msg_template_tag_rel r
JOIN iic_msg_email_config_version ev
  ON ev.email_code = r.email_code
 AND ev.version = r.version
 AND ev.status = 0
WHERE r.tag_code = @tag_code_to_deactivate
  AND r.status = 0
  AND ev.version_status IN (0, 1, 3);
