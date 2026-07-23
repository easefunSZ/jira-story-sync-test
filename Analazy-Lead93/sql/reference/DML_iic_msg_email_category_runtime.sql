-- Runtime Category mapper templates. Service validation and transaction handling are required.

-- Create Category/Subcategory. parent_id = 0 creates a Category; a non-zero
-- parent_id must resolve to an active level-1 Category.
INSERT INTO iic_msg_email_category (category_name, parent_id, sort_order, is_deleted, created_by, updated_by)
VALUES (:category_name, COALESCE(:parent_id, 0), :sort_order, 0, :operator, :operator);

-- Batch-create 1-5 Subcategories under one active parent. MyBatis/DAO expands
-- exactly one tuple per request item after validating the complete batch.
INSERT INTO iic_msg_email_category (category_name, parent_id, sort_order, is_deleted, created_by, updated_by)
VALUES (:name_1, :parent_id, :sort_order_1, 0, :operator, :operator),
       (:name_2, :parent_id, :sort_order_2, 0, :operator, :operator);

-- Rename or edit one active node.
UPDATE iic_msg_email_category
SET category_name = :category_name, updated_by = :operator, updated_date = CURRENT_TIMESTAMP
WHERE id = :category_id AND is_deleted = 0;

-- Reorder a complete sibling set. :parent_id = 0 addresses level-1 nodes.
-- The Service first locks and compares the complete active sibling ID set,
-- rejects duplicates/cross-parent/stale requests, then assigns dense positions
-- 1..N in the submitted order. Do not use MySQL changed-row count as the only
-- success condition because unchanged positions may report 0 changed rows.
UPDATE iic_msg_email_category
SET sort_order = CASE id
      WHEN :node_id_1 THEN :sort_order_1
      WHEN :node_id_2 THEN :sort_order_2
      ELSE sort_order
    END,
    updated_by = :operator,
    updated_date = CURRENT_TIMESTAMP
WHERE id IN (:node_id_1, :node_id_2)
  AND parent_id = :parent_id
  AND is_deleted = 0;

-- After UPDATE, re-read and compare the authoritative order before commit.
SELECT id, sort_order
FROM iic_msg_email_category
WHERE parent_id = :parent_id AND is_deleted = 0
ORDER BY sort_order, id;

-- The service locks and verifies the complete sibling set before reordering.
--
-- For every successful Create, Update, or Reorder, insert immutable node-level
-- history through DML_iic_msg_email_category_change_history.sql before commit.
-- Batch-created or reordered nodes share one backend-generated operation_id.
