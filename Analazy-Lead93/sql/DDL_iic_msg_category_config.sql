-- LEAD-93 one-time DDL: reuse category table for Template taxonomy.
ALTER TABLE iic_msg_category_config
  MODIFY COLUMN category_name varchar(100)
    CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL
    COMMENT '类别名称',
  ADD COLUMN normalized_name varchar(100)
    CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL
    COMMENT 'trim/lower 后名称，用于 Template taxonomy 唯一校验'
    AFTER category_name,
  ADD COLUMN description varchar(500)
    CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL
    COMMENT '类别描述'
    AFTER normalized_name,
  ADD COLUMN parent_id bigint DEFAULT NULL
    COMMENT '父 Category ID；一级节点为 NULL'
    AFTER description,
  ADD COLUMN category_level tinyint unsigned DEFAULT NULL
    COMMENT 'Template taxonomy: 1 Category, 2 Subcategory'
    AFTER parent_id,
  ADD COLUMN sort_order int NOT NULL DEFAULT 0
    COMMENT '同级排序'
    AFTER category_level,
  ADD COLUMN deleted_by varchar(100)
    CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL
    COMMENT '删除人'
    AFTER sort_order,
  ADD COLUMN deleted_date datetime DEFAULT NULL
    COMMENT '删除时间'
    AFTER deleted_by,
  ADD COLUMN source_batch_id varchar(64)
    CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL
    COMMENT 'LEAD-93 migration batch'
    AFTER deleted_date,
  ADD UNIQUE KEY uk_msg_category_flag_code (flag, category_code),
  ADD UNIQUE KEY uk_msg_category_flag_name (flag, normalized_name),
  ADD KEY idx_msg_category_tree
    (flag, is_deleted, parent_id, category_level, sort_order);

