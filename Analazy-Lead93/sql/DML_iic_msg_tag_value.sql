INSERT INTO iic_msg_tag_value
  (group_code, tag_code, tag_name, is_default, sort_order,
   status, created_by, updated_by)
VALUES
  ('CONTENT_TYPE', 'CONTENT_TYPE_UNCLASSIFIED', 'Unclassified', 1, 0, 0, @migration_user, @migration_user),
  ('TRIGGER', 'TRIGGER_UNCLASSIFIED', 'Unclassified', 1, 0, 0, @migration_user, @migration_user),
  ('LIFECYCLE_STAGE', 'LIFECYCLE_STAGE_UNCLASSIFIED', 'Unclassified', 1, 0, 0, @migration_user, @migration_user),
  ('FINANCIAL_NEED', 'FINANCIAL_NEED_UNCLASSIFIED', 'Unclassified', 1, 0, 0, @migration_user, @migration_user)
ON DUPLICATE KEY UPDATE
  group_code = VALUES(group_code),
  tag_name = VALUES(tag_name),
  is_default = VALUES(is_default),
  status = 0,
  updated_by = VALUES(updated_by),
  updated_date = CURRENT_TIMESTAMP;

-- Controlled maintenance template: deactivate one Tag Value only when it is
-- not a Mandatory Group default and is not referenced by an Active, Draft, or
-- Schedule Template Version. When the variable is non-NULL, a guarded update
-- that affects 0 rows must be treated as a failed maintenance action.
UPDATE iic_msg_tag_value v
JOIN iic_msg_tag_group g ON g.group_code = v.group_code
SET v.status = -1,
    v.updated_by = @migration_user,
    v.updated_date = CURRENT_TIMESTAMP
WHERE v.tag_code = @tag_code_to_deactivate
  AND v.status = 0
  AND NOT (g.is_mandatory = 1 AND v.is_default = 1)
  AND NOT EXISTS (
    SELECT 1
    FROM iic_msg_template_tag_rel r
    JOIN iic_msg_email_config_version ev
      ON ev.email_code = r.email_code
     AND ev.version = r.version
     AND ev.status = 0
    WHERE r.tag_code = v.tag_code
      AND r.status = 0
      AND ev.version_status IN (0, 1, 3)
  );

UPDATE iic_msg_tag_value v
JOIN iic_msg_template_migration_snapshot s ON s.source_batch_id = @migration_batch_id AND s.record_type = 'TAG_VALUE' AND s.record_key = v.tag_code AND s.action_type = 'UPDATE'
SET v.group_code = JSON_UNQUOTE(JSON_EXTRACT(s.snapshot_json, '$.group_code')),
    v.tag_name = JSON_UNQUOTE(JSON_EXTRACT(s.snapshot_json, '$.tag_name')),
    v.is_default = CAST(JSON_UNQUOTE(JSON_EXTRACT(s.snapshot_json, '$.is_default')) AS UNSIGNED),
    v.sort_order = CAST(JSON_UNQUOTE(JSON_EXTRACT(s.snapshot_json, '$.sort_order')) AS SIGNED),
    v.status = CAST(JSON_UNQUOTE(JSON_EXTRACT(s.snapshot_json, '$.status')) AS SIGNED),
    v.updated_by = @migration_user,
    v.updated_date = CURRENT_TIMESTAMP
WHERE @lead93_rollback = 1;

UPDATE iic_msg_tag_value v
JOIN iic_msg_template_migration_snapshot s ON s.source_batch_id = @migration_batch_id AND s.record_type = 'TAG_VALUE' AND s.record_key = v.tag_code AND s.action_type = 'INSERT'
SET v.status = -1, v.updated_by = @migration_user, v.updated_date = CURRENT_TIMESTAMP
WHERE @lead93_rollback = 1;
