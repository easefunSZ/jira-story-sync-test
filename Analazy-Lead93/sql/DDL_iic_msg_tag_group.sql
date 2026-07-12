CREATE TABLE IF NOT EXISTS iic_msg_tag_group (
  id bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '主键',
  group_code varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  group_name varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  is_mandatory tinyint(1) NOT NULL DEFAULT 0 COMMENT '0可选，1必填',
  sort_order int NOT NULL DEFAULT 0,
  source_batch_id varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,
  status int NOT NULL DEFAULT 0 COMMENT '0有效，-1删除',
  created_by varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'system',
  created_date datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'system',
  updated_date datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id) USING BTREE,
  UNIQUE KEY uk_tag_group_code (group_code),
  KEY idx_tag_group_status_sort (status, sort_order)
) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin
  ROW_FORMAT=DYNAMIC
  COMMENT='Fixed Template tag groups';

