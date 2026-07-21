-- LEAD-93 one-time DDL: dedicated Email Template Category/Subcategory table.
CREATE TABLE IF NOT EXISTS iic_msg_email_category (
  id bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '主键',
  category_name varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT 'Category/Subcategory 名称',
  description varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '类别描述',
  parent_id bigint unsigned DEFAULT NULL COMMENT '父 Category ID；一级节点为 NULL',
  sort_order int NOT NULL DEFAULT 0 COMMENT '同级排序',
  is_deleted tinyint unsigned NOT NULL DEFAULT 0 COMMENT '0 有效，1 已软删除',
  created_by varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '创建人',
  created_date datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  updated_by varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '更新人',
  updated_date datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  deleted_by varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '删除人',
  deleted_date datetime DEFAULT NULL COMMENT '删除时间',
  PRIMARY KEY (id),
  KEY idx_email_category_tree (is_deleted, parent_id, sort_order)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin COMMENT='Email Template Category/Subcategory';
