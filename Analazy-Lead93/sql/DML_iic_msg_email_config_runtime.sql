-- Runtime mapper template for Copy and Create. This file is not part of the
-- DBA deployment sequence. The Service generates :new_email_code and validates
-- the complete submitted snapshot before opening the write transaction.

-- Insert the independent Template B master row. copy_from_email_code records the
-- immutable source A for the management-side publish reminder only. It is not a
-- replacement, visibility, status-cascade, or content-Version relationship.
INSERT INTO iic_msg_email_config (module_code, scenario_code, email_code, email_name, description, email_status, tenant_id, created_by, created_date, updated_by, updated_date, status, channel, channel_name, send_times, latest_send_time, dae_country_code, is_custom_branding, is_campaign, category_id, copy_from_email_code)
VALUES (:module_code, :scenario_code, :new_email_code, :email_name, :description, 0, :tenant_id, :operator, CURRENT_TIMESTAMP, :operator, CURRENT_TIMESTAMP, 0, :channel, :channel_name, 0, NULL, :dae_country_code, :is_custom_branding, :is_campaign, :category_id, :source_email_code);

-- Require affected_rows = 1. Do not retry this statement with another generated
-- email_code inside the same request after any downstream write has failed.
