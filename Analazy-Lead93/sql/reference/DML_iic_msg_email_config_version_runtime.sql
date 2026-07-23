-- LEAD-93 runtime version mapper templates. This file is not part of the DBA
-- deployment sequence.

-- Category/Subcategory/Tag are Template-level current attributes and therefore
-- are not copied, replaced or deleted by Version lifecycle operations.

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

-- Each UPDATE branch must require affected_rows = 1. A zero-row result is handled by
-- the existing Version Conflict path. LEAD-93 adds no revision token, edit-lock
-- column, Redis lock, or new conflict mechanism.

-- Copy and Create: insert the independent Template B V1 Draft after its config
-- row has been inserted. file_keys/thumbnail_key are reference values only; this
-- operation does not copy S3 objects or iic_msg_file_upload rows.
INSERT INTO iic_msg_email_config_version (module_code, scenario_code, email_code, version, effective_way, effective_from, effective_until, title, edit_mode, email_content, text_content, version_status, tenant_id, created_by, created_date, updated_by, updated_date, status, file_keys, thumbnail_key, dae_country_code)
VALUES (:module_code, :scenario_code, :new_email_code, 'V1', NULL, NULL, NULL, :title, :edit_mode, :email_content, :text_content, 3, :tenant_id, :operator, CURRENT_TIMESTAMP, :operator, CURRENT_TIMESTAMP, 0, :file_keys, :thumbnail_key, :dae_country_code);

-- Require affected_rows = 1. The config Insert, this Insert, Metadata relation
-- Inserts and CREATE History Insert are one transaction and roll back together.
