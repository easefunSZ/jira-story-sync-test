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

-- Metadata Update API: replace the primary Category for one explicit version.
-- The service validates Draft/Active completeness before this statement and
-- executes it in the same transaction as both relation replacements.
UPDATE iic_msg_email_config_version
SET category_id = :category_id,
    updated_by = :operator,
    updated_date = CURRENT_TIMESTAMP
WHERE email_code = :email_code
  AND version = :version
  AND status = 0
  AND version_status IN (1, 3);

-- Require affected_rows = 1. A Draft may pass category_id = NULL; an Active
-- version must pass a valid level-1 Category and complete Published metadata.

-- Save Draft when the selected row is Expired. Reuse V(N), change only the
-- lifecycle state here, and preserve effective_from/effective_until.
UPDATE iic_msg_email_config_version
SET version_status = 3,
    updated_by = :operator,
    updated_date = CURRENT_TIMESTAMP
WHERE email_code = :email_code
  AND version = :version
  AND status = 0
  AND version_status = 2;

-- Save Draft when the selected row is Scheduled. Reuse V(N), change 0 -> 3,
-- and preserve effective_from/effective_until. The existing Save Draft mapper
-- writes the editable version fields in the same business operation.
UPDATE iic_msg_email_config_version
SET version_status = 3,
    updated_by = :operator,
    updated_date = CURRENT_TIMESTAMP
WHERE email_code = :email_code
  AND version = :version
  AND status = 0
  AND version_status = 0;

-- Existing alternative for cancelling a Scheduled version: Version Delete.
-- Soft-delete the row without changing version_status or effective time.
UPDATE iic_msg_email_config_version
SET status = -1,
    updated_by = :operator,
    updated_date = CURRENT_TIMESTAMP
WHERE email_code = :email_code
  AND version = :version
  AND status = 0
  AND version_status = 0;

-- Each branch must require affected_rows = 1. A zero-row result is handled by
-- the existing Version Conflict path. LEAD-93 adds no revision token, edit-lock
-- column, Redis lock, or new conflict mechanism.
