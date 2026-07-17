INSERT INTO iic_msg_tag_group
  (group_code, group_name, is_mandatory, sort_order,
   status, created_by, updated_by)
VALUES
  ('CONTENT_TYPE', 'Content Type', 1, 10, 0, @migration_user, @migration_user),
  ('TRIGGER', 'Trigger', 1, 20, 0, @migration_user, @migration_user),
  ('LIFECYCLE_STAGE', 'Lifecycle Stage', 1, 30, 0, @migration_user, @migration_user),
  ('FINANCIAL_NEED', 'Financial Need', 1, 40, 0, @migration_user, @migration_user),
  ('PROPOSITION', 'Proposition', 0, 50, 0, @migration_user, @migration_user),
  ('SOURCE', 'Source', 0, 60, 0, @migration_user, @migration_user)
ON DUPLICATE KEY UPDATE
  group_name = VALUES(group_name),
  is_mandatory = VALUES(is_mandatory),
  sort_order = VALUES(sort_order),
  status = 0,
  updated_by = VALUES(updated_by),
  updated_date = CURRENT_TIMESTAMP;

-- Controlled maintenance template: deactivate one Optional Tag Group only
-- when no Active, Draft, or Schedule Template Version references a Value in
-- the Group. When the variable is non-NULL, a guarded update that affects 0
-- rows must be treated as a failed maintenance action.
UPDATE iic_msg_tag_group g
SET g.status = -1,
    g.updated_by = @migration_user,
    g.updated_date = CURRENT_TIMESTAMP
WHERE g.group_code = @tag_group_code_to_deactivate
  AND g.status = 0
  AND g.is_mandatory = 0
  AND NOT EXISTS (
    SELECT 1
    FROM iic_msg_template_tag_rel r
    JOIN iic_msg_email_config_version ev
      ON ev.email_code = r.email_code
     AND ev.version = r.version
     AND ev.status = 0
    WHERE r.group_code = g.group_code
      AND r.status = 0
      AND ev.version_status IN (0, 1, 3)
  );

UPDATE iic_msg_tag_group g
JOIN iic_msg_template_migration_snapshot s ON s.source_batch_id = @migration_batch_id AND s.record_type = 'TAG_GROUP' AND s.record_key = g.group_code AND s.action_type = 'UPDATE'
SET g.group_name = JSON_UNQUOTE(JSON_EXTRACT(s.snapshot_json, '$.group_name')),
    g.is_mandatory = CAST(JSON_UNQUOTE(JSON_EXTRACT(s.snapshot_json, '$.is_mandatory')) AS UNSIGNED),
    g.sort_order = CAST(JSON_UNQUOTE(JSON_EXTRACT(s.snapshot_json, '$.sort_order')) AS SIGNED),
    g.status = CAST(JSON_UNQUOTE(JSON_EXTRACT(s.snapshot_json, '$.status')) AS SIGNED),
    g.updated_by = @migration_user,
    g.updated_date = CURRENT_TIMESTAMP
WHERE @lead93_rollback = 1;

UPDATE iic_msg_tag_group g
JOIN iic_msg_template_migration_snapshot s ON s.source_batch_id = @migration_batch_id AND s.record_type = 'TAG_GROUP' AND s.record_key = g.group_code AND s.action_type = 'INSERT'
SET g.status = -1, g.updated_by = @migration_user, g.updated_date = CURRENT_TIMESTAMP
WHERE @lead93_rollback = 1;
