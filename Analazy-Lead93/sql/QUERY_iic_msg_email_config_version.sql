-- More than one Active version per logical template; expected 0 rows.
SELECT email_code, COUNT(*) AS active_count
FROM iic_msg_email_config_version
WHERE status = 0
  AND version_status = 1
GROUP BY email_code
HAVING COUNT(*) > 1;

-- More than one Draft Working Copy per logical template. The normal UI path
-- prevents this, but the current backend/database do not enforce uniqueness.
-- Any returned row is an accepted As-Is risk that requires manual investigation.
SELECT email_code, COUNT(*) AS draft_count
FROM iic_msg_email_config_version
WHERE status = 0
  AND version_status = 3
GROUP BY email_code
HAVING COUNT(*) > 1;

-- Invalid persisted lifecycle timestamps for non-Draft versions;
-- expected 0 rows. An overdue Schedule remains valid until the scheduler runs.
SELECT id, email_code, version, version_status,
       effective_from, effective_until
FROM iic_msg_email_config_version
WHERE status = 0
  AND (
    (version_status = 0 AND effective_from IS NULL)
    OR (version_status = 1
        AND (effective_from IS NULL OR effective_until IS NOT NULL))
    OR (version_status = 2 AND effective_until IS NULL)
  );

-- Scheduler candidate query used by changeVersionStatusByEffectiveFrom().
SELECT id, email_code, version, effective_from
FROM iic_msg_email_config_version
WHERE version_status = 0
  AND status = 0
  AND effective_from <= CURRENT_TIMESTAMP
ORDER BY effective_from, id;

-- Copy and Create source precondition. Execute inside the Copy transaction before
-- any B Insert. Exactly one row must match; otherwise return COPY_SOURCE_NOT_ACTIVE.
-- FOR UPDATE prevents the source Active selection from changing until B commits.
SELECT c.email_code, c.email_name, c.description, c.is_campaign, c.channel, c.channel_name, c.is_custom_branding, c.category_id,
       v.version, v.title, v.edit_mode, v.email_content, v.text_content, v.file_keys, v.thumbnail_key
FROM iic_msg_email_config c
JOIN iic_msg_email_config_version v ON v.email_code = c.email_code AND v.status = 0 AND v.version_status = 1
WHERE c.email_code = :source_email_code
  AND c.status = 0
  AND c.email_status = 1
  AND v.version = :source_version
FOR UPDATE;
