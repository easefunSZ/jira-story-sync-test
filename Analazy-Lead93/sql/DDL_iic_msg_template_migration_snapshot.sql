CREATE TABLE IF NOT EXISTS iic_msg_template_migration_snapshot (
  id bigint unsigned NOT NULL AUTO_INCREMENT,
  source_batch_id varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  record_type varchar(40) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT 'Target table logical type',
  record_key varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT 'Stable business key used by rollback',
  action_type varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT 'INSERT or UPDATE',
  record_id bigint unsigned DEFAULT NULL COMMENT 'Existing row ID; NULL when migration inserts a new row',
  email_code varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  snapshot_json json DEFAULT NULL COMMENT 'Pre-migration values; NULL for INSERT',
  created_by varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'system',
  created_date datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id) USING BTREE,
  UNIQUE KEY uk_template_migration_snapshot (source_batch_id, record_type, record_key),
  KEY idx_template_migration_snapshot_email (source_batch_id, email_code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=DYNAMIC COMMENT='LEAD-93 migration-only rollback snapshot';
