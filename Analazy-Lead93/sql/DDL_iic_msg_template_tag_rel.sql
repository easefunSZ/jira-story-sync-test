CREATE TABLE IF NOT EXISTS iic_msg_template_tag_rel (
  id bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '主键',
  email_code varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  version varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '对应 iic_msg_email_config_version.version',
  group_code varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  tag_code varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  status int NOT NULL DEFAULT 0 COMMENT '0有效，-1删除',
  created_by varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'system',
  created_date datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'system',
  updated_date datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id) USING BTREE,
  UNIQUE KEY uk_template_version_tag (email_code, version, group_code, tag_code),
  KEY idx_template_tag_rel_version (email_code, version, status),
  KEY idx_template_tag_rel_filter (group_code, tag_code, status, email_code, version)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=DYNAMIC COMMENT='Template version to fixed Tag relation';
