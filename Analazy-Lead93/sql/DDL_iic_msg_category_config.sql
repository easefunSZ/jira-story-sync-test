-- LEAD-93 one-time DDL: reuse category table for Template taxonomy.
-- Existing rows keep category_level NULL. LEAD-93 Category/Subcategory rows use
-- category_level 1/2, so no new flag or namespace value is introduced.
ALTER TABLE iic_msg_category_config
  MODIFY COLUMN category_name varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '类别名称',
  ADD COLUMN normalized_name varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT 'trim/lower 后名称，用于 Template taxonomy 唯一校验' AFTER category_name,
  ADD COLUMN description varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '类别描述' AFTER normalized_name,
  ADD COLUMN parent_id bigint DEFAULT NULL COMMENT '父 Category ID；一级节点为 NULL' AFTER description,
  ADD COLUMN category_level tinyint unsigned DEFAULT NULL COMMENT 'Template taxonomy: 1 Category, 2 Subcategory' AFTER parent_id,
  ADD COLUMN sort_order int NOT NULL DEFAULT 0 COMMENT '同级排序' AFTER category_level,
  ADD COLUMN deleted_by varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '删除人' AFTER sort_order,
  ADD COLUMN deleted_date datetime DEFAULT NULL COMMENT '删除时间' AFTER deleted_by,
  ADD COLUMN source_batch_id varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'LEAD-93 migration batch' AFTER deleted_date,
  ADD COLUMN active_template_normalized_name varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci GENERATED ALWAYS AS (CASE WHEN is_deleted = 0 AND category_level IN (1, 2) THEN normalized_name ELSE NULL END) STORED COMMENT '有效 Template taxonomy 节点名称唯一键' AFTER source_batch_id,
  ADD COLUMN template_category_code varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin GENERATED ALWAYS AS (CASE WHEN category_level IN (1, 2) THEN category_code ELSE NULL END) STORED COMMENT 'Template taxonomy 节点 Snowflake 编码唯一键' AFTER active_template_normalized_name,
  ADD UNIQUE KEY uk_msg_category_active_template_name (active_template_normalized_name),
  ADD UNIQUE KEY uk_msg_category_template_code (template_category_code),
  ADD KEY idx_msg_category_tree (category_level, is_deleted, parent_id, sort_order);
