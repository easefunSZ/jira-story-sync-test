CREATE TABLE IF NOT EXISTS iic_msg_template_category_rel (
  email_code varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  subcategory_id bigint unsigned NOT NULL COMMENT 'iic_msg_email_category.id；Subcategory ID',
  PRIMARY KEY (email_code, subcategory_id),
  KEY idx_template_category_rel_subcategory (subcategory_id, email_code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin COMMENT='Template to current Subcategory relation';
