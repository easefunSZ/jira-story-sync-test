-- LEAD-93 one-time DDL: store the current main Category and Copy source on the Template master.
ALTER TABLE iic_msg_email_config 
ADD COLUMN category_id bigint unsigned DEFAULT NULL COMMENT '当前主 Category ID；关联 iic_msg_email_category.id',
ADD COLUMN copy_from_email_code varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT 'Copy and Create 来源 email_code；仅用于管理端发布提醒',
ADD KEY idx_email_config_category (category_id, status, email_status, is_campaign);
