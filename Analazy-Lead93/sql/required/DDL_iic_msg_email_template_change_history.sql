-- Runtime Template modification history. Current searchable values remain in
-- normalized Template/Category/Tag tables; immutable before/after snapshots use
-- JSON so one-to-many Subcategory and Tag values remain readable after rename
-- or soft deletion.
CREATE TABLE IF NOT EXISTS iic_msg_email_template_change_history (
  id bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '主键',
  operation_id varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin  NULL COMMENT '一次业务操作标识；批量迁移可对应多个 Template',
  email_code varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT 'Template 业务标识',
  change_type varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT 'CREATE/BASIC_INFO/METADATA/STATUS/CATEGORY_REASSIGNMENT/DELETE',
  changed_fields json DEFAULT NULL COMMENT '本次实际修改字段数组；包含 field、beforeValue、afterValue',
  before_snapshot json DEFAULT NULL COMMENT '修改前完整 Template 级快照',
  after_snapshot json DEFAULT NULL COMMENT '修改后完整 Template 级快照',
  changed_by varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '操作人',
  changed_date datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '操作时间',
  PRIMARY KEY (id),
  UNIQUE KEY uk_email_template_change_operation (operation_id, email_code),
  KEY idx_email_template_change_history (email_code, changed_date, id),
  KEY idx_email_template_change_type (change_type, changed_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin COMMENT='Email Template current-attribute modification history';
