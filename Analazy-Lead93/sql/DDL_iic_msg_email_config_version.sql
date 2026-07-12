-- LEAD-93 one-time DDL: correct status comment and add list/scheduler indexes.
ALTER TABLE iic_msg_email_config_version
  MODIFY COLUMN version_status int NOT NULL
    COMMENT '版本状态(0预约，1生效，2过期，3草稿)',
  ADD KEY idx_email_version_active
    (version_status, status, email_code, updated_date),
  ADD KEY idx_email_version_schedule
    (version_status, status, effective_from);

