-- Batch-level release execution log only. It intentionally has no Template
-- before_snapshot/after_snapshot; per-Template business snapshots belong to
-- iic_msg_email_template_change_history.
CREATE TABLE IF NOT EXISTS iic_msg_template_migration_log (
  id bigint unsigned NOT NULL AUTO_INCREMENT,
  batch_id varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  execution_status varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT 'STARTED, SUCCESS or FAILED',
  total_count int NOT NULL DEFAULT 0,
  success_count int NOT NULL DEFAULT 0,
  failed_count int NOT NULL DEFAULT 0,
  error_message varchar(1000) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,
  executed_by varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'system',
  started_date datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  completed_date datetime DEFAULT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uk_template_migration_log_batch (batch_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin COMMENT='LEAD-93 one-time migration batch log; not runtime audit';
