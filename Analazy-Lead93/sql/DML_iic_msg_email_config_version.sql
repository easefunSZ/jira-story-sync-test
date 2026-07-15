-- Main Category migration. Q5 must provide one approved row per target version.
UPDATE iic_msg_email_config_version v
JOIN tmp_lead93_version_category_mapping m
  ON m.email_code = v.email_code
 AND m.version = v.version
JOIN iic_msg_category_config c
  ON c.category_code = m.category_code
 AND c.category_level = 1
 AND c.is_deleted = 0
SET v.category_id = c.id,
    v.updated_by = @migration_user,
    v.updated_date = CURRENT_TIMESTAMP
WHERE v.status = 0;

-- Email Subject migration. Template Title is config.email_name; Email Subject
-- is version.title.
UPDATE iic_msg_email_config_version v
JOIN tmp_lead93_template_mapping m ON m.email_code = v.email_code
SET v.title = m.new_subject,
    v.updated_by = @migration_user,
    v.updated_date = CURRENT_TIMESTAMP
WHERE v.version_status = 1
  AND v.status = 0
  AND m.new_subject IS NOT NULL;

UPDATE iic_msg_email_config_version v
JOIN iic_msg_template_migration_snapshot s
  ON s.record_type = 'VERSION'
 AND s.record_id = v.id
 AND s.source_batch_id = @migration_batch_id
SET v.title = NULLIF(JSON_UNQUOTE(JSON_EXTRACT(s.snapshot_json, '$.title')), 'null'),
    v.category_id = CAST(NULLIF(JSON_UNQUOTE(JSON_EXTRACT(s.snapshot_json, '$.category_id')), 'null') AS SIGNED),
    v.updated_by = @migration_user,
    v.updated_date = CURRENT_TIMESTAMP
WHERE @lead93_rollback = 1;
