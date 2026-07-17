-- One-time migration execution log. These statements must run in a log
-- transaction separate from the business migration transaction so FAILED can
-- still be recorded after the business transaction rolls back. This table is
-- not written by runtime Template APIs.

-- Register the migration batch before starting business DML.
INSERT INTO iic_msg_template_migration_log (source_batch_id, record_key, migration_action, action_reason, execution_result, executed_by)
VALUES (@migration_batch_id, 'BATCH', 'LEAD93_MIGRATION', @migration_reason, 'STARTED', @migration_user)
ON DUPLICATE KEY UPDATE action_reason = VALUES(action_reason), execution_result = 'STARTED', affected_rows = 0, error_message = NULL, executed_by = VALUES(executed_by), executed_date = CURRENT_TIMESTAMP;

-- Register Template Master actions such as rename, description correction or
-- approved deactivation. KEEP rows remain useful evidence of explicit review.
INSERT INTO iic_msg_template_migration_log (source_batch_id, record_key, email_code, migration_action, action_reason, execution_result, executed_by)
SELECT @migration_batch_id, CONCAT(m.email_code, '|MASTER'), m.email_code, m.migration_action, m.action_note, 'STARTED', @migration_user
FROM tmp_lead93_template_mapping m
ON DUPLICATE KEY UPDATE action_reason = VALUES(action_reason), execution_result = 'STARTED', affected_rows = 0, error_message = NULL, executed_by = VALUES(executed_by), executed_date = CURRENT_TIMESTAMP;

-- Register every explicitly mapped target version. The union intentionally
-- does not infer historical versions; Q8 must freeze which versions are loaded.
INSERT INTO iic_msg_template_migration_log (source_batch_id, record_key, email_code, version, migration_action, action_reason, before_version_status, after_version_status, execution_result, executed_by)
SELECT @migration_batch_id, CONCAT(t.email_code, '|', t.version), t.email_code, t.version, 'METADATA_BACKFILL', m.action_note, v.version_status, v.version_status, 'STARTED', @migration_user
FROM (
  SELECT email_code, version FROM tmp_lead93_version_category_mapping
  UNION
  SELECT email_code, version FROM tmp_lead93_subcategory_mapping
  UNION
  SELECT email_code, version FROM tmp_lead93_tag_mapping
) t
JOIN iic_msg_email_config_version v ON v.email_code = t.email_code AND v.version = t.version AND v.status = 0
LEFT JOIN tmp_lead93_template_mapping m ON m.email_code = t.email_code
ON DUPLICATE KEY UPDATE action_reason = VALUES(action_reason), before_version_status = VALUES(before_version_status), after_version_status = VALUES(after_version_status), execution_result = 'STARTED', affected_rows = 0, error_message = NULL, executed_by = VALUES(executed_by), executed_date = CURRENT_TIMESTAMP;

-- After all mapping DML and validation queries succeed, mark each target and
-- then the batch SUCCESS in the independent log transaction.
UPDATE iic_msg_template_migration_log SET execution_result = 'SUCCESS', affected_rows = 1, error_message = NULL, executed_by = @migration_user, executed_date = CURRENT_TIMESTAMP WHERE source_batch_id = @migration_batch_id AND record_key <> 'BATCH' AND execution_result = 'STARTED';
SET @migration_success_count = (SELECT COUNT(*) FROM iic_msg_template_migration_log WHERE source_batch_id = @migration_batch_id AND record_key <> 'BATCH' AND execution_result = 'SUCCESS');
UPDATE iic_msg_template_migration_log SET execution_result = 'SUCCESS', affected_rows = @migration_success_count, error_message = NULL, executed_by = @migration_user, executed_date = CURRENT_TIMESTAMP WHERE source_batch_id = @migration_batch_id AND record_key = 'BATCH' AND migration_action = 'LEAD93_MIGRATION';

-- After rollback, the release executor binds one failed record when known and
-- always marks the batch FAILED. Do not store stack traces or sensitive data.
UPDATE iic_msg_template_migration_log SET execution_result = 'FAILED', affected_rows = 0, error_message = :error_message, executed_by = @migration_user, executed_date = CURRENT_TIMESTAMP WHERE source_batch_id = @migration_batch_id AND record_key = :failed_record_key AND migration_action = :failed_action;
UPDATE iic_msg_template_migration_log SET execution_result = 'FAILED', affected_rows = 0, error_message = :error_message, executed_by = @migration_user, executed_date = CURRENT_TIMESTAMP WHERE source_batch_id = @migration_batch_id AND record_key = 'BATCH' AND migration_action = 'LEAD93_MIGRATION';
