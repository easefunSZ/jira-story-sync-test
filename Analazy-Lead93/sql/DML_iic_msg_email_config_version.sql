-- Email Subject migration. Template Title is config.email_name; Email Subject
-- is version.title.
UPDATE iic_msg_email_config_version v
JOIN tmp_lead93_template_mapping m ON m.email_code = v.email_code
SET v.title = m.new_subject,
    v.updated_by = @migration_user,
    v.updated_date = CURRENT_TIMESTAMP
WHERE v.version_status = 1
  AND v.status = 0
  AND m.new_subject IS NOT NULL;
