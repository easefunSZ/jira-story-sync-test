-- Runtime mapper templates for atomic Template-level Category/Subcategory
-- Reassign-and-Delete. The Service first freezes affected email_code values
-- with QUERY_iic_msg_email_category.sql and captures each Template before-state.

-- Level-1 delete: replace the current main Category for affected Templates.
UPDATE iic_msg_email_config template
JOIN (
  SELECT :email_code_1 AS email_code
  UNION ALL SELECT :email_code_2
) affected ON affected.email_code = template.email_code
SET template.category_id = :target_category_id,
    template.updated_by = :operator,
    template.updated_date = CURRENT_TIMESTAMP
WHERE template.status = 0 AND template.category_id = :source_category_id;

-- Level-1 delete: replace the complete current Subcategory set.
DELETE relation
FROM iic_msg_template_category_rel relation
JOIN (
  SELECT :email_code_1 AS email_code
  UNION ALL SELECT :email_code_2
) affected ON affected.email_code = relation.email_code;

-- Level-2 delete: remove only the deleted Subcategory; valid siblings remain.
DELETE relation
FROM iic_msg_template_category_rel relation
JOIN (
  SELECT :email_code_1 AS email_code
  UNION ALL SELECT :email_code_2
) affected ON affected.email_code = relation.email_code
WHERE relation.subcategory_id = :source_subcategory_id;

-- Insert approved replacement Subcategories. For a level-1 delete this is the
-- complete replacement set; for a level-2 delete it is merged with siblings.
INSERT INTO iic_msg_template_category_rel (email_code, subcategory_id)
VALUES (:email_code_1, :target_subcategory_id_1),
       (:email_code_1, :target_subcategory_id_2),
       (:email_code_2, :target_subcategory_id_1)
ON DUPLICATE KEY UPDATE subcategory_id = VALUES(subcategory_id);

-- Soft-delete the source node and, for a level-1 source, all active children.
UPDATE iic_msg_email_category
SET is_deleted = 1, deleted_by = :operator, deleted_date = CURRENT_TIMESTAMP, updated_by = :operator, updated_date = CURRENT_TIMESTAMP
WHERE (id = :source_category_id OR parent_id = :source_category_id) AND is_deleted = 0;

-- Final transaction steps:
-- 1. Insert one iic_msg_email_template_change_history row per affected Template
--    with change_type=CATEGORY_REASSIGNMENT and before/after snapshots.
-- 2. Insert one iic_msg_email_category_delete_audit operation row.
-- Any count mismatch or history/audit failure rolls back the complete operation.
