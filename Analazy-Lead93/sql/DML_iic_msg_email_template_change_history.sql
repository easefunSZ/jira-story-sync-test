-- Insert one immutable history row for each successfully changed Template.
-- The Service captures complete snapshots before mutation and after validation.
-- Subcategories and Tags are arrays of {id/code, name}. Each full snapshot uses
-- this stable business-field boundary from iic_msg_email_config:
-- moduleCode, scenarioCode, emailCode, templateName, description, emailStatus,
-- status, channel, channelName, sendTimes, latestSendTime, tenantId,
-- daeCountryCode, customBranding, isCampaign, categoryId and
-- copyFromEmailCode. It also contains Category/Subcategory/Tag display snapshots.
-- changed_fields contains only actual changes as an array of
-- {"field":"templateName","beforeValue":"A","afterValue":"B"} objects.
INSERT INTO iic_msg_email_template_change_history (operation_id, email_code, change_type, changed_fields, before_snapshot, after_snapshot, changed_by, changed_date)
VALUES (:operation_id, :email_code, :change_type, CAST(:changed_fields AS JSON), CAST(:before_snapshot AS JSON), CAST(:after_snapshot AS JSON), :operator, CURRENT_TIMESTAMP);

-- For Category Reassign-and-Delete, reuse one operation_id and execute this
-- INSERT once per affected email_code before the shared transaction commits.

-- For Copy and Create, bind B's new email_code, change_type = 'CREATE',
-- before_snapshot = NULL and after_snapshot = B's complete current Template
-- snapshot. Store A's email_code only in B.config.copy_from_email_code; do not
-- model sourceVersion or an A-to-B lifecycle relationship in change history.
