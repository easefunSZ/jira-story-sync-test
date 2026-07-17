CREATE TABLE IF NOT EXISTS iic_msg_tag_value (
  id bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '主键',
  group_code varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  tag_code varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  tag_name varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  is_default tinyint(1) NOT NULL DEFAULT 0 COMMENT '是否为组内 Draft 默认值',
  sort_order int NOT NULL DEFAULT 0,
  status int NOT NULL DEFAULT 0 COMMENT '0有效，-1删除',
  created_by varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'system',
  created_date datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'system',
  updated_date datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id) USING BTREE,
  UNIQUE KEY uk_tag_value_code (tag_code),
  KEY idx_tag_value_group (group_code, status, sort_order)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=DYNAMIC COMMENT='Fixed Template tag values';
