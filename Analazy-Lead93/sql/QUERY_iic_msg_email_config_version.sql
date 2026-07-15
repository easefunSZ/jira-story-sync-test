-- More than one Active version per logical template; expected 0 rows.
SELECT email_code, COUNT(*) AS active_count
FROM iic_msg_email_config_version
WHERE status = 0
  AND version_status = 1
GROUP BY email_code
HAVING COUNT(*) > 1;

-- More than one Draft Working Copy per logical template; expected 0 rows.
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
