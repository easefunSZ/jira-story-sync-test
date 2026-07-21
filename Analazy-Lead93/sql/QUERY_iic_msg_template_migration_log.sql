-- Batch summary for the release report.
SELECT batch_id, execution_status, total_count, success_count, failed_count,
       error_message, executed_by, started_date, completed_date
FROM iic_msg_template_migration_log
WHERE batch_id = @migration_batch_id;

-- Completion gate: expected 0 rows before migration sign-off.
SELECT batch_id, execution_status, error_message
FROM iic_msg_template_migration_log
WHERE batch_id = @migration_batch_id AND execution_status <> 'SUCCESS';
