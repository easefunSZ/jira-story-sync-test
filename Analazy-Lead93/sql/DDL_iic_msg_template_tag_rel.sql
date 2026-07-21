CREATE TABLE IF NOT EXISTS iic_msg_template_tag_rel (
  email_code varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  tag_code varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  PRIMARY KEY (email_code, tag_code),
  KEY idx_template_tag_rel_filter (tag_code, email_code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin COMMENT='Template to current fixed Tag relation';
