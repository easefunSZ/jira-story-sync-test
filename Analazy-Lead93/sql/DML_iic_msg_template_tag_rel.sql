-- Replace the complete Tag set for every version present in the approved
-- mapping. Multiple tag_code rows in the same group are valid.
UPDATE iic_msg_template_tag_rel r
JOIN (SELECT DISTINCT email_code, version FROM tmp_lead93_tag_mapping) target
  ON target.email_code = r.email_code AND target.version = r.version
SET r.status = -1,
    r.updated_by = @migration_user,
    r.updated_date = CURRENT_TIMESTAMP
WHERE r.status = 0;

INSERT INTO iic_msg_template_tag_rel
  (email_code, version, group_code, tag_code, status,
   created_by, updated_by)
SELECT m.email_code, m.version, v.group_code, v.tag_code,
       0, @migration_user, @migration_user
FROM tmp_lead93_tag_mapping m
JOIN iic_msg_email_config e
  ON e.email_code = m.email_code AND e.status = 0
JOIN iic_msg_email_config_version ev
  ON ev.email_code = m.email_code
 AND ev.version = m.version
 AND ev.status = 0
JOIN iic_msg_tag_value v
  ON v.tag_code = m.tag_code
 AND v.group_code = m.group_code
 AND v.status = 0
ON DUPLICATE KEY UPDATE
  status = 0,
  updated_by = VALUES(updated_by),
  updated_date = CURRENT_TIMESTAMP;

UPDATE iic_msg_template_tag_rel r
JOIN iic_msg_template_migration_snapshot s ON s.source_batch_id = @migration_batch_id AND s.record_type = 'TAG_REL' AND s.record_key = CONCAT(r.email_code, '|', r.version, '|', r.group_code, '|', r.tag_code) AND s.action_type = 'UPDATE'
SET r.status = CAST(JSON_UNQUOTE(JSON_EXTRACT(s.snapshot_json, '$.status')) AS SIGNED),
    r.updated_by = @migration_user,
    r.updated_date = CURRENT_TIMESTAMP
WHERE @lead93_rollback = 1;

UPDATE iic_msg_template_tag_rel r
JOIN iic_msg_template_migration_snapshot s ON s.source_batch_id = @migration_batch_id AND s.record_type = 'TAG_REL' AND s.record_key = CONCAT(r.email_code, '|', r.version, '|', r.group_code, '|', r.tag_code) AND s.action_type = 'INSERT'
SET r.status = -1, r.updated_by = @migration_user, r.updated_date = CURRENT_TIMESTAMP
WHERE @lead93_rollback = 1;
