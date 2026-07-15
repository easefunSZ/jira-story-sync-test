-- LEAD-93 runtime mapper template: reference-protected Category soft delete.
-- This is not a deployment migration script. Execute only after the QUERY
-- checks in the same service transaction and while holding the target row lock.
-- Active/Draft/Schedule references block deletion. Expired references do not.
-- The original row is retained with ID/Name/deleted_by/deleted_date for LEAD-307.
UPDATE iic_msg_category_config
SET is_deleted = 1,
    deleted_by = :operator,
    deleted_date = CURRENT_TIMESTAMP,
    updated_by = :operator,
    updated_date = CURRENT_TIMESTAMP
WHERE (id = :category_id OR parent_id = :category_id)
  AND category_level IN (1, 2)
  AND is_deleted = 0;

-- The service must require affected_rows >= 1. Deleting a level-1 Category may
-- update the parent and multiple children. Zero rows maps to CATEGORY_NOT_FOUND
-- or a concurrent-state conflict after rechecking.
