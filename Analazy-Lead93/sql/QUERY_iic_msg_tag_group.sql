-- Published Template missing a mandatory Tag Group; expected 0 rows.
SELECT DISTINCT c.email_code, g.group_code
FROM iic_msg_email_config c
JOIN iic_msg_email_config_version v
  ON v.email_code = c.email_code
 AND v.status = 0
 AND v.version_status = 1
CROSS JOIN iic_msg_tag_group g
WHERE c.status = 0
  AND c.email_status = 1
  AND g.status = 0
  AND g.is_mandatory = 1
  AND NOT EXISTS (
    SELECT 1
    FROM iic_msg_template_tag_rel r
    WHERE r.email_code = c.email_code
      AND r.version = v.version
      AND r.group_code = g.group_code
      AND r.status = 0
  );

-- Tag Group deactivation pre-check. Expected 0 rows before an approved
-- maintenance script sets the Group status to -1.
SELECT group_code, group_name, is_mandatory
FROM iic_msg_tag_group
WHERE group_code = @tag_group_code_to_deactivate
  AND is_mandatory = 1;

SELECT DISTINCT r.email_code, r.version, ev.version_status, r.group_code, r.tag_code
FROM iic_msg_template_tag_rel r
JOIN iic_msg_email_config_version ev
  ON ev.email_code = r.email_code
 AND ev.version = r.version
 AND ev.status = 0
WHERE r.group_code = @tag_group_code_to_deactivate
  AND r.status = 0
  AND ev.version_status IN (0, 1, 3);
