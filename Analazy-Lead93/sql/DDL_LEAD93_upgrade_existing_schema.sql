-- LEAD-93 one-time upgrade from the previous LEAD-93 draft schema.
-- Do not run this file on a fresh environment; use the individual final DDL files.
-- DDL auto-commits in MySQL. Take a schema backup and complete the pre-checks first.
-- Expected baseline: category_id/copy_from_email_code/format and all six new
-- taxonomy/relation/history tables already exist; Tag Value still has is_default
-- and does not yet have description or changed_fields.

-- Pre-check: all statements must return 0 before the unique-key changes.
SELECT email_code, tag_code, COUNT(*) AS duplicate_count FROM iic_msg_template_tag_rel GROUP BY email_code, tag_code HAVING COUNT(*) > 1;
SELECT COUNT(*) AS invalid_tag_group_count FROM iic_msg_template_tag_rel r LEFT JOIN iic_msg_tag_value v ON v.tag_code = r.tag_code WHERE v.tag_code IS NULL OR r.group_code <> v.group_code;

-- Template master: remove the obsolete format field and restore the agreed query index.
ALTER TABLE iic_msg_email_config DROP COLUMN format, ADD KEY idx_email_config_category (category_id, status, email_status, is_campaign);

-- Category: restore the tree query index.
ALTER TABLE iic_msg_email_category MODIFY COLUMN category_code varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '后端生成的业务编码', ADD KEY idx_email_category_tree (is_deleted, parent_id, sort_order);

-- Tag taxonomy: retain soft-delete/audit columns, widen group_code, restore Value description, and remove is_default.
ALTER TABLE iic_msg_tag_group MODIFY COLUMN group_code varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL, ADD KEY idx_tag_group_status_sort (status, sort_order, group_code);
ALTER TABLE iic_msg_tag_value MODIFY COLUMN group_code varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL, ADD COLUMN description varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'Tag Taxonomy 中的可选描述' AFTER tag_name, DROP COLUMN is_default, ADD KEY idx_tag_value_group (group_code, status, sort_order, tag_code);

-- Relation tables: retain surrogate IDs/audit fields, rename business indexes,
-- and keep group_code as intentional redundant data on Tag relations.
ALTER TABLE iic_msg_template_category_rel DROP INDEX uk_template_version_subcategory, DROP INDEX idx_template_category_rel_version, ADD UNIQUE KEY uk_template_subcategory (email_code, subcategory_id), ADD KEY idx_template_category_rel_email (email_code, status);
ALTER TABLE iic_msg_template_tag_rel MODIFY COLUMN group_code varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL, DROP INDEX uk_template_version_tag, DROP INDEX idx_template_tag_rel_version, ADD UNIQUE KEY uk_template_tag (email_code, tag_code), ADD KEY idx_template_tag_rel_email (email_code, status);

-- Template history: keep complete before/after snapshots and add a field-level delta.
ALTER TABLE iic_msg_email_template_change_history ADD COLUMN changed_fields json DEFAULT NULL COMMENT '本次实际修改字段数组；包含 field、beforeValue、afterValue' AFTER change_type;

-- Post-check: the count must be 0.
SELECT COUNT(*) AS invalid_active_tag_relation_count FROM iic_msg_template_tag_rel r LEFT JOIN iic_msg_tag_value v ON v.tag_code = r.tag_code AND v.status = 0 LEFT JOIN iic_msg_tag_group g ON g.group_code = r.group_code AND g.status = 0 WHERE r.status = 0 AND (v.tag_code IS NULL OR g.group_code IS NULL OR v.group_code <> r.group_code);
