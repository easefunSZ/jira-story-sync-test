-- Batch summary for the release report.
SELECT source_batch_id, execution_result, COUNT(*) AS record_count, SUM(affected_rows) AS affected_rows, MIN(executed_date) AS first_event_time, MAX(executed_date) AS last_event_time
FROM iic_msg_template_migration_log
WHERE source_batch_id = @migration_batch_id
GROUP BY source_batch_id, execution_result
ORDER BY execution_result;

-- Version-level execution details. This is migration evidence, not a runtime
-- Template audit history.
SELECT email_code, version, migration_action, action_reason, before_version_status, after_version_status, execution_result, affected_rows, error_message, executed_by, executed_date
FROM iic_msg_template_migration_log
WHERE source_batch_id = @migration_batch_id
  AND record_key <> 'BATCH'
ORDER BY email_code, version, migration_action;

-- Completion gate: expected 0 rows before migration sign-off.
SELECT record_key, email_code, version, migration_action, execution_result, error_message
FROM iic_msg_template_migration_log
WHERE source_batch_id = @migration_batch_id
  AND execution_result <> 'SUCCESS';
