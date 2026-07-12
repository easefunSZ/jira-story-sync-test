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
    v.updated_by = @migration_user,
    v.updated_date = CURRENT_TIMESTAMP
WHERE @lead93_rollback = 1;

