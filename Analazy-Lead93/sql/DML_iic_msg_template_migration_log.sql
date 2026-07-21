-- One-time migration batch log. Run these statements in a transaction separate
-- from business DML so a FAILED result can be recorded after rollback.

INSERT INTO iic_msg_template_migration_log (batch_id, execution_status, total_count, success_count, failed_count, executed_by)
VALUES (@migration_batch_id, 'STARTED', :total_count, 0, 0, @migration_user)
ON DUPLICATE KEY UPDATE execution_status = 'STARTED', total_count = VALUES(total_count), success_count = 0, failed_count = 0, error_message = NULL, executed_by = VALUES(executed_by), started_date = CURRENT_TIMESTAMP, completed_date = NULL;

-- Mark the batch successful after business DML and all validation queries commit.
UPDATE iic_msg_template_migration_log
SET execution_status = 'SUCCESS', success_count = :success_count, failed_count = 0, error_message = NULL, completed_date = CURRENT_TIMESTAMP
WHERE batch_id = @migration_batch_id AND execution_status = 'STARTED';

-- Mark the batch failed after business DML rolls back. Do not persist stack
-- traces, mapping payloads, Template content or other sensitive data.
UPDATE iic_msg_template_migration_log
SET execution_status = 'FAILED', success_count = :success_count, failed_count = :failed_count, error_message = :error_message, completed_date = CURRENT_TIMESTAMP
WHERE batch_id = @migration_batch_id AND execution_status = 'STARTED';
