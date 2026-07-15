-- LEAD-93 runtime Category mapper templates. This file is not part of the DBA
-- deployment sequence. Service validation and transaction handling are required.

-- Create Category/Subcategory. category_code is a backend-generated Snowflake
-- ID converted to varchar; the frontend neither supplies nor edits it.
INSERT INTO iic_msg_category_config
  (tenant_id, category_code, category_name, normalized_name, description,
   parent_id, category_level, sort_order, is_deleted,
   created_by, updated_by, dae_country_code)
VALUES
  (:tenant_id, :backend_snowflake_category_code, :category_name,
   LOWER(TRIM(:category_name)), :description, :parent_id, :category_level,
   :sort_order, 0, :operator, :operator, :dae_country_code);

-- Rename/Edit one active Template taxonomy node. The generated unique column
-- rejects a normalized-name conflict with another active node.
UPDATE iic_msg_category_config
SET category_name = :category_name,
    normalized_name = LOWER(TRIM(:category_name)),
    description = :description,
    updated_by = :operator,
    updated_date = CURRENT_TIMESTAMP
WHERE id = :category_id
  AND category_level IN (1, 2)
  AND is_deleted = 0;

-- Reorder mapper template. MyBatis/DAO expands the CASE and IN placeholders
-- for the complete sibling set after validating level, parent and duplicate IDs.
UPDATE iic_msg_category_config
SET sort_order = CASE id
      WHEN :node_id_1 THEN :sort_order_1
      WHEN :node_id_2 THEN :sort_order_2
      ELSE sort_order
    END,
    updated_by = :operator,
    updated_date = CURRENT_TIMESTAMP
WHERE id IN (:node_id_1, :node_id_2)
  AND category_level = :category_level
  AND is_deleted = 0
  AND (
    (:category_level = 1 AND parent_id IS NULL)
    OR (:category_level = 2 AND parent_id = :parent_id)
  );

-- The service must lock and verify the complete sibling set before this update.
-- MySQL affected_rows may be lower when a submitted sort_order is unchanged.
