INSERT INTO iic_msg_template_metadata
  (email_code, category_id, source_batch_id, status, created_by, updated_by)
SELECT m.email_code, c.id, @migration_batch_id, 0, @migration_user, @migration_user
FROM tmp_lead93_template_mapping m
JOIN iic_msg_email_config e
  ON e.email_code = m.email_code AND e.status = 0
JOIN iic_msg_category_config c
  ON c.category_code = m.category_code
 AND c.flag = @template_category_flag
 AND c.category_level = 1
 AND c.is_deleted = 0
ON DUPLICATE KEY UPDATE
  category_id = VALUES(category_id),
  source_batch_id = VALUES(source_batch_id),
  status = 0,
  updated_by = VALUES(updated_by),
  updated_date = CURRENT_TIMESTAMP;

UPDATE iic_msg_template_metadata
SET status = -1, updated_by = @migration_user, updated_date = CURRENT_TIMESTAMP
WHERE @lead93_rollback = 1
  AND source_batch_id = @migration_batch_id;

