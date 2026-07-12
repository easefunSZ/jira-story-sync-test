-- LEAD-93 one-time DDL: Published list filtering and stable sorting.
ALTER TABLE iic_msg_email_config
  ADD KEY idx_email_config_published
    (status, email_status, is_campaign, updated_date, email_code);

