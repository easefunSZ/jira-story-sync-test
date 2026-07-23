-- Runtime Category/Subcategory lifecycle history. The current tree remains in
-- iic_msg_email_category; immutable snapshots preserve each node change.
CREATE TABLE IF NOT EXISTS iic_msg_email_category_change_history (
  id bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '主键',
  operation_id varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '后端生成的一次业务操作标识',
  category_id bigint unsigned NOT NULL COMMENT '发生变更的 Category/Subcategory ID',
  change_type varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT 'CREATE/UPDATE/REORDER/DELETE',
  changed_fields json DEFAULT NULL COMMENT '本次实际变更字段数组；包含 field、beforeValue、afterValue',
  before_snapshot json DEFAULT NULL COMMENT '变更前节点完整快照',
  after_snapshot json DEFAULT NULL COMMENT '变更后节点完整快照',
  changed_by varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '操作人',
  changed_date datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '操作时间',
  PRIMARY KEY (id),
  UNIQUE KEY uk_email_category_change_operation (operation_id, category_id),
  KEY idx_email_category_change_history (category_id, changed_date, id),
  KEY idx_email_category_change_type (change_type, changed_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin COMMENT='Email Template Category/Subcategory lifecycle change history';
