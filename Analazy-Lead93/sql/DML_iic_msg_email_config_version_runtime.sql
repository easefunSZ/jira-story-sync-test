-- LEAD-93 runtime version mapper templates. This file is not part of the DBA
-- deployment sequence.

-- Initialize the main Category after the existing Save Draft flow has inserted
-- a new Working Copy version from the current Active version. Run in the same
-- transaction as the Draft insert and relation copies below.
UPDATE iic_msg_email_config_version draft
JOIN iic_msg_email_config_version active
  ON active.email_code = draft.email_code
 AND active.version = :active_version
 AND active.status = 0
 AND active.version_status = 1
SET draft.category_id = active.category_id,
    draft.updated_by = :operator,
    draft.updated_date = CURRENT_TIMESTAMP
WHERE draft.email_code = :email_code
  AND draft.version = :draft_version
  AND draft.status = 0
  AND draft.version_status = 3;

-- The service must require affected_rows = 1. This initialization runs only
-- when a new Draft Working Copy is inserted, not when updating an existing Draft.

-- Cancel Schedule. The Scheduled row is restored to Draft before editing.
UPDATE iic_msg_email_config_version
SET version_status = 3,
    effective_from = NULL,
    effective_until = NULL,
    updated_by = :operator,
    updated_date = CURRENT_TIMESTAMP
WHERE email_code = :email_code
  AND version = :version
  AND status = 0
  AND version_status = 0;

-- The service must require affected_rows = 1 and reject Save Draft while the
-- selected version remains version_status = 0.
