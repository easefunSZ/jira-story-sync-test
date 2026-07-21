CREATE TABLE IF NOT EXISTS iic_msg_template_category_rel (
  id bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '主键',
  email_code varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  subcategory_id bigint unsigned NOT NULL COMMENT 'iic_msg_email_category.id；Subcategory ID',
  status int NOT NULL DEFAULT 0 COMMENT '0有效，-1删除',
  created_by varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'system',
  created_date datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'system',
  updated_date datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id) USING BTREE,
  UNIQUE KEY uk_template_subcategory (email_code, subcategory_id),
  KEY idx_template_category_rel_email (email_code, status),
  KEY idx_template_category_rel_subcategory (subcategory_id, status, email_code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=DYNAMIC COMMENT='Template to Subcategory relation';
