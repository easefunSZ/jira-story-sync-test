INSERT INTO iic_msg_tag_group
  (group_code, group_name, is_mandatory, sort_order,
   source_batch_id, status, created_by, updated_by)
VALUES
  ('CONTENT_TYPE', 'Content Type', 1, 10, @migration_batch_id, 0, @migration_user, @migration_user),
  ('TRIGGER', 'Trigger', 1, 20, @migration_batch_id, 0, @migration_user, @migration_user),
  ('LIFECYCLE_STAGE', 'Lifecycle Stage', 1, 30, @migration_batch_id, 0, @migration_user, @migration_user),
  ('FINANCIAL_NEED', 'Financial Need', 1, 40, @migration_batch_id, 0, @migration_user, @migration_user),
  ('PROPOSITION', 'Proposition', 0, 50, @migration_batch_id, 0, @migration_user, @migration_user),
  ('SOURCE', 'Source', 0, 60, @migration_batch_id, 0, @migration_user, @migration_user)
ON DUPLICATE KEY UPDATE
  group_name = VALUES(group_name),
  is_mandatory = VALUES(is_mandatory),
  sort_order = VALUES(sort_order),
  status = 0,
  source_batch_id = VALUES(source_batch_id),
  updated_by = VALUES(updated_by),
  updated_date = CURRENT_TIMESTAMP;

UPDATE iic_msg_tag_group
SET status = -1, updated_by = @migration_user, updated_date = CURRENT_TIMESTAMP
WHERE @lead93_rollback = 1
  AND source_batch_id = @migration_batch_id;

