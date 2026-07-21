CREATE TABLE IF NOT EXISTS iic_msg_tag_value (
  group_code varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  tag_code varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  tag_name varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  description varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'Tag Taxonomy 中的可选描述',
  sort_order int NOT NULL DEFAULT 0,
  PRIMARY KEY (tag_code),
  KEY idx_tag_value_group (group_code, sort_order)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin COMMENT='Fixed Template tag values';
