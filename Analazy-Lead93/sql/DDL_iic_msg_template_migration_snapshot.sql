CREATE TABLE IF NOT EXISTS iic_msg_template_migration_snapshot (
  id bigint unsigned NOT NULL AUTO_INCREMENT,
  source_batch_id varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  record_type varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL
    COMMENT 'CONFIG or VERSION',
  record_id bigint unsigned NOT NULL,
  email_code varchar(100)
    CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  snapshot_json json NOT NULL,
  created_by varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'system',
  created_date datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id) USING BTREE,
  UNIQUE KEY uk_template_migration_snapshot
    (source_batch_id, record_type, record_id),
  KEY idx_template_migration_snapshot_email (source_batch_id, email_code)
) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin
  ROW_FORMAT=DYNAMIC
  COMMENT='LEAD-93 migration rollback snapshot';

