INSERT INTO iic_msg_template_migration_snapshot
  (source_batch_id, record_type, record_id, email_code, snapshot_json, created_by)
SELECT
  @migration_batch_id, 'CONFIG', c.id, c.email_code,
  JSON_OBJECT('email_name', c.email_name, 'description', c.description,
    'email_status', c.email_status, 'status', c.status,
    'updated_by', c.updated_by, 'updated_date', c.updated_date),
  @migration_user
FROM iic_msg_email_config c
JOIN tmp_lead93_template_mapping m ON m.email_code = c.email_code
WHERE c.status = 0
ON DUPLICATE KEY UPDATE record_id = VALUES(record_id);

INSERT INTO iic_msg_template_migration_snapshot
  (source_batch_id, record_type, record_id, email_code, snapshot_json, created_by)
SELECT
  @migration_batch_id, 'VERSION', v.id, v.email_code,
  JSON_OBJECT('title', v.title, 'category_id', v.category_id,
    'updated_by', v.updated_by,
    'updated_date', v.updated_date),
  @migration_user
FROM iic_msg_email_config_version v
JOIN tmp_lead93_version_category_mapping m
  ON m.email_code = v.email_code
 AND m.version = v.version
WHERE v.status = 0
ON DUPLICATE KEY UPDATE record_id = VALUES(record_id);
