INSERT INTO iic_msg_template_tag_rel
  (email_code, group_code, tag_code, source_batch_id, status, created_by, updated_by)
SELECT m.email_code, v.group_code, v.tag_code, @migration_batch_id, 0,
       @migration_user, @migration_user
FROM tmp_lead93_tag_mapping m
JOIN iic_msg_email_config e
  ON e.email_code = m.email_code AND e.status = 0
JOIN iic_msg_tag_value v
  ON v.tag_code = m.tag_code AND v.status = 0
ON DUPLICATE KEY UPDATE
  group_code = VALUES(group_code),
  source_batch_id = VALUES(source_batch_id),
  status = 0,
  updated_by = VALUES(updated_by),
  updated_date = CURRENT_TIMESTAMP;

UPDATE iic_msg_template_tag_rel
SET status = -1, updated_by = @migration_user, updated_date = CURRENT_TIMESTAMP
WHERE @lead93_rollback = 1
  AND source_batch_id = @migration_batch_id;

