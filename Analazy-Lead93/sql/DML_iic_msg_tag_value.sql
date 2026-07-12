INSERT INTO iic_msg_tag_value
  (group_code, tag_code, tag_name, is_default, sort_order,
   source_batch_id, status, created_by, updated_by)
VALUES
  ('CONTENT_TYPE', 'CONTENT_TYPE_UNCLASSIFIED', 'Unclassified', 1, 0, @migration_batch_id, 0, @migration_user, @migration_user),
  ('TRIGGER', 'TRIGGER_UNCLASSIFIED', 'Unclassified', 1, 0, @migration_batch_id, 0, @migration_user, @migration_user),
  ('LIFECYCLE_STAGE', 'LIFECYCLE_STAGE_UNCLASSIFIED', 'Unclassified', 1, 0, @migration_batch_id, 0, @migration_user, @migration_user),
  ('FINANCIAL_NEED', 'FINANCIAL_NEED_UNCLASSIFIED', 'Unclassified', 1, 0, @migration_batch_id, 0, @migration_user, @migration_user)
ON DUPLICATE KEY UPDATE
  group_code = VALUES(group_code),
  tag_name = VALUES(tag_name),
  is_default = VALUES(is_default),
  status = 0,
  source_batch_id = VALUES(source_batch_id),
  updated_by = VALUES(updated_by),
  updated_date = CURRENT_TIMESTAMP;

UPDATE iic_msg_tag_value
SET status = -1, updated_by = @migration_user, updated_date = CURRENT_TIMESTAMP
WHERE @lead93_rollback = 1
  AND source_batch_id = @migration_batch_id;

