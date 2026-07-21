-- LEAD-93 runtime audit for successful Category/Subcategory reassign-and-delete.
CREATE TABLE IF NOT EXISTS iic_msg_email_category_delete_audit (
  id bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '主键',
  operation_id varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '后端生成的一次删除操作标识',
  source_category_id bigint unsigned NOT NULL COMMENT '删除入口选择的 Category/Subcategory ID',
  source_category_name varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '删除时源节点名称快照',
  source_parent_id bigint unsigned DEFAULT NULL COMMENT '删除时源节点父 ID 快照',
  target_category_id bigint unsigned DEFAULT NULL COMMENT '有引用时迁移到的目标主 Category ID',
  affected_template_count int NOT NULL DEFAULT 0 COMMENT '实际影响 Template 数',
  deleted_node_count int NOT NULL DEFAULT 0 COMMENT '实际软删除 Category/Subcategory 节点数',
  deleted_nodes_snapshot json NOT NULL COMMENT '被软删除节点 ID、名称、父 ID 快照',
  deleted_by varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '操作人',
  deleted_date datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '成功删除时间',
  PRIMARY KEY (id),
  UNIQUE KEY uk_email_category_delete_audit_operation (operation_id),
  KEY idx_email_category_delete_audit_source (source_category_id, deleted_date),
  KEY idx_email_category_delete_audit_operator (deleted_by, deleted_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin COMMENT='Email Template Category/Subcategory successful delete audit';
