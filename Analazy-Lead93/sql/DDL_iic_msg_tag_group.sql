CREATE TABLE IF NOT EXISTS iic_msg_tag_group (
  group_code varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  group_name varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  is_mandatory tinyint(1) NOT NULL DEFAULT 0 COMMENT '0可选，1必填',
  sort_order int NOT NULL DEFAULT 0,
  PRIMARY KEY (group_code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin COMMENT='Fixed Template tag groups';
