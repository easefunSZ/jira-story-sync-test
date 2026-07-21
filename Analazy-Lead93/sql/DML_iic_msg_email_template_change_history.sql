-- Insert one immutable history row for each successfully changed Template.
-- The Service captures complete snapshots before mutation and after validation.
-- Subcategories and Tags are arrays of {id/code, name}; snapshots also include
-- emailCode, Template Name, Description, is_campaign/Format, Channel/Channel Name, Custom Branding,
-- email_status, soft-delete status and the current Category.
INSERT INTO iic_msg_email_template_change_history (operation_id, email_code, change_type, before_snapshot, after_snapshot, changed_by, changed_date)
VALUES (:operation_id, :email_code, :change_type, CAST(:before_snapshot AS JSON), CAST(:after_snapshot AS JSON), :operator, CURRENT_TIMESTAMP);

-- For Category Reassign-and-Delete, reuse one operation_id and execute this
-- INSERT once per affected email_code before the shared transaction commits.

-- For Copy and Create, bind B's new email_code, change_type = 'CREATE',
-- before_snapshot = NULL and after_snapshot = B's complete current Template
-- snapshot. Store A's email_code only in B.config.copy_from_email_code; do not
-- model sourceVersion or an A-to-B lifecycle relationship in change history.
